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

* Dispatch Relays
Init     bra FuserInit
         nop
Read     daa
         clrb
         rts
Write    daa
         clrb
         rts
GetStat  daa
         clrb
         rts
SetStat  daa
         clrb
         rts
Term     bra FuserTerm


* Driver Init: U=DeviceVars Y=DeviceDescription
FuserInit  DAA   ; Init for Fuser
        LDD #'A
        SWI
        FCB 104    ; Hyper PutChar
        LDD #'A
        SWI
        FCB 104    ; Hyper PutChar
        LDD #'A
        SWI
        FCB 104    ; Hyper PutChar
        LDD #'A
        SWI
        FCB 104    ; Hyper PutChar
        clrb
        rts

FuserTerm  DAA

        LDD #'Z
        SWI
        FCB 104    ; Hyper PutChar
        LDD #'Z
        SWI
        FCB 104    ; Hyper PutChar
        LDD #'Z
        SWI
        FCB 104    ; Hyper PutChar
        LDD #'Z
        SWI
        FCB 104    ; Hyper PutChar

       SWI
       FCB 100    ; Fatal Core Dump, just to stop the emulator.

         clrb
         rts

         emod
eom      equ   *
         end
