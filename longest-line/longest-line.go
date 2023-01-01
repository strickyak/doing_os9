/*
ff /tmp/unix/ | xargs  go run filetype/filetype.go | tee /tmp/ft | while read typ fil junk ; do case $typ in txt ) /home/strick/go/bin/longest-line $fil ;; esac ; done | sort -n
*/
package main

import (
	"bufio"
	"bytes"
	"flag"
	"fmt"
	"os"
)

const N = 99999

func longestLine(filename string) {
	r, err := os.Open(filename)
	if err != nil {
		panic(err)
	}
	r2 := bufio.NewReader(r)
	var tmp []byte
	for {
		b, err := r2.ReadByte()
		if err != nil {
			break
		}
		if b == 13 {
			tmp = append(tmp, 10)
		} else {
			tmp = append(tmp, b)
		}
	}
	r3 := bytes.NewReader(tmp)

	sc := bufio.NewScanner(r3)
	sc.Buffer(make([]byte, N), N)
	max := 0
	for sc.Scan() {
		t := sc.Text()
		if len(t) > max {
			max = len(t)
		}
	}
	fmt.Printf("%7d %s\n", max, filename)
}

func main() {
	flag.Parse()
	for _, a := range flag.Args() {
		longestLine(a)
	}
}
