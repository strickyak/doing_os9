package cmocly

import (
	"log"
	"strconv"
)

func parseDec(s string) int {
	z, err := strconv.ParseInt(s, 10 /*decimal*/, 32 /*bit*/)
	if err != nil {
		log.Fatalf("bad decimal string %q: %v", s, err)
	}
	return int(z)
}

func parseHex(s string) int {
	z, err := strconv.ParseInt(s, 16 /*hexadecimal*/, 16 /*bit*/)
	if err != nil {
		log.Fatalf("bad hex string %q: %v", s, err)
	}
	return int(z)
}
