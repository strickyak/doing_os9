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
         ldx #$FF68
         lda #$80
         lda #$03
Loop     sta 0,x
         stb 0,x
         clr 1,x
         clr 2,x
         ldb 3,x
         bra Loop

         emod
eom      equ   *
         end

