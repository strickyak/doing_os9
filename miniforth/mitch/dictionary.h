#define MAXDICT 0x10000

// ORIGIN is the starting address of the dictionary
extern char origin[];

// HERE is the address of the first unused byte in the dictionary
extern char *here;

// ALIGN aligns HERE to a cell boundary
void align(void);

// ALLOT allocates nbytes within the dictionary
void allot(cell nbytes);

// UNUSED returns the number of unused bytes available in the dictionary
cell unused(void);

// COMMA adds a number to the dictionary
void comma(cell n);

// COMPILE adds an execution token to the dictionary
void compile(cell xt);
