// +build !canvas

package emu

import (
	"bufio"
	"flag"
	"log"
	"os"
)

var flagN = flag.Bool("n", false, "Disable reading keystrokes from stdin")

func InputRoutine(keystrokes chan<- byte) {
	if *flagN {
		return
	}
	in := bufio.NewScanner(os.Stdin)
	for in.Scan() {
		for _, r := range in.Text() {
			keystrokes <- byte(r)
		}
		keystrokes <- '\r'
	}
	close(keystrokes)
	log.Fatal("Stdin ended")
}

func PublishVideoText() {}
