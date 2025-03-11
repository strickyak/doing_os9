#include "forth.h"

char origin[MAXDICT];

char *here;

void align()
{
    while ((cell)here & (sizeof(cell)-1)) {
	++here;
    }
}

void allot(cell nbytes)
{
    here += nbytes;
}

cell unused(void)
{
    return &origin[MAXDICT] - here;
}

void comma(cell n)
{
    *(cell *)here = n;
    here += sizeof(cell);
}

void compile(cell xt)
{
    comma(xt);
}
