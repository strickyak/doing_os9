all: _FORCE_
	cmoc -i --os9 -I.. frobio.c w5100s.c

_FORCE_:
	:

clean:
	rm -f frobio *.o *.s *.list *.lst *.map *.link

ci:
	mkdir -p RCS
	ci -l -m/dev/null -t/dev/null -q *.c *.h Makefile
