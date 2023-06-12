//go:build level2

package emu

import (
	"bytes"
	"log"

	"github.com/strickyak/doing_os9/gomar/sym"
)

const Level = 2

// While booting OS9 Level2, the screen seems to be doubleByte
// at 07c000 to 07d000.  Second line begins at 07c0a0,
// that is 160 bytes from start, or 80 doubleBytes.
// 4096 div 160 is 25.6 lines.

const P_Path = sym.P_Path // vs P_PATH in level 1

func DoDumpPageZero() {
	saved_mmut := MmuTask
	MmuTask = 0
	saved_map00 := MmuMap[0][0]
	MmuMap[0][0] = 0
	defer func() {
		MmuTask = saved_mmut
		MmuMap[0][0] = saved_map00
	}()
	////////////////////////////

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

func DoDumpProcDesc(a Word, queue string, followQ bool) {
	PrettyDumpHex64(a, 0x100)
	if B(a+sym.P_PID) == 0 {
		L("but PID=0")
		return
	}

	tmp := MmuTask
	MmuTask = 0
	defer func() {
		MmuTask = tmp
	}()

	currency := ""
	if W(sym.D_Proc) == a {
		currency = " CURRENT "
	}
	// L("a=%04x", a)
	// switch Level {
	// case 1, 2:
	// {
	begin := PeekW(a + sym.P_PModul)
	name_str := "?"
	mod_str := "?"
	if begin != 0 {
		m := GetMappingTask0(a + sym.P_DATImg)
		modPhys := MapAddrWithMapping(begin, m)
		modPhysPlus4 := PeekWPhys(modPhys + 4)
		if modPhysPlus4 > 0 {
			name := begin + modPhysPlus4
			name_str = Os9StringWithMapping(name, m)
			mod_str = F("%q @%04x %v", name_str, begin, m)
		}
	}
	L("Process %x %s %s @%x: id=%x pid=%x sid=%x cid=%x module=%s", B(a+sym.P_PID), queue, currency, a, B(a+sym.P_ID), B(a+sym.P_PID), B(a+sym.P_SID), B(a+sym.P_CID), mod_str)

	L("   sp=%x task=%x PagCnt=%x User=%x Pri=%x Age=%x State=%x",
		W(a+sym.P_SP), B(a+sym.P_Task), B(a+sym.P_PagCnt), W(a+sym.P_User), B(a+sym.P_Prior), B(a+sym.P_Age), B(a+sym.P_State))

	L("   Queue=%x IOQP=%x IOQN=%x Signal=%x SigVec=%x SigDat=%x",
		W(a+sym.P_Queue), B(a+sym.P_IOQP), B(a+sym.P_IOQN), B(a+sym.P_Signal), B(a+sym.P_SigVec), B(a+sym.P_SigDat))
	L("   DIO %x %x %x  %x %x %x  PATH %x %x %x %x  %x %x %x %x  %x %x %x %x  %x %x %x %x",
		W(a+sym.P_DIO), W(a+sym.P_DIO+2), W(a+sym.P_DIO+4),
		W(a+sym.P_DIO+6), W(a+sym.P_DIO+8), W(a+sym.P_DIO+10),
		B(a+sym.P_Path+0), B(a+sym.P_Path+1), B(a+sym.P_Path+2), B(a+sym.P_Path+3),
		B(a+sym.P_Path+4), B(a+sym.P_Path+5), B(a+sym.P_Path+6), B(a+sym.P_Path+7),
		B(a+sym.P_Path+8), B(a+sym.P_Path+9), B(a+sym.P_Path+10), B(a+sym.P_Path+11),
		B(a+sym.P_Path+12), B(a+sym.P_Path+13), B(a+sym.P_Path+14), B(a+sym.P_Path+15))

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

	if followQ && W(a+sym.P_Queue) != 0 && queue != "Current" {
		DoDumpProcDesc(W(a+sym.P_Queue), queue, followQ)
	}

	// }
	// }
}
func MemoryModuleOf(addr Word) (name string, offset Word) {
	//if enableRom {
	//return "(rom)", addr
	//}
	// TODO: speed up with caching.
	if addr >= 0xFF00 {
		log.Panicf("PC in IO page: $%x", addr)
	}
	if addr >= 0xFE00 {
		return "(FE)", 0 // No module found for the addr.
	}
	if addr < 0x0100 {
		return "(00)", 0 // No module found for the addr.
	}

	addrPhys := MapAddr(addr, true)
	addr32 := uint32(addrPhys)

	// First scan for initial modules.
	for _, m := range InitialModules {
		if addr32 >= m.Addr && addr32 < (m.Addr+m.Len) {
			return m.Id(), Word(addr32 - m.Addr)
		}
	}

	dirStart := SysMemW(sym.D_ModDir)
	dirLimit := SysMemW(sym.D_ModEnd)
	for i := dirStart; i < dirLimit; i += 8 {
		datPtr := SysMemW(i + 0)
		// usedBytes := SysMemW(i + 2)
		begin := SysMemW(i + 4)
		links := SysMemW(i + 6)
		if datPtr == 0 {
			continue
		}
		if links == 0 { // ddt Mon May 29 12:59:19 PM PDT 2023
			// continue
		}

		m := GetMapping(datPtr)
		magic := PeekWWithMapping(begin, m)
		if magic != 0x87CD {
			return "noMods", addr
			panic(i)
		}
		//log.Printf("DDT: TRY i=%x begin=%x %q .....", i, begin, ModuleId(begin, m))

		// Module offset 2 is module size.
		remaining := int(PeekWWithMapping(begin+2, m))
		// Module offset 4 is offset to name string.
		// namePtr := begin + PeekWWithMapping(begin+4, m)

		//-------------
		// beginP := MapAddrWithMapping(begin, m)

		region := begin
		offset := Word(0) // offset into module.
		for remaining > 0 {
			// If module crosses paged blocks, it has more than one region.
			regionP := MapAddrWithMapping(region, m)
			endOfRegionBlockP := 1 + (regionP | 0x1FFF)
			regionSize := remaining
			if int(regionSize) > endOfRegionBlockP-regionP {
				// A smaller region of the module.
				regionSize = endOfRegionBlockP - regionP
			}

			//log.Printf("DDT: try %x (%x) %x", regionP, addrPhys, regionP+int(regionSize))
			if regionP <= addrPhys && addrPhys < regionP+int(regionSize) {
				if links == 0 {
					return "unlinkedMod", addr
					log.Panicf("in unlinked module: i=%x addr=%x", i, addr)
				}
				id := ModuleId(begin, m)
				delta := offset + Word(int(addrPhys)-regionP)
				//log.Printf("DDT: FOUND %q+%x", id, delta)
				return id, delta
			}
			remaining -= regionSize
			regionP += regionSize
			region += Word(regionSize)
			offset += Word(regionSize)
			//log.Printf("DDT: advanced remaining=%x regionSize=%x", remaining, regionSize)
		}
	}
	//log.Printf("DDT: NOT FOUND")
	return "", 0 // No module found for the addr.
}
func MemoryModules() {
	WithKernelTask(func() {

		L("[all mem]")
		DumpAllMemory()
		L("[page zero]")
		DumpPageZero()
		L("[processes]")
		DumpProcesses()
		L("[all path descs]")
		DumpAllPathDescs()
		L("[block zero]")
		DoDumpBlockZero()
		L("\n#MemoryModules(")

		var buf bytes.Buffer
		Z(&buf, "MOD name begin:end(len/blocklen) [addr:dat,blocklen,begin,links] dat\n")

		dirStart := SysMemW(sym.D_ModDir)
		dirLimit := SysMemW(sym.D_ModEnd)
		for i := dirStart; i < dirLimit; i += 8 {
			datPtr := SysMemW(i + 0)
			usedBytes := SysMemW(i + 2)
			begin := SysMemW(i + 4)
			links := SysMemW(i + 6)
			if datPtr == 0 {
				continue
			}

			m := GetMapping(datPtr)
			end := begin + PeekWWithMapping(begin+2, m)
			name := begin + PeekWWithMapping(begin+4, m)

			Z(&buf, "MOD %s %x:%x(%x/%x) [%x:%x,%x,%x,%x] %v\n", Os9StringWithMapping(name, m), begin, end, end-begin, usedBytes, i, datPtr, usedBytes, begin, links, m)
		}
		L("%s", buf.String())
		L("#MemoryModules)")
	})
}
func HandleBtBug() {
	if pcreg == sym.D_BtBug {
		if len(DebugString) < 20 {
			DebugString += string(rune(GetAReg() & 0x7F))
		}
	}
}
