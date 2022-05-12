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
		PrintK()
	case 102:
		fmt.Printf(" MMU[%s]\n", ExplainMMU())
	default:
		log.Printf("Unknown HyperOp $%x = $d.", hop, hop)
	}
}

func PrintK() {
	log.Printf("PrintK: S=%x U=%x", sreg, ureg)
	for i := Word(0); i < 256; i += 2 {
		that := PeekW(sreg + i)
		var bb bytes.Buffer
		for j := Word(0); j < 16; j++ {
			fmt.Fprintf(&bb, " %02x", PeekB(that+j))
		}
		log.Printf("   MEM: %x: %x: %s", sreg+i, that, bb.String())
	}
}
