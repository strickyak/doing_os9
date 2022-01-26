* WARNING: Untested

* Input: `x` points 128 bytes into a 256-byte state.
*        `y` points to the beginning of a 4-byte state.         
* Returns the byte in `b`.

VX equ 0
VY equ 1
VSX equ 2
VSY equ 3

arc4byte
	inc VX,y  ; x = x + 1
	ldb VX,y

	lda b,x   ; sx = s[x]
	sta VSX,y

	adda VY,y    ; y = sx + y
	sta VY,y

  lda a,x   ; sy = s[y]
	sta VSY,y

	ldb VX,y  ; s[x] = sy
	sta b,x

	lda VSX,y ; s[y] = sx
	ldb VY,y
	sta b,x

	adda VSY,y ; return s[sx+sy]
	ldb b,x    ; return byte is in b
	rts

* END
