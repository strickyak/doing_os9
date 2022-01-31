// *INDENT-OFF*

#ifndef OMIT_stkcheck
asm void stkcheck() {
	asm {
		pshs  x
		ldx   2,s           ; get the supposed return PC

		tfr   s,d           ; going to subtract from S.
		addd  ,x            ; add the max stack size.
		std   _heap_max,y   ; save as maximum usable heap ram.
		subd  _heap_brk,y   ; sub the brk.
		bcs   stkcheckBAD   ; bad if underflowed.
		leax  2,x           ; add 2 to it
		stx   2,s           ; put it back
		puls  x,pc          ; and use it to return.

stkcheckBAD	leax  stkcheckMSG,pcr

*		ldy   #(stkcheckNUL-stkcheckMSG)
*		lda   #2            ; stderr
*		os9   I_WritLn

		pshs x
		lbsr _panic
		ldb   #5
		os9   F_Exit


stkcheckMSG	fcc   / *stack oom* /
stkcheckNUL	fcb   0
	}
}
#endif

asm void pc_trace(int mark, char* ptr) {
	asm {
*                           ; 10: mark; 12:ptr
		pshs y,u    ; 4: orig &; 6: orig frame pointer U.
		leas -4,s   ; 0: char 2: int (for puthex)

		ldd #$0d00   ; CR.
		std 2,s
		leax 2,s
		stx ,s
		lbsr _puts

		ldd 10,s
		std 0,s
		ldd 12,s
		std 2,s
		lbsr _puthex

		ldd #'{'
		std 0,s
		ldd #$FFF1
		std 2,s
		lbsr _puthex


PcTraceLoop	ldd #'U'
		std ,s
		stU 2,s
		lbsr _puthex

		ldd #'P'
		std ,s
		ldd 2,u
		std 2,s
		lbsr _puthex

		ldU ,u	; previous frame pointer
		tfr U,D
		addd #0
		bne PcTraceLoop

		ldd #'}'
		std 0,s
		ldd #$FFF2
		std 2,s
		lbsr _puthex

		ldd #$0d00   ; CR.
		std 2,s
		leax 2,s
		stx ,s
		lbsr _puts

		puls D,X,y,u,pc  ; D and X to undo "leas -4,s"
	}
}

#ifndef OMIT_exit
asm void exit(int status) {
	asm {
		ldd 2,s      ; status code in b.
		os9 F_Exit
	}
}
#endif

asm int Os9Create(char* path, int mode, int attrs, int* fd) {
	asm {
		pshs y,u
		ldx 6,s      ; buf
		lda 9,s      ; mode
		ldb 11,s      ; attrs
		os9 0x83
		lbcs Os9Err

		tfr a,b
		sex
		std [12,s]   ; set fd

		ldd #0
		puls y,u,pc
	}
}

asm int Os9Open(char* path, int mode, int* fd) {
	asm {
		pshs y,u
		ldx 6,s      ; buf
		lda 9,s      ; mode
		os9 0x84
		lbcs Os9Err

		tfr a,b
		sex
		std [10,s]   ; set fd

		ldd #0
		puls y,u,pc
	}
}

asm int Os9Delete(char* path) {
	asm {
		pshs y,u
		ldx 6,s      ; path
		os9 0x87
		jmp ZeroOrErr,pcr
	}
}

asm int Os9ChgDir(char* path, int mode) {
	asm {
		pshs y,u
		ldx 6,s      ; path
		lda 9,s      ; mode
		os9 0x86     ; I$ChgDir
		jmp ZeroOrErr,pcr
	}
}

asm int Os9MakDir(char* path, int mode) {
	asm {
		pshs y,u
		ldx 6,s      ; path
		ldb 9,s      ; dir attrs
		os9 0x85     ; I$MakDir
		jmp ZeroOrErr,pcr
	}
}

asm int Os9GetStt(int path, int func, int* dOut, int* xOut, int* uOut) {
	asm {
		pshs y,u
		lda 7,s      ; path
		ldb 9,s      ; func
		os9 0x8D     ; I$GetStt
		lbcs Os9Err
		std [10,s]   ; dOut
		stx [12,s]   ; xOut
		stu [14,s]   ; uOut
		ldd #0
		puls y,u,pc
	}
}

asm int Os9Read(int path, char* buf, int buflen, int* bytes_read) {
	asm {
		pshs y,u
		lda 7,s      ; path
		ldx 8,s      ; buf
		ldy 10,s      ; buflen
		os9 0x89
		lbcs Os9Err
		sty [12,s]   ; bytes_read
		ldd #0
		puls y,u,pc
	}
}

asm int Os9ReadLn(int path, char* buf, int buflen, int* bytes_read) {
	asm {
		pshs y,u
		lda 7,s      ; path
		ldx 8,s      ; buf
		ldy 10,s      ; buflen
		os9 I_ReadLn
		lbcs Os9Err
		sty [12,s]   ; bytes_read
		ldd #0
		puls y,u,pc
	}
}

asm int Os9Write(int path, const char* buf, int max, int* bytes_written) {
	asm {
		pshs y,u
		lda 7,s      ; path
		ldx 8,s      ; buf
		ldy 10,s      ; max
		os9 0x8A
		lbcs Os9Err
		sty [12,s]   ; bytes_written
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
		lbcs Os9Err
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
		lbcs Os9Err
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
		jmp ZeroOrErr,pcr
	}
}

asm int Os9Sleep(int secs) {
	asm {
		pshs y,u
		ldx 6,s  ; ticks
		os9 0x0A ; I$Sleep
ZeroOrErr	lbcs Os9Err
		ldd #0
		puls y,u,pc
Os9Err
		clra
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

asm int Os9Wait(int* child_id_and_exit_status) {
	asm {
		pshs y,u
		os9 0x04 ; F$Wait
		lbcs Os9Err
		std [6,s]      ; return Child Id in hi byte; Exit Status in low byte.
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
		lbcs Os9Err
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
		clra      ; extend unsigned error B to D
		puls y,u,pc
	}
}

asm int Os9Send(int process_id, int signal_code) {
	asm {
		pshs y,u
		lda 7,s      ; process_id
		ldb 9,s      ; signal_code
		os9 0x08     ; F$Send
		jmp ZeroOrErr,pcr
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
