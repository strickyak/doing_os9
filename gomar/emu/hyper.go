package emu

import (
	"bytes"
	"fmt"
	"log"
	"os"
)

func Nice(ch byte) byte {
	ch = ch & 127
	if ' ' <= ch && ch <= '~' {
		return ch
	}
	return '.'
}

func ShowRegs() {
	fmt.Printf(" REGS{ cc:%02x dp:%02x d:%04x x:%04x y:%04x u:%04x s:%04x pc:%04x }\n",
		ccreg, dpreg, dreg, xreg, yreg, ureg, sreg, pcreg)
}

func ShowRam32(addr Word) {
	fmt.Printf("RAM [%04x]{", addr)
	for i := Word(0); i < 32; i += 2 {
		fmt.Printf("%04x ", PeekW(addr+i))
		if (i&7) == 6 && i < 30 {
			fmt.Printf(" ")
		}
	}
	fmt.Printf("| ")
	for i := Word(0); i < 32; i += 1 {
		fmt.Printf("%c", Nice(PeekB(addr+i)))
		if (i & 7) == 7 {
			fmt.Printf(" ")
		}
	}
	fmt.Printf("}`\n")
}

func PrintH() {
	var_ptr := ureg + 4
	p := PeekW(var_ptr)
	var_ptr += 2
	bb := bytes.NewBuffer(nil)
	for {
		ch := PeekB(p)
		// fmt.Printf("<%04x:%02x>", p, ch)
		if ch < 9 {
			break
		}
		if ch > 126 {
			break
		}
		// bb.WriteRune('+')
		if ch == '%' {
			p++
			ch = PeekB(p)
			switch ch {
			case 'x':
				bb.WriteString(fmt.Sprintf("$%04x", PeekW(var_ptr)))
			case 'd':
				bb.WriteString(fmt.Sprintf("%d.", PeekW(var_ptr)))
			case 's':
				sptr := PeekW(var_ptr)
				bb.WriteRune('"')
				for {
					ch2 := PeekB(sptr)
					sptr++
					if ch2 == 0 {
						break
					}
					if ' ' <= ch2 && ch2 <= '~' {
						bb.WriteRune(rune(ch2))
					} else {
						bb.WriteString(fmt.Sprintf("(%d.)", ch2))
					}
					if ch2 > 126 {
						break
					}
				}
				bb.WriteRune('"')
			default:
				bb.WriteRune('%')
				bb.WriteRune(rune(ch))
				var_ptr -= 2
			}
			var_ptr += 2
		} else {
			bb.WriteRune(rune(ch))
		}
		p++
	}
	proc_num := byte(0)
	proc_ptr := PeekW(0x0050)
	if proc_ptr != 0x0000 {
		proc_num = PeekB(proc_ptr)
	}
	fmt.Printf("[<%x>%s]", proc_num, bb.String())
}

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
		ShowRam32(dreg)

	case 106: // Show Task RAM 32
		task := GetBReg()
		addr := xreg
		fmt.Printf("TaskRam [[%x t%x]]{{", addr, task)

		for i := Word(0); i < 32; i += 2 {
			fmt.Printf("%04x ", PeekWWithTask(addr+i, task))
			if (i&7) == 6 && i < 30 {
				fmt.Printf(" ")
			}
		}
		for i := Word(0); i < 32; i += 1 {
			fmt.Printf("%c", Nice(PeekBWithTask(addr+i, task)))
			if (i & 7) == 7 {
				fmt.Printf(" ")
			}
		}
		fmt.Printf("}}`\n")

	case 107: // Exit
		log.Printf("*** GOMAR Hyper Exit: %d", dreg)
		fmt.Printf("*** GOMAR Hyper Exit: %d\n", dreg)
		os.Exit(int(dreg))

	case 108: // PrintH
		PrintH()

	case 109: // ShowRegs
		ShowRegs()

	case 110: // ShowStr
		{
			p := dreg
			bb := bytes.NewBuffer(nil)
			for {
				ch := PeekB(p)
				if ch == 0 {
					break
				}
				if ch == 13 {
					ch = 10
				}
				bb.WriteRune(rune(ch))
				if ch < 10 {
					break
				}
				if ch > 127 {
					break
				}
				p++
			}
			fmt.Printf("[~[%s]~]", bb.String())
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
