package emu

import (
	"flag"
	"log"
)

// NEW WITH Compile tags
// `d` Device

// Verbosity:
//
//	'a' all lowercase letters
//	's' sys calls
//	'r' RAM dumps at sys calls
//	'd' I/O devices
//	'i' instructions
//	'm' memory get/put
//	'p' physical memory get/put
//	'w' wiznet
var V [128]bool                                                            // Verbosity bits
var FlagInitialVerbosity = flag.String("v", "", "Initial verbosity chars") // Initial Verbosity
var FlagTraceVerbosity = flag.String("vv", "", "Trace verbosity chars")    // Trace Verbosity
var FlagTraceAfter = flag.Uint64("t", MaxUint64, "Tracing starts after this many steps")

func SetVerbosityBits(s string) {
	for _, r := range s {
		if int(r) >= len(V) {
			log.Panicf("Verbosity rune %d too large for Verbosity Array", r)
		}
		if r == 'a' {
			for i := 'a'; i <= 'z'; i++ {
				V[i] = true
			}
			continue
		}
		V[r] = true
	}
}
