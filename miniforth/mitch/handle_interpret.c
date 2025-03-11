#include "forth.h"

void perform(cell *xt)
{
    ((void (*)(void))(*(cell *)xt))();
}

void handle_word(char *word_adr, cell word_len)
{
    cell immediate;
    cell found;
    cell xt;
    found = find(word_adr, word_len, &xt);
    if (found) {
	perform(xt);
    } else {
	cell num;
	if (is_number(word_adr, word_len, &num)) {
	    push(num);
	} else {
	    type("Not found: ", 11);
	    type(word_adr, word_len);
	    cr();
	    to_in = num_source;  // Ignore the rest of the line
	}
    }
}
