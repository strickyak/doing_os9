DISK=$$HOME/go/src/github.com/strickyak/doing_os9/disk2
CMOC=/opt/yak/cmoc

all:
	$(CMOC)/bin/cmoc --os9 -S ncl.c
	python  wrap_ncl.py  < ncl.s > ncl.asm 
	: lwasm -f"os9" --pragma=forwardrefmax -D"OS9" --output=ncl.bin --list="ncl.list" --map="ncl.map" ncl.asm
	lwasm -f"os9" --pragma=forwardrefmax --output=ncl.bin --list="ncl.list" --map="ncl.map" ncl.asm
	:
	cp ncl.list ../borges/ncl.mod
	os9 copy -r ncl.bin $(DISK),cmds/ncl
	os9 attr -e -r -w -pe -pr $(DISK),cmds/ncl
	:
	: OKAY

indent:
	indent -kr -nut -i2 -l100 *.c

clean:
	rm -f *.s *.asm *.list *.map *.bin *.c~
ci:
	ci-l Makefile *.[ch] *.py
