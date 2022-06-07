all: os9call.o

os9call.o: os9call.c
	cmoc -I.. -i -S --os9 os9call.c
	cmoc -I.. -i -c --os9 os9call.c

clean:
	rm -f *.s *.raw.a
