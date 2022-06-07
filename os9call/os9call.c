// OS9 System Calls, lightly wrapped for calling from C.
// This module contains no global data, including no
// const char* strings.

#include "os9call/os9call.h"
#include "os9call/os9.h"
#include "os9call/os9errno.h"

asm void Os9Exit(int status) {
	asm {
		ldd 2,s      ; status code in b.
		swi2
    fcb F_EXIT
	}
}

asm int Os9Create(const char* path, int mode, int attrs, int* fd) {
	asm {
		pshs y,u
		ldx 6,s      ; buf
		lda 9,s      ; mode
		ldb 11,s      ; attrs
		swi2
    fcb 0x83
		lbcs Os9Err

		tfr a,b
		sex
		std [12,s]   ; set fd

		ldd #0
		puls y,u,pc
	}
}

asm int Os9Open(const char* path, int mode, int* fd) {
	asm {
		pshs y,u
		ldx 6,s      ; buf
		lda 9,s      ; mode
		swi2
    fcb 0x84
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
		swi2
    fcb 0x87
		jmp ZeroOrErr,pcr
	}
}

asm int Os9ChgDir(char* path, int mode) {
	asm {
		pshs y,u
		ldx 6,s      ; path
		lda 9,s      ; mode
		swi2
    fcb 0x86     ; I$ChgDir
		jmp ZeroOrErr,pcr
	}
}

asm int Os9MakDir(char* path, int mode) {
	asm {
		pshs y,u
		ldx 6,s      ; path
		ldb 9,s      ; dir attrs
		swi2
    fcb 0x85     ; I$MakDir
		jmp ZeroOrErr,pcr
	}
}

asm int Os9GetStt(int path, int func, int* dOut, int* xOut, int* uOut) {
	asm {
		pshs y,u
		lda 7,s      ; path
		ldb 9,s      ; func
		swi2
    fcb 0x8D     ; I$GetStt
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
		swi2
    fcb 0x89
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
		swi2
    fcb I_READLN
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
		swi2
    fcb 0x8A
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
		swi2
    fcb I_WRITLN
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
		swi2
    fcb 0x82 ; I$Dup
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
		swi2
    fcb 0x8F ; I$Close
		jmp ZeroOrErr,pcr
	}
}

asm int Os9Sleep(int secs) {
	asm {
		pshs y,u
		ldx 6,s  ; ticks
		swi2
    fcb 0x0A ; I$Sleep
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
		swi2
    fcb 0x04 ; F$Wait
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
		swi2
    fcb 0x03  ; F$Fork
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
		swi2
    fcb 0x05  ; F$Chain -- if returns, then it is an error.
		clra      ; extend unsigned error B to D
		puls y,u,pc
	}
}

asm int Os9Send(int process_id, int signal_code) {
	asm {
		pshs y,u
		lda 7,s      ; process_id
		ldb 9,s      ; signal_code
		swi2
    fcb 0x08     ; F$Send
		jmp ZeroOrErr,pcr
	}
}
// *INDENT-ON*
