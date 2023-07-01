//go:build level1

package emu

import (
	"bytes"

	"github.com/strickyak/doing_os9/gomar/sym"
)

const Level = 1

const P_Path = sym.P_PATH // vs P_Path in level 2

func VerboseValidateModuleSyscall() string { return "" }
func DoDumpSysMap() {
	// Called on rti().

	ScanModDir()
}

func MemoryModuleOf(addr Word) (string, Word) {
	start := W(0x26)
	limit := W(0x28)

	if start != 0x300 || limit != 0x400 {
		return "NOTYET", addr
	}

	var buf bytes.Buffer
	for i := start; i < limit; i += 4 {
		mod := W(i)
		if mod != 0 {
			size := W(mod + 2)
			if mod < addr && addr < mod+size {
				cp := mod + W(mod+4)
				for {
					b := B(cp)
					ch := 127 & b
					if '!' <= ch && ch <= '~' {
						buf.WriteByte(ch)
					}
					if (b & 128) != 0 {
						h1, h2, h3 := B(mod+size-3), B(mod+size-2), B(mod+size-1)
						return F("%s.%04x%02x%02x%02x", buf.String(), size, h1, h2, h3), addr - mod
					}
					cp++
				}
			}
		}
	}
	return "UNFOUND", addr
}

func ScanModDir() {
	// In Level1, it is $300 to $400. ( pointed by DP+$26 and DP+$28 end )
	// That's 64 entries, so 4 bytes per entry.

	L("MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM")
	L("ScanModDir")
	PrettyDumpHex64(0x300, 0x100)
	MemoryModules()
	L("MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM")
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

		name := begin + PeekW(begin+4)
		name_str = Os9String(name)
		mod_str = F("%q @%04x", name_str, begin)
	}
	L("Process %x %s %s @%x: id=%x pid=%x sid=%x cid=%x module=%s", B(a+sym.P_PID), queue, currency, a, B(a+sym.P_ID), B(a+sym.P_PID), B(a+sym.P_SID), B(a+sym.P_CID), mod_str)

	L("   sp=%x chap=?x Addr=?x PagCnt=%x User=%x Pri=%x Age=%x State=%x",
		W(a+sym.P_SP) /*B(a+sym.P_CHAP), B(a+sym.P_ADDR),*/, B(a+sym.P_PagCnt), W(a+sym.P_User), B(a+sym.P_Prior), B(a+sym.P_Age), B(a+sym.P_State))

	L("   Queue=%x IOQP=%x IOQN=%x Signal=%x SigVec=%x SigDat=%x",
		W(a+sym.P_Queue), B(a+sym.P_IOQP), B(a+sym.P_IOQN), B(a+sym.P_Signal), B(a+sym.P_SigVec), B(a+sym.P_SigDat))
	L("   DIO %x %x %x  %x %x %x  PATH %x %x %x %x  %x %x %x %x  %x %x %x %x  %x %x %x %x",
		W(a+sym.P_DIO), W(a+sym.P_DIO+2), W(a+sym.P_DIO+4),
		W(a+sym.P_DIO+6), W(a+sym.P_DIO+8), W(a+sym.P_DIO+10),
		B(a+P_Path+0), B(a+P_Path+1), B(a+P_Path+2), B(a+P_Path+3),
		B(a+P_Path+4), B(a+P_Path+5), B(a+P_Path+6), B(a+P_Path+7),
		B(a+P_Path+8), B(a+P_Path+9), B(a+P_Path+10), B(a+P_Path+11),
		B(a+P_Path+12), B(a+P_Path+13), B(a+P_Path+14), B(a+P_Path+15))

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

func MemoryModules() {
	modulePointerOffset := Word(0)
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

		end := mod + PeekW(mod+2)
		name := mod + PeekW(mod+4)
		Z(&buf, "%x:%x:<%s> ", mod, end, Os9String(name))
	}
	L("%s", buf.String())
	L("#MemoryModules)")
}

func DoDumpAllMemoryPhys() {}
func DoDumpPageZero()      {}
func DoDumpProcesses()     {}
func DoDumpAllPathDescs()  {}
func DumpGimeStatus()      {}
func HandleBtBug()         {}

func MapAddr(logical Word, quiet bool) int {
	return int(logical)
}
func PrettyDumpHex64(addr Word, size Word) {
	// MMU stuff deleted for level1.
	for p := Word(addr); p < addr+size; p += 64 {
		k := Word(64)
		for i := 0; i < 32; i++ {
			w := PeekW(p + k - 2)
			if w != 0 {
				break
			}
			k -= 2
		}
		if k == 32 {
			continue // don't print all zeros row.
		}
		var buf bytes.Buffer
		Z(&buf, "%04x:", p)
		for q := Word(0); q < k; q += 2 {
			if q&7 == 0 {
				Z(&buf, " ")
			}
			if q&15 == 0 {
				Z(&buf, " ")
			}
			w := PeekW(p + q)
			if w == 0 {
				Z(&buf, "---- ")
			} else {
				Z(&buf, "%04x ", PeekW(p+q))
			}
		}
		L("%s", buf.String())
	}
}
