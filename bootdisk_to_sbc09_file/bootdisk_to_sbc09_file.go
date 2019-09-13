// To create a boot file for sbc09 (to run v09s.c) from a Level1 CoCo disk image
// (that loads "track 35" (sector offset 1224) into ram at $2600..$3800 and jumps to $2602):
//   go run bootdisk_to_sbc09_file.go <  $HOME/6809/nitros9/nos96809l1v030208coco_80d.dsk > /tmp/boot
package main

import (
	 "bytes"
	 "flag"
	 "io"
	 "os"
)

var flagLevel = flag.Int("level", 1, "level 1 or 2, for interrupt vectors")

const BOOT_SECTOR = 1224

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
	default:
		panic("bad level")
	}

	// Read 18 256-byte sectors, starting at BOOT_SECTOR.
	_, err := os.Stdin.Seek(BOOT_SECTOR*256, 0)
	if err != nil {
		panic("cannot Seek BOOT_SECTOR")
	}
	n, _ := io.ReadFull(os.Stdin, Mem[0x2600:0x3800])
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
