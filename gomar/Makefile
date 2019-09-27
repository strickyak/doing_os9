all:
	go run ../scrape_os9_symbols/scrape_os9_symbols.go "level1" < sym/level1_coco1.list | gofmt > sym/level1_defs.go
	go run ../scrape_os9_symbols/scrape_os9_symbols.go "level2" < sym/level2_coco3.list | gofmt > sym/level2_defs.go
