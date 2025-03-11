#include <stdio.h>

#include "forth.h"

// The following functions and variables are explained in input.h

u_cell accept(char *adr, cell len)
{
    u_cell cnt = 0;
    int c;
    while (len--) {
	c = fgetc(stdin);
	switch (c)
	{
	case EOF:
	case '\n':
	    return cnt;
	case '\r':
	    break;
	default:
	    adr[cnt++] = (char)c;
	}
    }
    return cnt;
}

char *source_adr;
cell source_len;
cell num_source;
cell source_id;
u_cell to_in;

void set_input(char *buffer, u_cell buflen, u_cell id)
{
    source_id = id;
    source_adr = buffer;
    source_len = buflen;
    num_source = 0;
    to_in = 0;
}

char tib[TIBSIZE];

cell refill()
{
    // This simplified implementation reads input only from stdin.
    // A more complete implementation would use source_id to
    // select the input data source.
    prompt();
    num_source = accept(source_adr, source_len);
    to_in = 0;
    if (num_source == 0) {
	return !feof(stdin);
    }
    return 1;
}
