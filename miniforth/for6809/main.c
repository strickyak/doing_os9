#include "forth.h"

int main(int argc, char **argv)
{
    init_dictionary();
    rclear();
    clear();
    set_input(tib, TIBSIZE, TIB_ID);

    while(refill()) {
	char *word_adr;
	cell word_len;

	while ((word_len = parse_word(&word_adr)) != 0) {
	    handle_word(word_adr, word_len);
	}
    }
}
