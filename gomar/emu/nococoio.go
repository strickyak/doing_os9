//go:build !cocoio

package emu

func PutCocoIO(a Word, b byte) {}
func GetCocoIO(a Word) byte {return 126}
