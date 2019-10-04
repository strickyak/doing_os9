/*
	Scrape important Os9 assembly symbols from a -symbols .list file and generate Go code with const definitions.

	Suggestions:
		go run scrape_os9_symbols/scrape_os9_symbols.go "level1" < /.../nitros9/level1/coco1/modules/rel.list | gofmt > gomar/sym/level1_defs.go
		go run scrape_os9_symbols/scrape_os9_symbols.go "level2" < /.../nitros9/level2/coco3/modules/rel_40.list | gofmt > gomar/sym/level2_defs.go

*/
package main

import (
	"bufio"
	"flag"
	"fmt"
	"os"
	"log"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
)

var flagListing = flag.String("listing", "", "assembler listing with definitions")
var flagErrMsg = flag.String("errmsg", "", "errmsg file from SYS directory")

// We pick symbols with a single `$` or `.`.
var SymbolMatch = regexp.MustCompile(`^[[].G[]] ([A-Za-z]+)([.$])([A-Za-z0-9]*) +([0-9A-F]{4})\s*$`)
var ErrMsgMatch = regexp.MustCompile(`^([0-9]+) [-]+ (.*)$`)

func SortedKeys(m map[string]string) []string {
	var keys []string
	for k := range m {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	return keys
}

func main() {
	flag.Parse()
	// Command line args are the +build tags to require.
	for _, arg := range flag.Args() {
		fmt.Printf("// +build %s\n", arg)
	}
	// Blank line required between +build directives and package comment.
	fmt.Printf("\n")
	// Avoid the following sentance appearing plain in this source file!
	fmt.Printf("// This file was %s by %s\n", "generated", filepath.Base(os.Args[0]))
	fmt.Printf("package sym\n")
	fmt.Printf("const (\n")

	structs := make(map[string]map[uint]string)
	structs["D."] = make(map[uint]string)
	structs["P$"] = make(map[uint]string)
	structs["PD."] = make(map[uint]string)

	consts := make(map[string]string)
	syscalls := make(map[string]string)
	errnos := make(map[string]string)

	fd, err := os.Open(*flagListing)
	if err != nil {
		log.Fatalf("Cannot open listing file %q: %v", *flagListing, err)
	}
	r := bufio.NewScanner(fd)
	for r.Scan() {
		t := r.Text()
		m := SymbolMatch.FindStringSubmatch(t)
		if m != nil {
			symbol := fmt.Sprintf("%s%s%s", m[1], m[2], m[3])
			constName := fmt.Sprintf("%s_%s", m[1], m[3])
			consts[constName] = m[4]
			fmt.Printf("\t%-12s = 0x%s // %s\n", constName, m[4], symbol)
			if m[2] == "$" && (m[1] == "F" || m[1] == "I") {
				syscalls[symbol] = constName
			}
			if m[2] == "$" && (m[1] == "E") {
				errnos[constName] = m[3]
			}
			value64, _ := strconv.ParseUint(m[4], 16, 16)
			value := uint(value64)
			if d, ok := structs[m[1] + m[2]] ; ok {
				d[value] = m[3]
			}
		}
	}
	fmt.Printf(")\n")

	fmt.Printf("var SysCallNames = map[byte]string {\n")
	for _, symbol := range SortedKeys(syscalls) {
		constName := syscalls[symbol]
		fmt.Printf("\t%s: %q,\n", constName, symbol)
	}
	fmt.Printf("}\n")

	fmt.Printf("type Slot struct { off uint; symbol string }\n")
	for s, d := range structs {
		fmt.Printf("var Slots_%s = []Slot {\n", s[:len(s)-1])
		for i := uint(0); i < 512; i++ {
			if symbol, ok := d[i]; ok {
				fmt.Printf("\t{0x%04x, %q},\n", i, symbol)
			}
		}
		fmt.Printf("}\n")
	}

	done := make(map[string]bool)
	fmt.Printf("var Os9Error = map[byte]string {\n")
	for _, errno := range SortedKeys(errnos) {
		val := consts[errno]
		did, _ := done[val]
		if !did {
			fmt.Printf("\t%s: %q,\n", errno, "E$" + errnos[errno])
			done[val] = true
		}
	}
	fmt.Printf("}\n")

	fmt.Printf("var Os9ErrorName = map[byte]string {\n")
	fd, err = os.Open(*flagErrMsg)
	if err != nil {
		log.Fatalf("Cannot open errmsg file %q: %v", *flagErrMsg, err)
	}
	r = bufio.NewScanner(fd)
	for r.Scan() {
		t := r.Text()
		m := ErrMsgMatch.FindStringSubmatch(t)
		if m == nil {
			log.Fatalf("Cannot ErrMsgMatch this line from %q: %q", *flagErrMsg, t)
		}
		fmt.Printf("\t%s: %q,\n", m[1], m[2])
	}
	fmt.Printf("}\n")
}
