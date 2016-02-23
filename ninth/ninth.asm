* D: top of param stack
* Y: Instruction Pointer
* X: temporary W register
* U: Param Stack
* S: Return Stack

  nam ninth
  ttl Ninth Forth

*  ifp1
    use   defsfile
*  endc

  org 0
D_Execute rmb 2
D_Enter rmb 2
D_Next rmb 2
D_Exit rmb 2
D_SIZE equ .

tylg     set   Prgrm+Objct   
atrv     set   ReEnt+rev
rev      set   $00
edition  set   9

  mod   eom,name,tylg,atrv,start,$800

name
  fcs /ninth/
  fcb edition

hello
  fcc /Hello Ninth!/
  fcb 10
  fcb 13
  fcb 0

start
  lda #1  ; stdout
  leax hello,pcr
  ldy #15
  os9 I$WritLn

  ldd #$0123
  jsr PrintD,pcr
  ldd #$4567
  jsr PrintD,pcr
  ldd #$89ab
  jsr PrintD,pcr
  ldd #$cdef
  jsr PrintD,pcr
  jmp Cold,pcr
  jmp OsExit,pcr

preamble
  leax Execute,pcr
  stx >D_Execute
  leax Enter,pcr
  stx >D_Enter
  leax Next,pcr
  stx >D_Next
  leax Exit,pcr
  stx >D_Exit

testing
  ldx ,y++
  ldd 0,x
  jmp D,X

l_dup
  fcb 0,0   ; link
  fcb 3     ; len
  fcc /dup/ ; name
  fcb 0     ; NUL term
c_dup
  fcb 0,2  ; Code Offset
a_dup
  ldd 0,u
  std ,--u
  jmp Next,pcr

l_plus
  fcb (l_plus-l_dup)/256
  fcb (l_plus-l_dup)
  fcb 1      ; len
  fcc /+/    ; name
  fdb 0      ; NUL
c_plus
  fcb 0,2   ; Code Offset
a_plus
  ldd ,u++
  addd 0,u
  std 0,u
  jmp Next,pcr

l_dot
  fcb (l_dot-l_plus)/256
  fcb (l_dot-l_plus)
  fcb 1      ; len
  fcc /./    ; name
  fdb 0      ; NUL
c_dot
  fcb 0,2   ; Code Offset
a_dot
  ldb #13
  jsr putchar,pcr
  ldd ,u++
  jsr PrintD,pcr
  ldb #13
  jsr putchar,pcr
  jmp Next,pcr

l_lit
  fcb (l_lit-l_dot)/256
  fcb (l_lit-l_dot)
  fcb 3      ; len
  fcc /lit/    ; name
  fdb 0      ; NUL
c_lit
  fcb 0,2   ; Code Offset
a_lit
  ldd ,Y++  ; get next cell from IP
  std ,--u  ; and stack it.
  jmp Next,pcr


l_run
  fcb ($10000+l_run-l_lit)/256
  fcb ($10000+l_run-l_lit)
  fcb 1      ; len
  fcc /./    ; name
  fdb 0      ; NUL
c_run
  fcb ($10000+Enter-c_run)/256
  fcb ($10000+Enter-c_run)
a_run
  fcb ($10000+c_lit-*)/256
  fcb ($10000+c_lit-*+1)
  fcb 0,3
  fcb ($10000+c_dup-*)/256
  fcb ($10000+c_dup-*+1)
  fcb ($10000+c_plus-*)/256
  fcb ($10000+c_plus-*+1)
  fcb ($10000+c_dot-*)/256
  fcb ($10000+c_dot-*+1)
  fcb ($10000+c_bye-*)/256
  fcb ($10000+c_bye-*+1)
  fcb ($10000+Exit-*)/256
  fcb ($10000+Exit-*+1)

l_bye
  fcb ($10000+l_bye-l_run)/256
  fcb ($10000+l_bye-l_run)
  fcb 3      ; len
  fcc /bye/    ; name
  fdb 0      ; NUL
c_bye
  fcb 0,2   ; Code Offset
a_bye
OsExit
  ldb #13  ; CR
  bsr putchar
  ldb #35  ; #
  bsr putchar
  ldb #13  ; CR
  bsr putchar
  clrb
  ldb #8
  os9 F$Exit



PrintD
  pshS A,B
  pshS B
  tfr A,B
  bsr PrintB
  pulS b
  bsr PrintB
  puls a,b,pc

PrintB
  pshS B
  lsrb
  lsrb
  lsrb
  lsrb
  bsr PrintNyb
  pulS B
  pshS B
  bsr PrintNyb
  pulS B,PC

* print low nyb of B.
PrintNyb
  pshS B
  andB #$0f  ; just low nybble
  addB #$30  ; add '0'

  cmpB #$3a  ; is it beyond '9'?
  blt Lpn001
  addB #('A-$3a)  ; covert $3a -> 'A'

Lpn001
  bsr putchar
  pulS B,PC

* putchar(b)
putchar
  pshS A,B,X,Y,U
  leaX 1,S     ; where B was stored
  ldy #1       ; y = just 1 char
  lda #1       ; a = path 1
  os9 I$WritLn ; putchar, trust it works.
  pulS A,B,X,Y,U,PC
  
Cold
  leaU $-200,s  ; U is Parameter Stack.
  clrD          ;
  tfr d,y       ; Y is IP
  tfr d,x       ; X is W or Temp
  pshs d,x,y
  pshu d,x,y

  leax c_run,pcr
  pshu x
  jmp Execute,pcr

  * DEAD
  ldb #10  ; LF
  bsr putchar
  bra OsExit

Execute
  pulU x       ; arg -> W
  ldd 0,x      ; goto W+[W]
  jmp D,X

Enter
  pshS y       ; push old IP onto Return Stack.
  leay 2,x     ; load new IP after W.
  bra Next     ; start executing.

Next
  ldd 0,y
  leax d,y
  leay 2,y
  ldd 0,x
  jmp d,x

  *ldx ,y++     ; [IP]->W; IP++
  *ldd 0,x      ; goto W+[W]
  *jmp D,X

Exit
  pulU y       ; pop previous IP.
  bra Next     ; and keep going.

  emod
eom equ *
