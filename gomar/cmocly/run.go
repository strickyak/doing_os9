package cmocly

import (
	"bufio"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

type RunSpec struct {
	AsmListingPath string
	LwAsm          string
	LwLink         string
	Cmoc           string
	OutputBinary   string
	Args           []string
}

func (rs RunSpec) RunCompiler(filename string) {
	cmd := exec.Command(rs.Cmoc, "--os9", "-S", filename)
	log.Printf("RUNNING: %v", cmd)
	err := cmd.Run()
	if err != nil {
		log.Fatalf("cmoc compiler failed: %v: %v", cmd, err)
	}
}
func (rs RunSpec) RunAssembler(filename string) {
	cmd := exec.Command(
		rs.LwAsm, "--obj", "--6809",
		"--list="+filename+".o.list",
		"-o", filename+".o",
		filename+".s")
	log.Printf("RUNNING: %v", cmd)
	err := cmd.Run()
	if err != nil {
		log.Fatalf("lwasm aassembler failed: %v: %v", cmd, err)
	}
}
func (rs RunSpec) RunLinker(ofiles []string, outbin string) {
	cmdargs := []string{"--os9", "-i", "--lwlink=" + rs.LwLink}
	cmdargs = append(cmdargs, ofiles...)
	cmd := exec.Command(rs.Cmoc, cmdargs...)
	log.Printf("RUNNING: %v", cmd)
	err := cmd.Run()
	if err != nil {
		log.Fatalf("cmoc/lwlink linker failed: %v: %v", cmd, err)
	}
}
func (rs RunSpec) Run() {
	if len(rs.Args) == 0 {
		log.Fatalf("no filanames to compile")
	}

	alists := make(map[string]map[string][]*AsmListingRecord)
	var ofiles []string
	for _, filename := range rs.Args {
		if !strings.HasSuffix(filename, ".c") {
			log.Fatalf("filename should end in .c: %q", filename)
		}
		rs.RunCompiler(filename)
		filebase := strings.TrimSuffix(filename, ".c")
		rs.RunAssembler(filebase)
		alist := ReadAsmListing(filebase + ".o.list")
		alists[Basename(filename)] = alist
		ofiles = append(ofiles, filebase+".o")
	}
	rs.RunLinker(ofiles, rs.OutputBinary)

	lmap := ReadLinkerMap(rs.OutputBinary + ".map")
	for _, e := range lmap {
		log.Printf("... %#v", *e)
	}

	listing_dirs := strings.Split(rs.AsmListingPath, ":")
	SearchForNeededListings(alists, lmap, listing_dirs)

	for filename, alist := range alists {
		for section, records := range alist {
			for _, rec := range records {
				log.Printf("%q ... %q ... %#v", filename, section, *rec)
			}
		}
	}

	mod, err := ioutil.ReadFile(rs.OutputBinary)
	if err != nil {
		log.Fatalf("Cannot read Output Binary: %q: %v", rs.OutputBinary, err)
	}

	fd, err := os.Create(rs.OutputBinary + ".listing")
	if err != nil {
		log.Fatalf("Cannot create Output listing: %q: %v", rs.OutputBinary+".listing", err)
	}
	w := bufio.NewWriter(fd)

	OutputFinalListing(lmap, alists, mod, w)
	w.Flush()
	fd.Close()

	modname := GetOs9ModuleName(mod)
	log.Printf("Module Name: %q", modname)
	log.Printf("Module Length: %04x", len(mod))
	checksum := mod[len(mod)-3:]
	log.Printf("Module CheckSum: %02x", checksum)

	r2, err := os.Open(rs.OutputBinary + ".listing")
	borges_name := fmt.Sprintf("%s.listing~%s.%04x%02x", rs.OutputBinary, modname, len(mod), checksum)
	log.Printf("Borges name: %q", borges_name)
	w2, err := os.Create(borges_name)
	if err != nil {
		log.Fatalf("Cannot create Borges listing: %q: %v", borges_name, err)
	}
	_, err = io.Copy(w2, r2)
	if err != nil {
		log.Fatalf("error copying to Borges listing: %q: %v", borges_name, err)
	}
	r2.Close()
	w2.Close()
}

func OutputFinalListing(
	lmap []*LinkerMapRecord,
	alists map[string]map[string][]*AsmListingRecord,
	mod []byte,
	w io.Writer) {
	for _, rec := range lmap {
		if rec.Section == "" {
			continue
		}
		if rec.Section == "bss" {
			continue
		}
		start := rec.Start
		n := rec.Length
		if n == 0 {
			continue
		}
		f := Basename(rec.Filename)
		alist, ok := alists[f]
		if !ok {
			log.Printf("Missing alist file: %q -> %q", rec.Filename, f)
			continue
		}
		seclist, ok := alist[rec.Section]
		if !ok {
			log.Printf("Missing alist section: %q -> %q; %q: %#v", rec.Filename, f, rec.Section, rec)
			continue
		}
		fmt.Fprintf(w, "\n")
		for _, line := range seclist {
			if line.Location >= n {
				log.Printf("Line location too big (>= %d): %#v", n, line)
				continue
			}
			log.Printf("loc %x + start %x = @%04x: %#v", line.Location, start, line.Location+start, line)

			hex := line.Bytes
			/*
			   if len(hex) > 16 {
			       hex = hex[:16]
			   }
			*/
			name := line.Filename
			/*
			   if len(name) > 17 {
			       name = name[:17]
			   }
			*/

			inst := fmt.Sprintf("%s:%05d | %s", strings.Trim(name, " "), line.LineNum, line.Instruction)
			// fmt.Fprintf(w, "%04x %-16s (%17s):%05d         %s\n", line.Location + start, hex, line.Filename, line.LineNum, line.Instruction)
			// fmt.Fprintf(w, "%04X %-16s (%s):%05d         %s\n", line.Location + start, hex, name, line.LineNum, line.Instruction)
			fmt.Fprintf(w, "%04X %-16s (%s):%05d         %s\n", line.Location+start, hex, name, line.LineNum, inst)
		}
		fmt.Fprintf(w, "\n")
	}
}

func GetOs9ModuleName(mod []byte) string {
	if mod[0] != 0x87 || mod[1] != 0xCD {
		panic("bad header")
	}
	expectedLen := int(mod[2])*256 + int(mod[3])
	if len(mod) != expectedLen {
		panic("bad length")
	}
	i := int(mod[4])*256 + int(mod[5])
	var z []byte
	for ; 0 == (mod[i] & 0x80); i++ {
		z = append(z, mod[i])
	}
	z = append(z, mod[i]&0x7F)
	return string(z)
}

func Basename(s string) string {
	// base name (directory removed)
	base := filepath.Base(s)
	// only what is before the first '.'
	return strings.Split(base, ".")[0]
}

func UseBasenames(
	alists map[string]map[string][]*AsmListingRecord) {
	// save keys
	var keys []string
	for k := range alists {
		keys = append(keys, k)
	}
	// now mutate map
	for _, key := range keys {
		alists[Basename(key)] = alists[key]
	}
}

func SearchForNeededListings(
	alists map[string]map[string][]*AsmListingRecord,
	lmap []*LinkerMapRecord,
	dirs []string) {
	// Use basenames in alists.
	UseBasenames(alists)

	for _, base := range BasenamesOfLinkerMap(lmap) {
		log.Printf("LINKER NAME %q", base)
		for _, dir := range dirs {
			filename := filepath.Join(dir, base+".os9_o.list")
			println("CHECK", filename)
			fd, err := os.Open(filename)
			println(fd, err)
			if err == nil {
				alist := ReadAsmListing(filename)
				for section, records := range alist {
					for _, rec := range records {
						log.Printf("%q... %q ... %#v", filename, section, *rec)
					}
				}
				alists[base] = alist
				fd.Close()
			}
		}
	}

}
