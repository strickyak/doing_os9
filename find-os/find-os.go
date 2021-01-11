// +build main

package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
)

var buf [256]byte

func main() {
	r := bufio.NewReader(os.Stdin)
	sector := 0
	for {
		count, err := r.Read(buf[:])
		if err != nil && err != io.EOF {
			break
		}
		if count != 256 {
			break
		}
		if string(buf[0:2]) == "OS" {
			fmt.Printf("%d : %q\n", sector, buf[0:32])
		}
		if err == io.EOF {
			break
		}
		sector++
	}
}
