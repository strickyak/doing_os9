// *INDENT-OFF*

asm void stkcheck() {
	asm {
		pshs x
		ldx 2,s   ; get the supposed return PC

		tfr s,d   ; going to subtract from S.
		addd ,x   ; add the max stack size.
		subd _ram_brk,y   ; sub the brk.
		bcs stkcheckBAD
		leax 2,x  ; add 2 to it
		stx 2,s   ; put it back
		puls x,pc ; and use it to return.

stkcheckBAD	leax stkcheckMSG,pcr
		ldy #(stkcheckNUL-stkcheckMSG)
		lda #2    ; stderr
		os9 I_WritLn
		ldb #57
		os9 F_Exit

stkcheckMSG	fcc / *stack oom* /
stkcheckNUL	fcb 0
	}
}

asm void exit(int status) {
	asm {
		ldd 2,s      ; status code in b.
		os9 F_Exit
	}
}

asm int Os9ReadLn(int path, char* buf, int buflen, int* bytes_read) {
	asm {
		pshs y,u
		lda 7,s      ; path
		ldx 8,s      ; buf
		ldy 10,s      ; buflen
		os9 I_ReadLn
		bcs Os9Err
		sty [12,s]   ; bytes_read
		ldd #0
		puls y,u,pc
	}
}

asm int Os9WritLn(int path, const char* buf, int max, int* bytes_written) {
	asm {
		pshs y,u
		lda 7,s      ; path
		ldx 8,s      ; buf
		ldy 10,s      ; max
		os9 I_WritLn
		bcs Os9Err
		sty [12,s]   ; bytes_written
		ldd #0
		puls y,u,pc
	}
}

asm int Os9Dup(int path, int* new_path) {
	asm {
		pshs y,u
		lda 7,s  ; old path.
		os9 0x82 ; I$Dup
		bcs Os9Err
		tfr a,b  ; new path.
		sex
		std [8,s]
		ldd #0
		puls y,u,pc
	}
}

asm int Os9Close(int path) {
	asm {
		pshs y,u
		lda 7,s  ; path.
		os9 0x8F ; I$Close
		bcs Os9Err
		ldd #0
		puls y,u,pc
	}
}

asm int Os9Sleep(int secs) {
	asm {
		pshs y,u
		ldx 6,s  ; ticks
		os9 0x0A ; I$Sleep
		bcs Os9Err
		ldd #0
		puls y,u,pc
Os9Err
		sex
		puls y,u,pc
	}
}

/*
 * OS9 F$Wait
MACHINE CODE: 103F 04
INPUT: None
OUTPUT: (A) = Deceased child process’ process ID
(B) = Child process’ exit status code
*/

asm int Os9Wait(int* child_id) {
	asm {
		pshs y,u
		os9 0x04 ; F$Wait
		bcs Os9Err
		tfr a,b
		sex
		std [6,s]
		ldd #0
		puls y,u,pc
	}
}

/*
   OS9 F$Fork
MACHINE CODE: 103F 03
INPUT: (X) = Address of module name or file name.
(Y) = Parameter area size.
(U) = Beginning address of the parameter area.
(A) = Language / Type code.
(B) = Optional data area size (pages).
OUTPUT: (X) = Updated past the name string.
(A) = New process ID number.
ERROR OUTPUT: (CC) = C bit set. (B) = Appropriate error code.
*/

asm int Os9Fork(const char* program, const char* params, int paramlen, int lang_type, int mem_size, int* child_id) {
	asm {
		pshs y,u
		ldx 6,s  ; program
		ldu 8,s  ; params
		ldy 10,s ; paramlen
		lda 13,s  ; lang_type
		ldb 15,s  ; mem_size
		os9 0x03  ; F$Fork
		bcs Os9Err
		tfr a,b    ; move child id to D
		clra
		std [16,s]  ; Store D to *child_id
		clrb        ; return D=0 no error
		puls y,u,pc
	}
}

asm int Os9Chain(const char* program, const char* params, int paramlen, int lang_type, int mem_size) {
	asm {
		pshs y,u
		ldx 6,s  ; program
		ldu 8,s  ; params
		ldy 10,s ; paramlen
		lda 13,s  ; lang_type
		ldb 15,s  ; mem_size
		os9 0x05  ; F$Chain -- if returns, then it is an error.
		sex         ; extend error B to D
		puls y,u,pc
	}
}

asm char* gets(char* buf) {
	asm {
		pshs y,u
		clra         ; path 0
		ldy #200
		ldx 6,s
		os9 I_ReadLn
		bcs returnNULL
		ldd 6,s      ; return buf
		puls y,u,pc
returnNULL	clra         ; return NULL
		clrb
		puls y,u,pc
	}
}

asm void puts(const char* s) {
	asm {
		pshs y,u
		ldx 6,s      ; arg1: string to write, for strlen.
		pshs x       ; push arg1 for strlen
		lbsr _strlen  ; see how much to puts.
		leas 2,s      ; drop 1 arg after strlen
		tfr d,y       ; max size (strlen) in y
		ldx 6,s      ; arg1: string to write.
		clra         ; a = path ...
		inca         ; a = path 1
		os9 I_WritLn
		puls y,u,pc
	}
	// TODO: error checking.
}

// *INDENT-ON*
