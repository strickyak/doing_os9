package lib

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
)

var PRE = flag.String("cmoc_pre", "", "prefix these flags to cmoc")

type RunSpec struct {
	AsmListingPath string
	LwAsm          string
	LwLink         string
	Cmoc           string
	OutputBinary   string
	Args           []string
	BorgesDir      string

	IncludeDirs []string
	LibDirs     []string
	LibFiles    []string
}

func (rs RunSpec) RunCompiler(filename string, includeDirs []string) {
	args := []string{"--os9", "-S"}
	for _, a := range strings.Split(*PRE, " ") {
		if a != "" {
			args = append(args, a)
		}
	}
	for _, e := range includeDirs {
		args = append(args, "-I"+e)
	}
	args = append(args, filename)
	cmd := exec.Command(rs.Cmoc, args...)
	cmd.Stdout = os.Stderr
	cmd.Stderr = os.Stderr
	log.Printf("RUNNING: %v", cmd)
	log.Printf("")
	err := cmd.Run()
	log.Printf("")
	if err != nil {
		log.Fatalf("cmoc compiler failed: %v: %v", cmd, err)
	}
}
func (rs RunSpec) TweakAssembler(filename string, directs map[string]bool) {
	orig_filename := filename + ".s-orig"
	new_filename := filename + ".s"

	err := os.Rename(new_filename, orig_filename)
	if err != nil {
		log.Fatalf("cannot rename %q to %q: %v",
			filename+".s", filename+".s-orig", err)
	}

	r, err := os.Open(orig_filename)
	if err != nil {
		log.Fatalf("cannot open: %q: %v", orig_filename, err)
	}
	w, err := os.Create(new_filename)
	if err != nil {
		log.Fatalf("cannot create: %q: %v", new_filename, err)
	}

	skip := 0
	pushedY := 0
	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		s := scanner.Text()

		// Sometimes Y is pushed and temporarily changed while an extra reg is needed.
		if FindPushY(s) != nil {
			pushedY++
		} else if FindPullY(s) != nil {
			pushedY--
		}

		// Only optimize ,Y patterns if Y is not pushed.
		if pushedY == 0 {
			m1 := FindCommaYTab(s)
			m2 := FindCommaYEnd(s)
			if m1 != nil {
				s = fmt.Sprintf("%s\t%s", m1[1], m1[2])
			} else if m2 != nil {
				s = fmt.Sprintf("%s\t;", m2[1])
			}

			m3 := FindLeaxVar(s)
			if m3 != nil {
				s = fmt.Sprintf("%s\tLDX\t#%s\t%s", m3[1], m3[2], m3[3])
			}

			m4 := FindLbsrStkcheck(s)
			if m4 != nil {
				skip = 2
			}
		}

		m5 := FindPotentiallyDirect(s)
		if m5 != nil {
			if _, ok := directs[m5[4]]; ok {
				s = fmt.Sprintf("%s\t%s\t%s<%s%s", m5[1], m5[2], m5[3], m5[4], m5[5])
			}
		}

		if skip == 0 {
			fmt.Fprintf(w, "%s\n", s)
		} else {
			skip--
		}
	}
	if err := scanner.Err(); err != nil {
		log.Fatalf("reading standard input:", err)
	}
	r.Close()
	w.Close()
}

var FindPushY = regexp.MustCompile("(.*)\tPSHS\tY(\t.*|$)").FindStringSubmatch
var FindPullY = regexp.MustCompile("(.*)\tPULS\tY(\t.*|$)").FindStringSubmatch

var FindCommaYTab = regexp.MustCompile("(.*),Y\t(.*)").FindStringSubmatch
var FindCommaYEnd = regexp.MustCompile("(.*),Y$").FindStringSubmatch
var FindLeaxVar = regexp.MustCompile("(.*)\tLEAX\t([[:word:]]+[+][[:digit:]]+)\t(.*)").FindStringSubmatch
var FindLbsrStkcheck = regexp.MustCompile("LBSR\t_stkcheck").FindStringSubmatch
var FindPotentiallyDirect = regexp.MustCompile("(.*)\t(LDD|STD|ADDD|CMPD|LDX|STX|LEAX)\t([[]?)(_[[:word:]]+)([+]0.*)").FindStringSubmatch

func (rs RunSpec) RunAssembler(filename string) {
	cmd := exec.Command(
		rs.LwAsm, "--obj", "--6809",
		"--list="+filename+".o.list",
		"-o", filename+".o",
		filename+".s")
	cmd.Stdout = os.Stderr
	cmd.Stderr = os.Stderr
	log.Printf("RUNNING: %v", cmd)
	log.Printf("")
	err := cmd.Run()
	log.Printf("")
	if err != nil {
		log.Fatalf("lwasm assembler failed: %v: %v", cmd, err)
	}
}
func (rs RunSpec) RunLinker(ofiles []string, outbin string, libDirs []string, libFiles []string) {
	cmdargs := []string{"--os9", "-i", "--lwlink=" + rs.LwLink, "-o", outbin}
	cmdargs = append(cmdargs, ofiles...)
	for _, e := range libDirs {
		cmdargs = append(cmdargs, "-L"+e)
	}
	for _, e := range libFiles {
		cmdargs = append(cmdargs, "-l"+e)
	}
	cmd := exec.Command(rs.Cmoc, cmdargs...)
	log.Printf("RUNNING: %v", cmd)
	log.Printf("")
	cmd.Stdout = os.Stderr
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	log.Printf("")
	if err != nil {
		log.Fatalf("cmoc/lwlink linker failed: %v: %v", cmd, err)
	}
}
func (rs RunSpec) RunAll() {
	if len(rs.Args) == 0 {
		log.Fatalf("no filenames to compile")
	}

	directs := make(map[string]bool)
	alists := make(map[string]map[string][]*AsmListingRecord)
	var lmap []*LinkerMapRecord
	for phase := 1; phase <= 2; phase++ {
		var ofiles []string
		for _, filename := range rs.Args {
			// TODO: handle ".asm" files.

			if strings.HasSuffix(filename, ".c") {
				// CASE *.c

				if !strings.HasSuffix(filename, ".c") {
					log.Fatalf("filename should end in .c: %q", filename)
				}
				rs.RunCompiler(filename, rs.IncludeDirs)
				filebase := strings.TrimSuffix(filename, ".c")
				filebase = filepath.Base(filebase) // in case .c file was in another directory.

				rs.TweakAssembler(filebase, directs)
				rs.RunAssembler(filebase)
				if phase == 2 {
					alist := ReadAsmListing(filebase + ".o.list")
					alists[filename] = alist
				}
				ofiles = append(ofiles, filebase+".o")

			} else if strings.HasSuffix(filename, ".asm") {

				contents, err := ioutil.ReadFile(filename)
				if err != nil {
					log.Fatalf("cannot read file %q: %v", filename, err)
				}

				filebase := strings.TrimSuffix(filename, ".c")
				filebase = filepath.Base(filebase) // in case .c file was in another directory.

				err = ioutil.WriteFile(filebase+".s", contents, 0777)
				if err != nil {
					log.Fatalf("cannot write file %q: %v", filebase+".s", err)
				}

				rs.RunAssembler(filebase)
				if phase == 2 {
					alist := ReadAsmListing(filebase + ".o.list")
					alists[filename] = alist
				}
				ofiles = append(ofiles, filebase+".o")

			} else {

				log.Fatalf("Cannot compile %q (not *.c and not *.asm)", filename)

			}
		}
		rs.RunLinker(ofiles, rs.OutputBinary, rs.LibDirs, rs.LibFiles)
		// Read the linker map.
		// The first time is for the `directs` set of potential direct page variables.
		// The second time is for finding all the linked object files and output the final listing.
		lmap = ReadLinkerMap(rs.OutputBinary + ".map")
		for _, e := range lmap {
			if e.Section == "" && strings.HasPrefix(e.Symbol, "_") && e.Start < 256 {
				directs[e.Symbol] = true
			}
		}
	} // next phase

	listing_dirs := strings.Split(rs.AsmListingPath, ":")
	SearchForNeededListings(alists, lmap, listing_dirs)

	mod, err := ioutil.ReadFile(rs.OutputBinary)
	if err != nil {
		log.Fatalf("Cannot read Output Binary: %q: %v", rs.OutputBinary, err)
	}

	modname := GetOs9ModuleName(mod)
	log.Printf("Module Name: %q", modname)
	log.Printf("Module Length: %04x", len(mod))
	checksum := mod[len(mod)-3:]
	log.Printf("Module CheckSum: %02x", checksum)
	borges_version := fmt.Sprintf("%s.%04x%02x", strings.ToLower(modname), len(mod), checksum)
	log.Printf("borges Version: %q", borges_version)

	list_out_filename := rs.OutputBinary + ".listing"
	if rs.BorgesDir != "" {
		// Change to use the lowercase module name and version suffix, in the Borges Dir.
		list_out_filename = filepath.Join(rs.BorgesDir, borges_version)
	}

	fd, err := os.Create(list_out_filename)
	if err != nil {
		log.Fatalf("Cannot create Output listing: %q: %v", list_out_filename, err)
	}
	w := bufio.NewWriter(fd)

	OutputFinalListing(lmap, alists, mod, w)
	w.Flush()
	fd.Close()

	log.Printf("WROTE FINAL LISTING TO %q", list_out_filename)
}

func OutputFinalListing(
	lmap []*LinkerMapRecord,
	alists map[string]map[string][]*AsmListingRecord,
	mod []byte,
	w io.Writer) {

	// just verbose:
	for _k, _v := range alists {
		log.Printf("ALIST: %q ...", _k)
		for _s, _e := range _v {
			log.Printf("...... SECTION %q # %d", _s, len(_e))
		}
	}

	for _, rec := range lmap {
		if rec.Section == "" {
			// It's a Symbol, not a Section.
			continue
		}
		if rec.Section == "bss" {
			// BSS have no instructions.
			continue
		}
		start := rec.Start
		n := rec.Length
		if n == 0 {
			continue
		}
		f := rec.Filename
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
			hex := line.Bytes
			name := line.Filename
			inst := fmt.Sprintf("%s:%05d | %s", strings.Trim(name, " "), line.LineNum, line.Instruction)
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

type alistsType map[string]map[string][]*AsmListingRecord

func FixAlistNames(alists alistsType) alistsType {
	// save keys
	var keys []string
	for k := range alists {
		keys = append(keys, k)
		log.Printf("OLD ALIST: %q", k)
	}
	// now mutate map
	newAlists := make(alistsType)
	for _, key := range keys {
		k2 := filepath.Base(key)
		if strings.HasSuffix(k2, ".c") {
			k2 = strings.TrimSuffix(k2, ".c")
			k2 += ".o"
		}
		newAlists[k2] = alists[key]
		log.Printf("NEW ALIST: %q -> %q", key, k2)
	}
	return newAlists
}

func SearchForNeededListings(
	alists map[string]map[string][]*AsmListingRecord,
	lmap []*LinkerMapRecord,
	dirs []string) {

	for _, base := range BasenamesOfLinkerMap(lmap) {
		log.Printf("[Search] LINKER NAME %q", base)
		for _, dir := range dirs {
			asm_filename := filepath.Join(dir, base+".list")

			println("[Search] CHECK", asm_filename)
			fd, err := os.Open(asm_filename)
			println(fd, err)
			if err == nil {
				alist := ReadAsmListing(asm_filename)
				for section, records := range alist {
					for _, rec := range records {
						log.Printf("[Search ReadAsm] %q... %q ... %#v", asm_filename, section, *rec)
					}
				}
				alists[base] = alist
				fd.Close()
			}
		}
	}

}
