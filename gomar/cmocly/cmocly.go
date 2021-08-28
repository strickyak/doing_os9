// +build main

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

	. "github.com/strickyak/doing_os9/gomar/cmocly"
)

var flag_linker_map = flag.String("linker_map", "", "filename of linker map")
var flag_asm_listing = flag.String("asm_listing", "", "filename of asm listing")
var flag_asm_listing_path = flag.String("asm_listing_path", "/home/strick/COCO/build/cmoc-rebuild/src/stdlib/", "where to look for listings")

var flag_lwasm = flag.String("lwasm", "/opt/yak/bin-os9/lwasm", "lwasm command")
var flag_lwlink = flag.String("lwlink", "/opt/yak/bin-os9/lwlink", "lwlink command")
var flag_cmoc = flag.String("cmoc", "/opt/yak/cmoc/bin/cmoc", "cmoc")
var flag_borges_dir = flag.String("borges_dir", "/home/strick/go/src/github.com/strickyak/doing_os9/borges/", "cmoc")
var flag_linker_map_in = flag.String("linker_map_in", "", "read linker map for direct page vars")

var flag_o = flag.String("o", "", "output binary name")

func main() {
	flag.Parse()
	log.SetFlags(0)
	log.SetPrefix("## ")

	if *flag_o == "" {
		demo()
	} else {
		RunSpec{
			AsmListingPath: *flag_asm_listing_path,
			LwAsm:          *flag_lwasm,
			LwLink:         *flag_lwlink,
			Cmoc:           *flag_cmoc,
			OutputBinary:   *flag_o,
			Args:           flag.Args(),
			BorgesDir:      *flag_borges_dir,
		}.RunAll()
	}
}

func demo() {
	var lmap []*LinkerMapRecord
	if *flag_linker_map != "" {
		lmap = ReadLinkerMap(*flag_linker_map)
		for _, e := range lmap {
			log.Printf("... %#v", *e)
		}
	}
	alists := make(map[string]map[string][]*AsmListingRecord)
	if *flag_asm_listing != "" {
		for _, filename := range strings.Split(*flag_asm_listing, ":") {
			alist := ReadAsmListing(filename)
			for section, records := range alist {
				for _, rec := range records {
					log.Printf("%q... %q ... %#v", filename, section, *rec)
				}
			}
			alists[filename] = alist
		}
	}
	if *flag_asm_listing_path != "" {
		dirs := strings.Split(*flag_asm_listing_path, ":")
		SearchForNeededListings(alists, lmap, dirs)
	}
}
