package emu

import (
	"bufio"
	"os"
	"time"
)

func StdinToKeystrokes(keystrokes chan<- byte) {
	in := bufio.NewScanner(os.Stdin)
	for in.Scan() {
		for _, r := range in.Text() {
			keystrokes <- byte(r)
		}
		keystrokes <- '\r'
	}
	close(keystrokes)
}

func ProduceKeystrokes(keystrokes chan<- byte) {
	if *FlagStressTest != "" {
		for {
			for _, r := range *FlagStressTest {
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
