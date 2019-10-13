// +build !canvas

package emu

import (
	"bufio"
	log "log"
	"os"
)

func InputRoutine(keystrokes chan<- byte) {
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
