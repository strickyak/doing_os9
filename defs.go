package grok_os9_disk

import "fmt"
import "io"

type Record struct {
  Len int
  Type string
  Field string
  Remark string
}

func FindString(recs []Record, b []byte, field string) string {
  k := 0
  for _, rec := range recs {
    if rec.Field == field {
      switch rec.Type {
        case "S": {
          z := ""
          for i := 0; i < rec.Len; i++ {
            z += string([]byte{b[k+i]&127})
            if b[k+i]&128 != 0 { break }
          }
          return z
        }
        default:
          panic(fmt.Sprintf("Field %q wrong type for String: %q", field, rec.Type))
      }
    }
    k += rec.Len
  }
  panic(fmt.Sprintf("Field %q not found", field))
}

func FindInt(recs []Record, b []byte, field string) int {
  k := 0
  for _, rec := range recs {
    if rec.Field == field {
      switch rec.Type {
        case "@": {
          return k
        }
        case "d", "A": {
          z := 0
          for i := 0; i < rec.Len; i++ {
            z = (z<<8) | int(b[k+i])
          }
          return z
        }
        default:
          panic(fmt.Sprintf("Field %q wrong type for Int: %q", field, rec.Type))
      }
    }
    k += rec.Len
  }
  panic(fmt.Sprintf("Field %q not found", field))
}

func PrintRecords(recs []Record, b []byte) {
  k := 0
  for _, rec := range recs {
    fmt.Printf("%s:\t", rec.Field)
    for i := 0; i < rec.Len; i++ {
      fmt.Printf("%02x ", b[k+i])
    }
    fmt.Printf("  \t[%d] %q :: ", rec.Len, rec.Remark)

    switch rec.Type {
    case "d": {
      z := 0
      for i := 0; i < rec.Len; i++ {
        z = (z<<8) | int(b[k+i])
      }
      fmt.Printf("%d", z)
    }
    case "S": {
      z := ""
      for i := 0; i < rec.Len; i++ {
        z += string([]byte{b[k+i]&127})
        if b[k+i]&128 != 0 { break }
      }
      fmt.Printf("%q", z)
    }
    case "T": {
      switch rec.Len {
      case 5:
        fmt.Printf("%04d-%02d-%02d %02d:%02d", 1900+int(b[k]), b[k+1], b[k+2], b[k+3], b[k+4])
      case 3:
        fmt.Printf("%04d-%02d-%02d", 1900+int(b[k]), b[k+1], b[k+2])
      default:
        panic("bad len")
      }
    }
    case "A": {
      fmt.Printf("(%s)", FileAttrs(int(b[k])))
    }
    case "@": {
      fmt.Printf("@%d", k)
    }
    case "-": {
      fmt.Printf("--")
    }
    }

    fmt.Printf("\n")
    k += rec.Len
  }
}

func ReadN(r io.Reader, n int) []byte {
  z := make([]byte, n, n)
  _, err := io.ReadFull(r, z)
  if err != nil { panic(err) }
  return z
}

/*
  READ.          EQU       %00000001
  WRITE.         EQU       %00000010
  UPDAT.         EQU       READ.+WRITE.
  EXEC.          EQU       %00000100
  PREAD.         EQU       %00001000
  PWRIT.         EQU       %00010000
  PEXEC.         EQU       %00100000
  SHARE.         EQU       %01000000
  DIR.           EQU       %10000000
  ISIZ.          EQU       %00100000
*/
func FileAttrs(x int) string {
  z := []byte("dsiXWRxwr")
  var i uint
  for i = 0; i < 8; i++ {
    if (1 << i) & x == 0 {
      z[7-i] = '-'
    }
  }
  return string(z)
}

// ***********************
//* LSN0 Disk Data Format
//*
//* Logical Sector Number 0 is the first sector on an RBF formatted device
//* and contains information about the device's size and format.
//*
//               ORG       0
//               DD.TOT         RMB       3                   Total number of sectors
//               DD.TKS         RMB       1                   Track size in sectors
//               DD.MAP         RMB       2                   Number of bytes in allocation bit map
//               DD.BIT         RMB       2                   Number of sectors/bit
//               DD.DIR         RMB       3                   Address of root directory fd
//               DD.OWN         RMB       2                   Owner
//               DD.ATT         RMB       1                   Attributes
//               DD.DSK         RMB       2                   Disk ID
//               DD.FMT         RMB       1                   Disk format; density/sides
//               DD.SPT         RMB       2                   Sectors/track
//               DD.RES         RMB       2                   Reserved for future use
//               DD.SIZ         EQU       .                   Device descriptor minimum size
//               DD.BT          RMB       3                   System bootstrap sector
//               DD.BSZ         RMB       2                   Size of system bootstrap
//               DD.DAT         RMB       5                   Creation date
//               DD.NAM         RMB       32                  Volume name
//               DD.OPT         RMB       32                  Option area

var Sector0 = []Record {
  {  3, "d", "DD.TOT", "Total number of sectors" },
  {  1, "d", "DD.TKS", "Track size in sectors" },
  {  2, "d", "DD.MAP", "Number of bytes in allocation bit map" },
  {  2, "d", "DD.BIT", "Number of sectors/bit" },
  {  3, "d", "DD.DIR", "Address of root directory fd" },
  {  2, "d", "DD.OWN", "Owner" },
  {  1, "d", "DD.ATT", "Attributes" },
  {  2, "d", "DD.DSK", "Disk ID" },
  {  1, "d", "DD.FMT", "Disk format; density/sides" },
  {  2, "d", "DD.SPT", "Sectors/track" },
  {  2, "d", "DD.RES", "Reserved for future use" },
  {  0, "@", "DD.SIZ", "Device descriptor minimum size" },
  {  3, "d", "DD.BT",  "System bootstrap sector" },
  {  2, "d", "DD.BSZ", "Size of system bootstrap" },
  {  5, "T", "DD.DAT", "Creation date" },
  { 32, "S", "DD.NAM", "Volume name" },
  { 32, "-", "DD.OPT", "Option area" },
}


//************************
//* File Descriptor Format
//*
//* The file descriptor is a sector that is present for every file
//* on an RBF device.  It contains attributes, modification dates,
//* and segment information on a file.
//*
//               ORG       0
//FD.ATT         RMB       1                   Attributes
//FD.OWN         RMB       2                   Owner
//FD.DAT         RMB       5                   Date last modified
//FD.LNK         RMB       1                   Link count
//FD.SIZ         RMB       4                   File size
//FD.Creat       RMB       3                   File creation date (YY/MM/DD)
//FD.SEG         EQU       .                   Beginning of segment list
//* Segment List Entry Format
//               ORG       0
//FDSL.A         RMB       3                   Segment beginning physical sector number
//FDSL.B         RMB       2                   Segment size
//FDSL.S         EQU       .                   Segment list entry size
//FD.LS1         EQU       FD.SEG+((256-FD.SEG)/FDSL.S-1)*FDSL.S
//FD.LS2         EQU       (256/FDSL.S-1)*FDSL.S
//MINSEC         SET       16


var FileDescSector = []Record {
  {  1, "A", "FD.ATT", "Attributes" },
  {  2, "d", "FD.OWN", "Owner" },
  {  5, "T", "FD.DAT", "Date last modified" },
  {  1, "d", "FD.LNK", "Link count" },
  {  4, "d", "FD.SIZ", "File size" },
  {  3, "T", "FD.Creat", "File creation date (YY/MM/DD)" },
  {  1, "@", "FD.SEG", "Beginning of segment list" },
}

//* Segment List Entry Format
//               ORG       0
//FDSL.A         RMB       3                   Segment beginning physical sector number
//FDSL.B         RMB       2                   Segment size
//FDSL.S         EQU       .                   Segment list entry size
//FD.LS1         EQU       FD.SEG+((256-FD.SEG)/FDSL.S-1)*FDSL.S
//FD.LS2         EQU       (256/FDSL.S-1)*FDSL.S
//MINSEC         SET       16

var SegmentEntry = []Record {
  {  3, "d", "FDSL.A", "Segment beginning physical sector number" },
  {  2, "d", "FDSL.B", "Segment size" },
}


//************************
//* Directory Entry Format
//*
//* Directory entries are part of a directory and define the name
//* of the file, as well as a pointer to its file descriptor.
//*
//               ORG       0
//DIR.NM         RMB       29                  File name
//DIR.FD         RMB       3                   File descriptor physical sector number
//DIR.SZ         EQU       .                   Directory record size

var DirEntry = []Record {
  { 29, "S", "DIR.NM", "File name" },
  {  3, "d", "DIR.FD", "File descriptor physical sector number" },
  {  0, "@", "DIR.SZ", "Directory record size" },
}

func AsciiString(a []byte) string {
  var z []byte
  for i := 0; i < len(a); i++ {
    if a[i] == 0 { break }
    z = append(z, a[i]&127)
    if a[i]&128 != 0 { break }
  }
  return string(z)
}
func Int(a []byte, n int) int {
  z := 0
  for i := 0; i < n; i++ {
    z = (z << 8) | int(a[i])
  }
  return z
}

func PrintModuleHeader(a []byte) {
  if len(a) < 9 || a[0] != 0x87 || a[1] != 0xCD {
    fmt.Printf("{Not a module.}\n")
    return
  }
  size := Int(a[2:], 2)
  nameAt := Int(a[4:], 2)
  name := AsciiString(a[nameAt:])
  typ := a[6]
  attrs := (a[7] >> 4) & 15
  rev := a[7] & 15

  fmt.Printf("{Module: %q size %d type %d attrs %d rev %d}\n", name, size, typ, attrs, rev)
  exec := Int(a[9:], 2)
  stack := Int(a[11:], 2)
  caps := Int(a[13:], 1)
  fmt.Printf("{    exec_offset %d stack_req %d driver_caps %d}", exec, stack, caps)
}

/*
* Module Definitions
*
* Universal Module Offsets
*
               ORG       0
M$ID           RMB       2                   ID Code
M$Size         RMB       2                   Module Size
M$Name         RMB       2                   Module Name
M$Type         RMB       1                   Type / Language
M$Revs         RMB       1                   Attributes / Revision Level
M$Parity       RMB       1                   Header Parity
M$IDSize       EQU       .                   Module ID Size

* Type-Dependent Module Offsets
*
* System, File Manager, Device Driver, Program Module
*
M$Exec         RMB       2                   Execution Entry Offset
*
* Device Driver, Program Module
*
M$Mem          RMB       2                   Stack Requirement
*
* Device Driver, Device Descriptor Module
*
M$Mode         RMB       1                   Device Driver Mode Capabilities

* Module Field Definitions
*
* ID Field - First two bytes of a NitrOS-9 module
*
M$ID1          EQU       $87                 Module ID code byte one
M$ID2          EQU       $CD                 Module ID code byte two
M$ID12         EQU       M$ID1*256+M$ID2

*
* Module Type/Language Field Masks
*
TypeMask       EQU       %11110000           Type Field
LangMask       EQU       %00001111           Language Field

*
* Module Type Values
*
Devic          EQU       $F0                 Device Descriptor Module
Drivr          EQU       $E0                 Physical Device Driver
FlMgr          EQU       $D0                 File Manager
Systm          EQU       $C0                 System Module
ShellSub       EQU       $50                 Shell+ shell sub module
Data           EQU       $40                 Data Module
Multi          EQU       $30                 Multi-Module
Sbrtn          EQU       $20                 Subroutine Module
Prgrm          EQU       $10                 Program Module

*
* Module Language Values
*
Objct          EQU       1                   6809 Object Code Module
ICode          EQU       2                   Basic09 I-code
PCode          EQU       3                   Pascal P-code
CCode          EQU       4                   C I-code
CblCode        EQU       5                   Cobol I-code
FrtnCode       EQU       6                   Fortran I-code
Obj6309        EQU       7                   6309 object code
*
* Module Attributes / Revision byte
*
* Field Masks
*
AttrMask       EQU       %11110000           Attributes Field
RevsMask       EQU       %00001111           Revision Level Field
*
* Attribute Flags
*
ReEnt          EQU       %10000000           Re-Entrant Module
ModProt        EQU       %01000000           Gimix Module protect bit (0=protected, 1=write enable)
ModNat         EQU       %00100000           6309 native mode attribute
*/
