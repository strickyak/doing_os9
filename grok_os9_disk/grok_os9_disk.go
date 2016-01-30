/*
  Grok and extract the contnts of a Microware OS-9 (or NitrOS9) disk image (at least, for Motorola 6809).

  Usage:

    go run grok_os9_disk.go [target_dirname] < nitros9/nos96809l1v030208coco_40d_1.dsk

  The command will list and explain the contents of the OS9 disk image on its stdin.

  If an argument is provided, the disk will be unbundled into that Posix directory on your host system.
*/
package main

import D "github.com/strickyak/doing_os9"

//import "bufio"
import "fmt"
import "io/ioutil"
import "os"
import FP "path/filepath"

type Segment struct {
  At int
  Segs int
}
type PairIS struct {
  A int
  B string
}

func main() {

  bb := D.ReadN(os.Stdin, 256)

  fmt.Println("=== SECTOR ZERO ===\n")
  D.PrintRecords(D.Sector0, bb)
  fmt.Println("\n")

  rootInode := D.FindInt(D.Sector0, bb, "DD.DIR")
  PrintInode(rootInode, "/")
}

func ReadAtLen(pos int, sz int) []byte {
  _, err := os.Stdin.Seek(int64(pos), 0)
  if err != nil {panic(err)}
  return D.ReadN(os.Stdin, sz)
}
func PrintInode(inode int, path string) {
  bb := ReadAtLen(inode*256, 256)

  fmt.Printf("\n========= INODE #%d %q =========\n\n", inode, path)
  D.PrintRecords(D.FileDescSector, bb)
  fmt.Println("\n")
  attrs := D.FindInt(D.FileDescSector, bb, "FD.ATT")
  size := D.FindInt(D.FileDescSector, bb, "FD.SIZ")

  var segments []Segment
  for i := 0; 16 + 5*i < 256-5+1; i++ {
    bb = ReadAtLen(inode*256 + 16 + 5*i, 256)
    at := D.FindInt(D.SegmentEntry, bb, "FDSL.A")
    segs := D.FindInt(D.SegmentEntry, bb, "FDSL.B")
    if segs == 0 { continue }
    segments = append(segments, Segment{at, segs})
    fmt.Printf("=== Segment %d ===\n", i)
    D.PrintRecords(D.SegmentEntry, bb)
  }
  fmt.Println("\n")

  if attrs & 0x80 != 0 {  // If is a DIR

    var subs []PairIS
    for _, p := range segments {
      fmt.Printf("=== Directory Segment at %d segs %d (inode %d path %q) ===\n", p.At, p.Segs, inode, path)

      if len(os.Args) > 1 {
        os.MkdirAll(FP.Join(os.Args[1], path), 0755)
      }

      segsize := p.Segs*256
      if size < segsize {
        segsize, size = size, 0
      } else {
        size -= segsize
      }

      for i := 0; i*32 < segsize; i++ {
        bb = ReadAtLen(p.At*256 + i*32, 32)
        fd := D.FindInt(D.DirEntry, bb, "DIR.FD")
        if fd == 0 { continue }
        D.PrintRecords(D.DirEntry, bb)
        name := D.FindString(D.DirEntry, bb, "DIR.NM")
        if name != "." && name != ".." {
          subName := path + "/" + name
          if path == "/" { subName = "/" + name }
          subs = append(subs, PairIS{fd, subName})
        }
      }
    }
    for _, p := range subs {
      PrintInode(p.A, p.B)
    }

  } else {  // IF is a FILE
    var contents []byte
    for _, p := range segments {
      fmt.Printf("=== File Segment at %d segs %d (inode %d path %q) ===\n", p.At, p.Segs, inode, path)

      segsize := p.Segs*256
      if size < segsize {
        segsize, size = size, 0
      } else {
        size -= segsize
      }

      bb := ReadAtLen(p.At*256, segsize)
      contents = append(contents, bb...)
    }

    D.PrintModuleHeader(contents)

    if len(os.Args) > 1 {
      ioutil.WriteFile(FP.Join(os.Args[1], path), contents, 0666)
    }
  }
}
