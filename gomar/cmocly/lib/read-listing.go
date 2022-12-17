package lib

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
	log.Printf("ENTER ReadAsmListing %q", filename)
	fd, err := os.Open(filename)
	if err != nil {
		log.Fatalf("ReadLinkerMap: Cannot open %q: %v", filename, err)
	}
	sc := bufio.NewScanner(fd)
	z := make(map[string][]*AsmListingRecord)
	section := kDEFAULT
	lineLabel := ""
	comment := ""
	for sc.Scan() {
		line := sc.Text()
		{
			m := matchNormal.FindStringSubmatch(line)
			if m != nil {
				vec, _ := z[section]
				instruction := m[5]
				if lineLabel != "" {
					n := len(lineLabel)
					if n > 6 {
						n = 6
					}
					// remove up to n+1 leading blanks from instruction.
					for i := 0; i < n+1; i++ {
						if len(instruction) > 0 && instruction[0] == ' ' {
							instruction = instruction[1:]
						}
					}
					instruction = lineLabel + " " + instruction
					lineLabel = ""
				}
				if comment != "" {
					instruction = instruction + ";" + comment
					comment = "" // start comment over.
				}
				z[section] = append(vec, &AsmListingRecord{
					Location:    parseHex(m[1]),
					Bytes:       m[2],
					Filename:    m[3],
					LineNum:     parseDec(m[4]),
					Instruction: instruction,
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
		{
			m := matchLabelEquStar.FindStringSubmatch(line)
			if m != nil {
				lineLabel = m[4]
				continue
			}
		}
		{
			m := matchStarComment.FindStringSubmatch(line)
			if m != nil {
				if strings.HasPrefix(m[3], "* Useless label") {
					continue
				}
				comment = comment + ";" + m[3]
				continue
			}
		}
		{
			m := matchEmptySourceLine.FindStringSubmatch(line)
			if m != nil {
				comment = "" // Reset after empty lines.
				continue
			}
		}
	}
	if err = sc.Err(); err != nil {
		log.Fatalf("ReadLinkerMap: while reading %q: %v", filename, err)
	}
	for _k, _v := range z {
		log.Printf("SECTION %q LEN %d", _k, len(_v))
		if _k == "code" {
			for _i, _e := range _v {
				log.Printf("[%05d] %04x #%d[%q]. %q", _i, _e.Location, len(_e.Bytes), _e.Bytes, _e.Instruction)
			}
		}
	}
	return z
}

var matchNormal = regexp.MustCompile(
	`^([[:xdigit:]]{4}) ([[:xdigit:]]{2,32}) *[(]([^()]+)[)]:([[:digit:]]{5})         (.*)`)

var matchDirective = regexp.MustCompile(
	`^ *[(]([^()]+)[)]:([[:digit:]]{5})         [ ]*([[:word:]]+) *([[:word:]]*)`)

// 12345
//
//	0399             (          chain.s):00838         _ChainIterMore  EQU     *
var matchLabelEquStar = regexp.MustCompile(
	`^     ([[:xdigit:]]{4}) *[(]([^()]+)[)]:([[:digit:]]{5}) *([[:word:]]+) *EQU *[*] *(.*)`)

var matchStarComment = regexp.MustCompile(
	`^          *[(]([^()]+)[)]:([[:digit:]]{5}) *([*].*)$`)

var matchEmptySourceLine = regexp.MustCompile(
	`^          *[(]([^()]+)[)]:([[:digit:]]{5}) *$`)
