DISK=$$HOME/go/src/github.com/strickyak/doing_os9/drive/disk2
CMOC=cmoc

all:
	$(CMOC) --os9 -S ncl.c
	python  wrap.py  < ncl.s > ncl.asm
	lwasm -f"os9" --pragma=forwardrefmax --output=ncl.bin --list="ncl.list" --map="ncl.map" ncl.asm
	:
	grep '^//-' ncl.c | sed 's;^//-;;' | LC_ALL=C sort  > commands.txt
	:
	cp ncl.list ../borges/ncl.mod
	os9 copy -r ncl.bin $(DISK),cmds/ncl
	os9 attr -e -r -w -pe -pr $(DISK),cmds/ncl
	os9 copy -r nclrc.tcl $(DISK),sys/nclrc.tcl
	:
	: OKAY

indent:
	indent -kr -nut -i2 -l100 *.c

clean:
	rm -f *.s *.asm *.list *.map *.bin *.c~
ci:
	ci-l Makefile *.[ch] *.py *.tcl
