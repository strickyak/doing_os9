//go:build d || a

package emu

import (
	"log"
)

func Ld(format string, args ...interface{}) {
	log.Printf("#d "+format, args...)
}
