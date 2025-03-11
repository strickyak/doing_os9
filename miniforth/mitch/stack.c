#include "forth.h"

cell stack[MAXSTACK+5];  // The +5 gives us a guard band
cell *sp;

cell pop(void)
{
    return *sp++;
}

void push(cell n)
{
    *--sp = n;
}

void clear(void)
{
    sp = &stack[MAXSTACK];
}

void depth(void)
{
    push(&stack[MAXSTACK] - sp);
}

void dup(void)
{
    push(*sp);
}

cell return_stack[MAXSTACK+5];  // The +5 gives us a guard band
cell *rp;


cell rpop(void)
{
    return *rp++;
}

void rpush(cell n)
{
   *--rp = n;
}

void rclear(void)
{
    rp = &return_stack[MAXSTACK];
}
