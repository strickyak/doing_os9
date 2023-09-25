//go:build !d && !a

package emu

const BUILD_TAG_d = false

func Ld(format string, args ...interface{}) {
}
