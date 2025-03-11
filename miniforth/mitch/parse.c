#include "forth.h"

#include <ctype.h>

cell parse_word(char **adr)
{
    cell len = 0;
    while(to_in < num_source && isspace(source_adr[to_in])) {
	++to_in;
    }
    *adr = &source_adr[to_in];

    while(to_in < num_source && !isspace(source_adr[to_in])) {
	++len;
	++to_in;
    }
    return len;
}

cell safe_parse_word(char **adr)
{
    cell len = parse_word(adr);
    if (len == 0) {
	ctype("End of line while parsing word\n");
    }
    return len;
}
