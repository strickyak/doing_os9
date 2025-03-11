// Facilities for character output

#include "forth.h"
#include "stdio.h"
#include "string.h"

// See output.h for explanations of these functions.

void emit(char c)
{
    fputc(c, stdout);
    // Flush to prevent the C stdio library from holding
    // characters until an end of line is sent.  This
    // makes it possible to see partial lines immediately,
    // which is useful for prompting and for progress
    // reports that stay entirely on one line.
    fflush(stdout);
}

void type(char *adr, u_cell len)
{
    while(len--) {
	emit(*adr++);
    }
}

void cr(void)
{
    emit('\n');
}

void ctype(char *str)
{
    type(str, strlen(str));
}

void prompt(void)
{
    ctype("\nok ");
}
