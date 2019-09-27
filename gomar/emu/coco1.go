// +build coco1

package emu

func AddressInDeviceSpace(addr Word) bool {
	return (addr&0xFF00) == 0xFF00 && (addr&0xFFF0) != 0xFFF0
}

func EmitHardware() {}

func ExplainMMU() string { return "" }

// B is fundamental func to get byte.  Hack register access into here.
func B(addr Word) byte {
	var z byte
	if AddressInDeviceSpace(addr) {
		z = GetIOByte(addr)
		L("HEY, GetIO %04x -> %02x : %c %c", addr, z, H(z), T(z))
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
	return mem[mapped]
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
