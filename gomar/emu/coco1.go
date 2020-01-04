// +build coco1

package emu

import (
	"github.com/strickyak/doing_os9/gomar/sym"

	"bytes"
	"log"
)

const P_Path = sym.P_PATH

const TraceMem = false // TODO: restore this some day.

func EmitHardware() {}
func InitHardware() {
	Coco1Contract()
}
func Coco1Contract() {
	// TODO
}

func ExplainMMU() string             { return "" }
func DoExplainMmuBlock(i int) string { return "" }

func FireTimerInterrupt() {
	irqs_pending |= IRQ_PENDING
	Waiting = false
}

// B is fundamental func to get byte.  Hack register access into here.
func B(addr Word) byte {
	var z byte
	if AddressInDeviceSpace(addr) {
		z = GetIOByte(addr)
		L("GetIO %04x -> %02x : %c %c", addr, z, H(z), T(z))
		mem[addr] = z
	} else {
		z = mem[addr]
	}
	if TraceMem {
		L("\t\t\t\tGetB %04x -> %02x : %c %c", addr, z, H(z), T(z))
	}
	return z
}

func PokeB(addr Word, b byte) {
	mem[addr] = b
}

func PeekB(addr Word) byte {
	return mem[addr]
}

// PutB is fundamental func to set byte.  Hack register access into here.
func PutB(addr Word, x byte) {
	old := mem[addr]
	mem[addr] = x
	if TraceMem {
		L("\t\t\t\tPutB %04x <- %02x (was %02x)", addr, x, old)
	}
	if AddressInDeviceSpace(addr) {
		PutIOByte(addr, x)
		L("PutIO %04x <- %02x (was %02x)", addr, x, old)
	}
}

func InMmuTask(task byte, fn func()) {
	fn()
}

func PutGimeIOByte(a Word, b byte) {
	// not used on coco1.
	log.Panicf("UNKNOWN PutGimeIOByte address: 0x%04x <- 0x%02x", a, b)
}
func MemoryModuleOf(addr Word) (name string, offset Word) {
	addr32 := uint32(addrPhys)

	for _, m := range InitialModules {
		if addr32 >= m.Addr && addr32 < (m.Addr+m.Len) {
			return m.Id(), m.Addr - addr32
		}
	}

	modulePointerOffset := Word(0)
	start := PeekW(sym.D_ModDir)
	limit := PeekW(sym.D_ModDir + 2)
	i := start

	for ; i < limit; i += 4 + modulePointerOffset {
		mod := PeekW(i + modulePointerOffset)
		if mod == 0 {
			continue
		}

		end := mod + PeekW(mod+2)
		if mod <= addr && addr < end {
			name := mod + PeekW(mod+4)
			return Os9String(name), addr - mod
		}
	}
	return "", 0 // No module found for the addr.
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

func HandleBtBug() {
	// None in level1
}

func DoDumpAllMemoryPhys() {}
func DoDumpPageZero()      {}
func DoDumpProcesses()     {}
func DoDumpAllPathDescs()  {}
func DumpGimeStatus()      {}

func MapAddr(logical Word, quiet bool) int {
	return int(logical)
}
