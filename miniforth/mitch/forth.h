#ifndef FORTH_H
#define FORTH_H

#include <stdint.h>

// Size of terminal input buffer in characters
#define TIBSIZE 132

// The basic Forth data type - the cell - is the size of a stack element,
// in both signed and unsigned form.  A stack element may contain either
// a number or an address.  On some systems, the C data type "int" is
// smaller than a pointer, so we use "intptr_t" as the base type.

typedef intptr_t cell;
typedef uintptr_t u_cell;

typedef void (*code_field_t)(void);



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
