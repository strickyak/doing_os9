package change

import (
	"log"
	"io/ioutil"
)


func ChangeDataSize(Incr int, Mod string) {
    log.Printf("module %q", Mod)

	module, err := ioutil.ReadFile(Mod)
	if err != nil {
		log.Fatalf("cannot read module file %q: %v", Mod, err)
	}
	assertEqB(module[0], 0x87)
	assertEqB(module[1], 0xCD)

	size := wordAt(module, 2)
	assertEqI(len(module), int(size))
	assert(size > 12)
    log.Printf("module length = $%04x = %d.", size, size)

	// Check header.
	c := byte(0)
	for _, b := range module[:9] {
		c ^= b
	}
	assertEqB(c, 255)

	assertEqB(0xF0 & module[6], 0x10)  // Must be Program module.

    storageSize := wordAt(module, 0x0b)
    log.Printf("old storage size = $%04x = %d.", storageSize, storageSize)
    // log.Printf("CRC = $%06x = ^$%06x", CRC(module[:size-3]), 0xFFFFFF ^ CRC(module[:size-3]))
    // log.Printf("CRC = $%06x = ^$%06x", CRC(module), 0xFFFFFF ^ CRC(module))

    got := (uint32(module[size-3]) << 16) + (uint32(module[size-2]) << 8) + uint32(module[size-1])
    calculated := CRC(module)
    // log.Printf("got %x calc %x xor %x", got, calculated, got ^ calculated)
    assertEqI(int(got ^ calculated), 0xFFFFFF)

    if Incr != 0 {
        newStorageSize := storageSize + uint16(Incr)
        pokeWordAt(module, 0x0b, newStorageSize)
        log.Printf("new storage size = $%04x = %d.", newStorageSize, newStorageSize)

        // fix header checksum
        c := byte(0)
        for _, b := range module[:9] {
            c ^= b
        }
        module[9] = 0xFF ^ c

        module[size-3] = 0
        module[size-2] = 0
        module[size-1] = 0
        newCrc := 0xffffff ^ CRC(module)
        module[size-3] = byte(newCrc >> 16)
        module[size-2] = byte(newCrc >> 8)
        module[size-1] = byte(newCrc)

        err = ioutil.WriteFile(Mod, module, 0666)
        if err != nil {
            log.Panicf("cannot rewrite module %q: %v", Mod, err)
        }
    }
}

func wordAt(bb []byte, off int) uint16 {
	return 256*uint16(bb[off]) + uint16(bb[off+1])
}
func pokeWordAt(bb []byte, off int, value uint16) {
    bb[off] = byte(value >> 8)
    bb[off+1] = byte(value)
}

func assertEqB(a, b byte) {
	if a != b {
		log.Fatalf("assertEqB FAILS: %d vs %d", a, b)
	}
}

func assertEqI(a, b int) {
	if a != b {
		log.Fatalf("assertEqI FAILS: %d vs %d", a, b)
	}
}

func assert(p bool) {
	if !p {
		log.Fatal("assert FAILS")
	}
}

func CRC(a []byte) uint32 {
    // copied from doing_os9/gomar/borges/borges.go
        var crc uint32 = 0xFFFFFF
        for k := 0; k < len(a)-3; k++ {
                crc ^= uint32(a[k]) << 16
                for i := 0; i < 8; i++ {
                        crc <<= 1
                        if (crc & 0x1000000) != 0 {
                                crc ^= 0x800063
                        }
                }
        }
        return crc & 0xffffff
}
