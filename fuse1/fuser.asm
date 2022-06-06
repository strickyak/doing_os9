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

V.AllBase   EQU 8   ; Skip 7.  Words debug easier when aligned!
V.AllFirst  EQU 10


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


*        PSHS B,Y,U
*        TFR y,d
*        SWI
*        FCB 105    ; Show Ram Description
*        TFR u,d
*        SWI
*        FCB 105    ; Show Ram Device Vars
*        TFR u,d
*        SWI
*        FCB 103    ; Hyper PutHex U
*        LDD #'z
*        SWI
*        FCB 104    ; Hyper PutChar
*        PULS B,Y,U
*
** Allocate the ram base page.
*        LDX #0  ; nullptr: no base table yet.
*        PSHS U
*        SWI2
*        FCB F$All64   ; allocate base table and first page.
*        PULS U
*        bcc InitOK
*
*        PSHS B
*        CLRA
*        SWI
*        FCB 103    ; Hyper PutHex error number
*        LDD #'#
*        SWI
*        FCB 104    ; Hyper PutChar '#'
*        PULS B
*
*        COMA       ; set Carry bit meaning error
*        RTS        ; return with errno in B.
*
*InitOK
*        STX V.AllBase,U   ; base for future All64
*        STY V.AllFirst,U  ; first alloc -- wasted for now.
*
*				ldd #13
*				SWI
*				FCB 104
*
*				ldd #'U
*				SWI
*				FCB 104
*				TFR U,D
*				SWI
*				FCB 103
*
*
*
*				ldd #'X
*				SWI
*				FCB 104
*				TFR X,D
*				SWI
*				FCB 103
*
*				ldd #'Y
*				SWI
*				FCB 104
*				TFR Y,D
*				SWI
*				FCB 103
*
*				ldd #'Z
*				SWI
*				FCB 104
*         clrb
*         rts


FuserTerm  DAA
        PSHS A,B,Y,U

*       PSHS A,B
*       LDD #'Z
*       SWI
*       FCB 104    ; Hyper PutChar
*       LDD #'Z
*       SWI
*       FCB 104    ; Hyper PutChar
*       LDD #'Z
*       SWI
*       FCB 104    ; Hyper PutChar
*       LDD #'Z
*       SWI
*       FCB 104    ; Hyper PutChar
*       PULS A,B


*       TFR y,d
*       SWI
*       FCB 105    ; Show Ram Description
*       TFR u,d
*       SWI
*       FCB 105    ; Show Ram Device Vars
*       TFR u,d
*       SWI
*       FCB 103    ; Hyper PutHex U

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

        PULS A,B,Y,U

*       SWI
*       FCB 100    ; Fatal Core Dump, just to stop the emulator.

         clrb
         rts

         emod
eom      equ   *
         end
