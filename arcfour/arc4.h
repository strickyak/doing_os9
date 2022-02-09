#ifndef ARCFOUR_ARC4_H_
#define ARCFOUR_ARC4_H_

// state_ptr points to unsigned char[260].
// The first 256 elements are a permutation of 0..255, and changes.
// The two are initialized to 0, but change.
// The next two are temporary variables and do not have to be initialized.
// e.g. struct { byte perm[256]; byte indexes[2]; byte temp[2]; };
unsigned char arc4_byte(unsigned char* state_ptr);

#endif
