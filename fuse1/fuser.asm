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

         mod   eom,name,tylg,atrv,start,static_ram_sz

PreDeviceVars  rmb 6   ; 6 bytes of predefined struct DeviceVars.
base_of_ram64  rmb 2   ; base page of 64-byte allocs.
static_ram_sz  equ .   ; will be rounded up to 256 anyway.

         fcb   READ.+WRITE.

name     fcs   /Fuser/
         fcb   edition

start    equ   *

* Dispatch Relays
Init     bra FuserInit
         nop
Read     clrb  ; never called.
         comb
         rts
Write    clrb  ; never called.
         comb
         rts
GetStat  clrb  ; never called.
         comb
         rts
SetStat  clrb  ; never called.
         comb
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
