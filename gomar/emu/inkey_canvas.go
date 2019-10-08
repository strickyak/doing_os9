// +build canvas

package emu

import (
	api "github.com/tfriedel6/canvas/examples/events"

	"log"
)

func InputRoutine(keystrokes chan<- byte) {
	mon := api.NewMonitor(40, 24, keystrokes)
	mon.Loop()
	close(keystrokes)
	log.Fatal("Monitor loop ended")
}
