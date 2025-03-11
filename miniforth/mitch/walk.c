#include "forth.h"

cell *ip;
cell *w;

// This is tricky.  In order to execute a Forth word from C, we
// have to make a small threaded code sequence that contains
// a reference to the Forth word, and then we need some way to
// return from the tree walker when it is done.  DO_FINISH
// forces the return by setting FINISHED to true.

static cell finished;

static void do_finish(void)
{
    finished = 1;
}

// FINISHER is a "headerless" Forth word - a bare code field
// without a name or link
static code_field_t finisher = do_finish;

// EXECUTER is the top level of a threaded code tree.
// In its first slot, we inject the execution token
// of the Forth word to be executed.  When that word exits,
// the second slot invokes FINISHER.
static cell executer[2] = { 0, (cell)&finisher };

static void execute(cell *xt)
{
    w = xt;
    ((code_field_t)(*w))();
}

static void walk(cell *new_ip)
{
    ip = new_ip;
    finished = 0;
    do {
	w = (cell *)*ip++;
	((code_field_t)(*w))();
    } while (!finished);
}

void perform(cell *xt)
{
    executer[0] = (cell)xt;
    walk(executer);
}
