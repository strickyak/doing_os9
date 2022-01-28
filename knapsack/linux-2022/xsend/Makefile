CFLAGS=-I. -I../mp -g

all: lib.o enroll xsend xget

enroll:
	$(CC) -o enroll $(CFLAGS) enroll.c lib.o -lcrypt -L../mp -lmp
xsend:
	$(CC) -o xsend $(CFLAGS) xsend.c lib.o -lcrypt -L../mp -lmp
xget:
	$(CC) -o xget $(CFLAGS) xget.c lib.o -lcrypt -L../mp -lmp

clean:
	rm -f *.o *.a enroll xsend xget
