//go:build level1

package emu

import (
	"log"

	"github.com/strickyak/doing_os9/gomar/sym"
)

const Level = 1

const P_Path = sym.P_PATH // vs P_Path in level 2

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

// TODO
func HandleBtBug() {
}

// TODO
func MemoryModuleOf(addr Word) (name string, offset Word) {
	return "L1", addr
}
func DoDumpPageZero() {
	log.Printf("Level1 not yet DoDumpPageZero")
}
