// +build main

package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

type ModuleMap map[string][]byte

func LoadDir(dirname string) ModuleMap {
	filenames, err := filepath.Glob(filepath.Join(dirname, "*.list"))
	if err != nil {
		log.Panicf("Cannot read directory %q: %v", dirname, err)
	}
	modules := make(ModuleMap)
	for _, filename := range filenames {
		modules[filename] = LoadFile(filename)
	}
	return modules
}

/*  Model Lines:
|0000 87CD012A000DC185 (/home/strick/6809):00042         Begin    mod   eom,name,tylg,atrv,start,size
|     D7002B0000
|                      (/home/strick/6809):00043
|                      (/home/strick/6809):00044                  org   0
|     0000             (/home/strick/6809):00045         size     equ   .          REL doesn't require any memory
|                      (/home/strick/6809):00046
|000D 5245CC           (/home/strick/6809):00047         name     fcs   /REL/
|0010 05               (/home/strick/6809):00048                  fcb   edition
*/

var startLine *regexp.Regexp
var continueLine *regexp.Regexp

func init() {
	// ..... "0000 87CD012A000DC185 (/home/strick/6809):00042         Begin    mod   eom,name,tylg,atrv,start,size"
	s := "(HHHH) (HHhhhhhhhhhhhhhh) {.................}:DDDDD         "
	s = strings.ReplaceAll(s, "H", "[0-9a-f]")  // Must be hex digits.
	s = strings.ReplaceAll(s, "h", "[0-9a-f ]") // Maybe 2 hex, maybe 2 spaces.
	// s = strings.ReplaceAll(s, "h?", "([0-9A-H][0-9A-H]|  )")  // Maybe 2 hex, maybe 2 spaces.
	s = strings.ReplaceAll(s, "{", "[(]")   // open paren
	s = strings.ReplaceAll(s, "}", "[)]")   // close paren
	s = strings.ReplaceAll(s, "D", "[0-9]") // decimal digit
	s += "([A-Za-z0-9$@_.]*) +"             // may be a label, must be spaces before opcode
	s += "([A-Za-z0-9]+)"                   // must be an opcode.
	startLine = regexp.MustCompile("^" + s)
	println()
	println(s)
	println()
	log.Printf("start: %v\n", s)
	log.Printf("start: %v\n", startLine)
	// | "     D7002B0000123456"
	c := "     ([0-9a-f]{2,16})$"
	continueLine = regexp.MustCompile("^" + c)
	println()
	log.Printf("cont: %v\n", c)
	log.Printf("cont: %v\n", continueLine)
	println()
}

func LoadFile(filename string) []byte {
	var err error
	fd, err := os.Open(filename)
	if err != nil {
		log.Panicf("Cannot open listing %q: %v", filename, err)
	}
	defer fd.Close()
	log.Printf("loading %q", filename)

	r := bufio.NewScanner(fd)
	inModule := false

	var addr uint
	var module []byte
	for r.Scan() {
		text := strings.ToLower(r.Text())
		sl := startLine.FindStringSubmatch(text)
		cl := continueLine.FindStringSubmatch(text)
		if sl != nil {
			// log.Printf("0(%q,%q,%q,%q) :: %q\n", sl[1], sl[2], sl[3], sl[4], text)

			if sl[4] == "mod" {
				inModule = true
			}

			if inModule {
				n, err := fmt.Sscanf(sl[1], "%x", &addr)
				if err != nil {
					panic(err)
				}
				if n != 1 {
					panic(sl[1])
				}
				var tmp []byte
				n, err = fmt.Sscanf(sl[2], "%x", &tmp)
				if err != nil {
					panic(err)
				}
				if n != 1 {
					panic(sl[2])
				}
				if len(module) != int(addr) {
					log.Printf("BAD filename %q len %d=0x%x addr %d=0x%x sl=%q,%q,%q,%q", filename, len(module), len(module), addr, addr, sl[1], sl[2], sl[3], sl[4])
					return nil
				}
				module = append(module, tmp...)
			}

			if sl[4] == "emod" {
				return module
			}

		} else if cl != nil {
			if inModule {
				// log.Printf("1(%q) :: %q\n", cl[1], text)
				var tmp []byte
				n, err := fmt.Sscanf(cl[1], "%x", &tmp)
				if err != nil {
					panic(err)
				}
				if n != 1 {
					panic(cl[1])
				}
				module = append(module, tmp...)
			}
		}
	}
	if inModule {
		log.Printf("BAD: no emod: %q", filename)
	}
	return nil
}

func ModuleName(module []byte) string {
	if len(module) < 10 {
		log.Panicf("too short: %02x", module)
	}
	if module[0] != 0x87 || module[1] != 0xCD {
		log.Panicf("bad magic")
	}
	size := int(module[2])*256 + int(module[3])
	if len(module) != size {
		log.Panicf("bad size %d len %d", size, len(module))
	}
	nameptr := int(module[4])*256 + int(module[5])
	var sb strings.Builder
	for {
		c := module[nameptr]
		sb.WriteByte(c & 0x7F)
		if c&0x80 != 0 {
			break
		}
		nameptr++
	}
	name := sb.String()

	got := (uint32(module[size-3]) << 16) + (uint32(module[size-2]) << 8) + uint32(module[size-1])
	// log.Printf("GOT %x", got)

	calculated := CRC(module) ^ 0xFFFFFF
	// log.Printf("CRC %x", calculated)
	if got != calculated {
		log.Panicf("bad crc: got %x calculated %x", got, calculated)
	}

	return fmt.Sprintf("%s.%04x%06x", name, size, got)
}

func CRC(a []byte) uint32 {
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

func SaveListingCopy(readpath, outdir, id string) {
	r, err := os.Open(readpath)
	if err != nil {
		log.Panicf("Cannot read file: %q: %v", readpath, err)
	}
	defer r.Close()

	writepath := filepath.Join(outdir, strings.ToLower(id))
	w, err := os.Create(writepath)
	if err != nil {
		log.Panicf("Cannot create file: %q: %v", writepath, err)
	}
	defer w.Close()

	_, err = io.Copy(w, r)
	if err != nil {
		log.Panicf("Cannot copy file: %q to %q: %v", readpath, writepath, err)
	}
}

func HasListSuffix(path string) bool {
	if strings.HasSuffix(path, ".lst") {
		return true
	}
	if strings.HasSuffix(path, ".list") {
		return true
	}
	if strings.HasSuffix(path, ".list+") {
		return true
	}
	if strings.HasSuffix(path, ".listing") {
		return true
	}
	return false
}

func Walker(path string, info os.FileInfo, err error) error {
	if HasListSuffix(path) {
		if info.Mode().IsRegular() {
			module := LoadFile(path)
			if module == nil {
				log.Printf("==== no module for %q", path)
				return nil
			}
			id := ModuleName(module)
			log.Printf("OKAY ==== %q ==> %q\n", path, id)
			if *Outdir != "" {
				SaveListingCopy(path, *Outdir, id)
			}
		}
	}
	return nil
}

var Outdir = flag.String("outdir", "", "directory to write listings to")

func main() {
	flag.Parse()

	for _, filename := range flag.Args() {
		err := filepath.Walk(filename, Walker)
		if err != nil {
			log.Panicf("cannot walk: %q: %v", filename, err)
		}
	}
}
