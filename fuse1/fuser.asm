********************************************************************
* Fuser - FUSE device driver
*
* Modified from piper.asm by Henry Strickland (github.com/strickyak)

         nam   Fuser
         ttl   Fuse device driver

         ifp1
         use   defsfile
         endc

tylg     set   Drivr+Objct   
atrv     set   ReEnt+rev
rev      set   $00
edition  set   1

         mod   eom,name,tylg,atrv,start,size

u0000    rmb   6
size     equ   .

         fcb   READ.+WRITE.

name     fcs   /Fuser/
         fcb   edition

start    equ   *
Init     clrb  
         rts   
         nop   
Read     clrb  
         rts   
         nop   
Write    clrb  
         rts   
         nop   
GetStat  clrb  
         rts   
         nop   
SetStat  clrb  
         rts   
         nop   
Term     clrb  
         rts   

         emod
eom      equ   *
         end
