package main

// To create a boot file for sbc09 (to run v09s.c) from a Level1 CoCo disk image
// (that loads "track 35" (sector offset 1224) into ram at $2600..$3800 and jumps to $2602):
//   go run bootdisk_to_sbc09_file.go <  /home/strick/6809/nitros9/nos96809l1v030208coco_40d_1.dsk > /tmp/boot
// Then
//   v09s -i0 -o0 /tmp/boot
// The -i0 -o0 mean don't use SWI for input or output.
// Next problem:  
//   Emulating the disk drive?
//   or preload OS9Boot as well, and don't use a disk drive.

import "io"
import "os"

const BOOT_SECTOR = 1224

func main() {
  // Emit "JMP $2602" at $100.
  n, _ := os.Stdout.Write([]byte{0x7E, 0x26, 0x02})
  if (n != 3) {panic("not n")}

  // Zeros in the gap from $103 to $2600
  gap := 0x2600 - 0x103
  n, _ = os.Stdout.Write(make ([]byte, gap, gap))
  if (n != gap) {panic("not gap")}

  os.Stdin.Seek(BOOT_SECTOR * 256, 0)
  T := 18*256
  track := make([]byte, T, T)
  n, _ = io.ReadFull(os.Stdin, track)
  if (n != T) {panic("not track")}

  n, _ = os.Stdout.Write(track)
  if (n != T) {panic("not gap")}
}
