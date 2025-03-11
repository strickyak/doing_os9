// EMIT sends a character to the console output device
void emit(char c);

// TYPE outputs a string of characters, defined by the starting
// address and length, via EMIT
void type(char *adr, u_cell len);

// CR outputs an end-of-line sequence
void cr(void);

// PROMPT issues a prompt telling the user that Forth is ready
// for a command.
void prompt(void);

// CTYPE is a convenience function to output a C string
void ctype(char *str);
