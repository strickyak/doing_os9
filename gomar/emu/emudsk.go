package emu

import (
	"bytes"
	"flag"
	"log"
	"os"
)

var flagH0 = flag.String("h0", "", "emudsk /H0 disk image")
var flagH1 = flag.String("h1", "", "emudsk /H1 disk image")

const kNumHDrives = 2

const (
	kEmudskReadSector byte = iota
	kEmudskWriteSector
	kEmudskCloseDevice
)

var fileEmudsk [kNumHDrives]*os.File
var nameEmudsk [kNumHDrives]string

func initEmudsk(i byte) {
	if i >= kNumHDrives {
		log.Panicf("initEmudsk: bad drive num: $%x", i)
	}

	if fileEmudsk[i] != nil {
		return // Already initialized.
	}

	nameEmudsk = [kNumHDrives]string{
		*flagH0,
		*flagH1,
	}

	if nameEmudsk[i] == "" {
		log.Panicf("Flag --emudsk required")
	}
	var err error
	fileEmudsk[i], err = os.OpenFile(nameEmudsk[i], os.O_RDWR, 0666)
	if err != nil {
		log.Fatalf("Cannot open emudsk %q: %v", nameEmudsk[i], err)
	}
}

func EmudskLogicalSectorNumberAndBufferLocation() (int, int) {
	lsn := (int(PeekB(0xFF80)) << 16) | (int(PeekB(0xFF81)) << 8) | int(PeekB(0xFF82))
	ptr := (int(PeekB(0xFF84)) << 8) | int(PeekB(0xFF85))
	return lsn, ptr
}

func EmudskGetIOByte(a Word) byte {
	switch a {
	default:
		log.Panicf("Bad address for Emudsk GetIO: $%x", a)

	case 0xFF83: /* emudsk status */
		return PeekB(a)
	}
	return 0
}

func EmudskPutIOByte(a Word, b byte) {
	switch a {
	default:
		log.Panicf("Bad address for Emudsk PutIO: $%x", a)

	case 0xFF80,
		0xFF81,
		0xFF82:
		log.Printf("emudsk: LogicalSectorNumber: $%x <- $%x", a, b)
		// Emulated Disk: Logical Sector Number: let it save in ram.

	case 0xFF84,
		0xFF85:
		log.Printf("emudsk: Buffer: $%x <- $%x", a, b)
		// Emulated Disk: Buffer Location: let it save in ram.

	case 0xFF86:
		log.Printf("emudsk: Drive Number: $%x <- $%x", a, b)
		// Emulated Disk: Drive Number: let it save in ram.

	case 0xFF83:
		drive := PeekB(0xFF86)
		log.Printf("emudsk[$%x]: Action: $%x <- $%x", drive, a, b)
		initEmudsk(drive)
		if nameEmudsk[drive] == "" {
			log.Panicf("No --emudsk flag")
		}
		switch b {
		default:
			log.Fatalf("emudsk: *default* not yet supported on emudsk")
		case kEmudskReadSector:
			{
				lsn, ptr := EmudskLogicalSectorNumberAndBufferLocation()
				log.Printf("emudsk: ReadSector: lsn=$%x ptr=$%x", lsn, ptr)

				_, err := fileEmudsk[drive].Seek(int64(lsn)*256, 0)
				if err != nil {
					log.Panicf("Cannot seek to sector $%x on %q: %v", lsn, nameEmudsk[drive], err)
				}
				bb := make([]byte, 256)
				cc, err := fileEmudsk[drive].Read(bb)
				if err != nil {
					log.Panicf("Cannot read sector $%x on %q: %v", lsn, nameEmudsk[drive], err)
				}
				if cc != 256 {
					log.Panicf("Short read sector $%x on %q: %d. bytes", lsn, nameEmudsk[drive], cc)
				}
				for i, e := range bb {
					PokeB(Word(ptr)+Word(i), e)
				}

				DumpHexLines(F("READ($%x)", lsn), bb)
				if false { // Verbosity:
					var buf bytes.Buffer
					var last byte
					for _, e := range bb {
						if e < ' ' || e > '~' {
							e = '.'
						}
						if last != e {
							buf.WriteRune(rune(e))
						}
						last = e
					}
					log.Printf("emudsk: ReadSector: %q", buf.String())
				}

				PokeB(0xFF83, 0) // Set good status.
			}

		case kEmudskWriteSector:
			{
				lsn, ptr := EmudskLogicalSectorNumberAndBufferLocation()
				log.Printf("emudsk: WriteSector: lsn=$%x ptr=$%x", lsn, ptr)

				_, err := fileEmudsk[drive].Seek(int64(lsn)*256, 0)
				if err != nil {
					log.Panicf("Cannot seek to sector $%x on %q: %v", lsn, nameEmudsk[drive], err)
				}
				ptrPhys := MapAddr(Word(ptr), false)
				bb := mem[ptrPhys : ptrPhys+256]
				cc, err := fileEmudsk[drive].Write(bb)
				if err != nil {
					log.Panicf("Cannot write sector $%x on %q: %v", lsn, nameEmudsk[drive], err)
				}
				if cc != 256 {
					log.Panicf("Short read sector $%x on %q: %d bytes", lsn, nameEmudsk[drive], cc)
				}

				DumpHexLines(F("WRITE($%x)", lsn), bb)
				if false { // Verbosity:
					var buf bytes.Buffer
					var last byte
					for _, e := range bb {
						if e < ' ' || e > '~' {
							e = '.'
						}
						if last != e {
							buf.WriteRune(rune(e))
						}
						last = e
					}
					log.Printf("emudsk: WriteSector: %q", buf.String())
				}

				PokeB(0xFF83, 0) // Set good status.
			}

		case kEmudskCloseDevice:
			PokeB(0xFF83, 0) // OK

		}
	}
}
