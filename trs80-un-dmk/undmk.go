// This is just enough code to make a crude rip of Tiny Pascal source.
// It still takes hand-editing the "big.txt" output file.
// Really this needs to understand the directory track and the floppy sector marks better.
// The input was named "M1_Tiny_PASCAL.dmk".
// The output, via "big.txt", after some editing, is "tiny-pascal-compiler-source-trs80-3-02-79.txt".
package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"strings"
)

var F = fmt.Fprintf
var L = log.Printf
var P = log.Panicf

var in *bufio.Reader
var buf = make([]byte, 2)
var head = make([]byte, 16)
var thead = make([]uint, 128)
var idam = make([]uint, 128)

func hilo(a, b byte) uint {
	return (uint(a) << 8) | uint(b)
}

func read(r io.Reader, buf []byte) {
	n, err := io.ReadFull(r, buf)
	if err != nil {
		P("read err: %v", err)
	}
	if n != len(buf) {
		P("read short: %d", n)
	}
}

func main() {
	in = bufio.NewReader(os.Stdin)
	read(in, head)
	L("write_protect=%x", head[0])
	num_tracks := head[1]
	L("num_tracks=%x", num_tracks)
	track_len := hilo(head[3], head[2])
	L("track_len=%x", track_len)
	flags := head[4]
	L("flags=%x", flags)
	L("reserved=%x", head[5:12])
	L("real_disk=%x", head[12:16])
	if flags != 0x10 {
		P("unsupported flags: %x", flags)
	}

	var big bytes.Buffer

	for track := byte(0); track < num_tracks; track++ {
		L("track # %d", track)
		tbuf := make([]byte, track_len)
		read(in, tbuf)

		for i := 0; i < 64; i++ {
			thead[i] = hilo(tbuf[i+i+1], tbuf[i+i])
		}
		L("thead: %v", thead)

		for sec := 0; sec < 64; sec++ {
			if thead[sec] == 0 {
				continue
			}
			j := 50 + thead[sec]
			// L("sector[%d] = %x", sec, tbuf[j : j+256])
			L("track[%d.] sector[%d.]", track, sec)
			var z strings.Builder
			for k := uint(0); k < 256; k++ {
				if (k & 31) == 0 {
					F(&z, "\n[%03x]", k)
				}
				if (k & 3) == 0 {
					F(&z, " ")
				}
				ch := tbuf[j+2*k]
				if ch != tbuf[j+2*k+1] {
					P("not duped %x %x at j=%x k=%x", ch, tbuf[j+2*k+1], j, k)
				}
				if ' ' <= ch && ch <= '~' {
					F(&z, "  %c", ch)
				} else {
					F(&z, " %02x", tbuf[j+k+k])
				}
			}
			L("%s", z.String())
		}

		if track < 2 || track == 17 {
			continue
		}

		for skip := 0; skip < 2; skip++ {
			for sec := skip; sec < 10; sec += 2 {
				if thead[sec] == 0 {
					continue
				}
				j := 50 + thead[sec]
				for k := uint(0); k < 256; k++ {
					ch := tbuf[j+2*k]
					if ' ' <= ch && ch <= 95 || ch == 9 || ch == 10 {
						big.WriteByte(ch)
					} else if ch == 13 {
						big.WriteByte('\n')
					} else {
						big.WriteByte('@')
						if k == 255 {
							big.WriteByte('\n')
						}
					}
				}
			}

		}
	} // next track

	ioutil.WriteFile("big.txt", big.Bytes(), 0644)
}
