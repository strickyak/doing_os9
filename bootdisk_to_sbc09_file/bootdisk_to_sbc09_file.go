// To create a boot file for sbc09 (to run v09s.c) from a Level1 CoCo disk image
// (that loads "track 35" (sector offset 1224) into ram at $2600..$3800 and jumps to $2602):
//   go run bootdisk_to_sbc09_file.go <  $HOME/6809/nitros9/nos96809l1v030208coco_80d.dsk > /tmp/boot
package main

/*
	DD.FMT DISK FORMAT:  offset $10:

	BIT B0 - SIDE
	0 = SINGLE SIDED
	1 = DOUBLE SIDED

	BIT B1 - DENSITY
	0 = SINGLE DENSITY
	1 = DOUBLE DENSITY

	BIT B2 - TRACK DENSITY
	0 = SINGLE (48 TPI)
	1= DOUBLE (96 TPI)
*/

import (
	 "bytes"
	 "flag"
	 "io"
	 "log"
	 "os"
)

var flagLevel = flag.Int("level", 0, "level 1 or 2, for interrupt vectors")

const BOOT_SECTOR = 1224
const BOOT_SECTOR_VHD = 612

var Mem []byte

func PutByte(a uint16, x byte) {
	Mem[a] = x
}
func PutWord(a uint16, x uint16) {
	Mem[a+0] = byte(x >> 8)
	Mem[a+1] = byte(x >> 0)
}

func main() {
	flag.Parse()
	Mem = make([]byte, 0x10000)

	// Emit "JMP $2602" at $100.
	PutWord(0x0100, 0x1A50) // Disable FIRQ & IRQ.
	PutByte(0x0102, 0x7E)   // JMP ...
	PutWord(0x0103, 0x2602) // ... $2602

  // Set COCO Interrupt Vectors.
	switch *flagLevel {
	case 1:
		PutWord(0xFFF2, 0x0100) // SWI3
		PutWord(0xFFF4, 0x0103) // SWI2
		PutWord(0xFFFA, 0x0106) // SWI
		PutWord(0xFFFC, 0x0109) // NMI
		PutWord(0xFFF8, 0x010C) // IRQ
		PutWord(0xFFF6, 0x010F) // FIRQ
	case 2:
		PutWord(0xFFF2, 0xFEEE) // SWI3
		PutWord(0xFFF4, 0xFEF1) // SWI2
		PutWord(0xFFFA, 0xFEFA) // SWI
		PutWord(0xFFFC, 0xFEFD) // NMI
		PutWord(0xFFF8, 0xFEF7) // IRQ
		PutWord(0xFFF6, 0xFEF4) // FIRQ
	case 0:
		panic("Use --level to define OS9 level")
	default:
		panic("bad level")
	}

	formatByte := make([]byte, 1)
	_, err := os.Stdin.Seek(10, 0)
	if err != nil {
		panic("cannot Seek FMT byte")
	}
	n, _ := io.ReadFull(os.Stdin, formatByte)
	if n != 1 {
		panic("cannot read FMT byte")
	}

	// Read 18 256-byte sectors, starting at BOOT_SECTOR.
	bootSector := int64(BOOT_SECTOR)
	switch formatByte[0] {
	case 2: bootSector = 612
	case 3: bootSector = 1224
	default:
		log.Panicf("unknown format byte: 0x%x", bootSector)
	}

	_, err = os.Stdin.Seek(bootSector*256, 0)
	if err != nil {
		panic("cannot Seek bootSector")
	}
	n, _ = io.ReadFull(os.Stdin, Mem[0x2600:0x3800])
	if n != 18*256 {
		panic("cannot read boot track")
	}

	// Write all but the first 256 bytes of mem to stdout.
	bb := bytes.NewBuffer(Mem[0x100:])
	m, err := io.Copy(os.Stdout, bb)
	if err != nil {
		panic("cannot copy to Stdout")
	}
	if m != 0xFF00 {
		panic("not gap")
	}
}
