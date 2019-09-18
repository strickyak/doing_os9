/* 6809 Simulator "GOMAR".

   License: GNU General Public License version 2, see LICENSE for more details.

   Converted to GO LANG by Henry Strickland, 2019,
   based on code with the following copyleft:

   ============================================================================

   created 1994 by L.C. Benschop.
   copyleft (c) 1994-2014 by the sbc09 team, see AUTHORS for more details.
   license: GNU General Public License version 2, see LICENSE for more details.

   This program simulates a 6809 processor.

   System dependencies: short must be 16 bits.
                        char  must be 8 bits.
                        long must be more than 16 bits.
                        arrays up to 65536 bytes must be supported.
                        machine must be twos complement.
   Most Unix machines will work. For MSODS you need long pointers
   and you may have to malloc() the mem array of 65536 bytes.

   Define CPU_BIG_ENDIAN with != 0 if you have a big-endian machine (680x0 etc)
   Usually UNIX systems get this automatically from BIG_ENDIAN and BYTE_ORDER
   definitions ...

   Define TRACE if you want an instruction trace on stderr.
   Define TERM_CONTROL if you want nonblocking non-echoing key input.
   * THIS IS DIRTY !!! *

   Special instructions:
   SWI2 writes char to stdout from register B.
   SWI3 reads char from stdout to register B, sets carry at EOF.
               (or when no key available when using term control).
   SWI retains its normal function.
   CWAI and SYNC stop simulator.

   The program reads a binary image file at $100 and runs it from there.
   The file name must be given on the command line.

   Revisions:
        2012-06-05 johann AT klasek at
                Fixed: com with C "NOT" operator ... 0^(value) did not work!
        2012-06-06
                Fixed: changes from 1994 release (flag handling)
                        reestablished.
        2012-07-15 JK
                New: option parsing, new option -d (dump memory on exit)
        2013-10-07 JK
                New: print ccreg with flag name in lower/upper case depending on flag state.
        2013-10-20 JK
                New: Show instruction disassembling in trace mode.
        2014-07-01 JK
                Fixed: disassembling output: cmpd
        2014-07-11 JK
                Fixed: undocumented tfr/exg register combinations.
                        http://www.6809.org.uk/dragon/illegal-opcodes.shtml

        2016-02-06 Henry Strickland <strickyak>
                Because OS/9 uses SWI2 for kernel calls, allow other SWIs for I/O.
                -i={0,1,2,3} Input char on {none, SWI, SWI2, or SWI3}.
                -o={0,1,2,3} Output char on {none, SWI, SWI2, or SWI3}
                -0  Initialize mem to 00.
                -F  Initialize mem to FF.
                -t  Enable trace.  (Still requires -DTRACE).
                And more.
*/

// 6809 Simulator "GOMAR".
package main

// License: GNU General Public License version 2, see LICENSE for more details.
// Code by  L.C. Benschop, the sbc09 team, Henry Strickland, et al.
// See bottom comment for more.

import (
	"github.com/strickyak/doing_os9/gomar/emu"

	"bufio"
	"flag"
	"log"
	"os"
	"strconv"
	"strings"
	"time"
)

var flagLevel = flag.Int("level", 1, "")
var flagTraceAfter = flag.Int64("t", 0, "")
var flagMaxSteps = flag.Int64("maxsteps", 0, "")
var flagBootImageFilename = flag.String("boot", "boot.mem", "")
var flagDiskImageFilename = flag.String("disk", "../_disk_", "")
var flagListings = flag.String("listings", "", "name:addr:listfile,...")
var flagStressTest = flag.String("stress", "", "If nonempty, string to repeat")
var flagListingsDir = flag.String("lists", "_lists", "")

func StdinToKeystrokes(keystrokes chan<- byte) {
	in := bufio.NewScanner(os.Stdin)
	for in.Scan() {
		for _, r := range in.Text() {
			keystrokes <- byte(r)
		}
		keystrokes <- '\r'
		// keystrokes <- 0
	}
	close(keystrokes)
}

func ProduceKeystrokes(keystrokes chan<- byte) {
	if *flagStressTest != "" {
		for {
			for _, r := range *flagStressTest {
				keystrokes <- byte(r)
			}
			keystrokes <- '\r'
			keystrokes <- 0
			time.Sleep(1 * time.Second)
		}
	} else {
		StdinToKeystrokes(keystrokes)
	}
}

func main() {
	log.SetFlags(0)
	flag.Parse()

	listings := make(map[string]string)
	relocations := make(map[string]emu.Word)
	for _, a := range strings.Split(*flagListings, ",") {
		b := strings.Split(a, ":")
		if len(b) == 3 {
			reloc, _ := strconv.ParseUint(b[1], 16, 16)
			relocations[b[0]] = emu.Word(reloc)
			listings[b[0]] = b[2]
		}
	}

	keystrokes := make(chan byte, 0)
	go ProduceKeystrokes(keystrokes)

	emu.Main(&emu.Config{
		DiskImageFilename: *flagDiskImageFilename,
		BootImageFilename: *flagBootImageFilename,
		Level:             *flagLevel,
		MaxSteps:          *flagMaxSteps,
		TraceAfter:        *flagTraceAfter,
		Keystrokes:        keystrokes,
		Listings:          listings,
		Relocations:       relocations,
		NewListingsDir:    *flagListingsDir,
	})
}
