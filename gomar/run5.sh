#!/bin/sh
# go run -x -tags=coco3,level2,display,trace gomar.go -boot eouBeta5/BOOTFILEsbc09 --disk eouBeta5/68EMU.dsk --h0 eouBeta5/68SDC.a  --borges ../borges/ 2>_

go run -x -tags=coco3,level2,display,trace gomar.go \
  -boot eouBeta5/BOOTFILEsbc09 \
  --disk eouBeta5/68EMU.dsk \
  --h0 eouBeta5/68SDC.a  \
  --borges ../borges/   \
  --trigger_os9='(?i:fork.*file=.gshell)' \
  --watch '"gshell.40014a85ef"+0d22:d:get X coord,"gshell.40014a85ef"+0d1a:d:get Y coord,"gshell.40014a85ef"+0790:d:update screen' \
  2>_

exit $?

cat <<EOF

$ ll /dd
lrwxrwxrwx 1 root root 16 Oct 30  2019 /dd -> /tmp/68sdc.unix//
$ ll /tmp/68sdc.unix
lrwxrwxrwx 1 strick primarygroup 72 Sep 13 21:15 /tmp/68sdc.unix -> /home/strick/go/src/github.com/strickyak/doing_os9/gomar/eouBeta5/68SDC//
$ 


== ./sourcecode/asm/nitros9/cmds/HOW.1

/home/strick/6809/bin//lwasm-orig \
  --6309 \
  --format=os9 \
  --pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal \
  --includedir=. \
  -DNOS9VER=3 \
  -DNOS9MAJ=3 \
  -DNOS9MIN=0 \
  -DNOS9DBG=1 \
  -Dcoco3=1 \
  -I /home/strick/go/src/github.com/strickyak/doing_os9/gomar/eouBeta5/68SDC/sourcecode/asm/nitros9/mods \
  --list=grfdrv_beta5_withmatchbox.listing \
  -o'grfdrv_beta5_withmatchbox.out' \
  grfdrv_beta5_withmatchbox.asm
# 


==   ./sourcecode/asm/nitros9/scf/HOW.1
for x in cowin_beta5 vtio_beta5 vtio_beta5yak
do
  /home/strick/6809/bin//lwasm-orig \
    --6309 \
    --format=os9 \
    --pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal \
    --includedir=. \
    -DNOS9VER=3 \
    -DNOS9MAJ=3 \
    -DNOS9MIN=0 \
    -DNOS9DBG=1 \
    -Dcoco3=1 \
    -I /home/strick/go/src/github.com/strickyak/doing_os9/gomar/eouBeta5/68SDC/sourcecode/asm/nitros9/mods \
    --list=$x.listingyak \
    -o"$x.out" \
    $x.asm
done

==  sourcecode/asm/gshell

$ /home/strick/6809/bin//lwasm-orig --6309 --format=os9 --pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal --includedir=. -DNOS9VER=3 -DNOS9MAJ=3 -DNOS9MIN=0 -DNOS9DBG=1 -Dcoco3=1 -I /home/strick/go/src/github.com/strickyak/doing_os9/gomar/eouBeta5/68SDC/sourcecode/asm/nitros9/mods --list="gshell_beta5_yak.listingyak" -o"gshell_beta5_yak.outyak"   gshell_beta5_yak.asm 


--- gshell_beta5.asm	2020-09-13 20:51:50.006638697 -0700
+++ gshell_beta5_yak.asm	2020-09-19 00:20:30.077609880 -0700
@@ -183,50 +183,50 @@
 IC.XTRNL equ   $0014      Start of external entries (from AIF files)
 
 * Menu ID #'s
-MID.CLS  equ   $0002
-MID.SUP  equ   $0004
-MID.SDN  equ   $0005
-MID.SRT  equ   $0006
-MID.SLT  equ   $0007
-MID.TDY  equ   $0014
-MID.FIL  equ   $0017
-MID.VEW  equ   $0018
-MID.DSK  equ   $0019
-MID.KDM  equ   $001A
+YID.CLS  equ   $0002
+YID.SUP  equ   $0004
+YID.SDN  equ   $0005
+YID.SRT  equ   $0006
+YID.SLT  equ   $0007
+YID.TDY  equ   $0014
+YID.FIL  equ   $0017
+YID.VEW  equ   $0018
+YID.DSK  equ   $0019
+YID.KDM  equ   $001A
 
 * Mouse packet variables (see manual)
-PT.VALID equ   $0000
-PT.CBSA  equ   $0008
-PT.CBSB  equ   $0009
-PT.STAT  equ   $0016
-PT.ACX   equ   $0018
-PT.ACY   equ   $001A
-PT.WRX   equ   $001C
-PT.WRY   equ   $001E
+YT.VALID equ   $0000
+YT.CBSA  equ   $0008
+YT.CBSB  equ   $0009
+YT.STAT  equ   $0016
+YT.ACX   equ   $0018
+YT.ACY   equ   $001A
+YT.WRX   equ   $001C
+YT.WRY   equ   $001E
 
 * Std paths
 STDOUT   equ   $0001
 STDERR   equ   $0002
 
 * CoWin window types we use
-WT.FSWIN equ   $0002      Framed/scroll bar window
-WT.DBOX  equ   $0004      Double Box window
+ZT.FSWIN equ   $0002      Framed/scroll bar window
+ZT.DBOX  equ   $0004      Double Box window
 
 * Window Descriptors values for a framed window
-WN.NMNS  equ   $0014      # items in menu bar
-WN.SYNC  equ   $0017      Sync byte offset in framed window descriptor
-WN.BAR   equ   $0020      Ptr to Menu descriptor array
-WINSYNC  equ   $C0C0      Actual Sync byte value (to show window is valid - $CoCo, get it?)
+XN.NMNS  equ   $0014      # items in menu bar
+XN.SYNC  equ   $0017      Sync byte offset in framed window descriptor
+XN.BAR   equ   $0020      Ptr to Menu descriptor array
+YWINSYNC  equ   $C0C0      Actual Sync byte value (to show window is valid - $CoCo, get it?)
 
 * Graphic cursors we use
-PTR.ARR  equ   $0001      Standard arrow ptr graphics cursor
-PTR.SLP  equ   $0004      Standard Wait (hourglass) graphics cursor
-PTR.ILL  equ   $0005      Standard Illegal action graphics cursor
+YTR.ARR  equ   $0001      Standard arrow ptr graphics cursor
+YTR.SLP  equ   $0004      Standard Wait (hourglass) graphics cursor
+YTR.ILL  equ   $0005      Standard Illegal action graphics cursor
 
 * Standard fonts we use
-FNT.S8X8 equ   $0001      Font # for normal 8x8 font
-FNT.S6X8 equ   $0002      Font # for normal 6x8 font
-FNT.G8X8 equ   $0003      Font # for normal 8x8 graphics symbol font
+YNT.S8X8 equ   $0001      Font # for normal 8x8 font
+YNT.S6X8 equ   $0002      Font # for normal 6x8 font
+YNT.G8X8 equ   $0003      Font # for normal 8x8 graphics symbol font
 
 * Signal codes we use
 MOUSIGNL equ   $000A      10=mouse click/select received signal
@@ -234,18 +234,18 @@
 DIRSIG   equ   $000C      New signal for SS.FSig (current viewed directory has been changed)
 
 * Menu descriptor vars we use
-MN.ENBL  equ   $0012      Menu Descriptor - Menu enabled flag offset
-MN.SIZ   equ   $0017      Menu Descriptor packet size (23 bytes)
+QN.ENBL  equ   $0012      Menu Descriptor - Menu enabled flag offset
+QN.SIZ   equ   $0017      Menu Descriptor packet size (23 bytes)
 
 * Menu item Descriptor vars we use
-MI.SIZ   equ   $0015      Menu Item descriptor size (21 bytes)
-MI.ENBL  equ   $000F      Menu Item descriptor - Menu item enabled flag offset
+QI.SIZ   equ   $0015      Menu Item descriptor size (21 bytes)
+QI.ENBL  equ   $000F      Menu Item descriptor - Menu item enabled flag offset
 
-WN.SIZ   equ   $0022      CoWin framed Window descriptor size (34 bytes)
+XN.SIZ   equ   $0022      CoWin framed Window descriptor size (34 bytes)
 
 * (MAY WANT NEW GROUP FOR 4 COLOR PTRS, KEEP THESE FOR TYPE 5 WINDOWS)
-GRP.FNT  equ   $00C8      Standard font group buffer #
-GRP.PTR  equ   $00CA      Standard font group for mouse cursor ptrs
+QRP.FNT  equ   $00C8      Standard font group buffer #
+QRP.PTR  equ   $00CA      Standard font group for mouse cursor ptrs
 
 * OS-9 DATA AREA DEFINITIONS
          org   0
@@ -308,35 +308,35 @@
 BXOFFSET rmb   2          X size for selection box. 
 WD48FLAG rmb   1          $80 if on type 7 window.
 SCRATCH  rmb   2          Scratch var (1 or 2 byte) to speed up some stuff that was on stack
-TNDYITMS rmb   MI.SIZ*8   Tandy Menu items array. (8 entries)
+TNDYITMS rmb   QI.SIZ*8   Tandy Menu items array. (8 entries)
 
 DISKITMS rmb   0          Disk Menu items array.
-ITM.FREE rmb   MI.SIZ     Free
-ITM.FLDR rmb   MI.SIZ     Folder
-ITM.FMAT rmb   MI.SIZ*4   Format to Set Devices (4 entries)
+ITM.FREE rmb   QI.SIZ     Free
+ITM.FLDR rmb   QI.SIZ     Folder
+ITM.FMAT rmb   QI.SIZ*4   Format to Set Devices (4 entries)
 
 FILSITMS rmb   0          Files menu items array.
-ITM.OPEN rmb   MI.SIZ     Open
-ITM.LIST rmb   MI.SIZ     List
-ITM.COPY rmb   MI.SIZ     Copy
-ITM.STAT rmb   MI.SIZ     Stat
-ITM.PRNT rmb   MI.SIZ     Print
-ITM.RNAM rmb   MI.SIZ     Rename
-ITM.DELT rmb   MI.SIZ     Delete
+ITM.OPEN rmb   QI.SIZ     Open
+ITM.LIST rmb   QI.SIZ     List
+ITM.COPY rmb   QI.SIZ     Copy
+ITM.STAT rmb   QI.SIZ     Stat
+ITM.PRNT rmb   QI.SIZ     Print
+ITM.RNAM rmb   QI.SIZ     Rename
+ITM.DELT rmb   QI.SIZ     Delete
 * 6809/6309 - add ITM.DUMP here
-ITM.DUMP rmb   MI.SIZ     Dump
-ITM.SORT rmb   MI.SIZ*2   Sort & Quit 
+ITM.DUMP rmb   QI.SIZ     Dump
+ITM.SORT rmb   QI.SIZ*2   Sort & Quit 
 
 VIEWITMS rmb   0          View Menu items array.
-ITM.LRES rmb   MI.SIZ*3   Low Res 4 Color (3 items total)
+ITM.LRES rmb   QI.SIZ*3   Low Res 4 Color (3 items total)
 
-KDMITMS  rmb   MI.SIZ*2   KDM Menu items array. 2 items, never selectable
+KDMITMS  rmb   QI.SIZ*2   KDM Menu items array. 2 items, never selectable
 
-TNDYDESC rmb   MN.SIZ     Tandy Menu descriptor.
-FILSDESC rmb   MN.SIZ     Files Menu descriptor.
-DISKDESC rmb   MN.SIZ     Disk Menu descriptor.
-VIEWDESC rmb   MN.SIZ     View Menu descriptor. 
-KDMDESC  rmb   MN.SIZ     KDM Menu descriptor. 
+TNDYDESC rmb   QN.SIZ     Tandy Menu descriptor.
+FILSDESC rmb   QN.SIZ     Files Menu descriptor.
+DISKDESC rmb   QN.SIZ     Disk Menu descriptor.
+VIEWDESC rmb   QN.SIZ     View Menu descriptor. 
+KDMDESC  rmb   QN.SIZ     KDM Menu descriptor. 
 
 SHELLNAM rmb   6          "shell"
 LISTNAM  rmb   5          "list"
@@ -372,7 +372,7 @@
 MTOP     rmb   2          "C" Variable.
 STBOT    rmb   2          "C" Variable.
 ERRNO    rmb   2          "C" Variable.
-WINDDESC rmb   WN.SIZ     GShell window descriptor.
+WINDDESC rmb   XN.SIZ     GShell window descriptor.
 DDIRNAME rmb   256        Full path name to current data directory.
 XDIRNAME rmb   256        Full path name to current execution directory.
 MOUSPCKT rmb   32         Mouse packet buffer.
@@ -549,11 +549,11 @@
          bra   DoneFix    Save & return
 
 BILDDESC ldx   #TNDYDESC  Point to our copy of Tandy Menu descriptor
-         stx   WINDDESC+WN.BAR,Y Save as ptr to menu descriptors
+         stx   WINDDESC+XN.BAR,Y Save as ptr to menu descriptors
          ldb   #5         5 menus on the menu bar
-         stb   WINDDESC+WN.NMNS,Y
-         ldd   #WINSYNC   Sync bytes to $c0c0 <grin>
-         std   WINDDESC+WN.SYNC,Y
+         stb   WINDDESC+XN.NMNS,Y
+         ldd   #YWINSYNC   Sync bytes to $c0c0 <grin>
+         std   WINDDESC+XN.SYNC,Y
          leax  <GSHELLTL,PC Point to GSHELL title bar
          pshs  X          Save it
          ldx   #WINDDESC  Point to Gshell menu descriptor
@@ -591,7 +591,7 @@
          blt   SETWIND1   ??? Error, skip ahead
          lbsr  MenuClr    Set color for menu bars
          ldx   #WINDDESC  Point to Gshell menu structure
-         ldd   #WT.FSWIN  Framed window with scrollbars
+         ldd   #ZT.FSWIN  Framed window with scrollbars
          pshs  d,X        Save on stack
          ldb   WNDWPATH+1 Get path to window
          pshs  d          Save
@@ -610,9 +610,9 @@
          ldb   WNDWPATH+1 Get window path
          stb   1,S        Save on stack
          lbsr  SELECT     Select Gshell window path as current window
-         ldb   #FNT.S6X8  Save 6x8 font #
+         ldb   #YNT.S6X8  Save 6x8 font #
          stb   1+4,S
-         ldb   #GRP.FNT   Save font group #
+         ldb   #QRP.FNT   Save font group #
          stb   3,S
          lbsr  FONT       Select the 6x8 font
          clrb             Echo off, pause off
@@ -672,8 +672,8 @@
          lbsr  SETVIEW    Set up the VIEW menu
          tst   RAMSIZE    >128k RAM?
          bne   FINLINIX   Yes, skip ahead
-         clr   VIEWDESC+MN.ENBL No, disable the view menu (only allow 16k 320x200x4)
-         clr   ITM.FMAT+MI.ENBL Disable the FORMAT command
+         clr   VIEWDESC+QN.ENBL No, disable the view menu (only allow 16k 320x200x4)
+         clr   ITM.FMAT+QI.ENBL Disable the FORMAT command
          lda   WNDWPATH+1 Get window path
          ldb   #SS.UMBar  Update the menu bar (to enforce above changes)
          os9   I$SetStt
@@ -737,11 +737,11 @@
          pshs  d,U
          lbsr  GT.MOUSE   Get mouse packet
          leas  4,S
-         ldb   PT.VALID,U Mouse on current window?
+         ldb   YT.VALID,U Mouse on current window?
          beq   WAITLOOP   No, continue waiting
-         ldb   PT.CBSA,U  Is button A pressed?
+         ldb   YT.CBSA,U  Is button A pressed?
          beq   WAITLOOP   No, continue waiting
-         ldb   PT.STAT,U  Is mouse in control region or off window?
+         ldb   YT.STAT,U  Is mouse in control region or off window?
          bne   CHEKMENU   Yes, go check if menu select made
          pshs  U
          lbsr  CHEKSCRN   No, check if user selected something not on menu bar
@@ -754,19 +754,19 @@
 * Error code added to see if we get errors when GSHELL "freezes"
          bcc   NoError
          os9   F$Exit
-NoError  suba  #MID.CLS   Close box?
+NoError  suba  #YID.CLS   Close box?
          beq   CLOSEBOX
-         suba  #MID.SUP-MID.CLS   Scroll up arrow?
+         suba  #YID.SUP-MID.CLS   Scroll up arrow?
          beq   SCRLLUPL
-         deca             Scroll down arrow? (MID.SDN)
+         deca             Scroll down arrow? (YID.SDN)
          beq   SCRLLDNR
-         deca             Scroll right arrow? (MID.SRT)
+         deca             Scroll right arrow? (YID.SRT)
          beq   SCRLLDNR
-         deca             Scroll left arrow? (MID.SLT)
+         deca             Scroll left arrow? (YID.SLT)
          beq   SCRLLUPL
-         suba  #MID.TDY-MID.SLT Tandy menu?
+         suba  #YID.TDY-MID.SLT Tandy menu?
          beq   TNDYMENU
-         suba  #MID.FIL-MID.TDY File menu?
+         suba  #YID.FIL-MID.TDY File menu?
          beq   FILEMENU
          deca             View menu?
          beq   VIEWMENU
@@ -1010,7 +1010,7 @@
          ldb   #1
          std   ,S
 * added for DUMP
-         stb   ITM.DUMP+MI.ENBL  Enable DUMP on files menu
+         stb   ITM.DUMP+QI.ENBL  Enable DUMP on files menu
          lbsr  ENBLOPEN   Enable OPEN item on files menu
          lbsr  ENSTRNDL   Enable STAT, RENAME & DELETE on files menu
          bra   ICONEXT1   Exit
@@ -1070,7 +1070,7 @@
 ICONAIF2 leas  2,S
 ICONPRG1 ldb   #1         Enable OPEN item on FILES menu
 * Added for DUMP (works on executables, AIF's of both types)
-         stb   ITM.DUMP+MI.ENBL  Enable DUMP menu as well
+         stb   ITM.DUMP+QI.ENBL  Enable DUMP menu as well
          pshs  d
          lbsr  ENBLOPEN
 ICONTEX1 ldb   #1
@@ -1662,9 +1662,9 @@
          clrb
        ENDC
          std   FILESCTR   # files in current dir=0
-         ldb   #PTR.SLP   Hourglass ptr
+         ldb   #YTR.SLP   Hourglass ptr
          pshs  d,X,Y
-         ldx   #GRP.PTR
+         ldx   #QRP.PTR
          ldd   WNDWPATH
          pshs  d,X
          lbsr  GCSET      Set cursor to hourglass
@@ -2239,10 +2239,10 @@
 *       else D=ptr to FL.* structure for icon selected
 ISITICON pshs  U
          ldx   4,S        Get ptr to mouse packet
-         ldd   PT.ACY,X   Get Y coord
+         ldd   YT.ACY,X   Get Y coord
          subd  #8
          pshs  d,X        Save modified Y coord & room for X coord
-         ldd   PT.ACX,X   Get X coord
+         ldd   YT.ACX,X   Get X coord
          tst   FLAG640W   640 wide screen?
          bne   ISITICO1   No, skip ahead
        IFNE  H6309
@@ -3046,9 +3046,9 @@
 * Exit: D=0 - could not fork program (error in GD.STATS,u), D=1 - successful fork
 LINKLOAD pshs  U
          ldu   4,S
-         ldb   #PTR.SLP   Change ptr to sleep icon
+         ldb   #YTR.SLP   Change ptr to sleep icon
          pshs  d,X
-         ldx   #GRP.PTR
+         ldx   #QRP.PTR
          ldd   WNDWPATH
          pshs  d,X
          lbsr  NOMOUSE    Shut auto-follow AND mouse cursor off
@@ -4333,7 +4333,7 @@
          ldd   WNDWPATH
          pshs  d,X
          lbsr  OWSET
-         ldd   #WT.DBOX   Double box overlay window
+         ldd   #ZT.DBOX   Double box overlay window
          std   2,S
          lbsr  ST.WNSET
          ldd   10+16,S
@@ -4526,8 +4526,8 @@
 *        2-3,s = Ptr to mouse packet
 TESTDBOX pshs  U
          ldu   4,S        Get ptr to mouse packet
-         ldx   PT.WRX,U   Get
-         ldd   PT.WRY,U
+         ldx   YT.WRX,U   Get
+         ldd   YT.WRY,U
          pshs  d,X
          ldd   10,S
          cmpd  2,S
@@ -4577,15 +4577,15 @@
 
 * Update VIEW menu options
 SETVIEW  ldb   #1
-         ldx   #ITM.LRES+MI.ENBL
+         ldx   #ITM.LRES+QI.ENBL
          stb   ,X
-         stb   MI.SIZ,X
-         stb   MI.SIZ*2,X
+         stb   QI.SIZ,X
+         stb   QI.SIZ*2,X
          ldb   DEFWTYPE+1
          subb  #5
 SETVIEW1 decb  
          beq   SETVIEW2
-         leax  MI.SIZ,X
+         leax  QI.SIZ,X
          bra   SETVIEW1
 
 SETVIEW2 clr   ,X
@@ -4709,7 +4709,7 @@
 
 EXCICON1 ldd   6,S        ???
          beq   EXCICON2
-         ldx   #WT.DBOX   Double box border
+         ldx   #ZT.DBOX   Double box border
          ldb   WNDWPATH+1 Window path
          pshs  D,X        Save for routine
          lbsr  ST.WNSET   Set window to double box
@@ -4740,7 +4740,7 @@
          blt   EXCICN11   No, report error
          ldd   6,S        Yes, Get double box window flag
          beq   EXCICON5   Not set, go straight to program fork
-         ldx   #WT.DBOX   Draw Double box window
+         ldx   #ZT.DBOX   Draw Double box window
          ldd   GD.WPATH,U Get path # to window program is/will be running on
          pshs  D,X        Save for subroutine
          lbsr  ST.WNSET   Set up window as double box type
@@ -4826,12 +4826,12 @@
 * If hi bit set, we want to switch to 8x8 font first
          leas  -6,s       Make room for vars for FONT command
          std   ,s         Save overlay window flag
-         ldd   #GRP.FNT   Font Group ($c8)
+         ldd   #QRP.FNT   Font Group ($c8)
          std   2,s
-         ldd   #FNT.S6X8  Default to 6x8 font
+         ldd   #YNT.S6X8  Default to 6x8 font
          tst   ,s         Do we want 8x8 font instead?
          bpl   SavFntTp   No, save 6x8
-         ldb   #FNT.S8X8  8x8 font (for DUMP and STAT)
+         ldb   #YNT.S8X8  8x8 font (for DUMP and STAT)
 SavFntTp std   4,s
          lbsr  FONT       Change font
          leas  6,s        Eat temp stack
@@ -4854,9 +4854,9 @@
          pshs  d
          bsr   MOUSENOW   Turn mouse back on (and mouse ptr)
 * Force font to 6x8         
-         ldd   #GRP.FNT   Font Group ($c8)
+         ldd   #QRP.FNT   Font Group ($c8)
          std   2,s
-         ldb   #FNT.S6X8  Default to 6x8 font
+         ldb   #YNT.S6X8  Default to 6x8 font
 SaveFnt  std   4,s
          lbsr  FONT       Change font
          leas  6,s        Eat temp stack
@@ -4995,9 +4995,9 @@
          rts   
 
 *Change current window type (from VIEW menu)
-SETHLRES ldd   #PTR.SLP   Set mouse cursor to hourglass
+SETHLRES ldd   #YTR.SLP   Set mouse cursor to hourglass
          pshs  d
-         ldx   #GRP.PTR
+         ldx   #QRP.PTR
          ldd   WNDWPATH
          pshs  d,X
          lbsr  GCSET
@@ -5051,7 +5051,7 @@
          ldb   WNDWPATH+1
          pshs  D,X
          lbsr  OWSET
-         ldd   #WT.DBOX
+         ldd   #ZT.DBOX
          std   2,S
          lbsr  ST.WNSET
          leax  <AREYSURE,PC
@@ -5158,7 +5158,7 @@
          leas  16,S       Eat stack
          std   -2,S       Was there an error?
          bne   OLAYBERR   Yes, deal with it
-         ldx   #WT.DBOX   No, convert overlay to Double box window
+         ldx   #ZT.DBOX   No, convert overlay to Double box window
          ldd   WNDWPATH
          pshs  D,X
          lbsr  ST.WNSET   Draw double box
@@ -5334,12 +5334,12 @@
          leas  16,S       Eat temp stack
          std   -2,S       If error, eat stack & return
          bne   OLAYGNB4
-         ldx   #WT.DBOX   Now make the overlay a double bordered box
+         ldx   #ZT.DBOX   Now make the overlay a double bordered box
          ldd   18-2,S
          pshs  D,X
          lbsr  ST.WNSET
          pshs  y          Save Y just in case
-         ldy   #GRP.FNT*256+FNT.S6X8   Font buffer group & 6x8 font #
+         ldy   #QRP.FNT*256+YNT.S6X8   Font buffer group & 6x8 font #
          ldd   #$1B3A     Font Select
          pshs  d,y        Save font select command
          leax  ,s         Point X to it
@@ -5510,7 +5510,7 @@
          ldd   4,S
          pshs  D,U
 GETMPAK1 lbsr  GT.MOUSE   Get mouse packet
-         ldd   PT.CBSA,U  Button A pressed?
+         ldd   YT.CBSA,U  Button A pressed?
          bne   GETMPAK1   Yes, wait till it is released
          leas  4,S
          puls  U,PC
@@ -5552,13 +5552,13 @@
          pshs  D
          lbsr  GT.MOUSE   Get mouse update
          leas  4,S
-         ldb   PT.CBSB,U  Button B pressed?
+         ldb   YT.CBSB,U  Button B pressed?
          beq   SETSTOP3   No, skip ahead
          ldd   #S$Wake    Flag WAKE signal
          std   RECDSGNL
          lbra  SETTOP13
 
-SETSTOP3 ldb   PT.CBSA,U  Button A pressed?
+SETSTOP3 ldb   YT.CBSA,U  Button A pressed?
          beq   SETSTOP4   No, skip ahead
          ldd   14,S       Button B pressed - do this?
          pshs  D
@@ -5569,7 +5569,7 @@
          bra   SETSTOP2
 
 * Button A pressed when positioning window
-SETSTOP4 ldd   PT.ACX,U   Get current X coord of mouse
+SETSTOP4 ldd   YT.ACX,U   Get current X coord of mouse
          std   6,S        Save it
          ldd   PROCWTYP   Get window type
          lbsr  COLS4080   40 or 80 column?
@@ -5581,7 +5581,7 @@
 SETSTOP5 ldd   6,S        Get X coord of mouse
          andb  #%11111000 Make it evenly divisible by 8
          std   6,S        Save new X coord
-         ldd   PT.ACY,U   Get current mouse Y coord
+         ldd   YT.ACY,U   Get current mouse Y coord
          andb  #%11111000 Make it evenly divisible by 8
          std   4,S        Save it
          ldd   6,S        Get X coord
@@ -5716,11 +5716,11 @@
          ldd   WPOSGOOD
          beq   SETSBOT2
          ldx   12,S
-         ldb   PT.CBSA,X
+         ldb   YT.CBSA,X
          bne   SETSBOT1
 
 SETSBOT2 ldx   12,S       Get ptr to mouse packet
-         ldd   PT.ACX,X   Get current mouse X coord
+         ldd   YT.ACX,X   Get current mouse X coord
          std   10,S       Save it
          ldd   PROCWTYP   Get new process' window type 
          lbsr  COLS4080   Check if 40 or 80 column
@@ -5734,7 +5734,7 @@
          lbsr  RNDUPTO8   Round up to nearest 8 pixel boundary
          std   10+2,S     Save it again
          ldx   12+2,S     Get mouse packet ptr again
-         ldd   PT.ACY,X   Get mouse Y coord
+         ldd   YT.ACY,X   Get mouse Y coord
          std   ,S         Save it
          lbsr  RNDUPTO8   Round it up to nearest 8 pixel boundary
          leas  2,S        Eat temp stack
@@ -5810,7 +5810,7 @@
          leas  2,S
 
 SETBOT11 ldx   12,S
-         ldb   PT.CBSA,X
+         ldb   YT.CBSA,X
          lbeq  SETSBOT1
          ldd   WPOSGOOD
          lbne  SETSBOT1
@@ -5836,9 +5836,9 @@
 STOPSIGN pshs  U
          ldd   #1
          std   WPOSGOOD
-         ldb   #PTR.ILL
+         ldb   #YTR.ILL
          pshs  D
-         ldx   #GRP.PTR
+         ldx   #QRP.PTR
          ldd   8-2,S
          pshs  D,X
          lbsr  GCSET
@@ -6615,7 +6615,7 @@
 DEFTYPE  fcc   "DEFTYPE="
 DEFTPEND fcb   NUL
 
-MONITOR  fcc   "MONTYPE="
+QONITOR  fcc   "MONTYPE="
 MONTEND  fcb   NUL
 
 * Added by LCB 12/24/1998 - Check for Default screen type=6,7,8
@@ -6634,11 +6634,11 @@
 DefEx    lbra  PROCENV4   Done processing current line
 
 * Added by LCB 04/15/1999 - set monitor type
-MonCheck ldb   #MONTEND-MONITOR Check for monitor type
-         leax  <MONITOR,pc
+MonCheck ldb   #MONTEND-QONITOR Check for monitor type
+         leax  <QONITOR,pc
          lbsr  PROCLINE
          bne   MousChk1   No, try next
-         leau  MONTEND-MONITOR,u Point to after MONTYPE=
+         leau  MONTEND-QONITOR,u Point to after MONTYPE=
          ldb   ,u         Get monitor type
          subb  #$30       Adjust to binary
          cmpb  #2         Above 2, ignore
@@ -6831,8 +6831,8 @@
          bra   GFXWR2
 
 * Change gfx cursor to arrow
-CRSRAROW lda   #GRP.PTR
-         ldb   #PTR.ARR
+CRSRAROW lda   #QRP.PTR
+         ldb   #YTR.ARR
          bra   GCSET.2
 
 GCSETOFF clra  
@@ -6993,7 +6993,7 @@
          ldb   <WNDWPATH+1
          pshs  d,X
          lbsr  OWSET      Overlay window
-         ldd   #WT.DBOX
+         ldd   #ZT.DBOX
          std   2,S
          lbsr  ST.WNSET   Double boxed window
          lbsr  IOOPTSON
@@ -7070,26 +7070,26 @@
 
 ENFREFLD ldb   3,S
 * Enable/Disable FREE, FOLDER & SORT on DISK menu
-ENFREFL1 stb   ITM.FREE+MI.ENBL
-         stb   ITM.FLDR+MI.ENBL
-         stb   ITM.SORT+MI.ENBL
+ENFREFL1 stb   ITM.FREE+QI.ENBL
+         stb   ITM.FLDR+QI.ENBL
+         stb   ITM.SORT+QI.ENBL
          rts   
 
 * Enable/Disable OPEN item on FILES menu
 ENBLOPEN ldb   3,S
-         stb   ITM.OPEN+MI.ENBL
+         stb   ITM.OPEN+QI.ENBL
          rts   
 
 * Enable/Disable LIST & PRINT items on FILES menu. When we add DUMP, it should be here too.
 ENLSTPRT ldb   3,S
-         stb   ITM.LIST+MI.ENBL
-         stb   ITM.PRNT+MI.ENBL
-         stb   ITM.DUMP+MI.ENBL
+         stb   ITM.LIST+QI.ENBL
+         stb   ITM.PRNT+QI.ENBL
+         stb   ITM.DUMP+QI.ENBL
          rts   
 
 * Enable/Disable COPY item on FILES menu
 ENBLCOPY ldd   2,S        Get item On/Off flag (6809/6309-only needs B)
-         stb   ITM.COPY+MI.ENBL (En/Dis)able COPY
+         stb   ITM.COPY+QI.ENBL (En/Dis)able COPY
          pshs  d          Save item on/off flag for sub (could leave original)
          bsr   ENSTRNDL   Deal with 3 other menu items
 ENBLSOFX leas  2,S
@@ -7097,9 +7097,9 @@
 
 * Enable/Disable STAT, RENAME & DELETE items on FILES menu
 ENSTRNDL ldb   3,S        Get item On/Off flag (6809/6309-only needs B)
-         stb   ITM.STAT+MI.ENBL  (En/Dis)able STAT
-         stb   ITM.RNAM+MI.ENBL  (En/Dis)able RENAME
-         stb   ITM.DELT+MI.ENBL  (En/Dis)able DELETE
+         stb   ITM.STAT+QI.ENBL  (En/Dis)able STAT
+         stb   ITM.RNAM+QI.ENBL  (En/Dis)able RENAME
+         stb   ITM.DELT+QI.ENBL  (En/Dis)able DELETE
          rts   
 
 INITSCRN bsr   FULLSCRN   Change working area to everything but menu/scroll bars
@@ -7168,11 +7168,11 @@
 
 *  Should flag to NOT do this if still in same dir.
 
-         ldd   #FNT.G8X8  8x8 graphic font
+         ldd   #YNT.G8X8  8x8 graphic font
 
          std   4,S
 
-         ldb   #GRP.FNT
+         ldb   #QRP.FNT
 
          std   2,S
 
@@ -7200,11 +7200,11 @@
 
          lbsr  WBOX.BAR   Draw dir entry close box, and bars all the way across
 
-         ldb   #FNT.S8X8  Select 8x8 text font
+         ldb   #YNT.S8X8  Select 8x8 text font
 
          std   4,S
 
-         ldb   #GRP.FNT
+         ldb   #QRP.FNT
 
          std   2,S
 
@@ -7220,11 +7220,11 @@
 
          lbsr  I.WRITE
 
-         ldb   #FNT.S6X8  6x8 text font
+         ldb   #YNT.S6X8  6x8 text font
 
          std   4,S
 
-         ldb   #GRP.FNT
+         ldb   #QRP.FNT
 
          std   2,S
 
@@ -8654,7 +8654,7 @@
 
 *        2-3,s   =Window path (only use B)
 
-*        4-5,s   =window type (WT.*)
+*        4-5,s   =window type (ZT.*)
 
 *        6-7,s   =Ptr to window/menu data (for framed windows only)
 
@@ -9796,7 +9796,7 @@
          fcc   "Tandy"
          fcb   NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
          fcb   NUL,NUL
-         fcb   MID.TDY
+         fcb   YID.TDY
          fcb   8,8,1
          fdb   $0000
          fdb   TNDYITMS
@@ -9805,7 +9805,7 @@
          fcc   "Files"
          fcb   NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
          fcb   NUL,NUL
-         fcb   MID.FIL
+         fcb   YID.FIL
 * Now 10 menu items when DUMP added
          fcb   6,10,1     6 chars wide, 10 items, 1=enabled
          fdb   $0000      Reserved
@@ -9815,7 +9815,7 @@
          fcc   "Disk"
          fcb   NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
          fcb   NUL,NUL,NUL
-         fcb   MID.DSK
+         fcb   YID.DSK
          fcb   12,6,1
          fdb   $0000
          fdb   DISKITMS
@@ -9824,7 +9824,7 @@
          fcc   "View"
          fcb   NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
          fcb   NUL,NUL,NUL
-         fcb   MID.VEW
+         fcb   YID.VEW
          fcb   13,3,1
          fdb   $0000
          fdb   VIEWITMS
@@ -9832,7 +9832,7 @@
 * KDMDESC
          fcc   "About.."
          fcb   NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
-         fcb   MID.KDM
+         fcb   YID.KDM
          fcb   9,2,1
          fdb   $0000
          fdb   KDMITMS

EOF
