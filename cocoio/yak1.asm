  nam yak1
  ttl yak1

  use defsfile

tylg     set   Prgrm+Objct   
atrv     set   ReEnt+rev
rev      set   $01
edition  set   0

         mod   eom,name,tylg,atrv,start,size

         org   0
u0000    rmb   450
size     equ   .

name     fcs   /yak1/
         fcb   edition
hello     fcs   /yak1x/

start    leax  hello,pcr
         ldy   #4
         lda   #1
         os9   I$WritLn 
         bcs   Exit
         clrb  
Exit     os9   F$Exit   

         emod
eom      equ   *
         end

