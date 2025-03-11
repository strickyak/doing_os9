#define MAXSTACK 100

// POP removes an element from the top of the stack
cell pop(void);

// PUSH adds an element to the top of the stack
void push(cell n);

// CLEAR clears the stack
void clear(void);

// DEPTH returns the number of items on the stack
void depth(void);

// DUP pushes a copy of the top of the stack
void dup(void);

// RPOP removes an element from the top of the return stack
cell rpop(void);

// RPUSH adds an element to the top of the return stack
void rpush(cell n);

// RCLEAR clears the return stack
void rclear(void);
