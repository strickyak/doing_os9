package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
)

var Log = log.Printf
var ExitStatus int

func main() {
	flag.Parse()

	for _, a := range flag.Args() {
		fmt.Printf("%s\n", WhatType(a))
	}

	os.Exit(ExitStatus)
}

func WhatType(filename string) string {
	t := "err"
	crs, lfs, tabs, printables, others := 0, 0, 0, 0, 0
	var martians []byte

	bb, err := ioutil.ReadFile(filename)
	if err != nil {
		ExitStatus = 255
	} else if len(bb) == 0 {
		t = "empty"
	} else {
		t = "txt"
		for _, b := range bb {
			switch b {
			case 10:
				lfs++
			case 13:
				crs++
			case 9, 12: // both TAB and FORM FEED
				tabs++
			default:
				if 32 <= b && b <= 126 {
					printables++
				} else {
					others++
					martians = append(martians, b)
					t = "bin"
				}
			}
		}
		ratio := float64(others) / float64(len(bb))
		if len(bb) > 100 && 0.0 < ratio && ratio < 0.01 {
			Log("File %q ratio %f", filename, ratio)
			for _, b := range martians {
				Log("Martian $%x == %d.", b, b)
			}
		}
	}
	return fmt.Sprintf("%-5s %s %d %d %d %d %d", t, filename, lfs, crs, tabs, printables, others)
}
