  nam yak2
  ttl yak2

  use defsfile

tylg     set   Prgrm+Objct   
atrv     set   ReEnt+rev
rev      set   $01
edition  set   0

         mod   eom,name,tylg,atrv,start,size

         org   0
u0000    rmb   450
size     equ   .

name     fcs   /yak2/
         fcb   edition
hello    fcs   /yak2x/

start    leax  hello,pcr
         ldy   #4
         lda   #1
         os9   I$WritLn 

Payload
         orcc #$50   ; disable interrupts
         ldx #$FF68  ; CoCoIO port
         lda #$80    ; RESET command
         lda #$03    ; AutoInc command
Loop     sta 0,x     ; Reset.
         stb 0,x     ; AutoInc mode.
         clr 1,x     ; Hi addr of reg is 0
         clr 2,x     ; Lo addr or reg is 0
         ldb 3,x     ; Read reg 0
         bra Loop

         emod
eom      equ   *
         end

