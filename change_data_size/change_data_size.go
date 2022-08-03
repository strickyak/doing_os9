package main

import (
    "flag"
    "log"

    "github.com/strickyak/doing_os9/change_data_size/change"
)

var INCR = flag.Int("incr", 0, "increase data size by this much")
var MOD = flag.String("mod", "", "pathname to module to edit")

func main() {
    flag.Parse()

	if *MOD == "" {
		log.Fatalf("module pathname required in --mod flag")
	}

    change.ChangeDataSize(*INCR, *MOD)
}
