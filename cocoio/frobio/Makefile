GITTOP=../../../../..
TLINDLER_CMOC_OS9=$(GITTOP)/github.com/tlindner/cmoc_os9

all: frobio tftp

frobio: _FORCE_
	cmoc -i --os9 -I.. frobio.c w5100s.c
	sync

tftp: _FORCE_
	# cmoc -i --os9 -I.. -I../.. -I$(TLINDLER_CMOC_OS9)/include tftp.c w5100s.c ../../nylib/nylib.c $(TLINDLER_CMOC_OS9)/lib/libc.a
	cmoc -i --os9 -I.. -I../.. tftp.c w5100s.c ../../nylib/nylib.c ../../os9call/os9call.c
	sync
launch-tftp: tftp
	sh  ../../gomar/launch.sh  ./tftp  /dev/null

my: all
	os9 copy -r ./frobio /media/strick/APRIL3/MY.DSK,CMDS/frobio
	os9 attr -per /media/strick/APRIL3/MY.DSK,CMDS/frobio
	sync

_FORCE_:
	sync

clean:
	rm -f frobio tftp *.o *.s *.list *.lst *.map *.link

ci:
	mkdir -p RCS
	ci -l -m/dev/null -t/dev/null -q *.c *.h Makefile
