#include "forth.h"

cell base = 10;

cell check_digit(char c)
{
    cell digit;

    digit = c - '0';

    // Handle base values from 0 to 10, where the characters are '0'..'9'
    if (base <= 10) {
	if (digit >= 0 && digit < base) {
	    return digit;
	}
	return -1;
    }

    if (digit >= 0 && digit < 10) {
	// The base is greater than 10, but the character is in the
	// '0'..'9' range
	return digit;
    }
    
    // The base is greater than 10 so we have to deal with alphabetic
    // characters 'A'..'Z' or 'a'..'z'
    if (c >= 'a' && c <= 'z') {
	// Convert to upper case
	c = c - 'a' + 'A';
    }
    digit = c - 'A' + 10;
    if (digit >= 10 && digit < base) {
	return digit;
    }
    return -1;
}

// NUMBER converts a string to a number according to the current radix
cell is_number(char *adr, cell len, cell *num)
{
    cell accum = 0;
    cell digit;
    while(len--) {
	digit = check_digit(*adr++);
	if (digit == -1) {
	    return 0;
	}
	accum = accum*base + digit;
    }
    *num = accum;
    return 1;
}
