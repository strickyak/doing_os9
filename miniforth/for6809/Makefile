all: miniforth_unopt miniforth

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
CFLAGS = -std=gnu99

miniforth_unopt: $(OBJS)
	PATH="$$HOME/coco-shelf/bin:$$PATH" lwlink --format=decb $(OBJS) -o'$@' -L"$$HOME/coco-shelf/lib/gcc/m6809-unknown/4.6.4/" -lgcc --map='$@.map'

miniforth: $(OBJS)
	cat *.c > _big.c
	PATH="$$HOME/coco-shelf/bin:$$PATH" gcc6809 -std=gnu99 -Os -c -f'omit-frame-pointer' -f'whole-program' _big.c
	PATH="$$HOME/coco-shelf/bin:$$PATH" lwlink --format=decb _big.o -o'miniforth' -L"$$HOME/coco-shelf/lib/gcc/m6809-unknown/4.6.4/" -lgcc --map='miniforth.map'

.c.o:
	PATH="$$HOME/coco-shelf/bin:$$PATH" $(CC) $(CFLAGS) -c $<

clean:
	-rm -f $(OBJS) ctags miniforth* *.list *.map _* ,*
