// ny: NitroYak: Yak Libs for NitrOS9

#ifndef _NYLIB_H_
#define _NYLIB_H_

#ifndef NYLIB_OMIT_TYPEDEFS
// Fundamental type definitions for using cmoc.
typedef unsigned char bool;
typedef unsigned char byte;
typedef unsigned char error;
typedef unsigned int word;
typedef unsigned long ip4addr;
#define OKAY (error)0
#define NYLIB_OMIT_TYPEDEFS
#endif

// Spaces and all control chars <32 are white.
bool ny_white(char c);
int ny_split(char* s, char**words_out, int max_words);




#endif // _NYLIB_H_
