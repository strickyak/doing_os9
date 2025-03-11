all: miniforth

OBJS = platform.o

OBJS += main.o
OBJS += input.o
OBJS += output.o
OBJS += parse.o
OBJS += find.o
OBJS += dictionary.o
OBJS += number.o
# OBJS += handle_interpret.o
OBJS += handle_compile.o
OBJS += stack.o
OBJS += initdict.o
OBJS += walk.o

CC = gcc6809
CFLAGS = -std=gnu99 -Os

miniforth: $(OBJS)
	PATH="$$HOME/coco-shelf/bin:$$PATH" lwlink --format=decb $(OBJS) -o'$@' -L"$$HOME/coco-shelf/lib/gcc/m6809-unknown/4.6.4/" -lgcc --map='$@.map'

.c.o:
	PATH="$$HOME/coco-shelf/bin:$$PATH" $(CC) $(CFLAGS) -c $<

clean:
	-rm -f $(OBJS) ctags miniforth* *.list *.map _* ,*
