//go:build trace
// +build trace

package emu

import (
	// "github.com/strickyak/doing_os9/gomar/sym"
	"github.com/strickyak/doing_os9/gomar/listings"

	"bytes"
	"log"
	"strings"
)

var been_there [0x10000]bool

/* max. bytes of instruction code per trace line */
const kMaximumBytesPerOpcode = 4

/* disassembled instruction len */
var dis_length Word

func Dis_len(n Word) {
	dis_length = n
}
func Dis_len_incr(n Word) {
	dis_length += n
}

func Trace() {
	var buf bytes.Buffer
	wh := where(pcreg_prev)
	// oldnew would be improved with Memory Block.
	oldnew := CondI(been_there[pcreg_prev], 'o', 'N')
	Z(&buf, "%s%c %04x:", wh, oldnew, pcreg_prev)
	been_there[pcreg_prev] = true

	var ilen int
	if dis_length != 0 {
		ilen = int(dis_length)
	} else {
		ilen = int(pcreg - pcreg_prev)
		if ilen < 0 {
			ilen = -ilen
		}
	}
	for i := Word(0); i < kMaximumBytesPerOpcode; i++ {
		if int(i) < ilen {
			Z(&buf, "%02x", B(pcreg_prev+i)) // two hex chars
		} else {
			Z(&buf, "  ") // two spaces
		}
	}

	Z(&buf, " {%-5s %-17s}  ", dinst.String(), dops.String())
	log.Printf("%s%s", buf.String(), Regs())
	dis_length = 0

	module, offset := MemoryModuleOf(pcreg_prev)

	if module != "" {
		moduleLower := strings.ToLower(module)
		text := listings.Lookup(moduleLower, uint(offset), func() {
			*FlagTraceAfter = 1
		})
		log.Printf("          {{ %s }}", text)
	}

	if pcreg < pcreg_prev || pcreg > pcreg_prev+4 {
		log.Printf("")
		log.Printf("    %s debug=%q", ExplainMMU(), DebugString)
		log.Printf("")
	}

	wh = strings.Trim(wh, " ")
	for _, w := range Watches {
		if wh == w.Where {
			var val Word
			switch w.Register {
			case "d":
				val = dreg
			}
			log.Printf("@WATCH@ %s == %04x == %q", w.Where, val, w.Message)
		}
	}
}

func Finish() {
	L("Finish:")
	L("Cycles: %d   Steps: %d", cycles_sum, Steps)
	L("")
	DoDumpAllMemory()
	L("")
	DoDumpAllMemoryPhys()
	L("")
	L("Cycles: %d   Steps: %d", cycles_sum, Steps)
}

func where(addr Word) string {
	if Level == 2 {
		name, offset := MemoryModuleOf(addr)
		if name != "" {
			return F("%q+%04x ", name, offset)
		} else {
			return "\"\" "
		}
	}

	// if Level == 1 ...
	// TODO -- did this ever work for Level 1?
	var buf bytes.Buffer

	start := W(0x26)
	limit := W(0x28)

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
						Z(&buf, ",%04x ", addr-mod)
						return buf.String()
					}
					cp++
				}
			}
		}
	}
	return "? "
}

func Dis_inst(inst string, reg string, cyclecount int) {
	dinst.Reset()
	dops.Reset()
	dinst.WriteString(inst)
	dinst.WriteString(reg)
	cycles += cyclecount
}

func Dis_inst_cat(inst string, cyclecount int) {
	dinst.WriteString(inst)
	cycles += cyclecount
}

func Dis_ops(part1 string, part2 string, cyclecount int) {
	dops.WriteString(part1)
	dops.WriteString(part2)
	cycles += cyclecount
}

var reg_for_da_reg = []string{"d", "x", "y", "u", "s", "pc", "?", "?", "a", "b", "cc", "dp", "?", "?", "?", "?"}

func Dis_reg(b byte) {
	dops.WriteString(reg_for_da_reg[(b>>4)&0xf])
	dops.WriteString(",")
	dops.WriteString(reg_for_da_reg[b&0xf])
}

func DumpAllMemory()    { DoDumpAllMemory() }
func DumpPageZero()     { DoDumpPageZero() }
func DumpProcesses()    { DoDumpProcesses() }
func DumpAllPathDescs() { DoDumpAllPathDescs() }

//func LogIO(f string, args ...interface{}) {
//	L(f, args...)
//}

// Call this before each instruction until it returns false.
func EarlyAction() bool {
	// OS9 boots with PC in the first half of memory space.
	// When it jumps into the higher half, it jumps into modules.
	if pcreg > 0x8000 {
		DumpAllMemory()
		InitialModules = ScanRamForOs9Modules()
		return false
	}
	return true
}
