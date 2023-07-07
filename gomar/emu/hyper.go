package emu

import (
	"bytes"
	"fmt"
	"log"
	"os"
)

var HyperPrinting = true

func Nice(ch byte) byte {
	ch = ch & 127
	if ' ' <= ch && ch <= '~' {
		return ch
	}
	return '.'
}

func ShowRegs() {
	if HyperPrinting {
		fmt.Printf(" REGS{ cc:%02x dp:%02x d:%04x x:%04x y:%04x u:%04x s:%04x pc:%04x }\n",
			ccreg, dpreg, dreg, xreg, yreg, ureg, sreg, pcreg)
	}
}

func ShowRam32(addr Word) {
	if HyperPrinting {
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
}

func PrintH2() {
	var_ptr := xreg // format pointer (char**) is in X register
	PrintHyper(var_ptr)
}

func PrintH() {
	var_ptr := ureg + 4 // format (char*) is first arg, above frame pointer & stack pointer.
	PrintHyper(var_ptr)
}

var Want string
var Got bytes.Buffer
var Logged bytes.Buffer
var Round int

func SetWant() {
	Round++
	Want = string(MachinePointerToString(xreg))
	log.Printf("START Round #%d. START WANT: %q", Round, Want)
	if Want == "" {
		log.Panic("START Round #%d. Don't set empty expectation", Round)
	}
}

func CheckWanted() {
	log.Printf("=== END Round #%d.  LOGGED  {{{{{%s}}}}}\n\n", Round, Logged.String())
	log.Printf("=== END Round #%d.  GOT: %q", Round, Got.String())
	log.Printf("=== END Round #%d. WANT: %q", Round, Want)
	if Want != Got.String() {
		log.Panicf("=== FAILED: Round #%d. GOT %q WANT %q", Round, Got.String(), Want)
	}
	log.Printf("\n=== OKAY: Round #%d. Got what was wanted.", Round)
	fmt.Printf("\n=== OKAY: Round #%d. Got what was wanted.\n", Round)
	Want = ""
	Got.Reset()
	Logged.Reset()
}

func Done() {
	log.Printf("Done: Exiting 0.")
	os.Exit(0)
}

func PrintHyper(var_ptr Word) {
	format := MachinePointerToString(PeekW(var_ptr))
	i := 0
	var_ptr += 2
	bb := bytes.NewBuffer(nil)
	for i < len(format) {
		ch := format[i]
		if ch == '%' {
			i++
			kind := format[i]
			switch kind {
			case 'c':
				bb.WriteString(fmt.Sprintf("%c", PeekW(var_ptr)))
			case 'x':
				bb.WriteString(fmt.Sprintf("$%04x", PeekW(var_ptr)))
			case 'd':
				bb.WriteString(fmt.Sprintf("%d.", PeekW(var_ptr)))
			case 's', 'q':
				bb.Write(MachinePointerToString(PeekW(var_ptr)))
			default:
				log.Panicf("Bad char after % in format string: '%c' in %q", kind, format)
			}
			var_ptr += 2
		} else {
			bb.WriteByte(ch)
		}
		i++
	}
	str := bb.String()
	fmt.Printf("HYPER: [#%d %q]\n", Steps, str)
	log.Printf("HYPER: [#%d %q]", Steps, str)
}

func MachinePointerToString(p Word) []byte {
	p0 := p
	var bb bytes.Buffer
	for {
		ch := PeekB(p)
		p++
		if ch == 0 {
			break
		} else if '\n' == ch || ch == '\r' {
			bb.WriteByte(ch)
		} else if ' ' <= ch && ch <= '~' {
			bb.WriteByte(ch)
		} else {
			log.Panicf("Bad char $%02x at $%04x after string %q starting at $%04x", ch, p-1, bb.String(), p0)
		}
	}
	return bb.Bytes()
}
func output_Words(args ...Word) {
	emit_Words(true, args...)
}
func log_Words(args ...Word) {
	emit_Words(false, args...)
}
func emit_Words(forOutput bool, args ...Word) {
	format := MachinePointerToString(args[0])
	i := 0
	args = args[1:]
	bb := bytes.NewBuffer(nil)
	for i < len(format) {
		ch := format[i]
		if ch == '%' {
			i++
			kind := format[i]
			switch kind {
			case 'c':
				bb.WriteString(fmt.Sprintf("%c", args[0]))
			case 'x':
				bb.WriteString(fmt.Sprintf("$%04x", args[0]))
			case 'd':
				bb.WriteString(fmt.Sprintf("%d.", args[0]))
			case 's':
				bb.Write(MachinePointerToString(args[0]))
			default:
				log.Panicf("Bad char after % in format string: '%c' in %q", kind, format)
			}
			args = args[1:]
		} else {
			bb.WriteByte(ch)
		}
		i++
	}
	str := bb.String()
	fmt.Printf("EMIT %v [ #%d  %q ]\n", forOutput, Steps, str)
	log.Printf("EMIT %v [ #%d  %q ]", forOutput, Steps, str)

	if forOutput {
		Got.WriteString(str)
		Logged.WriteString(fmt.Sprintf("##%q##", str))
	} else {
		Logged.WriteString(str)
	}
}

func HyperOp(hop byte) {
	switch hop {
	case 100: // Fatal
		FatalCoreDump()

	case 101: // Show Frame
		HFrame()

	case 102: // Explain MMU
		if HyperPrinting {
			fmt.Printf("`MMU[%s]`\n", ExplainMMU())
		}

	case 103: // ShowHex and tick
		if HyperPrinting {
			fmt.Printf("$%x`", dreg)
		}

	case 104: // ShowChar and tick
		if HyperPrinting {
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
		}

	case 105: // Show RAM 32
		ShowRam32(dreg)

	case 106: // Show Task RAM 32
		if HyperPrinting {
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
		}

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

	case 111: // PrintH2
		PrintH2()

	case 112:
		if Want != "" {
			CheckWanted()
		}
		SetWant()

	case 113:
		if Want != "" {
			CheckWanted()
		}
		Done()

	case 120:
		output_X()

	case 121:
		output_X_D()

	case 130:
		log_X()

	case 131:
		log_X_D()

	default:
		log.Printf("Unknown HyperOp $%x = $d.", hop, hop)
	}
}
func log_X() {
	log_Words(xreg)
}
func log_X_D() {
	log_Words(xreg, dreg)
}

func output_X() {
	output_Words(xreg)
}
func output_X_D() {
	output_Words(xreg, dreg)
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
