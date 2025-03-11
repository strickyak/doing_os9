// Searches the dictionary for a word whose name matches word_adr,word_len.
// Returns 0 if not found.
// Otherwise, sets *xt to the word's execution token and returns
// 1 if the word is immediate or 1 if it is not immediate.

cell find(char *name_adr, cell name_len, cell *xt);

void header(char *name_adr, cell name_len, void (*action_adr)(void));

void cheader(char *name, void (*action_adr)(void));

void immediate(void);

cell lastacf(void);
