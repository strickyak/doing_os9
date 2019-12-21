package listings

import (
	"bufio"
	"flag"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	//"strings"
)

var Borges = flag.String("borges", "", "dir with source module listings")

type ModSrc struct {
	Src      map[uint]string
	Filename string
	Err      error
}

var Listings = make(map[string]*ModSrc)

func Lookup(module string, offset uint) string {
	if *Borges == "" {
		return ""
	}

	m, ok := Listings[module]
	if !ok {
		filename := filepath.Join(*Borges, module)
		m = LoadFile(filename)
		Listings[module] = m
	}

	if m.Err != nil {
		return "" // Module not found.
	}
	s, _ := m.Src[offset]
	return s // Empty if offset not found.
}

var parse = regexp.MustCompile(`^([0-9A-F]{4}) [0-9A-F]+ +[(].*?[)]:[0-9]{5} +(.*)$`)
var parseSection = regexp.MustCompile(`^ +[(].*?[)]:[0-9]{5} +(?i:section) +([A-Za-z0-9_]+)`)
var parseEndSection = regexp.MustCompile(`^ +[(].*?[)]:[0-9]{5} +(?i:endsection)`)

func LoadFile(filename string) *ModSrc {
	d := make(map[uint]string)
	fd, err := os.Open(filename)
	if err != nil {
		log.Printf("BAD: Cannot open listing %q: %v", filename, err)
		return &ModSrc{
			Src:      nil,
			Filename: filename,
			Err:      err,
		}
	}
	defer fd.Close()
	r := bufio.NewScanner(fd)
	inOtherSection := false
	for r.Scan() {
		text := r.Text()
		m := parse.FindStringSubmatch(text)
		if m != nil && !inOtherSection {
			hexaddr, line := m[1], m[2]
			addr, err := strconv.ParseUint(hexaddr, 16, 16)
			if err != nil {
				log.Panicf("Should have been a hex integer: %q: %v", hexaddr, err)
			}
			d[uint(addr)] = line
			//log.Printf("FILE %s ADDR %x LINE %q", filename, addr, line)
		}
		m = parseSection.FindStringSubmatch(text)
		if m != nil {
			section := m[1]
			inOtherSection = (section != "code")
		}
		m = parseEndSection.FindStringSubmatch(text)
		if m != nil {
			inOtherSection = false
		}
	}
	log.Printf("BORGES: Loaded Source: %q", filename)
	return &ModSrc{
		Src:      d,
		Filename: filename,
		Err:      nil,
	}
}
