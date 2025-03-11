#ifndef FORTH_H
#define FORTH_H

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

typedef struct _file_ {} *FILE;
extern FILE stdin;
extern FILE stdout;
extern FILE stderr;


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
#endif
