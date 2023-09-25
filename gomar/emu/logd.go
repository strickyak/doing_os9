//go:build d || a

package emu

import (
	"log"
)

const BUILD_TAG_d = true

func Ld(format string, args ...interface{}) {
	log.Printf("#d "+format, args...)
}
