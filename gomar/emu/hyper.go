package emu

import (
	"bytes"
	"fmt"
	"log"
)

func HyperOp(hop byte) {
	switch hop {
	case 100:
		FatalCoreDump()
	case 101:
		HFrame()
	case 102:
		fmt.Printf("`MMU[%s]`\n", ExplainMMU())
	case 103:
		fmt.Printf("$%x`", dreg)
	case 104:
		if ' ' <= dreg && dreg <= '~' {
			fmt.Printf("%c`", dreg)
		} else if dreg == 10 || dreg == 13 {
			fmt.Printf("\n`")
		} else {
			fmt.Printf("{%d}`", dreg)
		}
	default:
		log.Printf("Unknown HyperOp $%x = $d.", hop, hop)
	}
}

func HFrame() {
	log.Printf("HFrame: S=%x U=%x", sreg, ureg)
	for i := Word(0); i < 256; i += 2 {
		that := PeekW(sreg + i)
		var bb bytes.Buffer
		for j := Word(0); j < 16; j++ {
			fmt.Fprintf(&bb, " %02x", PeekB(that+j))
		}
		log.Printf("   HFrame: %x: %x: %s", sreg+i, that, bb.String())
	}
}
