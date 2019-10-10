// +build canvas

package emu

import (
	api "github.com/tfriedel6/canvas/examples/events"

	"bytes"
	"log"
)

const MonBegin = 0x07c000
const MonWidth = 80
const MonHeight = 25

var monitor *api.Monitor

func InputRoutine(keystrokes chan<- byte) {
	monitor = api.NewMonitor(MonWidth, MonHeight, keystrokes)
	monitor.Loop()
	close(keystrokes)
	log.Fatal("Monitor loop ended")
}

func DoubleByteAsciiScreen(a []byte, wid, hei int) {
}

func PublishVideoText() {
	for j := 0; j < MonHeight; j++ {
		var buf bytes.Buffer
		for i := 0; i < MonWidth; i++ {
			buf.WriteByte(mem[MonBegin+2*(j*MonWidth+i)])
		}
		monitor.Rows[j] = buf.Bytes()
	}
}
