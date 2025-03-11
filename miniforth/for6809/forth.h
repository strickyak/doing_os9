#ifndef _6809_FORTH_H_
#define _6809_FORTH_H_

// Size of terminal input buffer in characters
#define TIBSIZE 132

#define MAXDICT 200

// The basic Forth data type - the cell - is the size of a stack element,
// in both signed and unsigned form.  A stack element may contain either
// a number or an address.  On some systems, the C data type "int" is
// smaller than a pointer, so we use "intptr_t" as the base type.

typedef signed int cell;
typedef unsigned int u_cell;

typedef void (*code_field_t)(void);

////////////////////////////
// for minimialist gcc6809 environment

#define EOF (-1)
#define NULL ((void*)0)
#define true 1
#define false 0

typedef struct _file_ {
    int fd;
} FILE;
extern FILE stdin[1];
extern FILE stdout[1];
extern FILE stderr[1];

extern void abort();
extern void exit(int a);
extern int feof(FILE* f);
extern void fflush(FILE* f);
extern int fgetc(FILE* f);
extern int fputc(int ch, FILE* f);
extern int isspace(int ch);
extern int printf(const char* fmt, ... );
extern int strlen(const char* s);

////////////////////////////

#include "input.h"
#include "output.h"
#include "parse.h"
#include "handle.h"
#include "find.h"
#include "dictionary.h"
#include "initdict.h"
#include "number.h"
#include "stack.h"
#include "walk.h"

#endif // _6809_FORTH_H_
