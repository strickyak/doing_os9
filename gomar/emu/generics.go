package emu

import (
	"fmt"
	"log"
	"strings"
)

type NUMBER interface {
	byte | Word | int | int64 | float64
}

func Str(a any) string {
	return fmt.Sprintf("%v", a)
}

func StrEach(vec []any) string {
	var b strings.Builder
	b.WriteString("[ ")
	for _, e := range vec {
		b.WriteString(Str(e))
		b.WriteString(", ")
	}
	b.WriteString("]")
	return b.String()
}

func Repr(a any) string {
	return fmt.Sprintf("%#v", a)
}

func GiveInfo(extra ...any) string {
	if len(info) == 0 {
		return ""
	}
	return fmt.Sprintf(" info: %s", StrEach(extra))
}

func AssertEQ[N NUMBER](a, b N, extra ...any) {
	if !(a == b) {
		log.Fatalf("FAILED Assertion (%s) == (%s) %s", Str(a), Str(b), GiveInfo)
	}
}

func AssertNE[N NUMBER](a, b N, extra ...any) {
	if !(a != b) {
		log.Fatalf("FAILED Assertion (%s) != (%s) %s", Str(a), Str(b), GiveInfo)
	}
}

func AssertLE[N NUMBER](a, b N, extra ...any) {
	if !(a <= b) {
		log.Fatalf("FAILED Assertion (%s) <= (%s) %s", Str(a), Str(b), GiveInfo)
	}
}

func AssertLT[N NUMBER](a, b N, extra ...any) {
	if !(a < b) {
		log.Fatalf("FAILED Assertion (%s) < (%s) %s", Str(a), Str(b), GiveInfo)
	}
}

func AssertGE[N NUMBER](a, b N, extra ...any) {
	if !(a >= b) {
		log.Fatalf("FAILED Assertion (%s) >= (%s) %s", Str(a), Str(b), GiveInfo)
	}
}

func AssertGT[N NUMBER](a, b N, extra ...any) {
	if !(a > b) {
		log.Fatalf("FAILED Assertion (%s) > (%s) %s", Str(a), Str(b), GiveInfo)
	}
}
