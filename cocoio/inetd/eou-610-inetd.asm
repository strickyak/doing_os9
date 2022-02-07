         nam   inetd
         ttl   program module       

* Some opcodes disassembled by Strick 2022/02/06
* Disassembled 2014/05/23 18:54:21 by Disasm v1.5 (C) 1988 by RML

H6309 equ 0

         ifp1
         use   /dd/defs/os9defs
         endc
tylg     set   Prgrm+Objct   
atrv     set   ReEnt+rev
rev      set   $00

			org 0
         mod   eom,name,tylg,atrv,start,size
u0000    rmb   983
size     equ   .
         fcb   $20 
SlashN   fcs   "/N"

         fcb   $30 0
         fcb   $C9 I
         fcb   $00 
         fcb   $00 
         fcb   $C6 F
         fcb   $00 
         fcb   $10 
         fcb   $3F ?
         fcb   $8D 
         fcb   $39 9
         fcb   $30 0
         fcb   $C9 I
         fcb   $00 
         fcb   $00 
         fcb   $C6 F
         fcb   $00 
         fcb   $10 
         fcb   $3F ?
         fcb   $8E 
         fcb   $39 9
         fcb   $34 4
         fcb   $12 
         fcb   $8D 
         fcb   $E8 h
         fcb   $25 %
         fcb   $49 I
         fcb   $C6 F
         fcb   $01 
         fcb   $E7 g
         fcb   $89 
         fcb   $00 
         fcb   $04 
         fcb   $8D 
         fcb   $E8 h
         fcb   $35 5
         fcb   $92 
         fcb   $34 4
         fcb   $12 
         fcb   $8D 
         fcb   $D8 X
         fcb   $25 %
         fcb   $39 9
         fcb   $6F o
         fcb   $89 
         fcb   $00 
         fcb   $04 
         fcb   $8D 
         fcb   $DA Z
         fcb   $35 5
         fcb   $92 
         fcb   $34 4
         fcb   $12 
         fcb   $8D 
         fcb   $CA J
         fcb   $25 %
         fcb   $2B +
         fcb   $C6 F
         fcb   $01 
         fcb   $E7 g
         fcb   $89 
         fcb   $00 
         fcb   $05 
         fcb   $8D 
         fcb   $CA J
         fcb   $35 5
         fcb   $92 
         fcb   $34 4
         fcb   $12 
         fcb   $8D 
         fcb   $BA :
         fcb   $25 %
         fcb   $1B 
         fcb   $6F o
         fcb   $89 
         fcb   $00 
         fcb   $05 
         fcb   $8D 
         fcb   $BC <
         fcb   $35 5
         fcb   $92 
         fcb   $34 4
         fcb   $12 
         fcb   $8D 
         fcb   $AC ,
         fcb   $25 %
         fcb   $0D 
         fcb   $30 0
         fcb   $89 
         fcb   $00 
         fcb   $01 
         fcb   $C6 F
         fcb   $10 
         fcb   $6F o
         fcb   $80 
         fcb   $5A Z
         fcb   $2A *
         fcb   $FB 
         fcb   $8D 
         fcb   $A7 '
         fcb   $35 5
         fcb   $92 
L0075    pshs  y,x

         lda   #$03

         leax  SlashN,pcr


         os9   I$Open


         bcs   L0085 

         fcb   $8D 
         fcb   $B1 1
         fcb   $8D 
         fcb   $CD M
L0085    puls  pc,y,x

         fcb   $34 4
         fcb   $32 2
         fcb   $30 0
         fcb   $8D 
         fcb   $00 
         fcb   $C6 F
         fcb   $10 
         fcb   $8E 
         fcb   $00 
         fcb   $09 
         fcb   $10 
         fcb   $3F ?
         fcb   $8A 
         fcb   $10 
         fcb   $25 %
         fcb   $00 
         fcb   $6D m
         fcb   $20 
         fcb   $39 9
         fcb   $34 4
         fcb   $32 2
         fcb   $30 0
         fcb   $8D 
         fcb   $00 
         fcb   $AA *
         fcb   $10 
         fcb   $8E 
         fcb   $00 
         fcb   $09 
         fcb   $10 
         fcb   $3F ?
         fcb   $8A 
         fcb   $10 
         fcb   $25 %
         fcb   $00 
         fcb   $5A Z
         fcb   $20 
         fcb   $26 &
         fcb   $34 4
         fcb   $32 2
         fcb   $30 0
         fcb   $8D 
         fcb   $00 
         fcb   $80 
         fcb   $10 
         fcb   $8E 
         fcb   $00 
         fcb   $0C 
         fcb   $10 
         fcb   $3F ?
         fcb   $8A 
         fcb   $25 %
         fcb   $49 I
         fcb   $AE .
         fcb   $61 a
         fcb   $17 
         fcb   $06 
         fcb   $22 "
         fcb   $1F 
         fcb   $02 
         fcb   $A6 &
         fcb   $E4 d
         fcb   $10 
         fcb   $3F ?
         fcb   $8A 
         fcb   $30 0
         fcb   $8D 
         fcb   $FF 
         fcb   $41 A
         fcb   $10 
         fcb   $8E 
         fcb   $00 
         fcb   $01 
         fcb   $10 
         fcb   $3F ?
         fcb   $8A 
         fcb   $AE .
         fcb   $63 c
         fcb   $34 4
         fcb   $02 
         fcb   $17 
         fcb   $06 
         fcb   $09 
         fcb   $1F 
         fcb   $02 
         fcb   $35 5
         fcb   $02 
         fcb   $10 
         fcb   $3F ?
         fcb   $8A 
         fcb   $30 0
         fcb   $8D 
         fcb   $00 
         fcb   $22 "
         fcb   $10 
         fcb   $8E 
         fcb   $00 
         fcb   $01 
         fcb   $10 
         fcb   $3F ?
         fcb   $8C 
         fcb   $30 0
         fcb   $C9 I
         fcb   $00 
         fcb   $00 
         fcb   $10 
         fcb   $8E 
         fcb   $00 
         fcb   $80 
         fcb   $10 
         fcb   $3F ?
         fcb   $8B 
         fcb   $25 %
         fcb   $0C 
         fcb   $A6 &
         fcb   $84 
         fcb   $81 
         fcb   $46 F
         fcb   $26 &
         fcb   $06 
         fcb   $30 0
         fcb   $05 
         fcb   $17 
         fcb   $04 
         fcb   $F1 q
         fcb   $43 C
         fcb   $35 5
         fcb   $B2 2
         fcb   $0D 
         fcb   $34 4
         fcb   $32 2
         fcb   $30 0
         fcb   $8D 
         fcb   $00 
         fcb   $31 1
         fcb   $10 
         fcb   $8E 
         fcb   $00 
         fcb   $0B 
         fcb   $10 
         fcb   $3F ?
         fcb   $8A 
         fcb   $25 %
         fcb   $EE n
         fcb   $AE .
         fcb   $61 a
         fcb   $17 
         fcb   $05 
         fcb   $C7 G
         fcb   $1F 
         fcb   $02 
         fcb   $A6 &
         fcb   $E4 d
         fcb   $10 
         fcb   $3F ?
         fcb   $8A 
         fcb   $30 0
         fcb   $8C 
         fcb   $E1 a
         fcb   $10 
         fcb   $8E 
         fcb   $00 
         fcb   $01 
         fcb   $10 
         fcb   $3F ?
         fcb   $8C 
         fcb   $20 
         fcb   $BD =
         fcb   $10 
         fcb   $3F ?
         fcb   $8F 
         fcb   $39 9
         fcb   $74 t
         fcb   $63 c
         fcb   $70 p
         fcb   $20 
         fcb   $63 c
         fcb   $6F o
         fcb   $6E n
         fcb   $6E n
         fcb   $65 e
         fcb   $63 c
         fcb   $74 t
         fcb   $20 
         fcb   $74 t
         fcb   $63 c
         fcb   $70 p
         fcb   $20 
         fcb   $6C l
         fcb   $69 i
         fcb   $73 s
         fcb   $74 t
         fcb   $65 e
         fcb   $6E n
         fcb   $20 
         fcb   $74 t
         fcb   $63 c
         fcb   $70 p
         fcb   $20 
         fcb   $6A j
         fcb   $6F o
         fcb   $69 i
         fcb   $6E n
         fcb   $20 
         fcb   $74 t
         fcb   $63 c
         fcb   $70 p
         fcb   $20 
         fcb   $6B k
         fcb   $69 i
         fcb   $6C l
         fcb   $6C l
         fcb   $20 
         fcb   $74 t
         fcb   $6D m
         fcb   $6F o
         fcb   $64 d
         fcb   $E5 e
Ltrap         fcb   $C1 A
         fcb   $02 
         fcb   $26 &
         fcb   $04 
         fcb   $6C l
         fcb   $C9 I
         fcb   $00 
         fcb   $82 
         fcb   $3B ;
start    leax  Ltrap,pcr 


         os9  F$Icpt


         clr   $0082,u



         leax  $0083,u
         
        
       
         stx   $0183,u



         ldd   #$0100


         leas  -32,s

         
         tfr   s,x

         os9   I$GetStt


         bcs   $0190

         clr   >$0007,x
         
        
       
         os9  I$SetStt
         
        
         leas  $20,s


         lbsr  L0075

         
         lbcs  Lexit


*         fcb   $63 c
         fcb   $A7 '
         fcb   $C9 I
         fcb   $01 
         fcb   $8B 
         fcb   $30 0
         fcb   $8D 
         fcb   $01 
         fcb   $D4 T
         fcb   $17 
         fcb   $01 
         fcb   $5B [
         fcb   $10 
         fcb   $25 %
         fcb   $01 
         fcb   $54 T
         fcb   $17 
         fcb   $05 
         fcb   $5E ^
         fcb   $47 G
         fcb   $6F o
         fcb   $74 t
         fcb   $20 
         fcb   $6E n
         fcb   $65 e
         fcb   $74 t
         fcb   $70 p
         fcb   $61 a
         fcb   $74 t
         fcb   $68 h
         fcb   $20 
         fcb   $61 a
         fcb   $6E n
         fcb   $64 d
         fcb   $20 
         fcb   $73 s
         fcb   $65 e
         fcb   $74 t
         fcb   $75 u
         fcb   $70 p
         fcb   $20 
         fcb   $70 p
         fcb   $6F o
         fcb   $72 r
         fcb   $74 t
         fcb   $73 s
         fcb   $0D 
         fcb   $00 
         fcb   $17 
         fcb   $05 
         fcb   $3E >
         fcb   $53 S
         fcb   $53 S
         fcb   $2E .
         fcb   $53 S
         fcb   $53 S
         fcb   $69 i
         fcb   $67 g
         fcb   $20 
         fcb   $6F o
         fcb   $6E n
         fcb   $20 
         fcb   $4E N
         fcb   $65 e
         fcb   $74 t
         fcb   $50 P
         fcb   $61 a
         fcb   $74 t
         fcb   $68 h
         fcb   $0D 
         fcb   $00 
         fcb   $A6 &
         fcb   $C9 I
         fcb   $01 
         fcb   $8B 
         fcb   $C6 F
         fcb   $1A 
         fcb   $8E 
         fcb   $00 
         fcb   $02 
         fcb   $10 
         fcb   $3F ?
         fcb   $8E 
         fcb   $10 
         fcb   $25 %
         fcb   $01 
         fcb   $0D 
         fcb   $34 4
         fcb   $01 
         fcb   $1A 
         fcb   $50 P
         fcb   $6D m
         fcb   $C9 I
         fcb   $00 
         fcb   $82 
         fcb   $26 &
         fcb   $13 
         fcb   $10 
         fcb   $3F ?
         fcb   $04 
         fcb   $24 $
         fcb   $0A 
         fcb   $C1 A
         fcb   $E2 b
         fcb   $26 &
         fcb   $06 
         fcb   $8E 
         fcb   $00 
         fcb   $00 
         fcb   $10 
         fcb   $3F ?
         fcb   $0A 
         fcb   $35 5
         fcb   $01 
         fcb   $20 
         fcb   $BC <
         fcb   $35 5
         fcb   $01 
         fcb   $6A j
         fcb   $C9 I
         fcb   $00 
         fcb   $82 
         fcb   $17 
         fcb   $04 
         fcb   $F4 t
         fcb   $52 R
         fcb   $65 e
         fcb   $61 a
         fcb   $64 d
         fcb   $69 i
         fcb   $6E n
         fcb   $67 g
         fcb   $20 
         fcb   $64 d
         fcb   $61 a
         fcb   $74 t
         fcb   $61 a
         fcb   $20 
         fcb   $66 f
         fcb   $72 r
         fcb   $6F o
         fcb   $6D m
         fcb   $20 
         fcb   $6E n
         fcb   $65 e
         fcb   $74 t
         fcb   $70 p
         fcb   $61 a
         fcb   $74 t
         fcb   $68 h
         fcb   $0D 
         fcb   $00 
         fcb   $A6 &
         fcb   $C9 I
         fcb   $01 
         fcb   $8B 
         fcb   $C6 F
         fcb   $01 
         fcb   $10 
         fcb   $3F ?
         fcb   $8D 
         fcb   $25 %
         fcb   $8D 
         fcb   $4F O
         fcb   $1F 
         fcb   $02 
         fcb   $A6 &
         fcb   $C9 I
         fcb   $01 
         fcb   $8B 
         fcb   $AE .
         fcb   $C9 I
         fcb   $01 
         fcb   $83 
         fcb   $10 
         fcb   $3F ?
         fcb   $89 
         fcb   $10 
         fcb   $25 %
         fcb   $00 
         fcb   $AF /
         fcb   $1F 
         fcb   $20 
         fcb   $30 0
         fcb   $8B 
         fcb   $AF /
         fcb   $C9 I
         fcb   $01 
         fcb   $83 
         fcb   $A6 &
         fcb   $1F 
         fcb   $81 
         fcb   $0D 
         fcb   $10 
         fcb   $26 &
         fcb   $FF 
         fcb   $6B k
         fcb   $30 0
         fcb   $C9 I
         fcb   $00 
         fcb   $83 
         fcb   $AF /
         fcb   $C9 I
         fcb   $01 
         fcb   $83 
         fcb   $86 
         fcb   $01 
         fcb   $10 
         fcb   $8E 
         fcb   $01 
         fcb   $00 
         fcb   $10 
         fcb   $3F ?
         fcb   $8C 
         fcb   $A6 &
         fcb   $84 
         fcb   $81 
         fcb   $39 9
         fcb   $2F /
         fcb   $05 
         fcb   $81 
         fcb   $46 F
         fcb   $16 
         fcb   $FF 
         fcb   $4F O
         fcb   $17 
         fcb   $03 
         fcb   $78 x
         fcb   $ED m
         fcb   $C9 I
         fcb   $01 
         fcb   $85 
         fcb   $34 4
         fcb   $06 
         fcb   $17 
         fcb   $04 
         fcb   $84 
         fcb   $47 G
         fcb   $6F o
         fcb   $74 t
         fcb   $20 
         fcb   $74 t
         fcb   $6F o
         fcb   $6B k
         fcb   $65 e
         fcb   $6E n
         fcb   $20 
         fcb   $00 
         fcb   $35 5
         fcb   $06 
         fcb   $17 
         fcb   $03 
         fcb   $4F O
         fcb   $17 
         fcb   $04 
         fcb   $71 q
         fcb   $0D 
         fcb   $00 
         fcb   $17 
         fcb   $04 
         fcb   $6C l
         fcb   $54 T
         fcb   $6F o
         fcb   $20 
         fcb   $53 S
         fcb   $70 p
         fcb   $61 a
         fcb   $63 c
         fcb   $65 e
         fcb   $2E .
         fcb   $2E .
         fcb   $2E .
         fcb   $0D 
         fcb   $00 
         fcb   $17 
         fcb   $04 
         fcb   $B5 5
         fcb   $17 
         fcb   $04 
         fcb   $59 Y
         fcb   $54 T
         fcb   $6F o
         fcb   $20 
         fcb   $4E N
         fcb   $6F o
         fcb   $6E n
         fcb   $2D -
         fcb   $53 S
         fcb   $70 p
         fcb   $61 a
         fcb   $63 c
         fcb   $65 e
         fcb   $2E .
         fcb   $2E .
         fcb   $2E .
         fcb   $0D 
         fcb   $00 
         fcb   $17 
         fcb   $04 
         fcb   $AA *
         fcb   $17 
         fcb   $03 
         fcb   $2D -
         fcb   $ED m
         fcb   $C9 I
         fcb   $00 
         fcb   $80 
         fcb   $34 4
         fcb   $06 
         fcb   $17 
         fcb   $04 
         fcb   $39 9
         fcb   $47 G
         fcb   $6F o
         fcb   $74 t
         fcb   $20 
         fcb   $72 r
         fcb   $65 e
         fcb   $71 q
         fcb   $75 u
         fcb   $65 e
         fcb   $73 s
         fcb   $74 t
         fcb   $20 
         fcb   $66 f
         fcb   $6F o
         fcb   $72 r
         fcb   $20 
         fcb   $70 p
         fcb   $6F o
         fcb   $72 r
         fcb   $74 t
         fcb   $20 
         fcb   $00 
         fcb   $EC l
         fcb   $E4 d
         fcb   $17 
         fcb   $02 
         fcb   $F9 y
         fcb   $17 
         fcb   $04 
         fcb   $1B 
         fcb   $0D 
         fcb   $00 
         fcb   $35 5
         fcb   $06 
         fcb   $30 0
         fcb   $8D 
         fcb   $00 
         fcb   $B4 4
         fcb   $17 
         fcb   $00 
         fcb   $06 
         fcb   $16 
         fcb   $FE 
         fcb   $CC L
Lexit    os9   F$Exit


         fcb   $34 4
         fcb   $10 
         fcb   $30 0
         fcb   $8D 
         fcb   $02 
         fcb   $C9 I
         fcb   $86 
         fcb   $01 
         fcb   $10 
         fcb   $3F ?
         fcb   $84 
         fcb   $25 %
         fcb   $67 g
         fcb   $34 4
         fcb   $06 
         fcb   $17 
         fcb   $03 
         fcb   $F8 x
         fcb   $4F O
         fcb   $70 p
         fcb   $65 e
         fcb   $6E n
         fcb   $65 e
         fcb   $64 d
         fcb   $20 
         fcb   $69 i
         fcb   $6E n
         fcb   $65 e
         fcb   $74 t
         fcb   $64 d
         fcb   $2E .
         fcb   $63 c
         fcb   $6F o
         fcb   $6E n
         fcb   $66 f
         fcb   $20 
         fcb   $6F o
         fcb   $6B k
         fcb   $0D 
         fcb   $00 
         fcb   $35 5
         fcb   $06 
         fcb   $30 0
         fcb   $C9 I
         fcb   $01 
         fcb   $03 
         fcb   $10 
         fcb   $8E 
         fcb   $00 
         fcb   $7F ÿ
         fcb   $17 
         fcb   $04 
         fcb   $20 
         fcb   $25 %
         fcb   $31 1
         fcb   $17 
         fcb   $04 
         fcb   $35 5
         fcb   $E6 f
         fcb   $84 
         fcb   $C1 A
         fcb   $0D 
         fcb   $27 '
         fcb   $EA j
         fcb   $C1 A
         fcb   $23 #
         fcb   $27 '
         fcb   $E6 f
         fcb   $34 4
         fcb   $16 
         fcb   $17 
         fcb   $03 
         fcb   $C1 A
         fcb   $52 R
         fcb   $65 e
         fcb   $61 a
         fcb   $64 d
         fcb   $69 i
         fcb   $6E n
         fcb   $67 g
         fcb   $20 
         fcb   $6C l
         fcb   $69 i
         fcb   $6E n
         fcb   $65 e
         fcb   $3A :
         fcb   $20 
         fcb   $00 
         fcb   $AE .
         fcb   $62 b
         fcb   $17 
         fcb   $03 
         fcb   $BE >
         fcb   $35 5
         fcb   $16 
         fcb   $34 4
         fcb   $02 
         fcb   $AD -
         fcb   $F8 x
         fcb   $01 
         fcb   $35 5
         fcb   $02 
         fcb   $24 $
         fcb   $C2 B
         fcb   $C1 A
         fcb   $D3 S
         fcb   $26 &
         fcb   $01 
         fcb   $5F _
         fcb   $34 4
         fcb   $05 
         fcb   $10 
         fcb   $3F ?
         fcb   $8F 
         fcb   $35 5
         fcb   $05 
         fcb   $35 5
         fcb   $90 
         fcb   $17 
         fcb   $02 
         fcb   $7C ü
         fcb   $10 
         fcb   $83 
         fcb   $00 
         fcb   $00 
         fcb   $27 '
         fcb   $29 )
         fcb   $1F 
         fcb   $12 
         fcb   $A6 &
         fcb   $A0 
         fcb   $81 
         fcb   $0D 
         fcb   $27 '
         fcb   $21 !
         fcb   $81 
         fcb   $2C ,
         fcb   $26 &
         fcb   $F6 v
         fcb   $6F o
         fcb   $3F ?
         fcb   $34 4
         fcb   $16 
         fcb   $17 
         fcb   $03 
         fcb   $78 x
         fcb   $53 S
         fcb   $65 e
         fcb   $6E n
         fcb   $64 d
         fcb   $20 
         fcb   $6C l
         fcb   $69 i
         fcb   $73 s
         fcb   $74 t
         fcb   $65 e
         fcb   $6E n
         fcb   $0D 
         fcb   $00 
         fcb   $35 5
         fcb   $16 
         fcb   $A6 &
         fcb   $C9 I
         fcb   $01 
         fcb   $8B 
         fcb   $17 
         fcb   $FD 
         fcb   $60 `
         fcb   $39 9
         fcb   $5F _
         fcb   $39 9
         fcb   $17 
         fcb   $02 
         fcb   $47 G
         fcb   $34 4
         fcb   $06 
         fcb   $17 
         fcb   $03 
         fcb   $57 W
         fcb   $52 R
         fcb   $65 e
         fcb   $61 a
         fcb   $64 d
         fcb   $69 i
         fcb   $6E n
         fcb   $67 g
         fcb   $20 
         fcb   $70 p
         fcb   $6F o
         fcb   $72 r
         fcb   $74 t
         fcb   $20 
         fcb   $00 
         fcb   $EC l
         fcb   $E4 d
         fcb   $17 
         fcb   $02 
         fcb   $1F 
         fcb   $17 
         fcb   $03 
         fcb   $41 A
         fcb   $0D 
         fcb   $00 
         fcb   $17 
         fcb   $03 
         fcb   $3C <
         fcb   $43 C
         fcb   $6F o
         fcb   $6D m
         fcb   $70 p
         fcb   $61 a
         fcb   $72 r
         fcb   $69 i
         fcb   $6E n
         fcb   $67 g
         fcb   $20 
         fcb   $74 t
         fcb   $6F o
         fcb   $20 
         fcb   $70 p
         fcb   $6F o
         fcb   $72 r
         fcb   $74 t
         fcb   $20 
         fcb   $00 
         fcb   $EC l
         fcb   $C9 I
         fcb   $00 
         fcb   $80 
         fcb   $17 
         fcb   $01 
         fcb   $FD 
         fcb   $17 
         fcb   $03 
         fcb   $1F 
         fcb   $0D 
         fcb   $00 
         fcb   $35 5
         fcb   $06 
         fcb   $10 
         fcb   $A3 #
         fcb   $C9 I
         fcb   $00 
         fcb   $80 
         fcb   $10 
         fcb   $26 &
         fcb   $FF 
         fcb   $B1 1
         fcb   $A6 &
         fcb   $A0 
         fcb   $81 
         fcb   $0D 
         fcb   $27 '
         fcb   $AA *
         fcb   $81 
         fcb   $2C ,
         fcb   $26 &
         fcb   $F6 v
         fcb   $1F 
         fcb   $21 !
         fcb   $31 1
         fcb   $C9 I
         fcb   $01 
         fcb   $8C 
         fcb   $A6 &
         fcb   $80 
         fcb   $81 
         fcb   $2C ,
         fcb   $27 '
         fcb   $0A 
         fcb   $81 
         fcb   $0D 
         fcb   $10 
         fcb   $27 '
         fcb   $01 
         fcb   $BA :
         fcb   $A7 '
         fcb   $A0 
         fcb   $20 
         fcb   $F0 p
         fcb   $A6 &
         fcb   $3F ?
         fcb   $8A 
         fcb   $80 
         fcb   $A7 '
         fcb   $3F ?
         fcb   $6F o
         fcb   $C9 I
         fcb   $02 
         fcb   $8C 
         fcb   $31 1
         fcb   $C9 I
         fcb   $02 
         fcb   $0C 
         fcb   $A6 &
         fcb   $80 
         fcb   $A7 '
         fcb   $A0 
         fcb   $81 
         fcb   $2C ,
         fcb   $27 '
         fcb   $04 
         fcb   $81 
         fcb   $0D 
         fcb   $27 '
         fcb   $10 
         fcb   $31 1
         fcb   $C9 I
         fcb   $02 
         fcb   $8D 
         fcb   $A6 &
         fcb   $80 
         fcb   $A7 '
         fcb   $A0 
         fcb   $6C l
         fcb   $C9 I
         fcb   $02 
         fcb   $0C 
         fcb   $81 
         fcb   $0D 
         fcb   $27 '
         fcb   $F4 t
         fcb   $34 4
         fcb   $06 
         fcb   $17 
         fcb   $02 
         fcb   $C3 C
         fcb   $47 G
         fcb   $6F o
         fcb   $74 t
         fcb   $20 
         fcb   $70 p
         fcb   $72 r
         fcb   $6F o
         fcb   $63 c
         fcb   $20 
         fcb   $61 a
         fcb   $6E n
         fcb   $64 d
         fcb   $20 
         fcb   $70 p
         fcb   $61 a
         fcb   $72 r
         fcb   $61 a
         fcb   $6D m
         fcb   $73 s
         fcb   $20 
         fcb   $74 t
         fcb   $6F o
         fcb   $20 
         fcb   $66 f
         fcb   $6F o
         fcb   $72 r
         fcb   $6B k
         fcb   $0D 
         fcb   $00 
         fcb   $35 5
         fcb   $06 
         fcb   $17 
         fcb   $FC 
         fcb   $0C 
         fcb   $24 $
         fcb   $19 
         fcb   $EC l
         fcb   $C9 I
         fcb   $01 
         fcb   $85 
         fcb   $32 2
         fcb   $78 x
         fcb   $30 0
         fcb   $E4 d
         fcb   $17 
         fcb   $02 
         fcb   $0A 
         fcb   $A6 &
         fcb   $C9 I
         fcb   $01 
         fcb   $8B 
         fcb   $1F 
         fcb   $12 
         fcb   $17 
         fcb   $FC 
         fcb   $08 
         fcb   $32 2
         fcb   $68 h
         fcb   $16 
         fcb   $01 
         fcb   $47 G
         fcb   $A7 '
         fcb   $C9 I
         fcb   $01 
         fcb   $8A 
         fcb   $EC l
         fcb   $C9 I
         fcb   $01 
         fcb   $85 
         fcb   $32 2
         fcb   $78 x
         fcb   $30 0
         fcb   $E4 d
         fcb   $17 
         fcb   $01 
         fcb   $ED m
         fcb   $A6 &
         fcb   $C9 I
         fcb   $01 
         fcb   $8A 
         fcb   $1F 
         fcb   $12 
         fcb   $17 
         fcb   $FB 
         fcb   $FE 
         fcb   $32 2
         fcb   $68 h
         fcb   $24 $
         fcb   $06 
         fcb   $10 
         fcb   $3F ?
         fcb   $8F 
         fcb   $16 
         fcb   $01 
         fcb   $25 %
         fcb   $34 4
         fcb   $06 
         fcb   $17 
         fcb   $02 
         fcb   $5F _
         fcb   $54 T
         fcb   $75 u
         fcb   $72 r
         fcb   $6E n
         fcb   $69 i
         fcb   $6E n
         fcb   $67 g
         fcb   $20 
         fcb   $6F o
         fcb   $6E n
         fcb   $20 
         fcb   $50 P
         fcb   $44 D
         fcb   $2E .
         fcb   $45 E
         fcb   $4B K
         fcb   $4F O
         fcb   $20 
         fcb   $61 a
         fcb   $6E n
         fcb   $64 d
         fcb   $20 
         fcb   $50 P
         fcb   $44 D
         fcb   $2E .
         fcb   $41 A
         fcb   $4C L
         fcb   $46 F
         fcb   $0D 
         fcb   $00 
         fcb   $35 5
         fcb   $06 
         fcb   $17 
         fcb   $FB 
         fcb   $56 V
         fcb   $10 
         fcb   $25 %
         fcb   $00 
         fcb   $FC 
         fcb   $17 
         fcb   $FB 
         fcb   $6D m
         fcb   $10 
         fcb   $25 %
         fcb   $00 
         fcb   $F5 u
         fcb   $34 4
         fcb   $06 
         fcb   $17 
         fcb   $02 
         fcb   $2C ,
         fcb   $44 D
         fcb   $75 u
         fcb   $70 p
         fcb   $69 i
         fcb   $6E n
         fcb   $67 g
         fcb   $20 
         fcb   $70 p
         fcb   $61 a
         fcb   $74 t
         fcb   $68 h
         fcb   $73 s
         fcb   $0D 
         fcb   $00 
         fcb   $35 5
         fcb   $06 
         fcb   $4F O
         fcb   $10 
         fcb   $3F ?
         fcb   $82 
         fcb   $10 
         fcb   $25 %
         fcb   $FE 
         fcb   $07 
         fcb   $A7 '
         fcb   $C9 I
         fcb   $01 
         fcb   $87 
         fcb   $86 
         fcb   $01 
         fcb   $10 
         fcb   $3F ?
         fcb   $82 
         fcb   $10 
         fcb   $25 %
         fcb   $FD 
         fcb   $FA z
         fcb   $A7 '
         fcb   $C9 I
         fcb   $01 
         fcb   $88 
         fcb   $86 
         fcb   $02 
         fcb   $10 
         fcb   $3F ?
         fcb   $82 
         fcb   $10 
         fcb   $25 %
         fcb   $FD 
         fcb   $ED m
         fcb   $A7 '
         fcb   $C9 I
         fcb   $01 
         fcb   $89 
         fcb   $4F O
         fcb   $10 
         fcb   $3F ?
         fcb   $8F 
         fcb   $4C L
         fcb   $10 
         fcb   $3F ?
         fcb   $8F 
         fcb   $4C L
         fcb   $10 
         fcb   $3F ?
         fcb   $8F 
         fcb   $A6 &
         fcb   $C9 I
         fcb   $01 
         fcb   $8A 
         fcb   $10 
         fcb   $3F ?
         fcb   $82 
         fcb   $10 
         fcb   $25 %
         fcb   $FD 
         fcb   $D2 R
         fcb   $10 
         fcb   $3F ?
         fcb   $82 
         fcb   $10 
         fcb   $25 %
         fcb   $FD 
         fcb   $CB K
         fcb   $10 
         fcb   $3F ?
         fcb   $82 
         fcb   $10 
         fcb   $25 %
         fcb   $FD 
         fcb   $C4 D
         fcb   $6D m
         fcb   $C9 I
         fcb   $02 
         fcb   $8C 
         fcb   $27 '
         fcb   $19 
         fcb   $34 4
         fcb   $40 @
         fcb   $30 0
         fcb   $8D 
         fcb   $FC 
         fcb   $17 
         fcb   $33 3
         fcb   $C9 I
         fcb   $02 
         fcb   $8D 
         fcb   $86 
         fcb   $01 
         fcb   $5F _
         fcb   $10 
         fcb   $8E 
         fcb   $01 
         fcb   $00 
         fcb   $10 
         fcb   $3F ?
         fcb   $03 
         fcb   $35 5
         fcb   $40 @
         fcb   $10 
         fcb   $3F ?
         fcb   $04 
         fcb   $34 4
         fcb   $40 @
         fcb   $30 0
         fcb   $C9 I
         fcb   $01 
         fcb   $8C 
         fcb   $33 3
         fcb   $C9 I
         fcb   $02 
         fcb   $0C 
         fcb   $86 
         fcb   $01 
         fcb   $5F _
         fcb   $10 
         fcb   $8E 
         fcb   $01 
         fcb   $00 
         fcb   $10 
         fcb   $3F ?
         fcb   $03 
         fcb   $35 5
         fcb   $40 @
         fcb   $4F O
         fcb   $10 
         fcb   $3F ?
         fcb   $8F 
         fcb   $4C L
         fcb   $10 
         fcb   $3F ?
         fcb   $8F 
         fcb   $4C L
         fcb   $10 
         fcb   $3F ?
         fcb   $8F 
         fcb   $A6 &
         fcb   $C9 I
         fcb   $01 
         fcb   $87 
         fcb   $10 
         fcb   $3F ?
         fcb   $82 
         fcb   $10 
         fcb   $25 %
         fcb   $FD 
         fcb   $78 x
         fcb   $A6 &
         fcb   $C9 I
         fcb   $01 
         fcb   $88 
         fcb   $10 
         fcb   $3F ?
         fcb   $82 
         fcb   $10 
         fcb   $25 %
         fcb   $FD 
         fcb   $6D m
         fcb   $A6 &
         fcb   $C9 I
         fcb   $01 
         fcb   $89 
         fcb   $10 
         fcb   $3F ?
         fcb   $82 
         fcb   $10 
         fcb   $25 %
         fcb   $FD 
         fcb   $62 b
         fcb   $A6 &
         fcb   $C9 I
         fcb   $01 
         fcb   $87 
         fcb   $10 
         fcb   $3F ?
         fcb   $8F 
         fcb   $A6 &
         fcb   $C9 I
         fcb   $01 
         fcb   $88 
         fcb   $10 
         fcb   $3F ?
         fcb   $8F 
         fcb   $A6 &
         fcb   $C9 I
         fcb   $01 
         fcb   $89 
         fcb   $10 
         fcb   $3F ?
         fcb   $8F 
         fcb   $A6 &
         fcb   $C9 I
         fcb   $01 
         fcb   $8A 
         fcb   $10 
         fcb   $3F ?
         fcb   $8F 
         fcb   $34 4
         fcb   $06 
         fcb   $17 
         fcb   $01 
         fcb   $4E N
         fcb   $50 P
         fcb   $72 r
         fcb   $6F o
         fcb   $63 c
         fcb   $20 
         fcb   $66 f
         fcb   $6F o
         fcb   $72 r
         fcb   $6B k
         fcb   $65 e
         fcb   $64 d
         fcb   $0D 
         fcb   $00 
         fcb   $35 5
         fcb   $06 
         fcb   $53 S
         fcb   $C6 F
         fcb   $D3 S
         fcb   $39 9
         fcb   $2E .
         fcb   $2E .
         fcb   $2E .
         fcb   $2E .
         fcb   $2E .
         fcb   $2E .
         fcb   $2F /
         fcb   $53 S
         fcb   $59 Y
         fcb   $53 S
         fcb   $2F /
         fcb   $69 i
         fcb   $6E n
         fcb   $65 e
         fcb   $74 t
         fcb   $64 d
         fcb   $2E .
         fcb   $63 c
         fcb   $6F o
         fcb   $6E n
         fcb   $66 f
         fcb   $0D 
         fcb   $34 4
         fcb   $12 
         fcb   $32 2
         fcb   $78 x
         fcb   $1F 
         fcb   $41 A
         fcb   $17 
         fcb   $00 
         fcb   $92 
         fcb   $17 
         fcb   $01 
         fcb   $2A *
         fcb   $32 2
         fcb   $68 h
         fcb   $35 5
         fcb   $92 
         fcb   $4F O
         fcb   $5F _
         fcb   $34 4
         fcb   $16 
         fcb   $32 2
         fcb   $7F ÿ
         fcb   $6F o
         fcb   $C9 I
         fcb   $03 
         fcb   $0D 
         fcb   $E6 f
         fcb   $80 
         fcb   $C1 A
         fcb   $2D -
         fcb   $26 &
         fcb   $06 
         fcb   $E7 g
         fcb   $C9 I
         fcb   $03 
         fcb   $0D 
         fcb   $E6 f
         fcb   $80 
         fcb   $17 
         fcb   $00 
         fcb   $E3 c
         fcb   $26 &
         fcb   $03 
         fcb   $4C L
         fcb   $20 
         fcb   $F6 v
         fcb   $17 
         fcb   $00 
         fcb   $E6 f
         fcb   $26 &
         fcb   $3C <
         fcb   $4D M
         fcb   $27 '
         fcb   $39 9
         fcb   $81 
         fcb   $06 
         fcb   $22 "
         fcb   $35 5
         fcb   $AE .
         fcb   $63 c
         fcb   $34 4
         fcb   $02 
         fcb   $A6 &
         fcb   $84 
         fcb   $81 
         fcb   $2D -
         fcb   $26 &
         fcb   $02 
         fcb   $30 0
         fcb   $01 
         fcb   $86 
         fcb   $05 
         fcb   $A0 
         fcb   $E0 `
         fcb   $48 H
         fcb   $31 1
         fcb   $8D 
         fcb   $00 
         fcb   $A3 #
         fcb   $31 1
         fcb   $A6 &
         fcb   $A6 &
         fcb   $80 
         fcb   $80 
         fcb   $30 0
         fcb   $27 '
         fcb   $0E 
         fcb   $A7 '
         fcb   $E4 d
         fcb   $EC l
         fcb   $61 a
         fcb   $E3 c
         fcb   $A4 $
         fcb   $25 %
         fcb   $10 
         fcb   $6A j
         fcb   $E4 d
         fcb   $26 &
         fcb   $F8 x
         fcb   $ED m
         fcb   $61 a
         fcb   $31 1
         fcb   $22 "
         fcb   $6D m
         fcb   $21 !
         fcb   $26 &
         fcb   $E6 f
         fcb   $6F o
         fcb   $E0 `
         fcb   $20 
         fcb   $06 
         fcb   $6F o
         fcb   $E4 d
         fcb   $6F o
         fcb   $61 a
         fcb   $63 c
         fcb   $E0 `
         fcb   $1F 
         fcb   $12 
         fcb   $35 5
         fcb   $16 
         fcb   $25 %
         fcb   $0D 
         fcb   $6D m
         fcb   $C9 I
         fcb   $03 
         fcb   $0D 
         fcb   $27 '
         fcb   $07 
         fcb   $83 
         fcb   $00 
         fcb   $01 
         fcb   $43 C
         fcb   $53 S
         fcb   $1C 
         fcb   $FE 
         fcb   $39 9
         fcb   $6F o
         fcb   $C9 I
         fcb   $03 
         fcb   $0E 
         fcb   $4D M
         fcb   $2A *
         fcb   $0B 
         fcb   $A7 '
         fcb   $C9 I
         fcb   $03 
         fcb   $0E 
         fcb   $53 S
         fcb   $43 C
         fcb   $C3 C
         fcb   $00 
         fcb   $01 
         fcb   $20 
         fcb   $04 
         fcb   $6F o
         fcb   $C9 I
         fcb   $03 
         fcb   $0E 
         fcb   $34 4
         fcb   $36 6
         fcb   $86 
         fcb   $07 
         fcb   $6F o
         fcb   $80 
         fcb   $4A J
         fcb   $26 &
         fcb   $FB 
         fcb   $AE .
         fcb   $62 b
         fcb   $EC l
         fcb   $E4 d
         fcb   $26 &
         fcb   $06 
         fcb   $86 
         fcb   $30 0
         fcb   $A7 '
         fcb   $84 
         fcb   $20 
         fcb   $3C <
         fcb   $6D m
         fcb   $C9 I
         fcb   $03 
         fcb   $0E 
         fcb   $27 '
         fcb   $08 
         fcb   $34 4
         fcb   $02 
         fcb   $86 
         fcb   $2D -
         fcb   $A7 '
         fcb   $80 
         fcb   $35 5
         fcb   $02 
         fcb   $31 1
         fcb   $8D 
         fcb   $00 
         fcb   $2C ,
         fcb   $6F o
         fcb   $E3 c
         fcb   $6F o
         fcb   $61 a
         fcb   $A3 #
         fcb   $A4 $
         fcb   $25 %
         fcb   $04 
         fcb   $6C l
         fcb   $61 a
         fcb   $20 
         fcb   $F8 x
         fcb   $E3 c
         fcb   $A4 $
         fcb   $34 4
         fcb   $06 
         fcb   $A6 &
         fcb   $63 c
         fcb   $8B 
         fcb   $30 0
         fcb   $81 
         fcb   $30 0
         fcb   $26 &
         fcb   $04 
         fcb   $6D m
         fcb   $62 b
         fcb   $27 '
         fcb   $04 
         fcb   $6C l
         fcb   $62 b
         fcb   $A7 '
         fcb   $80 
         fcb   $31 1
         fcb   $22 "
         fcb   $6D m
         fcb   $21 !
         fcb   $35 5
         fcb   $06 
         fcb   $26 &
         fcb   $DA Z
         fcb   $32 2
         fcb   $62 b
         fcb   $35 5
         fcb   $B6 6
         fcb   $27 '
         fcb   $10 
         fcb   $03 
         fcb   $E8 h
         fcb   $00 
         fcb   $64 d
         fcb   $00 
         fcb   $0A 
         fcb   $00 
         fcb   $01 
         fcb   $00 
         fcb   $00 
         fcb   $34 4
         fcb   $10 
         fcb   $CC L
         fcb   $FF 
         fcb   $FF 
         fcb   $C3 C
         fcb   $00 
         fcb   $01 
         fcb   $6D m
         fcb   $80 
         fcb   $26 &
         fcb   $F9 y
         fcb   $35 5
         fcb   $90 
         fcb   $C1 A
         fcb   $30 0
         fcb   $25 %
         fcb   $06 
         fcb   $C1 A
         fcb   $39 9
         fcb   $22 "
         fcb   $02 
         fcb   $1A 
         fcb   $04 
         fcb   $39 9
         fcb   $5D ]
         fcb   $27 '
         fcb   $0A 
         fcb   $C1 A
         fcb   $20 
         fcb   $27 '
         fcb   $06 
         fcb   $C1 A
         fcb   $0D 
         fcb   $27 '
         fcb   $02 
         fcb   $C1 A
         fcb   $2C ,
         fcb   $39 9
         fcb   $34 4
         fcb   $50 P
         fcb   $AE .
         fcb   $64 d
         fcb   $1F 
         fcb   $13 
         fcb   $6D m
         fcb   $C0 @
         fcb   $26 &
         fcb   $FC 
         fcb   $EF o
         fcb   $64 d
         fcb   $17 
         fcb   $00 
         fcb   $02 
         fcb   $35 5
         fcb   $D0 P
         fcb   $34 4
         fcb   $02 
         fcb   $86 
         fcb   $01 
         fcb   $17 
         fcb   $00 
         fcb   $02 
         fcb   $35 5
         fcb   $82 
         fcb   $34 4
         fcb   $72 r
         fcb   $1F 
         fcb   $13 
         fcb   $34 4
         fcb   $40 @
         fcb   $10 
         fcb   $8E 
         fcb   $FF 
         fcb   $FF 
         fcb   $31 1
         fcb   $21 !
         fcb   $E6 f
         fcb   $C0 @
         fcb   $27 '
         fcb   $06 
         fcb   $C1 A
         fcb   $0D 
         fcb   $26 &
         fcb   $F6 v
         fcb   $31 1
         fcb   $21 !
         fcb   $35 5
         fcb   $10 
         fcb   $10 
         fcb   $3F ?
         fcb   $8C 
         fcb   $25 %
         fcb   $04 
         fcb   $6D m
         fcb   $5F _
         fcb   $26 &
         fcb   $E3 c
         fcb   $35 5
         fcb   $F2 r
         fcb   $34 4
         fcb   $16 
         fcb   $8D 
         fcb   $0A 
         fcb   $25 %
         fcb   $06 
         fcb   $1F 
         fcb   $20 
         fcb   $30 0
         fcb   $1F 
         fcb   $6F o
         fcb   $8B 
         fcb   $35 5
         fcb   $96 
         fcb   $34 4
         fcb   $12 
         fcb   $10 
         fcb   $3F ?
         fcb   $8B 
         fcb   $25 %
         fcb   $05 
         fcb   $1F 
         fcb   $20 
         fcb   $6F o
         fcb   $8B 
         fcb   $5F _
         fcb   $35 5
         fcb   $92 
         fcb   $34 4
         fcb   $04 
         fcb   $E6 f
         fcb   $80 
         fcb   $C1 A
         fcb   $20 
         fcb   $26 &
         fcb   $FA z
         fcb   $30 0
         fcb   $1F 
         fcb   $35 5
         fcb   $84 
         fcb   $E6 f
         fcb   $80 
         fcb   $C1 A
         fcb   $20 
         fcb   $27 '
         fcb   $FA z
         fcb   $30 0
         fcb   $1F 
         fcb   $39 9
name     equ   *
         fcs   /inetd/
         fcb   $03 
         emod
eom      equ   *
         end
