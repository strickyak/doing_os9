// +build coco3

package emu

func AddressInDeviceSpace(addr Word) bool {
	return (addr&0xFF00) == 0xFF00 && (addr&0xFFF0) != 0xFFF0
}

const MmuDefaultStartAddr = (0x38 << 13)

var GimeVertIrqEnable bool
var MmuEnable bool
var MmuTask byte
var MmuMap [2][8]byte

func InitHardware() {
	Coco3Contract()
}

// Coco3Contract ensures the contract between Coco3's disk booting mechanism
// and the OS/9 Level2 kernel, documented at
// nitros9/level2/modules/kernel/ccbkrn.txt
func Coco3Contract() {

	// Initialize Memory Map thus: 00 39 3a 3b 3c 3d 3e 3f
	for task := 0; task < 2; task++ {
		MmuMap[task][0] = 0x00 // Exception.
		for page := 1; page < 8; page++ {
			MmuMap[task][page] = byte(0x38 + page)
		}
	}
	// Initialize physical block 3b to spaces, except 0x0008 at the beginning.
	const block3b = 0x3b * 0x2000
	mem[block3b+0] = 0x00
	mem[block3b+1] = 0x08
	for i := 2; i < 0x2000; i++ {
		mem[block3b+i] = ' '
	}
	/*   starting at 0xff90:
	6c      init0
	00      init1
	00      irq enable
	00      firq enable
	0900    timer register
	0000    unused
	0320    screen settings
	0000    ????
	00      ????
	ec01    physical video address (block 3b offset 0x0008 )
	00      horizontal offset / scroll

	A mirror of these bytes will appear at 0x0090-0x009f in the DP
	*/
	for i, b := range []byte{0x6c, 0, 0, 0, 9, 0, 0, 0, 3, 0x20, 0, 0, 0, 0x3c, 1, 0} {
		PutIOByte(Word(0xFF90+i), b)
		mem[0x90+i] = b // Probably don't need to set the mirror, but doing it anyway.
	}
}

func ExplainMMU() string {
	return F("mmu:%d task:%d : (t0) %02x %02x %02x %02x  %02x %02x %02x %02x : (t1) %02x %02x %02x %02x  %02x %02x %02x %02x :",
		CondI(MmuEnable, 1, 0),
		MmuTask&1,
		MmuMap[0][0],
		MmuMap[0][1],
		MmuMap[0][2],
		MmuMap[0][3],
		MmuMap[0][4],
		MmuMap[0][5],
		MmuMap[0][6],
		MmuMap[0][7],
		MmuMap[1][0],
		MmuMap[1][1],
		MmuMap[1][2],
		MmuMap[1][3],
		MmuMap[1][4],
		MmuMap[1][5],
		MmuMap[1][6],
		MmuMap[1][7],
	)
}

func MapAddrWithMapping(logical Word, m Mapping) int {
	slot := 7 & (logical >> 13)
	low := int(logical & 0x1FFF)
	physicalPage := m[slot]
	return (int(physicalPage) << 13) | low
}

func MapAddr(logical Word, quiet bool) int {
	if logical >= 0xFE00 {
		return (0x3F << 13) | int(logical)
	}
	var z int
	if MmuEnable {
		slot := byte(logical >> 13)
		low := int(logical & 0x1FFF)
		physicalPage := MmuMap[MmuTask][slot]
		z = (int(physicalPage) << 13) | low
		if !quiet && TraceMem {
			L("\t\t\t\t\t\t MapAddr: %04x -> %06x ... task=%x  slot=%x  page=%x", logical, z, MmuTask, slot, physicalPage)
		}
		return z
	} else {
		if z < 0x2000 {
			z = int(logical)
		} else {
			z = MmuDefaultStartAddr + int(logical)
		}
		if !quiet && TraceMem {
			L("\t\t\t\t\t\t MapAddr: %04x -> %06x ... default map", logical, z)
		}
		return z
	}
}

// B is fundamental func to get byte.  Hack register access into here.
func B(addr Word) byte {
	var z byte
	mapped := MapAddr(addr, false)
	if AddressInDeviceSpace(addr) {
		z = GetIOByte(addr)
		L("HEY, GetIO (%06x) %04x -> %02x : %c %c", mapped, addr, z, H(z), T(z))
		mem[mapped] = z
	} else {
		z = mem[mapped]
	}
	if TraceMem {
		L("\t\t\t\tGetB (%06x) %04x -> %02x : %c %c", mapped, addr, z, H(z), T(z))
	}
	return z
}

func PokeB(addr Word, b byte) {
	mapped := MapAddr(addr, true)
	mem[mapped] = b
}

func PeekB(addr Word) byte {
	var z byte
	mapped := MapAddr(addr, true)
	z = mem[mapped]
	return z
}

// PutB is fundamental func to set byte.  Hack register access into here.
func PutB(addr Word, x byte) {
	mapped := MapAddr(addr, false)
	old := mem[mapped]
	mem[mapped] = x
	if TraceMem {
		L("\t\t\t\tPutB (%06x) %04x <- %02x (was %02x)", mapped, addr, x, old)
	}
	if AddressInDeviceSpace(addr) {
		PutIOByte(addr, x)
		L("PutIO (%06x) %04x <- %02x (was %02x)", mapped, addr, x, old)
	}
}

func PeekWPhys(addr int) Word {
	if addr+1 > len(mem) {
		panic(addr)
		// return 0
	}
	return Word(mem[addr])<<8 | Word(mem[addr+1])
}
