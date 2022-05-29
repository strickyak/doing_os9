********************************************************************
* FuseMan - User-mode Filesystem manager for OS9
*
* 2020-03 Henry Strickland <github.com/strickyak>
* 
* MIT License
* 
* Copyright (c) 2021 Strick Yak
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
* 

         nam   FuseMan
         ttl   Fuse Filesystem Manager

         ifp1  
         use   defsfile
         endc  

rev      set   $01
ty       set   FlMgr
         IFNE  H6309
lg       set   Obj6309
         ELSE
lg       set   Objct
         ENDC
tylg     set   ty+lg
atrv     set   ReEnt+rev
edition  set   1

         org   $00
size     equ   .

         mod   eom,name,tylg,atrv,start,size

name     fcs   /FuseMan/
         fcb   edition


****************************
*
* Main entry points
*
* Entry: Y = Path descriptor pointer
*        U = Register stack pointer

start    lbra  _CreateOrOpenA
         lbra  _CreateOrOpenA
         lbra  ManMakDir
         lbra  ManChgDir
         lbra  ManDelete
         lbra  ManSeek
         lbra  _ReadA
         lbra  _WriteA
         lbra  _ReadLnA
         lbra  _WritLnA
         lbra  _GetStatA
         lbra  _SetStatA
         lbra  _CloseA


*
* I$Create Entry Point
*
* Entry: A = access mode desired
*        B = file attributes (for Create, not for Open)
*        X = address of the pathlist
*
* Exit:  A = pathnum
*        X = last byte of pathlist address
*
* Error: CC Carry set
*        B = errcode
*
ManCreateOrOpen
	lbsr _CreateOrOpenA

ReturnEither
  orb #0
	bne ReturnError
ReturnOk
  clrb  ; clear carry
	rts

ReturnBug
  ldb #E$Bug
ReturnError
  coma  ; set carry
	rts


*
* I$MakDir Entry Point
*
* Entry: X = address of the pathlist
*
* Exit:  X = last byte of pathlist address
*
* Error: CC Carry set
*        B = errcode
*
ManMakDir
         lbra ReturnBug


*
* I$Close Entry Point
*
* Entry: A = path number
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
ManClose
         lbra _CloseA


*
* I$ChgDir Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
ManChgDir
         lbra ReturnBug


*
* I$Delete Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
ManDelete   
         lbra ReturnBug


*
* I$Seek Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
ManSeek     
         lbra ReturnBug


*
* I$ReadLn Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
ManReadLn
         lbra _ReadLnA
         

*
* I$Read Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
ManRead     
         lbra _ReadA


*
* I$WritLn Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
ManWriteLn  
         lbra _WritLnA


*
* I$Write Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
ManWrite    
         lbra _WriteA

*
* I$GetStat Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
ManGetStat  
         lbra ReturnOk



*
* I$SetStat Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
ManSetStat  
         lbra ReturnOk


         use _generated_from_fusec_.a

         emod  
eom      equ   *
         end

