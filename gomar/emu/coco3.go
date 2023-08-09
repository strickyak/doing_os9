//go:build coco3
// +build coco3

package emu

import (
	"github.com/strickyak/doing_os9/gomar/display"
	"github.com/strickyak/doing_os9/gomar/sym"

	"bytes"
	"fmt"
	"log"
	"strings"
)

const TraceMem = false // TODO: restore this some day.

var GimeVertIrqEnable bool
var MmuEnable bool
var MmuTask byte
var MmuMap [2][8]byte

var BitCoCo12Compat bool
var BitFixedFExx bool
var BitMC0, BitMC1 bool // Rom Mode: low bits at FF90

var videoEpoch int64

var DisabledMmuMap = []byte{0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f}

////////////////////////////////////////

func FireTimerInterrupt() {
	if Level == 1 || GimeVertIrqEnable {
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
func InitHardware() {
	if usedRom {
		Coco3ContractRaw()
	} else {
		Coco3ContractForDos()
	}
}
func InitializeMemoryMap() {
	for task := 0; task < 2; task++ {
		for block, phys := range DisabledMmuMap {
			MmuMap[task][block] = phys
		}
	}
}

func Coco3ContractRaw() {
	DisabledMmuMap = []byte{0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f}
	InitializeMemoryMap()
}

func Coco3ContractForDos() {
	DisabledMmuMap = []byte{0x00, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f}
	InitializeMemoryMap()

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
		// DONT // mem[0x90+i] = b // Probably don't need to set the mirror, but doing it anyway.
	}
}

type Mapping [8]Word

func GetMapping(addr Word) Mapping {
	// Mappings are in SysMem (block 0).
	return Mapping{
		// TODO: drop the "0x3F &".
		0x3F & SysMemW(addr),
		0x3F & SysMemW(addr+2),
		0x3F & SysMemW(addr+4),
		0x3F & SysMemW(addr+6),
		0x3F & SysMemW(addr+8),
		0x3F & SysMemW(addr+10),
		0x3F & SysMemW(addr+12),
		0x3F & SysMemW(addr+14),
	}
}

func WithMmuTask(task byte, fn func()) {
	tmp := MmuTask
	MmuTask = task
	defer func() {
		MmuTask = tmp
	}()
	fn()
}

func GetMappingTask0(addr Word) Mapping {
	// Use Task 0 for the mapping.
	tmp := MmuTask
	MmuTask = 0
	defer func() {
		MmuTask = tmp
	}()

	return Mapping{
		// TODO: drop the "0x3F &".
		0x3F & PeekW(addr),
		0x3F & PeekW(addr+2),
		0x3F & PeekW(addr+4),
		0x3F & PeekW(addr+6),
		0x3F & PeekW(addr+8),
		0x3F & PeekW(addr+10),
		0x3F & PeekW(addr+12),
		0x3F & PeekW(addr+14),
	}
}
func TaskNumberToMapping(task byte) Mapping {
	dope := PeekW(0x00A1) // D.TskIPt
	dat := PeekW(dope + 2*Word(task))
	var m Mapping
	for i := Word(0); i < 8; i++ {
		m[i] = PeekW(dat + 2*i)
	}
	return m
}
func PeekBWithTask(addr Word, task byte) byte {
	m := TaskNumberToMapping(task)
	return PeekBWithMapping(addr, m)
}
func PeekWWithTask(addr Word, task byte) Word {
	m := TaskNumberToMapping(task)
	return PeekWWithMapping(addr, m)
}
func PeekBWithMapping(addr Word, m Mapping) byte {
	logBlock := (addr >> 13) & 7
	physBlock := m[logBlock]
	ptr := int(addr&0x1FFF) | (int(physBlock) << 13)
	return mem[ptr]
}
func PeekWWithMapping(addr Word, m Mapping) Word {
	hi := PeekBWithMapping(addr, m)
	lo := PeekBWithMapping(addr+1, m)
	return (Word(hi) << 8) | Word(lo)
}

func Os9StringWithMapping(addr Word, m Mapping) string {
	var buf bytes.Buffer
	for {
		var b byte = PeekBWithMapping(addr, m)
		var ch byte = 0x7F & b
		if '!' <= ch && ch <= '~' {
			buf.WriteByte(ch)
		} else {
			break
		}
		if (b & 128) != 0 {
			break
		}
		addr++
	}
	return buf.String()
}

func ExplainMMU() string {
	return F("mmu:%d task:%d [[ %02x %02x %02x %02x  %02x %02x %02x %02x || %02x %02x %02x %02x  %02x %02x %02x %02x ]]",
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
	slot := byte(logical >> 13)
	low := int(logical & 0x1FFF)
	var physicalPage byte

	if BitFixedFExx && logical >= 0xFE00 {
		physicalPage = 0x3F
	} else if logical >= 0xFF00 {
		physicalPage = 0x3F
	} else if MmuEnable {
		physicalPage = MmuMap[MmuTask][slot]
	} else {
		physicalPage = DisabledMmuMap[slot]
	}

	z := (int(physicalPage) << 13) | low

	if !quiet && TraceMem {
		L("\t\t\t\t\t\t MapAddr: %04x -> %06x ... task=%x  slot=%x  page=%x", logical, z, MmuTask, slot, physicalPage)
	}
	return z
}

// B is fundamental func to get byte.  Hack register access into here.
func B(addr Word) byte {
	var z byte
	mapped := MapAddr(addr, false)

	if AddressInDeviceSpace(addr) {
		z = GetIOByte(addr)
		Ld("GetIO (%06x) %04x -> %02x : %c %c", mapped, addr, z, H(z), T(z))
		mem[mapped] = z
	} else {
		z = PeekB(addr)
	}
	if TraceMem {
		L("\t\t\t\tGetB (%06x) %04x -> %02x : %c %c", mapped, addr, z, H(z), T(z))
	}
	if addr >= 0xfff0 { // XXX
		L("\t\t\t\tGetB (%06x) %04x -> %02x", mapped, addr, z)
		L("\t\tAllRam=%v enableRom=%v inRomSpace=%v", sam.AllRam, enableRom, MappedAddressInRomSpace(addr, mapped))
	}
	return z
}

func PeekB(addr Word) byte {
	var z byte
	mapped := MapAddr(addr, true)

	if !sam.AllRam && enableRom && MappedAddressInRomSpace(addr, mapped) {
		switch BitMC1 {
		case false:
			if mapped < (0x3E << 13) {
				z = internalRom[mapped&0x3FFF]
			} else {
				z = cartRom[mapped&0x7FFF]
			}
		case true:
			switch BitMC0 {
			case false:
				z = internalRom[mapped&0x7FFF]
			case true:
				z = cartRom[addr&0x7FFF]
			}
		}
	} else {
		z = mem[mapped]
	}
	return z
}

func PokeB(addr Word, x byte) {
	mapped := MapAddr(addr, true)
	if !sam.AllRam && enableRom && MappedAddressInRomSpace(addr, mapped) {
		// cannot write ROM
	} else {
		mem[mapped] = x
	}
}

// PutB is fundamental func to set byte.  Hack register access into here.
func PutB(addr Word, x byte) {
	mapped := MapAddr(addr, false)

	old := mem[mapped]
	mem[mapped] = x
	if TraceMem {
		Ld("\t\t\t\tPutB (%06x) %04x <- %02x (was %02x)", mapped, addr, x, old)
	}
	if addr >= 0xfff0 { // XXX
		L("\t\t\t\tPutB (%06x) %04x <- %02x (was %02x)", mapped, addr, x, old)
	}
	if AddressInDeviceSpace(addr) {
		PutIOByte(addr, x)
		Ld("PutIO (%06x) %04x <- %02x (was %02x)", mapped, addr, x, old)
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
	if !V['p'] {
		return
	}
	var i, j int
	var buf bytes.Buffer
	L("\n#DumpAllMemoryPhys(\n")
	n := len(mem)
	for i = 0; i < n; i += 32 {
		if i&0x1FFF == 0 {
			L("P [%02x] %06x:", i>>13, i)
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
		Z(&buf, "P %06x: ", i)
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

func DoDumpBlockZero() {
	PrettyDumpHex64(0, 0xFF00)
}

func DoDumpPathDesc(a Word) {
	PrettyDumpHex64(a, 0x40)
	if 0 == B(a+sym.PD_PD) {
		return
	}
	pd_pd := B(a + sym.PD_PD)
	if pd_pd > 32 {
		// Doesn't seem likely > 32
		L("???????? PathDesc %x @%x: mode=%x count=%x entry=%x\n", pd_pd, a, B(a+sym.PD_MOD), B(a+sym.PD_CNT), W(a+sym.PD_DEV))
		return
	}

	L("PathDesc %x @%x: mode=%x count=%x entry=%x\n", pd_pd, a, B(a+sym.PD_MOD), B(a+sym.PD_CNT), W(a+sym.PD_DEV))
	L("   curr_process=%x regs=%x buf=%x  dev_type=%x\n",
		B(a+sym.PD_CPR), W(a+sym.PD_RGS), W(a+sym.PD_BUF), B(a+sym.PD_DTP))

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
			L("DoDumpAllPathDescs: D_PthDPT is zero.")
			return
		}
		AssertEQ(p&255, 0, p)
		PrettyDumpHex64(p, 64)

		for i := Word(0); i < 32; i++ {
			q := W(p + i*2)
			if q != 0 {
				// L("PathDesc[%x]: %x", i, q)

				for j := Word(0); j < 4; j++ {
					k := i*4 + j
					// L("........[%x]: %x", j, k)
					if k == 0 {
						continue
					} // There is no path desc 0 (it's the table of allocs).
					DoDumpPathDesc(q + j*64)
				}

			}
		}
	}
}

func DoDumpProcesses() {
	saved_mmut := MmuTask
	MmuTask = 0
	saved_map00 := MmuMap[0][0]
	MmuMap[0][0] = 0
	defer func() {
		MmuTask = saved_mmut
		MmuMap[0][0] = saved_map00
	}()
	///////////////////////////////////
	p := W(sym.D_PrcDBT)
	AssertNE(p, 0)
	AssertEQ(p&255, 0, p)
	PrettyDumpHex64(p, 64)

	for i := 0; i < 64; i++ {
		pg := B(p + Word(i))
		if pg == 0 {
			break
		}
		DoDumpProcDesc(Word(pg)<<8, F("TABLE_%d", i), false)
	}

	///////////////////////////////////

	if W(sym.D_Proc) != 0 {
		DoDumpProcDesc(W(sym.D_Proc), "Current", false)
	}
	if W(sym.D_AProcQ) != 0 {
		// L("D_AProcQ: Active:")
		DoDumpProcDesc(W(sym.D_AProcQ), "ActiveQ", true)
	}
	if W(sym.D_WProcQ) != 0 {
		// L("D_WProcQ: Wait:")
		DoDumpProcDesc(W(sym.D_WProcQ), "WaitQ", true)
	}
	if W(sym.D_SProcQ) != 0 {
		// L("D_SProcQ: Sleep")
		DoDumpProcDesc(W(sym.D_SProcQ), "SleepQ", true)
	}
}

func LPeekB(a Word) uint64 {
	return uint64(PeekB(a))
}

func ExplainColor(b byte) string {
	return F("rgb=$%02x=(%x,%x,%x)", b&63,
		((b&0x20)>>4)|((b&0x04)>>2),
		((b&0x10)>>3)|((b&0x02)>>1),
		((b&0x08)>>2)|((b&0x01)>>0))
}

/*
HRES:
	http://users.axess.com/twilight/sock/gime.html
Horizontal resolution using graphics:
000=16 bytes per row
001=20 bytes per row
010=32 bytes per row
011=40 bytes per row
100=64 bytes per row
101=80 bytes per row
110=128 bytes per row
111=160 bytes per row

When using text:
0x0=32 characters per row
0x1=40 characters per row
1x0=64 characters per row
1x1=80 characters per row
*/

var GraphicsBytesPerRowHRES = []int{16, 20, 32, 40, 64, 80, 128, 160}
var AlphaCharsPerRowHRES = []int{32, 40, 32, 40, 64, 80, 64, 80}

/*
CRES:
	http://users.axess.com/twilight/sock/gime.html
Color Resolution using graphics:
00=2 colors (8 pixels per byte)
01=4 colors (4 pixels per byte)
10=16 colors (2 pixels per byte)
11=Undefined (would have been 256 colors)

When using text:
x0=No color attributes
x1=Color attributes enabled
*/

var GraphicsColorBitsCRES = []int{1, 2, 4, 8}
var AlphaHasAttrsCRES = []bool{false, true, false, true}

var FF92Bits = []string{
	"?", "?", "TimerIRQ", "HorzIRQ", "VertIRQ", "SerialIRQ", "KbdIRQ", "CartIRQ"}
var FF93Bits = []string{
	"?", "?", "TimerFIRQ", "HorzFIRQ", "VertFIRQ", "SerialFIRQ", "KbdFIRQ", "CartFIRQ"}

var GimeLinesPerField = []int{192, 200, 210, 225}
var GimeLinesPerCharRow = []int{1, 2, 3, 8, 9, 10, 12, -1}

func GetCocoDisplayParams() *display.CocoDisplayParams {
	a := PeekB(0xFF98)
	b := PeekB(0xFF99)
	c := PeekB(0xFF9C)
	d := PeekB(0xFF9F)
	z := &display.CocoDisplayParams{
		BasicText:       *FlagBasicText,
		Gime:            true,
		Graphics:        (a>>7)&1 != 0,
		AttrsIfAlpha:    (a>>6)&1 != 0,
		VirtOffsetAddr:  int(HiLo(PeekB(0xFF9D), PeekB(0xFF9E))) << 3,
		HorzOffsetAddr:  int(d & 127),
		VirtScroll:      int(c & 15),
		LinesPerField:   GimeLinesPerField[(b>>5)&3],
		LinesPerCharRow: GimeLinesPerCharRow[a&7],
		Monochrome:      (a>>4)&1 != 0,
		HRES:            int((b >> 2) & 7),
		CRES:            int(b & 3),
		HVEN:            d>>7 != 0,
	}
	if z.Graphics {
		z.GraphicsBytesPerRow = GraphicsBytesPerRowHRES[z.HRES]
		z.GraphicsColorBits = GraphicsColorBitsCRES[z.CRES]
	} else {
		z.AlphaCharsPerRow = AlphaCharsPerRowHRES[z.HRES]
		z.AlphaHasAttrs = AlphaHasAttrsCRES[z.CRES]
	}
	for i := 0; i < 16; i++ {
		z.ColorMap[i] = PeekB(0xFFB0 + Word(i))
	}
	return z
}

func DumpGimeStatus() {
	for i := Word(0); i < 16; i += 4 {
		L("GIME/palette[%x..%x]: %s %s %s %s", i, i+3,
			ExplainColor(PeekB(0xFFB0+i)),
			ExplainColor(PeekB(0xFFB1+i)),
			ExplainColor(PeekB(0xFFB2+i)),
			ExplainColor(PeekB(0xFFB3+i)))
	}
	L("GIME/CpuSpeed: %x", PeekB(0xFFD9))
	L("GIME/MmuEnable: %v", PeekB(0xFF90)&0x40 != 0)
	L("GIME/MmuTask: %v; clock rate: %v", MmuTask, 0 != (PeekB(0xFF91)&0x40))
	L("GIME/IRQ bits: %s", ExplainBits(PeekB(0xFF92), FF92Bits))
	L("GIME/FIRQ bits: %s", ExplainBits(PeekB(0xFF93), FF93Bits))
	L("GIME/Timer=$%x", HiLo(PeekB(0xFF94), PeekB(0xFF95)))
	b := PeekB(0xFF98)
	L("GIME/GraphicsNotAlpha=%x AttrsIfAlpha=%x Artifacting=%x Monochrome=%x 50Hz=%x LinesPerCharRow=%x=%d.",
		(b>>7)&1,
		(b>>6)&1,
		(b>>5)&1,
		(b>>4)&1,
		(b>>3)&1,
		(b & 7),
		GimeLinesPerCharRow[b&7])
	b = PeekB(0xFF99)
	L("GIME/LinesPerField=%x=%d. HRES=%x CRES=%x",
		(b>>5)&3,
		GimeLinesPerField[(b>>5)&3],
		(b>>2)&7,
		b&3)

	b = PeekB(0xFF9C)
	L("GIME/Virt Scroll (alpha) = %x", b&15)
	L("GIME/VirtOffsetAddr=$%05x",
		uint64(HiLo(PeekB(0xFF9D), PeekB(0xFF9E)))<<3)
	/*
		L("GIME/VirtOffsetAddr=$%05x",
				(((LPeekB(0xFF9C)>>4)&7)<<16)|
					(((LPeekB(0xFF9D))&255)<<8)|
					(((LPeekB(0xFF9E))&255)<<0))
	*/
	b = PeekB(0xFF9F)
	L("GIME/HVEN=%x HorzOffsetAddr=%x", (b >> 7), b&127)
	L("GIME/GetCocoDisplayParams = %#v", *GetCocoDisplayParams())
}

func PutGimeIOByte(a Word, b byte) {
	L("GIME %x <= %02x", a, b)
	PokeB(a, b)

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
		L("GIME\t\t$%x: palette[$%x] <- %s", a, a&15, ExplainColor(b))

	case 0xFFD9:
		L("GIME\t\t$%x: Cpu Speed <- %02x", a, b)

	case 0xFF90:
		MmuEnable = 0 != (b & 0x40)
		BitFixedFExx = 0 != (b & 0x08)
		BitMC1 = 0 != (b & 0x02)
		BitMC0 = 0 != (b & 0x01)
		L("GIME MmuEnable <- %v; MC=%d", MmuEnable, (b & 3))

	case 0xFF91:
		MmuTask = b & 0x01
		L("GIME MmuTask <- %v; clock rate <- %v", MmuTask, 0 != (b&0x40))

	case 0xFF92:
		L("GIME\t\tIRQ bits: %s", ExplainBits(b, FF92Bits))
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
		L("GIME\t\tFIRQ bits: %s", ExplainBits(b, FF93Bits))
		if b != 0 {
			log.Panicf("GIME FIRQ Enable for unsupported emulated bits: %04x %02x", a, b)
		}

	case 0xFF94:
		L("GIME\t\tTimer=$%x Start!", HiLo(PeekB(0xFF94), PeekB(0xFF95)))
	case 0xFF95:
		L("GIME\t\tTimer=$%x", HiLo(PeekB(0xFF94), PeekB(0xFF95)))
	case 0xFF96:
		L("GIME\t\treserved")
	case 0xFF97:
		L("GIME\t\treserved")
	case 0xFF98:
		L("GIME\t\tGraphicsNotAlpha=%x AttrsIfAlpha=%x Artifacting=%x Monochrome=%x 50Hz=%x LinesPerCharRow=%x=%d.",
			(b>>7)&1,
			(b>>6)&1,
			(b>>5)&1,
			(b>>4)&1,
			(b>>3)&1,
			(b & 7),
			GimeLinesPerCharRow[b&7])
	case 0xFF99:
		L("GIME\t\tLinesPerField=%x=%d. HRES=%x CRES=%x",
			(b>>5)&3,
			GimeLinesPerField[(b>>5)&3],
			(b>>2)&7,
			b&3)

	case 0xFF9A:
		L("GIME\t\tBorder: %s", ExplainColor(b))
	case 0xFF9B:
		L("GIME\t\t512K bank selector: %02x", b)
	case 0xFF9C:
		L("GIME\t\tVirt Scroll (alpha) = %x", b&15)
	case 0xFF9D,
		0xFF9E:
		L("GIME\t\tVirtOffsetAddr=$%05x",
			uint64(HiLo(PeekB(0xFF9D), PeekB(0xFF9E)))<<3)
	case 0xFF9F:
		L("GIME\t\tHVEN=%x HorzOffsetAddr=%x", (b >> 7), b&127)

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
func ModuleId(begin Word, m Mapping) string {
	namePtr := begin + PeekWWithMapping(begin+4, m)
	modname := strings.ToLower(Os9StringWithMapping(namePtr, m))
	sz := PeekWWithMapping(begin+2, m)
	crc1 := PeekBWithMapping(begin+sz-3, m)
	crc2 := PeekBWithMapping(begin+sz-2, m)
	crc3 := PeekBWithMapping(begin+sz-1, m)
	return fmt.Sprintf("%s.%04x%02x%02x%02x", modname, sz, crc1, crc2, crc3)
}

func WithKernelTask(fn func()) {
	saved_mmut := MmuTask
	MmuTask = 0
	saved_map00 := MmuMap[0][0]
	MmuMap[0][0] = 0
	defer func() {
		MmuTask = saved_mmut
		MmuMap[0][0] = saved_map00
	}()

	fn()
}

func IsTermPath(path byte) bool {
	isTerm := false
	kpath := path
	task := MmuTask & 1
	WithMmuTask(0, func() {
		proc := PeekW(sym.D_Proc)
		procID := PeekB(proc + sym.P_ID)
		if task == 1 {
			// User mode: translate path to kernel path.
			kpath = PeekB(proc + P_Path + Word(path))
		}
		pathDBT := PeekW(sym.D_PthDBT)
		// fmt.Printf(" [dbt:%x] ", pathDBT)

		for i := Word(0); i < 8; i++ {
			// fmt.Printf(" [%x:%x] ", i, PeekW(pathDBT+2*i))
		}

		var pdPage Word
		if kpath > 3 {
			pdPage = PeekW(pathDBT + 2*(Word(kpath)>>2))
		} else {
			pdPage = pathDBT
		}
		if pdPage != 0 {
			pd := pdPage + 64*(Word(kpath)&3)
			dev := PeekW(pd + sym.PD_DEV)
			desc := PeekW(dev + sym.V_DESC)
			name := ModuleName(desc)
			_ = procID
			// fmt.Printf("<<< #%d %x.t%x.p%x/kpath=%x/dbt=%x/page=%x/pd=%x/dev=%x/desc=%x/name=%s>>>", Steps, procID, task, path, kpath, pathDBT, pdPage, pd, dev, desc, name)
			if (pdPage & 255) != 0 {
				// CoreDump(fmt.Sprintf("/tmp/core#%d", Steps))
			}
			isTerm = (name == *FlagTerm)
		}
	})
	return isTerm
}
