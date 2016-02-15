package main

import "bufio"
import . "fmt"
import "os"
import "regexp"
import "strings"

var MatchAddrAndBytes = regexp.MustCompile(`^([0-9A-F]{4}) ([0-9A-F]{2,8})`).FindStringSubmatch
var ReplaceWhite = regexp.MustCompile(`  +`).ReplaceAllString

func GrokLine(line string, tag string, d map[string]string) {
	m := MatchAddrAndBytes(line)
	if m != nil {
		k := tag + "," + m[1]
		k = strings.ToUpper(k)

		if len(line) > 56 {
			d[k] = line[56:]
		}
	}
}

func main() {
	d := make(map[string]string)
	for _, a := range os.Args[1:] {
		ww := strings.Split(a, ",")
		tag, fname := ww[0], ww[1]
		println(a)
		r, err := os.Open(fname)
		if err != nil {
			panic(fname)
		}
		sc := bufio.NewScanner(r)
		for sc.Scan() {
			line := sc.Text()
			GrokLine(line, tag, d)
		}

		r.Close()
	}

	r := os.Stdin
	sc := bufio.NewScanner(r)
	for sc.Scan() {
		line := sc.Text()
		tail := ""
		ww := strings.Split(line, " ")
		if len(ww) > 0 && len(ww[0]) > 0 {
			k := strings.ToUpper(ww[0])
			if v, ok := d[k]; ok {
				tail = ReplaceWhite(v, " ")
			}
		}
		Println(line + " ;; " + tail)
	}
}
