all:
	go run ../scrape_os9_symbols/scrape_os9_symbols.go --listing sym/level1_coco1.list --errmsg sym/errmsg.txt "level1" | gofmt > sym/level1_defs.go
	go run ../scrape_os9_symbols/scrape_os9_symbols.go --listing sym/level2_coco3.list --errmsg sym/errmsg.txt "level2" | gofmt > sym/level2_defs.go
