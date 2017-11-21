* Y: Instruction Pointer
* X: temporary W register
* U: Param Stack
* S: Return Stack

  nam ninth
  ttl Ninth Forth

    use   defsfile

  org 0

tylg     set   Prgrm+Objct
atrv     set   ReEnt+rev
rev      set   $00
edition  set   1

  mod   eom,name,tylg,atrv,start,$800

name
  fcs /ninth/
  fcb edition

HelloNinth
  fcc /{Ninth Forth}/
  fcb 10
  fcb 13
  fcb 0
endHelloNinth

show_regs
  pshs d,x,y,u

  ldb #'<'
  lbsr putchar

  ldb #'d'
  lbsr putchar
  ldd 0,s
  lbsr PrintDsp

  ldb #'x'
  lbsr putchar
  ldd 2,s
  lbsr PrintDsp

  ldb #'y'
  lbsr putchar
  ldd 4,s
  lbsr PrintDsp

  ldb #'u'
  lbsr putchar
  ldd 6,s
  lbsr PrintDsp

  ldx 6,s
  bsr Print3DspAtX

  ldb #'s'
  lbsr putchar
  tfr s,d      ; Now print s
  addd #8       ; but correct it; we pushed 8.
  lbsr PrintDsp

  tfr s,x
  leax 8,x
  bsr Print3DspAtX

  ldb #'>'
  lbsr putchar

  ldb #10
  lbsr putchar
  puls d,x,y,u
  rts

Print3DspAtX
  ldb #'^'
  lbsr putchar
  ldd 0,x
  lbsr PrintDsp

  ldb #'^'
  lbsr putchar
  ldd 2,x
  lbsr PrintDsp

  ldb #'^'
  lbsr putchar
  ldd 4,x
  lbsr PrintDsp
  
  rts

start
  * At beginning of process:
  * Y is end of parameter, end of process memory.
  * X, SP are begin of parameter
  * U, DP are begin of process memory.

  ldd #256
  tfr u,x
clr_page0
  clr ,x++
  subd #1
  bne clr_page0

  stu <v_page0
  sts <v_return0   ; remember initial stacks.
  stu <v_param0

  lbsr show_regs

  lda #1  ; stdout
  leax HelloNinth,pcr
  ldy #endHelloNinth-HelloNinth
  os9 I$WritLn

  leaU $-200,s  ; U is Parameter Stack.
  tfr u,d
  andb #$F0      ; nicely aligned looks better :)
  tfr d,u

  jsr Init,pcr
  leax c_main,pcr
  pshu x
  jmp Execute,pcr

* putchar(b)
putchar
  pshS A,B,X,Y,U
  leaX 1,S     ; where B was stored
  ldy #1       ; y = just 1 char
  lda #1       ; a = path 1
  os9 I$WritLn ; putchar, trust it works.
  pulS A,B,X,Y,U,PC

* Print D (currently in %04x) and a space.
PrintDsp
  pshS D
  bsr PrintD
  ldb #32
  bsr putchar
  pulS D,PC

* Print D (currently in %04x).
PrintD
  pshS A,B
  pshS B
  tfr A,B
  bsr PrintB
  pulS b
  bsr PrintB
  puls a,b,pc

* Print B (as %02x)
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

  tst <v_traceEnable+1  ; just check the low byte.
  ble skip_trace
  *** BEGIN printing word.
  pshs d,x,y

  leax -1,x  ; Back to EOS
  ldb #32
  bsr putchar
  ldb #126
  bsr putchar
  ldb #32
LoopBackwards
  leax -1,x  ; Back to final letter of word.
  lda 0,x
  cmpb 0,x
  ble LoopBackwards

  clra
  ldb 0,x
  tfr d,y   ; number bytes to write
  leax 1,x  ; addr of bytes
  lda #2    ; stderr
  os9 I$WritLn
  ldb #32
  jsr putchar

  puls d,x,y
  *** BEGIN printing IP.
  IFNE 0
  pshs d,x,y
  ldb #$28       "("
  bsr putchar

  tfr y,d
  leax 0,pcr        ; absolute addr of module
  pshs x            ; put it in mem (on S stack)
  subd 0,s          ; subtract begin of module
  leas 2,s          ; drop it from S stack
  jsr PrintD,pcr

  ldb #$29       ")"
  bsr putchar
  ldb #$20       " "
  bsr putchar
  puls d,x,y
  ENDC
  *** END printing IP.
skip_trace

  leay 2,y
  ldd 0,x
  jmp d,x


Exit
  pulU y       ; pop previous IP.
  bra Next     ; and keep going.

  use prelude.asm

  emod
eom equ *
