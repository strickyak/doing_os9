#include <inttypes.h>

#include "forth.h"
#include "stdio.h"
#include "stdlib.h"

static void plus(void)
{
    push(pop() + pop());
}

static void minus(void)
{
    cell n = pop();
    push(pop() - n);
}

static void times(void)
{
    push(pop() * pop());
}

static void divide(void)
{
    cell n = pop();
    push(pop() / n);
}

static void print(void)
{
    cell n = pop();
    printf(base == 10 ? "%"PRIdPTR" " : "%"PRIxPTR" ", n);
}

static void drop(void)
{
    (void)pop();
}

static void bye(void)
{
    exit(0);
}

static void unnest()
{
    ip = (cell *)rpop();
}

static cell unnester;

static void semicolon(void)
{
    compile(unnester);
    state = 0;
}


static void docolon(void)
{
    rpush((cell)ip);
    ip = w+1;
}

static void colon(void)
{
    char *p;
    cell len;
    if ((len = safe_parse_word(&p)) == 0) {
	return;
    }
    header(p, len, docolon);
    state = 1;
}


static void doconstant(void)
{
    push(*(w+1));
}

static void constant(void)
{
    char *p;
    cell len;
    if ((len = safe_parse_word(&p)) == 0) {
	return;
    }
    header(p, len, doconstant);
    comma(pop());
}

static void dovariable(void)
{
    push((cell)(w+1));
}

static void variable(void)
{
    char *p;
    cell len;
    if ((len = safe_parse_word(&p)) == 0) {
	return;
    }
    header(p, len, dovariable);
    comma(0);
}


static void doliteral(void)
{
    push(*ip++);
}

static cell dolit;

void literal(cell n)
{
    compile(dolit);
    compile(n);
}


static void fetch(void)
{
    cell *adr = (cell *)pop();
    push(*adr);
}

static void store(void)
{
    cell *adr = (cell *)pop();
    *adr = pop();
}

void init_dictionary(void)
{
    here = origin;

    cheader("exit", unnest);
    unnester = lastacf();
    cheader(";", semicolon); immediate();

    cheader(":", colon);
    cheader("variable", variable);
    cheader("constant", constant);

    cheader("(literal)", doliteral);
    dolit = lastacf();

    cheader("+", plus);
    cheader("-", minus);
    cheader("*", times);
    cheader("/", divide);
    cheader(".", print);

    cheader("drop", drop);
    cheader("dup", dup);
    cheader("depth", depth);

    cheader("@", fetch);
    cheader("!", store);

    cheader("bye", bye);
}
