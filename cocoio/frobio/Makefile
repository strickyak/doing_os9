all: _FORCE_
	cmoc -i --os9 -I.. frobio.c w5100s.c
	sync

my: all
	os9 copy -r ./frobio /media/strick/APRIL3/MY.DSK,CMDS/frobio
	os9 attr -per /media/strick/APRIL3/MY.DSK,CMDS/frobio
	sync

_FORCE_:
	sync

clean:
	rm -f frobio *.o *.s *.list *.lst *.map *.link

ci:
	mkdir -p RCS
	ci -l -m/dev/null -t/dev/null -q *.c *.h Makefile
