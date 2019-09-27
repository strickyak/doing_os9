package listings

import (
	"bufio"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
)

type Listings struct {
	Lines map[string]map[uint]string
}

func (o *Listings) Lookup(module string, offset uint) string {
	if o == nil {
		return ""
	}
	key := strings.ToLower(module)
	d, ok := o.Lines[key]
	if !ok {
		return "" // Module not found.
	}
	s, _ := d[offset]
	return s // Empty if offset not found.
}

func LoadDir(dirname string) *Listings {
	filenames, err := filepath.Glob(filepath.Join(dirname, "*.list"))
	if err != nil {
		log.Panicf("Cannot read directory %q: %v", dirname, err)
	}
	listings := &Listings{
		Lines: make(map[string]map[uint]string),
	}
	for _, filename := range filenames {
		base := filepath.Base(filename)
		parts := strings.Split(base, ".")
		key := strings.ToLower(parts[0])
		listings.Lines[key] = loadFile(filename)
	}
	return listings
}

var parse = regexp.MustCompile(`^([0-9A-F]{4}) [0-9A-F]+ +[(].*?[)]:[0-9]{5} *(.*)$`)

func loadFile(filename string) map[uint]string {
	d := make(map[uint]string)
	fd, err := os.Open(filename)
	if err != nil {
		log.Panicf("Cannot open listing %q: %v", filename, err)
	}
	defer fd.Close()
	r := bufio.NewScanner(fd)
	for r.Scan() {
		m := parse.FindStringSubmatch(r.Text())
		if m != nil {
			hexaddr, line := m[1], m[2]
			addr, err := strconv.ParseUint(hexaddr, 16, 16)
			if err != nil {
				log.Panicf("Should have been a hex integer: %q: %v", hexaddr, err)
			}
			d[uint(addr)] = line
		}
	}
	return d
}
