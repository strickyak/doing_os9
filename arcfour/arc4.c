// state_ptr points to unsigned char[260].
// The first 256 elements are a permutation of 0..255, and changes.
// The two are initialized to 0, but change.
// The next two are temporary variables and do not have to be initialized.
// e.g. struct { byte perm[256]; byte indexes[2]; byte temp[2]; };
unsigned char arc4_byte(unsigned char* state_ptr) {
  unsigned char retval;
  unsigned char tempSx;
  unsigned char tempSy;

  asm {
    ldx state_ptr
    pshs y
    leax 128,x
    leay 128,x

* Input: `x` points 128 bytes into a 256-byte state.
*        `y` points to the beginning of a 4-byte state. # TODO: 2-byte state?
* Returns the byte in `b`.
*
* Does not change U, the CMOC frame pointer.

* compare with arcfour_byte() at
* https://stuff.mit.edu/afs/athena/contrib/crypto/src/ssh-1.2.27/arcfour.c

VX equ 0
VY equ 1

    inc VX,y  ; x = x + 1
    ldb VX,y

    eorb #$80    ; Correction
    lda b,x      ; tempSx = s[x]
    sta tempSx

    adda VY,y    ; y = tempSx + y
    sta VY,y

    eora #$80    ; Correction
    lda a,x      ; tempSy = s[y]
    sta tempSy

    ldb VX,y     ; s[x] = tempSy
    eorb #$80    ; Correction
    sta b,x

    lda tempSx    ; s[y] = tempSx
    ldb VY,y
    eorb #$80    ; Correction
    sta b,x

    adda tempSy ; return s[tempSx+tempSy]
    eora #$80    ; Correction
    ldb a,x    ; return byte is in b
    stb retval

    puls y
  }
  return retval;
}
