// To create a boot file for sbc09 (to run v09s.c) from a Level1 CoCo disk image
// (that loads "track 35" (sector offset 1224) into ram at $2600..$3800 and jumps to $2602):
//   go run bootdisk_to_sbc09_file.go <  $HOME/6809/nitros9/nos96809l1v030208coco_80d.dsk > /tmp/boot
package main

import "bytes"
import "io"
import "os"

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
	Mem = make([]byte, 0x10000)

	// Emit "JMP $2602" at $100.
	PutByte(0x0100, 0x7E) // JMP
	PutWord(0x0101, 0x2602)

  // Set COCO Interrupt Vectors.
	PutWord(0xFFF2, 0x0100) // SWI3
	PutWord(0xFFF4, 0x0103) // SWI2
	PutWord(0xFFFA, 0x0106) // SWI
	PutWord(0xFFFC, 0x0109) // NMI
	PutWord(0xFFF8, 0x010C) // IRQ
	PutWord(0xFFF6, 0x010F) // FIRQ

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
