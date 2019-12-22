package emu

import (
	"bytes"
	"flag"
	"log"
	"os"
)

var flagEmudsk = flag.String("emudsk", "", "emudsk Emulation Disk")

const (
	kEmudskReadSector byte = iota
	kEmudskWriteSector
	kEmudskCloseDevice
)

var fileEmudsk *os.File

func initEmudsk() {
	if fileEmudsk != nil {
		return // Already initialized.
	}
	if *flagEmudsk == "" {
		log.Panicf("Flag --emudsk required")
	}
	var err error
	fileEmudsk, err = os.OpenFile(*flagEmudsk, os.O_RDWR, 0666)
	if err != nil {
		log.Fatalf("Cannot open emudsk %q: %v", *flagEmudsk, err)
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
		log.Printf("emudsk: LogicalSectorNumber: %x <- %x", a, b)
		// Emulated Disk: Logical Sector Number: let it save in ram.

	case 0xFF84,
		0xFF85:
		log.Printf("emudsk: Buffer: %x <- %x", a, b)
		// Emulated Disk: Buffer Location: let it save in ram.

	case 0xFF83:
		log.Printf("emudsk: Action: %x <- %x", a, b)
		if *flagEmudsk == "" {
			log.Panicf("No --emudsk flag")
		}
		initEmudsk()
		switch b {
		default:
			log.Fatalf("emudsk: *default* not yet supported on emudsk")
		case kEmudskReadSector:
			{
				lsn, ptr := EmudskLogicalSectorNumberAndBufferLocation()
				log.Printf("emudsk: ReadSector: lsn=$%x ptr=$%x", lsn, ptr)

				_, err := fileEmudsk.Seek(int64(lsn)*256, 0)
				if err != nil {
					log.Panicf("Cannot seek to sector $%x on %q: %v", lsn, *flagEmudsk, err)
				}
				bb := make([]byte, 256)
				cc, err := fileEmudsk.Read(bb)
				if err != nil {
					log.Panicf("Cannot read sector $%x on %q: %v", lsn, *flagEmudsk, err)
				}
				if cc != 256 {
					log.Panicf("Short read sector $%x on %q: %d. bytes", lsn, *flagEmudsk, cc)
				}
				for i, e := range bb {
					PokeB(Word(ptr)+Word(i), e)
				}

				{ // Verbosity:
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

				_, err := fileEmudsk.Seek(int64(lsn)*256, 0)
				if err != nil {
					log.Panicf("Cannot seek to sector $%x on %q: %v", lsn, *flagEmudsk, err)
				}
				ptrPhys := MapAddr(Word(ptr), false)
				bb := mem[ptrPhys : ptrPhys+256]
				cc, err := fileEmudsk.Write(bb)
				if err != nil {
					log.Panicf("Cannot write sector $%x on %q: %v", lsn, *flagEmudsk, err)
				}
				if cc != 256 {
					log.Panicf("Short read sector $%x on %q: %d bytes", lsn, *flagEmudsk, cc)
				}

				{ // Verbosity:
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
			initEmudsk()
			PokeB(0xFF83, 0) // OK

		}
	}
}
