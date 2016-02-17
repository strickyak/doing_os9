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

// 005F 8E0106           (/home/strick/6809):00368                  ldx  #D.XSWI
// 0062 BFFFFA           (/home/strick/6809):00369                  stx  $FFFA
// 0065 8E0103           (/home/strick/6809):00370                  ldx  #D.XSWI2
// 0068 BFFFF4           (/home/strick/6809):00371                  stx  $FFF4
// 006B 8E0100           (/home/strick/6809):00372                  ldx  #D.XSWI3
// 006E BFFFF2           (/home/strick/6809):00373                  stx  $FFF2
// 0071 8E0109           (/home/strick/6809):00374                  ldx  #D.XNMI
// 0074 BFFFFC           (/home/strick/6809):00375                  stx  $FFFC
// 0077 8E010C           (/home/strick/6809):00376                  ldx  #D.XIRQ
// 007A BFFFF8           (/home/strick/6809):00377                  stx  $FFF8
// 007D 8E010F           (/home/strick/6809):00378                  ldx  #D.XFIRQ
// 0080 BFFFF6           (/home/strick/6809):00379                  stx  $FFF6


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
