package cmocly

import (
	"bufio"
	"log"
	"os"
	"regexp"
	"strings"
)

const kDEFAULT = "DEFAULT" // section name, if not in a section.

type AsmListingRecord struct {
	Location    int
	Bytes       string
	Filename    string
	LineNum     int
	Instruction string
}

func ReadAsmListing(filename string) map[string][]*AsmListingRecord {
	fd, err := os.Open(filename)
	if err != nil {
		log.Fatalf("ReadLinkerMap: Cannot open %q: %v", filename, err)
	}
	sc := bufio.NewScanner(fd)
	z := make(map[string][]*AsmListingRecord)
	section := kDEFAULT
	for sc.Scan() {
		line := sc.Text()
		{
			m := matchNormal.FindStringSubmatch(line)
			if m != nil {
				vec, _ := z[section]
				z[section] = append(vec, &AsmListingRecord{
					Location:    parseHex(m[1]),
					Bytes:       m[2],
					Filename:    m[3],
					LineNum:     parseDec(m[4]),
					Instruction: m[5],
				})
				continue
			}
		}
		{
			m := matchDirective.FindStringSubmatch(line)
			if m != nil {
				directive := m[3]
				name := m[4]
				if strings.ToUpper(directive) == "SECTION" {
					section = name
				} else if strings.ToUpper(directive) == "ENDSECTION" {
					section = kDEFAULT
				}
				continue
			}
		}
	}
	if err = sc.Err(); err != nil {
		log.Fatalf("ReadLinkerMap: while reading %q: %v", filename, err)
	}
	return z
}

var matchNormal = regexp.MustCompile(
	`^([[:xdigit:]]{4}) ([[:xdigit:]]{2,32}) *[(]([^()]+)[)]:([[:digit:]]{5})         (.*)`)

var matchDirective = regexp.MustCompile(
	`^ *[(]([^()]+)[)]:([[:digit:]]{5})         [ ]*([[:word:]]+) *([[:word:]]*)`)
