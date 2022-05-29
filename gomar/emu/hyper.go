package emu

import (
	"bytes"
	"fmt"
	"log"
)

func HyperOp(hop byte) {
	switch hop {
	case 100: // Fatal
		FatalCoreDump()

	case 101: // Show Frame
		HFrame()

	case 102: // Explain MMU
		fmt.Printf("`MMU[%s]`\n", ExplainMMU())

	case 103: // ShowHex and tick
		fmt.Printf("$%x`", dreg)

	case 104: // ShowChar and tick
		if (dreg & 128) != 0 {
			fmt.Printf("^")
		}
		ch := (byte)(dreg & 127)
		if ' ' <= ch && ch <= '~' {
			fmt.Printf("%c`", ch)
		} else if ch == 10 || ch == 13 {
			fmt.Printf(" (%d)\n`", ch)
		} else {
			fmt.Printf("{%d}`", ch)
		}

	case 105: // Show RAM 32
		fmt.Printf(" [[%x]]{{", dreg)
		for i := Word(0); i < 32; i += 2 {
			fmt.Printf("%04x ", PeekW(dreg+i))
			if (i&7) == 6 && i < 30 {
				fmt.Printf(" ")
			}
		}
		fmt.Printf("}}` ")

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
