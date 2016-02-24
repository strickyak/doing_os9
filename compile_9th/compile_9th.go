package main

import "io"
import "io/ioutil"
import "fmt"
import "os"
import "strconv"
import "strings"

var F = fmt.Sprintf
var P = fmt.Printf

type Ninth struct {
	Lines []string
	L     int

	Words []string
	W     int

	Latest string
	Here   int
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
			'a' <= ch && ch <= 'z' ||
			ch == '_' {
			bb = append(bb, byte(ch))
		} else {
			bb = append(bb, []byte(F("_%02x", ch))...)
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
		P("  fcb ($10000+l_%s-*)/256 ;link\n", elatest)
		P("  fcb ($10000+l_%s-*)+1\n", elatest)
	}
	P("  fcb %d  ;len\n", len(name))
	P("  fcc ~%s~\n", name)
	P("  fcb 0\n")

	P("c_%s\n", ename)
	P("  fcb ($10000+%s-*)/256 ;codeword\n", ecode)
	P("  fcb ($10000+%s-*)+1\n", ecode)
	P("d_%s\n", ename)

	o.Latest = name
}

func (o *Ninth) InsertAllot(offset int) {
	P("  tfr dp,a\n")
	P("  clrb\n")
	P("  addd #%d\n", offset)
	P("  pshU d\n")
	P("  jmp Next,pcr\n")
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

func (o *Ninth) InsertColon() {
	for {
		s := o.NextWord()
		P("  ******  %s\n", s)

    // Stop at the ";"
		if s == ";" {
			break
		}

    // Special handling for decimal integers.
		n, err := strconv.ParseInt(s, 10, 64)
		if err == nil {
      // Compile: lit
			P("  fcb ($10000+c_lit-*)/256 ;; %s ;;\n", s)
			P("  fcb ($10000+c_lit-*)+1\n")
      // Compile: the integer.
			P("  fcb ($10000+(%d))/256\n", n)
			P("  fcb (%d)\n", n)
			continue
		}

    // Special handling for "$" and hex integers.
		if s[0] == '$' {
      // Compile: lit
			P("  fcb ($10000+c_lit-*)/256 ;; %s ;;\n", s)
			P("  fcb ($10000+c_lit-*)+1\n")
			x, err := strconv.ParseInt(s[1:], 16, 64)
			if err != nil {
				panic(s)
			}
      // Compile: the integer.
			P("  fcb ($10000+(%d))/256\n", x)
			P("  fcb (%d)\n", x)
			continue
		}

    // Normal non-immediate words.
		es := EncodeFunnyChars(s)
		P("  fcb ($10000+c_%s-*)/256 ;; %s ;;\n", es, s)
		P("  fcb ($10000+c_%s-*)+1\n", es)
	}
	P("  fcb ($10000+c_exit-*)/256 ;; exit ;;\n")
	P("  fcb ($10000+c_exit-*)+1\n")
}

func (o *Ninth) DoCode() {
	name := o.NextWord()
	o.DoPrelude(name, "d_"+name)
	o.InsertCode()
}
func (o *Ninth) DoColon() {
	name := o.NextWord()
	o.DoPrelude(name, "Enter")
	o.InsertColon()
}
func (o *Ninth) DoAllot(n int) {
	name := o.NextWord()
	offset := o.Here
	o.Here += n
	o.DoPrelude(name, "d_"+name)
	o.InsertAllot(offset)
}
func (o *Ninth) DoInit() {
	// Save our dynamic o.Here into the "here" variable in RAM.
	P("  tfr dp,a\n")
	P("  clrb\n")
	P("  addd #%d\n", o.Here)
	P("  std <%d\n", o.Here)
	// Return
	P("  rts\n")
}

func CompileFile(w io.Writer, r io.Reader) {
	var hold int
	o := NewNinth(r)
	for {
		w := o.NextWord()
		if w == ">EOF<" {
			break
		}
		n, err := strconv.ParseInt(w, 10, 64)
		if err == nil {
			hold = int(n)
			continue
		}
		switch w {
		case "\\":
			o.Words = nil
		case ":":
			o.DoColon()
		case "code":
			o.DoCode()
		case "allot":
			o.DoAllot(hold)
		default:
			panic(F("Unknown Command: %q", w))
		}
	}
	o.DoInit()
}

func main() {
	CompileFile(os.Stdout, os.Stdin)
}
