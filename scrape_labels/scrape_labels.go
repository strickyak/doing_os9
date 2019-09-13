// a very incorrect kludge for getting level2 labels.
package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"regexp"
	"strconv"
	"strings"
)

var RE = regexp.MustCompile("[ ]*([0-9A-F]*)[ ]+[(].*[.]d[)][:][0-9]{5}[ ]+([A-Za-z0-9.$_]+)[ ]*([^ ]*)")

var dict = make(map[string]uint16)

func assign(val, name string) {
	old, ok := dict[name]
	if ok {
		log.Fatalf("Defined twice: %q = %q (was %x)", name, val, old)
	}
	x, err := strconv.ParseUint(val, 16 /*base*/, 16 /* bits */)
	if err != nil {
		log.Fatalf("Cannot parse hex %q = %q: %v", name, val, err)
	}
	dict[name] = uint16(x)
}

func main() {
	inhibit := false
	r := bufio.NewScanner(os.Stdin)
	for r.Scan() {
		t := r.Text()
		m := RE.FindStringSubmatch(t)
		//fmt.Printf("LINE[%d]: %s\n", len(m), t)

		if m == nil {
			continue
		}
		if len(m) != 4 {
			continue
		}

		val := m[1]
		s1 := m[2]
		s1u := strings.ToUpper(s1)
		s2 := m[3]
		s2u := strings.ToUpper(s2)

		if s1u == "IFEQ" && s2 == "Level-1" {
			inhibit = true
		}
		if s1u == "IFNE" && s2 == "1" {
			inhibit = true
		}
		if s1u == "IFNE" && s2 == "H6309" {
			inhibit = true
		}
		if s1u == "IFNE" && s2 == "DRAGON" {
			inhibit = true
		}
		if s1u == "IFEQ" && s2 == "CPUType-Color" {
			inhibit = true
		}
		if s1u == "IFEQ" && s2 == "PwrLnFrq-Hz50" {
			inhibit = true
		}
		if s1u == "IFEQ" && s2 == "Level-2" {
			inhibit = true
		}

		if s1u == "ELSE" || s1u == "ENDC" {
			inhibit = false
		}

		if s1u == "ELSE" || s1u == "ENDC" {
			inhibit = false
		}

		if !inhibit && len(s1) > 0 && strings.ContainsAny(s1, ".$") {

			if s2u == "RMB" || s2u == "EQU" || s2u == "SET" {
				assign(val, s1)
				// fmt.Printf("%30s %04x  : %s\n", s1, dict[s1], t)
				fmt.Printf("%30s %04x\n", s1, dict[s1])
			}

		}
	}
}
