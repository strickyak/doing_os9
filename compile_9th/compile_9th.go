package main

import "io"
import "io/ioutil"
import "fmt"
import "os"
import "strings"

var F = fmt.Sprintf

type Ninth struct {
	Lines []string
	L     int

	Words []string
	W     int
}

func (o *Ninth) NextWord() string {
	for o.W >= len(o.Words) {
		t := o.NextLine()
		if t == ">EOF<" {
			return t
		}
		o.Words = []string{}
		for _, w := range strings.Split(t, " ") {
			if w != "" {
				o.Words = append(o.Words, w)
			}
		}
		o.W = 0
	}
	z := o.Words[o.W]
	o.W++
	return z
}

func (o *Ninth) NextLine() string {
	o.Words = nil
	o.W = 0
	if o.L >= len(o.Lines) {
		return ">EOF<"
	}
	z := o.Lines[o.L]
	o.L++
	return strings.Replace(z, "\t", "        ", -1)
}

func NewNinth(r io.Reader) *Ninth {
	all, err := ioutil.ReadAll(r)
	if err != nil {
		panic("can't ioutil.ReadAll")
	}
	lines := strings.Split(string(all), "\n")
	return &Ninth{Lines: lines}
}

func CompileFile(w io.Writer, r io.Reader) {
	o := NewNinth(r)
	for {
		w := o.NextWord()
		if w == ">EOF<" {
			break
		}
		println("===", w, "===")
		switch w {
		case ":":
			DoColon(o)
		case "code":
			DoCode(o)
		default:
			panic(F("Unknown Command: %q", w))
		}
	}
}

func main() {
	CompileFile(os.Stdout, os.Stdin)
}
