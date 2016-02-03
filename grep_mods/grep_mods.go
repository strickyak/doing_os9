package main

import (
	"fmt"
	"io"
	"os"
)

const BIG = 100000000

// TryToDetectModule looks for a module beginning at the
// start of b.  It checks the header parity, but not the
// entire module CRC.
func TryToDetectModule(b []byte, offset int) {
	if b[0] == 0x87 && b[1] == 0xCD {
		x := 0
		for i := 0; i < 9; i++ {
			x ^= int(b[i])
		}
		if x == 0xff {
			fmt.Printf("Name: <")
			k := (int(b[4]) << 8) | int(b[5])
			for {
				fmt.Printf("%c", b[k]&127)
				if b[k]&128 == 128 {
					break
				}
				k++
			}
			k = (int(b[2]) << 8) | int(b[3])
			fmt.Printf("> at offset 0x%x == %d.\n", offset, offset)
			fmt.Printf("Size: 0x%x == %d.\n", k, k)
			fmt.Printf("Type: %d.\n", 15&(b[6]>>4))
			fmt.Printf("Lang: %d.\n", 15&(b[6]>>0))
			fmt.Printf("Attr: %d.\n", 15&(b[7]>>4))
			fmt.Printf("Revn: %d.\n", 15&(b[7]>>0))
			fmt.Printf("\n")
		}
	}
}

func main() {
	b := make([]byte, BIG, BIG)
	n, _ := io.ReadFull(os.Stdin, b)
	//if err != nil { panic(err) }
	b = b[:n]
	for i := 0; i < n-10; i++ {
		TryToDetectModule(b[i:], i)
	}
}
