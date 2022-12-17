package main

/* TODO
cmoc --os9 -S temp.c
cmoc --os9 -S defs.c
cmoc --os9 -S octet.c
lwasm --obj --6809 --list=temp.list -o temp.o temp.s
lwasm --obj --6809 --list=defs.list -o defs.o defs.s
lwasm --obj --6809 --list=octet.list -o octet.o octet.s
:
*/

// TODO: cmoc -i --lwlink=/opt/bin-os9/lwlink-v --os9 -o temp   temp.o defs.o octet.o

// TODO: cmocly --lwlink=/opt/bin-os9/lwlink-v --o temp temp.c defs.c octet.c

import (
	"flag"
	"log"
	"strings"

	. "github.com/strickyak/doing_os9/gomar/cmocly/lib"
)

var flag_linker_map = flag.String("linker_map", "", "filename of linker map")
var flag_asm_listing = flag.String("asm_listing", "", "filename of asm listing")
var flag_asm_listing_path = flag.String("asm_listing_path", ".:/opt/build/cmoc/src/stdlib", "where to look for listings")

var flag_lwasm = flag.String("lwasm", "/opt/yak/bin-os9/lwasm", "lwasm command")
var flag_lwlink = flag.String("lwlink", "/opt/yak/bin-os9/lwlink", "lwlink command")
var flag_cmoc = flag.String("cmoc", "/opt/yak/cmoc/bin/cmoc", "cmoc")
var flag_borges_dir = flag.String("borges_dir", "/home/strick/go/src/github.com/strickyak/doing_os9/borges/", "cmoc")
var flag_linker_map_in = flag.String("linker_map_in", "", "read linker map for direct page vars")

var flag_o = flag.String("o", "", "output binary name")
var flag_I = flag.String("I", "", "Include Dirs (comma sep)")
var flag_L = flag.String("L", "", "Library Dirs (comma sep)")
var flag_l = flag.String("l", "", "Libraries (comma sep)")

var _ = flag.Bool("os9", true, "always in --os9 mode, for now")

func main() {
	flag.Parse()
	log.SetFlags(0)
	log.SetPrefix("## ")

	if *flag_o == "" {
		log.Fatalf("You must provide the -o option")
	}
	RunSpec{
		AsmListingPath: *flag_asm_listing_path,
		LwAsm:          *flag_lwasm,
		LwLink:         *flag_lwlink,
		Cmoc:           *flag_cmoc,
		OutputBinary:   *flag_o,
		Args:           flag.Args(),
		BorgesDir:      *flag_borges_dir,
		IncludeDirs:    strings.Split(*flag_I, ","),
		LibDirs:        strings.Split(*flag_L, ","),
		LibFiles:       strings.Split(*flag_l, ","),
	}.RunAll()
}
