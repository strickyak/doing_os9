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
  jsr putchar,pcr
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
  pshs d,x,y    ; push some zeroes for fun.
  pshu d,x,y    ; push some zeroes for fun.
  jsr Init,pcr
  leax c_main,pcr
  pshu x
  jmp Execute,pcr

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

  use prelude.asm

  emod
eom equ *
