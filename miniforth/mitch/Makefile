all: miniforth

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

CFLAGS += -g

miniforth: $(OBJS)
	$(CC) $(LDFLAGS) $(OBJS) -o $@

.c.o:
	$(CC) $(CFLAGS) -c $<

clean:
	-rm -f $(OBJS) ctags miniforth*
