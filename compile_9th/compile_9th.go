package main

import "io"
import "io/ioutil"
import "fmt"
import "os"
import "strings"

var F = fmt.Sprintf
var P = fmt.Printf

type Ninth struct {
	Lines []string
	L     int

	Words []string
	W     int

	Latest string
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

func EncodeFunnyChars(s string) string {
	var bb []byte
	for _, ch := range s {
		if '0' <= ch && ch <= '9' ||
			'A' <= ch && ch <= 'Z' ||
			'a' <= ch && ch <= 'z' {
			bb = append(bb, byte(ch))
		} else {
			bb = append(bb, []byte(F("$%02x", ch))...)
		}
	}
	return string(bb)
}

func (o *Ninth) DoPrelude(name string, code string) {
	ename := EncodeFunnyChars(name)
	ecode := EncodeFunnyChars(code)
	elatest := EncodeFunnyChars(o.Latest)
	P("\n\n***  %s  ***\n\n", name)
	P("l_%s\n", ename)
	if o.Latest == "" {
		P("  fcb 0,0 ;link")
	} else {
		P("  fcb ($10000+%s-*)/256 ;link\n", elatest)
		P("  fcb ($10000+%s-*)+1\n", elatest)
	}
	P("  fcb %d  ;len\n", len(name))
	P("  fcc ~%s~\n", name)
	P("  fcb 0\n")

	P("c_%s\n", ename)
	P("  fcb ($10000+%s-*)/256 ;link\n", ecode)
	P("  fcb ($10000+%s-*)+1\n", ecode)
	P("b_%s\n", ename)

	o.Latest = name
}

func (o *Ninth) InsertCode() {
	for {
		s := o.NextLine()
		if strings.Trim(s, " \t") == ";" {
			break
		}
		P("%s\n", s)
	}
	P("  jmp Next,pcr\n")
}

func (o *Ninth) DoCode() {
	name := o.NextWord()
	o.DoPrelude(name, "c_"+name)
	o.InsertCode()
}
func (o *Ninth) DoColon() {
	name := o.NextWord()
	o.DoPrelude(name, "Enter")
}

func CompileFile(w io.Writer, r io.Reader) {
	o := NewNinth(r)
	for {
		w := o.NextWord()
		if w == ">EOF<" {
			break
		}
		switch w {
		case ":":
			o.DoColon()
		case "code":
			o.DoCode()
		default:
			panic(F("Unknown Command: %q", w))
		}
	}
}

func main() {
	CompileFile(os.Stdout, os.Stdin)
}
