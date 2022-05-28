********************************************************************
* Fuse - FUSE device descriptor
*
* Modified from pipe.asm by Henry Strickland (github.com/strickyak)

         nam   Fuse
         ttl   FUSE device descriptor

         ifp1  
         use   defsfile
*        use   pipedefs
         endc  

tylg     set   Devic+Objct
atrv     set   ReEnt+rev
rev      set   $00

         mod   eom,name,tylg,atrv,mgrnam,drvnam

         fcb   READ.+WRITE. ; mode byte
         fcb   $00          ; extended controller address
         fdb   $0000        ; physical controller address
         fcb   initsize-*-1 ; initilization table size
         fcb   23           ; device type 23
initsize equ   *

name     fcs   /Fuse/
mgrnam   fcs   /FuseMan/
drvnam   fcs   /Fuser/

         emod  
eom      equ   *
         end   
