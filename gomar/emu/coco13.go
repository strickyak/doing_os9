// +build coco1 coco3

package emu

import (
	"bytes"
	"flag"
	"fmt"
	"log"
	"os"
	"strings"
)

func AddressInDeviceSpace(addr Word) bool {
	return (addr&0xFF00) == 0xFF00 && (addr&0xFFF0) != 0xFFF0
}

func GetIOByte(a Word) byte {
	var z byte
	switch a {
	/* PIA 0 */
	case 0xFF00:
		z = 255
		if kbd_ch != 0 {
			z = keypress(kbd_probe, kbd_ch)
			L("KEYBOARD: %02x %q -> %02x\n", kbd_probe, string(rune(kbd_ch)), z)
		} else {
			L("KEYBOARD: %02x      -> %02x\n", kbd_probe, z)
		}
		return z
	case 0xFF01:
		return 0
	case 0xFF02:
		return kbd_probe /* Reset IRQ when this is read. TODO: multiple sources of IRQ. */
	case 0xFF03:
		return 0x80 /* Negative bit set: Yes the PIA caused IRQ. */

	/* PIA 1 */
	case 0xFF22:
		L("TODO: Get Io byte 0x%04x\n", a)
		return 0

	case 0xFF48: /* STATREG */
		return 0 /* low bit 0 means Ready, other bits are errors or not ready */

	case 0xFF4B: /* Read Data */
		z = 0
		if disk_i < 256 {
			z = disk_stuff[disk_i]
			L("fnord %x -> %x\n", disk_i, z)
		} else {
			z = 0
		}
		disk_i++
		if disk_i == 257 {
			L("Read SET NMI_PENDING\n")
			irqs_pending |= NMI_PENDING
			z = 0
			disk_i = 0
		}
		return z

	case 0xFF92: /* GIME IRQ */
		switch Level {
		case 2:
			return 0x08
		}
		return 0
	case 0xFF93: /* GIME FIRQ */
		return 0

	default:
		L("UNKNOWN GetIOByte: 0x%04x\n", a)
		return 0
	}
	panic("notreached")
}

func LogicalSector(sector, side, track byte) int64 {
	switch disk_dd_fmt {
	case 2:
		if side != 0 {
			panic(side)
		}
		return int64(disk_sector) - 1 + int64(disk_track)*18
	case 3:
		return int64(disk_sector) - 1 + int64(disk_side)*18 + int64(disk_track)*36
	}
	log.Panicf("bad disk_dd_fmt: %d", disk_dd_fmt)
	panic(0)
}

func PutIOByte(a Word, b byte) {
	if 0xFF90 <= a && a < 0xFFC0 {
		PutGimeIOByte(a, b)
		return
	}

	switch a {
	default:
		log.Panicf("UNKNOWN PutIOByte address: 0x%04x", a)

	case 0xFF02:
		kbd_probe = b

	case 0xFF00,
		0xFF01,
		0xFF03,

		0xFF20,
		0xFF21,
		0xFF22,
		0xFF23:
		L("TODO: Put IO byte 0x%04x\n", a)
		return

	case 0xFF40: /* CONTROL */
		{
			disk_control = b
			disk_side = CondB(b&0x40 != 0, 1, 0)
			disk_drive = CondB((b&1 != 0), 1, CondB((b&2 != 0), 2, CondB((b&4 != 0), 3, 0)))

			L("CONTROL: disk_command %x (control %x side %x drive %x)\n", disk_command, disk_control, disk_side, disk_drive)
			if b == 0 {
				// log.Panicf("panic: disk_command 0")
				break
			}

			switch disk_command {
			case 0x80:
				{
					prev_disk_command = disk_command
					disk_offset = 256 * LogicalSector(disk_sector, disk_side, disk_track)
					if disk_drive != 1 {
						log.Panicf("ERROR: R: Drive %d not supported\n", disk_drive)
					}
					if disk_fd == nil {
						log.Panicf("ERROR: R: No file for Disk Read Sector\n")
					}

					disk_stuff = zero_disk_stuff
					_, err := disk_fd.Seek(disk_offset, 0)
					if err != nil {
						log.Panicf("Bad disk sector seek: err=%v", err)
					}
					n, err := disk_fd.Read(disk_stuff[:])
					if err != nil {
						log.Panicf("Bad disk sector read: err=%v", err)
					}
					if n != 256 {
						log.Panicf("Short disk sector read: n=%d", n)
					}

					assert(n == 256)
					disk_i = 0
					L("READ fnord (Track, Sector-1) %d:%d:%d:%d == %d\n", disk_drive, disk_track, disk_side, disk_sector-1, disk_offset>>8)
				}
			case 0xA0:
				{
					prev_disk_command = disk_command
					disk_offset = 256 * LogicalSector(disk_sector, disk_side, disk_track)
					if disk_drive != 1 {
						log.Panicf("ERROR: W: Drive %d not supported\n", disk_drive)
					}
					if disk_fd == nil {
						log.Panicf("ERROR: W: No file for Disk Read Sector\n")
					}
					disk_stuff = zero_disk_stuff
					_, err := disk_fd.Seek(int64(disk_offset), 0)
					if err != nil {
						log.Panicf("Bad disk sector seek: err=%v", err)
					}

					disk_i = 0
					L("WRITE fnord (Track, Sector-1) %d:%d:%d:%d == %d\n", disk_drive, disk_track, disk_side, disk_sector-1, disk_offset>>8)
				}
			}
			disk_command = 0
		}
	case 0xFF48:
		{ // CMDREG //
			disk_command = b
			switch b {
			case 0x10:
				{
					disk_track = disk_data
					disk_status = 0
					L("Seek : %d\n", disk_data)
				}
			case 0x80:
				{ // Read Sector //
					// We have set disk_command.  Next control write defines disk & side. //

				}
			case 0xD0:
				{
					disk_drive = 0
					disk_side = 0
					disk_track = 0
					disk_sector = 0
					disk_i = 0
					disk_stuff = zero_disk_stuff
					L("Reset Disk\n")
				}
			}
		}
	case 0xFF49: /* TRACK */
		disk_track = b
		L("Track : %d\n", b)

	case 0xFF4A: /* SECTOR */
		disk_sector = b
		L("Sector-1 : %d\n", b-1)

	case 0xFF4B:
		{ /* DATA */
			if (prev_disk_command & 0xF0) != 0xA0 {
				disk_i = 0
				disk_data = b
			} // else
			if true {
				if disk_i < 256 {
					L("fnord %x %x <- %x\n", prev_disk_command, disk_i, b)
					disk_stuff[disk_i] = b
					///++disk_i;
				}
			}
			if (prev_disk_command & 0xF0) == 0xA0 {
				if disk_i < 256 {
					disk_i++
				}
				// TODO -- fix writing.
				if disk_i >= 256 {
					L("Write SET NMI_PENDING\n")
					irqs_pending |= NMI_PENDING
					disk_i = 0

					// TODO -- fix writing.
					n, err := disk_fd.Write(disk_stuff[:])
					if err != nil {
						log.Panicf("Error in disk_fd.Write: %v", err)
					}
					if n != 256 {
						log.Panicf("Error in disk_fd.Write: Short n=%d", n)
					}
					L("DID_WRITE fnord (Track, Sector-1) %d:%d:%d:%d == %d\n", disk_drive, disk_track, disk_side, disk_sector-1, disk_offset>>8)
				}
			}

		}

	/* VDG */
	case 0xFFC0,
		0xFFC1,
		0xFFC2,
		0xFFC3,
		0xFFC4,
		0xFFC5,
		0xFFC6,
		0xFFC7,
		0xFFC8,
		0xFFC9,
		0xFFCA,
		0xFFCB,
		0xFFCC,
		0xFFCD,
		0xFFCE,
		0xFFCF,

		0xFFD0,
		0xFFD1,
		0xFFD2,
		0xFFD3,
		0xFFD9,
		0xFFDF:
		{
			L("VDG PutByte OK: %x <- %x\n", a, b)
		}

	case 0xFF80,
		0xFF81,
		0xFF82:
		log.Printf("LogicalSectorNumber: %x <- %x", a, b)
		break // Emulated Disk: Logical Sector Number: let it save in ram.
	case 0xFF84,
		0xFF85:
		log.Printf("Buffer: %x <- %x", a, b)
		break // Emulated Disk: Buffer Location: let it save in ram.
	case 0xFF83:
		log.Printf("emudsk: %x <- %x", a, b)
		switch b {
		case emudskReadSector:
			{
				initEmudsk()
				lsn := (uint64(PeekB(0xFF80)) << 16) | (uint64(PeekB(0xFF81)) << 8) | uint64(PeekB(0xFF82))
				ptr := (uint64(PeekB(0xFF84)) << 8) | uint64(PeekB(0xFF85))
				_, err := fileEmudsk.Seek(int64(lsn*256), 0)
				if err != nil {
					log.Panicf("Cannot seek to sector %d on %q: %v", lsn, *flagEmudsk, err)
				}
				bb := make([]byte, 256)
				cc, err := fileEmudsk.Read(bb)
				if err != nil {
					log.Panicf("Cannot read sector %d on %q: %v", lsn, *flagEmudsk, err)
				}
				if cc != 256 {
					log.Panicf("Short read sector %d on %q: %d bytes", lsn, *flagEmudsk, cc)
				}
				for i, e := range bb {
					PokeB(Word(ptr)+Word(i), e)
				}
				PokeB(0xFF83, 0) // OK
			}
		case emudskWriteSector:
			initEmudsk()
			log.Fatalf("writing not yet supported on emudisk")
		case emudskCloseDevice:
			initEmudsk()
			PokeB(0xFF83, 0) // OK
			log.Fatalf("closing not yet supported on emudisk")
		}
	}
}

const (
	emudskReadSector byte = iota
	emudskWriteSector
	emudskCloseDevice
)

var flagEmudsk = flag.String("emudsk", "", "emudsk Emulation Disk")
var fileEmudsk *os.File

func initEmudsk() {
	if fileEmudsk != nil {
		return
	}
	if *flagEmudsk == "" {
		return
	}
	var err error
	fileEmudsk, err = os.Open(*flagEmudsk)
	if err != nil {
		log.Fatalf("Cannot open emudsk %q: %v", *flagEmudsk, err)
	}
}

func DoDumpAllMemory() {
	var i, j int
	var buf bytes.Buffer
	L("\n#DumpAllMemory(\n")
	for i = 0; i < 0x10000; i += 32 {
		if (i & 0x1FFF) == 0 {
			// For coco3
			DoExplainMmuBlock(i)
		}
		// Look ahead for something interesting on this line.
		something := false
		for j = 0; j < 32; j++ {
			x := PeekB(Word(i + j))
			if x != 0 && x != ' ' {
				something = true
				break
			}
		}

		if !something {
			continue
		}

		buf.Reset()
		Z(&buf, "%04x: ", i)
		for j = 0; j < 32; j += 8 {
			Z(&buf,
				"%02x%02x %02x%02x %02x%02x %02x%02x  ",
				PeekB(Word(i+j+0)), PeekB(Word(i+j+1)), PeekB(Word(i+j+2)), PeekB(Word(i+j+3)),
				PeekB(Word(i+j+4)), PeekB(Word(i+j+5)), PeekB(Word(i+j+6)), PeekB(Word(i+j+7)))
		}
		buf.WriteRune(' ')
		for j = 0; j < 32; j++ {
			ch := 0x7F & PeekB(Word(i+j))
			var r rune = '.'
			if ' ' <= ch && ch <= '~' {
				r = rune(ch)
			}
			buf.WriteRune(r)
		}
		L("%s\n", buf.String())
	}
	L("#DumpAllMemory)\n")
}

type ModuleFound struct {
	Addr uint32
	Len  uint32
	CRC  uint32
	Name string
}

func (m ModuleFound) Id() string {
	return strings.ToLower(fmt.Sprintf("%s.%04x%06x", m.Name, m.Len, m.CRC))
}

func ScanRamForOs9Modules() []*ModuleFound {
	var z []*ModuleFound
	for i := 256; i < len(mem)-256; i++ {
		if mem[i] == 0x87 && mem[i+1] == 0xCD {
			parity := byte(255)
			for j := 0; j < 9; j++ {
				parity ^= mem[i+j]
			}
			if parity == 0 {
				sz := int(HiLo(mem[i+2], mem[i+3]))
				nameAddr := i + int(HiLo(mem[i+4], mem[i+5]))
				got := uint32(HiMidLo(mem[i+sz-3], mem[i+sz-2], mem[i+sz-1]))
				crc := 0xFFFFFF ^ Os9CRC(mem[i:i+sz])
				if got == crc {
					log.Printf("SCAN (at $%x sz $%x) %q %06x %06x", i, sz, Os9StringPhys(nameAddr), mem[i+sz-3:i+sz], 0xFFFFFF^Os9CRC(mem[i:i+sz]))
					z = append(z, &ModuleFound{
						Addr: uint32(i),
						Len:  uint32(sz),
						CRC:  crc,
						Name: Os9StringPhys(nameAddr),
					})
				} else {
					log.Printf("SCAN BAD CRC (@%04x) %06x %06x", i, got, crc)

				}
			} else {
				log.Printf("SCAN BAD PARITY (@%04x) %02x", i, parity)
			}
		}
	}
	return z
}

func Os9CRC(a []byte) uint32 {
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
