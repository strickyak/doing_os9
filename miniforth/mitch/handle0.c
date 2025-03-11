#include "forth.h"

void handle_word(char *word_adr, cell word_len)
{
    type(word_adr, word_len);
    cr();
}
