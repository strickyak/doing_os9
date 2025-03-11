#include "forth.h"

#define SIMPLE 0

cell state = 0;

void handle_word(char *name_adr, cell name_len)
{
    cell immediate;
    cell found;
    cell xt;

    // Search for the name in the dictionary
    found = find(name_adr, name_len, &xt);
    if (found) {
	if (state && found < 0) {
	    // If state is true, we are compiling instead of interpreting
	    // If found<0, the word is NOT immediate, so we compile it normally
	    compile(xt);
	} else {
	    // If state is false, we always execute the word instead of compiling it
	    // If state is true and found>0, the word is immediate so it must
	    // be executed even in compile state.
	    perform((cell *) xt);
	}
    } else {
	// If the word is not found in the dictionary, it is either a
	// number or undefined
	cell num;
	if (is_number(name_adr, name_len, &num)) {
	    if (state) {
		// In complie state, we compile the number so that it will
		// be pushed on the stack later, when the definition that is
		// being compiled eventually executes.
		literal(num);
	    } else {
		// In interpret state, we just push the number on the stack now
		push(num);
	    }
	} else {
	    // The word is not recognized either as a prefefined word or as a
	    // number, it is an error
	    ctype("Not found: ");
	    type(name_adr, name_len);
	    cr();
	    to_in = num_source;  // Ignore the rest of the line
	}
    }
}
