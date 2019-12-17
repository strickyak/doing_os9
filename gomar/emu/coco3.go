// +build coco3

package emu

import (
	"github.com/strickyak/doing_os9/gomar/sym"

	"bytes"
	"log"
	"fmt"
	"strings"
)

// While booting OS9 Level2, the screen seems to be doubleByte
// at 07c000 to 07d000.  Second line begins at 07c0a0,
// that is 160 bytes from start, or 80 doubleBytes.
// 4096 div 160 is 25.6 lines.

const P_Path = sym.P_Path

const MmuDefaultStartAddr = (0x38 << 13)

const TraceMem = false // TODO: restore this some day.

var GimeVertIrqEnable bool
var MmuEnable bool
var MmuTask byte
var MmuMap [2][8]byte

func InitHardware() {
	Coco3Contract()
}

var videoEpoch int64

func FireTimerInterrupt() {
	if GimeVertIrqEnable {
		irqs_pending |= IRQ_PENDING
		Waiting = false
	}
	videoEpoch++
	if videoEpoch%10 == 1 {
		PublishVideoText()
	}
}

// Coco3Contract ensures the contract between Coco3's disk booting mechanism
// and the OS/9 Level2 kernel, documented at
// nitros9/level2/modules/kernel/ccbkrn.txt
func Coco3Contract() {

	// Initialize Memory Map thus: 00 39 3a 3b 3c 3d 3e 3f
	for task := 0; task < 2; task++ {
		MmuMap[task][0] = 0x00 // Exception.
		for page := 1; page < 8; page++ {
			MmuMap[task][page] = byte(0x38 + page)
		}
	}
	// Initialize physical block 3b to spaces, except 0x0008 at the beginning.
	const block3b = 0x3b * 0x2000
	mem[block3b+0] = 0x00
	mem[block3b+1] = 0x08
	for i := 2; i < 0x2000; i++ {
		mem[block3b+i] = ' '
	}
	/*   starting at 0xff90:
	6c      init0
	00      init1
	00      irq enable
	00      firq enable
	0900    timer register
	0000    unused
	0320    screen settings
	0000    ????
	00      ????
	ec01    physical video address (block 3b offset 0x0008 )
	00      horizontal offset / scroll

	A mirror of these bytes will appear at 0x0090-0x009f in the DP
	*/
	for i, b := range []byte{0x6c, 0, 0, 0, 9, 0, 0, 0, 3, 0x20, 0, 0, 0, 0x3c, 1, 0} {
		PutIOByte(Word(0xFF90+i), b)
		mem[0x90+i] = b // Probably don't need to set the mirror, but doing it anyway.
	}
}

func ExplainMMU() string {
	return F("mmu:%d task:%d : (t0) %02x %02x %02x %02x  %02x %02x %02x %02x : (t1) %02x %02x %02x %02x  %02x %02x %02x %02x :",
		CondI(MmuEnable, 1, 0),
		MmuTask&1,
		MmuMap[0][0],
		MmuMap[0][1],
		MmuMap[0][2],
		MmuMap[0][3],
		MmuMap[0][4],
		MmuMap[0][5],
		MmuMap[0][6],
		MmuMap[0][7],
		MmuMap[1][0],
		MmuMap[1][1],
		MmuMap[1][2],
		MmuMap[1][3],
		MmuMap[1][4],
		MmuMap[1][5],
		MmuMap[1][6],
		MmuMap[1][7],
	)
}

func MapAddrWithMapping(logical Word, m Mapping) int {
	slot := 7 & (logical >> 13)
	low := int(logical & 0x1FFF)
	physicalPage := m[slot]
	return (int(physicalPage) << 13) | low
}

func MapAddr(logical Word, quiet bool) int {
	if logical >= 0xFE00 {
		return (0x3F << 13) | int(logical)
	}
	var z int
	if MmuEnable {
		slot := byte(logical >> 13)
		low := int(logical & 0x1FFF)
		physicalPage := MmuMap[MmuTask][slot]
		z = (int(physicalPage) << 13) | low
		if !quiet && TraceMem {
			L("\t\t\t\t\t\t MapAddr: %04x -> %06x ... task=%x  slot=%x  page=%x", logical, z, MmuTask, slot, physicalPage)
		}
		return z
	} else {
		if z < 0x2000 {
			z = int(logical)
		} else {
			z = MmuDefaultStartAddr + int(logical)
		}
		if !quiet && TraceMem {
			L("\t\t\t\t\t\t MapAddr: %04x -> %06x ... default map", logical, z)
		}
		return z
	}
}

// B is fundamental func to get byte.  Hack register access into here.
func B(addr Word) byte {
	var z byte
	mapped := MapAddr(addr, false)
	if AddressInDeviceSpace(addr) {
		z = GetIOByte(addr)
		LogIO("GetIO (%06x) %04x -> %02x : %c %c", mapped, addr, z, H(z), T(z))
		mem[mapped] = z
	} else {
		z = mem[mapped]
	}
	if TraceMem {
		L("\t\t\t\tGetB (%06x) %04x -> %02x : %c %c", mapped, addr, z, H(z), T(z))
	}
	return z
}

func PokeB(addr Word, b byte) {
	mapped := MapAddr(addr, true)
	mem[mapped] = b
}

func PeekB(addr Word) byte {
	var z byte
	mapped := MapAddr(addr, true)
	z = mem[mapped]
	return z
}

// PutB is fundamental func to set byte.  Hack register access into here.
func PutB(addr Word, x byte) {
	mapped := MapAddr(addr, false)
	old := mem[mapped]
	mem[mapped] = x
	if TraceMem {
		LogIO("\t\t\t\tPutB (%06x) %04x <- %02x (was %02x)", mapped, addr, x, old)
	}
	if AddressInDeviceSpace(addr) {
		PutIOByte(addr, x)
		LogIO("PutIO (%06x) %04x <- %02x (was %02x)", mapped, addr, x, old)
	}
}

func PeekWPhys(addr int) Word {
	if addr+1 > len(mem) {
		panic(addr)
		// return 0
	}
	return Word(mem[addr])<<8 | Word(mem[addr+1])
}

//////// DUMP

func DoDumpAllMemoryPhys() {
	var i, j int
	var buf bytes.Buffer
	L("\n#DumpAllMemoryPhys(\n")
	n := len(mem)
	for i = 0; i < n; i += 32 {
		if i&0x1FFF == 0 {
			L("[%02x] %06x:", i>>13, i)
		}
		// Look ahead for something interesting on this line.
		something := false
		for j = 0; j < 32; j++ {
			x := mem[i+j]
			// if x != 0 && x != ' ' //
			if x != 0 {
				something = true
				break
			}
		}

		if !something {
			continue
		}

		buf.Reset()
		Z(&buf, "%06x: ", i)
		for j = 0; j < 32; j += 8 {
			Z(&buf,
				"%02x%02x %02x%02x %02x%02x %02x%02x  ",
				mem[i+j+0], mem[i+j+1], mem[i+j+2], mem[i+j+3],
				mem[i+j+4], mem[i+j+5], mem[i+j+6], mem[i+j+7])
		}
		buf.WriteRune(' ')
		for j = 0; j < 32; j++ {
			ch := 0x7F & mem[i+j]
			var r rune = '.'
			if ' ' <= ch && ch <= '~' {
				r = rune(ch)
			}
			buf.WriteRune(r)
		}
		L("%s\n", buf.String())
	}
	L("#DumpAllMemoryPhys)\n")
}

func DoExplainMmuBlock(i int) {
	blk := (i >> 13) & 0x3F
	blkPhys := MmuMap[MmuTask][blk]
	L("[%x -> %02x] %06x", blk, blkPhys, MapAddr(Word(i), true))
}

func DoDumpPageZero() {
	mmut := MmuTask
	MmuTask = 0
	map00 := MmuMap[0][0]
	MmuMap[0][0] = 0
	defer func() {
		MmuTask = mmut
		MmuMap[0][0] = map00
	}()

	L("PageZero:\n")

	/* some Level1:
	L("PageZero: FreeBitMap=%x:%x MemoryLimit=%x ModDir=%x RomBase=%x\n",
		W(sym.D_FMBM), W(sym.D_FMBM+2), W(sym.D_MLIM), W(sym.D_ModDir), W(sym.D_Init))
	*/
	L("  D_SWI3=%x D_SWI2=%x FIRQ=%x IRQ=%x SWI=%x NMI=%x SvcIRQ=%x Poll=%x\n",
		W(sym.D_SWI3), W(sym.D_SWI2), W(sym.D_FIRQ), W(sym.D_IRQ), W(sym.D_SWI), W(sym.D_NMI), W(sym.D_SvcIRQ), W(sym.D_Poll))
	/* some Level1:
	L("  BTLO=%x BTHI=%x  IO Free Mem Lo=%x Hi=%x D_DevTbl=%x D_PolTbl=%x D_PthDBT=%x D_Proc=%x\n",
		W(sym.D_BTLO), W(sym.D_BTHI), W(sym.D_IOML), W(sym.D_IOMH), W(sym.D_DevTbl), W(sym.D_PolTbl), W(sym.D_PthDBT), W(sym.D_Proc))
	*/
	L("  D_Slice=%x D_TSlice=%x\n",
		W(sym.D_Slice), W(sym.D_TSlice))

	var buf bytes.Buffer
	Z(&buf, " D.Tasks=%04x", PeekW(sym.D_Tasks))
	Z(&buf, " D.TmpDAT=%04x", PeekW(sym.D_TmpDAT))
	Z(&buf, " D.Init=%04x", PeekW(sym.D_Init))
	Z(&buf, " D.Poll=%04x", PeekW(sym.D_Poll))
	Z(&buf, " D.Tick=%02x", PeekB(sym.D_Tick))
	Z(&buf, " D.Slice=%02x", PeekB(sym.D_Slice))
	Z(&buf, " D.TSlice=%02x", PeekB(sym.D_TSlice))
	Z(&buf, " D.Boot=%02x", PeekB(sym.D_Boot))
	Z(&buf, " D.MotOn=%02x", PeekB(sym.D_MotOn))
	Z(&buf, " D.ErrCod=%02x", PeekB(sym.D_ErrCod))
	Z(&buf, " D.Daywk=%02x", PeekB(sym.D_Daywk))
	Z(&buf, " D.TkCnt=%02x", PeekB(sym.D_TkCnt))
	Z(&buf, " D.BtPtr=%04x", PeekW(sym.D_BtPtr))
	Z(&buf, " D.BtSz=%04x", PeekW(sym.D_BtSz))
	L("%s", buf.String())
	buf.Reset()

	Z(&buf, " D.CRC=%02x", PeekB(sym.D_CRC))
	Z(&buf, " D.Tenths=%02x", PeekB(sym.D_Tenths))
	Z(&buf, " D.Task1N=%02x", PeekB(sym.D_Task1N))
	Z(&buf, " D.Quick=%02x", PeekB(sym.D_Quick))
	Z(&buf, " D.QIRQ=%02x", PeekB(sym.D_QIRQ))
	Z(&buf, " D.BlkMap=%04x,%04x", PeekW(sym.D_BlkMap), PeekW(sym.D_BlkMap+2))
	Z(&buf, " D.ModDir=%04x,%04x", PeekW(sym.D_ModDir), PeekW(sym.D_ModDir+2))
	Z(&buf, " D.PrcDBT=%04x", PeekW(sym.D_PrcDBT))
	Z(&buf, " D.SysPrc=%04x", PeekW(sym.D_SysPrc))
	Z(&buf, " D.SysDAT=%04x", PeekW(sym.D_SysDAT))
	// Z(&buf, " D.Mem=%04x", PeekW(sym.D_Mem))
	Z(&buf, " D.Proc=%04x", PeekW(sym.D_Proc))
	Z(&buf, " D.AProcQ=%04x", PeekW(sym.D_AProcQ))
	Z(&buf, " D.WProcQ=%04x", PeekW(sym.D_WProcQ))
	Z(&buf, " D.SProcQ=%04x", PeekW(sym.D_SProcQ))
	L("%s", buf.String())
	buf.Reset()

	Z(&buf, " D.ModEnd=%04x", PeekW(sym.D_ModEnd))
	Z(&buf, " D.ModDAT=%04x", PeekW(sym.D_ModDAT))
	Z(&buf, " D.CldRes=%04x", PeekW(sym.D_CldRes))
	Z(&buf, " D.BtBug=%04x%02x", PeekW(sym.D_BtBug), PeekB(sym.D_BtBug+2))
	Z(&buf, " D.Pipe=%04x", PeekW(sym.D_Pipe))

	Z(&buf, " D.QCnt=%02x", PeekB(sym.D_QCnt))
	Z(&buf, " D.DevTbl=%04x", PeekW(sym.D_DevTbl))
	Z(&buf, " D.PolTbl=%04x", PeekW(sym.D_PolTbl))
	Z(&buf, " D.PthDBT=%04x", PeekW(sym.D_PthDBT))
	Z(&buf, " D.DMAReq=%02x", PeekB(sym.D_DMAReq))
	L("%s", buf.String())
	buf.Reset()
}

func DoDumpPathDesc(a Word) {
	L("a=%04x", a)
	if 0 == B(a+sym.PD_PD) {
		return
	}
	L("Path @%x: #=%x mode=%x count=%x dev=%x\n", a, B(a+sym.PD_PD), B(a+sym.PD_MOD), B(a+sym.PD_CNT), W(a+sym.PD_DEV))
	L("   curr_process=%x caller_reg_stack=%x buffer=%x  dev_type=%x\n",
		B(a+sym.PD_CPR), B(a+sym.PD_RGS), B(a+sym.PD_BUF), B(a+sym.PD_DTP))

	// the Device Table Entry:
	dev := W(a + sym.PD_DEV)
	var buf bytes.Buffer
	Z(&buf, "   dev: @%x driver_mod=%x=%s ",
		dev, W(dev+sym.V_DRIV), ModuleName(W(dev+sym.V_DRIV)))
	Z(&buf, "driver_static_store=%x descriptor_mod=%x=%s ",
		W(dev+sym.V_STAT), W(dev+sym.V_DESC), ModuleName(W(dev+sym.V_DESC)))
	Z(&buf, "file_man=%x=%s use=%d\n",
		W(dev+sym.V_FMGR), ModuleName(W(dev+sym.V_FMGR)), B(dev+sym.V_USRS))
	L("%s", buf.String())

	if false && paranoid {
		if B(a+sym.PD_PD) > 10 {
			panic("PD_PD")
		}
		if B(a+sym.PD_CNT) > 20 {
			panic("PD_CNT")
		}
		if B(a+sym.PD_CPR) > 10 {
			panic("PD_CPR")
		}
	}
}

func DoDumpAllPathDescs() {
	if true || Level == 1 {
		p := W(sym.D_PthDBT)
		if 0 == p {
			return
		}

		for i := Word(0); i < 32; i++ {
			q := W(p + i*2)
			L("PathDesc[%x]: %x", i, q)
			if q != 0 {

				for j := Word(0); j < 4; j++ {
					k := i*4 + j
					L("........[%x]: %x", j, k)
					if k == 0 {
						continue
					} // There is no path desc 0 (it's the table).
					DoDumpPathDesc(q + j*64)
				}

			}
		}
	}
}

func DoDumpProcDesc(a Word) {
	L("a=%04x", a)
	switch Level {
	case 1, 2:
		{
			mod := PeekW(a + sym.P_PModul)
			name_str := "?"
			mod_str := "?"
			if mod != 0 {
				if Level == 1 {
					name := mod + PeekW(mod+4)
					name_str = Os9String(name)
					mod_str = F("%q @%04x", name_str, mod)
				} else if Level == 2 {
					m := GetMapping(a + sym.P_DATImg)
					modPhys := MapAddrWithMapping(mod, m)
					modPhysPlus4 := PeekWPhys(modPhys + 4)
					if modPhysPlus4 > 0 {
						name := mod + modPhysPlus4
						name_str = Os9StringWithMapping(name, m)
						mod_str = F("%q @%04x %v", name_str, mod, m)
					}
				}
			}
			L("Process @%x: id=%x pid=%x sid=%x cid=%x module=%s", a, B(a+sym.P_ID), B(a+sym.P_PID), B(a+sym.P_SID), B(a+sym.P_CID), mod_str)
			/* some Level1
			L("   sp=%x chap=%x Addr=%x PagCnt=%x User=%x Pri=%x Age=%x State=%x",
				W(a+sym.P_SP), B(a+sym.P_CHAP), B(a+sym.P_ADDR), B(a+sym.P_PagCnt), W(a+sym.P_User), B(a+sym.P_Prior), B(a+sym.P_Age), B(a+sym.P_State))
			*/
			L("   Queue=%x IOQP=%x IOQN=%x Signal=%x SigVec=%x SigDat=%x",
				W(a+sym.P_Queue), B(a+sym.P_IOQP), B(a+sym.P_IOQN), B(a+sym.P_Signal), B(a+sym.P_SigVec), B(a+sym.P_SigDat))
			L("   DIO %x %x %x %x %x %x PATH %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x",
				W(a+sym.P_DIO), W(a+sym.P_DIO+2), W(a+sym.P_DIO+4),
				W(a+sym.P_DIO+6), W(a+sym.P_DIO+8), W(a+sym.P_DIO+10),
				B(a+sym.P_Path+0), B(a+sym.P_Path+1), B(a+sym.P_Path+2), B(a+sym.P_Path+3),
				B(a+sym.P_Path+4), B(a+sym.P_Path+5), B(a+sym.P_Path+6), B(a+sym.P_Path+7),
				B(a+sym.P_Path+8), B(a+sym.P_Path+9), B(a+sym.P_Path+10), B(a+sym.P_Path+11),
				B(a+sym.P_Path+12), B(a+sym.P_Path+13), B(a+sym.P_Path+14), B(a+sym.P_Path+15))
			if W(a+sym.P_Queue) != 0 {
				// If current proc, it has no queue.
				// Other procs are in a queue.
				if W(sym.D_Proc) != a {
					DoDumpProcDesc(W(a + sym.P_Queue))
				}
			}

			if paranoid {
				if B(a+sym.P_ID) > 10 {
					panic("P_ID")
				}
				if B(a+sym.P_PID) > 10 {
					panic("P_PID")
				}
				if B(a+sym.P_SID) > 10 {
					panic("P_SID")
				}
				if B(a+sym.P_CID) > 10 {
					panic("P_CID")
				}
				if W(a+sym.P_User) > 10 {
					panic("P_User")
				}
			}
		}
	}
}

func DoDumpProcesses() {
	if W(sym.D_Proc) != 0 {
		L("D_Proc: CURRENT:")
		DoDumpProcDesc(W(sym.D_Proc))
	}
	if W(sym.D_AProcQ) != 0 {
		L("D_AProcQ: Active:")
		DoDumpProcDesc(W(sym.D_AProcQ))
	}
	if W(sym.D_WProcQ) != 0 {
		L("D_WProcQ: Wait:")
		DoDumpProcDesc(W(sym.D_WProcQ))
	}
	if W(sym.D_SProcQ) != 0 {
		L("D_SProcQ: Sleep")
		DoDumpProcDesc(W(sym.D_SProcQ))
	}
}

func WithMmu(task byte, fn func()) {
	t := MmuTask
	MmuTask = task
	defer func() {
		MmuTask = t
	}()
	fn()
}

func PutGimeIOByte(a Word, b byte) {
	switch a {
	default:
		log.Panicf("UNKNOWN PutIOByte address: 0x%04x", a)

	case 0xFFB0,
		0xFFB1,
		0xFFB2,
		0xFFB3,
		0xFFB4,
		0xFFB5,
		0xFFB6,
		0xFFB7,
		0xFFB8,
		0xFFB9,
		0xFFBA,
		0xFFBB,
		0xFFBC,
		0xFFBD,
		0xFFBE,
		0xFFBF:
		L("B0: palettes <- %0x2", b)

	case 0xFFD9:
		L("D9: Cpu Speed <- %0x2", b)

	case 0xFF90:
		MmuEnable = 0 != (b & 0x40)
		L("GIME MmuEnable <- %v", MmuEnable)

	case 0xFF91:
		MmuTask = b & 0x01
		L("GIME MmuTask <- %v; clock rate <- %v", MmuTask, 0 != (b&0x40))

	case 0xFF92:
		// 0x08: Vertical IRQ.  0x01: Cartridge.
		if (b &^ 0x09) != 0 {
			log.Panicf("GIME IRQ Enable for unsupported emulated bits: %04x %02x", a, b)
		}
		if (b & 0x08) != 0 {
			GimeVertIrqEnable = true
		} else {
			GimeVertIrqEnable = false
		}

	case 0xFF93:
		if b != 0 {
			log.Panicf("GIME FIRQ Enable for unsupported emulated bits: %04x %02x", a, b)
		}

	case 0xFF94,
		0xFF95,
		0xFF96,
		0xFF97,
		0xFF98,
		0xFF99,
		0xFF9A,
		0xFF9B,
		0xFF9C,
		0xFF9D,
		0xFF9E,
		0xFF9F:
		L("GIME %x <= %02x", a, b)

	case 0xFFA0,
		0xFFA1,
		0xFFA2,
		0xFFA3,
		0xFFA4,
		0xFFA5,
		0xFFA6,
		0xFFA7,
		0xFFA8,
		0xFFA9,
		0xFFAA,
		0xFFAB,
		0xFFAC,
		0xFFAD,
		0xFFAE,
		0xFFAF:
		{
			task := byte((a >> 3) & 1)
			slot := byte(a & 7)
			was := MmuMap[task][slot]
			MmuMap[task][slot] = b & 0x3F
			L("GIME MmuMap[%d][%d] <- %02x  (was %02x)", task, slot, b, was)
			// if task == 0 && slot == 7 && b != 0x3F {
			// panic("bad MmuMap[0][7]")
			// }
			// yak ddt TODO
			// MmuMap[0][7] = 0x3F // Never change slot 7.
			// MmuMap[1][7] = 0x3F // Never change slot 7.
		}

	}
}
func MemoryModuleOf(addr Word) (name string, offset Word) {
	addrPhys := MapAddr(addr, true)
	addr32 := uint32(addrPhys)

	// First scan for initial modules.
	for _, m := range InitialModules {
		if addr32 >= m.Addr && addr32 < (m.Addr+m.Len) {
			return m.Id(), Word(addr32 - m.Addr)
		}
	}

	modulePointerOffset := Word(4)
	start := PeekW(sym.D_ModDir)
	limit := PeekW(sym.D_ModDir + 2)
	i := start

	mmut := MmuTask
	MmuTask = 0
	map00 := MmuMap[0][0]
	MmuMap[0][0] = 0
	defer func() {
		MmuTask = mmut
		MmuMap[0][0] = map00
	}()

	for ; i < limit; i += 4 + modulePointerOffset {
		mod := PeekW(i + modulePointerOffset)
		if mod == 0 {
			continue
		}

		moduleDatImagePtr := PeekW(i + 0)
		if moduleDatImagePtr < 256 {
			continue
		}
		m := GetMapping(moduleDatImagePtr)
		end := mod + PeekWWithMapping(mod+2, m)
		//name := mod + PeekWWithMapping(mod+4, m)

		modPhys := MapAddrWithMapping(mod, m)
		endPhys := MapAddrWithMapping(end, m)
		if modPhys <= addrPhys && addrPhys < endPhys {
			// return Os9StringWithMapping(name, m), Word(addrPhys - modPhys)
			return ModuleId(mod, modPhys, m), Word(addrPhys - modPhys)
		}
	}
	return "", 0 // No module found for the addr.
}

func ModuleId(mod Word, mp int, m Mapping) string {
	name := mod + PeekWWithMapping(mod+4, m)
	modname := Os9StringWithMapping(name, m)
	sz := int(PeekWWithMapping(mod+2, m))
	return fmt.Sprintf("%s.%04x%02x%02x%02x", strings.ToLower(modname), sz, mem[mp+sz-3], mem[mp+sz-2], mem[mp+sz-1])
}

func MemoryModules() {
	mmut := MmuTask
	MmuTask = 0
	map00 := MmuMap[0][0]
	MmuMap[0][0] = 0
	defer func() {
		MmuTask = mmut
		MmuMap[0][0] = map00
	}()

	modulePointerOffset := Word(4)
	start := PeekW(sym.D_ModDir)
	limit := PeekW(sym.D_ModDir + 2)
	i := start

	DumpAllMemory()
	DumpPageZero()
	DumpProcesses()
	DumpAllPathDescs()
	L("\n#MemoryModules(")
	var buf bytes.Buffer
	for ; i < limit; i += 4 + modulePointerOffset {
		mod := PeekW(i + modulePointerOffset)
		if mod == 0 {
			continue
		}

		moduleDatImagePtr := PeekW(i + 0)
		if moduleDatImagePtr < 256 {
			continue
		}
		m := GetMapping(moduleDatImagePtr)
		end := mod + PeekWWithMapping(mod+2, m)
		name := mod + PeekWWithMapping(mod+4, m)

		Z(&buf, "%s %x:%x [%x:%x,%x,%x,%x] %v\n", Os9StringWithMapping(name, m), mod, end, i, PeekW(i), PeekW(i+2), PeekW(i+4), PeekW(i+6), m)
	}
	L("%s", buf.String())
	L("#MemoryModules)")
}

func HandleBtBug() {
	if pcreg == sym.D_BtBug {
		if len(DebugString) < 20 {
			DebugString += string(rune(GetAReg() & 0x7F))
		}
	}
}
