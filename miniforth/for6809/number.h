// BASE is the radix for numeric input and output
extern cell base;

// IS_NUMBER determines whether or not that string at (adr,len)
// can be converted to a number using the current radix (BASE).
// If so, that number is stored at *num and 1 is returned.
// Otherwise, 0 is returned.
cell is_number(char *adr, cell len, cell *num);
