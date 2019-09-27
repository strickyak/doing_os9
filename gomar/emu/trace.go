// +build trace

package emu

import (
	// "github.com/strickyak/doing_os9/gomar/sym"
	"github.com/strickyak/doing_os9/gomar/listings"

	"bytes"
	"log"
	"strings"
)

var Source *listings.Listings

var been_there [0x10000]bool

/* max. bytes of instruction code per trace line */
const MaximumBytesPerOpcode = 4

/* disassembled instruction len (optional, on demand) */
var dis_length Word

func Dis_len(n Word) {
	dis_length = n
}
func Dis_len_incr(n Word) {
	dis_length += n
}

func InitTrace() {
	if *FlagListingsDir != "" {
		Source = listings.LoadDir(*FlagListingsDir)
	}
}

func Trace() {
	var buf bytes.Buffer
	wh := where(pcreg_prev)
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
	for i := Word(0); i < MaximumBytesPerOpcode; i++ {
		if int(i) < ilen {
			Z(&buf, "%02x", B(pcreg_prev+i))
		} else {
			Z(&buf, "  ")
		}
	}
	Z(&buf, " %-5s %-17s [%02d] ", dinst.String(), dops.String(), cycles)
	log.Printf("%s%s", buf.String(), Regs())
	dis_length = 0

	module, offset := MemoryModuleOf(pcreg_prev)
	if module != "" {
		moduleLower := strings.ToLower(module)
		text := Source.Lookup(moduleLower, uint(offset))
		log.Printf("%q+%04x :::: %s", module, offset, text)
	}

	log.Printf("\t%s debug=%q", ExplainMMU(), DebugString)
}

func Finish() {
	L("Finish:")
	L("Cycles: %d   Steps: %d", cycles_sum, steps)
	L("")
	DumpAllMemory()
	L("")
	DumpAllMemoryPhys()
	L("")
	L("Cycles: %d   Steps: %d", cycles_sum, steps)
}

func where(addr Word) string {
	if Level == 2 {
		name, offset := MemoryModuleOf(addr)
		if name != "" {
			return F("%q+%04x ", name, offset)
		} else {
			return "? "
		}
	}
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
