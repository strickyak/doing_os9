                      (          xyz.asm):00001         *** Generated Code (by wrap_ncl.py)
                      (          xyz.asm):00002             nam NCL
                      (          xyz.asm):00003             ttl NCL
                      (          xyz.asm):00004         
     0006             (          xyz.asm):00005         F_Exit          equ     $06     ; Terminate Process
     000A             (          xyz.asm):00006         F_Sleep         equ     $0A     ; Suspend Process
     008A             (          xyz.asm):00007         I_Write         equ     $8A     ; Write Data
     008B             (          xyz.asm):00008         I_ReadLn        equ     $8B     ; Read Line of ASCII Data
     008C             (          xyz.asm):00009         I_WritLn        equ     $8C     ; Write Line of ASCII Data
                      (          xyz.asm):00010         
     0010             (          xyz.asm):00011         Prgrm          EQU       $10                 Program Module
     0001             (          xyz.asm):00012         Objct          EQU       1                   6809 Object Code Module
     0080             (          xyz.asm):00013         ReEnt          EQU       %10000000           Re-Entrant Module
                      (          xyz.asm):00014         
     0011             (          xyz.asm):00015         tylg     set   Prgrm+Objct
     0080             (          xyz.asm):00016         atrv     set   ReEnt+rev
     0000             (          xyz.asm):00017         rev      set   $00
     0001             (          xyz.asm):00018         edition  set   1
                      (          xyz.asm):00019         
0000 87CD2ED7000D1180 (          xyz.asm):00020             mod   eom,name,tylg,atrv,start,$8000
     D000118000
000D                  (          xyz.asm):00021         name
000D 4E43CC           (          xyz.asm):00022             fcs /NCL/
0010 01               (          xyz.asm):00023             fcb edition
0011                  (          xyz.asm):00024         start
0011 3460             (          xyz.asm):00025             pshs Y,U   ; Not worrying about args yet, but there is Y.
                      (          xyz.asm):00026         
                      (          xyz.asm):00027         * Need to clear from U to SP.    
                      (          xyz.asm):00028         * How many bytes?   SP - U.
0013 1F40             (          xyz.asm):00029             tfr s,d    ; start with SP
0015 A362             (          xyz.asm):00030             subd 2,s    ; subtract pushed U
0017 1F01             (          xyz.asm):00031             tfr d,x   ; counter in X
0019 C600             (          xyz.asm):00032             ldb #0
001B E7C0             (          xyz.asm):00033         ClearLoop stb ,u+
001D 301F             (          xyz.asm):00034             leax -1,x
001F 26FA             (          xyz.asm):00035             bne ClearLoop
                      (          xyz.asm):00036         
0021 3560             (          xyz.asm):00037             puls Y,U   ; Not worrying about args yet, but there is Y.
0023 1F32             (          xyz.asm):00038             tfr u,y  ; With cmoc, Y points to the start of global memory.
0025 CE0000           (          xyz.asm):00039             ldu #0   ; NULL initial frame pointer.
0028 3440             (          xyz.asm):00040             pshs U
002A 3440             (          xyz.asm):00041             pshs U
002C 3440             (          xyz.asm):00042             pshs U
002E 3440             (          xyz.asm):00043             pshs U
0030 170733           (          xyz.asm):00044             lbsr _main
0033 103F06           (          xyz.asm):00045             os9 F_Exit
                      (          xyz.asm):00046         
                      (          xyz.asm):00047             org 0                  ; start of global variables.
0000.                 (          xyz.asm):00048         __unused__   RMB 2   ; Never put things at address 0.
                      (          xyz.asm):00049         
                      (          xyz.asm):00050         * ;;;;;;;;;;;;;;; bss
                      (          xyz.asm):00051         
                      (          xyz.asm):00052         
                      (          xyz.asm):00053         
                      (          xyz.asm):00054         * Uninitialized globals
     0002             (          xyz.asm):00055         bss_start       EQU     .
     0002             (          xyz.asm):00056         _ram_used       EQU     .
0002.                 (          xyz.asm):00057                 RMB     2               ram_used
     0004             (          xyz.asm):00058         _ram_roots      EQU     .
0004.                 (          xyz.asm):00059                 RMB     24              ram_roots
     001C             (          xyz.asm):00060         _ram    EQU     .
001C.                 (          xyz.asm):00061                 RMB     12000           ram
     2EFC             (          xyz.asm):00062         bss_end EQU     .
                      (          xyz.asm):00063         
                      (          xyz.asm):00064         
                      (          xyz.asm):00065         
                      (          xyz.asm):00066         
                      (          xyz.asm):00067         
                      (          xyz.asm):00068         
                      (          xyz.asm):00069         *******************************************************************************
                      (          xyz.asm):00070         
                      (          xyz.asm):00071         * FUNCTION AppendBuf(): defined at xyz.c:1075
     0036             (          xyz.asm):00072         _AppendBuf      EQU     *
0036 3440             (          xyz.asm):00073                 PSHS    U
0038 172A11           (          xyz.asm):00074                 LBSR    _stkcheck
003B FFC0             (          xyz.asm):00075                 FDB     -64             argument for _stkcheck
003D 33E4             (          xyz.asm):00076                 LEAU    ,S
                      (          xyz.asm):00077         * Formal parameters and locals:
                      (          xyz.asm):00078         *   buf: char *; 2 bytes at 4,U
                      (          xyz.asm):00079         *   buflen: int; 2 bytes at 6,U
                      (          xyz.asm):00080         *   x: char; 1 byte at 9,U
                      (          xyz.asm):00081         * Line xyz.c:1076: assignment: =
                      (          xyz.asm):00082         * Line xyz.c:1076: function call: realloc()
003F EC46             (          xyz.asm):00083                 LDD     6,U             variable buflen
0041 C30002           (          xyz.asm):00084                 ADDD    #$02            2
0044 3406             (          xyz.asm):00085                 PSHS    B,A             argument 2 of realloc(): int
0046 EC44             (          xyz.asm):00086                 LDD     4,U             variable buf, declared at xyz.c:1075
0048 3406             (          xyz.asm):00087                 PSHS    B,A             argument 1 of realloc(): void *
004A 172812           (          xyz.asm):00088                 LBSR    _realloc
004D 3264             (          xyz.asm):00089                 LEAS    4,S
004F ED44             (          xyz.asm):00090                 STD     4,U
                      (          xyz.asm):00091         * Line xyz.c:1077: assignment: =
                      (          xyz.asm):00092         * optim: optimize8BitStackOps
                      (          xyz.asm):00093         * optim: optimize8BitStackOps
0051 AE44             (          xyz.asm):00094                 LDX     4,U             pointer buf
0053 EC46             (          xyz.asm):00095                 LDD     6,U             variable buflen
0055 308B             (          xyz.asm):00096                 LEAX    D,X             add byte offset
0057 E649             (          xyz.asm):00097                 LDB     9,U             optim: optimize8BitStackOps
0059 E784             (          xyz.asm):00098                 STB     ,X
                      (          xyz.asm):00099         * Line xyz.c:1078: assignment: =
005B 4F               (          xyz.asm):00100                 CLRA
                      (          xyz.asm):00101         * CLRB  optim: optimizeStackOperations1
                      (          xyz.asm):00102         * PSHS B optim: optimizeStackOperations1
005C AE44             (          xyz.asm):00103                 LDX     4,U             pointer buf
                      (          xyz.asm):00104         * optim: stripExtraPulsX
005E EC46             (          xyz.asm):00105                 LDD     6,U             variable buflen
0060 C30001           (          xyz.asm):00106                 ADDD    #$01            1
                      (          xyz.asm):00107         * optim: stripExtraPulsX
0063 308B             (          xyz.asm):00108                 LEAX    D,X             add byte offset
0065 C600             (          xyz.asm):00109                 LDB     #0              optim: optimizeStackOperations1
0067 E784             (          xyz.asm):00110                 STB     ,X
                      (          xyz.asm):00111         * Line xyz.c:1079: return with value
0069 EC44             (          xyz.asm):00112                 LDD     4,U             variable buf, declared at xyz.c:1075
                      (          xyz.asm):00113         * optim: branchToNextLocation
                      (          xyz.asm):00114         * Useless label L00068 removed
006B 32C4             (          xyz.asm):00115                 LEAS    ,U
006D 35C0             (          xyz.asm):00116                 PULS    U,PC
                      (          xyz.asm):00117         * END FUNCTION AppendBuf(): defined at xyz.c:1075
     006F             (          xyz.asm):00118         funcend_AppendBuf       EQU *
     0039             (          xyz.asm):00119         funcsize_AppendBuf      EQU     funcend_AppendBuf-_AppendBuf
                      (          xyz.asm):00120         
                      (          xyz.asm):00121         
                      (          xyz.asm):00122         *******************************************************************************
                      (          xyz.asm):00123         
                      (          xyz.asm):00124         * FUNCTION AppendVec(): defined at xyz.c:1063
     006F             (          xyz.asm):00125         _AppendVec      EQU     *
006F 3440             (          xyz.asm):00126                 PSHS    U
0071 1729D8           (          xyz.asm):00127                 LBSR    _stkcheck
0074 FFC0             (          xyz.asm):00128                 FDB     -64             argument for _stkcheck
0076 33E4             (          xyz.asm):00129                 LEAU    ,S
                      (          xyz.asm):00130         * Formal parameters and locals:
                      (          xyz.asm):00131         *   vec: char **; 2 bytes at 4,U
                      (          xyz.asm):00132         *   veclen: int; 2 bytes at 6,U
                      (          xyz.asm):00133         *   s: char *; 2 bytes at 8,U
                      (          xyz.asm):00134         * Line xyz.c:1064: assignment: =
                      (          xyz.asm):00135         * Line xyz.c:1064: function call: realloc()
0078 4F               (          xyz.asm):00136                 CLRA
0079 C602             (          xyz.asm):00137                 LDB     #$02            decimal 2 signed
007B 1F01             (          xyz.asm):00138                 TFR     D,X             optim: stripExtraPulsX
007D EC46             (          xyz.asm):00139                 LDD     6,U             variable veclen
007F C30001           (          xyz.asm):00140                 ADDD    #$01            1
                      (          xyz.asm):00141         * optim: stripExtraPulsX
0082 172D7B           (          xyz.asm):00142                 LBSR    MUL16
0085 3406             (          xyz.asm):00143                 PSHS    B,A             argument 2 of realloc(): int
0087 EC44             (          xyz.asm):00144                 LDD     4,U             variable vec, declared at xyz.c:1063
0089 3406             (          xyz.asm):00145                 PSHS    B,A             argument 1 of realloc(): void *
008B 1727D1           (          xyz.asm):00146                 LBSR    _realloc
008E 3264             (          xyz.asm):00147                 LEAS    4,S
0090 ED44             (          xyz.asm):00148                 STD     4,U
                      (          xyz.asm):00149         * Line xyz.c:1065: assignment: =
0092 EC48             (          xyz.asm):00150                 LDD     8,U             variable s, declared at xyz.c:1063
0094 3406             (          xyz.asm):00151                 PSHS    B,A
0096 AE44             (          xyz.asm):00152                 LDX     4,U             pointer vec
0098 EC46             (          xyz.asm):00153                 LDD     6,U             variable veclen
009A 58               (          xyz.asm):00154                 LSLB
009B 49               (          xyz.asm):00155                 ROLA
009C 308B             (          xyz.asm):00156                 LEAX    D,X             add byte offset
009E 3506             (          xyz.asm):00157                 PULS    A,B             retrieve value to store
00A0 ED84             (          xyz.asm):00158                 STD     ,X
                      (          xyz.asm):00159         * Line xyz.c:1066: return with value
00A2 EC44             (          xyz.asm):00160                 LDD     4,U             variable vec, declared at xyz.c:1063
                      (          xyz.asm):00161         * optim: branchToNextLocation
                      (          xyz.asm):00162         * Useless label L00066 removed
00A4 32C4             (          xyz.asm):00163                 LEAS    ,U
00A6 35C0             (          xyz.asm):00164                 PULS    U,PC
                      (          xyz.asm):00165         * END FUNCTION AppendVec(): defined at xyz.c:1063
     00A8             (          xyz.asm):00166         funcend_AppendVec       EQU *
     0039             (          xyz.asm):00167         funcsize_AppendVec      EQU     funcend_AppendVec-_AppendVec
                      (          xyz.asm):00168         
                      (          xyz.asm):00169         
                      (          xyz.asm):00170         *******************************************************************************
                      (          xyz.asm):00171         
                      (          xyz.asm):00172         * FUNCTION Error(): defined at xyz.c:1170
     00A8             (          xyz.asm):00173         _Error  EQU     *
00A8 3440             (          xyz.asm):00174                 PSHS    U
00AA 17299F           (          xyz.asm):00175                 LBSR    _stkcheck
00AD FF80             (          xyz.asm):00176                 FDB     -128            argument for _stkcheck
00AF 33E4             (          xyz.asm):00177                 LEAU    ,S
00B1 32E8C0           (          xyz.asm):00178                 LEAS    -64,S
                      (          xyz.asm):00179         * Formal parameters and locals:
                      (          xyz.asm):00180         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):00181         *   argv0: char *; 2 bytes at 6,U
                      (          xyz.asm):00182         *   err: int; 2 bytes at 8,U
                      (          xyz.asm):00183         *   buf: char[]; 32 bytes at -64,U
                      (          xyz.asm):00184         *   buf2: char[]; 32 bytes at -32,U
                      (          xyz.asm):00185         * Line xyz.c:1172: function call: snprintf_s()
00B4 EC46             (          xyz.asm):00186                 LDD     6,U             variable argv0, declared at xyz.c:1170
00B6 3406             (          xyz.asm):00187                 PSHS    B,A             argument 4 of snprintf_s(): char *
00B8 308D2C68         (          xyz.asm):00188                 LEAX    S00112,PCR      "%s: ERROR %d"
                      (          xyz.asm):00189         * optim: optimizePshsOps
00BC 4F               (          xyz.asm):00190                 CLRA
00BD C620             (          xyz.asm):00191                 LDB     #$20            decimal 32 signed
00BF 3416             (          xyz.asm):00192                 PSHS    X,B,A           optim: optimizePshsOps
00C1 30C8C0           (          xyz.asm):00193                 LEAX    -64,U           address of array buf
00C4 3410             (          xyz.asm):00194                 PSHS    X               argument 1 of snprintf_s(): char[]
00C6 1728A1           (          xyz.asm):00195                 LBSR    _snprintf_s
00C9 3268             (          xyz.asm):00196                 LEAS    8,S
                      (          xyz.asm):00197         * Line xyz.c:1174: function call: snprintf_d()
00CB EC48             (          xyz.asm):00198                 LDD     8,U             variable err, declared at xyz.c:1170
00CD 3406             (          xyz.asm):00199                 PSHS    B,A             argument 4 of snprintf_d(): int
00CF 30C8C0           (          xyz.asm):00200                 LEAX    -64,U           address of array buf
                      (          xyz.asm):00201         * optim: optimizePshsOps
00D2 4F               (          xyz.asm):00202                 CLRA
00D3 C620             (          xyz.asm):00203                 LDB     #$20            decimal 32 signed
00D5 3416             (          xyz.asm):00204                 PSHS    X,B,A           optim: optimizePshsOps
00D7 30C8E0           (          xyz.asm):00205                 LEAX    -32,U           address of array buf2
00DA 3410             (          xyz.asm):00206                 PSHS    X               argument 1 of snprintf_d(): char[]
00DC 1727D5           (          xyz.asm):00207                 LBSR    _snprintf_d
00DF 3268             (          xyz.asm):00208                 LEAS    8,S
                      (          xyz.asm):00209         * Line xyz.c:1175: function call: picolSetResult()
00E1 30C8E0           (          xyz.asm):00210                 LEAX    -32,U           address of array buf2
                      (          xyz.asm):00211         * optim: optimizePshsOps
00E4 EC44             (          xyz.asm):00212                 LDD     4,U             variable i, declared at xyz.c:1170
00E6 3416             (          xyz.asm):00213                 PSHS    X,B,A           optim: optimizePshsOps
00E8 1725D0           (          xyz.asm):00214                 LBSR    _picolSetResult
00EB 3264             (          xyz.asm):00215                 LEAS    4,S
                      (          xyz.asm):00216         * Line xyz.c:1176: return with value
00ED 4F               (          xyz.asm):00217                 CLRA
00EE C601             (          xyz.asm):00218                 LDB     #$01            decimal 1 signed
                      (          xyz.asm):00219         * optim: branchToNextLocation
                      (          xyz.asm):00220         * Useless label L00074 removed
00F0 32C4             (          xyz.asm):00221                 LEAS    ,U
00F2 35C0             (          xyz.asm):00222                 PULS    U,PC
                      (          xyz.asm):00223         * END FUNCTION Error(): defined at xyz.c:1170
     00F4             (          xyz.asm):00224         funcend_Error   EQU *
     004C             (          xyz.asm):00225         funcsize_Error  EQU     funcend_Error-_Error
                      (          xyz.asm):00226         
                      (          xyz.asm):00227         
                      (          xyz.asm):00228         *******************************************************************************
                      (          xyz.asm):00229         
                      (          xyz.asm):00230         * FUNCTION FormList(): defined at xyz.c:1146
     00F4             (          xyz.asm):00231         _FormList       EQU     *
00F4 3440             (          xyz.asm):00232                 PSHS    U
00F6 172953           (          xyz.asm):00233                 LBSR    _stkcheck
00F9 FFB8             (          xyz.asm):00234                 FDB     -72             argument for _stkcheck
00FB 33E4             (          xyz.asm):00235                 LEAU    ,S
00FD 3278             (          xyz.asm):00236                 LEAS    -8,S
                      (          xyz.asm):00237         * Formal parameters and locals:
                      (          xyz.asm):00238         *   argc: int; 2 bytes at 4,U
                      (          xyz.asm):00239         *   argv: char **; 2 bytes at 6,U
                      (          xyz.asm):00240         *   b: char *; 2 bytes at -4,U
                      (          xyz.asm):00241         *   blen: int; 2 bytes at -2,U
                      (          xyz.asm):00242         * Line xyz.c:1147: init of variable b
                      (          xyz.asm):00243         * Line xyz.c:1147: function call: NewBuf()
00FF 17007E           (          xyz.asm):00244                 LBSR    _NewBuf
0102 ED5C             (          xyz.asm):00245                 STD     -4,U            variable b
                      (          xyz.asm):00246         * Line xyz.c:1148: init of variable blen
0104 4F               (          xyz.asm):00247                 CLRA
0105 5F               (          xyz.asm):00248                 CLRB
0106 ED5E             (          xyz.asm):00249                 STD     -2,U            variable blen
                      (          xyz.asm):00250         * Line xyz.c:1149: for init
                      (          xyz.asm):00251         * Line xyz.c:1149: init of variable i
                      (          xyz.asm):00252         * optim: stripExtraClrA_B
                      (          xyz.asm):00253         * optim: stripExtraClrA_B
0108 ED5A             (          xyz.asm):00254                 STD     -6,U            variable i
010A 160064           (          xyz.asm):00255                 LBRA    L00149          jump to for condition
     010D             (          xyz.asm):00256         L00148  EQU     *
                      (          xyz.asm):00257         * Line xyz.c:1149: for body
                      (          xyz.asm):00258         * Line xyz.c:1150: if
010D EC5A             (          xyz.asm):00259                 LDD     -6,U            variable i
010F C30000           (          xyz.asm):00260                 ADDD    #0
0112 2F1D             (          xyz.asm):00261                 BLE     L00153
                      (          xyz.asm):00262         * optim: condBranchOverUncondBranch
                      (          xyz.asm):00263         * Useless label L00152 removed
                      (          xyz.asm):00264         * Line xyz.c:1151: assignment: =
                      (          xyz.asm):00265         * Line xyz.c:1151: function call: AppendBuf()
0114 C620             (          xyz.asm):00266                 LDB     #$20            optim: lddToLDB
0116 1D               (          xyz.asm):00267                 SEX                     promoting byte argument to word
0117 3406             (          xyz.asm):00268                 PSHS    B,A             argument 3 of AppendBuf(): char
0119 EC5E             (          xyz.asm):00269                 LDD     -2,U            variable blen, declared at xyz.c:1148
011B 3406             (          xyz.asm):00270                 PSHS    B,A             argument 2 of AppendBuf(): int
011D EC5C             (          xyz.asm):00271                 LDD     -4,U            variable b, declared at xyz.c:1147
011F 3406             (          xyz.asm):00272                 PSHS    B,A             argument 1 of AppendBuf(): char *
0121 17FF12           (          xyz.asm):00273                 LBSR    _AppendBuf
0124 3266             (          xyz.asm):00274                 LEAS    6,S
0126 ED5C             (          xyz.asm):00275                 STD     -4,U
0128 305E             (          xyz.asm):00276                 LEAX    -2,U            variable blen, declared at xyz.c:1148
012A EC84             (          xyz.asm):00277                 LDD     ,X
012C C30001           (          xyz.asm):00278                 ADDD    #1
012F ED84             (          xyz.asm):00279                 STD     ,X
                      (          xyz.asm):00280         * optim: removeUselessOps
     0131             (          xyz.asm):00281         L00153  EQU     *               else
                      (          xyz.asm):00282         * Useless label L00154 removed
                      (          xyz.asm):00283         * Line xyz.c:1154: init of variable p
0131 AE46             (          xyz.asm):00284                 LDX     6,U             pointer argv
0133 EC5A             (          xyz.asm):00285                 LDD     -6,U            variable i
0135 58               (          xyz.asm):00286                 LSLB
0136 49               (          xyz.asm):00287                 ROLA
                      (          xyz.asm):00288         * optimizeLoadDX
0137 EC8B             (          xyz.asm):00289                 LDD     D,X             get r-value
0139 ED58             (          xyz.asm):00290                 STD     -8,U            variable p
                      (          xyz.asm):00291         * Line xyz.c:1155: while
013B 2028             (          xyz.asm):00292                 BRA     L00156          jump to while condition
     013D             (          xyz.asm):00293         L00155  EQU     *               while body
                      (          xyz.asm):00294         * Line xyz.c:1156: assignment: =
                      (          xyz.asm):00295         * Line xyz.c:1156: function call: AppendBuf()
013D AE58             (          xyz.asm):00296                 LDX     -8,U            get address for indirection of variable p
013F E684             (          xyz.asm):00297                 LDB     ,X              indirection
0141 1D               (          xyz.asm):00298                 SEX                     promoting byte argument to word
0142 3406             (          xyz.asm):00299                 PSHS    B,A             argument 3 of AppendBuf(): char
0144 EC5E             (          xyz.asm):00300                 LDD     -2,U            variable blen, declared at xyz.c:1148
0146 3406             (          xyz.asm):00301                 PSHS    B,A             argument 2 of AppendBuf(): int
0148 EC5C             (          xyz.asm):00302                 LDD     -4,U            variable b, declared at xyz.c:1147
014A 3406             (          xyz.asm):00303                 PSHS    B,A             argument 1 of AppendBuf(): char *
014C 17FEE7           (          xyz.asm):00304                 LBSR    _AppendBuf
014F 3266             (          xyz.asm):00305                 LEAS    6,S
0151 ED5C             (          xyz.asm):00306                 STD     -4,U
0153 305E             (          xyz.asm):00307                 LEAX    -2,U            variable blen, declared at xyz.c:1148
0155 EC84             (          xyz.asm):00308                 LDD     ,X
0157 C30001           (          xyz.asm):00309                 ADDD    #1
015A ED84             (          xyz.asm):00310                 STD     ,X
                      (          xyz.asm):00311         * optim: removeUselessOps
015C 3058             (          xyz.asm):00312                 LEAX    -8,U            variable p, declared at xyz.c:1154
015E EC84             (          xyz.asm):00313                 LDD     ,X
0160 C30001           (          xyz.asm):00314                 ADDD    #1
0163 ED84             (          xyz.asm):00315                 STD     ,X
                      (          xyz.asm):00316         * optim: removeUselessOps
     0165             (          xyz.asm):00317         L00156  EQU     *               while condition at xyz.c:1155
                      (          xyz.asm):00318         * optim: optimizeIndexedX
0165 E6D8F8           (          xyz.asm):00319                 LDB     [-8,U]          optim: optimizeIndexedX
                      (          xyz.asm):00320         * optim: loadCmpZeroBeqOrBne
0168 26D3             (          xyz.asm):00321                 BNE     L00155
                      (          xyz.asm):00322         * optim: branchToNextLocation
                      (          xyz.asm):00323         * Useless label L00157 removed
                      (          xyz.asm):00324         * Useless label L00150 removed
                      (          xyz.asm):00325         * Line xyz.c:1149: for increment(s)
016A EC5A             (          xyz.asm):00326                 LDD     -6,U
016C C30001           (          xyz.asm):00327                 ADDD    #1
016F ED5A             (          xyz.asm):00328                 STD     -6,U
     0171             (          xyz.asm):00329         L00149  EQU     *
                      (          xyz.asm):00330         * Line xyz.c:1149: for condition
0171 EC5A             (          xyz.asm):00331                 LDD     -6,U            variable i
0173 10A344           (          xyz.asm):00332                 CMPD    4,U             variable argc
0176 102DFF93         (          xyz.asm):00333                 LBLT    L00148
                      (          xyz.asm):00334         * optim: branchToNextLocation
                      (          xyz.asm):00335         * Useless label L00151 removed
                      (          xyz.asm):00336         * Line xyz.c:1161: return with value
017A EC5C             (          xyz.asm):00337                 LDD     -4,U            variable b, declared at xyz.c:1147
                      (          xyz.asm):00338         * optim: branchToNextLocation
                      (          xyz.asm):00339         * Useless label L00072 removed
017C 32C4             (          xyz.asm):00340                 LEAS    ,U
017E 35C0             (          xyz.asm):00341                 PULS    U,PC
                      (          xyz.asm):00342         * END FUNCTION FormList(): defined at xyz.c:1146
     0180             (          xyz.asm):00343         funcend_FormList        EQU *
     008C             (          xyz.asm):00344         funcsize_FormList       EQU     funcend_FormList-_FormList
                      (          xyz.asm):00345         
                      (          xyz.asm):00346         
                      (          xyz.asm):00347         *******************************************************************************
                      (          xyz.asm):00348         
                      (          xyz.asm):00349         * FUNCTION NewBuf(): defined at xyz.c:1069
     0180             (          xyz.asm):00350         _NewBuf EQU     *
0180 3440             (          xyz.asm):00351                 PSHS    U
0182 1728C7           (          xyz.asm):00352                 LBSR    _stkcheck
0185 FFBE             (          xyz.asm):00353                 FDB     -66             argument for _stkcheck
0187 33E4             (          xyz.asm):00354                 LEAU    ,S
0189 327E             (          xyz.asm):00355                 LEAS    -2,S
                      (          xyz.asm):00356         * Formal parameters and locals:
                      (          xyz.asm):00357         *   z: char *; 2 bytes at -2,U
                      (          xyz.asm):00358         * Line xyz.c:1070: init of variable z
                      (          xyz.asm):00359         * Line xyz.c:1070: function call: malloc()
018B 4F               (          xyz.asm):00360                 CLRA
018C C601             (          xyz.asm):00361                 LDB     #$01            decimal 1 signed
018E 3406             (          xyz.asm):00362                 PSHS    B,A             argument 1 of malloc(): int
0190 1706B7           (          xyz.asm):00363                 LBSR    _malloc
0193 3262             (          xyz.asm):00364                 LEAS    2,S
0195 ED5E             (          xyz.asm):00365                 STD     -2,U            variable z
                      (          xyz.asm):00366         * Line xyz.c:1071: assignment: =
0197 4F               (          xyz.asm):00367                 CLRA
                      (          xyz.asm):00368         * CLRB  optim: optimizeStackOperations1
                      (          xyz.asm):00369         * PSHS B optim: optimizeStackOperations1
                      (          xyz.asm):00370         * optim: optimizeLdx
0198 C600             (          xyz.asm):00371                 LDB     #0              optim: optimizeStackOperations1
019A E7D8FE           (          xyz.asm):00372                 STB     [-2,U]          optim: optimizeLdx
                      (          xyz.asm):00373         * Line xyz.c:1072: return with value
019D EC5E             (          xyz.asm):00374                 LDD     -2,U            variable z, declared at xyz.c:1070
                      (          xyz.asm):00375         * optim: branchToNextLocation
                      (          xyz.asm):00376         * Useless label L00067 removed
019F 32C4             (          xyz.asm):00377                 LEAS    ,U
01A1 35C0             (          xyz.asm):00378                 PULS    U,PC
                      (          xyz.asm):00379         * END FUNCTION NewBuf(): defined at xyz.c:1069
     01A3             (          xyz.asm):00380         funcend_NewBuf  EQU *
     0023             (          xyz.asm):00381         funcsize_NewBuf EQU     funcend_NewBuf-_NewBuf
                      (          xyz.asm):00382         
                      (          xyz.asm):00383         
                      (          xyz.asm):00384         *******************************************************************************
                      (          xyz.asm):00385         
                      (          xyz.asm):00386         * FUNCTION NewVec(): defined at xyz.c:1059
     01A3             (          xyz.asm):00387         _NewVec EQU     *
01A3 1728A6           (          xyz.asm):00388                 LBSR    _stkcheck
01A6 FFC0             (          xyz.asm):00389                 FDB     -64             argument for _stkcheck
                      (          xyz.asm):00390         * Line xyz.c:1060: return with value
                      (          xyz.asm):00391         * Line xyz.c:1060: function call: malloc()
01A8 4F               (          xyz.asm):00392                 CLRA
01A9 C602             (          xyz.asm):00393                 LDB     #$02            decimal 2 signed
01AB 3406             (          xyz.asm):00394                 PSHS    B,A             argument 1 of malloc(): int
01AD 17069A           (          xyz.asm):00395                 LBSR    _malloc
01B0 3262             (          xyz.asm):00396                 LEAS    2,S
                      (          xyz.asm):00397         * optim: branchToNextLocation
                      (          xyz.asm):00398         * Useless label L00065 removed
01B2 39               (          xyz.asm):00399                 RTS
                      (          xyz.asm):00400         * END FUNCTION NewVec(): defined at xyz.c:1059
     01B3             (          xyz.asm):00401         funcend_NewVec  EQU *
     0010             (          xyz.asm):00402         funcsize_NewVec EQU     funcend_NewVec-_NewVec
                      (          xyz.asm):00403         
                      (          xyz.asm):00404         
                      (          xyz.asm):00405         *******************************************************************************
                      (          xyz.asm):00406         
                      (          xyz.asm):00407         * FUNCTION Os9Chain(): defined at xyz.c:462
     01B3             (          xyz.asm):00408         _Os9Chain       EQU     *
                      (          xyz.asm):00409         * Formal parameters and locals:
                      (          xyz.asm):00410         *   program: char *; 2 bytes at 4,U
                      (          xyz.asm):00411         *   params: char *; 2 bytes at 6,U
                      (          xyz.asm):00412         *   paramlen: int; 2 bytes at 8,U
                      (          xyz.asm):00413         *   lang_type: int; 2 bytes at 10,U
                      (          xyz.asm):00414         *   mem_size: int; 2 bytes at 12,U
                      (          xyz.asm):00415         * Line xyz.c:463: inline assembly
                      (          xyz.asm):00416         * Inline assembly:
                      (          xyz.asm):00417         
                      (          xyz.asm):00418         
01B3 3460             (          xyz.asm):00419           pshs y,u
01B5 AE66             (          xyz.asm):00420           ldx 6,s ; program
01B7 EE68             (          xyz.asm):00421           ldu 8,s ; params
01B9 10AE6A           (          xyz.asm):00422           ldy 10,s ; paramlen
01BC A66D             (          xyz.asm):00423           lda 13,s ; lang_type
01BE E66F             (          xyz.asm):00424           ldb 15,s ; mem_size
01C0 103F05           (          xyz.asm):00425           os9 0x05 ; F$Chain -- if returns, then it is an error.
01C3 1D               (          xyz.asm):00426           sex ; extend error B to D
01C4 35E0             (          xyz.asm):00427           puls y,u,pc
                      (          xyz.asm):00428         
                      (          xyz.asm):00429         
                      (          xyz.asm):00430         * End of inline assembly.
                      (          xyz.asm):00431         * Useless label L00032 removed
01C6 39               (          xyz.asm):00432                 RTS
                      (          xyz.asm):00433         * END FUNCTION Os9Chain(): defined at xyz.c:462
     01C7             (          xyz.asm):00434         funcend_Os9Chain        EQU *
     0014             (          xyz.asm):00435         funcsize_Os9Chain       EQU     funcend_Os9Chain-_Os9Chain
                      (          xyz.asm):00436         
                      (          xyz.asm):00437         
                      (          xyz.asm):00438         *******************************************************************************
                      (          xyz.asm):00439         
                      (          xyz.asm):00440         * FUNCTION Os9Close(): defined at xyz.c:385
     01C7             (          xyz.asm):00441         _Os9Close       EQU     *
                      (          xyz.asm):00442         * Formal parameters and locals:
                      (          xyz.asm):00443         *   path: int; 2 bytes at 4,U
                      (          xyz.asm):00444         * Line xyz.c:386: inline assembly
                      (          xyz.asm):00445         * Inline assembly:
                      (          xyz.asm):00446         
                      (          xyz.asm):00447         
01C7 3460             (          xyz.asm):00448           pshs y,u
01C9 A667             (          xyz.asm):00449           lda 7,s ; path.
01CB 103F8F           (          xyz.asm):00450           os9 0x8F ; I$Close
01CE 255D             (          xyz.asm):00451           bcs Os9Err
01D0 CC0000           (          xyz.asm):00452           ldd #0
01D3 35E0             (          xyz.asm):00453           puls y,u,pc
                      (          xyz.asm):00454         
                      (          xyz.asm):00455         
                      (          xyz.asm):00456         * End of inline assembly.
                      (          xyz.asm):00457         * Useless label L00028 removed
01D5 39               (          xyz.asm):00458                 RTS
                      (          xyz.asm):00459         * END FUNCTION Os9Close(): defined at xyz.c:385
     01D6             (          xyz.asm):00460         funcend_Os9Close        EQU *
     000F             (          xyz.asm):00461         funcsize_Os9Close       EQU     funcend_Os9Close-_Os9Close
                      (          xyz.asm):00462         
                      (          xyz.asm):00463         
                      (          xyz.asm):00464         *******************************************************************************
                      (          xyz.asm):00465         
                      (          xyz.asm):00466         * FUNCTION Os9Dup(): defined at xyz.c:371
     01D6             (          xyz.asm):00467         _Os9Dup EQU     *
                      (          xyz.asm):00468         * Formal parameters and locals:
                      (          xyz.asm):00469         *   path: int; 2 bytes at 4,U
                      (          xyz.asm):00470         *   new_path: int *; 2 bytes at 6,U
                      (          xyz.asm):00471         * Line xyz.c:372: inline assembly
                      (          xyz.asm):00472         * Inline assembly:
                      (          xyz.asm):00473         
                      (          xyz.asm):00474         
01D6 3460             (          xyz.asm):00475           pshs y,u
01D8 A667             (          xyz.asm):00476           lda 7,s ; old path.
01DA 103F82           (          xyz.asm):00477           os9 0x82 ; I$Dup
01DD 254E             (          xyz.asm):00478           bcs Os9Err
01DF 1F89             (          xyz.asm):00479           tfr a,b ; new path.
01E1 1D               (          xyz.asm):00480           sex
01E2 EDF808           (          xyz.asm):00481           std [8,s]
01E5 CC0000           (          xyz.asm):00482           ldd #0
01E8 35E0             (          xyz.asm):00483           puls y,u,pc
                      (          xyz.asm):00484         
                      (          xyz.asm):00485         
                      (          xyz.asm):00486         * End of inline assembly.
                      (          xyz.asm):00487         * Useless label L00027 removed
01EA 39               (          xyz.asm):00488                 RTS
                      (          xyz.asm):00489         * END FUNCTION Os9Dup(): defined at xyz.c:371
     01EB             (          xyz.asm):00490         funcend_Os9Dup  EQU *
     0015             (          xyz.asm):00491         funcsize_Os9Dup EQU     funcend_Os9Dup-_Os9Dup
                      (          xyz.asm):00492         
                      (          xyz.asm):00493         
                      (          xyz.asm):00494         *******************************************************************************
                      (          xyz.asm):00495         
                      (          xyz.asm):00496         * FUNCTION Os9Fork(): defined at xyz.c:444
     01EB             (          xyz.asm):00497         _Os9Fork        EQU     *
                      (          xyz.asm):00498         * Formal parameters and locals:
                      (          xyz.asm):00499         *   program: char *; 2 bytes at 4,U
                      (          xyz.asm):00500         *   params: char *; 2 bytes at 6,U
                      (          xyz.asm):00501         *   paramlen: int; 2 bytes at 8,U
                      (          xyz.asm):00502         *   lang_type: int; 2 bytes at 10,U
                      (          xyz.asm):00503         *   mem_size: int; 2 bytes at 12,U
                      (          xyz.asm):00504         *   child_id: int *; 2 bytes at 14,U
                      (          xyz.asm):00505         * Line xyz.c:445: inline assembly
                      (          xyz.asm):00506         * Inline assembly:
                      (          xyz.asm):00507         
                      (          xyz.asm):00508         
01EB 3460             (          xyz.asm):00509           pshs y,u
01ED AE66             (          xyz.asm):00510           ldx 6,s ; program
01EF EE68             (          xyz.asm):00511           ldu 8,s ; params
01F1 10AE6A           (          xyz.asm):00512           ldy 10,s ; paramlen
01F4 A66D             (          xyz.asm):00513           lda 13,s ; lang_type
01F6 E66F             (          xyz.asm):00514           ldb 15,s ; mem_size
01F8 103F03           (          xyz.asm):00515           os9 0x03 ; F$Fork
01FB 2530             (          xyz.asm):00516           bcs Os9Err
01FD 1F89             (          xyz.asm):00517           tfr a,b ; move child id to D
01FF 4F               (          xyz.asm):00518           clra
0200 EDF810           (          xyz.asm):00519           std [16,s] ; Store D to *child_id
0203 5F               (          xyz.asm):00520           clrb ; return D=0 no error
0204 35E0             (          xyz.asm):00521           puls y,u,pc
                      (          xyz.asm):00522         
                      (          xyz.asm):00523         
                      (          xyz.asm):00524         * End of inline assembly.
                      (          xyz.asm):00525         * Useless label L00031 removed
0206 39               (          xyz.asm):00526                 RTS
                      (          xyz.asm):00527         * END FUNCTION Os9Fork(): defined at xyz.c:444
     0207             (          xyz.asm):00528         funcend_Os9Fork EQU *
     001C             (          xyz.asm):00529         funcsize_Os9Fork        EQU     funcend_Os9Fork-_Os9Fork
                      (          xyz.asm):00530         
                      (          xyz.asm):00531         
                      (          xyz.asm):00532         *******************************************************************************
                      (          xyz.asm):00533         
                      (          xyz.asm):00534         * FUNCTION Os9ReadLn(): defined at xyz.c:24
     0207             (          xyz.asm):00535         _Os9ReadLn      EQU     *
                      (          xyz.asm):00536         * Formal parameters and locals:
                      (          xyz.asm):00537         *   path: int; 2 bytes at 4,U
                      (          xyz.asm):00538         *   buf: char *; 2 bytes at 6,U
                      (          xyz.asm):00539         *   buflen: int; 2 bytes at 8,U
                      (          xyz.asm):00540         *   bytes_read: int *; 2 bytes at 10,U
                      (          xyz.asm):00541         * Line xyz.c:25: inline assembly
                      (          xyz.asm):00542         * Inline assembly:
                      (          xyz.asm):00543         
                      (          xyz.asm):00544         
0207 3460             (          xyz.asm):00545           pshs y,u
0209 A667             (          xyz.asm):00546           lda 7,s ; path
020B AE68             (          xyz.asm):00547           ldx 8,s ; buf
020D 10AE6A           (          xyz.asm):00548           ldy 10,s ; buflen
0210 103F8B           (          xyz.asm):00549           os9 I_ReadLn
0213 2518             (          xyz.asm):00550           bcs Os9Err
0215 10AFF80C         (          xyz.asm):00551           sty [12,s] ; bytes_read
0219 CC0000           (          xyz.asm):00552           ldd #0
021C 35E0             (          xyz.asm):00553           puls y,u,pc
                      (          xyz.asm):00554         
                      (          xyz.asm):00555         
                      (          xyz.asm):00556         * End of inline assembly.
                      (          xyz.asm):00557         * Useless label L00004 removed
021E 39               (          xyz.asm):00558                 RTS
                      (          xyz.asm):00559         * END FUNCTION Os9ReadLn(): defined at xyz.c:24
     021F             (          xyz.asm):00560         funcend_Os9ReadLn       EQU *
     0018             (          xyz.asm):00561         funcsize_Os9ReadLn      EQU     funcend_Os9ReadLn-_Os9ReadLn
                      (          xyz.asm):00562         
                      (          xyz.asm):00563         
                      (          xyz.asm):00564         *******************************************************************************
                      (          xyz.asm):00565         
                      (          xyz.asm):00566         * FUNCTION Os9Sleep(): defined at xyz.c:396
     021F             (          xyz.asm):00567         _Os9Sleep       EQU     *
                      (          xyz.asm):00568         * Formal parameters and locals:
                      (          xyz.asm):00569         *   secs: int; 2 bytes at 4,U
                      (          xyz.asm):00570         * Line xyz.c:397: inline assembly
                      (          xyz.asm):00571         * Inline assembly:
                      (          xyz.asm):00572         
                      (          xyz.asm):00573         
021F 3460             (          xyz.asm):00574           pshs y,u
0221 AE66             (          xyz.asm):00575           ldx 6,s ; ticks
0223 103F0A           (          xyz.asm):00576           os9 0x0A ; I$Sleep
0226 2505             (          xyz.asm):00577           bcs Os9Err
0228 CC0000           (          xyz.asm):00578           ldd #0
022B 35E0             (          xyz.asm):00579           puls y,u,pc
022D                  (          xyz.asm):00580         Os9Err
022D 1D               (          xyz.asm):00581           sex
022E 35E0             (          xyz.asm):00582           puls y,u,pc
                      (          xyz.asm):00583         
                      (          xyz.asm):00584         
                      (          xyz.asm):00585         * End of inline assembly.
                      (          xyz.asm):00586         * Useless label L00029 removed
0230 39               (          xyz.asm):00587                 RTS
                      (          xyz.asm):00588         * END FUNCTION Os9Sleep(): defined at xyz.c:396
     0231             (          xyz.asm):00589         funcend_Os9Sleep        EQU *
     0012             (          xyz.asm):00590         funcsize_Os9Sleep       EQU     funcend_Os9Sleep-_Os9Sleep
                      (          xyz.asm):00591         
                      (          xyz.asm):00592         
                      (          xyz.asm):00593         *******************************************************************************
                      (          xyz.asm):00594         
                      (          xyz.asm):00595         * FUNCTION Os9Wait(): defined at xyz.c:418
     0231             (          xyz.asm):00596         _Os9Wait        EQU     *
                      (          xyz.asm):00597         * Formal parameters and locals:
                      (          xyz.asm):00598         *   child_id: int *; 2 bytes at 4,U
                      (          xyz.asm):00599         * Line xyz.c:419: inline assembly
                      (          xyz.asm):00600         * Inline assembly:
                      (          xyz.asm):00601         
                      (          xyz.asm):00602         
0231 3460             (          xyz.asm):00603           pshs y,u
0233 103F04           (          xyz.asm):00604           os9 0x04 ; F$Wait
0236 25F5             (          xyz.asm):00605           bcs Os9Err
0238 1F89             (          xyz.asm):00606           tfr a,b
023A 1D               (          xyz.asm):00607           sex
023B EDF806           (          xyz.asm):00608           std [6,s]
023E CC0000           (          xyz.asm):00609           ldd #0
0241 35E0             (          xyz.asm):00610           puls y,u,pc
                      (          xyz.asm):00611         
                      (          xyz.asm):00612         
                      (          xyz.asm):00613         * End of inline assembly.
                      (          xyz.asm):00614         * Useless label L00030 removed
0243 39               (          xyz.asm):00615                 RTS
                      (          xyz.asm):00616         * END FUNCTION Os9Wait(): defined at xyz.c:418
     0244             (          xyz.asm):00617         funcend_Os9Wait EQU *
     0013             (          xyz.asm):00618         funcsize_Os9Wait        EQU     funcend_Os9Wait-_Os9Wait
                      (          xyz.asm):00619         
                      (          xyz.asm):00620         
                      (          xyz.asm):00621         *******************************************************************************
                      (          xyz.asm):00622         
                      (          xyz.asm):00623         * FUNCTION Os9WritLn(): defined at xyz.c:38
     0244             (          xyz.asm):00624         _Os9WritLn      EQU     *
                      (          xyz.asm):00625         * Formal parameters and locals:
                      (          xyz.asm):00626         *   path: int; 2 bytes at 4,U
                      (          xyz.asm):00627         *   buf: const char *; 2 bytes at 6,U
                      (          xyz.asm):00628         *   max: int; 2 bytes at 8,U
                      (          xyz.asm):00629         *   bytes_written: int *; 2 bytes at 10,U
                      (          xyz.asm):00630         * Line xyz.c:39: inline assembly
                      (          xyz.asm):00631         * Inline assembly:
                      (          xyz.asm):00632         
                      (          xyz.asm):00633         
0244 3460             (          xyz.asm):00634           pshs y,u
0246 A667             (          xyz.asm):00635           lda 7,s ; path
0248 AE68             (          xyz.asm):00636           ldx 8,s ; buf
024A 10AE6A           (          xyz.asm):00637           ldy 10,s ; max
024D 103F8C           (          xyz.asm):00638           os9 I_WritLn
0250 25DB             (          xyz.asm):00639           bcs Os9Err
0252 10AFF80C         (          xyz.asm):00640           sty [12,s] ; bytes_written
0256 CC0000           (          xyz.asm):00641           ldd #0
0259 35E0             (          xyz.asm):00642           puls y,u,pc
                      (          xyz.asm):00643         
                      (          xyz.asm):00644         
                      (          xyz.asm):00645         * End of inline assembly.
                      (          xyz.asm):00646         * Useless label L00005 removed
025B 39               (          xyz.asm):00647                 RTS
                      (          xyz.asm):00648         * END FUNCTION Os9WritLn(): defined at xyz.c:38
     025C             (          xyz.asm):00649         funcend_Os9WritLn       EQU *
     0018             (          xyz.asm):00650         funcsize_Os9WritLn      EQU     funcend_Os9WritLn-_Os9WritLn
                      (          xyz.asm):00651         
                      (          xyz.asm):00652         
                      (          xyz.asm):00653         *******************************************************************************
                      (          xyz.asm):00654         
                      (          xyz.asm):00655         * FUNCTION ReduceBigraphs(): defined at xyz.c:1268
     025C             (          xyz.asm):00656         _ReduceBigraphs EQU     *
025C 3440             (          xyz.asm):00657                 PSHS    U
025E 1727EB           (          xyz.asm):00658                 LBSR    _stkcheck
0261 FFBC             (          xyz.asm):00659                 FDB     -68             argument for _stkcheck
0263 33E4             (          xyz.asm):00660                 LEAU    ,S
0265 327C             (          xyz.asm):00661                 LEAS    -4,S
                      (          xyz.asm):00662         * Formal parameters and locals:
                      (          xyz.asm):00663         *   s: char *; 2 bytes at 4,U
                      (          xyz.asm):00664         *   z: char *; 2 bytes at -2,U
                      (          xyz.asm):00665         * Line xyz.c:1269: init of variable z
0267 EC44             (          xyz.asm):00666                 LDD     4,U             variable s, declared at xyz.c:1268
0269 ED5E             (          xyz.asm):00667                 STD     -2,U            variable z
                      (          xyz.asm):00668         * Line xyz.c:1270: for init
                      (          xyz.asm):00669         * Line xyz.c:1270: init of variable p
026B EC44             (          xyz.asm):00670                 LDD     4,U             variable s, declared at xyz.c:1268
026D ED5C             (          xyz.asm):00671                 STD     -4,U            variable p
026F 16008F           (          xyz.asm):00672                 LBRA    L00159          jump to for condition
     0272             (          xyz.asm):00673         L00158  EQU     *
                      (          xyz.asm):00674         * Line xyz.c:1270: for body
                      (          xyz.asm):00675         * Line xyz.c:1271: if
0272 C628             (          xyz.asm):00676                 LDB     #$28            optim: lddToLDB
0274 1D               (          xyz.asm):00677                 SEX                     promotion of binary operand
0275 3406             (          xyz.asm):00678                 PSHS    B,A
                      (          xyz.asm):00679         * optim: optimizeLdx
0277 E6D8FC           (          xyz.asm):00680                 LDB     [-4,U]          optim: optimizeLdx
027A 1D               (          xyz.asm):00681                 SEX                     promotion of binary operand
027B 10A3E1           (          xyz.asm):00682                 CMPD    ,S++
027E 2632             (          xyz.asm):00683                 BNE     L00163
                      (          xyz.asm):00684         * optim: condBranchOverUncondBranch
                      (          xyz.asm):00685         * Useless label L00162 removed
                      (          xyz.asm):00686         * Line xyz.c:1272: if
0280 C628             (          xyz.asm):00687                 LDB     #$28            optim: lddToLDB
0282 1D               (          xyz.asm):00688                 SEX                     promotion of binary operand
0283 3406             (          xyz.asm):00689                 PSHS    B,A
0285 AE5C             (          xyz.asm):00690                 LDX     -4,U            get pointer value
                      (          xyz.asm):00691         * optim: optimizeLeax
0287 E601             (          xyz.asm):00692                 LDB     1,X             optim: optimizeLeax
0289 1D               (          xyz.asm):00693                 SEX                     promotion of binary operand
028A 10A3E1           (          xyz.asm):00694                 CMPD    ,S++
028D 2617             (          xyz.asm):00695                 BNE     L00165
                      (          xyz.asm):00696         * optim: condBranchOverUncondBranch
                      (          xyz.asm):00697         * Useless label L00164 removed
                      (          xyz.asm):00698         * Line xyz.c:1273: assignment: =
028F 4F               (          xyz.asm):00699                 CLRA
                      (          xyz.asm):00700         * LDB #$7B optim: optimizeStackOperations1
                      (          xyz.asm):00701         * PSHS B optim: optimizeStackOperations1
0290 AE5E             (          xyz.asm):00702                 LDX     -2,U            get pointer z
0292 C67B             (          xyz.asm):00703                 LDB     #123            optimiz: optimizePostIncrement
                      (          xyz.asm):00704         * optimiz: optimizePostIncrement
0294 E780             (          xyz.asm):00705                 STB     ,X+             optimiz: optimizePostIncrement
                      (          xyz.asm):00706         * optimiz: optimizePostIncrement
0296 AF5E             (          xyz.asm):00707                 STX     -2,U            optimiz: optimizePostIncrement
0298 305C             (          xyz.asm):00708                 LEAX    -4,U            variable p, declared at xyz.c:1270
029A EC84             (          xyz.asm):00709                 LDD     ,X
029C C30001           (          xyz.asm):00710                 ADDD    #1
029F ED84             (          xyz.asm):00711                 STD     ,X
02A1 830001           (          xyz.asm):00712                 SUBD    #1              post increment yields initial value
02A4 2009             (          xyz.asm):00713                 BRA     L00166          jump over else clause
     02A6             (          xyz.asm):00714         L00165  EQU     *               else
                      (          xyz.asm):00715         * Line xyz.c:1275: assignment: =
02A6 4F               (          xyz.asm):00716                 CLRA
                      (          xyz.asm):00717         * LDB #$5B optim: optimizeStackOperations1
                      (          xyz.asm):00718         * PSHS B optim: optimizeStackOperations1
02A7 AE5E             (          xyz.asm):00719                 LDX     -2,U            get pointer z
02A9 C65B             (          xyz.asm):00720                 LDB     #91             optimiz: optimizePostIncrement
                      (          xyz.asm):00721         * optimiz: optimizePostIncrement
02AB E780             (          xyz.asm):00722                 STB     ,X+             optimiz: optimizePostIncrement
                      (          xyz.asm):00723         * optimiz: optimizePostIncrement
02AD AF5E             (          xyz.asm):00724                 STX     -2,U            optimiz: optimizePostIncrement
     02AF             (          xyz.asm):00725         L00166  EQU     *               end if
02AF 160048           (          xyz.asm):00726                 LBRA    L00167          jump over else clause
     02B2             (          xyz.asm):00727         L00163  EQU     *               else
                      (          xyz.asm):00728         * Line xyz.c:1277: if
02B2 C629             (          xyz.asm):00729                 LDB     #$29            optim: lddToLDB
02B4 1D               (          xyz.asm):00730                 SEX                     promotion of binary operand
02B5 3406             (          xyz.asm):00731                 PSHS    B,A
                      (          xyz.asm):00732         * optim: optimizeLdx
02B7 E6D8FC           (          xyz.asm):00733                 LDB     [-4,U]          optim: optimizeLdx
02BA 1D               (          xyz.asm):00734                 SEX                     promotion of binary operand
02BB 10A3E1           (          xyz.asm):00735                 CMPD    ,S++
02BE 2631             (          xyz.asm):00736                 BNE     L00169
                      (          xyz.asm):00737         * optim: condBranchOverUncondBranch
                      (          xyz.asm):00738         * Useless label L00168 removed
                      (          xyz.asm):00739         * Line xyz.c:1278: if
02C0 C629             (          xyz.asm):00740                 LDB     #$29            optim: lddToLDB
02C2 1D               (          xyz.asm):00741                 SEX                     promotion of binary operand
02C3 3406             (          xyz.asm):00742                 PSHS    B,A
02C5 AE5C             (          xyz.asm):00743                 LDX     -4,U            get pointer value
                      (          xyz.asm):00744         * optim: optimizeLeax
02C7 E601             (          xyz.asm):00745                 LDB     1,X             optim: optimizeLeax
02C9 1D               (          xyz.asm):00746                 SEX                     promotion of binary operand
02CA 10A3E1           (          xyz.asm):00747                 CMPD    ,S++
02CD 2617             (          xyz.asm):00748                 BNE     L00171
                      (          xyz.asm):00749         * optim: condBranchOverUncondBranch
                      (          xyz.asm):00750         * Useless label L00170 removed
                      (          xyz.asm):00751         * Line xyz.c:1279: assignment: =
02CF 4F               (          xyz.asm):00752                 CLRA
                      (          xyz.asm):00753         * LDB #$7D optim: optimizeStackOperations1
                      (          xyz.asm):00754         * PSHS B optim: optimizeStackOperations1
02D0 AE5E             (          xyz.asm):00755                 LDX     -2,U            get pointer z
02D2 C67D             (          xyz.asm):00756                 LDB     #125            optimiz: optimizePostIncrement
                      (          xyz.asm):00757         * optimiz: optimizePostIncrement
02D4 E780             (          xyz.asm):00758                 STB     ,X+             optimiz: optimizePostIncrement
                      (          xyz.asm):00759         * optimiz: optimizePostIncrement
02D6 AF5E             (          xyz.asm):00760                 STX     -2,U            optimiz: optimizePostIncrement
02D8 305C             (          xyz.asm):00761                 LEAX    -4,U            variable p, declared at xyz.c:1270
02DA EC84             (          xyz.asm):00762                 LDD     ,X
02DC C30001           (          xyz.asm):00763                 ADDD    #1
02DF ED84             (          xyz.asm):00764                 STD     ,X
02E1 830001           (          xyz.asm):00765                 SUBD    #1              post increment yields initial value
02E4 2009             (          xyz.asm):00766                 BRA     L00172          jump over else clause
     02E6             (          xyz.asm):00767         L00171  EQU     *               else
                      (          xyz.asm):00768         * Line xyz.c:1281: assignment: =
02E6 4F               (          xyz.asm):00769                 CLRA
                      (          xyz.asm):00770         * LDB #$5D optim: optimizeStackOperations1
                      (          xyz.asm):00771         * PSHS B optim: optimizeStackOperations1
02E7 AE5E             (          xyz.asm):00772                 LDX     -2,U            get pointer z
02E9 C65D             (          xyz.asm):00773                 LDB     #93             optimiz: optimizePostIncrement
                      (          xyz.asm):00774         * optimiz: optimizePostIncrement
02EB E780             (          xyz.asm):00775                 STB     ,X+             optimiz: optimizePostIncrement
                      (          xyz.asm):00776         * optimiz: optimizePostIncrement
02ED AF5E             (          xyz.asm):00777                 STX     -2,U            optimiz: optimizePostIncrement
     02EF             (          xyz.asm):00778         L00172  EQU     *               end if
02EF 2009             (          xyz.asm):00779                 BRA     L00173          jump over else clause
     02F1             (          xyz.asm):00780         L00169  EQU     *               else
                      (          xyz.asm):00781         * Line xyz.c:1284: assignment: =
                      (          xyz.asm):00782         * optim: optimizeIndexedX
02F1 E6D8FC           (          xyz.asm):00783                 LDB     [-4,U]          optim: optimizeIndexedX
                      (          xyz.asm):00784         * optim: stripExtraPushPullB
02F4 AE5E             (          xyz.asm):00785                 LDX     -2,U            get pointer z
                      (          xyz.asm):00786         * optimiz: optimizePostIncrement
                      (          xyz.asm):00787         * optimiz: optimizePostIncrement
02F6 E780             (          xyz.asm):00788                 STB     ,X+             optimiz: optimizePostIncrement
                      (          xyz.asm):00789         * optim: stripExtraPushPullB
02F8 AF5E             (          xyz.asm):00790                 STX     -2,U            optimiz: optimizePostIncrement
     02FA             (          xyz.asm):00791         L00173  EQU     *               end if
     02FA             (          xyz.asm):00792         L00167  EQU     *               end if
                      (          xyz.asm):00793         * Useless label L00160 removed
                      (          xyz.asm):00794         * Line xyz.c:1270: for increment(s)
02FA EC5C             (          xyz.asm):00795                 LDD     -4,U
02FC C30001           (          xyz.asm):00796                 ADDD    #1
02FF ED5C             (          xyz.asm):00797                 STD     -4,U
     0301             (          xyz.asm):00798         L00159  EQU     *
                      (          xyz.asm):00799         * Line xyz.c:1270: for condition
                      (          xyz.asm):00800         * optim: optimizeIndexedX
0301 E6D8FC           (          xyz.asm):00801                 LDB     [-4,U]          optim: optimizeIndexedX
                      (          xyz.asm):00802         * optim: loadCmpZeroBeqOrBne
0304 1026FF6A         (          xyz.asm):00803                 LBNE    L00158
                      (          xyz.asm):00804         * optim: branchToNextLocation
                      (          xyz.asm):00805         * Useless label L00161 removed
                      (          xyz.asm):00806         * Line xyz.c:1287: assignment: =
0308 4F               (          xyz.asm):00807                 CLRA
0309 5F               (          xyz.asm):00808                 CLRB
                      (          xyz.asm):00809         * optim: stripExtraPushPullB
                      (          xyz.asm):00810         * optim: optimizeLdx
                      (          xyz.asm):00811         * optim: stripExtraPushPullB
030A E7D8FE           (          xyz.asm):00812                 STB     [-2,U]          optim: optimizeLdx
                      (          xyz.asm):00813         * Useless label L00083 removed
030D 32C4             (          xyz.asm):00814                 LEAS    ,U
030F 35C0             (          xyz.asm):00815                 PULS    U,PC
                      (          xyz.asm):00816         * END FUNCTION ReduceBigraphs(): defined at xyz.c:1268
     0311             (          xyz.asm):00817         funcend_ReduceBigraphs  EQU *
     00B5             (          xyz.asm):00818         funcsize_ReduceBigraphs EQU     funcend_ReduceBigraphs-_ReduceBigraphs
                      (          xyz.asm):00819         
                      (          xyz.asm):00820         
                      (          xyz.asm):00821         *******************************************************************************
                      (          xyz.asm):00822         
                      (          xyz.asm):00823         * FUNCTION ResultD(): defined at xyz.c:1178
     0311             (          xyz.asm):00824         _ResultD        EQU     *
0311 3440             (          xyz.asm):00825                 PSHS    U
0313 172736           (          xyz.asm):00826                 LBSR    _stkcheck
0316 FFA0             (          xyz.asm):00827                 FDB     -96             argument for _stkcheck
0318 33E4             (          xyz.asm):00828                 LEAU    ,S
031A 32E8E0           (          xyz.asm):00829                 LEAS    -32,S
                      (          xyz.asm):00830         * Formal parameters and locals:
                      (          xyz.asm):00831         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):00832         *   x: int; 2 bytes at 6,U
                      (          xyz.asm):00833         *   buf: char[]; 32 bytes at -32,U
                      (          xyz.asm):00834         * Line xyz.c:1180: function call: snprintf_d()
031D EC46             (          xyz.asm):00835                 LDD     6,U             variable x, declared at xyz.c:1178
031F 3406             (          xyz.asm):00836                 PSHS    B,A             argument 4 of snprintf_d(): int
0321 308D2988         (          xyz.asm):00837                 LEAX    S00100,PCR      "%d"
                      (          xyz.asm):00838         * optim: optimizePshsOps
0325 4F               (          xyz.asm):00839                 CLRA
0326 C620             (          xyz.asm):00840                 LDB     #$20            decimal 32 signed
0328 3416             (          xyz.asm):00841                 PSHS    X,B,A           optim: optimizePshsOps
032A 30C8E0           (          xyz.asm):00842                 LEAX    -32,U           address of array buf
032D 3410             (          xyz.asm):00843                 PSHS    X               argument 1 of snprintf_d(): char[]
032F 172582           (          xyz.asm):00844                 LBSR    _snprintf_d
0332 3268             (          xyz.asm):00845                 LEAS    8,S
                      (          xyz.asm):00846         * Line xyz.c:1181: function call: picolSetResult()
0334 30C8E0           (          xyz.asm):00847                 LEAX    -32,U           address of array buf
                      (          xyz.asm):00848         * optim: optimizePshsOps
0337 EC44             (          xyz.asm):00849                 LDD     4,U             variable i, declared at xyz.c:1178
0339 3416             (          xyz.asm):00850                 PSHS    X,B,A           optim: optimizePshsOps
033B 17237D           (          xyz.asm):00851                 LBSR    _picolSetResult
033E 3264             (          xyz.asm):00852                 LEAS    4,S
                      (          xyz.asm):00853         * Line xyz.c:1182: return with value
0340 4F               (          xyz.asm):00854                 CLRA
0341 5F               (          xyz.asm):00855                 CLRB
                      (          xyz.asm):00856         * optim: branchToNextLocation
                      (          xyz.asm):00857         * Useless label L00075 removed
0342 32C4             (          xyz.asm):00858                 LEAS    ,U
0344 35C0             (          xyz.asm):00859                 PULS    U,PC
                      (          xyz.asm):00860         * END FUNCTION ResultD(): defined at xyz.c:1178
     0346             (          xyz.asm):00861         funcend_ResultD EQU *
     0035             (          xyz.asm):00862         funcsize_ResultD        EQU     funcend_ResultD-_ResultD
                      (          xyz.asm):00863         
                      (          xyz.asm):00864         
                      (          xyz.asm):00865         *******************************************************************************
                      (          xyz.asm):00866         
                      (          xyz.asm):00867         * FUNCTION SplitList(): defined at xyz.c:1082
     0346             (          xyz.asm):00868         _SplitList      EQU     *
0346 3440             (          xyz.asm):00869                 PSHS    U
0348 172701           (          xyz.asm):00870                 LBSR    _stkcheck
034B FFB8             (          xyz.asm):00871                 FDB     -72             argument for _stkcheck
034D 33E4             (          xyz.asm):00872                 LEAU    ,S
034F 3278             (          xyz.asm):00873                 LEAS    -8,S
                      (          xyz.asm):00874         * Formal parameters and locals:
                      (          xyz.asm):00875         *   s: char *; 2 bytes at 4,U
                      (          xyz.asm):00876         *   argcP: int *; 2 bytes at 6,U
                      (          xyz.asm):00877         *   argvP: char ***; 2 bytes at 8,U
                      (          xyz.asm):00878         *   vec: char **; 2 bytes at -4,U
                      (          xyz.asm):00879         *   veclen: int; 2 bytes at -2,U
                      (          xyz.asm):00880         * Line xyz.c:1083: init of variable vec
                      (          xyz.asm):00881         * Line xyz.c:1083: function call: NewVec()
0351 17FE4F           (          xyz.asm):00882                 LBSR    _NewVec
0354 ED5C             (          xyz.asm):00883                 STD     -4,U            variable vec
                      (          xyz.asm):00884         * Line xyz.c:1084: init of variable veclen
0356 4F               (          xyz.asm):00885                 CLRA
0357 5F               (          xyz.asm):00886                 CLRB
0358 ED5E             (          xyz.asm):00887                 STD     -2,U            variable veclen
                      (          xyz.asm):00888         * Line xyz.c:1086: while
035A 16007C           (          xyz.asm):00889                 LBRA    L00175          jump to while condition
     035D             (          xyz.asm):00890         L00174  EQU     *               while body
                      (          xyz.asm):00891         * Line xyz.c:1087: while
035D 2009             (          xyz.asm):00892                 BRA     L00178          jump to while condition
     035F             (          xyz.asm):00893         L00177  EQU     *               while body
035F 3044             (          xyz.asm):00894                 LEAX    4,U             variable s, declared at xyz.c:1082
0361 EC84             (          xyz.asm):00895                 LDD     ,X
0363 C30001           (          xyz.asm):00896                 ADDD    #1
0366 ED84             (          xyz.asm):00897                 STD     ,X
                      (          xyz.asm):00898         * optim: removeUselessOps
     0368             (          xyz.asm):00899         L00178  EQU     *               while condition at xyz.c:1087
                      (          xyz.asm):00900         * optim: optimizeIndexedX
0368 E6D804           (          xyz.asm):00901                 LDB     [4,U]           optim: optimizeIndexedX
                      (          xyz.asm):00902         * optim: loadCmpZeroBeqOrBne
036B 270A             (          xyz.asm):00903                 BEQ     L00179
                      (          xyz.asm):00904         * optim: condBranchOverUncondBranch
                      (          xyz.asm):00905         * Useless label L00180 removed
                      (          xyz.asm):00906         * optim: optimizeStackOperations5
                      (          xyz.asm):00907         * optim: optimizeStackOperations5
                      (          xyz.asm):00908         * optim: optimizeStackOperations5
                      (          xyz.asm):00909         * optim: optimizeLdx
036D E6D804           (          xyz.asm):00910                 LDB     [4,U]           optim: optimizeLdx
0370 1D               (          xyz.asm):00911                 SEX                     promotion of binary operand
0371 10830020         (          xyz.asm):00912                 CMPD    #$20            optim: optimizeStackOperations5
0375 2FE8             (          xyz.asm):00913                 BLE     L00177
                      (          xyz.asm):00914         * optim: branchToNextLocation
     0377             (          xyz.asm):00915         L00179  EQU     *               after end of while starting at xyz.c:1087
                      (          xyz.asm):00916         * Line xyz.c:1091: init of variable b
                      (          xyz.asm):00917         * Line xyz.c:1091: function call: NewBuf()
0377 17FE06           (          xyz.asm):00918                 LBSR    _NewBuf
037A ED58             (          xyz.asm):00919                 STD     -8,U            variable b
                      (          xyz.asm):00920         * Line xyz.c:1092: init of variable blen
037C 4F               (          xyz.asm):00921                 CLRA
037D 5F               (          xyz.asm):00922                 CLRB
037E ED5A             (          xyz.asm):00923                 STD     -6,U            variable blen
                      (          xyz.asm):00924         * Line xyz.c:1093: while
0380 2028             (          xyz.asm):00925                 BRA     L00182          jump to while condition
     0382             (          xyz.asm):00926         L00181  EQU     *               while body
                      (          xyz.asm):00927         * Line xyz.c:1095: assignment: =
                      (          xyz.asm):00928         * Line xyz.c:1095: function call: AppendBuf()
0382 AE44             (          xyz.asm):00929                 LDX     4,U             get address for indirection of variable s
0384 E684             (          xyz.asm):00930                 LDB     ,X              indirection
0386 1D               (          xyz.asm):00931                 SEX                     promoting byte argument to word
0387 3406             (          xyz.asm):00932                 PSHS    B,A             argument 3 of AppendBuf(): char
0389 EC5A             (          xyz.asm):00933                 LDD     -6,U            variable blen, declared at xyz.c:1092
038B 3406             (          xyz.asm):00934                 PSHS    B,A             argument 2 of AppendBuf(): int
038D EC58             (          xyz.asm):00935                 LDD     -8,U            variable b, declared at xyz.c:1091
038F 3406             (          xyz.asm):00936                 PSHS    B,A             argument 1 of AppendBuf(): char *
0391 17FCA2           (          xyz.asm):00937                 LBSR    _AppendBuf
0394 3266             (          xyz.asm):00938                 LEAS    6,S
0396 ED58             (          xyz.asm):00939                 STD     -8,U
0398 305A             (          xyz.asm):00940                 LEAX    -6,U            variable blen, declared at xyz.c:1092
039A EC84             (          xyz.asm):00941                 LDD     ,X
039C C30001           (          xyz.asm):00942                 ADDD    #1
039F ED84             (          xyz.asm):00943                 STD     ,X
                      (          xyz.asm):00944         * optim: removeUselessOps
03A1 3044             (          xyz.asm):00945                 LEAX    4,U             variable s, declared at xyz.c:1082
03A3 EC84             (          xyz.asm):00946                 LDD     ,X
03A5 C30001           (          xyz.asm):00947                 ADDD    #1
03A8 ED84             (          xyz.asm):00948                 STD     ,X
                      (          xyz.asm):00949         * optim: removeUselessOps
     03AA             (          xyz.asm):00950         L00182  EQU     *               while condition at xyz.c:1093
                      (          xyz.asm):00951         * optim: optimizeIndexedX
03AA E6D804           (          xyz.asm):00952                 LDB     [4,U]           optim: optimizeIndexedX
                      (          xyz.asm):00953         * optim: loadCmpZeroBeqOrBne
03AD 270A             (          xyz.asm):00954                 BEQ     L00183
                      (          xyz.asm):00955         * optim: condBranchOverUncondBranch
                      (          xyz.asm):00956         * Useless label L00184 removed
                      (          xyz.asm):00957         * optim: optimizeStackOperations5
                      (          xyz.asm):00958         * optim: optimizeStackOperations5
                      (          xyz.asm):00959         * optim: optimizeStackOperations5
                      (          xyz.asm):00960         * optim: optimizeLdx
03AF E6D804           (          xyz.asm):00961                 LDB     [4,U]           optim: optimizeLdx
03B2 1D               (          xyz.asm):00962                 SEX                     promotion of binary operand
03B3 10830020         (          xyz.asm):00963                 CMPD    #$20            optim: optimizeStackOperations5
03B7 2EC9             (          xyz.asm):00964                 BGT     L00181
                      (          xyz.asm):00965         * optim: branchToNextLocation
     03B9             (          xyz.asm):00966         L00183  EQU     *               after end of while starting at xyz.c:1093
                      (          xyz.asm):00967         * Line xyz.c:1099: if
03B9 EC5A             (          xyz.asm):00968                 LDD     -6,U            variable blen, declared at xyz.c:1092
                      (          xyz.asm):00969         * optim: loadCmpZeroBeqOrBne
03BB 271C             (          xyz.asm):00970                 BEQ     L00186
                      (          xyz.asm):00971         * optim: condBranchOverUncondBranch
                      (          xyz.asm):00972         * Useless label L00185 removed
                      (          xyz.asm):00973         * Line xyz.c:1102: assignment: =
                      (          xyz.asm):00974         * Line xyz.c:1102: function call: AppendVec()
03BD EC58             (          xyz.asm):00975                 LDD     -8,U            variable b, declared at xyz.c:1091
03BF 3406             (          xyz.asm):00976                 PSHS    B,A             argument 3 of AppendVec(): char *
03C1 EC5E             (          xyz.asm):00977                 LDD     -2,U            variable veclen, declared at xyz.c:1084
03C3 3406             (          xyz.asm):00978                 PSHS    B,A             argument 2 of AppendVec(): int
03C5 EC5C             (          xyz.asm):00979                 LDD     -4,U            variable vec, declared at xyz.c:1083
03C7 3406             (          xyz.asm):00980                 PSHS    B,A             argument 1 of AppendVec(): char **
03C9 17FCA3           (          xyz.asm):00981                 LBSR    _AppendVec
03CC 3266             (          xyz.asm):00982                 LEAS    6,S
03CE ED5C             (          xyz.asm):00983                 STD     -4,U
03D0 305E             (          xyz.asm):00984                 LEAX    -2,U            variable veclen, declared at xyz.c:1084
03D2 EC84             (          xyz.asm):00985                 LDD     ,X
03D4 C30001           (          xyz.asm):00986                 ADDD    #1
03D7 ED84             (          xyz.asm):00987                 STD     ,X
                      (          xyz.asm):00988         * optim: removeUselessOps
     03D9             (          xyz.asm):00989         L00186  EQU     *               else
                      (          xyz.asm):00990         * Useless label L00187 removed
     03D9             (          xyz.asm):00991         L00175  EQU     *               while condition at xyz.c:1086
                      (          xyz.asm):00992         * optim: optimizeIndexedX
03D9 E6D804           (          xyz.asm):00993                 LDB     [4,U]           optim: optimizeIndexedX
                      (          xyz.asm):00994         * optim: loadCmpZeroBeqOrBne
03DC 1026FF7D         (          xyz.asm):00995                 LBNE    L00174
                      (          xyz.asm):00996         * optim: branchToNextLocation
                      (          xyz.asm):00997         * Useless label L00176 removed
                      (          xyz.asm):00998         * Line xyz.c:1107: assignment: =
03E0 EC5C             (          xyz.asm):00999                 LDD     -4,U            variable vec, declared at xyz.c:1083
                      (          xyz.asm):01000         * optim: stripUselessPushPull
                      (          xyz.asm):01001         * optim: optimizeLdx
                      (          xyz.asm):01002         * optim: stripUselessPushPull
03E2 EDD808           (          xyz.asm):01003                 STD     [8,U]           optim: optimizeLdx
                      (          xyz.asm):01004         * Line xyz.c:1108: assignment: =
03E5 EC5E             (          xyz.asm):01005                 LDD     -2,U            variable veclen, declared at xyz.c:1084
                      (          xyz.asm):01006         * optim: stripUselessPushPull
                      (          xyz.asm):01007         * optim: optimizeLdx
                      (          xyz.asm):01008         * optim: stripUselessPushPull
03E7 EDD806           (          xyz.asm):01009                 STD     [6,U]           optim: optimizeLdx
                      (          xyz.asm):01010         * Line xyz.c:1111: return with value
03EA 4F               (          xyz.asm):01011                 CLRA
03EB 5F               (          xyz.asm):01012                 CLRB
                      (          xyz.asm):01013         * optim: branchToNextLocation
                      (          xyz.asm):01014         * Useless label L00069 removed
03EC 32C4             (          xyz.asm):01015                 LEAS    ,U
03EE 35C0             (          xyz.asm):01016                 PULS    U,PC
                      (          xyz.asm):01017         * END FUNCTION SplitList(): defined at xyz.c:1082
     03F0             (          xyz.asm):01018         funcend_SplitList       EQU *
     00AA             (          xyz.asm):01019         funcsize_SplitList      EQU     funcend_SplitList-_SplitList
                      (          xyz.asm):01020         
                      (          xyz.asm):01021         
                      (          xyz.asm):01022         *******************************************************************************
                      (          xyz.asm):01023         
                      (          xyz.asm):01024         * FUNCTION Up(): defined at xyz.c:116
     03F0             (          xyz.asm):01025         _Up     EQU     *
03F0 3440             (          xyz.asm):01026                 PSHS    U
03F2 172657           (          xyz.asm):01027                 LBSR    _stkcheck
03F5 FFC0             (          xyz.asm):01028                 FDB     -64             argument for _stkcheck
03F7 33E4             (          xyz.asm):01029                 LEAU    ,S
                      (          xyz.asm):01030         * Formal parameters and locals:
                      (          xyz.asm):01031         *   c: char; 1 byte at 5,U
                      (          xyz.asm):01032         * Line xyz.c:117: return with value
03F9 E645             (          xyz.asm):01033                 LDB     5,U             variable c, declared at xyz.c:116
03FB 1D               (          xyz.asm):01034                 SEX                     promotion of binary operand
03FC 3406             (          xyz.asm):01035                 PSHS    B,A
03FE C661             (          xyz.asm):01036                 LDB     #$61            optim: lddToLDB
0400 1D               (          xyz.asm):01037                 SEX                     promotion of binary operand
0401 10A3E1           (          xyz.asm):01038                 CMPD    ,S++
0404 2F03             (          xyz.asm):01039                 BLE     L00189          if true
0406 5F               (          xyz.asm):01040                 CLRB
0407 2002             (          xyz.asm):01041                 BRA     L00190          false
     0409             (          xyz.asm):01042         L00189  EQU     *
0409 C601             (          xyz.asm):01043                 LDB     #1
     040B             (          xyz.asm):01044         L00190  EQU     *
040B 5D               (          xyz.asm):01045                 TSTB                    &&
040C 2710             (          xyz.asm):01046                 BEQ     L00188          && at xyz.c:117 yields false, B == 0
040E E645             (          xyz.asm):01047                 LDB     5,U             variable c
0410 C17A             (          xyz.asm):01048                 CMPB    #$7A
0412 2F03             (          xyz.asm):01049                 BLE     L00191          if true
0414 5F               (          xyz.asm):01050                 CLRB
0415 2002             (          xyz.asm):01051                 BRA     L00192          false
     0417             (          xyz.asm):01052         L00191  EQU     *
0417 C601             (          xyz.asm):01053                 LDB     #1
     0419             (          xyz.asm):01054         L00192  EQU     *
0419 5D               (          xyz.asm):01055                 TSTB                    &&
041A 2702             (          xyz.asm):01056                 BEQ     L00188          && at xyz.c:117 yields false, B == 0
041C C601             (          xyz.asm):01057                 LDB     #1              && yields true
     041E             (          xyz.asm):01058         L00188  EQU     *
041E 5D               (          xyz.asm):01059                 TSTB
041F 2708             (          xyz.asm):01060                 BEQ     L00193          if conditional expression is false
0421 E645             (          xyz.asm):01061                 LDB     5,U
0423 1D               (          xyz.asm):01062                 SEX
0424 C3FFE0           (          xyz.asm):01063                 ADDD    #$FFE0          65504
0427 2002             (          xyz.asm):01064                 BRA     L00194          end of true expression of conditional
     0429             (          xyz.asm):01065         L00193  EQU     *
0429 E645             (          xyz.asm):01066                 LDB     5,U             variable c, declared at xyz.c:116
     042B             (          xyz.asm):01067         L00194  EQU     *
                      (          xyz.asm):01068         * optim: branchToNextLocation
                      (          xyz.asm):01069         * Useless label L00011 removed
042B 32C4             (          xyz.asm):01070                 LEAS    ,U
042D 35C0             (          xyz.asm):01071                 PULS    U,PC
                      (          xyz.asm):01072         * END FUNCTION Up(): defined at xyz.c:116
     042F             (          xyz.asm):01073         funcend_Up      EQU *
     003F             (          xyz.asm):01074         funcsize_Up     EQU     funcend_Up-_Up
                      (          xyz.asm):01075         
                      (          xyz.asm):01076         
                      (          xyz.asm):01077         *******************************************************************************
                      (          xyz.asm):01078         
                      (          xyz.asm):01079         * FUNCTION atoi(): defined at xyz.c:119
     042F             (          xyz.asm):01080         _atoi   EQU     *
042F 3440             (          xyz.asm):01081                 PSHS    U
0431 172618           (          xyz.asm):01082                 LBSR    _stkcheck
0434 FFBD             (          xyz.asm):01083                 FDB     -67             argument for _stkcheck
0436 33E4             (          xyz.asm):01084                 LEAU    ,S
0438 327D             (          xyz.asm):01085                 LEAS    -3,S
                      (          xyz.asm):01086         * Formal parameters and locals:
                      (          xyz.asm):01087         *   s: const char *; 2 bytes at 4,U
                      (          xyz.asm):01088         *   z: int; 2 bytes at -3,U
                      (          xyz.asm):01089         *   neg: unsigned char; 1 byte at -1,U
                      (          xyz.asm):01090         * Line xyz.c:120: init of variable z
043A 4F               (          xyz.asm):01091                 CLRA
043B 5F               (          xyz.asm):01092                 CLRB
043C ED5D             (          xyz.asm):01093                 STD     -3,U            variable z
                      (          xyz.asm):01094         * Line xyz.c:121: init of variable neg
043E 6F5F             (          xyz.asm):01095                 CLR     -1,U            variable neg
                      (          xyz.asm):01096         * Line xyz.c:122: if
0440 C62D             (          xyz.asm):01097                 LDB     #$2D            optim: removeAndOrMulAddSub
0442 1D               (          xyz.asm):01098                 SEX                     promotion of binary operand
0443 3406             (          xyz.asm):01099                 PSHS    B,A
                      (          xyz.asm):01100         * optim: optimizeLdx
0445 E6D804           (          xyz.asm):01101                 LDB     [4,U]           optim: optimizeLdx
0448 1D               (          xyz.asm):01102                 SEX                     promotion of binary operand
0449 10A3E1           (          xyz.asm):01103                 CMPD    ,S++
044C 2611             (          xyz.asm):01104                 BNE     L00196
                      (          xyz.asm):01105         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01106         * Useless label L00195 removed
                      (          xyz.asm):01107         * Line xyz.c:123: assignment: =
044E 4F               (          xyz.asm):01108                 CLRA
044F C601             (          xyz.asm):01109                 LDB     #$01            decimal 1 signed
0451 E75F             (          xyz.asm):01110                 STB     -1,U
0453 3044             (          xyz.asm):01111                 LEAX    4,U             variable s, declared at xyz.c:119
0455 EC84             (          xyz.asm):01112                 LDD     ,X
0457 C30001           (          xyz.asm):01113                 ADDD    #1
045A ED84             (          xyz.asm):01114                 STD     ,X
045C 830001           (          xyz.asm):01115                 SUBD    #1              post increment yields initial value
     045F             (          xyz.asm):01116         L00196  EQU     *               else
                      (          xyz.asm):01117         * Useless label L00197 removed
                      (          xyz.asm):01118         * Line xyz.c:126: if
045F C630             (          xyz.asm):01119                 LDB     #$30            optim: lddToLDB
0461 1D               (          xyz.asm):01120                 SEX                     promotion of binary operand
0462 3406             (          xyz.asm):01121                 PSHS    B,A
                      (          xyz.asm):01122         * optim: optimizeLdx
0464 E6D804           (          xyz.asm):01123                 LDB     [4,U]           optim: optimizeLdx
0467 1D               (          xyz.asm):01124                 SEX                     promotion of binary operand
0468 10A3E1           (          xyz.asm):01125                 CMPD    ,S++
046B 10260129         (          xyz.asm):01126                 LBNE    L00199
                      (          xyz.asm):01127         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01128         * Useless label L00198 removed
046F 3044             (          xyz.asm):01129                 LEAX    4,U             variable s, declared at xyz.c:119
0471 EC84             (          xyz.asm):01130                 LDD     ,X
0473 C30001           (          xyz.asm):01131                 ADDD    #1
0476 ED84             (          xyz.asm):01132                 STD     ,X
                      (          xyz.asm):01133         * optim: stripOpToDeadReg
                      (          xyz.asm):01134         * Line xyz.c:128: if
0478 C678             (          xyz.asm):01135                 LDB     #$78            optim: lddToLDB
047A 1D               (          xyz.asm):01136                 SEX                     promotion of binary operand
047B 3406             (          xyz.asm):01137                 PSHS    B,A
                      (          xyz.asm):01138         * optim: optimizeLdx
047D E6D804           (          xyz.asm):01139                 LDB     [4,U]           optim: optimizeLdx
0480 1D               (          xyz.asm):01140                 SEX                     promotion of binary operand
0481 10A3E1           (          xyz.asm):01141                 CMPD    ,S++
0484 102600C7         (          xyz.asm):01142                 LBNE    L00201
                      (          xyz.asm):01143         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01144         * Useless label L00200 removed
                      (          xyz.asm):01145         * Line xyz.c:130: while
0488 160073           (          xyz.asm):01146                 LBRA    L00203          jump to while condition
     048B             (          xyz.asm):01147         L00202  EQU     *               while body
                      (          xyz.asm):01148         * Line xyz.c:131: if
                      (          xyz.asm):01149         * optim: optimizeLdx
048B E6D804           (          xyz.asm):01150                 LDB     [4,U]           optim: optimizeLdx
048E 1D               (          xyz.asm):01151                 SEX                     promotion of binary operand
048F 3406             (          xyz.asm):01152                 PSHS    B,A
0491 C630             (          xyz.asm):01153                 LDB     #$30            optim: lddToLDB
0493 1D               (          xyz.asm):01154                 SEX                     promotion of binary operand
0494 10A3E1           (          xyz.asm):01155                 CMPD    ,S++
0497 2E2A             (          xyz.asm):01156                 BGT     L00206
                      (          xyz.asm):01157         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01158         * Useless label L00207 removed
0499 C639             (          xyz.asm):01159                 LDB     #$39            optim: lddToLDB
049B 1D               (          xyz.asm):01160                 SEX                     promotion of binary operand
049C 3406             (          xyz.asm):01161                 PSHS    B,A
                      (          xyz.asm):01162         * optim: optimizeLdx
049E E6D804           (          xyz.asm):01163                 LDB     [4,U]           optim: optimizeLdx
04A1 1D               (          xyz.asm):01164                 SEX                     promotion of binary operand
04A2 10A3E1           (          xyz.asm):01165                 CMPD    ,S++
04A5 2E1C             (          xyz.asm):01166                 BGT     L00206
                      (          xyz.asm):01167         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01168         * Useless label L00205 removed
                      (          xyz.asm):01169         * Line xyz.c:132: assignment: =
04A7 C630             (          xyz.asm):01170                 LDB     #$30            optim: lddToLDB
04A9 1D               (          xyz.asm):01171                 SEX                     promotion of binary operand
04AA 3404             (          xyz.asm):01172                 PSHS    B               optim: stripPushLeas
                      (          xyz.asm):01173         * optim: optimizeLdx
04AC E6D804           (          xyz.asm):01174                 LDB     [4,U]           optim: optimizeLdx
04AF 1D               (          xyz.asm):01175                 SEX                     promotion of binary operand
                      (          xyz.asm):01176         * optim: stripPushLeas1
04B0 E0E0             (          xyz.asm):01177                 SUBB    ,S+
04B2 1D               (          xyz.asm):01178                 SEX                     promotion of binary operand
04B3 3406             (          xyz.asm):01179                 PSHS    B,A
04B5 AE5D             (          xyz.asm):01180                 LDX     -3,U            left
04B7 4F               (          xyz.asm):01181                 CLRA
04B8 C610             (          xyz.asm):01182                 LDB     #$10            right
04BA 172943           (          xyz.asm):01183                 LBSR    MUL16
04BD E3E1             (          xyz.asm):01184                 ADDD    ,S++
04BF ED5D             (          xyz.asm):01185                 STD     -3,U
04C1 202F             (          xyz.asm):01186                 BRA     L00208          jump over else clause
     04C3             (          xyz.asm):01187         L00206  EQU     *               else
                      (          xyz.asm):01188         * Line xyz.c:134: assignment: =
04C3 C641             (          xyz.asm):01189                 LDB     #$41            optim: lddToLDB
04C5 1D               (          xyz.asm):01190                 SEX                     promotion of binary operand
04C6 3406             (          xyz.asm):01191                 PSHS    B,A
04C8 4F               (          xyz.asm):01192                 CLRA
04C9 C60A             (          xyz.asm):01193                 LDB     #$0A            decimal 10 signed
04CB 3406             (          xyz.asm):01194                 PSHS    B,A
                      (          xyz.asm):01195         * Line xyz.c:134: function call: Up()
04CD AE44             (          xyz.asm):01196                 LDX     4,U             get address for indirection of variable s
04CF E684             (          xyz.asm):01197                 LDB     ,X              indirection
04D1 1D               (          xyz.asm):01198                 SEX                     promoting byte argument to word
04D2 3406             (          xyz.asm):01199                 PSHS    B,A             argument 1 of Up(): const char
04D4 17FF19           (          xyz.asm):01200                 LBSR    _Up
04D7 3262             (          xyz.asm):01201                 LEAS    2,S
04D9 1D               (          xyz.asm):01202                 SEX                     promotion of binary operand
04DA 3261             (          xyz.asm):01203                 LEAS    1,S
04DC EBE0             (          xyz.asm):01204                 ADDB    ,S+
04DE 1D               (          xyz.asm):01205                 SEX                     promotion of binary operand
04DF 3261             (          xyz.asm):01206                 LEAS    1,S
04E1 E0E0             (          xyz.asm):01207                 SUBB    ,S+
04E3 1D               (          xyz.asm):01208                 SEX                     promotion of binary operand
04E4 3406             (          xyz.asm):01209                 PSHS    B,A
04E6 AE5D             (          xyz.asm):01210                 LDX     -3,U            left
04E8 4F               (          xyz.asm):01211                 CLRA
04E9 C610             (          xyz.asm):01212                 LDB     #$10            right
04EB 172912           (          xyz.asm):01213                 LBSR    MUL16
04EE E3E1             (          xyz.asm):01214                 ADDD    ,S++
04F0 ED5D             (          xyz.asm):01215                 STD     -3,U
     04F2             (          xyz.asm):01216         L00208  EQU     *               end if
04F2 3044             (          xyz.asm):01217                 LEAX    4,U             variable s, declared at xyz.c:119
04F4 EC84             (          xyz.asm):01218                 LDD     ,X
04F6 C30001           (          xyz.asm):01219                 ADDD    #1
04F9 ED84             (          xyz.asm):01220                 STD     ,X
04FB 830001           (          xyz.asm):01221                 SUBD    #1              post increment yields initial value
     04FE             (          xyz.asm):01222         L00203  EQU     *               while condition at xyz.c:130
                      (          xyz.asm):01223         * optim: optimizeLdx
04FE E6D804           (          xyz.asm):01224                 LDB     [4,U]           optim: optimizeLdx
0501 1D               (          xyz.asm):01225                 SEX                     promotion of binary operand
0502 3406             (          xyz.asm):01226                 PSHS    B,A
0504 C630             (          xyz.asm):01227                 LDB     #$30            optim: lddToLDB
0506 1D               (          xyz.asm):01228                 SEX                     promotion of binary operand
0507 10A3E1           (          xyz.asm):01229                 CMPD    ,S++
050A 2E10             (          xyz.asm):01230                 BGT     L00209
                      (          xyz.asm):01231         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01232         * Useless label L00210 removed
050C C639             (          xyz.asm):01233                 LDB     #$39            optim: lddToLDB
050E 1D               (          xyz.asm):01234                 SEX                     promotion of binary operand
050F 3406             (          xyz.asm):01235                 PSHS    B,A
                      (          xyz.asm):01236         * optim: optimizeLdx
0511 E6D804           (          xyz.asm):01237                 LDB     [4,U]           optim: optimizeLdx
0514 1D               (          xyz.asm):01238                 SEX                     promotion of binary operand
0515 10A3E1           (          xyz.asm):01239                 CMPD    ,S++
0518 102FFF6F         (          xyz.asm):01240                 LBLE    L00202
                      (          xyz.asm):01241         * optim: branchToNextLocation
     051C             (          xyz.asm):01242         L00209  EQU     *
                      (          xyz.asm):01243         * Line xyz.c:130: function call: Up()
051C AE44             (          xyz.asm):01244                 LDX     4,U             get address for indirection of variable s
051E E684             (          xyz.asm):01245                 LDB     ,X              indirection
0520 1D               (          xyz.asm):01246                 SEX                     promoting byte argument to word
0521 3406             (          xyz.asm):01247                 PSHS    B,A             argument 1 of Up(): const char
0523 17FECA           (          xyz.asm):01248                 LBSR    _Up
0526 3262             (          xyz.asm):01249                 LEAS    2,S
0528 1D               (          xyz.asm):01250                 SEX                     promotion of binary operand
0529 3406             (          xyz.asm):01251                 PSHS    B,A
052B C641             (          xyz.asm):01252                 LDB     #$41            optim: lddToLDB
052D 1D               (          xyz.asm):01253                 SEX                     promotion of binary operand
052E 10A3E1           (          xyz.asm):01254                 CMPD    ,S++
0531 2E19             (          xyz.asm):01255                 BGT     L00204
                      (          xyz.asm):01256         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01257         * Useless label L00211 removed
                      (          xyz.asm):01258         * Line xyz.c:130: function call: Up()
0533 AE44             (          xyz.asm):01259                 LDX     4,U             get address for indirection of variable s
0535 E684             (          xyz.asm):01260                 LDB     ,X              indirection
0537 1D               (          xyz.asm):01261                 SEX                     promoting byte argument to word
0538 3406             (          xyz.asm):01262                 PSHS    B,A             argument 1 of Up(): const char
053A 17FEB3           (          xyz.asm):01263                 LBSR    _Up
053D 3262             (          xyz.asm):01264                 LEAS    2,S
053F 1D               (          xyz.asm):01265                 SEX                     promotion of binary operand
0540 3406             (          xyz.asm):01266                 PSHS    B,A
0542 C646             (          xyz.asm):01267                 LDB     #$46            optim: lddToLDB
0544 1D               (          xyz.asm):01268                 SEX                     promotion of binary operand
0545 10A3E1           (          xyz.asm):01269                 CMPD    ,S++
0548 102FFF3F         (          xyz.asm):01270                 LBLE    L00202
                      (          xyz.asm):01271         * optim: branchToNextLocation
     054C             (          xyz.asm):01272         L00204  EQU     *               after end of while starting at xyz.c:130
054C 160046           (          xyz.asm):01273                 LBRA    L00212          jump over else clause
     054F             (          xyz.asm):01274         L00201  EQU     *               else
                      (          xyz.asm):01275         * Line xyz.c:140: while
054F 2026             (          xyz.asm):01276                 BRA     L00214          jump to while condition
     0551             (          xyz.asm):01277         L00213  EQU     *               while body
                      (          xyz.asm):01278         * Line xyz.c:141: assignment: =
0551 C630             (          xyz.asm):01279                 LDB     #$30            optim: lddToLDB
0553 1D               (          xyz.asm):01280                 SEX                     promotion of binary operand
0554 3404             (          xyz.asm):01281                 PSHS    B               optim: stripPushLeas
                      (          xyz.asm):01282         * optim: optimizeLdx
0556 E6D804           (          xyz.asm):01283                 LDB     [4,U]           optim: optimizeLdx
0559 1D               (          xyz.asm):01284                 SEX                     promotion of binary operand
                      (          xyz.asm):01285         * optim: stripPushLeas1
055A E0E0             (          xyz.asm):01286                 SUBB    ,S+
055C 1D               (          xyz.asm):01287                 SEX                     promotion of binary operand
055D 3406             (          xyz.asm):01288                 PSHS    B,A
055F AE5D             (          xyz.asm):01289                 LDX     -3,U            left
0561 4F               (          xyz.asm):01290                 CLRA
0562 C608             (          xyz.asm):01291                 LDB     #$08            right
0564 172899           (          xyz.asm):01292                 LBSR    MUL16
0567 E3E1             (          xyz.asm):01293                 ADDD    ,S++
0569 ED5D             (          xyz.asm):01294                 STD     -3,U
056B 3044             (          xyz.asm):01295                 LEAX    4,U             variable s, declared at xyz.c:119
056D EC84             (          xyz.asm):01296                 LDD     ,X
056F C30001           (          xyz.asm):01297                 ADDD    #1
0572 ED84             (          xyz.asm):01298                 STD     ,X
0574 830001           (          xyz.asm):01299                 SUBD    #1              post increment yields initial value
     0577             (          xyz.asm):01300         L00214  EQU     *               while condition at xyz.c:140
                      (          xyz.asm):01301         * optim: optimizeLdx
0577 E6D804           (          xyz.asm):01302                 LDB     [4,U]           optim: optimizeLdx
057A 1D               (          xyz.asm):01303                 SEX                     promotion of binary operand
057B 3406             (          xyz.asm):01304                 PSHS    B,A
057D C630             (          xyz.asm):01305                 LDB     #$30            optim: lddToLDB
057F 1D               (          xyz.asm):01306                 SEX                     promotion of binary operand
0580 10A3E1           (          xyz.asm):01307                 CMPD    ,S++
0583 2E10             (          xyz.asm):01308                 BGT     L00215
                      (          xyz.asm):01309         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01310         * Useless label L00216 removed
0585 C637             (          xyz.asm):01311                 LDB     #$37            optim: lddToLDB
0587 1D               (          xyz.asm):01312                 SEX                     promotion of binary operand
0588 3406             (          xyz.asm):01313                 PSHS    B,A
                      (          xyz.asm):01314         * optim: optimizeLdx
058A E6D804           (          xyz.asm):01315                 LDB     [4,U]           optim: optimizeLdx
058D 1D               (          xyz.asm):01316                 SEX                     promotion of binary operand
058E 10A3E1           (          xyz.asm):01317                 CMPD    ,S++
0591 102FFFBC         (          xyz.asm):01318                 LBLE    L00213
                      (          xyz.asm):01319         * optim: branchToNextLocation
     0595             (          xyz.asm):01320         L00215  EQU     *               after end of while starting at xyz.c:140
     0595             (          xyz.asm):01321         L00212  EQU     *               end if
0595 160044           (          xyz.asm):01322                 LBRA    L00217          jump over else clause
     0598             (          xyz.asm):01323         L00199  EQU     *               else
                      (          xyz.asm):01324         * Line xyz.c:147: while
0598 2024             (          xyz.asm):01325                 BRA     L00219          jump to while condition
     059A             (          xyz.asm):01326         L00218  EQU     *               while body
                      (          xyz.asm):01327         * Line xyz.c:148: assignment: =
059A C630             (          xyz.asm):01328                 LDB     #$30            optim: lddToLDB
059C 1D               (          xyz.asm):01329                 SEX                     promotion of binary operand
059D 3404             (          xyz.asm):01330                 PSHS    B               optim: stripPushLeas
059F AE44             (          xyz.asm):01331                 LDX     4,U             get address for indirection of variable s
05A1 E684             (          xyz.asm):01332                 LDB     ,X              indirection
05A3 1D               (          xyz.asm):01333                 SEX                     promotion of binary operand
                      (          xyz.asm):01334         * optim: stripPushLeas1
05A4 E0E0             (          xyz.asm):01335                 SUBB    ,S+
05A6 1D               (          xyz.asm):01336                 SEX                     promotion of binary operand
05A7 3406             (          xyz.asm):01337                 PSHS    B,A
05A9 EC5D             (          xyz.asm):01338                 LDD     -3,U            variable z, declared at xyz.c:120
05AB 1728D5           (          xyz.asm):01339                 LBSR    MUL16BY10
05AE E3E1             (          xyz.asm):01340                 ADDD    ,S++
05B0 ED5D             (          xyz.asm):01341                 STD     -3,U
05B2 3044             (          xyz.asm):01342                 LEAX    4,U             variable s, declared at xyz.c:119
05B4 EC84             (          xyz.asm):01343                 LDD     ,X
05B6 C30001           (          xyz.asm):01344                 ADDD    #1
05B9 ED84             (          xyz.asm):01345                 STD     ,X
05BB 830001           (          xyz.asm):01346                 SUBD    #1              post increment yields initial value
     05BE             (          xyz.asm):01347         L00219  EQU     *               while condition at xyz.c:147
                      (          xyz.asm):01348         * optim: optimizeLdx
05BE E6D804           (          xyz.asm):01349                 LDB     [4,U]           optim: optimizeLdx
05C1 1D               (          xyz.asm):01350                 SEX                     promotion of binary operand
05C2 3406             (          xyz.asm):01351                 PSHS    B,A
05C4 C630             (          xyz.asm):01352                 LDB     #$30            optim: lddToLDB
05C6 1D               (          xyz.asm):01353                 SEX                     promotion of binary operand
05C7 10A3E1           (          xyz.asm):01354                 CMPD    ,S++
05CA 2E10             (          xyz.asm):01355                 BGT     L00220
                      (          xyz.asm):01356         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01357         * Useless label L00221 removed
05CC C639             (          xyz.asm):01358                 LDB     #$39            optim: lddToLDB
05CE 1D               (          xyz.asm):01359                 SEX                     promotion of binary operand
05CF 3406             (          xyz.asm):01360                 PSHS    B,A
                      (          xyz.asm):01361         * optim: optimizeLdx
05D1 E6D804           (          xyz.asm):01362                 LDB     [4,U]           optim: optimizeLdx
05D4 1D               (          xyz.asm):01363                 SEX                     promotion of binary operand
05D5 10A3E1           (          xyz.asm):01364                 CMPD    ,S++
05D8 102FFFBE         (          xyz.asm):01365                 LBLE    L00218
                      (          xyz.asm):01366         * optim: branchToNextLocation
     05DC             (          xyz.asm):01367         L00220  EQU     *               after end of while starting at xyz.c:147
     05DC             (          xyz.asm):01368         L00217  EQU     *               end if
                      (          xyz.asm):01369         * Line xyz.c:152: return with value
05DC E65F             (          xyz.asm):01370                 LDB     -1,U            variable neg, declared at xyz.c:121
                      (          xyz.asm):01371         * optim: loadCmpZeroBeqOrBne
05DE 2709             (          xyz.asm):01372                 BEQ     L00222          if conditional expression is false
05E0 EC5D             (          xyz.asm):01373                 LDD     -3,U            variable z, declared at xyz.c:120
05E2 43               (          xyz.asm):01374                 COMA
05E3 53               (          xyz.asm):01375                 COMB
05E4 C30001           (          xyz.asm):01376                 ADDD    #1
05E7 2002             (          xyz.asm):01377                 BRA     L00223          end of true expression of conditional
     05E9             (          xyz.asm):01378         L00222  EQU     *
05E9 EC5D             (          xyz.asm):01379                 LDD     -3,U            variable z, declared at xyz.c:120
     05EB             (          xyz.asm):01380         L00223  EQU     *
                      (          xyz.asm):01381         * optim: branchToNextLocation
                      (          xyz.asm):01382         * Useless label L00012 removed
05EB 32C4             (          xyz.asm):01383                 LEAS    ,U
05ED 35C0             (          xyz.asm):01384                 PULS    U,PC
                      (          xyz.asm):01385         * END FUNCTION atoi(): defined at xyz.c:119
     05EF             (          xyz.asm):01386         funcend_atoi    EQU *
     01C0             (          xyz.asm):01387         funcsize_atoi   EQU     funcend_atoi-_atoi
                      (          xyz.asm):01388         
                      (          xyz.asm):01389         
                      (          xyz.asm):01390         *******************************************************************************
                      (          xyz.asm):01391         
                      (          xyz.asm):01392         * FUNCTION bzero(): defined at xyz.c:182
     05EF             (          xyz.asm):01393         _bzero  EQU     *
05EF 3440             (          xyz.asm):01394                 PSHS    U
05F1 172458           (          xyz.asm):01395                 LBSR    _stkcheck
05F4 FFBE             (          xyz.asm):01396                 FDB     -66             argument for _stkcheck
05F6 33E4             (          xyz.asm):01397                 LEAU    ,S
05F8 327E             (          xyz.asm):01398                 LEAS    -2,S
                      (          xyz.asm):01399         * Formal parameters and locals:
                      (          xyz.asm):01400         *   p: char *; 2 bytes at 4,U
                      (          xyz.asm):01401         *   n: int; 2 bytes at 6,U
                      (          xyz.asm):01402         * Line xyz.c:183: for init
                      (          xyz.asm):01403         * Line xyz.c:183: init of variable i
05FA 4F               (          xyz.asm):01404                 CLRA
05FB 5F               (          xyz.asm):01405                 CLRB
05FC ED5E             (          xyz.asm):01406                 STD     -2,U            variable i
05FE 2012             (          xyz.asm):01407                 BRA     L00225          jump to for condition
     0600             (          xyz.asm):01408         L00224  EQU     *
                      (          xyz.asm):01409         * Line xyz.c:183: for body
                      (          xyz.asm):01410         * Line xyz.c:183: assignment: =
0600 4F               (          xyz.asm):01411                 CLRA
                      (          xyz.asm):01412         * CLRB  optim: optimizeStackOperations1
                      (          xyz.asm):01413         * PSHS B optim: optimizeStackOperations1
0601 AE44             (          xyz.asm):01414                 LDX     4,U             pointer p
0603 EC5E             (          xyz.asm):01415                 LDD     -2,U            variable i
0605 308B             (          xyz.asm):01416                 LEAX    D,X             add byte offset
0607 C600             (          xyz.asm):01417                 LDB     #0              optim: optimizeStackOperations1
0609 E784             (          xyz.asm):01418                 STB     ,X
                      (          xyz.asm):01419         * Useless label L00226 removed
                      (          xyz.asm):01420         * Line xyz.c:183: for increment(s)
060B EC5E             (          xyz.asm):01421                 LDD     -2,U
060D C30001           (          xyz.asm):01422                 ADDD    #1
0610 ED5E             (          xyz.asm):01423                 STD     -2,U
     0612             (          xyz.asm):01424         L00225  EQU     *
                      (          xyz.asm):01425         * Line xyz.c:183: for condition
0612 EC5E             (          xyz.asm):01426                 LDD     -2,U            variable i
0614 10A346           (          xyz.asm):01427                 CMPD    6,U             variable n
0617 2DE7             (          xyz.asm):01428                 BLT     L00224
                      (          xyz.asm):01429         * optim: branchToNextLocation
                      (          xyz.asm):01430         * Useless label L00227 removed
                      (          xyz.asm):01431         * Useless label L00017 removed
0619 32C4             (          xyz.asm):01432                 LEAS    ,U
061B 35C0             (          xyz.asm):01433                 PULS    U,PC
                      (          xyz.asm):01434         * END FUNCTION bzero(): defined at xyz.c:182
     061D             (          xyz.asm):01435         funcend_bzero   EQU *
     002E             (          xyz.asm):01436         funcsize_bzero  EQU     funcend_bzero-_bzero
                      (          xyz.asm):01437         
                      (          xyz.asm):01438         
                      (          xyz.asm):01439         *******************************************************************************
                      (          xyz.asm):01440         
                      (          xyz.asm):01441         * FUNCTION exit(): defined at xyz.c:17
     061D             (          xyz.asm):01442         _exit   EQU     *
                      (          xyz.asm):01443         * Formal parameters and locals:
                      (          xyz.asm):01444         *   status: int; 2 bytes at 4,U
                      (          xyz.asm):01445         * Line xyz.c:18: inline assembly
                      (          xyz.asm):01446         * Inline assembly:
                      (          xyz.asm):01447         
                      (          xyz.asm):01448         
061D EC62             (          xyz.asm):01449           ldd 2,s ; status code in b.
061F 103F06           (          xyz.asm):01450           os9 F_Exit
                      (          xyz.asm):01451         
                      (          xyz.asm):01452         
                      (          xyz.asm):01453         * End of inline assembly.
                      (          xyz.asm):01454         * Useless label L00003 removed
0622 39               (          xyz.asm):01455                 RTS
                      (          xyz.asm):01456         * END FUNCTION exit(): defined at xyz.c:17
     0623             (          xyz.asm):01457         funcend_exit    EQU *
     0006             (          xyz.asm):01458         funcsize_exit   EQU     funcend_exit-_exit
                      (          xyz.asm):01459         
                      (          xyz.asm):01460         
                      (          xyz.asm):01461         *******************************************************************************
                      (          xyz.asm):01462         
                      (          xyz.asm):01463         * FUNCTION free(): defined at xyz.c:322
     0623             (          xyz.asm):01464         _free   EQU     *
0623 3440             (          xyz.asm):01465                 PSHS    U
0625 172424           (          xyz.asm):01466                 LBSR    _stkcheck
0628 FFBA             (          xyz.asm):01467                 FDB     -70             argument for _stkcheck
062A 33E4             (          xyz.asm):01468                 LEAU    ,S
062C 327A             (          xyz.asm):01469                 LEAS    -6,S
                      (          xyz.asm):01470         * Formal parameters and locals:
                      (          xyz.asm):01471         *   p: void *; 2 bytes at 4,U
                      (          xyz.asm):01472         *   h: struct Head *; 2 bytes at -6,U
                      (          xyz.asm):01473         *   i: int; 2 bytes at -4,U
                      (          xyz.asm):01474         *   cap: int; 2 bytes at -2,U
                      (          xyz.asm):01475         * Line xyz.c:323: if
062E EC44             (          xyz.asm):01476                 LDD     4,U             variable p, declared at xyz.c:322
                      (          xyz.asm):01477         * optim: loadCmpZeroBeqOrBne
0630 2603             (          xyz.asm):01478                 BNE     L00229
                      (          xyz.asm):01479         * optim: branchToNextLocation
                      (          xyz.asm):01480         * Useless label L00228 removed
0632 1600C2           (          xyz.asm):01481                 LBRA    L00024          return (xyz.c:323)
     0635             (          xyz.asm):01482         L00229  EQU     *               else
                      (          xyz.asm):01483         * Useless label L00230 removed
                      (          xyz.asm):01484         * Line xyz.c:326: init of variable h
0635 4F               (          xyz.asm):01485                 CLRA
0636 C601             (          xyz.asm):01486                 LDB     #$01            decimal 1 signed
0638 1F01             (          xyz.asm):01487                 TFR     D,X             optim: pushLoadDLoadX
063A EC44             (          xyz.asm):01488                 LDD     4,U             variable p, declared at xyz.c:322
                      (          xyz.asm):01489         *
063C 3406             (          xyz.asm):01490                 PSHS    B,A             save left side (the pointer)
063E CC0006           (          xyz.asm):01491                 LDD     #6              size of array element
0641 1727BC           (          xyz.asm):01492                 LBSR    MUL16           multiply array index by size of array element, result in D
0644 1F01             (          xyz.asm):01493                 TFR     D,X             right side in X
0646 3506             (          xyz.asm):01494                 PULS    A,B             pointer in D
0648 3410             (          xyz.asm):01495                 PSHS    X               right side on stack
064A A3E1             (          xyz.asm):01496                 SUBD    ,S++            subtract integer from pointer
064C ED5A             (          xyz.asm):01497                 STD     -6,U            variable h
                      (          xyz.asm):01498         * Line xyz.c:327: if
064E C641             (          xyz.asm):01499                 LDB     #$41            optim: lddToLDB
0650 1D               (          xyz.asm):01500                 SEX                     promotion of binary operand
0651 3406             (          xyz.asm):01501                 PSHS    B,A
                      (          xyz.asm):01502         * optim: optimizeLdx
0653 E6D8FA           (          xyz.asm):01503                 LDB     [-6,U]          optim: optimizeLdx
0656 1D               (          xyz.asm):01504                 SEX                     promotion of binary operand
0657 10A3E1           (          xyz.asm):01505                 CMPD    ,S++
065A 270B             (          xyz.asm):01506                 BEQ     L00232
                      (          xyz.asm):01507         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01508         * Useless label L00231 removed
                      (          xyz.asm):01509         * Line xyz.c:327: function call: panic()
065C 308D25B1         (          xyz.asm):01510                 LEAX    S00092,PCR      "free: corrupt magicA"
0660 3410             (          xyz.asm):01511                 PSHS    X               argument 1 of panic(): const char[]
0662 170379           (          xyz.asm):01512                 LBSR    _panic
0665 3262             (          xyz.asm):01513                 LEAS    2,S
     0667             (          xyz.asm):01514         L00232  EQU     *               else
                      (          xyz.asm):01515         * Useless label L00233 removed
                      (          xyz.asm):01516         * Line xyz.c:328: if
0667 C65A             (          xyz.asm):01517                 LDB     #$5A            optim: lddToLDB
0669 1D               (          xyz.asm):01518                 SEX                     promotion of binary operand
066A 3406             (          xyz.asm):01519                 PSHS    B,A
066C AE5A             (          xyz.asm):01520                 LDX     -6,U            variable h
066E E605             (          xyz.asm):01521                 LDB     5,X             member magicZ of Head
0670 1D               (          xyz.asm):01522                 SEX                     promotion of binary operand
0671 10A3E1           (          xyz.asm):01523                 CMPD    ,S++
0674 270B             (          xyz.asm):01524                 BEQ     L00235
                      (          xyz.asm):01525         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01526         * Useless label L00234 removed
                      (          xyz.asm):01527         * Line xyz.c:328: function call: panic()
0676 308D25AC         (          xyz.asm):01528                 LEAX    S00093,PCR      "free: corrupt magicZ"
067A 3410             (          xyz.asm):01529                 PSHS    X               argument 1 of panic(): const char[]
067C 17035F           (          xyz.asm):01530                 LBSR    _panic
067F 3262             (          xyz.asm):01531                 LEAS    2,S
     0681             (          xyz.asm):01532         L00235  EQU     *               else
                      (          xyz.asm):01533         * Useless label L00236 removed
                      (          xyz.asm):01534         * Line xyz.c:331: init of variable cap
0681 4F               (          xyz.asm):01535                 CLRA
0682 C608             (          xyz.asm):01536                 LDB     #$08            8
0684 ED5E             (          xyz.asm):01537                 STD     -2,U            variable cap
                      (          xyz.asm):01538         * Line xyz.c:332: for init
                      (          xyz.asm):01539         * Line xyz.c:332: assignment: =
                      (          xyz.asm):01540         * optim: stripExtraClrA_B
0686 5F               (          xyz.asm):01541                 CLRB
0687 ED5C             (          xyz.asm):01542                 STD     -4,U
0689 2018             (          xyz.asm):01543                 BRA     L00238          jump to for condition
     068B             (          xyz.asm):01544         L00237  EQU     *
                      (          xyz.asm):01545         * Line xyz.c:332: for body
                      (          xyz.asm):01546         * Line xyz.c:333: if
                      (          xyz.asm):01547         * optim: optimizeStackOperations4
                      (          xyz.asm):01548         * optim: optimizeStackOperations4
068B AE5A             (          xyz.asm):01549                 LDX     -6,U            variable h
068D EC03             (          xyz.asm):01550                 LDD     3,X             member cap of Head
068F 10A35E           (          xyz.asm):01551                 CMPD    -2,U            optim: optimizeStackOperations4
0692 2602             (          xyz.asm):01552                 BNE     L00242
                      (          xyz.asm):01553         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01554         * Useless label L00241 removed
0694 2015             (          xyz.asm):01555                 BRA     L00240          break
     0696             (          xyz.asm):01556         L00242  EQU     *               else
                      (          xyz.asm):01557         * Useless label L00243 removed
                      (          xyz.asm):01558         * Line xyz.c:334: assignment: +=
0696 EC5E             (          xyz.asm):01559                 LDD     -2,U            variable cap
0698 E35E             (          xyz.asm):01560                 ADDD    -2,U            variable cap
069A ED5E             (          xyz.asm):01561                 STD     -2,U            variable cap
                      (          xyz.asm):01562         * Useless label L00239 removed
                      (          xyz.asm):01563         * Line xyz.c:332: for increment(s)
069C EC5C             (          xyz.asm):01564                 LDD     -4,U
069E C30001           (          xyz.asm):01565                 ADDD    #1
06A1 ED5C             (          xyz.asm):01566                 STD     -4,U
     06A3             (          xyz.asm):01567         L00238  EQU     *
                      (          xyz.asm):01568         * Line xyz.c:332: for condition
06A3 EC5C             (          xyz.asm):01569                 LDD     -4,U            variable i
06A5 1083000A         (          xyz.asm):01570                 CMPD    #$0A
06A9 2DE0             (          xyz.asm):01571                 BLT     L00237
                      (          xyz.asm):01572         * optim: branchToNextLocation
     06AB             (          xyz.asm):01573         L00240  EQU     *               end for
                      (          xyz.asm):01574         * Line xyz.c:336: if
06AB EC5C             (          xyz.asm):01575                 LDD     -4,U            variable i
06AD 1083000A         (          xyz.asm):01576                 CMPD    #$0A
06B1 2D1B             (          xyz.asm):01577                 BLT     L00245
                      (          xyz.asm):01578         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01579         * Useless label L00244 removed
                      (          xyz.asm):01580         * Line xyz.c:337: function call: puthex()
06B3 AE5A             (          xyz.asm):01581                 LDX     -6,U            variable h
06B5 EC03             (          xyz.asm):01582                 LDD     3,X             member cap of Head
06B7 3406             (          xyz.asm):01583                 PSHS    B,A             argument 2 of puthex(): int
06B9 C663             (          xyz.asm):01584                 LDB     #$63            optim: lddToLDB
06BB 1D               (          xyz.asm):01585                 SEX                     promoting byte argument to word
06BC 3406             (          xyz.asm):01586                 PSHS    B,A             argument 1 of puthex(): char
06BE 1720F8           (          xyz.asm):01587                 LBSR    _puthex
06C1 3264             (          xyz.asm):01588                 LEAS    4,S
                      (          xyz.asm):01589         * Line xyz.c:338: function call: panic()
06C3 308D2574         (          xyz.asm):01590                 LEAX    S00094,PCR      "corrupt free"
06C7 3410             (          xyz.asm):01591                 PSHS    X               argument 1 of panic(): const char[]
06C9 170312           (          xyz.asm):01592                 LBSR    _panic
06CC 3262             (          xyz.asm):01593                 LEAS    2,S
     06CE             (          xyz.asm):01594         L00245  EQU     *               else
                      (          xyz.asm):01595         * Useless label L00246 removed
                      (          xyz.asm):01596         * Line xyz.c:341: function call: bzero()
06CE EC5E             (          xyz.asm):01597                 LDD     -2,U            variable cap, declared at xyz.c:331
06D0 3406             (          xyz.asm):01598                 PSHS    B,A             argument 2 of bzero(): int
06D2 EC44             (          xyz.asm):01599                 LDD     4,U             variable p, declared at xyz.c:322
06D4 3406             (          xyz.asm):01600                 PSHS    B,A             argument 1 of bzero(): char *
06D6 17FF16           (          xyz.asm):01601                 LBSR    _bzero
06D9 3264             (          xyz.asm):01602                 LEAS    4,S
                      (          xyz.asm):01603         * Line xyz.c:343: assignment: =
06DB 3024             (          xyz.asm):01604                 LEAX    _ram_roots+0,Y  address of array ram_roots
06DD EC5C             (          xyz.asm):01605                 LDD     -4,U            variable i
06DF 58               (          xyz.asm):01606                 LSLB
06E0 49               (          xyz.asm):01607                 ROLA
                      (          xyz.asm):01608         * optimizeLoadDX
06E1 EC8B             (          xyz.asm):01609                 LDD     D,X             get r-value
                      (          xyz.asm):01610         * optim: stripUselessPushPull
06E3 AE5A             (          xyz.asm):01611                 LDX     -6,U            variable h
                      (          xyz.asm):01612         * optim: optimizeLeax
                      (          xyz.asm):01613         * optim: stripUselessPushPull
06E5 ED01             (          xyz.asm):01614                 STD     1,X             optim: optimizeLeax
                      (          xyz.asm):01615         * Line xyz.c:344: assignment: =
06E7 EC5A             (          xyz.asm):01616                 LDD     -6,U            variable h, declared at xyz.c:326
06E9 3406             (          xyz.asm):01617                 PSHS    B,A
06EB 3024             (          xyz.asm):01618                 LEAX    _ram_roots+0,Y  address of array ram_roots
06ED EC5C             (          xyz.asm):01619                 LDD     -4,U            variable i
06EF 58               (          xyz.asm):01620                 LSLB
06F0 49               (          xyz.asm):01621                 ROLA
06F1 308B             (          xyz.asm):01622                 LEAX    D,X             add byte offset
06F3 3506             (          xyz.asm):01623                 PULS    A,B             retrieve value to store
06F5 ED84             (          xyz.asm):01624                 STD     ,X
     06F7             (          xyz.asm):01625         L00024  EQU     *               end of free()
06F7 32C4             (          xyz.asm):01626                 LEAS    ,U
06F9 35C0             (          xyz.asm):01627                 PULS    U,PC
                      (          xyz.asm):01628         * END FUNCTION free(): defined at xyz.c:322
     06FB             (          xyz.asm):01629         funcend_free    EQU *
     00D8             (          xyz.asm):01630         funcsize_free   EQU     funcend_free-_free
                      (          xyz.asm):01631         
                      (          xyz.asm):01632         
                      (          xyz.asm):01633         *******************************************************************************
                      (          xyz.asm):01634         
                      (          xyz.asm):01635         * FUNCTION gets(): defined at xyz.c:52
     06FB             (          xyz.asm):01636         _gets   EQU     *
                      (          xyz.asm):01637         * Formal parameters and locals:
                      (          xyz.asm):01638         *   buf: char *; 2 bytes at 4,U
                      (          xyz.asm):01639         * Line xyz.c:53: inline assembly
                      (          xyz.asm):01640         * Inline assembly:
                      (          xyz.asm):01641         
                      (          xyz.asm):01642         
06FB 3460             (          xyz.asm):01643           pshs y,u
06FD 4F               (          xyz.asm):01644           clra ; path 0
06FE 108E00C8         (          xyz.asm):01645           ldy #200
0702 AE66             (          xyz.asm):01646           ldx 6,s
0704 103F8B           (          xyz.asm):01647           os9 I_ReadLn
0707 2504             (          xyz.asm):01648           bcs returnNULL
0709 EC66             (          xyz.asm):01649           ldd 6,s ; return buf
070B 35E0             (          xyz.asm):01650           puls y,u,pc
070D 4F               (          xyz.asm):01651         returnNULL clra ; return 0
070E 5F               (          xyz.asm):01652           clrb
070F 35E0             (          xyz.asm):01653           puls y,u,pc
                      (          xyz.asm):01654         
                      (          xyz.asm):01655         
                      (          xyz.asm):01656         * End of inline assembly.
                      (          xyz.asm):01657         * Useless label L00006 removed
0711 39               (          xyz.asm):01658                 RTS
                      (          xyz.asm):01659         * END FUNCTION gets(): defined at xyz.c:52
     0712             (          xyz.asm):01660         funcend_gets    EQU *
     0017             (          xyz.asm):01661         funcsize_gets   EQU     funcend_gets-_gets
                      (          xyz.asm):01662         
                      (          xyz.asm):01663         
                      (          xyz.asm):01664         *******************************************************************************
                      (          xyz.asm):01665         
                      (          xyz.asm):01666         * FUNCTION hexchar(): defined at xyz.c:85
     0712             (          xyz.asm):01667         _hexchar        EQU     *
0712 3440             (          xyz.asm):01668                 PSHS    U
0714 172335           (          xyz.asm):01669                 LBSR    _stkcheck
0717 FFC0             (          xyz.asm):01670                 FDB     -64             argument for _stkcheck
0719 33E4             (          xyz.asm):01671                 LEAU    ,S
                      (          xyz.asm):01672         * Formal parameters and locals:
                      (          xyz.asm):01673         *   i: unsigned char; 1 byte at 5,U
                      (          xyz.asm):01674         * Line xyz.c:86: if
071B E645             (          xyz.asm):01675                 LDB     5,U             variable i, declared at xyz.c:85
071D 4F               (          xyz.asm):01676                 CLRA                    promotion of binary operand
071E 3406             (          xyz.asm):01677                 PSHS    B,A
                      (          xyz.asm):01678         * optim: stripExtraClrA_B
0720 5F               (          xyz.asm):01679                 CLRB
0721 10A3E1           (          xyz.asm):01680                 CMPD    ,S++
0724 2212             (          xyz.asm):01681                 BHI     L00248
                      (          xyz.asm):01682         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01683         * Useless label L00249 removed
0726 E645             (          xyz.asm):01684                 LDB     5,U             variable i
0728 C109             (          xyz.asm):01685                 CMPB    #$09
072A 220C             (          xyz.asm):01686                 BHI     L00248
                      (          xyz.asm):01687         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01688         * Useless label L00247 removed
                      (          xyz.asm):01689         * Line xyz.c:86: return with value
072C E645             (          xyz.asm):01690                 LDB     5,U             variable i, declared at xyz.c:85
072E 4F               (          xyz.asm):01691                 CLRA                    promotion of binary operand
072F 3404             (          xyz.asm):01692                 PSHS    B               optim: stripPushLeas
0731 C630             (          xyz.asm):01693                 LDB     #$30            optim: changeLoadDToLoadB
0733 1D               (          xyz.asm):01694                 SEX                     promotion of binary operand
                      (          xyz.asm):01695         * optim: stripPushLeas1
0734 EBE0             (          xyz.asm):01696                 ADDB    ,S+
0736 202A             (          xyz.asm):01697                 BRA     L00008          return (xyz.c:86)
     0738             (          xyz.asm):01698         L00248  EQU     *               else
                      (          xyz.asm):01699         * Useless label L00250 removed
                      (          xyz.asm):01700         * Line xyz.c:87: if
0738 E645             (          xyz.asm):01701                 LDB     5,U             variable i, declared at xyz.c:85
073A 4F               (          xyz.asm):01702                 CLRA                    promotion of binary operand
073B 3406             (          xyz.asm):01703                 PSHS    B,A
073D C60A             (          xyz.asm):01704                 LDB     #$0A            optim: changeLoadDToLoadB
073F 10A3E1           (          xyz.asm):01705                 CMPD    ,S++
0742 221B             (          xyz.asm):01706                 BHI     L00252
                      (          xyz.asm):01707         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01708         * Useless label L00253 removed
0744 E645             (          xyz.asm):01709                 LDB     5,U             variable i
0746 C10F             (          xyz.asm):01710                 CMPB    #$0F
0748 2215             (          xyz.asm):01711                 BHI     L00252
                      (          xyz.asm):01712         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01713         * Useless label L00251 removed
                      (          xyz.asm):01714         * Line xyz.c:87: return with value
074A 4F               (          xyz.asm):01715                 CLRA
074B C60A             (          xyz.asm):01716                 LDB     #$0A            decimal 10 signed
074D 3406             (          xyz.asm):01717                 PSHS    B,A
074F E645             (          xyz.asm):01718                 LDB     5,U             variable i, declared at xyz.c:85
                      (          xyz.asm):01719         * optim: stripExtraClrA_B
0751 3404             (          xyz.asm):01720                 PSHS    B               optim: stripPushLeas
0753 C641             (          xyz.asm):01721                 LDB     #$41            optim: changeLoadDToLoadB
0755 1D               (          xyz.asm):01722                 SEX                     promotion of binary operand
                      (          xyz.asm):01723         * optim: stripPushLeas1
0756 EBE0             (          xyz.asm):01724                 ADDB    ,S+
0758 1D               (          xyz.asm):01725                 SEX                     promotion of binary operand
0759 3261             (          xyz.asm):01726                 LEAS    1,S
075B E0E0             (          xyz.asm):01727                 SUBB    ,S+
075D 2003             (          xyz.asm):01728                 BRA     L00008          return (xyz.c:87)
     075F             (          xyz.asm):01729         L00252  EQU     *               else
                      (          xyz.asm):01730         * Useless label L00254 removed
                      (          xyz.asm):01731         * Line xyz.c:88: return with value
075F 4F               (          xyz.asm):01732                 CLRA
0760 C63F             (          xyz.asm):01733                 LDB     #$3F            decimal 63 signed
                      (          xyz.asm):01734         * optim: branchToNextLocation
     0762             (          xyz.asm):01735         L00008  EQU     *               end of hexchar()
0762 32C4             (          xyz.asm):01736                 LEAS    ,U
0764 35C0             (          xyz.asm):01737                 PULS    U,PC
                      (          xyz.asm):01738         * END FUNCTION hexchar(): defined at xyz.c:85
     0766             (          xyz.asm):01739         funcend_hexchar EQU *
     0054             (          xyz.asm):01740         funcsize_hexchar        EQU     funcend_hexchar-_hexchar
                      (          xyz.asm):01741         
                      (          xyz.asm):01742         
                      (          xyz.asm):01743         *******************************************************************************
                      (          xyz.asm):01744         
                      (          xyz.asm):01745         * FUNCTION main(): defined at xyz.c:1290
     0766             (          xyz.asm):01746         _main   EQU     *
0766 3440             (          xyz.asm):01747                 PSHS    U
0768 1722E1           (          xyz.asm):01748                 LBSR    _stkcheck
076B FF62             (          xyz.asm):01749                 FDB     -158            argument for _stkcheck
076D 33E4             (          xyz.asm):01750                 LEAU    ,S
076F 32E8A2           (          xyz.asm):01751                 LEAS    -94,S
                      (          xyz.asm):01752         * Formal parameters and locals:
                      (          xyz.asm):01753         *   argc: int; 2 bytes at 4,U
                      (          xyz.asm):01754         *   argv: char **; 2 bytes at 6,U
                      (          xyz.asm):01755         *   line: char[]; 80 bytes at -88,U
                      (          xyz.asm):01756         *   interp: struct picolInterp; 8 bytes at -8,U
                      (          xyz.asm):01757         * Line xyz.c:1293: function call: puts()
0772 308D264F         (          xyz.asm):01758                 LEAX    S00141,PCR      " *alpha* "
0776 3410             (          xyz.asm):01759                 PSHS    X               argument 1 of puts(): const char[]
0778 1720CD           (          xyz.asm):01760                 LBSR    _puts
077B 3262             (          xyz.asm):01761                 LEAS    2,S
                      (          xyz.asm):01762         * Line xyz.c:1294: function call: picolInitInterp()
077D 3058             (          xyz.asm):01763                 LEAX    -8,U            variable interp, declared at xyz.c:1292
077F 3410             (          xyz.asm):01764                 PSHS    X               argument 1 of picolInitInterp(): struct picolInterp *
0781 1715B1           (          xyz.asm):01765                 LBSR    _picolInitInterp
0784 3262             (          xyz.asm):01766                 LEAS    2,S
                      (          xyz.asm):01767         * Line xyz.c:1295: function call: puts()
0786 308D2645         (          xyz.asm):01768                 LEAX    S00142,PCR      " *beta* "
078A 3410             (          xyz.asm):01769                 PSHS    X               argument 1 of puts(): const char[]
078C 1720B9           (          xyz.asm):01770                 LBSR    _puts
078F 3262             (          xyz.asm):01771                 LEAS    2,S
                      (          xyz.asm):01772         * Line xyz.c:1296: function call: picolRegisterCoreCommands()
0791 3058             (          xyz.asm):01773                 LEAX    -8,U            variable interp, declared at xyz.c:1292
0793 3410             (          xyz.asm):01774                 PSHS    X               argument 1 of picolRegisterCoreCommands(): struct picolInterp *
0795 171CFD           (          xyz.asm):01775                 LBSR    _picolRegisterCoreCommands
0798 3262             (          xyz.asm):01776                 LEAS    2,S
                      (          xyz.asm):01777         * Line xyz.c:1297: function call: puts()
079A 308D263A         (          xyz.asm):01778                 LEAX    S00143,PCR      " *gamma* "
079E 3410             (          xyz.asm):01779                 PSHS    X               argument 1 of puts(): const char[]
07A0 1720A5           (          xyz.asm):01780                 LBSR    _puts
07A3 3262             (          xyz.asm):01781                 LEAS    2,S
                      (          xyz.asm):01782         * Line xyz.c:1299: while
07A5 16009F           (          xyz.asm):01783                 LBRA    L00256          jump to while condition
     07A8             (          xyz.asm):01784         L00255  EQU     *               while body
                      (          xyz.asm):01785         * Line xyz.c:1301: function call: puts()
07A8 308D2636         (          xyz.asm):01786                 LEAX    S00144,PCR      " >picol> "
07AC 3410             (          xyz.asm):01787                 PSHS    X               argument 1 of puts(): const char[]
07AE 172097           (          xyz.asm):01788                 LBSR    _puts
07B1 3262             (          xyz.asm):01789                 LEAS    2,S
                      (          xyz.asm):01790         * Line xyz.c:1302: function call: bzero()
07B3 4F               (          xyz.asm):01791                 CLRA
07B4 C650             (          xyz.asm):01792                 LDB     #$50            constant expression: 80 decimal, unsigned
07B6 3406             (          xyz.asm):01793                 PSHS    B,A             argument 2 of bzero(): unsigned int
07B8 30C8A8           (          xyz.asm):01794                 LEAX    -88,U           address of array line
07BB 3410             (          xyz.asm):01795                 PSHS    X               argument 1 of bzero(): char[]
07BD 17FE2F           (          xyz.asm):01796                 LBSR    _bzero
07C0 3264             (          xyz.asm):01797                 LEAS    4,S
                      (          xyz.asm):01798         * Line xyz.c:1305: init of variable e
                      (          xyz.asm):01799         * Line xyz.c:1305: function call: Os9ReadLn()
07C2 30C8A4           (          xyz.asm):01800                 LEAX    -92,U           variable bytes_read, declared at xyz.c:1304
                      (          xyz.asm):01801         * optim: optimizePshsOps
07C5 4F               (          xyz.asm):01802                 CLRA
07C6 C650             (          xyz.asm):01803                 LDB     #$50            decimal 80 signed
07C8 3416             (          xyz.asm):01804                 PSHS    X,B,A           optim: optimizePshsOps
07CA 30C8A8           (          xyz.asm):01805                 LEAX    -88,U           address of array line
                      (          xyz.asm):01806         * optim: optimizePshsOps
                      (          xyz.asm):01807         * optim: stripExtraClrA_B
07CD 5F               (          xyz.asm):01808                 CLRB
07CE 3416             (          xyz.asm):01809                 PSHS    X,B,A           optim: optimizePshsOps
07D0 17FA34           (          xyz.asm):01810                 LBSR    _Os9ReadLn
07D3 3268             (          xyz.asm):01811                 LEAS    8,S
07D5 EDC8A6           (          xyz.asm):01812                 STD     -90,U           variable e
                      (          xyz.asm):01813         * Line xyz.c:1306: if
                      (          xyz.asm):01814         * optim: storeLoad
07D8 C30000           (          xyz.asm):01815                 ADDD    #0
07DB 2714             (          xyz.asm):01816                 BEQ     L00259
                      (          xyz.asm):01817         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01818         * Useless label L00258 removed
                      (          xyz.asm):01819         * Line xyz.c:1307: function call: puts()
07DD 308D260B         (          xyz.asm):01820                 LEAX    S00145,PCR      " *EOF*\r"
07E1 3410             (          xyz.asm):01821                 PSHS    X               argument 1 of puts(): const char[]
07E3 172062           (          xyz.asm):01822                 LBSR    _puts
07E6 3262             (          xyz.asm):01823                 LEAS    2,S
                      (          xyz.asm):01824         * Line xyz.c:1308: function call: exit()
07E8 4F               (          xyz.asm):01825                 CLRA
07E9 5F               (          xyz.asm):01826                 CLRB
07EA 3406             (          xyz.asm):01827                 PSHS    B,A             argument 1 of exit(): int
07EC 17FE2E           (          xyz.asm):01828                 LBSR    _exit
07EF 3262             (          xyz.asm):01829                 LEAS    2,S
     07F1             (          xyz.asm):01830         L00259  EQU     *               else
                      (          xyz.asm):01831         * Useless label L00260 removed
                      (          xyz.asm):01832         * Line xyz.c:1310: function call: ReduceBigraphs()
07F1 30C8A8           (          xyz.asm):01833                 LEAX    -88,U           address of array line
07F4 3410             (          xyz.asm):01834                 PSHS    X               argument 1 of ReduceBigraphs(): char[]
07F6 17FA63           (          xyz.asm):01835                 LBSR    _ReduceBigraphs
07F9 3262             (          xyz.asm):01836                 LEAS    2,S
                      (          xyz.asm):01837         * Line xyz.c:1311: assignment: =
                      (          xyz.asm):01838         * Line xyz.c:1311: function call: picolEval()
07FB 30C8A8           (          xyz.asm):01839                 LEAX    -88,U           address of array line
07FE 3410             (          xyz.asm):01840                 PSHS    X               argument 2 of picolEval(): char[]
0800 3058             (          xyz.asm):01841                 LEAX    -8,U            variable interp, declared at xyz.c:1292
0802 3410             (          xyz.asm):01842                 PSHS    X               argument 1 of picolEval(): struct picolInterp *
0804 170FE9           (          xyz.asm):01843                 LBSR    _picolEval
0807 3264             (          xyz.asm):01844                 LEAS    4,S
0809 EDC8A2           (          xyz.asm):01845                 STD     -94,U
                      (          xyz.asm):01846         * Line xyz.c:1312: if
                      (          xyz.asm):01847         * optim: optimizeLdx
                      (          xyz.asm):01848         * optim: removeTfrDX
080C E6D8FE           (          xyz.asm):01849                 LDB     [-2,U]          optim: optimizeLdx
                      (          xyz.asm):01850         * optim: loadCmpZeroBeqOrBne
080F 2736             (          xyz.asm):01851                 BEQ     L00262
                      (          xyz.asm):01852         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01853         * Useless label L00261 removed
                      (          xyz.asm):01854         * Line xyz.c:1313: function call: snprintf_d()
0811 ECC8A2           (          xyz.asm):01855                 LDD     -94,U           variable retcode, declared at xyz.c:1300
0814 3406             (          xyz.asm):01856                 PSHS    B,A             argument 4 of snprintf_d(): int
0816 308D25DA         (          xyz.asm):01857                 LEAX    S00146,PCR      "[%d] <<"
                      (          xyz.asm):01858         * optim: optimizePshsOps
081A 4F               (          xyz.asm):01859                 CLRA
081B C650             (          xyz.asm):01860                 LDB     #$50            decimal 80 signed
081D 3416             (          xyz.asm):01861                 PSHS    X,B,A           optim: optimizePshsOps
081F 30C8A8           (          xyz.asm):01862                 LEAX    -88,U           address of array line
0822 3410             (          xyz.asm):01863                 PSHS    X               argument 1 of snprintf_d(): char[]
0824 17208D           (          xyz.asm):01864                 LBSR    _snprintf_d
0827 3268             (          xyz.asm):01865                 LEAS    8,S
                      (          xyz.asm):01866         * Line xyz.c:1314: function call: puts()
0829 30C8A8           (          xyz.asm):01867                 LEAX    -88,U           address of array line
082C 3410             (          xyz.asm):01868                 PSHS    X               argument 1 of puts(): char[]
082E 172017           (          xyz.asm):01869                 LBSR    _puts
0831 3262             (          xyz.asm):01870                 LEAS    2,S
                      (          xyz.asm):01871         * Line xyz.c:1315: function call: puts()
0833 EC5E             (          xyz.asm):01872                 LDD     -2,U            member result of picolInterp, via variable interp
0835 3406             (          xyz.asm):01873                 PSHS    B,A             argument 1 of puts(): char *
0837 17200E           (          xyz.asm):01874                 LBSR    _puts
083A 3262             (          xyz.asm):01875                 LEAS    2,S
                      (          xyz.asm):01876         * Line xyz.c:1316: function call: puts()
083C 308D25BC         (          xyz.asm):01877                 LEAX    S00147,PCR      ">>\r"
0840 3410             (          xyz.asm):01878                 PSHS    X               argument 1 of puts(): const char[]
0842 172003           (          xyz.asm):01879                 LBSR    _puts
0845 3262             (          xyz.asm):01880                 LEAS    2,S
     0847             (          xyz.asm):01881         L00262  EQU     *               else
                      (          xyz.asm):01882         * Useless label L00263 removed
     0847             (          xyz.asm):01883         L00256  EQU     *               while condition at xyz.c:1299
0847 16FF5E           (          xyz.asm):01884                 LBRA    L00255          go to start of while body
                      (          xyz.asm):01885         * Useless label L00257 removed
                      (          xyz.asm):01886         * Line xyz.c:1319: return with value
                      (          xyz.asm):01887         * optim: instrFollowingUncondBranch
                      (          xyz.asm):01888         * optim: instrFollowingUncondBranch
                      (          xyz.asm):01889         * optim: branchToNextLocation
                      (          xyz.asm):01890         * Useless label L00084 removed
                      (          xyz.asm):01891         * optim: instrFollowingUncondBranch
                      (          xyz.asm):01892         * optim: instrFollowingUncondBranch
                      (          xyz.asm):01893         * END FUNCTION main(): defined at xyz.c:1290
     084A             (          xyz.asm):01894         funcend_main    EQU *
     00E4             (          xyz.asm):01895         funcsize_main   EQU     funcend_main-_main
                      (          xyz.asm):01896         
                      (          xyz.asm):01897         
                      (          xyz.asm):01898         *******************************************************************************
                      (          xyz.asm):01899         
                      (          xyz.asm):01900         * FUNCTION malloc(): defined at xyz.c:279
     084A             (          xyz.asm):01901         _malloc EQU     *
084A 3440             (          xyz.asm):01902                 PSHS    U
084C 1721FD           (          xyz.asm):01903                 LBSR    _stkcheck
084F FFB8             (          xyz.asm):01904                 FDB     -72             argument for _stkcheck
0851 33E4             (          xyz.asm):01905                 LEAU    ,S
0853 3278             (          xyz.asm):01906                 LEAS    -8,S
                      (          xyz.asm):01907         * Formal parameters and locals:
                      (          xyz.asm):01908         *   n: int; 2 bytes at 4,U
                      (          xyz.asm):01909         *   i: int; 2 bytes at -8,U
                      (          xyz.asm):01910         *   cap: int; 2 bytes at -6,U
                      (          xyz.asm):01911         *   h: struct Head *; 2 bytes at -4,U
                      (          xyz.asm):01912         *   p: char *; 2 bytes at -2,U
                      (          xyz.asm):01913         * Line xyz.c:282: init of variable cap
0855 4F               (          xyz.asm):01914                 CLRA
0856 C608             (          xyz.asm):01915                 LDB     #$08            8
0858 ED5A             (          xyz.asm):01916                 STD     -6,U            variable cap
                      (          xyz.asm):01917         * Line xyz.c:283: for init
                      (          xyz.asm):01918         * Line xyz.c:283: assignment: =
                      (          xyz.asm):01919         * optim: stripExtraClrA_B
085A 5F               (          xyz.asm):01920                 CLRB
085B ED58             (          xyz.asm):01921                 STD     -8,U
085D 2016             (          xyz.asm):01922                 BRA     L00265          jump to for condition
     085F             (          xyz.asm):01923         L00264  EQU     *
                      (          xyz.asm):01924         * Line xyz.c:283: for body
                      (          xyz.asm):01925         * Line xyz.c:284: if
085F EC44             (          xyz.asm):01926                 LDD     4,U             variable n
0861 10A35A           (          xyz.asm):01927                 CMPD    -6,U            variable cap
0864 2E02             (          xyz.asm):01928                 BGT     L00269
                      (          xyz.asm):01929         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01930         * Useless label L00268 removed
0866 2015             (          xyz.asm):01931                 BRA     L00267          break
     0868             (          xyz.asm):01932         L00269  EQU     *               else
                      (          xyz.asm):01933         * Useless label L00270 removed
                      (          xyz.asm):01934         * Line xyz.c:285: assignment: +=
0868 EC5A             (          xyz.asm):01935                 LDD     -6,U            variable cap
086A E35A             (          xyz.asm):01936                 ADDD    -6,U            variable cap
086C ED5A             (          xyz.asm):01937                 STD     -6,U            variable cap
                      (          xyz.asm):01938         * Useless label L00266 removed
                      (          xyz.asm):01939         * Line xyz.c:283: for increment(s)
086E EC58             (          xyz.asm):01940                 LDD     -8,U
0870 C30001           (          xyz.asm):01941                 ADDD    #1
0873 ED58             (          xyz.asm):01942                 STD     -8,U
     0875             (          xyz.asm):01943         L00265  EQU     *
                      (          xyz.asm):01944         * Line xyz.c:283: for condition
0875 EC58             (          xyz.asm):01945                 LDD     -8,U            variable i
0877 1083000C         (          xyz.asm):01946                 CMPD    #$0C
087B 2DE2             (          xyz.asm):01947                 BLT     L00264
                      (          xyz.asm):01948         * optim: branchToNextLocation
     087D             (          xyz.asm):01949         L00267  EQU     *               end for
                      (          xyz.asm):01950         * Line xyz.c:287: if
087D EC58             (          xyz.asm):01951                 LDD     -8,U            variable i
087F 1083000A         (          xyz.asm):01952                 CMPD    #$0A
0883 2D19             (          xyz.asm):01953                 BLT     L00272
                      (          xyz.asm):01954         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01955         * Useless label L00271 removed
                      (          xyz.asm):01956         * Line xyz.c:288: function call: puthex()
0885 EC44             (          xyz.asm):01957                 LDD     4,U             variable n, declared at xyz.c:279
0887 3406             (          xyz.asm):01958                 PSHS    B,A             argument 2 of puthex(): int
0889 C66D             (          xyz.asm):01959                 LDB     #$6D            optim: lddToLDB
088B 1D               (          xyz.asm):01960                 SEX                     promoting byte argument to word
088C 3406             (          xyz.asm):01961                 PSHS    B,A             argument 1 of puthex(): char
088E 171F28           (          xyz.asm):01962                 LBSR    _puthex
0891 3264             (          xyz.asm):01963                 LEAS    4,S
                      (          xyz.asm):01964         * Line xyz.c:289: function call: panic()
0893 308D2329         (          xyz.asm):01965                 LEAX    S00087,PCR      "malloc too big"
0897 3410             (          xyz.asm):01966                 PSHS    X               argument 1 of panic(): const char[]
0899 170142           (          xyz.asm):01967                 LBSR    _panic
089C 3262             (          xyz.asm):01968                 LEAS    2,S
     089E             (          xyz.asm):01969         L00272  EQU     *               else
                      (          xyz.asm):01970         * Useless label L00273 removed
                      (          xyz.asm):01971         * Line xyz.c:294: init of variable h
089E 3024             (          xyz.asm):01972                 LEAX    _ram_roots+0,Y  address of array ram_roots
08A0 EC58             (          xyz.asm):01973                 LDD     -8,U            variable i
08A2 58               (          xyz.asm):01974                 LSLB
08A3 49               (          xyz.asm):01975                 ROLA
                      (          xyz.asm):01976         * optimizeLoadDX
08A4 EC8B             (          xyz.asm):01977                 LDD     D,X             get r-value
08A6 ED5C             (          xyz.asm):01978                 STD     -4,U            variable h
                      (          xyz.asm):01979         * Line xyz.c:295: if
                      (          xyz.asm):01980         * optim: storeLoad
08A8 C30000           (          xyz.asm):01981                 ADDD    #0
08AB 10270071         (          xyz.asm):01982                 LBEQ    L00275
                      (          xyz.asm):01983         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01984         * Useless label L00274 removed
                      (          xyz.asm):01985         * Line xyz.c:296: if
08AF C641             (          xyz.asm):01986                 LDB     #$41            optim: lddToLDB
08B1 1D               (          xyz.asm):01987                 SEX                     promotion of binary operand
08B2 3406             (          xyz.asm):01988                 PSHS    B,A
                      (          xyz.asm):01989         * optim: optimizeLdx
08B4 E6D8FC           (          xyz.asm):01990                 LDB     [-4,U]          optim: optimizeLdx
08B7 1D               (          xyz.asm):01991                 SEX                     promotion of binary operand
08B8 10A3E1           (          xyz.asm):01992                 CMPD    ,S++
08BB 270B             (          xyz.asm):01993                 BEQ     L00277
                      (          xyz.asm):01994         * optim: condBranchOverUncondBranch
                      (          xyz.asm):01995         * Useless label L00276 removed
                      (          xyz.asm):01996         * Line xyz.c:296: function call: panic()
08BD 308D230E         (          xyz.asm):01997                 LEAX    S00088,PCR      "malloc: corrupt magicA"
08C1 3410             (          xyz.asm):01998                 PSHS    X               argument 1 of panic(): const char[]
08C3 170118           (          xyz.asm):01999                 LBSR    _panic
08C6 3262             (          xyz.asm):02000                 LEAS    2,S
     08C8             (          xyz.asm):02001         L00277  EQU     *               else
                      (          xyz.asm):02002         * Useless label L00278 removed
                      (          xyz.asm):02003         * Line xyz.c:297: if
08C8 C65A             (          xyz.asm):02004                 LDB     #$5A            optim: lddToLDB
08CA 1D               (          xyz.asm):02005                 SEX                     promotion of binary operand
08CB 3406             (          xyz.asm):02006                 PSHS    B,A
08CD AE5C             (          xyz.asm):02007                 LDX     -4,U            variable h
08CF E605             (          xyz.asm):02008                 LDB     5,X             member magicZ of Head
08D1 1D               (          xyz.asm):02009                 SEX                     promotion of binary operand
08D2 10A3E1           (          xyz.asm):02010                 CMPD    ,S++
08D5 270B             (          xyz.asm):02011                 BEQ     L00280
                      (          xyz.asm):02012         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02013         * Useless label L00279 removed
                      (          xyz.asm):02014         * Line xyz.c:297: function call: panic()
08D7 308D230B         (          xyz.asm):02015                 LEAX    S00089,PCR      "malloc: corrupt magicZ"
08DB 3410             (          xyz.asm):02016                 PSHS    X               argument 1 of panic(): const char[]
08DD 1700FE           (          xyz.asm):02017                 LBSR    _panic
08E0 3262             (          xyz.asm):02018                 LEAS    2,S
     08E2             (          xyz.asm):02019         L00280  EQU     *               else
                      (          xyz.asm):02020         * Useless label L00281 removed
                      (          xyz.asm):02021         * Line xyz.c:298: if
                      (          xyz.asm):02022         * optim: optimizeStackOperations4
                      (          xyz.asm):02023         * optim: optimizeStackOperations4
08E2 AE5C             (          xyz.asm):02024                 LDX     -4,U            variable h
08E4 EC03             (          xyz.asm):02025                 LDD     3,X             member cap of Head
08E6 10A35A           (          xyz.asm):02026                 CMPD    -6,U            optim: optimizeStackOperations4
08E9 270B             (          xyz.asm):02027                 BEQ     L00283
                      (          xyz.asm):02028         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02029         * Useless label L00282 removed
                      (          xyz.asm):02030         * Line xyz.c:298: function call: panic()
08EB 308D230E         (          xyz.asm):02031                 LEAX    S00090,PCR      "corrupt cap"
08EF 3410             (          xyz.asm):02032                 PSHS    X               argument 1 of panic(): const char[]
08F1 1700EA           (          xyz.asm):02033                 LBSR    _panic
08F4 3262             (          xyz.asm):02034                 LEAS    2,S
     08F6             (          xyz.asm):02035         L00283  EQU     *               else
                      (          xyz.asm):02036         * Useless label L00284 removed
                      (          xyz.asm):02037         * Line xyz.c:299: assignment: =
08F6 AE5C             (          xyz.asm):02038                 LDX     -4,U            variable h
08F8 EC01             (          xyz.asm):02039                 LDD     1,X             member next of Head
08FA 3406             (          xyz.asm):02040                 PSHS    B,A
08FC 3024             (          xyz.asm):02041                 LEAX    _ram_roots+0,Y  address of array ram_roots
08FE EC58             (          xyz.asm):02042                 LDD     -8,U            variable i
0900 58               (          xyz.asm):02043                 LSLB
0901 49               (          xyz.asm):02044                 ROLA
0902 308B             (          xyz.asm):02045                 LEAX    D,X             add byte offset
0904 3506             (          xyz.asm):02046                 PULS    A,B             retrieve value to store
0906 ED84             (          xyz.asm):02047                 STD     ,X
                      (          xyz.asm):02048         * Line xyz.c:300: function call: bzero()
0908 EC5A             (          xyz.asm):02049                 LDD     -6,U            variable cap, declared at xyz.c:282
090A 3406             (          xyz.asm):02050                 PSHS    B,A             argument 2 of bzero(): int
090C EC5C             (          xyz.asm):02051                 LDD     -4,U            variable h
090E C30006           (          xyz.asm):02052                 ADDD    #$06            6
0911 3406             (          xyz.asm):02053                 PSHS    B,A             argument 1 of bzero(): char *
0913 17FCD9           (          xyz.asm):02054                 LBSR    _bzero
0916 3264             (          xyz.asm):02055                 LEAS    4,S
                      (          xyz.asm):02056         * Line xyz.c:302: return with value
0918 EC5C             (          xyz.asm):02057                 LDD     -4,U            variable h
091A C30006           (          xyz.asm):02058                 ADDD    #$06            6
091D 160083           (          xyz.asm):02059                 LBRA    L00023          return (xyz.c:302)
     0920             (          xyz.asm):02060         L00275  EQU     *               else
                      (          xyz.asm):02061         * Useless label L00285 removed
                      (          xyz.asm):02062         * Line xyz.c:305: init of variable p
                      (          xyz.asm):02063         * optim: optimizeStackOperations4
                      (          xyz.asm):02064         * optim: optimizeStackOperations4
0920 30A81C           (          xyz.asm):02065                 LEAX    _ram+0,Y        address of array ram
0923 1F10             (          xyz.asm):02066                 TFR     X,D             as r-value
0925 E322             (          xyz.asm):02067                 ADDD    _ram_used+0,Y   optim: optimizeStackOperations4
0927 ED5E             (          xyz.asm):02068                 STD     -2,U            variable p
                      (          xyz.asm):02069         * Line xyz.c:306: assignment: +=
0929 EC5A             (          xyz.asm):02070                 LDD     -6,U            variable cap
092B C30006           (          xyz.asm):02071                 ADDD    #$06            6
092E E322             (          xyz.asm):02072                 ADDD    _ram_used+0,Y   optim: pushDLoadAdd
                      (          xyz.asm):02073         *
                      (          xyz.asm):02074         *
0930 ED22             (          xyz.asm):02075                 STD     _ram_used+0,Y
                      (          xyz.asm):02076         * Line xyz.c:307: if
                      (          xyz.asm):02077         * optim: storeLoad
0932 10832EE0         (          xyz.asm):02078                 CMPD    #$2EE0
0936 2F35             (          xyz.asm):02079                 BLE     L00287
                      (          xyz.asm):02080         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02081         * Useless label L00286 removed
                      (          xyz.asm):02082         * Line xyz.c:308: function call: puthex()
0938 EC44             (          xyz.asm):02083                 LDD     4,U             variable n, declared at xyz.c:279
093A 3406             (          xyz.asm):02084                 PSHS    B,A             argument 2 of puthex(): int
093C C66E             (          xyz.asm):02085                 LDB     #$6E            optim: lddToLDB
093E 1D               (          xyz.asm):02086                 SEX                     promoting byte argument to word
093F 3406             (          xyz.asm):02087                 PSHS    B,A             argument 1 of puthex(): char
0941 171E75           (          xyz.asm):02088                 LBSR    _puthex
0944 3264             (          xyz.asm):02089                 LEAS    4,S
                      (          xyz.asm):02090         * Line xyz.c:309: function call: puthex()
0946 EC5A             (          xyz.asm):02091                 LDD     -6,U            variable cap, declared at xyz.c:282
0948 3406             (          xyz.asm):02092                 PSHS    B,A             argument 2 of puthex(): int
094A C663             (          xyz.asm):02093                 LDB     #$63            optim: lddToLDB
094C 1D               (          xyz.asm):02094                 SEX                     promoting byte argument to word
094D 3406             (          xyz.asm):02095                 PSHS    B,A             argument 1 of puthex(): char
094F 171E67           (          xyz.asm):02096                 LBSR    _puthex
0952 3264             (          xyz.asm):02097                 LEAS    4,S
                      (          xyz.asm):02098         * Line xyz.c:310: function call: puthex()
0954 EC22             (          xyz.asm):02099                 LDD     _ram_used+0,Y   variable ram_used, declared at xyz.c:275
0956 3406             (          xyz.asm):02100                 PSHS    B,A             argument 2 of puthex(): int
0958 C675             (          xyz.asm):02101                 LDB     #$75            optim: lddToLDB
095A 1D               (          xyz.asm):02102                 SEX                     promoting byte argument to word
095B 3406             (          xyz.asm):02103                 PSHS    B,A             argument 1 of puthex(): char
095D 171E59           (          xyz.asm):02104                 LBSR    _puthex
0960 3264             (          xyz.asm):02105                 LEAS    4,S
                      (          xyz.asm):02106         * Line xyz.c:311: function call: panic()
0962 308D22A3         (          xyz.asm):02107                 LEAX    S00091,PCR      " *oom* "
0966 3410             (          xyz.asm):02108                 PSHS    X               argument 1 of panic(): const char[]
0968 170073           (          xyz.asm):02109                 LBSR    _panic
096B 3262             (          xyz.asm):02110                 LEAS    2,S
     096D             (          xyz.asm):02111         L00287  EQU     *               else
                      (          xyz.asm):02112         * Useless label L00288 removed
                      (          xyz.asm):02113         * Line xyz.c:313: assignment: =
096D 4F               (          xyz.asm):02114                 CLRA
096E C601             (          xyz.asm):02115                 LDB     #$01            decimal 1 signed
0970 1F01             (          xyz.asm):02116                 TFR     D,X             optim: pushLoadDLoadX
0972 EC5E             (          xyz.asm):02117                 LDD     -2,U            variable p, declared at xyz.c:305
                      (          xyz.asm):02118         *
0974 3406             (          xyz.asm):02119                 PSHS    B,A             save left side (the pointer)
0976 CC0006           (          xyz.asm):02120                 LDD     #6              size of array element
0979 172484           (          xyz.asm):02121                 LBSR    MUL16           multiply array index by size of array element, result in D
097C 1F01             (          xyz.asm):02122                 TFR     D,X             right side in X
097E 3506             (          xyz.asm):02123                 PULS    A,B             pointer in D
0980 3410             (          xyz.asm):02124                 PSHS    X               right side on stack
0982 A3E1             (          xyz.asm):02125                 SUBD    ,S++            subtract integer from pointer
0984 ED5C             (          xyz.asm):02126                 STD     -4,U
                      (          xyz.asm):02127         * Line xyz.c:314: assignment: =
0986 4F               (          xyz.asm):02128                 CLRA
                      (          xyz.asm):02129         * LDB #$41 optim: optimizeStackOperations1
                      (          xyz.asm):02130         * PSHS B optim: optimizeStackOperations1
                      (          xyz.asm):02131         * optim: optimizeLdx
0987 C641             (          xyz.asm):02132                 LDB     #65             optim: optimizeStackOperations1
0989 E7D8FC           (          xyz.asm):02133                 STB     [-4,U]          optim: optimizeLdx
                      (          xyz.asm):02134         * Line xyz.c:315: assignment: =
                      (          xyz.asm):02135         * LDD #$5A optim: optimizeStackOperations1
                      (          xyz.asm):02136         * PSHS B optim: optimizeStackOperations1
098C AE5C             (          xyz.asm):02137                 LDX     -4,U            variable h
                      (          xyz.asm):02138         * optim: optimizeLeax
098E C65A             (          xyz.asm):02139                 LDB     #90             optim: optimizeStackOperations1
0990 E705             (          xyz.asm):02140                 STB     5,X             optim: optimizeLeax
                      (          xyz.asm):02141         * Line xyz.c:316: assignment: =
0992 EC5A             (          xyz.asm):02142                 LDD     -6,U            variable cap, declared at xyz.c:282
                      (          xyz.asm):02143         * optim: stripUselessPushPull
0994 AE5C             (          xyz.asm):02144                 LDX     -4,U            variable h
                      (          xyz.asm):02145         * optim: optimizeLeax
                      (          xyz.asm):02146         * optim: stripUselessPushPull
0996 ED03             (          xyz.asm):02147                 STD     3,X             optim: optimizeLeax
                      (          xyz.asm):02148         * Line xyz.c:317: assignment: =
0998 4F               (          xyz.asm):02149                 CLRA
0999 5F               (          xyz.asm):02150                 CLRB
                      (          xyz.asm):02151         * optim: stripUselessPushPull
099A AE5C             (          xyz.asm):02152                 LDX     -4,U            variable h
                      (          xyz.asm):02153         * optim: optimizeLeax
                      (          xyz.asm):02154         * optim: stripUselessPushPull
099C ED01             (          xyz.asm):02155                 STD     1,X             optim: optimizeLeax
                      (          xyz.asm):02156         * Line xyz.c:319: return with value
099E EC5C             (          xyz.asm):02157                 LDD     -4,U            variable h
09A0 C30006           (          xyz.asm):02158                 ADDD    #$06            6
                      (          xyz.asm):02159         * optim: branchToNextLocation
     09A3             (          xyz.asm):02160         L00023  EQU     *               end of malloc()
09A3 32C4             (          xyz.asm):02161                 LEAS    ,U
09A5 35C0             (          xyz.asm):02162                 PULS    U,PC
                      (          xyz.asm):02163         * END FUNCTION malloc(): defined at xyz.c:279
     09A7             (          xyz.asm):02164         funcend_malloc  EQU *
     015D             (          xyz.asm):02165         funcsize_malloc EQU     funcend_malloc-_malloc
                      (          xyz.asm):02166         
                      (          xyz.asm):02167         
                      (          xyz.asm):02168         *******************************************************************************
                      (          xyz.asm):02169         
                      (          xyz.asm):02170         * FUNCTION memcpy(): defined at xyz.c:154
     09A7             (          xyz.asm):02171         _memcpy EQU     *
09A7 3440             (          xyz.asm):02172                 PSHS    U
09A9 1720A0           (          xyz.asm):02173                 LBSR    _stkcheck
09AC FFBA             (          xyz.asm):02174                 FDB     -70             argument for _stkcheck
09AE 33E4             (          xyz.asm):02175                 LEAU    ,S
09B0 327A             (          xyz.asm):02176                 LEAS    -6,S
                      (          xyz.asm):02177         * Formal parameters and locals:
                      (          xyz.asm):02178         *   d: void *; 2 bytes at 4,U
                      (          xyz.asm):02179         *   s: const void *; 2 bytes at 6,U
                      (          xyz.asm):02180         *   sz: int; 2 bytes at 8,U
                      (          xyz.asm):02181         *   a: char *; 2 bytes at -6,U
                      (          xyz.asm):02182         *   b: const char *; 2 bytes at -4,U
                      (          xyz.asm):02183         *   i: int; 2 bytes at -2,U
                      (          xyz.asm):02184         * Line xyz.c:155: init of variable a
09B2 EC44             (          xyz.asm):02185                 LDD     4,U             variable d, declared at xyz.c:154
09B4 ED5A             (          xyz.asm):02186                 STD     -6,U            variable a
                      (          xyz.asm):02187         * Line xyz.c:156: init of variable b
09B6 EC46             (          xyz.asm):02188                 LDD     6,U             variable s, declared at xyz.c:154
09B8 ED5C             (          xyz.asm):02189                 STD     -4,U            variable b
                      (          xyz.asm):02190         * Line xyz.c:158: for init
                      (          xyz.asm):02191         * Line xyz.c:158: assignment: =
09BA 4F               (          xyz.asm):02192                 CLRA
09BB 5F               (          xyz.asm):02193                 CLRB
09BC ED5E             (          xyz.asm):02194                 STD     -2,U
09BE 2013             (          xyz.asm):02195                 BRA     L00290          jump to for condition
     09C0             (          xyz.asm):02196         L00289  EQU     *
                      (          xyz.asm):02197         * Line xyz.c:158: for body
                      (          xyz.asm):02198         * Line xyz.c:158: assignment: =
09C0 AE5C             (          xyz.asm):02199                 LDX     -4,U            get pointer b
09C2 E680             (          xyz.asm):02200                 LDB     ,X+             indirection with post-increment
09C4 AF5C             (          xyz.asm):02201                 STX     -4,U            store incremented pointer b
                      (          xyz.asm):02202         * optim: stripExtraPushPullB
09C6 AE5A             (          xyz.asm):02203                 LDX     -6,U            get pointer a
                      (          xyz.asm):02204         * optimiz: optimizePostIncrement
                      (          xyz.asm):02205         * optimiz: optimizePostIncrement
09C8 E780             (          xyz.asm):02206                 STB     ,X+             optimiz: optimizePostIncrement
                      (          xyz.asm):02207         * optim: stripExtraPushPullB
09CA AF5A             (          xyz.asm):02208                 STX     -6,U            optimiz: optimizePostIncrement
                      (          xyz.asm):02209         * Useless label L00291 removed
                      (          xyz.asm):02210         * Line xyz.c:158: for increment(s)
09CC EC5E             (          xyz.asm):02211                 LDD     -2,U
09CE C30001           (          xyz.asm):02212                 ADDD    #1
09D1 ED5E             (          xyz.asm):02213                 STD     -2,U
     09D3             (          xyz.asm):02214         L00290  EQU     *
                      (          xyz.asm):02215         * Line xyz.c:158: for condition
09D3 EC5E             (          xyz.asm):02216                 LDD     -2,U            variable i
09D5 10A348           (          xyz.asm):02217                 CMPD    8,U             variable sz
09D8 2DE6             (          xyz.asm):02218                 BLT     L00289
                      (          xyz.asm):02219         * optim: branchToNextLocation
                      (          xyz.asm):02220         * Useless label L00292 removed
                      (          xyz.asm):02221         * Useless label L00013 removed
09DA 32C4             (          xyz.asm):02222                 LEAS    ,U
09DC 35C0             (          xyz.asm):02223                 PULS    U,PC
                      (          xyz.asm):02224         * END FUNCTION memcpy(): defined at xyz.c:154
     09DE             (          xyz.asm):02225         funcend_memcpy  EQU *
     0037             (          xyz.asm):02226         funcsize_memcpy EQU     funcend_memcpy-_memcpy
                      (          xyz.asm):02227         
                      (          xyz.asm):02228         
                      (          xyz.asm):02229         *******************************************************************************
                      (          xyz.asm):02230         
                      (          xyz.asm):02231         * FUNCTION panic(): defined at xyz.c:109
     09DE             (          xyz.asm):02232         _panic  EQU     *
09DE 3440             (          xyz.asm):02233                 PSHS    U
09E0 172069           (          xyz.asm):02234                 LBSR    _stkcheck
09E3 FFC0             (          xyz.asm):02235                 FDB     -64             argument for _stkcheck
09E5 33E4             (          xyz.asm):02236                 LEAU    ,S
                      (          xyz.asm):02237         * Formal parameters and locals:
                      (          xyz.asm):02238         *   s: const char *; 2 bytes at 4,U
                      (          xyz.asm):02239         * Line xyz.c:110: function call: puthex()
09E7 EC44             (          xyz.asm):02240                 LDD     4,U             variable s, declared at xyz.c:109
09E9 3406             (          xyz.asm):02241                 PSHS    B,A             argument 2 of puthex(): int
09EB C650             (          xyz.asm):02242                 LDB     #$50            optim: lddToLDB
09ED 1D               (          xyz.asm):02243                 SEX                     promoting byte argument to word
09EE 3406             (          xyz.asm):02244                 PSHS    B,A             argument 1 of puthex(): char
09F0 171DC6           (          xyz.asm):02245                 LBSR    _puthex
09F3 3264             (          xyz.asm):02246                 LEAS    4,S
                      (          xyz.asm):02247         * Line xyz.c:111: function call: puts()
09F5 EC44             (          xyz.asm):02248                 LDD     4,U             variable s, declared at xyz.c:109
09F7 3406             (          xyz.asm):02249                 PSHS    B,A             argument 1 of puts(): const char *
09F9 171E4C           (          xyz.asm):02250                 LBSR    _puts
09FC 3262             (          xyz.asm):02251                 LEAS    2,S
                      (          xyz.asm):02252         * Line xyz.c:112: function call: exit()
09FE 4F               (          xyz.asm):02253                 CLRA
09FF C605             (          xyz.asm):02254                 LDB     #$05            decimal 5 signed
0A01 3406             (          xyz.asm):02255                 PSHS    B,A             argument 1 of exit(): int
0A03 17FC17           (          xyz.asm):02256                 LBSR    _exit
0A06 3262             (          xyz.asm):02257                 LEAS    2,S
                      (          xyz.asm):02258         * Useless label L00010 removed
0A08 32C4             (          xyz.asm):02259                 LEAS    ,U
0A0A 35C0             (          xyz.asm):02260                 PULS    U,PC
                      (          xyz.asm):02261         * END FUNCTION panic(): defined at xyz.c:109
     0A0C             (          xyz.asm):02262         funcend_panic   EQU *
     002E             (          xyz.asm):02263         funcsize_panic  EQU     funcend_panic-_panic
                      (          xyz.asm):02264         
                      (          xyz.asm):02265         
                      (          xyz.asm):02266         *******************************************************************************
                      (          xyz.asm):02267         
                      (          xyz.asm):02268         * FUNCTION picolArityErr(): defined at xyz.c:857
     0A0C             (          xyz.asm):02269         _picolArityErr  EQU     *
0A0C 3440             (          xyz.asm):02270                 PSHS    U
0A0E 17203B           (          xyz.asm):02271                 LBSR    _stkcheck
0A11 FEF8             (          xyz.asm):02272                 FDB     -264            argument for _stkcheck
0A13 33E4             (          xyz.asm):02273                 LEAU    ,S
0A15 32E9FF38         (          xyz.asm):02274                 LEAS    -200,S
                      (          xyz.asm):02275         * Formal parameters and locals:
                      (          xyz.asm):02276         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):02277         *   name: char *; 2 bytes at 6,U
                      (          xyz.asm):02278         *   buf: char[]; 200 bytes at -200,U
                      (          xyz.asm):02279         * Line xyz.c:859: function call: snprintf_s()
0A19 EC46             (          xyz.asm):02280                 LDD     6,U             variable name, declared at xyz.c:857
0A1B 3406             (          xyz.asm):02281                 PSHS    B,A             argument 4 of snprintf_s(): char *
0A1D 308D2270         (          xyz.asm):02282                 LEAX    S00099,PCR      "Wrong number of args for %s"
                      (          xyz.asm):02283         * optim: optimizePshsOps
0A21 4F               (          xyz.asm):02284                 CLRA
0A22 C6C8             (          xyz.asm):02285                 LDB     #$C8            decimal 200 signed
0A24 3416             (          xyz.asm):02286                 PSHS    X,B,A           optim: optimizePshsOps
0A26 30C9FF38         (          xyz.asm):02287                 LEAX    -200,U          address of array buf
0A2A 3410             (          xyz.asm):02288                 PSHS    X               argument 1 of snprintf_s(): char[]
0A2C 171F3B           (          xyz.asm):02289                 LBSR    _snprintf_s
0A2F 3268             (          xyz.asm):02290                 LEAS    8,S
                      (          xyz.asm):02291         * Line xyz.c:860: function call: picolSetResult()
0A31 30C9FF38         (          xyz.asm):02292                 LEAX    -200,U          address of array buf
                      (          xyz.asm):02293         * optim: optimizePshsOps
0A35 EC44             (          xyz.asm):02294                 LDD     4,U             variable i, declared at xyz.c:857
0A37 3416             (          xyz.asm):02295                 PSHS    X,B,A           optim: optimizePshsOps
0A39 171C7F           (          xyz.asm):02296                 LBSR    _picolSetResult
0A3C 3264             (          xyz.asm):02297                 LEAS    4,S
                      (          xyz.asm):02298         * Line xyz.c:861: return with value
0A3E 4F               (          xyz.asm):02299                 CLRA
0A3F C601             (          xyz.asm):02300                 LDB     #$01            decimal 1 signed
                      (          xyz.asm):02301         * optim: branchToNextLocation
                      (          xyz.asm):02302         * Useless label L00051 removed
0A41 32C4             (          xyz.asm):02303                 LEAS    ,U
0A43 35C0             (          xyz.asm):02304                 PULS    U,PC
                      (          xyz.asm):02305         * END FUNCTION picolArityErr(): defined at xyz.c:857
     0A45             (          xyz.asm):02306         funcend_picolArityErr   EQU *
     0039             (          xyz.asm):02307         funcsize_picolArityErr  EQU     funcend_picolArityErr-_picolArityErr
                      (          xyz.asm):02308         
                      (          xyz.asm):02309         
                      (          xyz.asm):02310         *******************************************************************************
                      (          xyz.asm):02311         
                      (          xyz.asm):02312         * FUNCTION picolCommandCallProc(): defined at xyz.c:969
     0A45             (          xyz.asm):02313         _picolCommandCallProc   EQU     *
0A45 3440             (          xyz.asm):02314                 PSHS    U
0A47 172002           (          xyz.asm):02315                 LBSR    _stkcheck
0A4A FEE4             (          xyz.asm):02316                 FDB     -284            argument for _stkcheck
0A4C 33E4             (          xyz.asm):02317                 LEAU    ,S
0A4E 32E9FF24         (          xyz.asm):02318                 LEAS    -220,S
                      (          xyz.asm):02319         * Formal parameters and locals:
                      (          xyz.asm):02320         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):02321         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):02322         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):02323         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):02324         *   x: char **; 2 bytes at -218,U
                      (          xyz.asm):02325         *   alist: char *; 2 bytes at -216,U
                      (          xyz.asm):02326         *   body: char *; 2 bytes at -214,U
                      (          xyz.asm):02327         *   p: char *; 2 bytes at -212,U
                      (          xyz.asm):02328         *   tofree: char *; 2 bytes at -210,U
                      (          xyz.asm):02329         *   cf: struct picolCallFrame *; 2 bytes at -208,U
                      (          xyz.asm):02330         *   arity: int; 2 bytes at -206,U
                      (          xyz.asm):02331         *   done: int; 2 bytes at -204,U
                      (          xyz.asm):02332         *   errcode: int; 2 bytes at -202,U
                      (          xyz.asm):02333         *   errbuf: char[]; 200 bytes at -200,U
                      (          xyz.asm):02334         * Line xyz.c:970: init of variable x
0A52 EC4A             (          xyz.asm):02335                 LDD     10,U            variable pd, declared at xyz.c:969
0A54 EDC9FF26         (          xyz.asm):02336                 STD     -218,U          variable x
                      (          xyz.asm):02337         * Line xyz.c:970: init of variable alist
                      (          xyz.asm):02338         * optim: optimizeIndexedX
0A58 ECD9FF26         (          xyz.asm):02339                 LDD     [-218,U]        optim: optimizeIndexedX
0A5C EDC9FF28         (          xyz.asm):02340                 STD     -216,U          variable alist
                      (          xyz.asm):02341         * Line xyz.c:970: init of variable body
0A60 AEC9FF26         (          xyz.asm):02342                 LDX     -218,U          get pointer value
0A64 3002             (          xyz.asm):02343                 LEAX    2,X             add index (1) multiplied by pointed object size (2)
0A66 EC84             (          xyz.asm):02344                 LDD     ,X
0A68 EDC9FF2A         (          xyz.asm):02345                 STD     -214,U          variable body
                      (          xyz.asm):02346         * Line xyz.c:970: init of variable p
                      (          xyz.asm):02347         * Line xyz.c:970: function call: strdup()
0A6C ECC9FF28         (          xyz.asm):02348                 LDD     -216,U          variable alist, declared at xyz.c:970
0A70 3406             (          xyz.asm):02349                 PSHS    B,A             argument 1 of strdup(): char *
0A72 1720D5           (          xyz.asm):02350                 LBSR    _strdup
0A75 3262             (          xyz.asm):02351                 LEAS    2,S
0A77 EDC9FF2C         (          xyz.asm):02352                 STD     -212,U          variable p
                      (          xyz.asm):02353         * Line xyz.c:971: init of variable cf
                      (          xyz.asm):02354         * Line xyz.c:971: function call: malloc()
0A7B 4F               (          xyz.asm):02355                 CLRA
0A7C C604             (          xyz.asm):02356                 LDB     #$04            constant expression: 4 decimal, unsigned
0A7E 3406             (          xyz.asm):02357                 PSHS    B,A             argument 1 of malloc(): unsigned int
0A80 17FDC7           (          xyz.asm):02358                 LBSR    _malloc
0A83 3262             (          xyz.asm):02359                 LEAS    2,S
0A85 EDC9FF30         (          xyz.asm):02360                 STD     -208,U          variable cf
                      (          xyz.asm):02361         * Line xyz.c:972: init of variable arity
0A89 4F               (          xyz.asm):02362                 CLRA
0A8A 5F               (          xyz.asm):02363                 CLRB
0A8B EDC9FF32         (          xyz.asm):02364                 STD     -206,U          variable arity
                      (          xyz.asm):02365         * Line xyz.c:972: init of variable done
                      (          xyz.asm):02366         * optim: stripExtraClrA_B
                      (          xyz.asm):02367         * optim: stripExtraClrA_B
0A8F EDC9FF34         (          xyz.asm):02368                 STD     -204,U          variable done
                      (          xyz.asm):02369         * Line xyz.c:972: init of variable errcode
                      (          xyz.asm):02370         * optim: stripExtraClrA_B
                      (          xyz.asm):02371         * optim: stripExtraClrA_B
0A93 EDC9FF36         (          xyz.asm):02372                 STD     -202,U          variable errcode
                      (          xyz.asm):02373         * Line xyz.c:974: assignment: =
                      (          xyz.asm):02374         * optim: stripExtraClrA_B
                      (          xyz.asm):02375         * optim: stripExtraClrA_B
                      (          xyz.asm):02376         * optim: stripUselessPushPull
                      (          xyz.asm):02377         * optim: optimizeLdx
                      (          xyz.asm):02378         * optim: stripUselessPushPull
0A97 EDD9FF30         (          xyz.asm):02379                 STD     [-208,U]        optim: optimizeLdx
                      (          xyz.asm):02380         * Line xyz.c:975: assignment: =
0A9B AE44             (          xyz.asm):02381                 LDX     4,U             variable i
0A9D EC02             (          xyz.asm):02382                 LDD     2,X             member callframe of picolInterp
                      (          xyz.asm):02383         * optim: stripUselessPushPull
0A9F AEC9FF30         (          xyz.asm):02384                 LDX     -208,U          variable cf
                      (          xyz.asm):02385         * optim: optimizeLeax
                      (          xyz.asm):02386         * optim: stripUselessPushPull
0AA3 ED02             (          xyz.asm):02387                 STD     2,X             optim: optimizeLeax
                      (          xyz.asm):02388         * Line xyz.c:976: assignment: =
0AA5 ECC9FF30         (          xyz.asm):02389                 LDD     -208,U          variable cf, declared at xyz.c:971
                      (          xyz.asm):02390         * optim: stripUselessPushPull
0AA9 AE44             (          xyz.asm):02391                 LDX     4,U             variable i
                      (          xyz.asm):02392         * optim: optimizeLeax
                      (          xyz.asm):02393         * optim: stripUselessPushPull
0AAB ED02             (          xyz.asm):02394                 STD     2,X             optim: optimizeLeax
                      (          xyz.asm):02395         * Line xyz.c:977: assignment: =
                      (          xyz.asm):02396         * optim: stripConsecutiveLoadsToSameReg
0AAD ECC9FF2C         (          xyz.asm):02397                 LDD     -212,U
0AB1 EDC9FF2E         (          xyz.asm):02398                 STD     -210,U
                      (          xyz.asm):02399         * Line xyz.c:978: while
0AB5 1600BD           (          xyz.asm):02400                 LBRA    L00294          jump to while condition
     0AB8             (          xyz.asm):02401         L00293  EQU     *               while body
                      (          xyz.asm):02402         * Line xyz.c:979: init of variable start
0AB8 ECC9FF2C         (          xyz.asm):02403                 LDD     -212,U          variable p, declared at xyz.c:970
0ABC EDC9FF24         (          xyz.asm):02404                 STD     -220,U          variable start
                      (          xyz.asm):02405         * Line xyz.c:980: while
0AC0 200E             (          xyz.asm):02406                 BRA     L00297          jump to while condition
     0AC2             (          xyz.asm):02407         L00296  EQU     *               while body
0AC2 30C9FF2C         (          xyz.asm):02408                 LEAX    -212,U          variable p, declared at xyz.c:970
0AC6 EC84             (          xyz.asm):02409                 LDD     ,X
0AC8 C30001           (          xyz.asm):02410                 ADDD    #1
0ACB ED84             (          xyz.asm):02411                 STD     ,X
0ACD 830001           (          xyz.asm):02412                 SUBD    #1              post increment yields initial value
     0AD0             (          xyz.asm):02413         L00297  EQU     *               while condition at xyz.c:980
0AD0 C620             (          xyz.asm):02414                 LDB     #$20            optim: lddToLDB
0AD2 1D               (          xyz.asm):02415                 SEX                     promotion of binary operand
0AD3 3406             (          xyz.asm):02416                 PSHS    B,A
                      (          xyz.asm):02417         * optim: optimizeLdx
0AD5 E6D9FF2C         (          xyz.asm):02418                 LDB     [-212,U]        optim: optimizeLdx
0AD9 1D               (          xyz.asm):02419                 SEX                     promotion of binary operand
0ADA 10A3E1           (          xyz.asm):02420                 CMPD    ,S++
0ADD 2706             (          xyz.asm):02421                 BEQ     L00298
                      (          xyz.asm):02422         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02423         * Useless label L00299 removed
                      (          xyz.asm):02424         * optim: optimizeIndexedX
0ADF E6D9FF2C         (          xyz.asm):02425                 LDB     [-212,U]        optim: optimizeIndexedX
                      (          xyz.asm):02426         * optim: loadCmpZeroBeqOrBne
0AE3 26DD             (          xyz.asm):02427                 BNE     L00296
                      (          xyz.asm):02428         * optim: branchToNextLocation
     0AE5             (          xyz.asm):02429         L00298  EQU     *               after end of while starting at xyz.c:980
                      (          xyz.asm):02430         * Line xyz.c:981: if
                      (          xyz.asm):02431         * optim: optimizeIndexedX
0AE5 E6D9FF2C         (          xyz.asm):02432                 LDB     [-212,U]        optim: optimizeIndexedX
                      (          xyz.asm):02433         * optim: loadCmpZeroBeqOrBne
0AE9 271C             (          xyz.asm):02434                 BEQ     L00301
                      (          xyz.asm):02435         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02436         * Useless label L00302 removed
                      (          xyz.asm):02437         * optim: optimizeStackOperations4
                      (          xyz.asm):02438         * optim: optimizeStackOperations4
0AEB ECC9FF2C         (          xyz.asm):02439                 LDD     -212,U          variable p, declared at xyz.c:970
0AEF 10A3C9FF24       (          xyz.asm):02440                 CMPD    -220,U          optim: optimizeStackOperations4
0AF4 2611             (          xyz.asm):02441                 BNE     L00301
                      (          xyz.asm):02442         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02443         * Useless label L00300 removed
0AF6 30C9FF2C         (          xyz.asm):02444                 LEAX    -212,U          variable p, declared at xyz.c:970
0AFA EC84             (          xyz.asm):02445                 LDD     ,X
0AFC C30001           (          xyz.asm):02446                 ADDD    #1
0AFF ED84             (          xyz.asm):02447                 STD     ,X
0B01 830001           (          xyz.asm):02448                 SUBD    #1              post increment yields initial value
0B04 16006E           (          xyz.asm):02449                 LBRA    L00294          continue
     0B07             (          xyz.asm):02450         L00301  EQU     *               else
                      (          xyz.asm):02451         * Useless label L00303 removed
                      (          xyz.asm):02452         * Line xyz.c:984: if
                      (          xyz.asm):02453         * optim: optimizeStackOperations4
                      (          xyz.asm):02454         * optim: optimizeStackOperations4
0B07 ECC9FF2C         (          xyz.asm):02455                 LDD     -212,U          variable p, declared at xyz.c:970
0B0B 10A3C9FF24       (          xyz.asm):02456                 CMPD    -220,U          optim: optimizeStackOperations4
0B10 2603             (          xyz.asm):02457                 BNE     L00305
                      (          xyz.asm):02458         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02459         * Useless label L00304 removed
0B12 160063           (          xyz.asm):02460                 LBRA    L00295          break
     0B15             (          xyz.asm):02461         L00305  EQU     *               else
                      (          xyz.asm):02462         * Useless label L00306 removed
                      (          xyz.asm):02463         * Line xyz.c:985: if
                      (          xyz.asm):02464         * optim: optimizeIndexedX
0B15 E6D9FF2C         (          xyz.asm):02465                 LDB     [-212,U]        optim: optimizeIndexedX
                      (          xyz.asm):02466         * optim: loadCmpZeroBeqOrBne
0B19 2609             (          xyz.asm):02467                 BNE     L00308
                      (          xyz.asm):02468         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02469         * Useless label L00307 removed
                      (          xyz.asm):02470         * Line xyz.c:985: assignment: =
0B1B 4F               (          xyz.asm):02471                 CLRA
0B1C C601             (          xyz.asm):02472                 LDB     #$01            decimal 1 signed
0B1E EDC9FF34         (          xyz.asm):02473                 STD     -204,U
0B22 2007             (          xyz.asm):02474                 BRA     L00309          jump over else clause
     0B24             (          xyz.asm):02475         L00308  EQU     *               else
                      (          xyz.asm):02476         * Line xyz.c:985: assignment: =
0B24 4F               (          xyz.asm):02477                 CLRA
                      (          xyz.asm):02478         * CLRB  optim: optimizeStackOperations1
                      (          xyz.asm):02479         * PSHS B optim: optimizeStackOperations1
                      (          xyz.asm):02480         * optim: optimizeLdx
0B25 C600             (          xyz.asm):02481                 LDB     #0              optim: optimizeStackOperations1
0B27 E7D9FF2C         (          xyz.asm):02482                 STB     [-212,U]        optim: optimizeLdx
     0B2B             (          xyz.asm):02483         L00309  EQU     *               end if
                      (          xyz.asm):02484         * Line xyz.c:986: if
0B2B EC46             (          xyz.asm):02485                 LDD     6,U             variable argc
0B2D C3FFFF           (          xyz.asm):02486                 ADDD    #$FFFF          65535
0B30 3406             (          xyz.asm):02487                 PSHS    B,A
0B32 30C9FF32         (          xyz.asm):02488                 LEAX    -206,U          variable arity, declared at xyz.c:972
0B36 EC84             (          xyz.asm):02489                 LDD     ,X
0B38 C30001           (          xyz.asm):02490                 ADDD    #1
0B3B ED84             (          xyz.asm):02491                 STD     ,X
0B3D 10A3E1           (          xyz.asm):02492                 CMPD    ,S++
0B40 2F03             (          xyz.asm):02493                 BLE     L00311
                      (          xyz.asm):02494         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02495         * Useless label L00310 removed
                      (          xyz.asm):02496         * Line xyz.c:986: goto arityerr
0B42 16007A           (          xyz.asm):02497                 LBRA    L00059
     0B45             (          xyz.asm):02498         L00311  EQU     *               else
                      (          xyz.asm):02499         * Useless label L00312 removed
                      (          xyz.asm):02500         * Line xyz.c:987: function call: picolSetVar()
0B45 AE48             (          xyz.asm):02501                 LDX     8,U             pointer argv
0B47 ECC9FF32         (          xyz.asm):02502                 LDD     -206,U          variable arity
0B4B 58               (          xyz.asm):02503                 LSLB
0B4C 49               (          xyz.asm):02504                 ROLA
0B4D 308B             (          xyz.asm):02505                 LEAX    D,X             add byte offset
0B4F EC84             (          xyz.asm):02506                 LDD     ,X              get r-value
0B51 3406             (          xyz.asm):02507                 PSHS    B,A             argument 3 of picolSetVar(): char *
0B53 ECC9FF24         (          xyz.asm):02508                 LDD     -220,U          variable start, declared at xyz.c:979
0B57 3406             (          xyz.asm):02509                 PSHS    B,A             argument 2 of picolSetVar(): char *
0B59 EC44             (          xyz.asm):02510                 LDD     4,U             variable i, declared at xyz.c:969
0B5B 3406             (          xyz.asm):02511                 PSHS    B,A             argument 1 of picolSetVar(): struct picolInterp *
0B5D 171B80           (          xyz.asm):02512                 LBSR    _picolSetVar
0B60 3266             (          xyz.asm):02513                 LEAS    6,S
0B62 30C9FF2C         (          xyz.asm):02514                 LEAX    -212,U          variable p, declared at xyz.c:970
0B66 EC84             (          xyz.asm):02515                 LDD     ,X
0B68 C30001           (          xyz.asm):02516                 ADDD    #1
0B6B ED84             (          xyz.asm):02517                 STD     ,X
                      (          xyz.asm):02518         * optim: stripOpToDeadReg
                      (          xyz.asm):02519         * Line xyz.c:989: if
0B6D ECC9FF34         (          xyz.asm):02520                 LDD     -204,U          variable done, declared at xyz.c:972
                      (          xyz.asm):02521         * optim: loadCmpZeroBeqOrBne
0B71 2702             (          xyz.asm):02522                 BEQ     L00314
                      (          xyz.asm):02523         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02524         * Useless label L00313 removed
0B73 2003             (          xyz.asm):02525                 BRA     L00295          break
     0B75             (          xyz.asm):02526         L00314  EQU     *               else
                      (          xyz.asm):02527         * Useless label L00315 removed
     0B75             (          xyz.asm):02528         L00294  EQU     *               while condition at xyz.c:978
0B75 16FF40           (          xyz.asm):02529                 LBRA    L00293          go to start of while body
     0B78             (          xyz.asm):02530         L00295  EQU     *               after end of while starting at xyz.c:978
                      (          xyz.asm):02531         * Line xyz.c:991: function call: free()
0B78 ECC9FF2E         (          xyz.asm):02532                 LDD     -210,U          variable tofree, declared at xyz.c:970
0B7C 3406             (          xyz.asm):02533                 PSHS    B,A             argument 1 of free(): char *
0B7E 17FAA2           (          xyz.asm):02534                 LBSR    _free
0B81 3262             (          xyz.asm):02535                 LEAS    2,S
                      (          xyz.asm):02536         * Line xyz.c:992: if
0B83 EC46             (          xyz.asm):02537                 LDD     6,U             variable argc
0B85 C3FFFF           (          xyz.asm):02538                 ADDD    #$FFFF          65535
                      (          xyz.asm):02539         * optim: optimize16BitCompares
                      (          xyz.asm):02540         * optim: optimize16BitCompares
0B88 10A3C9FF32       (          xyz.asm):02541                 CMPD    -206,U          optim: optimize16BitCompares
0B8D 2702             (          xyz.asm):02542                 BEQ     L00317          optim: optimize16BitCompares
                      (          xyz.asm):02543         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02544         * Useless label L00316 removed
                      (          xyz.asm):02545         * Line xyz.c:992: goto arityerr
0B8F 202E             (          xyz.asm):02546                 BRA     L00059
     0B91             (          xyz.asm):02547         L00317  EQU     *               else
                      (          xyz.asm):02548         * Useless label L00318 removed
                      (          xyz.asm):02549         * Line xyz.c:993: assignment: =
                      (          xyz.asm):02550         * Line xyz.c:993: function call: picolEval()
0B91 ECC9FF2A         (          xyz.asm):02551                 LDD     -214,U          variable body, declared at xyz.c:970
0B95 3406             (          xyz.asm):02552                 PSHS    B,A             argument 2 of picolEval(): char *
0B97 EC44             (          xyz.asm):02553                 LDD     4,U             variable i, declared at xyz.c:969
0B99 3406             (          xyz.asm):02554                 PSHS    B,A             argument 1 of picolEval(): struct picolInterp *
0B9B 170C52           (          xyz.asm):02555                 LBSR    _picolEval
0B9E 3264             (          xyz.asm):02556                 LEAS    4,S
0BA0 EDC9FF36         (          xyz.asm):02557                 STD     -202,U
                      (          xyz.asm):02558         * Line xyz.c:994: if
                      (          xyz.asm):02559         * optim: storeLoad
0BA4 10830002         (          xyz.asm):02560                 CMPD    #$02
0BA8 2606             (          xyz.asm):02561                 BNE     L00320
                      (          xyz.asm):02562         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02563         * Useless label L00319 removed
                      (          xyz.asm):02564         * Line xyz.c:994: assignment: =
0BAA 4F               (          xyz.asm):02565                 CLRA
0BAB 5F               (          xyz.asm):02566                 CLRB
0BAC EDC9FF36         (          xyz.asm):02567                 STD     -202,U
     0BB0             (          xyz.asm):02568         L00320  EQU     *               else
                      (          xyz.asm):02569         * Useless label L00321 removed
                      (          xyz.asm):02570         * Line xyz.c:995: function call: picolDropCallFrame()
0BB0 EC44             (          xyz.asm):02571                 LDD     4,U             variable i, declared at xyz.c:969
0BB2 3406             (          xyz.asm):02572                 PSHS    B,A             argument 1 of picolDropCallFrame(): struct picolInterp *
0BB4 170BD9           (          xyz.asm):02573                 LBSR    _picolDropCallFrame
0BB7 3262             (          xyz.asm):02574                 LEAS    2,S
                      (          xyz.asm):02575         * Line xyz.c:996: return with value
0BB9 ECC9FF36         (          xyz.asm):02576                 LDD     -202,U          variable errcode, declared at xyz.c:972
0BBD 2032             (          xyz.asm):02577                 BRA     L00060          return (xyz.c:996)
                      (          xyz.asm):02578         * Line xyz.c:998: labeled statement
     0BBF             (          xyz.asm):02579         L00059  EQU     *               label arityerr, declared at xyz.c:997
                      (          xyz.asm):02580         * Line xyz.c:998: function call: snprintf_s()
                      (          xyz.asm):02581         * optim: optimizeIndexedX
0BBF ECD808           (          xyz.asm):02582                 LDD     [8,U]           optim: optimizeIndexedX
0BC2 3406             (          xyz.asm):02583                 PSHS    B,A             argument 4 of snprintf_s(): char *
0BC4 308D2105         (          xyz.asm):02584                 LEAX    S00105,PCR      "Proc \'%s\' called with wrong arg num"
                      (          xyz.asm):02585         * optim: optimizePshsOps
0BC8 4F               (          xyz.asm):02586                 CLRA
0BC9 C6C8             (          xyz.asm):02587                 LDB     #$C8            decimal 200 signed
0BCB 3416             (          xyz.asm):02588                 PSHS    X,B,A           optim: optimizePshsOps
0BCD 30C9FF38         (          xyz.asm):02589                 LEAX    -200,U          address of array errbuf
0BD1 3410             (          xyz.asm):02590                 PSHS    X               argument 1 of snprintf_s(): char[]
0BD3 171D94           (          xyz.asm):02591                 LBSR    _snprintf_s
0BD6 3268             (          xyz.asm):02592                 LEAS    8,S
                      (          xyz.asm):02593         * Line xyz.c:999: function call: picolSetResult()
0BD8 30C9FF38         (          xyz.asm):02594                 LEAX    -200,U          address of array errbuf
                      (          xyz.asm):02595         * optim: optimizePshsOps
0BDC EC44             (          xyz.asm):02596                 LDD     4,U             variable i, declared at xyz.c:969
0BDE 3416             (          xyz.asm):02597                 PSHS    X,B,A           optim: optimizePshsOps
0BE0 171AD8           (          xyz.asm):02598                 LBSR    _picolSetResult
0BE3 3264             (          xyz.asm):02599                 LEAS    4,S
                      (          xyz.asm):02600         * Line xyz.c:1000: function call: picolDropCallFrame()
0BE5 EC44             (          xyz.asm):02601                 LDD     4,U             variable i, declared at xyz.c:969
0BE7 3406             (          xyz.asm):02602                 PSHS    B,A             argument 1 of picolDropCallFrame(): struct picolInterp *
0BE9 170BA4           (          xyz.asm):02603                 LBSR    _picolDropCallFrame
0BEC 3262             (          xyz.asm):02604                 LEAS    2,S
                      (          xyz.asm):02605         * Line xyz.c:1001: return with value
0BEE 4F               (          xyz.asm):02606                 CLRA
0BEF C601             (          xyz.asm):02607                 LDB     #$01            decimal 1 signed
                      (          xyz.asm):02608         * optim: branchToNextLocation
     0BF1             (          xyz.asm):02609         L00060  EQU     *               end of picolCommandCallProc()
0BF1 32C4             (          xyz.asm):02610                 LEAS    ,U
0BF3 35C0             (          xyz.asm):02611                 PULS    U,PC
                      (          xyz.asm):02612         * END FUNCTION picolCommandCallProc(): defined at xyz.c:969
     0BF5             (          xyz.asm):02613         funcend_picolCommandCallProc    EQU *
     01B0             (          xyz.asm):02614         funcsize_picolCommandCallProc   EQU     funcend_picolCommandCallProc-_picolCommandCallProc
                      (          xyz.asm):02615         
                      (          xyz.asm):02616         
                      (          xyz.asm):02617         *******************************************************************************
                      (          xyz.asm):02618         
                      (          xyz.asm):02619         * FUNCTION picolCommandCatch(): defined at xyz.c:1114
     0BF5             (          xyz.asm):02620         _picolCommandCatch      EQU     *
0BF5 3440             (          xyz.asm):02621                 PSHS    U
0BF7 171E52           (          xyz.asm):02622                 LBSR    _stkcheck
0BFA FFBA             (          xyz.asm):02623                 FDB     -70             argument for _stkcheck
0BFC 33E4             (          xyz.asm):02624                 LEAU    ,S
0BFE 327A             (          xyz.asm):02625                 LEAS    -6,S
                      (          xyz.asm):02626         * Formal parameters and locals:
                      (          xyz.asm):02627         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):02628         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):02629         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):02630         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):02631         *   body: char *; 2 bytes at -6,U
                      (          xyz.asm):02632         *   resultVar: char *; 2 bytes at -4,U
                      (          xyz.asm):02633         *   e: int; 2 bytes at -2,U
                      (          xyz.asm):02634         * Line xyz.c:1115: if
0C00 EC46             (          xyz.asm):02635                 LDD     6,U             variable argc
0C02 10830002         (          xyz.asm):02636                 CMPD    #$02
0C06 271A             (          xyz.asm):02637                 BEQ     L00323
                      (          xyz.asm):02638         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02639         * Useless label L00324 removed
0C08 EC46             (          xyz.asm):02640                 LDD     6,U             variable argc
0C0A 10830003         (          xyz.asm):02641                 CMPD    #$03
0C0E 2712             (          xyz.asm):02642                 BEQ     L00323
                      (          xyz.asm):02643         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02644         * Useless label L00322 removed
                      (          xyz.asm):02645         * Line xyz.c:1115: return with value
                      (          xyz.asm):02646         * Line xyz.c:1115: function call: picolArityErr()
0C10 AE48             (          xyz.asm):02647                 LDX     8,U             get pointer value
0C12 EC84             (          xyz.asm):02648                 LDD     ,X
0C14 3406             (          xyz.asm):02649                 PSHS    B,A             argument 2 of picolArityErr(): char *
0C16 EC44             (          xyz.asm):02650                 LDD     4,U             variable i, declared at xyz.c:1114
0C18 3406             (          xyz.asm):02651                 PSHS    B,A             argument 1 of picolArityErr(): struct picolInterp *
0C1A 17FDEF           (          xyz.asm):02652                 LBSR    _picolArityErr
0C1D 3264             (          xyz.asm):02653                 LEAS    4,S
0C1F 160053           (          xyz.asm):02654                 LBRA    L00070          return (xyz.c:1115)
     0C22             (          xyz.asm):02655         L00323  EQU     *               else
                      (          xyz.asm):02656         * Useless label L00325 removed
                      (          xyz.asm):02657         * Line xyz.c:1116: init of variable body
0C22 AE48             (          xyz.asm):02658                 LDX     8,U             get pointer value
                      (          xyz.asm):02659         * optim: optimizeLeaxLdd
0C24 EC02             (          xyz.asm):02660                 LDD     2,X             optim: optimizeLeaxLdd
0C26 ED5A             (          xyz.asm):02661                 STD     -6,U            variable body
                      (          xyz.asm):02662         * Line xyz.c:1117: init of variable resultVar
0C28 EC46             (          xyz.asm):02663                 LDD     6,U             variable argc
0C2A 10830003         (          xyz.asm):02664                 CMPD    #$03
0C2E 2703             (          xyz.asm):02665                 BEQ     L00326          if true
0C30 5F               (          xyz.asm):02666                 CLRB
0C31 2002             (          xyz.asm):02667                 BRA     L00327          false
     0C33             (          xyz.asm):02668         L00326  EQU     *
0C33 C601             (          xyz.asm):02669                 LDB     #1
     0C35             (          xyz.asm):02670         L00327  EQU     *
0C35 5D               (          xyz.asm):02671                 TSTB
0C36 2706             (          xyz.asm):02672                 BEQ     L00328          if conditional expression is false
0C38 AE48             (          xyz.asm):02673                 LDX     8,U             get pointer value
                      (          xyz.asm):02674         * optim: optimizeLeaxLdd
0C3A EC04             (          xyz.asm):02675                 LDD     4,X             optim: optimizeLeaxLdd
0C3C 2002             (          xyz.asm):02676                 BRA     L00329          end of true expression of conditional
     0C3E             (          xyz.asm):02677         L00328  EQU     *
0C3E 4F               (          xyz.asm):02678                 CLRA
0C3F 5F               (          xyz.asm):02679                 CLRB
     0C40             (          xyz.asm):02680         L00329  EQU     *
0C40 ED5C             (          xyz.asm):02681                 STD     -4,U            variable resultVar
                      (          xyz.asm):02682         * Line xyz.c:1118: init of variable e
                      (          xyz.asm):02683         * Line xyz.c:1118: function call: picolEval()
0C42 EC5A             (          xyz.asm):02684                 LDD     -6,U            variable body, declared at xyz.c:1116
0C44 3406             (          xyz.asm):02685                 PSHS    B,A             argument 2 of picolEval(): char *
0C46 EC44             (          xyz.asm):02686                 LDD     4,U             variable i, declared at xyz.c:1114
0C48 3406             (          xyz.asm):02687                 PSHS    B,A             argument 1 of picolEval(): struct picolInterp *
0C4A 170BA3           (          xyz.asm):02688                 LBSR    _picolEval
0C4D 3264             (          xyz.asm):02689                 LEAS    4,S
0C4F ED5E             (          xyz.asm):02690                 STD     -2,U            variable e
                      (          xyz.asm):02691         * Line xyz.c:1119: if
0C51 EC5C             (          xyz.asm):02692                 LDD     -4,U            variable resultVar, declared at xyz.c:1117
                      (          xyz.asm):02693         * optim: loadCmpZeroBeqOrBne
0C53 2713             (          xyz.asm):02694                 BEQ     L00331
                      (          xyz.asm):02695         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02696         * Useless label L00330 removed
                      (          xyz.asm):02697         * Line xyz.c:1120: function call: picolSetVar()
0C55 AE44             (          xyz.asm):02698                 LDX     4,U             variable i
0C57 EC06             (          xyz.asm):02699                 LDD     6,X             member result of picolInterp
0C59 3406             (          xyz.asm):02700                 PSHS    B,A             argument 3 of picolSetVar(): char *
0C5B EC5C             (          xyz.asm):02701                 LDD     -4,U            variable resultVar, declared at xyz.c:1117
0C5D 3406             (          xyz.asm):02702                 PSHS    B,A             argument 2 of picolSetVar(): char *
0C5F EC44             (          xyz.asm):02703                 LDD     4,U             variable i, declared at xyz.c:1114
0C61 3406             (          xyz.asm):02704                 PSHS    B,A             argument 1 of picolSetVar(): struct picolInterp *
0C63 171A7A           (          xyz.asm):02705                 LBSR    _picolSetVar
0C66 3266             (          xyz.asm):02706                 LEAS    6,S
     0C68             (          xyz.asm):02707         L00331  EQU     *               else
                      (          xyz.asm):02708         * Useless label L00332 removed
                      (          xyz.asm):02709         * Line xyz.c:1122: return with value
                      (          xyz.asm):02710         * Line xyz.c:1122: function call: ResultD()
0C68 EC5E             (          xyz.asm):02711                 LDD     -2,U            variable e, declared at xyz.c:1118
0C6A 3406             (          xyz.asm):02712                 PSHS    B,A             argument 2 of ResultD(): int
0C6C EC44             (          xyz.asm):02713                 LDD     4,U             variable i, declared at xyz.c:1114
0C6E 3406             (          xyz.asm):02714                 PSHS    B,A             argument 1 of ResultD(): struct picolInterp *
0C70 17F69E           (          xyz.asm):02715                 LBSR    _ResultD
0C73 3264             (          xyz.asm):02716                 LEAS    4,S
                      (          xyz.asm):02717         * optim: branchToNextLocation
     0C75             (          xyz.asm):02718         L00070  EQU     *               end of picolCommandCatch()
0C75 32C4             (          xyz.asm):02719                 LEAS    ,U
0C77 35C0             (          xyz.asm):02720                 PULS    U,PC
                      (          xyz.asm):02721         * END FUNCTION picolCommandCatch(): defined at xyz.c:1114
     0C79             (          xyz.asm):02722         funcend_picolCommandCatch       EQU *
     0084             (          xyz.asm):02723         funcsize_picolCommandCatch      EQU     funcend_picolCommandCatch-_picolCommandCatch
                      (          xyz.asm):02724         
                      (          xyz.asm):02725         
                      (          xyz.asm):02726         *******************************************************************************
                      (          xyz.asm):02727         
                      (          xyz.asm):02728         * FUNCTION picolCommandChain(): defined at xyz.c:1185
     0C79             (          xyz.asm):02729         _picolCommandChain      EQU     *
0C79 3440             (          xyz.asm):02730                 PSHS    U
0C7B 171DCE           (          xyz.asm):02731                 LBSR    _stkcheck
0C7E FFBA             (          xyz.asm):02732                 FDB     -70             argument for _stkcheck
0C80 33E4             (          xyz.asm):02733                 LEAU    ,S
0C82 327A             (          xyz.asm):02734                 LEAS    -6,S
                      (          xyz.asm):02735         * Formal parameters and locals:
                      (          xyz.asm):02736         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):02737         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):02738         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):02739         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):02740         *   program: char *; 2 bytes at -6,U
                      (          xyz.asm):02741         *   params: char *; 2 bytes at -4,U
                      (          xyz.asm):02742         *   e: int; 2 bytes at -2,U
                      (          xyz.asm):02743         * Line xyz.c:1186: if
0C84 EC46             (          xyz.asm):02744                 LDD     6,U             variable argc
0C86 10830002         (          xyz.asm):02745                 CMPD    #$02
0C8A 2C13             (          xyz.asm):02746                 BGE     L00334
                      (          xyz.asm):02747         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02748         * Useless label L00333 removed
                      (          xyz.asm):02749         * Line xyz.c:1187: function call: picolSetResult()
0C8C 308D20A1         (          xyz.asm):02750                 LEAX    S00113,PCR      "chain: too few args"
                      (          xyz.asm):02751         * optim: optimizePshsOps
0C90 EC44             (          xyz.asm):02752                 LDD     4,U             variable i, declared at xyz.c:1185
0C92 3416             (          xyz.asm):02753                 PSHS    X,B,A           optim: optimizePshsOps
0C94 171A24           (          xyz.asm):02754                 LBSR    _picolSetResult
0C97 3264             (          xyz.asm):02755                 LEAS    4,S
                      (          xyz.asm):02756         * Line xyz.c:1188: return with value
0C99 4F               (          xyz.asm):02757                 CLRA
0C9A C601             (          xyz.asm):02758                 LDB     #$01            decimal 1 signed
0C9C 16004E           (          xyz.asm):02759                 LBRA    L00076          return (xyz.c:1188)
     0C9F             (          xyz.asm):02760         L00334  EQU     *               else
                      (          xyz.asm):02761         * Useless label L00335 removed
                      (          xyz.asm):02762         * Line xyz.c:1190: init of variable program
0C9F AE48             (          xyz.asm):02763                 LDX     8,U             get pointer value
0CA1 3002             (          xyz.asm):02764                 LEAX    2,X             add index (1) multiplied by pointed object size (2)
0CA3 EC84             (          xyz.asm):02765                 LDD     ,X
0CA5 ED5A             (          xyz.asm):02766                 STD     -6,U            variable program
                      (          xyz.asm):02767         * Line xyz.c:1191: init of variable params
                      (          xyz.asm):02768         * Line xyz.c:1191: function call: FormList()
0CA7 EC48             (          xyz.asm):02769                 LDD     8,U             variable argv
0CA9 C30004           (          xyz.asm):02770                 ADDD    #$04            4
0CAC 3406             (          xyz.asm):02771                 PSHS    B,A             argument 2 of FormList(): char **
0CAE EC46             (          xyz.asm):02772                 LDD     6,U             variable argc
0CB0 C3FFFE           (          xyz.asm):02773                 ADDD    #$FFFE          65534
0CB3 3406             (          xyz.asm):02774                 PSHS    B,A             argument 1 of FormList(): int
0CB5 17F43C           (          xyz.asm):02775                 LBSR    _FormList
0CB8 3264             (          xyz.asm):02776                 LEAS    4,S
0CBA ED5C             (          xyz.asm):02777                 STD     -4,U            variable params
                      (          xyz.asm):02778         * Line xyz.c:1192: init of variable e
                      (          xyz.asm):02779         * Line xyz.c:1192: function call: Os9Chain()
0CBC 4F               (          xyz.asm):02780                 CLRA
0CBD 5F               (          xyz.asm):02781                 CLRB
0CBE 3406             (          xyz.asm):02782                 PSHS    B,A             argument 5 of Os9Chain(): int
                      (          xyz.asm):02783         * optim: stripExtraClrA_B
                      (          xyz.asm):02784         * optim: stripExtraClrA_B
0CC0 3406             (          xyz.asm):02785                 PSHS    B,A             argument 4 of Os9Chain(): int
                      (          xyz.asm):02786         * Line xyz.c:1192: function call: strlen()
0CC2 EC5C             (          xyz.asm):02787                 LDD     -4,U            variable params, declared at xyz.c:1191
0CC4 3406             (          xyz.asm):02788                 PSHS    B,A             argument 1 of strlen(): char *
0CC6 171EB6           (          xyz.asm):02789                 LBSR    _strlen
0CC9 3262             (          xyz.asm):02790                 LEAS    2,S
0CCB 3406             (          xyz.asm):02791                 PSHS    B,A             argument 3 of Os9Chain(): int
0CCD EC5C             (          xyz.asm):02792                 LDD     -4,U            variable params, declared at xyz.c:1191
0CCF 3406             (          xyz.asm):02793                 PSHS    B,A             argument 2 of Os9Chain(): char *
0CD1 EC5A             (          xyz.asm):02794                 LDD     -6,U            variable program, declared at xyz.c:1190
0CD3 3406             (          xyz.asm):02795                 PSHS    B,A             argument 1 of Os9Chain(): char *
0CD5 17F4DB           (          xyz.asm):02796                 LBSR    _Os9Chain
0CD8 326A             (          xyz.asm):02797                 LEAS    10,S
0CDA ED5E             (          xyz.asm):02798                 STD     -2,U            variable e
                      (          xyz.asm):02799         * Line xyz.c:1194: return with value
                      (          xyz.asm):02800         * Line xyz.c:1194: function call: Error()
                      (          xyz.asm):02801         * optim: storeLoad
0CDC 3406             (          xyz.asm):02802                 PSHS    B,A             argument 3 of Error(): int
0CDE AE48             (          xyz.asm):02803                 LDX     8,U             get pointer value
0CE0 EC84             (          xyz.asm):02804                 LDD     ,X
0CE2 3406             (          xyz.asm):02805                 PSHS    B,A             argument 2 of Error(): char *
0CE4 EC44             (          xyz.asm):02806                 LDD     4,U             variable i, declared at xyz.c:1185
0CE6 3406             (          xyz.asm):02807                 PSHS    B,A             argument 1 of Error(): struct picolInterp *
0CE8 17F3BD           (          xyz.asm):02808                 LBSR    _Error
0CEB 3266             (          xyz.asm):02809                 LEAS    6,S
                      (          xyz.asm):02810         * optim: branchToNextLocation
     0CED             (          xyz.asm):02811         L00076  EQU     *               end of picolCommandChain()
0CED 32C4             (          xyz.asm):02812                 LEAS    ,U
0CEF 35C0             (          xyz.asm):02813                 PULS    U,PC
                      (          xyz.asm):02814         * END FUNCTION picolCommandChain(): defined at xyz.c:1185
     0CF1             (          xyz.asm):02815         funcend_picolCommandChain       EQU *
     0078             (          xyz.asm):02816         funcsize_picolCommandChain      EQU     funcend_picolCommandChain-_picolCommandChain
                      (          xyz.asm):02817         
                      (          xyz.asm):02818         
                      (          xyz.asm):02819         *******************************************************************************
                      (          xyz.asm):02820         
                      (          xyz.asm):02821         * FUNCTION picolCommandClose(): defined at xyz.c:1225
     0CF1             (          xyz.asm):02822         _picolCommandClose      EQU     *
0CF1 3440             (          xyz.asm):02823                 PSHS    U
0CF3 171D56           (          xyz.asm):02824                 LBSR    _stkcheck
0CF6 FFBC             (          xyz.asm):02825                 FDB     -68             argument for _stkcheck
0CF8 33E4             (          xyz.asm):02826                 LEAU    ,S
0CFA 327C             (          xyz.asm):02827                 LEAS    -4,S
                      (          xyz.asm):02828         * Formal parameters and locals:
                      (          xyz.asm):02829         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):02830         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):02831         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):02832         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):02833         *   path: int; 2 bytes at -4,U
                      (          xyz.asm):02834         *   e: int; 2 bytes at -2,U
                      (          xyz.asm):02835         * Line xyz.c:1226: if
0CFC EC46             (          xyz.asm):02836                 LDD     6,U             variable argc
0CFE 10830002         (          xyz.asm):02837                 CMPD    #$02
0D02 2712             (          xyz.asm):02838                 BEQ     L00337
                      (          xyz.asm):02839         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02840         * Useless label L00336 removed
                      (          xyz.asm):02841         * Line xyz.c:1226: return with value
                      (          xyz.asm):02842         * Line xyz.c:1226: function call: picolArityErr()
0D04 AE48             (          xyz.asm):02843                 LDX     8,U             get pointer value
0D06 EC84             (          xyz.asm):02844                 LDD     ,X
0D08 3406             (          xyz.asm):02845                 PSHS    B,A             argument 2 of picolArityErr(): char *
0D0A EC44             (          xyz.asm):02846                 LDD     4,U             variable i, declared at xyz.c:1225
0D0C 3406             (          xyz.asm):02847                 PSHS    B,A             argument 1 of picolArityErr(): struct picolInterp *
0D0E 17FCFB           (          xyz.asm):02848                 LBSR    _picolArityErr
0D11 3264             (          xyz.asm):02849                 LEAS    4,S
0D13 160041           (          xyz.asm):02850                 LBRA    L00080          return (xyz.c:1226)
     0D16             (          xyz.asm):02851         L00337  EQU     *               else
                      (          xyz.asm):02852         * Useless label L00338 removed
                      (          xyz.asm):02853         * Line xyz.c:1227: init of variable path
                      (          xyz.asm):02854         * Line xyz.c:1227: function call: atoi()
0D16 AE48             (          xyz.asm):02855                 LDX     8,U             get pointer value
0D18 3002             (          xyz.asm):02856                 LEAX    2,X             add index (1) multiplied by pointed object size (2)
0D1A EC84             (          xyz.asm):02857                 LDD     ,X
0D1C 3406             (          xyz.asm):02858                 PSHS    B,A             argument 1 of atoi(): char *
0D1E 17F70E           (          xyz.asm):02859                 LBSR    _atoi
0D21 3262             (          xyz.asm):02860                 LEAS    2,S
0D23 ED5C             (          xyz.asm):02861                 STD     -4,U            variable path
                      (          xyz.asm):02862         * Line xyz.c:1228: init of variable e
                      (          xyz.asm):02863         * Line xyz.c:1228: function call: Os9Close()
                      (          xyz.asm):02864         * optim: storeLoad
0D25 3406             (          xyz.asm):02865                 PSHS    B,A             argument 1 of Os9Close(): int
0D27 17F49D           (          xyz.asm):02866                 LBSR    _Os9Close
0D2A 3262             (          xyz.asm):02867                 LEAS    2,S
0D2C ED5E             (          xyz.asm):02868                 STD     -2,U            variable e
                      (          xyz.asm):02869         * Line xyz.c:1229: if
                      (          xyz.asm):02870         * optim: storeLoad
0D2E C30000           (          xyz.asm):02871                 ADDD    #0
0D31 2715             (          xyz.asm):02872                 BEQ     L00340
                      (          xyz.asm):02873         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02874         * Useless label L00339 removed
                      (          xyz.asm):02875         * Line xyz.c:1229: return with value
                      (          xyz.asm):02876         * Line xyz.c:1229: function call: Error()
0D33 EC5E             (          xyz.asm):02877                 LDD     -2,U            variable e, declared at xyz.c:1228
0D35 3406             (          xyz.asm):02878                 PSHS    B,A             argument 3 of Error(): int
0D37 AE48             (          xyz.asm):02879                 LDX     8,U             get pointer value
0D39 EC84             (          xyz.asm):02880                 LDD     ,X
0D3B 3406             (          xyz.asm):02881                 PSHS    B,A             argument 2 of Error(): char *
0D3D EC44             (          xyz.asm):02882                 LDD     4,U             variable i, declared at xyz.c:1225
0D3F 3406             (          xyz.asm):02883                 PSHS    B,A             argument 1 of Error(): struct picolInterp *
0D41 17F364           (          xyz.asm):02884                 LBSR    _Error
0D44 3266             (          xyz.asm):02885                 LEAS    6,S
0D46 200F             (          xyz.asm):02886                 BRA     L00080          return (xyz.c:1229)
     0D48             (          xyz.asm):02887         L00340  EQU     *               else
                      (          xyz.asm):02888         * Useless label L00341 removed
                      (          xyz.asm):02889         * Line xyz.c:1230: function call: picolSetResult()
0D48 308D1EFC         (          xyz.asm):02890                 LEAX    S00095,PCR      ""
                      (          xyz.asm):02891         * optim: optimizePshsOps
0D4C EC44             (          xyz.asm):02892                 LDD     4,U             variable i, declared at xyz.c:1225
0D4E 3416             (          xyz.asm):02893                 PSHS    X,B,A           optim: optimizePshsOps
0D50 171968           (          xyz.asm):02894                 LBSR    _picolSetResult
0D53 3264             (          xyz.asm):02895                 LEAS    4,S
                      (          xyz.asm):02896         * Line xyz.c:1231: return with value
0D55 4F               (          xyz.asm):02897                 CLRA
0D56 5F               (          xyz.asm):02898                 CLRB
                      (          xyz.asm):02899         * optim: branchToNextLocation
     0D57             (          xyz.asm):02900         L00080  EQU     *               end of picolCommandClose()
0D57 32C4             (          xyz.asm):02901                 LEAS    ,U
0D59 35C0             (          xyz.asm):02902                 PULS    U,PC
                      (          xyz.asm):02903         * END FUNCTION picolCommandClose(): defined at xyz.c:1225
     0D5B             (          xyz.asm):02904         funcend_picolCommandClose       EQU *
     006A             (          xyz.asm):02905         funcsize_picolCommandClose      EQU     funcend_picolCommandClose-_picolCommandClose
                      (          xyz.asm):02906         
                      (          xyz.asm):02907         
                      (          xyz.asm):02908         *******************************************************************************
                      (          xyz.asm):02909         
                      (          xyz.asm):02910         * FUNCTION picolCommandDup(): defined at xyz.c:1216
     0D5B             (          xyz.asm):02911         _picolCommandDup        EQU     *
0D5B 3440             (          xyz.asm):02912                 PSHS    U
0D5D 171CEC           (          xyz.asm):02913                 LBSR    _stkcheck
0D60 FFBA             (          xyz.asm):02914                 FDB     -70             argument for _stkcheck
0D62 33E4             (          xyz.asm):02915                 LEAU    ,S
0D64 327A             (          xyz.asm):02916                 LEAS    -6,S
                      (          xyz.asm):02917         * Formal parameters and locals:
                      (          xyz.asm):02918         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):02919         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):02920         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):02921         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):02922         *   new_path: int; 2 bytes at -6,U
                      (          xyz.asm):02923         *   path: int; 2 bytes at -4,U
                      (          xyz.asm):02924         *   e: int; 2 bytes at -2,U
                      (          xyz.asm):02925         * Line xyz.c:1217: if
0D66 EC46             (          xyz.asm):02926                 LDD     6,U             variable argc
0D68 10830002         (          xyz.asm):02927                 CMPD    #$02
0D6C 2712             (          xyz.asm):02928                 BEQ     L00343
                      (          xyz.asm):02929         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02930         * Useless label L00342 removed
                      (          xyz.asm):02931         * Line xyz.c:1217: return with value
                      (          xyz.asm):02932         * Line xyz.c:1217: function call: picolArityErr()
0D6E AE48             (          xyz.asm):02933                 LDX     8,U             get pointer value
0D70 EC84             (          xyz.asm):02934                 LDD     ,X
0D72 3406             (          xyz.asm):02935                 PSHS    B,A             argument 2 of picolArityErr(): char *
0D74 EC44             (          xyz.asm):02936                 LDD     4,U             variable i, declared at xyz.c:1216
0D76 3406             (          xyz.asm):02937                 PSHS    B,A             argument 1 of picolArityErr(): struct picolInterp *
0D78 17FC91           (          xyz.asm):02938                 LBSR    _picolArityErr
0D7B 3264             (          xyz.asm):02939                 LEAS    4,S
0D7D 160047           (          xyz.asm):02940                 LBRA    L00079          return (xyz.c:1217)
     0D80             (          xyz.asm):02941         L00343  EQU     *               else
                      (          xyz.asm):02942         * Useless label L00344 removed
                      (          xyz.asm):02943         * Line xyz.c:1218: init of variable new_path
0D80 4F               (          xyz.asm):02944                 CLRA
0D81 5F               (          xyz.asm):02945                 CLRB
0D82 ED5A             (          xyz.asm):02946                 STD     -6,U            variable new_path
                      (          xyz.asm):02947         * Line xyz.c:1219: init of variable path
                      (          xyz.asm):02948         * Line xyz.c:1219: function call: atoi()
0D84 AE48             (          xyz.asm):02949                 LDX     8,U             get pointer value
0D86 3002             (          xyz.asm):02950                 LEAX    2,X             add index (1) multiplied by pointed object size (2)
0D88 EC84             (          xyz.asm):02951                 LDD     ,X
0D8A 3406             (          xyz.asm):02952                 PSHS    B,A             argument 1 of atoi(): char *
0D8C 17F6A0           (          xyz.asm):02953                 LBSR    _atoi
0D8F 3262             (          xyz.asm):02954                 LEAS    2,S
0D91 ED5C             (          xyz.asm):02955                 STD     -4,U            variable path
                      (          xyz.asm):02956         * Line xyz.c:1220: init of variable e
                      (          xyz.asm):02957         * Line xyz.c:1220: function call: Os9Dup()
0D93 305A             (          xyz.asm):02958                 LEAX    -6,U            variable new_path, declared at xyz.c:1218
0D95 3410             (          xyz.asm):02959                 PSHS    X               argument 2 of Os9Dup(): int *
                      (          xyz.asm):02960         * optim: removeUselessLdd
0D97 3406             (          xyz.asm):02961                 PSHS    B,A             argument 1 of Os9Dup(): int
0D99 17F43A           (          xyz.asm):02962                 LBSR    _Os9Dup
0D9C 3264             (          xyz.asm):02963                 LEAS    4,S
0D9E ED5E             (          xyz.asm):02964                 STD     -2,U            variable e
                      (          xyz.asm):02965         * Line xyz.c:1221: if
                      (          xyz.asm):02966         * optim: storeLoad
0DA0 C30000           (          xyz.asm):02967                 ADDD    #0
0DA3 2715             (          xyz.asm):02968                 BEQ     L00346
                      (          xyz.asm):02969         * optim: condBranchOverUncondBranch
                      (          xyz.asm):02970         * Useless label L00345 removed
                      (          xyz.asm):02971         * Line xyz.c:1221: return with value
                      (          xyz.asm):02972         * Line xyz.c:1221: function call: Error()
0DA5 EC5E             (          xyz.asm):02973                 LDD     -2,U            variable e, declared at xyz.c:1220
0DA7 3406             (          xyz.asm):02974                 PSHS    B,A             argument 3 of Error(): int
0DA9 AE48             (          xyz.asm):02975                 LDX     8,U             get pointer value
0DAB EC84             (          xyz.asm):02976                 LDD     ,X
0DAD 3406             (          xyz.asm):02977                 PSHS    B,A             argument 2 of Error(): char *
0DAF EC44             (          xyz.asm):02978                 LDD     4,U             variable i, declared at xyz.c:1216
0DB1 3406             (          xyz.asm):02979                 PSHS    B,A             argument 1 of Error(): struct picolInterp *
0DB3 17F2F2           (          xyz.asm):02980                 LBSR    _Error
0DB6 3266             (          xyz.asm):02981                 LEAS    6,S
0DB8 200D             (          xyz.asm):02982                 BRA     L00079          return (xyz.c:1221)
     0DBA             (          xyz.asm):02983         L00346  EQU     *               else
                      (          xyz.asm):02984         * Useless label L00347 removed
                      (          xyz.asm):02985         * Line xyz.c:1222: return with value
                      (          xyz.asm):02986         * Line xyz.c:1222: function call: ResultD()
0DBA EC5A             (          xyz.asm):02987                 LDD     -6,U            variable new_path, declared at xyz.c:1218
0DBC 3406             (          xyz.asm):02988                 PSHS    B,A             argument 2 of ResultD(): int
0DBE EC44             (          xyz.asm):02989                 LDD     4,U             variable i, declared at xyz.c:1216
0DC0 3406             (          xyz.asm):02990                 PSHS    B,A             argument 1 of ResultD(): struct picolInterp *
0DC2 17F54C           (          xyz.asm):02991                 LBSR    _ResultD
0DC5 3264             (          xyz.asm):02992                 LEAS    4,S
                      (          xyz.asm):02993         * optim: branchToNextLocation
     0DC7             (          xyz.asm):02994         L00079  EQU     *               end of picolCommandDup()
0DC7 32C4             (          xyz.asm):02995                 LEAS    ,U
0DC9 35C0             (          xyz.asm):02996                 PULS    U,PC
                      (          xyz.asm):02997         * END FUNCTION picolCommandDup(): defined at xyz.c:1216
     0DCB             (          xyz.asm):02998         funcend_picolCommandDup EQU *
     0070             (          xyz.asm):02999         funcsize_picolCommandDup        EQU     funcend_picolCommandDup-_picolCommandDup
                      (          xyz.asm):03000         
                      (          xyz.asm):03001         
                      (          xyz.asm):03002         *******************************************************************************
                      (          xyz.asm):03003         
                      (          xyz.asm):03004         * FUNCTION picolCommandExit(): defined at xyz.c:1018
     0DCB             (          xyz.asm):03005         _picolCommandExit       EQU     *
0DCB 3440             (          xyz.asm):03006                 PSHS    U
0DCD 171C7C           (          xyz.asm):03007                 LBSR    _stkcheck
0DD0 FFC0             (          xyz.asm):03008                 FDB     -64             argument for _stkcheck
0DD2 33E4             (          xyz.asm):03009                 LEAU    ,S
                      (          xyz.asm):03010         * Formal parameters and locals:
                      (          xyz.asm):03011         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):03012         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):03013         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):03014         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):03015         * Line xyz.c:1019: if
0DD4 EC46             (          xyz.asm):03016                 LDD     6,U             variable argc
0DD6 10830001         (          xyz.asm):03017                 CMPD    #$01
0DDA 2719             (          xyz.asm):03018                 BEQ     L00349
                      (          xyz.asm):03019         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03020         * Useless label L00350 removed
0DDC EC46             (          xyz.asm):03021                 LDD     6,U             variable argc
0DDE 10830002         (          xyz.asm):03022                 CMPD    #$02
0DE2 2711             (          xyz.asm):03023                 BEQ     L00349
                      (          xyz.asm):03024         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03025         * Useless label L00348 removed
                      (          xyz.asm):03026         * Line xyz.c:1019: return with value
                      (          xyz.asm):03027         * Line xyz.c:1019: function call: picolArityErr()
0DE4 AE48             (          xyz.asm):03028                 LDX     8,U             get pointer value
0DE6 EC84             (          xyz.asm):03029                 LDD     ,X
0DE8 3406             (          xyz.asm):03030                 PSHS    B,A             argument 2 of picolArityErr(): char *
0DEA EC44             (          xyz.asm):03031                 LDD     4,U             variable i, declared at xyz.c:1018
0DEC 3406             (          xyz.asm):03032                 PSHS    B,A             argument 1 of picolArityErr(): struct picolInterp *
0DEE 17FC1B           (          xyz.asm):03033                 LBSR    _picolArityErr
0DF1 3264             (          xyz.asm):03034                 LEAS    4,S
0DF3 202A             (          xyz.asm):03035                 BRA     L00063          return (xyz.c:1019)
     0DF5             (          xyz.asm):03036         L00349  EQU     *               else
                      (          xyz.asm):03037         * Useless label L00351 removed
                      (          xyz.asm):03038         * Line xyz.c:1020: function call: exit()
0DF5 EC46             (          xyz.asm):03039                 LDD     6,U             variable argc
0DF7 10830002         (          xyz.asm):03040                 CMPD    #$02
0DFB 2703             (          xyz.asm):03041                 BEQ     L00352          if true
0DFD 5F               (          xyz.asm):03042                 CLRB
0DFE 2002             (          xyz.asm):03043                 BRA     L00353          false
     0E00             (          xyz.asm):03044         L00352  EQU     *
0E00 C601             (          xyz.asm):03045                 LDB     #1
     0E02             (          xyz.asm):03046         L00353  EQU     *
0E02 5D               (          xyz.asm):03047                 TSTB
0E03 270F             (          xyz.asm):03048                 BEQ     L00354          if conditional expression is false
                      (          xyz.asm):03049         * Line xyz.c:1020: function call: atoi()
0E05 AE48             (          xyz.asm):03050                 LDX     8,U             get pointer value
0E07 3002             (          xyz.asm):03051                 LEAX    2,X             add index (1) multiplied by pointed object size (2)
0E09 EC84             (          xyz.asm):03052                 LDD     ,X
0E0B 3406             (          xyz.asm):03053                 PSHS    B,A             argument 1 of atoi(): char *
0E0D 17F61F           (          xyz.asm):03054                 LBSR    _atoi
0E10 3262             (          xyz.asm):03055                 LEAS    2,S
0E12 2002             (          xyz.asm):03056                 BRA     L00355          end of true expression of conditional
     0E14             (          xyz.asm):03057         L00354  EQU     *
0E14 4F               (          xyz.asm):03058                 CLRA
0E15 5F               (          xyz.asm):03059                 CLRB
     0E16             (          xyz.asm):03060         L00355  EQU     *
0E16 3406             (          xyz.asm):03061                 PSHS    B,A             argument 1 of exit(): int
0E18 17F802           (          xyz.asm):03062                 LBSR    _exit
0E1B 3262             (          xyz.asm):03063                 LEAS    2,S
                      (          xyz.asm):03064         * Line xyz.c:1021: return with value
0E1D 4F               (          xyz.asm):03065                 CLRA
0E1E 5F               (          xyz.asm):03066                 CLRB
                      (          xyz.asm):03067         * optim: branchToNextLocation
     0E1F             (          xyz.asm):03068         L00063  EQU     *               end of picolCommandExit()
0E1F 32C4             (          xyz.asm):03069                 LEAS    ,U
0E21 35C0             (          xyz.asm):03070                 PULS    U,PC
                      (          xyz.asm):03071         * END FUNCTION picolCommandExit(): defined at xyz.c:1018
     0E23             (          xyz.asm):03072         funcend_picolCommandExit        EQU *
     0058             (          xyz.asm):03073         funcsize_picolCommandExit       EQU     funcend_picolCommandExit-_picolCommandExit
                      (          xyz.asm):03074         
                      (          xyz.asm):03075         
                      (          xyz.asm):03076         *******************************************************************************
                      (          xyz.asm):03077         
                      (          xyz.asm):03078         * FUNCTION picolCommandForEach(): defined at xyz.c:1125
     0E23             (          xyz.asm):03079         _picolCommandForEach    EQU     *
0E23 3440             (          xyz.asm):03080                 PSHS    U
0E25 171C24           (          xyz.asm):03081                 LBSR    _stkcheck
0E28 FFB0             (          xyz.asm):03082                 FDB     -80             argument for _stkcheck
0E2A 33E4             (          xyz.asm):03083                 LEAU    ,S
0E2C 3270             (          xyz.asm):03084                 LEAS    -16,S
                      (          xyz.asm):03085         * Formal parameters and locals:
                      (          xyz.asm):03086         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):03087         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):03088         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):03089         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):03090         *   var: char *; 2 bytes at -12,U
                      (          xyz.asm):03091         *   list: char *; 2 bytes at -10,U
                      (          xyz.asm):03092         *   body: char *; 2 bytes at -8,U
                      (          xyz.asm):03093         *   c: int; 2 bytes at -6,U
                      (          xyz.asm):03094         *   v: char **; 2 bytes at -4,U
                      (          xyz.asm):03095         *   err: int; 2 bytes at -2,U
                      (          xyz.asm):03096         * Line xyz.c:1126: if
0E2E EC46             (          xyz.asm):03097                 LDD     6,U             variable argc
0E30 10830004         (          xyz.asm):03098                 CMPD    #$04
0E34 2712             (          xyz.asm):03099                 BEQ     L00357
                      (          xyz.asm):03100         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03101         * Useless label L00356 removed
                      (          xyz.asm):03102         * Line xyz.c:1126: return with value
                      (          xyz.asm):03103         * Line xyz.c:1126: function call: picolArityErr()
0E36 AE48             (          xyz.asm):03104                 LDX     8,U             get pointer value
0E38 EC84             (          xyz.asm):03105                 LDD     ,X
0E3A 3406             (          xyz.asm):03106                 PSHS    B,A             argument 2 of picolArityErr(): char *
0E3C EC44             (          xyz.asm):03107                 LDD     4,U             variable i, declared at xyz.c:1125
0E3E 3406             (          xyz.asm):03108                 PSHS    B,A             argument 1 of picolArityErr(): struct picolInterp *
0E40 17FBC9           (          xyz.asm):03109                 LBSR    _picolArityErr
0E43 3264             (          xyz.asm):03110                 LEAS    4,S
0E45 160091           (          xyz.asm):03111                 LBRA    L00071          return (xyz.c:1126)
     0E48             (          xyz.asm):03112         L00357  EQU     *               else
                      (          xyz.asm):03113         * Useless label L00358 removed
                      (          xyz.asm):03114         * Line xyz.c:1127: init of variable var
0E48 AE48             (          xyz.asm):03115                 LDX     8,U             get pointer value
                      (          xyz.asm):03116         * optim: optimizeLeaxLdd
0E4A EC02             (          xyz.asm):03117                 LDD     2,X             optim: optimizeLeaxLdd
0E4C ED54             (          xyz.asm):03118                 STD     -12,U           variable var
                      (          xyz.asm):03119         * Line xyz.c:1128: init of variable list
0E4E AE48             (          xyz.asm):03120                 LDX     8,U             get pointer value
                      (          xyz.asm):03121         * optim: optimizeLeaxLdd
0E50 EC04             (          xyz.asm):03122                 LDD     4,X             optim: optimizeLeaxLdd
0E52 ED56             (          xyz.asm):03123                 STD     -10,U           variable list
                      (          xyz.asm):03124         * Line xyz.c:1129: init of variable body
0E54 AE48             (          xyz.asm):03125                 LDX     8,U             get pointer value
                      (          xyz.asm):03126         * optim: optimizeLeaxLdd
0E56 EC06             (          xyz.asm):03127                 LDD     6,X             optim: optimizeLeaxLdd
0E58 ED58             (          xyz.asm):03128                 STD     -8,U            variable body
                      (          xyz.asm):03129         * Line xyz.c:1131: init of variable c
0E5A 4F               (          xyz.asm):03130                 CLRA
0E5B 5F               (          xyz.asm):03131                 CLRB
0E5C ED5A             (          xyz.asm):03132                 STD     -6,U            variable c
                      (          xyz.asm):03133         * Line xyz.c:1132: init of variable v
                      (          xyz.asm):03134         * optim: stripExtraClrA_B
                      (          xyz.asm):03135         * optim: stripExtraClrA_B
0E5E ED5C             (          xyz.asm):03136                 STD     -4,U            variable v
                      (          xyz.asm):03137         * Line xyz.c:1133: init of variable err
                      (          xyz.asm):03138         * Line xyz.c:1133: function call: SplitList()
0E60 305C             (          xyz.asm):03139                 LEAX    -4,U            variable v, declared at xyz.c:1132
0E62 3410             (          xyz.asm):03140                 PSHS    X               argument 3 of SplitList(): char ***
0E64 305A             (          xyz.asm):03141                 LEAX    -6,U            variable c, declared at xyz.c:1131
                      (          xyz.asm):03142         * optim: optimizePshsOps
0E66 EC56             (          xyz.asm):03143                 LDD     -10,U           variable list, declared at xyz.c:1128
0E68 3416             (          xyz.asm):03144                 PSHS    X,B,A           optim: optimizePshsOps
0E6A 17F4D9           (          xyz.asm):03145                 LBSR    _SplitList
0E6D 3266             (          xyz.asm):03146                 LEAS    6,S
0E6F ED5E             (          xyz.asm):03147                 STD     -2,U            variable err
                      (          xyz.asm):03148         * Line xyz.c:1134: for init
                      (          xyz.asm):03149         * Line xyz.c:1134: init of variable j
0E71 4F               (          xyz.asm):03150                 CLRA
0E72 5F               (          xyz.asm):03151                 CLRB
0E73 ED52             (          xyz.asm):03152                 STD     -14,U           variable j
0E75 160049           (          xyz.asm):03153                 LBRA    L00360          jump to for condition
     0E78             (          xyz.asm):03154         L00359  EQU     *
                      (          xyz.asm):03155         * Line xyz.c:1134: for body
                      (          xyz.asm):03156         * Line xyz.c:1135: function call: picolSetVar()
0E78 AE5C             (          xyz.asm):03157                 LDX     -4,U            pointer v
0E7A EC52             (          xyz.asm):03158                 LDD     -14,U           variable j
0E7C 58               (          xyz.asm):03159                 LSLB
0E7D 49               (          xyz.asm):03160                 ROLA
0E7E 308B             (          xyz.asm):03161                 LEAX    D,X             add byte offset
0E80 EC84             (          xyz.asm):03162                 LDD     ,X              get r-value
0E82 3406             (          xyz.asm):03163                 PSHS    B,A             argument 3 of picolSetVar(): char *
0E84 EC54             (          xyz.asm):03164                 LDD     -12,U           variable var, declared at xyz.c:1127
0E86 3406             (          xyz.asm):03165                 PSHS    B,A             argument 2 of picolSetVar(): char *
0E88 EC44             (          xyz.asm):03166                 LDD     4,U             variable i, declared at xyz.c:1125
0E8A 3406             (          xyz.asm):03167                 PSHS    B,A             argument 1 of picolSetVar(): struct picolInterp *
0E8C 171851           (          xyz.asm):03168                 LBSR    _picolSetVar
0E8F 3266             (          xyz.asm):03169                 LEAS    6,S
                      (          xyz.asm):03170         * Line xyz.c:1136: init of variable e
                      (          xyz.asm):03171         * Line xyz.c:1136: function call: picolEval()
0E91 EC58             (          xyz.asm):03172                 LDD     -8,U            variable body, declared at xyz.c:1129
0E93 3406             (          xyz.asm):03173                 PSHS    B,A             argument 2 of picolEval(): char *
0E95 EC44             (          xyz.asm):03174                 LDD     4,U             variable i, declared at xyz.c:1125
0E97 3406             (          xyz.asm):03175                 PSHS    B,A             argument 1 of picolEval(): struct picolInterp *
0E99 170954           (          xyz.asm):03176                 LBSR    _picolEval
0E9C 3264             (          xyz.asm):03177                 LEAS    4,S
0E9E ED50             (          xyz.asm):03178                 STD     -16,U           variable e
                      (          xyz.asm):03179         * Line xyz.c:1137: if
                      (          xyz.asm):03180         * optim: storeLoad
0EA0 10830004         (          xyz.asm):03181                 CMPD    #$04
0EA4 2602             (          xyz.asm):03182                 BNE     L00364
                      (          xyz.asm):03183         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03184         * Useless label L00363 removed
0EA6 2012             (          xyz.asm):03185                 BRA     L00361          continue
     0EA8             (          xyz.asm):03186         L00364  EQU     *               else
                      (          xyz.asm):03187         * Useless label L00365 removed
                      (          xyz.asm):03188         * Line xyz.c:1138: if
0EA8 EC50             (          xyz.asm):03189                 LDD     -16,U           variable e
0EAA 10830003         (          xyz.asm):03190                 CMPD    #$03
0EAE 2602             (          xyz.asm):03191                 BNE     L00367
                      (          xyz.asm):03192         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03193         * Useless label L00366 removed
0EB0 2018             (          xyz.asm):03194                 BRA     L00362          break
     0EB2             (          xyz.asm):03195         L00367  EQU     *               else
                      (          xyz.asm):03196         * Useless label L00368 removed
                      (          xyz.asm):03197         * Line xyz.c:1139: if
0EB2 EC50             (          xyz.asm):03198                 LDD     -16,U           variable e, declared at xyz.c:1136
                      (          xyz.asm):03199         * optim: loadCmpZeroBeqOrBne
0EB4 2704             (          xyz.asm):03200                 BEQ     L00370
                      (          xyz.asm):03201         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03202         * Useless label L00369 removed
                      (          xyz.asm):03203         * Line xyz.c:1139: return with value
0EB6 EC50             (          xyz.asm):03204                 LDD     -16,U           variable e, declared at xyz.c:1136
0EB8 201F             (          xyz.asm):03205                 BRA     L00071          return (xyz.c:1139)
     0EBA             (          xyz.asm):03206         L00370  EQU     *               else
                      (          xyz.asm):03207         * Useless label L00371 removed
     0EBA             (          xyz.asm):03208         L00361  EQU     *
                      (          xyz.asm):03209         * Line xyz.c:1134: for increment(s)
0EBA EC52             (          xyz.asm):03210                 LDD     -14,U
0EBC C30001           (          xyz.asm):03211                 ADDD    #1
0EBF ED52             (          xyz.asm):03212                 STD     -14,U
     0EC1             (          xyz.asm):03213         L00360  EQU     *
                      (          xyz.asm):03214         * Line xyz.c:1134: for condition
0EC1 EC52             (          xyz.asm):03215                 LDD     -14,U           variable j
0EC3 10A35A           (          xyz.asm):03216                 CMPD    -6,U            variable c
0EC6 102DFFAE         (          xyz.asm):03217                 LBLT    L00359
                      (          xyz.asm):03218         * optim: branchToNextLocation
     0ECA             (          xyz.asm):03219         L00362  EQU     *               end for
                      (          xyz.asm):03220         * Line xyz.c:1142: function call: picolSetResult()
0ECA 308D1D7A         (          xyz.asm):03221                 LEAX    S00095,PCR      ""
                      (          xyz.asm):03222         * optim: optimizePshsOps
0ECE EC44             (          xyz.asm):03223                 LDD     4,U             variable i, declared at xyz.c:1125
0ED0 3416             (          xyz.asm):03224                 PSHS    X,B,A           optim: optimizePshsOps
0ED2 1717E6           (          xyz.asm):03225                 LBSR    _picolSetResult
0ED5 3264             (          xyz.asm):03226                 LEAS    4,S
                      (          xyz.asm):03227         * Line xyz.c:1143: return with value
0ED7 4F               (          xyz.asm):03228                 CLRA
0ED8 5F               (          xyz.asm):03229                 CLRB
                      (          xyz.asm):03230         * optim: branchToNextLocation
     0ED9             (          xyz.asm):03231         L00071  EQU     *               end of picolCommandForEach()
0ED9 32C4             (          xyz.asm):03232                 LEAS    ,U
0EDB 35C0             (          xyz.asm):03233                 PULS    U,PC
                      (          xyz.asm):03234         * END FUNCTION picolCommandForEach(): defined at xyz.c:1125
     0EDD             (          xyz.asm):03235         funcend_picolCommandForEach     EQU *
     00BA             (          xyz.asm):03236         funcsize_picolCommandForEach    EQU     funcend_picolCommandForEach-_picolCommandForEach
                      (          xyz.asm):03237         
                      (          xyz.asm):03238         
                      (          xyz.asm):03239         *******************************************************************************
                      (          xyz.asm):03240         
                      (          xyz.asm):03241         * FUNCTION picolCommandFork(): defined at xyz.c:1196
     0EDD             (          xyz.asm):03242         _picolCommandFork       EQU     *
0EDD 3440             (          xyz.asm):03243                 PSHS    U
0EDF 171B6A           (          xyz.asm):03244                 LBSR    _stkcheck
0EE2 FFB8             (          xyz.asm):03245                 FDB     -72             argument for _stkcheck
0EE4 33E4             (          xyz.asm):03246                 LEAU    ,S
0EE6 3278             (          xyz.asm):03247                 LEAS    -8,S
                      (          xyz.asm):03248         * Formal parameters and locals:
                      (          xyz.asm):03249         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):03250         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):03251         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):03252         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):03253         *   program: char *; 2 bytes at -8,U
                      (          xyz.asm):03254         *   params: char *; 2 bytes at -6,U
                      (          xyz.asm):03255         *   child_id: int; 2 bytes at -4,U
                      (          xyz.asm):03256         *   e: int; 2 bytes at -2,U
                      (          xyz.asm):03257         * Line xyz.c:1197: if
0EE8 EC46             (          xyz.asm):03258                 LDD     6,U             variable argc
0EEA 10830002         (          xyz.asm):03259                 CMPD    #$02
0EEE 2C13             (          xyz.asm):03260                 BGE     L00373
                      (          xyz.asm):03261         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03262         * Useless label L00372 removed
                      (          xyz.asm):03263         * Line xyz.c:1198: function call: picolSetResult()
0EF0 308D1E51         (          xyz.asm):03264                 LEAX    S00114,PCR      "fork: too few args"
                      (          xyz.asm):03265         * optim: optimizePshsOps
0EF4 EC44             (          xyz.asm):03266                 LDD     4,U             variable i, declared at xyz.c:1196
0EF6 3416             (          xyz.asm):03267                 PSHS    X,B,A           optim: optimizePshsOps
0EF8 1717C0           (          xyz.asm):03268                 LBSR    _picolSetResult
0EFB 3264             (          xyz.asm):03269                 LEAS    4,S
                      (          xyz.asm):03270         * Line xyz.c:1199: return with value
0EFD 4F               (          xyz.asm):03271                 CLRA
0EFE C601             (          xyz.asm):03272                 LDB     #$01            decimal 1 signed
0F00 16006A           (          xyz.asm):03273                 LBRA    L00077          return (xyz.c:1199)
     0F03             (          xyz.asm):03274         L00373  EQU     *               else
                      (          xyz.asm):03275         * Useless label L00374 removed
                      (          xyz.asm):03276         * Line xyz.c:1201: init of variable program
0F03 AE48             (          xyz.asm):03277                 LDX     8,U             get pointer value
0F05 3002             (          xyz.asm):03278                 LEAX    2,X             add index (1) multiplied by pointed object size (2)
0F07 EC84             (          xyz.asm):03279                 LDD     ,X
0F09 ED58             (          xyz.asm):03280                 STD     -8,U            variable program
                      (          xyz.asm):03281         * Line xyz.c:1202: init of variable params
                      (          xyz.asm):03282         * Line xyz.c:1202: function call: FormList()
0F0B EC48             (          xyz.asm):03283                 LDD     8,U             variable argv
0F0D C30004           (          xyz.asm):03284                 ADDD    #$04            4
0F10 3406             (          xyz.asm):03285                 PSHS    B,A             argument 2 of FormList(): char **
0F12 EC46             (          xyz.asm):03286                 LDD     6,U             variable argc
0F14 C3FFFE           (          xyz.asm):03287                 ADDD    #$FFFE          65534
0F17 3406             (          xyz.asm):03288                 PSHS    B,A             argument 1 of FormList(): int
0F19 17F1D8           (          xyz.asm):03289                 LBSR    _FormList
0F1C 3264             (          xyz.asm):03290                 LEAS    4,S
0F1E ED5A             (          xyz.asm):03291                 STD     -6,U            variable params
                      (          xyz.asm):03292         * Line xyz.c:1203: init of variable child_id
0F20 4F               (          xyz.asm):03293                 CLRA
0F21 5F               (          xyz.asm):03294                 CLRB
0F22 ED5C             (          xyz.asm):03295                 STD     -4,U            variable child_id
                      (          xyz.asm):03296         * Line xyz.c:1204: init of variable e
                      (          xyz.asm):03297         * Line xyz.c:1204: function call: Os9Fork()
0F24 305C             (          xyz.asm):03298                 LEAX    -4,U            variable child_id, declared at xyz.c:1203
0F26 3410             (          xyz.asm):03299                 PSHS    X               argument 6 of Os9Fork(): int *
                      (          xyz.asm):03300         * optim: stripExtraClrA_B
                      (          xyz.asm):03301         * optim: stripExtraClrA_B
0F28 3406             (          xyz.asm):03302                 PSHS    B,A             argument 5 of Os9Fork(): int
                      (          xyz.asm):03303         * optim: stripExtraClrA_B
                      (          xyz.asm):03304         * optim: stripExtraClrA_B
0F2A 3406             (          xyz.asm):03305                 PSHS    B,A             argument 4 of Os9Fork(): int
                      (          xyz.asm):03306         * Line xyz.c:1204: function call: strlen()
0F2C EC5A             (          xyz.asm):03307                 LDD     -6,U            variable params, declared at xyz.c:1202
0F2E 3406             (          xyz.asm):03308                 PSHS    B,A             argument 1 of strlen(): char *
0F30 171C4C           (          xyz.asm):03309                 LBSR    _strlen
0F33 3262             (          xyz.asm):03310                 LEAS    2,S
0F35 3406             (          xyz.asm):03311                 PSHS    B,A             argument 3 of Os9Fork(): int
0F37 EC5A             (          xyz.asm):03312                 LDD     -6,U            variable params, declared at xyz.c:1202
0F39 3406             (          xyz.asm):03313                 PSHS    B,A             argument 2 of Os9Fork(): char *
0F3B EC58             (          xyz.asm):03314                 LDD     -8,U            variable program, declared at xyz.c:1201
0F3D 3406             (          xyz.asm):03315                 PSHS    B,A             argument 1 of Os9Fork(): char *
0F3F 17F2A9           (          xyz.asm):03316                 LBSR    _Os9Fork
0F42 326C             (          xyz.asm):03317                 LEAS    12,S
0F44 ED5E             (          xyz.asm):03318                 STD     -2,U            variable e
                      (          xyz.asm):03319         * Line xyz.c:1205: if
                      (          xyz.asm):03320         * optim: storeLoad
0F46 C30000           (          xyz.asm):03321                 ADDD    #0
0F49 2715             (          xyz.asm):03322                 BEQ     L00376
                      (          xyz.asm):03323         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03324         * Useless label L00375 removed
                      (          xyz.asm):03325         * Line xyz.c:1205: return with value
                      (          xyz.asm):03326         * Line xyz.c:1205: function call: Error()
0F4B EC5E             (          xyz.asm):03327                 LDD     -2,U            variable e, declared at xyz.c:1204
0F4D 3406             (          xyz.asm):03328                 PSHS    B,A             argument 3 of Error(): int
0F4F AE48             (          xyz.asm):03329                 LDX     8,U             get pointer value
0F51 EC84             (          xyz.asm):03330                 LDD     ,X
0F53 3406             (          xyz.asm):03331                 PSHS    B,A             argument 2 of Error(): char *
0F55 EC44             (          xyz.asm):03332                 LDD     4,U             variable i, declared at xyz.c:1196
0F57 3406             (          xyz.asm):03333                 PSHS    B,A             argument 1 of Error(): struct picolInterp *
0F59 17F14C           (          xyz.asm):03334                 LBSR    _Error
0F5C 3266             (          xyz.asm):03335                 LEAS    6,S
0F5E 200D             (          xyz.asm):03336                 BRA     L00077          return (xyz.c:1205)
     0F60             (          xyz.asm):03337         L00376  EQU     *               else
                      (          xyz.asm):03338         * Useless label L00377 removed
                      (          xyz.asm):03339         * Line xyz.c:1206: return with value
                      (          xyz.asm):03340         * Line xyz.c:1206: function call: ResultD()
0F60 EC5C             (          xyz.asm):03341                 LDD     -4,U            variable child_id, declared at xyz.c:1203
0F62 3406             (          xyz.asm):03342                 PSHS    B,A             argument 2 of ResultD(): int
0F64 EC44             (          xyz.asm):03343                 LDD     4,U             variable i, declared at xyz.c:1196
0F66 3406             (          xyz.asm):03344                 PSHS    B,A             argument 1 of ResultD(): struct picolInterp *
0F68 17F3A6           (          xyz.asm):03345                 LBSR    _ResultD
0F6B 3264             (          xyz.asm):03346                 LEAS    4,S
                      (          xyz.asm):03347         * optim: branchToNextLocation
     0F6D             (          xyz.asm):03348         L00077  EQU     *               end of picolCommandFork()
0F6D 32C4             (          xyz.asm):03349                 LEAS    ,U
0F6F 35C0             (          xyz.asm):03350                 PULS    U,PC
                      (          xyz.asm):03351         * END FUNCTION picolCommandFork(): defined at xyz.c:1196
     0F71             (          xyz.asm):03352         funcend_picolCommandFork        EQU *
     0094             (          xyz.asm):03353         funcsize_picolCommandFork       EQU     funcend_picolCommandFork-_picolCommandFork
                      (          xyz.asm):03354         
                      (          xyz.asm):03355         
                      (          xyz.asm):03356         *******************************************************************************
                      (          xyz.asm):03357         
                      (          xyz.asm):03358         * FUNCTION picolCommandIf(): defined at xyz.c:923
     0F71             (          xyz.asm):03359         _picolCommandIf EQU     *
0F71 3440             (          xyz.asm):03360                 PSHS    U
0F73 171AD6           (          xyz.asm):03361                 LBSR    _stkcheck
0F76 FFBE             (          xyz.asm):03362                 FDB     -66             argument for _stkcheck
0F78 33E4             (          xyz.asm):03363                 LEAU    ,S
0F7A 327E             (          xyz.asm):03364                 LEAS    -2,S
                      (          xyz.asm):03365         * Formal parameters and locals:
                      (          xyz.asm):03366         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):03367         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):03368         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):03369         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):03370         *   retcode: int; 2 bytes at -2,U
                      (          xyz.asm):03371         * Line xyz.c:925: if
0F7C EC46             (          xyz.asm):03372                 LDD     6,U             variable argc
0F7E 10830003         (          xyz.asm):03373                 CMPD    #$03
0F82 271A             (          xyz.asm):03374                 BEQ     L00379
                      (          xyz.asm):03375         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03376         * Useless label L00380 removed
0F84 EC46             (          xyz.asm):03377                 LDD     6,U             variable argc
0F86 10830005         (          xyz.asm):03378                 CMPD    #$05
0F8A 2712             (          xyz.asm):03379                 BEQ     L00379
                      (          xyz.asm):03380         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03381         * Useless label L00378 removed
                      (          xyz.asm):03382         * Line xyz.c:925: return with value
                      (          xyz.asm):03383         * Line xyz.c:925: function call: picolArityErr()
0F8C AE48             (          xyz.asm):03384                 LDX     8,U             get pointer value
0F8E EC84             (          xyz.asm):03385                 LDD     ,X
0F90 3406             (          xyz.asm):03386                 PSHS    B,A             argument 2 of picolArityErr(): char *
0F92 EC44             (          xyz.asm):03387                 LDD     4,U             variable i, declared at xyz.c:923
0F94 3406             (          xyz.asm):03388                 PSHS    B,A             argument 1 of picolArityErr(): struct picolInterp *
0F96 17FA73           (          xyz.asm):03389                 LBSR    _picolArityErr
0F99 3264             (          xyz.asm):03390                 LEAS    4,S
0F9B 16005D           (          xyz.asm):03391                 LBRA    L00055          return (xyz.c:925)
     0F9E             (          xyz.asm):03392         L00379  EQU     *               else
                      (          xyz.asm):03393         * Useless label L00381 removed
                      (          xyz.asm):03394         * Line xyz.c:926: if
                      (          xyz.asm):03395         * Line xyz.c:926: assignment: =
                      (          xyz.asm):03396         * Line xyz.c:926: function call: picolEval()
0F9E AE48             (          xyz.asm):03397                 LDX     8,U             get pointer value
0FA0 3002             (          xyz.asm):03398                 LEAX    2,X             add index (1) multiplied by pointed object size (2)
0FA2 EC84             (          xyz.asm):03399                 LDD     ,X
0FA4 3406             (          xyz.asm):03400                 PSHS    B,A             argument 2 of picolEval(): char *
0FA6 EC44             (          xyz.asm):03401                 LDD     4,U             variable i, declared at xyz.c:923
0FA8 3406             (          xyz.asm):03402                 PSHS    B,A             argument 1 of picolEval(): struct picolInterp *
0FAA 170843           (          xyz.asm):03403                 LBSR    _picolEval
0FAD 3264             (          xyz.asm):03404                 LEAS    4,S
0FAF ED5E             (          xyz.asm):03405                 STD     -2,U
0FB1 C30000           (          xyz.asm):03406                 ADDD    #0
0FB4 2705             (          xyz.asm):03407                 BEQ     L00383
                      (          xyz.asm):03408         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03409         * Useless label L00382 removed
                      (          xyz.asm):03410         * Line xyz.c:926: return with value
0FB6 EC5E             (          xyz.asm):03411                 LDD     -2,U            variable retcode, declared at xyz.c:924
0FB8 160040           (          xyz.asm):03412                 LBRA    L00055          return (xyz.c:926)
     0FBB             (          xyz.asm):03413         L00383  EQU     *               else
                      (          xyz.asm):03414         * Useless label L00384 removed
                      (          xyz.asm):03415         * Line xyz.c:927: if
                      (          xyz.asm):03416         * Line xyz.c:927: function call: atoi()
0FBB AE44             (          xyz.asm):03417                 LDX     4,U             variable i
0FBD EC06             (          xyz.asm):03418                 LDD     6,X             member result of picolInterp
0FBF 3406             (          xyz.asm):03419                 PSHS    B,A             argument 1 of atoi(): char *
0FC1 17F46B           (          xyz.asm):03420                 LBSR    _atoi
0FC4 3262             (          xyz.asm):03421                 LEAS    2,S
0FC6 C30000           (          xyz.asm):03422                 ADDD    #0
0FC9 2713             (          xyz.asm):03423                 BEQ     L00386
                      (          xyz.asm):03424         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03425         * Useless label L00385 removed
                      (          xyz.asm):03426         * Line xyz.c:927: return with value
                      (          xyz.asm):03427         * Line xyz.c:927: function call: picolEval()
0FCB AE48             (          xyz.asm):03428                 LDX     8,U             get pointer value
0FCD 3004             (          xyz.asm):03429                 LEAX    4,X             add index (2) multiplied by pointed object size (2)
0FCF EC84             (          xyz.asm):03430                 LDD     ,X
0FD1 3406             (          xyz.asm):03431                 PSHS    B,A             argument 2 of picolEval(): char *
0FD3 EC44             (          xyz.asm):03432                 LDD     4,U             variable i, declared at xyz.c:923
0FD5 3406             (          xyz.asm):03433                 PSHS    B,A             argument 1 of picolEval(): struct picolInterp *
0FD7 170816           (          xyz.asm):03434                 LBSR    _picolEval
0FDA 3264             (          xyz.asm):03435                 LEAS    4,S
0FDC 201D             (          xyz.asm):03436                 BRA     L00055          return (xyz.c:927)
                      (          xyz.asm):03437         * optim: instrFollowingUncondBranch
     0FDE             (          xyz.asm):03438         L00386  EQU     *               else
                      (          xyz.asm):03439         * Line xyz.c:928: if
0FDE EC46             (          xyz.asm):03440                 LDD     6,U             variable argc
0FE0 10830005         (          xyz.asm):03441                 CMPD    #$05
0FE4 2613             (          xyz.asm):03442                 BNE     L00389
                      (          xyz.asm):03443         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03444         * Useless label L00388 removed
                      (          xyz.asm):03445         * Line xyz.c:928: return with value
                      (          xyz.asm):03446         * Line xyz.c:928: function call: picolEval()
0FE6 AE48             (          xyz.asm):03447                 LDX     8,U             get pointer value
0FE8 3008             (          xyz.asm):03448                 LEAX    8,X             add index (4) multiplied by pointed object size (2)
0FEA EC84             (          xyz.asm):03449                 LDD     ,X
0FEC 3406             (          xyz.asm):03450                 PSHS    B,A             argument 2 of picolEval(): char *
0FEE EC44             (          xyz.asm):03451                 LDD     4,U             variable i, declared at xyz.c:923
0FF0 3406             (          xyz.asm):03452                 PSHS    B,A             argument 1 of picolEval(): struct picolInterp *
0FF2 1707FB           (          xyz.asm):03453                 LBSR    _picolEval
0FF5 3264             (          xyz.asm):03454                 LEAS    4,S
0FF7 2002             (          xyz.asm):03455                 BRA     L00055          return (xyz.c:928)
     0FF9             (          xyz.asm):03456         L00389  EQU     *               else
                      (          xyz.asm):03457         * Useless label L00390 removed
                      (          xyz.asm):03458         * Useless label L00387 removed
                      (          xyz.asm):03459         * Line xyz.c:929: return with value
0FF9 4F               (          xyz.asm):03460                 CLRA
0FFA 5F               (          xyz.asm):03461                 CLRB
                      (          xyz.asm):03462         * optim: branchToNextLocation
     0FFB             (          xyz.asm):03463         L00055  EQU     *               end of picolCommandIf()
0FFB 32C4             (          xyz.asm):03464                 LEAS    ,U
0FFD 35C0             (          xyz.asm):03465                 PULS    U,PC
                      (          xyz.asm):03466         * END FUNCTION picolCommandIf(): defined at xyz.c:923
     0FFF             (          xyz.asm):03467         funcend_picolCommandIf  EQU *
     008E             (          xyz.asm):03468         funcsize_picolCommandIf EQU     funcend_picolCommandIf-_picolCommandIf
                      (          xyz.asm):03469         
                      (          xyz.asm):03470         
                      (          xyz.asm):03471         *******************************************************************************
                      (          xyz.asm):03472         
                      (          xyz.asm):03473         * FUNCTION picolCommandInfo(): defined at xyz.c:1024
     0FFF             (          xyz.asm):03474         _picolCommandInfo       EQU     *
0FFF 3440             (          xyz.asm):03475                 PSHS    U
1001 171A48           (          xyz.asm):03476                 LBSR    _stkcheck
1004 FFBA             (          xyz.asm):03477                 FDB     -70             argument for _stkcheck
1006 33E4             (          xyz.asm):03478                 LEAU    ,S
1008 327A             (          xyz.asm):03479                 LEAS    -6,S
                      (          xyz.asm):03480         * Formal parameters and locals:
                      (          xyz.asm):03481         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):03482         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):03483         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):03484         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):03485         *   c: struct picolCmd *; 2 bytes at -4,U
                      (          xyz.asm):03486         *   f: struct picolCallFrame *; 2 bytes at -2,U
                      (          xyz.asm):03487         * Line xyz.c:1025: function call: puts()
100A 308D1CE3         (          xyz.asm):03488                 LEAX    S00106,PCR      " procs: "
100E 3410             (          xyz.asm):03489                 PSHS    X               argument 1 of puts(): const char[]
1010 171835           (          xyz.asm):03490                 LBSR    _puts
1013 3262             (          xyz.asm):03491                 LEAS    2,S
                      (          xyz.asm):03492         * Line xyz.c:1027: for init
                      (          xyz.asm):03493         * Line xyz.c:1027: assignment: =
1015 AE44             (          xyz.asm):03494                 LDX     4,U             variable i
1017 EC04             (          xyz.asm):03495                 LDD     4,X             member commands of picolInterp
1019 ED5C             (          xyz.asm):03496                 STD     -4,U
101B 2033             (          xyz.asm):03497                 BRA     L00392          jump to for condition
     101D             (          xyz.asm):03498         L00391  EQU     *
                      (          xyz.asm):03499         * Line xyz.c:1027: for body
                      (          xyz.asm):03500         * Line xyz.c:1028: if
101D 308DFA24         (          xyz.asm):03501                 LEAX    _picolCommandCallProc,PCR       address of picolCommandCallProc(), defined at xyz.c:969
1021 3410             (          xyz.asm):03502                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):03503         * optim: optimizeTfrPush
1023 AE5C             (          xyz.asm):03504                 LDX     -4,U            variable c
1025 EC02             (          xyz.asm):03505                 LDD     2,X             member func of picolCmd
1027 10A3E1           (          xyz.asm):03506                 CMPD    ,S++
102A 2702             (          xyz.asm):03507                 BEQ     L00396
                      (          xyz.asm):03508         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03509         * Useless label L00395 removed
102C 201C             (          xyz.asm):03510                 BRA     L00393          continue
     102E             (          xyz.asm):03511         L00396  EQU     *               else
                      (          xyz.asm):03512         * Useless label L00397 removed
                      (          xyz.asm):03513         * Line xyz.c:1029: function call: puts()
102E AE5C             (          xyz.asm):03514                 LDX     -4,U            variable c
1030 EC84             (          xyz.asm):03515                 LDD     ,X              member name of picolCmd
1032 3406             (          xyz.asm):03516                 PSHS    B,A             argument 1 of puts(): char *
1034 171811           (          xyz.asm):03517                 LBSR    _puts
1037 3262             (          xyz.asm):03518                 LEAS    2,S
                      (          xyz.asm):03519         * Line xyz.c:1030: function call: puts()
1039 308D1CBD         (          xyz.asm):03520                 LEAX    S00107,PCR      " "
103D 3410             (          xyz.asm):03521                 PSHS    X               argument 1 of puts(): const char[]
103F 171806           (          xyz.asm):03522                 LBSR    _puts
1042 3262             (          xyz.asm):03523                 LEAS    2,S
                      (          xyz.asm):03524         * Line xyz.c:1031: assignment: =
1044 AE5C             (          xyz.asm):03525                 LDX     -4,U            variable c
1046 EC06             (          xyz.asm):03526                 LDD     6,X             member next of picolCmd
1048 ED5C             (          xyz.asm):03527                 STD     -4,U
     104A             (          xyz.asm):03528         L00393  EQU     *
                      (          xyz.asm):03529         * Line xyz.c:1027: for increment(s)
                      (          xyz.asm):03530         * Line xyz.c:1027: assignment: =
104A AE5C             (          xyz.asm):03531                 LDX     -4,U            variable c
104C EC06             (          xyz.asm):03532                 LDD     6,X             member next of picolCmd
104E ED5C             (          xyz.asm):03533                 STD     -4,U
     1050             (          xyz.asm):03534         L00392  EQU     *
                      (          xyz.asm):03535         * Line xyz.c:1027: for condition
1050 EC5C             (          xyz.asm):03536                 LDD     -4,U            variable c, declared at xyz.c:1026
                      (          xyz.asm):03537         * optim: loadCmpZeroBeqOrBne
1052 26C9             (          xyz.asm):03538                 BNE     L00391
                      (          xyz.asm):03539         * optim: branchToNextLocation
                      (          xyz.asm):03540         * Useless label L00394 removed
                      (          xyz.asm):03541         * Line xyz.c:1033: function call: puts()
1054 308D1C64         (          xyz.asm):03542                 LEAX    S00102,PCR      "\r"
1058 3410             (          xyz.asm):03543                 PSHS    X               argument 1 of puts(): const char[]
105A 1717EB           (          xyz.asm):03544                 LBSR    _puts
105D 3262             (          xyz.asm):03545                 LEAS    2,S
                      (          xyz.asm):03546         * Line xyz.c:1035: function call: puts()
105F 308D1C99         (          xyz.asm):03547                 LEAX    S00108,PCR      " other commands: "
1063 3410             (          xyz.asm):03548                 PSHS    X               argument 1 of puts(): const char[]
1065 1717E0           (          xyz.asm):03549                 LBSR    _puts
1068 3262             (          xyz.asm):03550                 LEAS    2,S
                      (          xyz.asm):03551         * Line xyz.c:1036: for init
                      (          xyz.asm):03552         * Line xyz.c:1036: assignment: =
106A AE44             (          xyz.asm):03553                 LDX     4,U             variable i
106C EC04             (          xyz.asm):03554                 LDD     4,X             member commands of picolInterp
106E ED5C             (          xyz.asm):03555                 STD     -4,U
1070 2033             (          xyz.asm):03556                 BRA     L00399          jump to for condition
     1072             (          xyz.asm):03557         L00398  EQU     *
                      (          xyz.asm):03558         * Line xyz.c:1036: for body
                      (          xyz.asm):03559         * Line xyz.c:1037: if
1072 308DF9CF         (          xyz.asm):03560                 LEAX    _picolCommandCallProc,PCR       address of picolCommandCallProc(), defined at xyz.c:969
1076 3410             (          xyz.asm):03561                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):03562         * optim: optimizeTfrPush
1078 AE5C             (          xyz.asm):03563                 LDX     -4,U            variable c
107A EC02             (          xyz.asm):03564                 LDD     2,X             member func of picolCmd
107C 10A3E1           (          xyz.asm):03565                 CMPD    ,S++
107F 2602             (          xyz.asm):03566                 BNE     L00403
                      (          xyz.asm):03567         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03568         * Useless label L00402 removed
1081 201C             (          xyz.asm):03569                 BRA     L00400          continue
     1083             (          xyz.asm):03570         L00403  EQU     *               else
                      (          xyz.asm):03571         * Useless label L00404 removed
                      (          xyz.asm):03572         * Line xyz.c:1038: function call: puts()
1083 AE5C             (          xyz.asm):03573                 LDX     -4,U            variable c
1085 EC84             (          xyz.asm):03574                 LDD     ,X              member name of picolCmd
1087 3406             (          xyz.asm):03575                 PSHS    B,A             argument 1 of puts(): char *
1089 1717BC           (          xyz.asm):03576                 LBSR    _puts
108C 3262             (          xyz.asm):03577                 LEAS    2,S
                      (          xyz.asm):03578         * Line xyz.c:1039: function call: puts()
108E 308D1C68         (          xyz.asm):03579                 LEAX    S00107,PCR      " "
1092 3410             (          xyz.asm):03580                 PSHS    X               argument 1 of puts(): const char[]
1094 1717B1           (          xyz.asm):03581                 LBSR    _puts
1097 3262             (          xyz.asm):03582                 LEAS    2,S
                      (          xyz.asm):03583         * Line xyz.c:1040: assignment: =
1099 AE5C             (          xyz.asm):03584                 LDX     -4,U            variable c
109B EC06             (          xyz.asm):03585                 LDD     6,X             member next of picolCmd
109D ED5C             (          xyz.asm):03586                 STD     -4,U
     109F             (          xyz.asm):03587         L00400  EQU     *
                      (          xyz.asm):03588         * Line xyz.c:1036: for increment(s)
                      (          xyz.asm):03589         * Line xyz.c:1036: assignment: =
109F AE5C             (          xyz.asm):03590                 LDX     -4,U            variable c
10A1 EC06             (          xyz.asm):03591                 LDD     6,X             member next of picolCmd
10A3 ED5C             (          xyz.asm):03592                 STD     -4,U
     10A5             (          xyz.asm):03593         L00399  EQU     *
                      (          xyz.asm):03594         * Line xyz.c:1036: for condition
10A5 EC5C             (          xyz.asm):03595                 LDD     -4,U            variable c, declared at xyz.c:1026
                      (          xyz.asm):03596         * optim: loadCmpZeroBeqOrBne
10A7 26C9             (          xyz.asm):03597                 BNE     L00398
                      (          xyz.asm):03598         * optim: branchToNextLocation
                      (          xyz.asm):03599         * Useless label L00401 removed
                      (          xyz.asm):03600         * Line xyz.c:1042: function call: puts()
10A9 308D1C0F         (          xyz.asm):03601                 LEAX    S00102,PCR      "\r"
10AD 3410             (          xyz.asm):03602                 PSHS    X               argument 1 of puts(): const char[]
10AF 171796           (          xyz.asm):03603                 LBSR    _puts
10B2 3262             (          xyz.asm):03604                 LEAS    2,S
                      (          xyz.asm):03605         * Line xyz.c:1045: for init
                      (          xyz.asm):03606         * Line xyz.c:1045: assignment: =
10B4 AE44             (          xyz.asm):03607                 LDX     4,U             variable i
10B6 EC02             (          xyz.asm):03608                 LDD     2,X             member callframe of picolInterp
10B8 ED5E             (          xyz.asm):03609                 STD     -2,U
10BA 160069           (          xyz.asm):03610                 LBRA    L00406          jump to for condition
     10BD             (          xyz.asm):03611         L00405  EQU     *
                      (          xyz.asm):03612         * Line xyz.c:1045: for body
                      (          xyz.asm):03613         * Line xyz.c:1046: function call: puts()
10BD AE5E             (          xyz.asm):03614                 LDX     -2,U            variable f
10BF EC02             (          xyz.asm):03615                 LDD     2,X             member parent of picolCallFrame
                      (          xyz.asm):03616         * optim: loadCmpZeroBeqOrBne
10C1 2708             (          xyz.asm):03617                 BEQ     L00409          if conditional expression is false
10C3 308D1C47         (          xyz.asm):03618                 LEAX    S00109,PCR      " frame: "
10C7 1F10             (          xyz.asm):03619                 TFR     X,D
10C9 2006             (          xyz.asm):03620                 BRA     L00410          end of true expression of conditional
     10CB             (          xyz.asm):03621         L00409  EQU     *
10CB 308D1C48         (          xyz.asm):03622                 LEAX    S00110,PCR      " globals: "
10CF 1F10             (          xyz.asm):03623                 TFR     X,D
     10D1             (          xyz.asm):03624         L00410  EQU     *
10D1 3406             (          xyz.asm):03625                 PSHS    B,A             argument 1 of puts(): const char[]
10D3 171772           (          xyz.asm):03626                 LBSR    _puts
10D6 3262             (          xyz.asm):03627                 LEAS    2,S
                      (          xyz.asm):03628         * Line xyz.c:1048: for init
                      (          xyz.asm):03629         * Line xyz.c:1048: assignment: =
                      (          xyz.asm):03630         * optim: optimizeIndexedX
10D8 ECD8FE           (          xyz.asm):03631                 LDD     [-2,U]          optim: optimizeIndexedX
10DB ED5A             (          xyz.asm):03632                 STD     -6,U
10DD 2032             (          xyz.asm):03633                 BRA     L00412          jump to for condition
     10DF             (          xyz.asm):03634         L00411  EQU     *
                      (          xyz.asm):03635         * Line xyz.c:1048: for body
                      (          xyz.asm):03636         * Line xyz.c:1049: function call: puts()
10DF AE5A             (          xyz.asm):03637                 LDX     -6,U            variable v
10E1 EC84             (          xyz.asm):03638                 LDD     ,X              member name of picolVar
10E3 3406             (          xyz.asm):03639                 PSHS    B,A             argument 1 of puts(): char *
10E5 171760           (          xyz.asm):03640                 LBSR    _puts
10E8 3262             (          xyz.asm):03641                 LEAS    2,S
                      (          xyz.asm):03642         * Line xyz.c:1049: function call: puts()
10EA 308D1C34         (          xyz.asm):03643                 LEAX    S00111,PCR      "="
10EE 3410             (          xyz.asm):03644                 PSHS    X               argument 1 of puts(): const char[]
10F0 171755           (          xyz.asm):03645                 LBSR    _puts
10F3 3262             (          xyz.asm):03646                 LEAS    2,S
                      (          xyz.asm):03647         * Line xyz.c:1050: function call: puts()
10F5 AE5A             (          xyz.asm):03648                 LDX     -6,U            variable v
10F7 EC02             (          xyz.asm):03649                 LDD     2,X             member val of picolVar
10F9 3406             (          xyz.asm):03650                 PSHS    B,A             argument 1 of puts(): char *
10FB 17174A           (          xyz.asm):03651                 LBSR    _puts
10FE 3262             (          xyz.asm):03652                 LEAS    2,S
                      (          xyz.asm):03653         * Line xyz.c:1050: function call: puts()
1100 308D1BF6         (          xyz.asm):03654                 LEAX    S00107,PCR      " "
1104 3410             (          xyz.asm):03655                 PSHS    X               argument 1 of puts(): const char[]
1106 17173F           (          xyz.asm):03656                 LBSR    _puts
1109 3262             (          xyz.asm):03657                 LEAS    2,S
                      (          xyz.asm):03658         * Useless label L00413 removed
                      (          xyz.asm):03659         * Line xyz.c:1048: for increment(s)
                      (          xyz.asm):03660         * Line xyz.c:1048: assignment: =
110B AE5A             (          xyz.asm):03661                 LDX     -6,U            variable v
110D EC04             (          xyz.asm):03662                 LDD     4,X             member next of picolVar
110F ED5A             (          xyz.asm):03663                 STD     -6,U
     1111             (          xyz.asm):03664         L00412  EQU     *
                      (          xyz.asm):03665         * Line xyz.c:1048: for condition
1111 EC5A             (          xyz.asm):03666                 LDD     -6,U            variable v, declared at xyz.c:1047
                      (          xyz.asm):03667         * optim: loadCmpZeroBeqOrBne
1113 26CA             (          xyz.asm):03668                 BNE     L00411
                      (          xyz.asm):03669         * optim: branchToNextLocation
                      (          xyz.asm):03670         * Useless label L00414 removed
                      (          xyz.asm):03671         * Line xyz.c:1052: function call: puts()
1115 308D1BA3         (          xyz.asm):03672                 LEAX    S00102,PCR      "\r"
1119 3410             (          xyz.asm):03673                 PSHS    X               argument 1 of puts(): const char[]
111B 17172A           (          xyz.asm):03674                 LBSR    _puts
111E 3262             (          xyz.asm):03675                 LEAS    2,S
                      (          xyz.asm):03676         * Useless label L00407 removed
                      (          xyz.asm):03677         * Line xyz.c:1045: for increment(s)
                      (          xyz.asm):03678         * Line xyz.c:1045: assignment: =
1120 AE5E             (          xyz.asm):03679                 LDX     -2,U            variable f
1122 EC02             (          xyz.asm):03680                 LDD     2,X             member parent of picolCallFrame
1124 ED5E             (          xyz.asm):03681                 STD     -2,U
     1126             (          xyz.asm):03682         L00406  EQU     *
                      (          xyz.asm):03683         * Line xyz.c:1045: for condition
1126 EC5E             (          xyz.asm):03684                 LDD     -2,U            variable f, declared at xyz.c:1044
                      (          xyz.asm):03685         * optim: loadCmpZeroBeqOrBne
1128 1026FF91         (          xyz.asm):03686                 LBNE    L00405
                      (          xyz.asm):03687         * optim: branchToNextLocation
                      (          xyz.asm):03688         * Useless label L00408 removed
                      (          xyz.asm):03689         * Line xyz.c:1055: function call: picolSetResult()
112C 308D1B18         (          xyz.asm):03690                 LEAX    S00095,PCR      ""
                      (          xyz.asm):03691         * optim: optimizePshsOps
1130 EC44             (          xyz.asm):03692                 LDD     4,U             variable i, declared at xyz.c:1024
1132 3416             (          xyz.asm):03693                 PSHS    X,B,A           optim: optimizePshsOps
1134 171584           (          xyz.asm):03694                 LBSR    _picolSetResult
1137 3264             (          xyz.asm):03695                 LEAS    4,S
                      (          xyz.asm):03696         * Line xyz.c:1056: return with value
1139 4F               (          xyz.asm):03697                 CLRA
113A 5F               (          xyz.asm):03698                 CLRB
                      (          xyz.asm):03699         * optim: branchToNextLocation
                      (          xyz.asm):03700         * Useless label L00064 removed
113B 32C4             (          xyz.asm):03701                 LEAS    ,U
113D 35C0             (          xyz.asm):03702                 PULS    U,PC
                      (          xyz.asm):03703         * END FUNCTION picolCommandInfo(): defined at xyz.c:1024
     113F             (          xyz.asm):03704         funcend_picolCommandInfo        EQU *
     0140             (          xyz.asm):03705         funcsize_picolCommandInfo       EQU     funcend_picolCommandInfo-_picolCommandInfo
                      (          xyz.asm):03706         
                      (          xyz.asm):03707         
                      (          xyz.asm):03708         *******************************************************************************
                      (          xyz.asm):03709         
                      (          xyz.asm):03710         * FUNCTION picolCommandList(): defined at xyz.c:1164
     113F             (          xyz.asm):03711         _picolCommandList       EQU     *
113F 3440             (          xyz.asm):03712                 PSHS    U
1141 171908           (          xyz.asm):03713                 LBSR    _stkcheck
1144 FFBE             (          xyz.asm):03714                 FDB     -66             argument for _stkcheck
1146 33E4             (          xyz.asm):03715                 LEAU    ,S
1148 327E             (          xyz.asm):03716                 LEAS    -2,S
                      (          xyz.asm):03717         * Formal parameters and locals:
                      (          xyz.asm):03718         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):03719         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):03720         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):03721         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):03722         *   s: char *; 2 bytes at -2,U
                      (          xyz.asm):03723         * Line xyz.c:1165: init of variable s
                      (          xyz.asm):03724         * Line xyz.c:1165: function call: FormList()
114A EC48             (          xyz.asm):03725                 LDD     8,U             variable argv
114C C30002           (          xyz.asm):03726                 ADDD    #$02            2
114F 3406             (          xyz.asm):03727                 PSHS    B,A             argument 2 of FormList(): char **
1151 EC46             (          xyz.asm):03728                 LDD     6,U             variable argc
1153 C3FFFF           (          xyz.asm):03729                 ADDD    #$FFFF          65535
1156 3406             (          xyz.asm):03730                 PSHS    B,A             argument 1 of FormList(): int
1158 17EF99           (          xyz.asm):03731                 LBSR    _FormList
115B 3264             (          xyz.asm):03732                 LEAS    4,S
115D ED5E             (          xyz.asm):03733                 STD     -2,U            variable s
                      (          xyz.asm):03734         * Line xyz.c:1166: function call: picolSetResult()
                      (          xyz.asm):03735         * optim: storeLoad
115F 3406             (          xyz.asm):03736                 PSHS    B,A             argument 2 of picolSetResult(): char *
1161 EC44             (          xyz.asm):03737                 LDD     4,U             variable i, declared at xyz.c:1164
1163 3406             (          xyz.asm):03738                 PSHS    B,A             argument 1 of picolSetResult(): struct picolInterp *
1165 171553           (          xyz.asm):03739                 LBSR    _picolSetResult
1168 3264             (          xyz.asm):03740                 LEAS    4,S
                      (          xyz.asm):03741         * Line xyz.c:1167: return with value
116A 4F               (          xyz.asm):03742                 CLRA
116B 5F               (          xyz.asm):03743                 CLRB
                      (          xyz.asm):03744         * optim: branchToNextLocation
                      (          xyz.asm):03745         * Useless label L00073 removed
116C 32C4             (          xyz.asm):03746                 LEAS    ,U
116E 35C0             (          xyz.asm):03747                 PULS    U,PC
                      (          xyz.asm):03748         * END FUNCTION picolCommandList(): defined at xyz.c:1164
     1170             (          xyz.asm):03749         funcend_picolCommandList        EQU *
     0031             (          xyz.asm):03750         funcsize_picolCommandList       EQU     funcend_picolCommandList-_picolCommandList
                      (          xyz.asm):03751         
                      (          xyz.asm):03752         
                      (          xyz.asm):03753         *******************************************************************************
                      (          xyz.asm):03754         
                      (          xyz.asm):03755         * FUNCTION picolCommandMath(): defined at xyz.c:864
     1170             (          xyz.asm):03756         _picolCommandMath       EQU     *
1170 3440             (          xyz.asm):03757                 PSHS    U
1172 1718D7           (          xyz.asm):03758                 LBSR    _stkcheck
1175 FFB2             (          xyz.asm):03759                 FDB     -78             argument for _stkcheck
1177 33E4             (          xyz.asm):03760                 LEAU    ,S
1179 3272             (          xyz.asm):03761                 LEAS    -14,S
                      (          xyz.asm):03762         * Formal parameters and locals:
                      (          xyz.asm):03763         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):03764         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):03765         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):03766         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):03767         *   buf: char[]; 8 bytes at -14,U
                      (          xyz.asm):03768         *   a: int; 2 bytes at -6,U
                      (          xyz.asm):03769         *   b: int; 2 bytes at -4,U
                      (          xyz.asm):03770         *   c: int; 2 bytes at -2,U
                      (          xyz.asm):03771         * Line xyz.c:866: if
117B EC46             (          xyz.asm):03772                 LDD     6,U             variable argc
117D 10830003         (          xyz.asm):03773                 CMPD    #$03
1181 2712             (          xyz.asm):03774                 BEQ     L00416
                      (          xyz.asm):03775         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03776         * Useless label L00415 removed
                      (          xyz.asm):03777         * Line xyz.c:866: return with value
                      (          xyz.asm):03778         * Line xyz.c:866: function call: picolArityErr()
1183 AE48             (          xyz.asm):03779                 LDX     8,U             get pointer value
1185 EC84             (          xyz.asm):03780                 LDD     ,X
1187 3406             (          xyz.asm):03781                 PSHS    B,A             argument 2 of picolArityErr(): char *
1189 EC44             (          xyz.asm):03782                 LDD     4,U             variable i, declared at xyz.c:864
118B 3406             (          xyz.asm):03783                 PSHS    B,A             argument 1 of picolArityErr(): struct picolInterp *
118D 17F87C           (          xyz.asm):03784                 LBSR    _picolArityErr
1190 3264             (          xyz.asm):03785                 LEAS    4,S
1192 1601C8           (          xyz.asm):03786                 LBRA    L00052          return (xyz.c:866)
     1195             (          xyz.asm):03787         L00416  EQU     *               else
                      (          xyz.asm):03788         * Useless label L00417 removed
                      (          xyz.asm):03789         * Line xyz.c:867: assignment: =
                      (          xyz.asm):03790         * Line xyz.c:867: function call: atoi()
1195 AE48             (          xyz.asm):03791                 LDX     8,U             get pointer value
1197 3002             (          xyz.asm):03792                 LEAX    2,X             add index (1) multiplied by pointed object size (2)
1199 EC84             (          xyz.asm):03793                 LDD     ,X
119B 3406             (          xyz.asm):03794                 PSHS    B,A             argument 1 of atoi(): char *
119D 17F28F           (          xyz.asm):03795                 LBSR    _atoi
11A0 3262             (          xyz.asm):03796                 LEAS    2,S
11A2 ED5A             (          xyz.asm):03797                 STD     -6,U
                      (          xyz.asm):03798         * Line xyz.c:867: assignment: =
                      (          xyz.asm):03799         * Line xyz.c:867: function call: atoi()
11A4 AE48             (          xyz.asm):03800                 LDX     8,U             get pointer value
11A6 3004             (          xyz.asm):03801                 LEAX    4,X             add index (2) multiplied by pointed object size (2)
11A8 EC84             (          xyz.asm):03802                 LDD     ,X
11AA 3406             (          xyz.asm):03803                 PSHS    B,A             argument 1 of atoi(): char *
11AC 17F280           (          xyz.asm):03804                 LBSR    _atoi
11AF 3262             (          xyz.asm):03805                 LEAS    2,S
11B1 ED5C             (          xyz.asm):03806                 STD     -4,U
                      (          xyz.asm):03807         * Line xyz.c:868: if
11B3 C62B             (          xyz.asm):03808                 LDB     #$2B            optim: lddToLDB
11B5 1D               (          xyz.asm):03809                 SEX                     promotion of binary operand
11B6 3406             (          xyz.asm):03810                 PSHS    B,A
                      (          xyz.asm):03811         * optim: optimizeLdx
11B8 AED808           (          xyz.asm):03812                 LDX     [8,U]           optim: optimizeLdx
                      (          xyz.asm):03813         * optim: removeTfrDX
11BB E684             (          xyz.asm):03814                 LDB     ,X              get r-value
11BD 1D               (          xyz.asm):03815                 SEX                     promotion of binary operand
11BE 10A3E1           (          xyz.asm):03816                 CMPD    ,S++
11C1 2609             (          xyz.asm):03817                 BNE     L00419
                      (          xyz.asm):03818         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03819         * Useless label L00418 removed
                      (          xyz.asm):03820         * Line xyz.c:868: assignment: =
                      (          xyz.asm):03821         * optim: optimizeStackOperations4
                      (          xyz.asm):03822         * optim: optimizeStackOperations4
11C3 EC5A             (          xyz.asm):03823                 LDD     -6,U            variable a, declared at xyz.c:865
11C5 E35C             (          xyz.asm):03824                 ADDD    -4,U            optim: optimizeStackOperations4
11C7 ED5E             (          xyz.asm):03825                 STD     -2,U
11C9 16016E           (          xyz.asm):03826                 LBRA    L00420          jump over else clause
     11CC             (          xyz.asm):03827         L00419  EQU     *               else
                      (          xyz.asm):03828         * Line xyz.c:869: if
11CC C62D             (          xyz.asm):03829                 LDB     #$2D            optim: lddToLDB
11CE 1D               (          xyz.asm):03830                 SEX                     promotion of binary operand
11CF 3406             (          xyz.asm):03831                 PSHS    B,A
                      (          xyz.asm):03832         * optim: optimizeLdx
11D1 AED808           (          xyz.asm):03833                 LDX     [8,U]           optim: optimizeLdx
                      (          xyz.asm):03834         * optim: removeTfrDX
11D4 E684             (          xyz.asm):03835                 LDB     ,X              get r-value
11D6 1D               (          xyz.asm):03836                 SEX                     promotion of binary operand
11D7 10A3E1           (          xyz.asm):03837                 CMPD    ,S++
11DA 2609             (          xyz.asm):03838                 BNE     L00422
                      (          xyz.asm):03839         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03840         * Useless label L00421 removed
                      (          xyz.asm):03841         * Line xyz.c:869: assignment: =
                      (          xyz.asm):03842         * optim: optimizeStackOperations4
                      (          xyz.asm):03843         * optim: optimizeStackOperations4
11DC EC5A             (          xyz.asm):03844                 LDD     -6,U            variable a, declared at xyz.c:865
11DE A35C             (          xyz.asm):03845                 SUBD    -4,U            optim: optimizeStackOperations4
11E0 ED5E             (          xyz.asm):03846                 STD     -2,U
11E2 160155           (          xyz.asm):03847                 LBRA    L00423          jump over else clause
     11E5             (          xyz.asm):03848         L00422  EQU     *               else
                      (          xyz.asm):03849         * Line xyz.c:870: if
11E5 C62A             (          xyz.asm):03850                 LDB     #$2A            optim: lddToLDB
11E7 1D               (          xyz.asm):03851                 SEX                     promotion of binary operand
11E8 3406             (          xyz.asm):03852                 PSHS    B,A
                      (          xyz.asm):03853         * optim: optimizeLdx
11EA AED808           (          xyz.asm):03854                 LDX     [8,U]           optim: optimizeLdx
                      (          xyz.asm):03855         * optim: removeTfrDX
11ED E684             (          xyz.asm):03856                 LDB     ,X              get r-value
11EF 1D               (          xyz.asm):03857                 SEX                     promotion of binary operand
11F0 10A3E1           (          xyz.asm):03858                 CMPD    ,S++
11F3 260C             (          xyz.asm):03859                 BNE     L00425
                      (          xyz.asm):03860         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03861         * Useless label L00424 removed
                      (          xyz.asm):03862         * Line xyz.c:870: assignment: =
11F5 AE5A             (          xyz.asm):03863                 LDX     -6,U            left
11F7 EC5C             (          xyz.asm):03864                 LDD     -4,U            right
11F9 171C04           (          xyz.asm):03865                 LBSR    MUL16
11FC ED5E             (          xyz.asm):03866                 STD     -2,U
11FE 160139           (          xyz.asm):03867                 LBRA    L00426          jump over else clause
     1201             (          xyz.asm):03868         L00425  EQU     *               else
                      (          xyz.asm):03869         * Line xyz.c:871: if
1201 C62F             (          xyz.asm):03870                 LDB     #$2F            optim: lddToLDB
1203 1D               (          xyz.asm):03871                 SEX                     promotion of binary operand
1204 3406             (          xyz.asm):03872                 PSHS    B,A
                      (          xyz.asm):03873         * optim: optimizeLdx
1206 AED808           (          xyz.asm):03874                 LDX     [8,U]           optim: optimizeLdx
                      (          xyz.asm):03875         * optim: removeTfrDX
1209 E684             (          xyz.asm):03876                 LDB     ,X              get r-value
120B 1D               (          xyz.asm):03877                 SEX                     promotion of binary operand
120C 10A3E1           (          xyz.asm):03878                 CMPD    ,S++
120F 260C             (          xyz.asm):03879                 BNE     L00428
                      (          xyz.asm):03880         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03881         * Useless label L00427 removed
                      (          xyz.asm):03882         * Line xyz.c:871: assignment: =
1211 AE5A             (          xyz.asm):03883                 LDX     -6,U            left
1213 EC5C             (          xyz.asm):03884                 LDD     -4,U            right
1215 171C00           (          xyz.asm):03885                 LBSR    SDIV16
                      (          xyz.asm):03886         * optim: optimizeTfrOp
1218 AF5E             (          xyz.asm):03887                 STX     -2,U            optim: optimizeTfrOp
121A 16011D           (          xyz.asm):03888                 LBRA    L00429          jump over else clause
     121D             (          xyz.asm):03889         L00428  EQU     *               else
                      (          xyz.asm):03890         * Line xyz.c:872: if
121D C63E             (          xyz.asm):03891                 LDB     #$3E            optim: lddToLDB
121F 1D               (          xyz.asm):03892                 SEX                     promotion of binary operand
1220 3406             (          xyz.asm):03893                 PSHS    B,A
                      (          xyz.asm):03894         * optim: optimizeLdx
1222 AED808           (          xyz.asm):03895                 LDX     [8,U]           optim: optimizeLdx
                      (          xyz.asm):03896         * optim: removeTfrDX
1225 E684             (          xyz.asm):03897                 LDB     ,X              get r-value
1227 1D               (          xyz.asm):03898                 SEX                     promotion of binary operand
1228 10A3E1           (          xyz.asm):03899                 CMPD    ,S++
122B 2619             (          xyz.asm):03900                 BNE     L00431
                      (          xyz.asm):03901         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03902         * Useless label L00432 removed
                      (          xyz.asm):03903         * optim: optimizeLdx
122D AED808           (          xyz.asm):03904                 LDX     [8,U]           optim: optimizeLdx
                      (          xyz.asm):03905         * optim: removeTfrDX
                      (          xyz.asm):03906         * optim: optimizeLeax
1230 E601             (          xyz.asm):03907                 LDB     1,X             optim: optimizeLeax
                      (          xyz.asm):03908         * optim: loadCmpZeroBeqOrBne
1232 2612             (          xyz.asm):03909                 BNE     L00431
                      (          xyz.asm):03910         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03911         * Useless label L00430 removed
                      (          xyz.asm):03912         * Line xyz.c:872: assignment: =
1234 EC5A             (          xyz.asm):03913                 LDD     -6,U            variable a
1236 10A35C           (          xyz.asm):03914                 CMPD    -4,U            variable b
1239 2E03             (          xyz.asm):03915                 BGT     L00433          if true
123B 5F               (          xyz.asm):03916                 CLRB
123C 2002             (          xyz.asm):03917                 BRA     L00434          false
     123E             (          xyz.asm):03918         L00433  EQU     *
123E C601             (          xyz.asm):03919                 LDB     #1
     1240             (          xyz.asm):03920         L00434  EQU     *
1240 4F               (          xyz.asm):03921                 CLRA
1241 ED5E             (          xyz.asm):03922                 STD     -2,U
1243 1600F4           (          xyz.asm):03923                 LBRA    L00435          jump over else clause
     1246             (          xyz.asm):03924         L00431  EQU     *               else
                      (          xyz.asm):03925         * Line xyz.c:873: if
1246 C63E             (          xyz.asm):03926                 LDB     #$3E            optim: lddToLDB
1248 1D               (          xyz.asm):03927                 SEX                     promotion of binary operand
1249 3406             (          xyz.asm):03928                 PSHS    B,A
                      (          xyz.asm):03929         * optim: optimizeLdx
124B AED808           (          xyz.asm):03930                 LDX     [8,U]           optim: optimizeLdx
                      (          xyz.asm):03931         * optim: removeTfrDX
124E E684             (          xyz.asm):03932                 LDB     ,X              get r-value
1250 1D               (          xyz.asm):03933                 SEX                     promotion of binary operand
1251 10A3E1           (          xyz.asm):03934                 CMPD    ,S++
1254 2622             (          xyz.asm):03935                 BNE     L00437
                      (          xyz.asm):03936         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03937         * Useless label L00438 removed
1256 C63D             (          xyz.asm):03938                 LDB     #$3D            optim: lddToLDB
1258 1D               (          xyz.asm):03939                 SEX                     promotion of binary operand
1259 3406             (          xyz.asm):03940                 PSHS    B,A
                      (          xyz.asm):03941         * optim: optimizeLdx
125B AED808           (          xyz.asm):03942                 LDX     [8,U]           optim: optimizeLdx
                      (          xyz.asm):03943         * optim: removeTfrDX
                      (          xyz.asm):03944         * optim: optimizeLeax
125E E601             (          xyz.asm):03945                 LDB     1,X             optim: optimizeLeax
1260 1D               (          xyz.asm):03946                 SEX                     promotion of binary operand
1261 10A3E1           (          xyz.asm):03947                 CMPD    ,S++
1264 2612             (          xyz.asm):03948                 BNE     L00437
                      (          xyz.asm):03949         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03950         * Useless label L00436 removed
                      (          xyz.asm):03951         * Line xyz.c:873: assignment: =
1266 EC5A             (          xyz.asm):03952                 LDD     -6,U            variable a
1268 10A35C           (          xyz.asm):03953                 CMPD    -4,U            variable b
126B 2C03             (          xyz.asm):03954                 BGE     L00439          if true
126D 5F               (          xyz.asm):03955                 CLRB
126E 2002             (          xyz.asm):03956                 BRA     L00440          false
     1270             (          xyz.asm):03957         L00439  EQU     *
1270 C601             (          xyz.asm):03958                 LDB     #1
     1272             (          xyz.asm):03959         L00440  EQU     *
1272 4F               (          xyz.asm):03960                 CLRA
1273 ED5E             (          xyz.asm):03961                 STD     -2,U
1275 1600C2           (          xyz.asm):03962                 LBRA    L00441          jump over else clause
     1278             (          xyz.asm):03963         L00437  EQU     *               else
                      (          xyz.asm):03964         * Line xyz.c:874: if
1278 C63C             (          xyz.asm):03965                 LDB     #$3C            optim: lddToLDB
127A 1D               (          xyz.asm):03966                 SEX                     promotion of binary operand
127B 3406             (          xyz.asm):03967                 PSHS    B,A
                      (          xyz.asm):03968         * optim: optimizeLdx
127D AED808           (          xyz.asm):03969                 LDX     [8,U]           optim: optimizeLdx
                      (          xyz.asm):03970         * optim: removeTfrDX
1280 E684             (          xyz.asm):03971                 LDB     ,X              get r-value
1282 1D               (          xyz.asm):03972                 SEX                     promotion of binary operand
1283 10A3E1           (          xyz.asm):03973                 CMPD    ,S++
1286 2619             (          xyz.asm):03974                 BNE     L00443
                      (          xyz.asm):03975         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03976         * Useless label L00444 removed
                      (          xyz.asm):03977         * optim: optimizeLdx
1288 AED808           (          xyz.asm):03978                 LDX     [8,U]           optim: optimizeLdx
                      (          xyz.asm):03979         * optim: removeTfrDX
                      (          xyz.asm):03980         * optim: optimizeLeax
128B E601             (          xyz.asm):03981                 LDB     1,X             optim: optimizeLeax
                      (          xyz.asm):03982         * optim: loadCmpZeroBeqOrBne
128D 2612             (          xyz.asm):03983                 BNE     L00443
                      (          xyz.asm):03984         * optim: condBranchOverUncondBranch
                      (          xyz.asm):03985         * Useless label L00442 removed
                      (          xyz.asm):03986         * Line xyz.c:874: assignment: =
128F EC5A             (          xyz.asm):03987                 LDD     -6,U            variable a
1291 10A35C           (          xyz.asm):03988                 CMPD    -4,U            variable b
1294 2D03             (          xyz.asm):03989                 BLT     L00445          if true
1296 5F               (          xyz.asm):03990                 CLRB
1297 2002             (          xyz.asm):03991                 BRA     L00446          false
     1299             (          xyz.asm):03992         L00445  EQU     *
1299 C601             (          xyz.asm):03993                 LDB     #1
     129B             (          xyz.asm):03994         L00446  EQU     *
129B 4F               (          xyz.asm):03995                 CLRA
129C ED5E             (          xyz.asm):03996                 STD     -2,U
129E 160099           (          xyz.asm):03997                 LBRA    L00447          jump over else clause
     12A1             (          xyz.asm):03998         L00443  EQU     *               else
                      (          xyz.asm):03999         * Line xyz.c:875: if
12A1 C63C             (          xyz.asm):04000                 LDB     #$3C            optim: lddToLDB
12A3 1D               (          xyz.asm):04001                 SEX                     promotion of binary operand
12A4 3406             (          xyz.asm):04002                 PSHS    B,A
                      (          xyz.asm):04003         * optim: optimizeLdx
12A6 AED808           (          xyz.asm):04004                 LDX     [8,U]           optim: optimizeLdx
                      (          xyz.asm):04005         * optim: removeTfrDX
12A9 E684             (          xyz.asm):04006                 LDB     ,X              get r-value
12AB 1D               (          xyz.asm):04007                 SEX                     promotion of binary operand
12AC 10A3E1           (          xyz.asm):04008                 CMPD    ,S++
12AF 2622             (          xyz.asm):04009                 BNE     L00449
                      (          xyz.asm):04010         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04011         * Useless label L00450 removed
12B1 C63D             (          xyz.asm):04012                 LDB     #$3D            optim: lddToLDB
12B3 1D               (          xyz.asm):04013                 SEX                     promotion of binary operand
12B4 3406             (          xyz.asm):04014                 PSHS    B,A
                      (          xyz.asm):04015         * optim: optimizeLdx
12B6 AED808           (          xyz.asm):04016                 LDX     [8,U]           optim: optimizeLdx
                      (          xyz.asm):04017         * optim: removeTfrDX
                      (          xyz.asm):04018         * optim: optimizeLeax
12B9 E601             (          xyz.asm):04019                 LDB     1,X             optim: optimizeLeax
12BB 1D               (          xyz.asm):04020                 SEX                     promotion of binary operand
12BC 10A3E1           (          xyz.asm):04021                 CMPD    ,S++
12BF 2612             (          xyz.asm):04022                 BNE     L00449
                      (          xyz.asm):04023         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04024         * Useless label L00448 removed
                      (          xyz.asm):04025         * Line xyz.c:875: assignment: =
12C1 EC5A             (          xyz.asm):04026                 LDD     -6,U            variable a
12C3 10A35C           (          xyz.asm):04027                 CMPD    -4,U            variable b
12C6 2F03             (          xyz.asm):04028                 BLE     L00451          if true
12C8 5F               (          xyz.asm):04029                 CLRB
12C9 2002             (          xyz.asm):04030                 BRA     L00452          false
     12CB             (          xyz.asm):04031         L00451  EQU     *
12CB C601             (          xyz.asm):04032                 LDB     #1
     12CD             (          xyz.asm):04033         L00452  EQU     *
12CD 4F               (          xyz.asm):04034                 CLRA
12CE ED5E             (          xyz.asm):04035                 STD     -2,U
12D0 160067           (          xyz.asm):04036                 LBRA    L00453          jump over else clause
     12D3             (          xyz.asm):04037         L00449  EQU     *               else
                      (          xyz.asm):04038         * Line xyz.c:876: if
12D3 C63D             (          xyz.asm):04039                 LDB     #$3D            optim: lddToLDB
12D5 1D               (          xyz.asm):04040                 SEX                     promotion of binary operand
12D6 3406             (          xyz.asm):04041                 PSHS    B,A
                      (          xyz.asm):04042         * optim: optimizeLdx
12D8 AED808           (          xyz.asm):04043                 LDX     [8,U]           optim: optimizeLdx
                      (          xyz.asm):04044         * optim: removeTfrDX
12DB E684             (          xyz.asm):04045                 LDB     ,X              get r-value
12DD 1D               (          xyz.asm):04046                 SEX                     promotion of binary operand
12DE 10A3E1           (          xyz.asm):04047                 CMPD    ,S++
12E1 2622             (          xyz.asm):04048                 BNE     L00455
                      (          xyz.asm):04049         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04050         * Useless label L00456 removed
12E3 C63D             (          xyz.asm):04051                 LDB     #$3D            optim: lddToLDB
12E5 1D               (          xyz.asm):04052                 SEX                     promotion of binary operand
12E6 3406             (          xyz.asm):04053                 PSHS    B,A
                      (          xyz.asm):04054         * optim: optimizeLdx
12E8 AED808           (          xyz.asm):04055                 LDX     [8,U]           optim: optimizeLdx
                      (          xyz.asm):04056         * optim: removeTfrDX
                      (          xyz.asm):04057         * optim: optimizeLeax
12EB E601             (          xyz.asm):04058                 LDB     1,X             optim: optimizeLeax
12ED 1D               (          xyz.asm):04059                 SEX                     promotion of binary operand
12EE 10A3E1           (          xyz.asm):04060                 CMPD    ,S++
12F1 2612             (          xyz.asm):04061                 BNE     L00455
                      (          xyz.asm):04062         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04063         * Useless label L00454 removed
                      (          xyz.asm):04064         * Line xyz.c:876: assignment: =
12F3 EC5A             (          xyz.asm):04065                 LDD     -6,U            variable a
12F5 10A35C           (          xyz.asm):04066                 CMPD    -4,U            variable b
12F8 2703             (          xyz.asm):04067                 BEQ     L00457          if true
12FA 5F               (          xyz.asm):04068                 CLRB
12FB 2002             (          xyz.asm):04069                 BRA     L00458          false
     12FD             (          xyz.asm):04070         L00457  EQU     *
12FD C601             (          xyz.asm):04071                 LDB     #1
     12FF             (          xyz.asm):04072         L00458  EQU     *
12FF 4F               (          xyz.asm):04073                 CLRA
1300 ED5E             (          xyz.asm):04074                 STD     -2,U
1302 160035           (          xyz.asm):04075                 LBRA    L00459          jump over else clause
     1305             (          xyz.asm):04076         L00455  EQU     *               else
                      (          xyz.asm):04077         * Line xyz.c:877: if
1305 C621             (          xyz.asm):04078                 LDB     #$21            optim: lddToLDB
1307 1D               (          xyz.asm):04079                 SEX                     promotion of binary operand
1308 3406             (          xyz.asm):04080                 PSHS    B,A
                      (          xyz.asm):04081         * optim: optimizeLdx
130A AED808           (          xyz.asm):04082                 LDX     [8,U]           optim: optimizeLdx
                      (          xyz.asm):04083         * optim: removeTfrDX
130D E684             (          xyz.asm):04084                 LDB     ,X              get r-value
130F 1D               (          xyz.asm):04085                 SEX                     promotion of binary operand
1310 10A3E1           (          xyz.asm):04086                 CMPD    ,S++
1313 2621             (          xyz.asm):04087                 BNE     L00461
                      (          xyz.asm):04088         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04089         * Useless label L00462 removed
1315 C63D             (          xyz.asm):04090                 LDB     #$3D            optim: lddToLDB
1317 1D               (          xyz.asm):04091                 SEX                     promotion of binary operand
1318 3406             (          xyz.asm):04092                 PSHS    B,A
                      (          xyz.asm):04093         * optim: optimizeLdx
131A AED808           (          xyz.asm):04094                 LDX     [8,U]           optim: optimizeLdx
                      (          xyz.asm):04095         * optim: removeTfrDX
                      (          xyz.asm):04096         * optim: optimizeLeax
131D E601             (          xyz.asm):04097                 LDB     1,X             optim: optimizeLeax
131F 1D               (          xyz.asm):04098                 SEX                     promotion of binary operand
1320 10A3E1           (          xyz.asm):04099                 CMPD    ,S++
1323 2611             (          xyz.asm):04100                 BNE     L00461
                      (          xyz.asm):04101         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04102         * Useless label L00460 removed
                      (          xyz.asm):04103         * Line xyz.c:877: assignment: =
1325 EC5A             (          xyz.asm):04104                 LDD     -6,U            variable a
1327 10A35C           (          xyz.asm):04105                 CMPD    -4,U            variable b
132A 2603             (          xyz.asm):04106                 BNE     L00463          if true
132C 5F               (          xyz.asm):04107                 CLRB
132D 2002             (          xyz.asm):04108                 BRA     L00464          false
     132F             (          xyz.asm):04109         L00463  EQU     *
132F C601             (          xyz.asm):04110                 LDB     #1
     1331             (          xyz.asm):04111         L00464  EQU     *
1331 4F               (          xyz.asm):04112                 CLRA
1332 ED5E             (          xyz.asm):04113                 STD     -2,U
1334 2004             (          xyz.asm):04114                 BRA     L00465          jump over else clause
     1336             (          xyz.asm):04115         L00461  EQU     *               else
                      (          xyz.asm):04116         * Line xyz.c:878: assignment: =
1336 4F               (          xyz.asm):04117                 CLRA
1337 5F               (          xyz.asm):04118                 CLRB
1338 ED5E             (          xyz.asm):04119                 STD     -2,U
     133A             (          xyz.asm):04120         L00465  EQU     *               end if
     133A             (          xyz.asm):04121         L00459  EQU     *               end if
     133A             (          xyz.asm):04122         L00453  EQU     *               end if
     133A             (          xyz.asm):04123         L00447  EQU     *               end if
     133A             (          xyz.asm):04124         L00441  EQU     *               end if
     133A             (          xyz.asm):04125         L00435  EQU     *               end if
     133A             (          xyz.asm):04126         L00429  EQU     *               end if
     133A             (          xyz.asm):04127         L00426  EQU     *               end if
     133A             (          xyz.asm):04128         L00423  EQU     *               end if
     133A             (          xyz.asm):04129         L00420  EQU     *               end if
                      (          xyz.asm):04130         * Line xyz.c:879: function call: snprintf_d()
133A EC5E             (          xyz.asm):04131                 LDD     -2,U            variable c, declared at xyz.c:865
133C 3406             (          xyz.asm):04132                 PSHS    B,A             argument 4 of snprintf_d(): int
133E 308D196B         (          xyz.asm):04133                 LEAX    S00100,PCR      "%d"
                      (          xyz.asm):04134         * optim: optimizePshsOps
1342 4F               (          xyz.asm):04135                 CLRA
1343 C608             (          xyz.asm):04136                 LDB     #$08            decimal 8 signed
1345 3416             (          xyz.asm):04137                 PSHS    X,B,A           optim: optimizePshsOps
1347 3052             (          xyz.asm):04138                 LEAX    -14,U           address of array buf
1349 3410             (          xyz.asm):04139                 PSHS    X               argument 1 of snprintf_d(): char[]
134B 171566           (          xyz.asm):04140                 LBSR    _snprintf_d
134E 3268             (          xyz.asm):04141                 LEAS    8,S
                      (          xyz.asm):04142         * Line xyz.c:880: function call: picolSetResult()
1350 3052             (          xyz.asm):04143                 LEAX    -14,U           address of array buf
                      (          xyz.asm):04144         * optim: optimizePshsOps
1352 EC44             (          xyz.asm):04145                 LDD     4,U             variable i, declared at xyz.c:864
1354 3416             (          xyz.asm):04146                 PSHS    X,B,A           optim: optimizePshsOps
1356 171362           (          xyz.asm):04147                 LBSR    _picolSetResult
1359 3264             (          xyz.asm):04148                 LEAS    4,S
                      (          xyz.asm):04149         * Line xyz.c:881: return with value
135B 4F               (          xyz.asm):04150                 CLRA
135C 5F               (          xyz.asm):04151                 CLRB
                      (          xyz.asm):04152         * optim: branchToNextLocation
     135D             (          xyz.asm):04153         L00052  EQU     *               end of picolCommandMath()
135D 32C4             (          xyz.asm):04154                 LEAS    ,U
135F 35C0             (          xyz.asm):04155                 PULS    U,PC
                      (          xyz.asm):04156         * END FUNCTION picolCommandMath(): defined at xyz.c:864
     1361             (          xyz.asm):04157         funcend_picolCommandMath        EQU *
     01F1             (          xyz.asm):04158         funcsize_picolCommandMath       EQU     funcend_picolCommandMath-_picolCommandMath
                      (          xyz.asm):04159         
                      (          xyz.asm):04160         
                      (          xyz.asm):04161         *******************************************************************************
                      (          xyz.asm):04162         
                      (          xyz.asm):04163         * FUNCTION picolCommandProc(): defined at xyz.c:1004
     1361             (          xyz.asm):04164         _picolCommandProc       EQU     *
1361 3440             (          xyz.asm):04165                 PSHS    U
1363 1716E6           (          xyz.asm):04166                 LBSR    _stkcheck
1366 FFBE             (          xyz.asm):04167                 FDB     -66             argument for _stkcheck
1368 33E4             (          xyz.asm):04168                 LEAU    ,S
136A 327E             (          xyz.asm):04169                 LEAS    -2,S
                      (          xyz.asm):04170         * Formal parameters and locals:
                      (          xyz.asm):04171         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):04172         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):04173         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):04174         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):04175         *   procdata: char **; 2 bytes at -2,U
                      (          xyz.asm):04176         * Line xyz.c:1005: init of variable procdata
                      (          xyz.asm):04177         * Line xyz.c:1005: function call: malloc()
136C 4F               (          xyz.asm):04178                 CLRA
136D C604             (          xyz.asm):04179                 LDB     #$04            constant expression: 4 decimal, unsigned
136F 3406             (          xyz.asm):04180                 PSHS    B,A             argument 1 of malloc(): unsigned int
1371 17F4D6           (          xyz.asm):04181                 LBSR    _malloc
1374 3262             (          xyz.asm):04182                 LEAS    2,S
1376 ED5E             (          xyz.asm):04183                 STD     -2,U            variable procdata
                      (          xyz.asm):04184         * Line xyz.c:1006: if
1378 EC46             (          xyz.asm):04185                 LDD     6,U             variable argc
137A 10830004         (          xyz.asm):04186                 CMPD    #$04
137E 2711             (          xyz.asm):04187                 BEQ     L00467
                      (          xyz.asm):04188         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04189         * Useless label L00466 removed
                      (          xyz.asm):04190         * Line xyz.c:1006: return with value
                      (          xyz.asm):04191         * Line xyz.c:1006: function call: picolArityErr()
1380 AE48             (          xyz.asm):04192                 LDX     8,U             get pointer value
1382 EC84             (          xyz.asm):04193                 LDD     ,X
1384 3406             (          xyz.asm):04194                 PSHS    B,A             argument 2 of picolArityErr(): char *
1386 EC44             (          xyz.asm):04195                 LDD     4,U             variable i, declared at xyz.c:1004
1388 3406             (          xyz.asm):04196                 PSHS    B,A             argument 1 of picolArityErr(): struct picolInterp *
138A 17F67F           (          xyz.asm):04197                 LBSR    _picolArityErr
138D 3264             (          xyz.asm):04198                 LEAS    4,S
138F 203C             (          xyz.asm):04199                 BRA     L00061          return (xyz.c:1006)
     1391             (          xyz.asm):04200         L00467  EQU     *               else
                      (          xyz.asm):04201         * Useless label L00468 removed
                      (          xyz.asm):04202         * Line xyz.c:1007: assignment: =
                      (          xyz.asm):04203         * Line xyz.c:1007: function call: strdup()
1391 AE48             (          xyz.asm):04204                 LDX     8,U             get pointer value
1393 3004             (          xyz.asm):04205                 LEAX    4,X             add index (2) multiplied by pointed object size (2)
1395 EC84             (          xyz.asm):04206                 LDD     ,X
1397 3406             (          xyz.asm):04207                 PSHS    B,A             argument 1 of strdup(): char *
1399 1717AE           (          xyz.asm):04208                 LBSR    _strdup
139C 3262             (          xyz.asm):04209                 LEAS    2,S
                      (          xyz.asm):04210         * optim: stripUselessPushPull
                      (          xyz.asm):04211         * optim: optimizeLdx
                      (          xyz.asm):04212         * optim: stripUselessPushPull
139E EDD8FE           (          xyz.asm):04213                 STD     [-2,U]          optim: optimizeLdx
                      (          xyz.asm):04214         * Line xyz.c:1008: assignment: =
                      (          xyz.asm):04215         * Line xyz.c:1008: function call: strdup()
13A1 AE48             (          xyz.asm):04216                 LDX     8,U             get pointer value
13A3 3006             (          xyz.asm):04217                 LEAX    6,X             add index (3) multiplied by pointed object size (2)
13A5 EC84             (          xyz.asm):04218                 LDD     ,X
13A7 3406             (          xyz.asm):04219                 PSHS    B,A             argument 1 of strdup(): char *
13A9 17179E           (          xyz.asm):04220                 LBSR    _strdup
13AC 3262             (          xyz.asm):04221                 LEAS    2,S
                      (          xyz.asm):04222         * optim: stripUselessPushPull
13AE AE5E             (          xyz.asm):04223                 LDX     -2,U            get pointer value
                      (          xyz.asm):04224         * optim: optimizeLeax
                      (          xyz.asm):04225         * optim: stripUselessPushPull
13B0 ED02             (          xyz.asm):04226                 STD     2,X             optim: optimizeLeax
                      (          xyz.asm):04227         * Line xyz.c:1009: return with value
                      (          xyz.asm):04228         * Line xyz.c:1009: function call: picolRegisterCommand()
13B2 EC5E             (          xyz.asm):04229                 LDD     -2,U            variable procdata, declared at xyz.c:1005
13B4 3406             (          xyz.asm):04230                 PSHS    B,A             argument 4 of picolRegisterCommand(): char **
13B6 308DF68B         (          xyz.asm):04231                 LEAX    _picolCommandCallProc,PCR       address of picolCommandCallProc(), defined at xyz.c:969
13BA 3410             (          xyz.asm):04232                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):04233         * optim: optimizeTfrPush
13BC AE48             (          xyz.asm):04234                 LDX     8,U             get pointer value
13BE 3002             (          xyz.asm):04235                 LEAX    2,X             add index (1) multiplied by pointed object size (2)
13C0 EC84             (          xyz.asm):04236                 LDD     ,X
13C2 3406             (          xyz.asm):04237                 PSHS    B,A             argument 2 of picolRegisterCommand(): char *
13C4 EC44             (          xyz.asm):04238                 LDD     4,U             variable i, declared at xyz.c:1004
13C6 3406             (          xyz.asm):04239                 PSHS    B,A             argument 1 of picolRegisterCommand(): struct picolInterp *
13C8 17103A           (          xyz.asm):04240                 LBSR    _picolRegisterCommand
13CB 3268             (          xyz.asm):04241                 LEAS    8,S
                      (          xyz.asm):04242         * optim: branchToNextLocation
     13CD             (          xyz.asm):04243         L00061  EQU     *               end of picolCommandProc()
13CD 32C4             (          xyz.asm):04244                 LEAS    ,U
13CF 35C0             (          xyz.asm):04245                 PULS    U,PC
                      (          xyz.asm):04246         * END FUNCTION picolCommandProc(): defined at xyz.c:1004
     13D1             (          xyz.asm):04247         funcend_picolCommandProc        EQU *
     0070             (          xyz.asm):04248         funcsize_picolCommandProc       EQU     funcend_picolCommandProc-_picolCommandProc
                      (          xyz.asm):04249         
                      (          xyz.asm):04250         
                      (          xyz.asm):04251         *******************************************************************************
                      (          xyz.asm):04252         
                      (          xyz.asm):04253         * FUNCTION picolCommandPuts(): defined at xyz.c:902
     13D1             (          xyz.asm):04254         _picolCommandPuts       EQU     *
13D1 3440             (          xyz.asm):04255                 PSHS    U
13D3 171676           (          xyz.asm):04256                 LBSR    _stkcheck
13D6 FFB7             (          xyz.asm):04257                 FDB     -73             argument for _stkcheck
13D8 33E4             (          xyz.asm):04258                 LEAU    ,S
13DA 3277             (          xyz.asm):04259                 LEAS    -9,S
                      (          xyz.asm):04260         * Formal parameters and locals:
                      (          xyz.asm):04261         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):04262         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):04263         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):04264         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):04265         *   argv0: char *; 2 bytes at -9,U
                      (          xyz.asm):04266         *   nonewline: unsigned char; 1 byte at -7,U
                      (          xyz.asm):04267         *   path: int; 2 bytes at -6,U
                      (          xyz.asm):04268         *   unused: int; 2 bytes at -4,U
                      (          xyz.asm):04269         *   e: int; 2 bytes at -2,U
                      (          xyz.asm):04270         * Line xyz.c:903: init of variable argv0
                      (          xyz.asm):04271         * optim: optimizeIndexedX
13DC ECD808           (          xyz.asm):04272                 LDD     [8,U]           optim: optimizeIndexedX
13DF ED57             (          xyz.asm):04273                 STD     -9,U            variable argv0
                      (          xyz.asm):04274         * Line xyz.c:904: init of variable nonewline
13E1 6F59             (          xyz.asm):04275                 CLR     -7,U            variable nonewline
                      (          xyz.asm):04276         * Line xyz.c:906: if
13E3 EC46             (          xyz.asm):04277                 LDD     6,U             variable argc
13E5 10830002         (          xyz.asm):04278                 CMPD    #$02
13E9 2F27             (          xyz.asm):04279                 BLE     L00470
                      (          xyz.asm):04280         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04281         * Useless label L00471 removed
13EB C62D             (          xyz.asm):04282                 LDB     #$2D            optim: lddToLDB
13ED 1D               (          xyz.asm):04283                 SEX                     promotion of binary operand
13EE 3406             (          xyz.asm):04284                 PSHS    B,A
13F0 AE48             (          xyz.asm):04285                 LDX     8,U             get pointer value
                      (          xyz.asm):04286         * optim: optimizeLeaxLdx
                      (          xyz.asm):04287         * optim: optimizeLdx
                      (          xyz.asm):04288         * optim: removeTfrDX
13F2 E69802           (          xyz.asm):04289                 LDB     [2,X]           optim: optimizeLdx
13F5 1D               (          xyz.asm):04290                 SEX                     promotion of binary operand
13F6 10A3E1           (          xyz.asm):04291                 CMPD    ,S++
13F9 2617             (          xyz.asm):04292                 BNE     L00470
                      (          xyz.asm):04293         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04294         * Useless label L00469 removed
                      (          xyz.asm):04295         * Line xyz.c:907: assignment: =
13FB 4F               (          xyz.asm):04296                 CLRA
13FC C601             (          xyz.asm):04297                 LDB     #$01            decimal 1 signed
13FE E759             (          xyz.asm):04298                 STB     -7,U
1400 3046             (          xyz.asm):04299                 LEAX    6,U             variable argc, declared at xyz.c:902
1402 EC84             (          xyz.asm):04300                 LDD     ,X
1404 830001           (          xyz.asm):04301                 SUBD    #1
1407 ED84             (          xyz.asm):04302                 STD     ,X
                      (          xyz.asm):04303         * optim: removeUselessOps
1409 3048             (          xyz.asm):04304                 LEAX    8,U             variable argv, declared at xyz.c:902
140B EC84             (          xyz.asm):04305                 LDD     ,X
140D C30002           (          xyz.asm):04306                 ADDD    #2
1410 ED84             (          xyz.asm):04307                 STD     ,X
                      (          xyz.asm):04308         * optim: removeUselessOps
     1412             (          xyz.asm):04309         L00470  EQU     *               else
                      (          xyz.asm):04310         * Useless label L00472 removed
                      (          xyz.asm):04311         * Line xyz.c:910: if
1412 EC46             (          xyz.asm):04312                 LDD     6,U             variable argc
1414 10830002         (          xyz.asm):04313                 CMPD    #$02
1418 2718             (          xyz.asm):04314                 BEQ     L00474
                      (          xyz.asm):04315         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04316         * Useless label L00475 removed
141A EC46             (          xyz.asm):04317                 LDD     6,U             variable argc
141C 10830003         (          xyz.asm):04318                 CMPD    #$03
1420 2710             (          xyz.asm):04319                 BEQ     L00474
                      (          xyz.asm):04320         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04321         * Useless label L00473 removed
                      (          xyz.asm):04322         * Line xyz.c:910: return with value
                      (          xyz.asm):04323         * Line xyz.c:910: function call: picolArityErr()
1422 EC57             (          xyz.asm):04324                 LDD     -9,U            variable argv0, declared at xyz.c:903
1424 3406             (          xyz.asm):04325                 PSHS    B,A             argument 2 of picolArityErr(): char *
1426 EC44             (          xyz.asm):04326                 LDD     4,U             variable i, declared at xyz.c:902
1428 3406             (          xyz.asm):04327                 PSHS    B,A             argument 1 of picolArityErr(): struct picolInterp *
142A 17F5DF           (          xyz.asm):04328                 LBSR    _picolArityErr
142D 3264             (          xyz.asm):04329                 LEAS    4,S
142F 1600A4           (          xyz.asm):04330                 LBRA    L00054          return (xyz.c:910)
     1432             (          xyz.asm):04331         L00474  EQU     *               else
                      (          xyz.asm):04332         * Useless label L00476 removed
                      (          xyz.asm):04333         * Line xyz.c:912: init of variable path
1432 EC46             (          xyz.asm):04334                 LDD     6,U             variable argc
1434 10830003         (          xyz.asm):04335                 CMPD    #$03
1438 2703             (          xyz.asm):04336                 BEQ     L00477          if true
143A 5F               (          xyz.asm):04337                 CLRB
143B 2002             (          xyz.asm):04338                 BRA     L00478          false
     143D             (          xyz.asm):04339         L00477  EQU     *
143D C601             (          xyz.asm):04340                 LDB     #1
     143F             (          xyz.asm):04341         L00478  EQU     *
143F 5D               (          xyz.asm):04342                 TSTB
1440 270F             (          xyz.asm):04343                 BEQ     L00479          if conditional expression is false
                      (          xyz.asm):04344         * Line xyz.c:912: function call: atoi()
1442 AE48             (          xyz.asm):04345                 LDX     8,U             get pointer value
1444 3002             (          xyz.asm):04346                 LEAX    2,X             add index (1) multiplied by pointed object size (2)
1446 EC84             (          xyz.asm):04347                 LDD     ,X
1448 3406             (          xyz.asm):04348                 PSHS    B,A             argument 1 of atoi(): char *
144A 17EFE2           (          xyz.asm):04349                 LBSR    _atoi
144D 3262             (          xyz.asm):04350                 LEAS    2,S
144F 2003             (          xyz.asm):04351                 BRA     L00480          end of true expression of conditional
     1451             (          xyz.asm):04352         L00479  EQU     *
1451 4F               (          xyz.asm):04353                 CLRA
1452 C601             (          xyz.asm):04354                 LDB     #$01            decimal 1 signed
     1454             (          xyz.asm):04355         L00480  EQU     *
1454 ED5A             (          xyz.asm):04356                 STD     -6,U            variable path
                      (          xyz.asm):04357         * Line xyz.c:914: init of variable e
                      (          xyz.asm):04358         * Line xyz.c:914: function call: Os9WritLn()
1456 305C             (          xyz.asm):04359                 LEAX    -4,U            variable unused, declared at xyz.c:913
1458 3410             (          xyz.asm):04360                 PSHS    X               argument 4 of Os9WritLn(): int *
                      (          xyz.asm):04361         * Line xyz.c:914: function call: strlen()
145A AE48             (          xyz.asm):04362                 LDX     8,U             pointer argv
                      (          xyz.asm):04363         * optim: stripExtraPulsX
145C EC46             (          xyz.asm):04364                 LDD     6,U             variable argc
145E C3FFFF           (          xyz.asm):04365                 ADDD    #$FFFF          65535
1461 58               (          xyz.asm):04366                 LSLB
1462 49               (          xyz.asm):04367                 ROLA
                      (          xyz.asm):04368         * optim: stripExtraPulsX
1463 308B             (          xyz.asm):04369                 LEAX    D,X             add byte offset
1465 EC84             (          xyz.asm):04370                 LDD     ,X              get r-value
1467 3406             (          xyz.asm):04371                 PSHS    B,A             argument 1 of strlen(): char *
1469 171713           (          xyz.asm):04372                 LBSR    _strlen
146C 3262             (          xyz.asm):04373                 LEAS    2,S
146E 3406             (          xyz.asm):04374                 PSHS    B,A             argument 3 of Os9WritLn(): int
1470 AE48             (          xyz.asm):04375                 LDX     8,U             pointer argv
                      (          xyz.asm):04376         * optim: stripExtraPulsX
1472 EC46             (          xyz.asm):04377                 LDD     6,U             variable argc
1474 C3FFFF           (          xyz.asm):04378                 ADDD    #$FFFF          65535
1477 58               (          xyz.asm):04379                 LSLB
1478 49               (          xyz.asm):04380                 ROLA
                      (          xyz.asm):04381         * optim: stripExtraPulsX
1479 308B             (          xyz.asm):04382                 LEAX    D,X             add byte offset
147B EC84             (          xyz.asm):04383                 LDD     ,X              get r-value
147D 3406             (          xyz.asm):04384                 PSHS    B,A             argument 2 of Os9WritLn(): char *
147F EC5A             (          xyz.asm):04385                 LDD     -6,U            variable path, declared at xyz.c:912
1481 3406             (          xyz.asm):04386                 PSHS    B,A             argument 1 of Os9WritLn(): int
1483 17EDBE           (          xyz.asm):04387                 LBSR    _Os9WritLn
1486 3268             (          xyz.asm):04388                 LEAS    8,S
1488 ED5E             (          xyz.asm):04389                 STD     -2,U            variable e
                      (          xyz.asm):04390         * Line xyz.c:915: if
                      (          xyz.asm):04391         * optim: storeLoad
148A C30000           (          xyz.asm):04392                 ADDD    #0
148D 2713             (          xyz.asm):04393                 BEQ     L00482
                      (          xyz.asm):04394         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04395         * Useless label L00481 removed
                      (          xyz.asm):04396         * Line xyz.c:915: return with value
                      (          xyz.asm):04397         * Line xyz.c:915: function call: Error()
148F EC5E             (          xyz.asm):04398                 LDD     -2,U            variable e, declared at xyz.c:914
1491 3406             (          xyz.asm):04399                 PSHS    B,A             argument 3 of Error(): int
1493 EC57             (          xyz.asm):04400                 LDD     -9,U            variable argv0, declared at xyz.c:903
1495 3406             (          xyz.asm):04401                 PSHS    B,A             argument 2 of Error(): char *
1497 EC44             (          xyz.asm):04402                 LDD     4,U             variable i, declared at xyz.c:902
1499 3406             (          xyz.asm):04403                 PSHS    B,A             argument 1 of Error(): struct picolInterp *
149B 17EC0A           (          xyz.asm):04404                 LBSR    _Error
149E 3266             (          xyz.asm):04405                 LEAS    6,S
14A0 2034             (          xyz.asm):04406                 BRA     L00054          return (xyz.c:915)
     14A2             (          xyz.asm):04407         L00482  EQU     *               else
                      (          xyz.asm):04408         * Useless label L00483 removed
                      (          xyz.asm):04409         * Line xyz.c:916: if
14A2 E659             (          xyz.asm):04410                 LDB     -7,U            variable nonewline, declared at xyz.c:904
                      (          xyz.asm):04411         * optim: loadCmpZeroBeqOrBne
14A4 262E             (          xyz.asm):04412                 BNE     L00485
                      (          xyz.asm):04413         * optim: branchToNextLocation
                      (          xyz.asm):04414         * Useless label L00484 removed
                      (          xyz.asm):04415         * Line xyz.c:917: assignment: =
                      (          xyz.asm):04416         * Line xyz.c:917: function call: Os9WritLn()
14A6 305C             (          xyz.asm):04417                 LEAX    -4,U            variable unused, declared at xyz.c:913
                      (          xyz.asm):04418         * optim: optimizePshsOps
14A8 4F               (          xyz.asm):04419                 CLRA
14A9 C601             (          xyz.asm):04420                 LDB     #$01            decimal 1 signed
14AB 3416             (          xyz.asm):04421                 PSHS    X,B,A           optim: optimizePshsOps
14AD 308D180B         (          xyz.asm):04422                 LEAX    S00102,PCR      "\r"
                      (          xyz.asm):04423         * optim: optimizePshsOps
14B1 EC5A             (          xyz.asm):04424                 LDD     -6,U            variable path, declared at xyz.c:912
14B3 3416             (          xyz.asm):04425                 PSHS    X,B,A           optim: optimizePshsOps
14B5 17ED8C           (          xyz.asm):04426                 LBSR    _Os9WritLn
14B8 3268             (          xyz.asm):04427                 LEAS    8,S
14BA ED5E             (          xyz.asm):04428                 STD     -2,U
                      (          xyz.asm):04429         * Line xyz.c:918: if
                      (          xyz.asm):04430         * optim: storeLoad
14BC C30000           (          xyz.asm):04431                 ADDD    #0
14BF 2713             (          xyz.asm):04432                 BEQ     L00487
                      (          xyz.asm):04433         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04434         * Useless label L00486 removed
                      (          xyz.asm):04435         * Line xyz.c:918: return with value
                      (          xyz.asm):04436         * Line xyz.c:918: function call: Error()
14C1 EC5E             (          xyz.asm):04437                 LDD     -2,U            variable e, declared at xyz.c:914
14C3 3406             (          xyz.asm):04438                 PSHS    B,A             argument 3 of Error(): int
14C5 EC57             (          xyz.asm):04439                 LDD     -9,U            variable argv0, declared at xyz.c:903
14C7 3406             (          xyz.asm):04440                 PSHS    B,A             argument 2 of Error(): char *
14C9 EC44             (          xyz.asm):04441                 LDD     4,U             variable i, declared at xyz.c:902
14CB 3406             (          xyz.asm):04442                 PSHS    B,A             argument 1 of Error(): struct picolInterp *
14CD 17EBD8           (          xyz.asm):04443                 LBSR    _Error
14D0 3266             (          xyz.asm):04444                 LEAS    6,S
14D2 2002             (          xyz.asm):04445                 BRA     L00054          return (xyz.c:918)
     14D4             (          xyz.asm):04446         L00487  EQU     *               else
                      (          xyz.asm):04447         * Useless label L00488 removed
     14D4             (          xyz.asm):04448         L00485  EQU     *               else
                      (          xyz.asm):04449         * Useless label L00489 removed
                      (          xyz.asm):04450         * Line xyz.c:920: return with value
14D4 4F               (          xyz.asm):04451                 CLRA
14D5 5F               (          xyz.asm):04452                 CLRB
                      (          xyz.asm):04453         * optim: branchToNextLocation
     14D6             (          xyz.asm):04454         L00054  EQU     *               end of picolCommandPuts()
14D6 32C4             (          xyz.asm):04455                 LEAS    ,U
14D8 35C0             (          xyz.asm):04456                 PULS    U,PC
                      (          xyz.asm):04457         * END FUNCTION picolCommandPuts(): defined at xyz.c:902
     14DA             (          xyz.asm):04458         funcend_picolCommandPuts        EQU *
     0109             (          xyz.asm):04459         funcsize_picolCommandPuts       EQU     funcend_picolCommandPuts-_picolCommandPuts
                      (          xyz.asm):04460         
                      (          xyz.asm):04461         
                      (          xyz.asm):04462         *******************************************************************************
                      (          xyz.asm):04463         
                      (          xyz.asm):04464         * FUNCTION picolCommandRetCodes(): defined at xyz.c:948
     14DA             (          xyz.asm):04465         _picolCommandRetCodes   EQU     *
14DA 3440             (          xyz.asm):04466                 PSHS    U
14DC 17156D           (          xyz.asm):04467                 LBSR    _stkcheck
14DF FFC0             (          xyz.asm):04468                 FDB     -64             argument for _stkcheck
14E1 33E4             (          xyz.asm):04469                 LEAU    ,S
                      (          xyz.asm):04470         * Formal parameters and locals:
                      (          xyz.asm):04471         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):04472         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):04473         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):04474         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):04475         * Line xyz.c:949: if
14E3 EC46             (          xyz.asm):04476                 LDD     6,U             variable argc
14E5 10830001         (          xyz.asm):04477                 CMPD    #$01
14E9 2711             (          xyz.asm):04478                 BEQ     L00491
                      (          xyz.asm):04479         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04480         * Useless label L00490 removed
                      (          xyz.asm):04481         * Line xyz.c:949: return with value
                      (          xyz.asm):04482         * Line xyz.c:949: function call: picolArityErr()
14EB AE48             (          xyz.asm):04483                 LDX     8,U             get pointer value
14ED EC84             (          xyz.asm):04484                 LDD     ,X
14EF 3406             (          xyz.asm):04485                 PSHS    B,A             argument 2 of picolArityErr(): char *
14F1 EC44             (          xyz.asm):04486                 LDD     4,U             variable i, declared at xyz.c:948
14F3 3406             (          xyz.asm):04487                 PSHS    B,A             argument 1 of picolArityErr(): struct picolInterp *
14F5 17F514           (          xyz.asm):04488                 LBSR    _picolArityErr
14F8 3264             (          xyz.asm):04489                 LEAS    4,S
14FA 2038             (          xyz.asm):04490                 BRA     L00057          return (xyz.c:949)
     14FC             (          xyz.asm):04491         L00491  EQU     *               else
                      (          xyz.asm):04492         * Useless label L00492 removed
                      (          xyz.asm):04493         * Line xyz.c:950: if
                      (          xyz.asm):04494         * Line xyz.c:950: function call: strcasecmp()
14FC 308D17BE         (          xyz.asm):04495                 LEAX    S00103,PCR      "break"
1500 3410             (          xyz.asm):04496                 PSHS    X               argument 2 of strcasecmp(): const char[]
1502 AE48             (          xyz.asm):04497                 LDX     8,U             get pointer value
1504 EC84             (          xyz.asm):04498                 LDD     ,X
1506 3406             (          xyz.asm):04499                 PSHS    B,A             argument 1 of strcasecmp(): char *
1508 17154C           (          xyz.asm):04500                 LBSR    _strcasecmp
150B 3264             (          xyz.asm):04501                 LEAS    4,S
150D C30000           (          xyz.asm):04502                 ADDD    #0
1510 2605             (          xyz.asm):04503                 BNE     L00494
                      (          xyz.asm):04504         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04505         * Useless label L00493 removed
                      (          xyz.asm):04506         * Line xyz.c:950: return with value
1512 4F               (          xyz.asm):04507                 CLRA
1513 C603             (          xyz.asm):04508                 LDB     #$03            decimal 3 signed
1515 201D             (          xyz.asm):04509                 BRA     L00057          return (xyz.c:950)
                      (          xyz.asm):04510         * optim: instrFollowingUncondBranch
     1517             (          xyz.asm):04511         L00494  EQU     *               else
                      (          xyz.asm):04512         * Line xyz.c:951: if
                      (          xyz.asm):04513         * Line xyz.c:951: function call: strcasecmp()
1517 308D17A9         (          xyz.asm):04514                 LEAX    S00104,PCR      "continue"
151B 3410             (          xyz.asm):04515                 PSHS    X               argument 2 of strcasecmp(): const char[]
151D AE48             (          xyz.asm):04516                 LDX     8,U             get pointer value
151F EC84             (          xyz.asm):04517                 LDD     ,X
1521 3406             (          xyz.asm):04518                 PSHS    B,A             argument 1 of strcasecmp(): char *
1523 171531           (          xyz.asm):04519                 LBSR    _strcasecmp
1526 3264             (          xyz.asm):04520                 LEAS    4,S
1528 C30000           (          xyz.asm):04521                 ADDD    #0
152B 2605             (          xyz.asm):04522                 BNE     L00497
                      (          xyz.asm):04523         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04524         * Useless label L00496 removed
                      (          xyz.asm):04525         * Line xyz.c:951: return with value
152D 4F               (          xyz.asm):04526                 CLRA
152E C604             (          xyz.asm):04527                 LDB     #$04            decimal 4 signed
1530 2002             (          xyz.asm):04528                 BRA     L00057          return (xyz.c:951)
     1532             (          xyz.asm):04529         L00497  EQU     *               else
                      (          xyz.asm):04530         * Useless label L00498 removed
                      (          xyz.asm):04531         * Useless label L00495 removed
                      (          xyz.asm):04532         * Line xyz.c:952: return with value
1532 4F               (          xyz.asm):04533                 CLRA
1533 5F               (          xyz.asm):04534                 CLRB
                      (          xyz.asm):04535         * optim: branchToNextLocation
     1534             (          xyz.asm):04536         L00057  EQU     *               end of picolCommandRetCodes()
1534 32C4             (          xyz.asm):04537                 LEAS    ,U
1536 35C0             (          xyz.asm):04538                 PULS    U,PC
                      (          xyz.asm):04539         * END FUNCTION picolCommandRetCodes(): defined at xyz.c:948
     1538             (          xyz.asm):04540         funcend_picolCommandRetCodes    EQU *
     005E             (          xyz.asm):04541         funcsize_picolCommandRetCodes   EQU     funcend_picolCommandRetCodes-_picolCommandRetCodes
                      (          xyz.asm):04542         
                      (          xyz.asm):04543         
                      (          xyz.asm):04544         *******************************************************************************
                      (          xyz.asm):04545         
                      (          xyz.asm):04546         * FUNCTION picolCommandReturn(): defined at xyz.c:1012
     1538             (          xyz.asm):04547         _picolCommandReturn     EQU     *
1538 3440             (          xyz.asm):04548                 PSHS    U
153A 17150F           (          xyz.asm):04549                 LBSR    _stkcheck
153D FFC0             (          xyz.asm):04550                 FDB     -64             argument for _stkcheck
153F 33E4             (          xyz.asm):04551                 LEAU    ,S
                      (          xyz.asm):04552         * Formal parameters and locals:
                      (          xyz.asm):04553         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):04554         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):04555         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):04556         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):04557         * Line xyz.c:1013: if
1541 EC46             (          xyz.asm):04558                 LDD     6,U             variable argc
1543 10830001         (          xyz.asm):04559                 CMPD    #$01
1547 2719             (          xyz.asm):04560                 BEQ     L00500
                      (          xyz.asm):04561         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04562         * Useless label L00501 removed
1549 EC46             (          xyz.asm):04563                 LDD     6,U             variable argc
154B 10830002         (          xyz.asm):04564                 CMPD    #$02
154F 2711             (          xyz.asm):04565                 BEQ     L00500
                      (          xyz.asm):04566         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04567         * Useless label L00499 removed
                      (          xyz.asm):04568         * Line xyz.c:1013: return with value
                      (          xyz.asm):04569         * Line xyz.c:1013: function call: picolArityErr()
1551 AE48             (          xyz.asm):04570                 LDX     8,U             get pointer value
1553 EC84             (          xyz.asm):04571                 LDD     ,X
1555 3406             (          xyz.asm):04572                 PSHS    B,A             argument 2 of picolArityErr(): char *
1557 EC44             (          xyz.asm):04573                 LDD     4,U             variable i, declared at xyz.c:1012
1559 3406             (          xyz.asm):04574                 PSHS    B,A             argument 1 of picolArityErr(): struct picolInterp *
155B 17F4AE           (          xyz.asm):04575                 LBSR    _picolArityErr
155E 3264             (          xyz.asm):04576                 LEAS    4,S
1560 202A             (          xyz.asm):04577                 BRA     L00062          return (xyz.c:1013)
     1562             (          xyz.asm):04578         L00500  EQU     *               else
                      (          xyz.asm):04579         * Useless label L00502 removed
                      (          xyz.asm):04580         * Line xyz.c:1014: function call: picolSetResult()
1562 EC46             (          xyz.asm):04581                 LDD     6,U             variable argc
1564 10830002         (          xyz.asm):04582                 CMPD    #$02
1568 2703             (          xyz.asm):04583                 BEQ     L00503          if true
156A 5F               (          xyz.asm):04584                 CLRB
156B 2002             (          xyz.asm):04585                 BRA     L00504          false
     156D             (          xyz.asm):04586         L00503  EQU     *
156D C601             (          xyz.asm):04587                 LDB     #1
     156F             (          xyz.asm):04588         L00504  EQU     *
156F 5D               (          xyz.asm):04589                 TSTB
1570 2706             (          xyz.asm):04590                 BEQ     L00505          if conditional expression is false
1572 AE48             (          xyz.asm):04591                 LDX     8,U             get pointer value
                      (          xyz.asm):04592         * optim: optimizeLeaxLdd
1574 EC02             (          xyz.asm):04593                 LDD     2,X             optim: optimizeLeaxLdd
1576 2006             (          xyz.asm):04594                 BRA     L00506          end of true expression of conditional
     1578             (          xyz.asm):04595         L00505  EQU     *
1578 308D16CC         (          xyz.asm):04596                 LEAX    S00095,PCR      ""
157C 1F10             (          xyz.asm):04597                 TFR     X,D
     157E             (          xyz.asm):04598         L00506  EQU     *
157E 3406             (          xyz.asm):04599                 PSHS    B,A             argument 2 of picolSetResult(): const char *
1580 EC44             (          xyz.asm):04600                 LDD     4,U             variable i, declared at xyz.c:1012
1582 3406             (          xyz.asm):04601                 PSHS    B,A             argument 1 of picolSetResult(): struct picolInterp *
1584 171134           (          xyz.asm):04602                 LBSR    _picolSetResult
1587 3264             (          xyz.asm):04603                 LEAS    4,S
                      (          xyz.asm):04604         * Line xyz.c:1015: return with value
1589 4F               (          xyz.asm):04605                 CLRA
158A C602             (          xyz.asm):04606                 LDB     #$02            decimal 2 signed
                      (          xyz.asm):04607         * optim: branchToNextLocation
     158C             (          xyz.asm):04608         L00062  EQU     *               end of picolCommandReturn()
158C 32C4             (          xyz.asm):04609                 LEAS    ,U
158E 35C0             (          xyz.asm):04610                 PULS    U,PC
                      (          xyz.asm):04611         * END FUNCTION picolCommandReturn(): defined at xyz.c:1012
     1590             (          xyz.asm):04612         funcend_picolCommandReturn      EQU *
     0058             (          xyz.asm):04613         funcsize_picolCommandReturn     EQU     funcend_picolCommandReturn-_picolCommandReturn
                      (          xyz.asm):04614         
                      (          xyz.asm):04615         
                      (          xyz.asm):04616         *******************************************************************************
                      (          xyz.asm):04617         
                      (          xyz.asm):04618         * FUNCTION picolCommandSet(): defined at xyz.c:884
     1590             (          xyz.asm):04619         _picolCommandSet        EQU     *
1590 3440             (          xyz.asm):04620                 PSHS    U
1592 1714B7           (          xyz.asm):04621                 LBSR    _stkcheck
1595 FFBE             (          xyz.asm):04622                 FDB     -66             argument for _stkcheck
1597 33E4             (          xyz.asm):04623                 LEAU    ,S
1599 327E             (          xyz.asm):04624                 LEAS    -2,S
                      (          xyz.asm):04625         * Formal parameters and locals:
                      (          xyz.asm):04626         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):04627         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):04628         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):04629         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):04630         * Line xyz.c:885: if
159B EC46             (          xyz.asm):04631                 LDD     6,U             variable argc
159D 10830002         (          xyz.asm):04632                 CMPD    #$02
15A1 271A             (          xyz.asm):04633                 BEQ     L00508
                      (          xyz.asm):04634         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04635         * Useless label L00509 removed
15A3 EC46             (          xyz.asm):04636                 LDD     6,U             variable argc
15A5 10830003         (          xyz.asm):04637                 CMPD    #$03
15A9 2712             (          xyz.asm):04638                 BEQ     L00508
                      (          xyz.asm):04639         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04640         * Useless label L00507 removed
                      (          xyz.asm):04641         * Line xyz.c:885: return with value
                      (          xyz.asm):04642         * Line xyz.c:885: function call: picolArityErr()
15AB AE48             (          xyz.asm):04643                 LDX     8,U             get pointer value
15AD EC84             (          xyz.asm):04644                 LDD     ,X
15AF 3406             (          xyz.asm):04645                 PSHS    B,A             argument 2 of picolArityErr(): char *
15B1 EC44             (          xyz.asm):04646                 LDD     4,U             variable i, declared at xyz.c:884
15B3 3406             (          xyz.asm):04647                 PSHS    B,A             argument 1 of picolArityErr(): struct picolInterp *
15B5 17F454           (          xyz.asm):04648                 LBSR    _picolArityErr
15B8 3264             (          xyz.asm):04649                 LEAS    4,S
15BA 160072           (          xyz.asm):04650                 LBRA    L00053          return (xyz.c:885)
     15BD             (          xyz.asm):04651         L00508  EQU     *               else
                      (          xyz.asm):04652         * Useless label L00510 removed
                      (          xyz.asm):04653         * Line xyz.c:886: if
15BD EC46             (          xyz.asm):04654                 LDD     6,U             variable argc
15BF 10830002         (          xyz.asm):04655                 CMPD    #$02
15C3 1026003E         (          xyz.asm):04656                 LBNE    L00512
                      (          xyz.asm):04657         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04658         * Useless label L00511 removed
                      (          xyz.asm):04659         * Line xyz.c:888: init of variable s
                      (          xyz.asm):04660         * Line xyz.c:888: function call: picolGetVar()
15C7 AE48             (          xyz.asm):04661                 LDX     8,U             get pointer value
15C9 3002             (          xyz.asm):04662                 LEAX    2,X             add index (1) multiplied by pointed object size (2)
15CB EC84             (          xyz.asm):04663                 LDD     ,X
15CD 3406             (          xyz.asm):04664                 PSHS    B,A             argument 2 of picolGetVar(): char *
15CF EC44             (          xyz.asm):04665                 LDD     4,U             variable i, declared at xyz.c:884
15D1 3406             (          xyz.asm):04666                 PSHS    B,A             argument 1 of picolGetVar(): struct picolInterp *
15D3 170723           (          xyz.asm):04667                 LBSR    _picolGetVar
15D6 3264             (          xyz.asm):04668                 LEAS    4,S
15D8 ED5E             (          xyz.asm):04669                 STD     -2,U            variable s
                      (          xyz.asm):04670         * Line xyz.c:889: if
                      (          xyz.asm):04671         * optim: storeLoad
15DA C30000           (          xyz.asm):04672                 ADDD    #0
15DD 2613             (          xyz.asm):04673                 BNE     L00514
                      (          xyz.asm):04674         * optim: branchToNextLocation
                      (          xyz.asm):04675         * Useless label L00513 removed
                      (          xyz.asm):04676         * Line xyz.c:890: function call: picolSetResult()
15DF 308D16CD         (          xyz.asm):04677                 LEAX    S00101,PCR      "no such var"
                      (          xyz.asm):04678         * optim: optimizePshsOps
15E3 EC44             (          xyz.asm):04679                 LDD     4,U             variable i, declared at xyz.c:884
15E5 3416             (          xyz.asm):04680                 PSHS    X,B,A           optim: optimizePshsOps
15E7 1710D1           (          xyz.asm):04681                 LBSR    _picolSetResult
15EA 3264             (          xyz.asm):04682                 LEAS    4,S
                      (          xyz.asm):04683         * Line xyz.c:891: return with value
15EC 4F               (          xyz.asm):04684                 CLRA
15ED C601             (          xyz.asm):04685                 LDB     #$01            decimal 1 signed
15EF 16003D           (          xyz.asm):04686                 LBRA    L00053          return (xyz.c:891)
     15F2             (          xyz.asm):04687         L00514  EQU     *               else
                      (          xyz.asm):04688         * Useless label L00515 removed
                      (          xyz.asm):04689         * Line xyz.c:893: function call: picolSetResult()
15F2 AE5E             (          xyz.asm):04690                 LDX     -2,U            variable s
15F4 EC02             (          xyz.asm):04691                 LDD     2,X             member val of picolVar
15F6 3406             (          xyz.asm):04692                 PSHS    B,A             argument 2 of picolSetResult(): char *
15F8 EC44             (          xyz.asm):04693                 LDD     4,U             variable i, declared at xyz.c:884
15FA 3406             (          xyz.asm):04694                 PSHS    B,A             argument 1 of picolSetResult(): struct picolInterp *
15FC 1710BC           (          xyz.asm):04695                 LBSR    _picolSetResult
15FF 3264             (          xyz.asm):04696                 LEAS    4,S
                      (          xyz.asm):04697         * Line xyz.c:894: return with value
1601 4F               (          xyz.asm):04698                 CLRA
1602 5F               (          xyz.asm):04699                 CLRB
1603 202A             (          xyz.asm):04700                 BRA     L00053          return (xyz.c:894)
     1605             (          xyz.asm):04701         L00512  EQU     *               else
                      (          xyz.asm):04702         * Useless label L00516 removed
                      (          xyz.asm):04703         * Line xyz.c:897: function call: picolSetVar()
1605 AE48             (          xyz.asm):04704                 LDX     8,U             get pointer value
                      (          xyz.asm):04705         * optim: optimizeLeaxLdd
1607 EC04             (          xyz.asm):04706                 LDD     4,X             optim: optimizeLeaxLdd
1609 3406             (          xyz.asm):04707                 PSHS    B,A             argument 3 of picolSetVar(): char *
160B AE48             (          xyz.asm):04708                 LDX     8,U             get pointer value
160D 3002             (          xyz.asm):04709                 LEAX    2,X             add index (1) multiplied by pointed object size (2)
160F EC84             (          xyz.asm):04710                 LDD     ,X
1611 3406             (          xyz.asm):04711                 PSHS    B,A             argument 2 of picolSetVar(): char *
1613 EC44             (          xyz.asm):04712                 LDD     4,U             variable i, declared at xyz.c:884
1615 3406             (          xyz.asm):04713                 PSHS    B,A             argument 1 of picolSetVar(): struct picolInterp *
1617 1710C6           (          xyz.asm):04714                 LBSR    _picolSetVar
161A 3266             (          xyz.asm):04715                 LEAS    6,S
                      (          xyz.asm):04716         * Line xyz.c:898: function call: picolSetResult()
161C AE48             (          xyz.asm):04717                 LDX     8,U             get pointer value
161E 3004             (          xyz.asm):04718                 LEAX    4,X             add index (2) multiplied by pointed object size (2)
1620 EC84             (          xyz.asm):04719                 LDD     ,X
1622 3406             (          xyz.asm):04720                 PSHS    B,A             argument 2 of picolSetResult(): char *
1624 EC44             (          xyz.asm):04721                 LDD     4,U             variable i, declared at xyz.c:884
1626 3406             (          xyz.asm):04722                 PSHS    B,A             argument 1 of picolSetResult(): struct picolInterp *
1628 171090           (          xyz.asm):04723                 LBSR    _picolSetResult
162B 3264             (          xyz.asm):04724                 LEAS    4,S
                      (          xyz.asm):04725         * Line xyz.c:899: return with value
162D 4F               (          xyz.asm):04726                 CLRA
162E 5F               (          xyz.asm):04727                 CLRB
                      (          xyz.asm):04728         * optim: branchToNextLocation
     162F             (          xyz.asm):04729         L00053  EQU     *               end of picolCommandSet()
162F 32C4             (          xyz.asm):04730                 LEAS    ,U
1631 35C0             (          xyz.asm):04731                 PULS    U,PC
                      (          xyz.asm):04732         * END FUNCTION picolCommandSet(): defined at xyz.c:884
     1633             (          xyz.asm):04733         funcend_picolCommandSet EQU *
     00A3             (          xyz.asm):04734         funcsize_picolCommandSet        EQU     funcend_picolCommandSet-_picolCommandSet
                      (          xyz.asm):04735         
                      (          xyz.asm):04736         
                      (          xyz.asm):04737         *******************************************************************************
                      (          xyz.asm):04738         
                      (          xyz.asm):04739         * FUNCTION picolCommandSleep(): defined at xyz.c:1234
     1633             (          xyz.asm):04740         _picolCommandSleep      EQU     *
1633 3440             (          xyz.asm):04741                 PSHS    U
1635 171414           (          xyz.asm):04742                 LBSR    _stkcheck
1638 FFBC             (          xyz.asm):04743                 FDB     -68             argument for _stkcheck
163A 33E4             (          xyz.asm):04744                 LEAU    ,S
163C 327C             (          xyz.asm):04745                 LEAS    -4,S
                      (          xyz.asm):04746         * Formal parameters and locals:
                      (          xyz.asm):04747         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):04748         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):04749         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):04750         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):04751         *   ticks: int; 2 bytes at -4,U
                      (          xyz.asm):04752         *   e: int; 2 bytes at -2,U
                      (          xyz.asm):04753         * Line xyz.c:1235: if
163E EC46             (          xyz.asm):04754                 LDD     6,U             variable argc
1640 10830002         (          xyz.asm):04755                 CMPD    #$02
1644 2712             (          xyz.asm):04756                 BEQ     L00518
                      (          xyz.asm):04757         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04758         * Useless label L00517 removed
                      (          xyz.asm):04759         * Line xyz.c:1235: return with value
                      (          xyz.asm):04760         * Line xyz.c:1235: function call: picolArityErr()
1646 AE48             (          xyz.asm):04761                 LDX     8,U             get pointer value
1648 EC84             (          xyz.asm):04762                 LDD     ,X
164A 3406             (          xyz.asm):04763                 PSHS    B,A             argument 2 of picolArityErr(): char *
164C EC44             (          xyz.asm):04764                 LDD     4,U             variable i, declared at xyz.c:1234
164E 3406             (          xyz.asm):04765                 PSHS    B,A             argument 1 of picolArityErr(): struct picolInterp *
1650 17F3B9           (          xyz.asm):04766                 LBSR    _picolArityErr
1653 3264             (          xyz.asm):04767                 LEAS    4,S
1655 160041           (          xyz.asm):04768                 LBRA    L00081          return (xyz.c:1235)
     1658             (          xyz.asm):04769         L00518  EQU     *               else
                      (          xyz.asm):04770         * Useless label L00519 removed
                      (          xyz.asm):04771         * Line xyz.c:1236: init of variable ticks
                      (          xyz.asm):04772         * Line xyz.c:1236: function call: atoi()
1658 AE48             (          xyz.asm):04773                 LDX     8,U             get pointer value
165A 3002             (          xyz.asm):04774                 LEAX    2,X             add index (1) multiplied by pointed object size (2)
165C EC84             (          xyz.asm):04775                 LDD     ,X
165E 3406             (          xyz.asm):04776                 PSHS    B,A             argument 1 of atoi(): char *
1660 17EDCC           (          xyz.asm):04777                 LBSR    _atoi
1663 3262             (          xyz.asm):04778                 LEAS    2,S
1665 ED5C             (          xyz.asm):04779                 STD     -4,U            variable ticks
                      (          xyz.asm):04780         * Line xyz.c:1237: init of variable e
                      (          xyz.asm):04781         * Line xyz.c:1237: function call: Os9Sleep()
                      (          xyz.asm):04782         * optim: storeLoad
1667 3406             (          xyz.asm):04783                 PSHS    B,A             argument 1 of Os9Sleep(): int
1669 17EBB3           (          xyz.asm):04784                 LBSR    _Os9Sleep
166C 3262             (          xyz.asm):04785                 LEAS    2,S
166E ED5E             (          xyz.asm):04786                 STD     -2,U            variable e
                      (          xyz.asm):04787         * Line xyz.c:1238: if
                      (          xyz.asm):04788         * optim: storeLoad
1670 C30000           (          xyz.asm):04789                 ADDD    #0
1673 2715             (          xyz.asm):04790                 BEQ     L00521
                      (          xyz.asm):04791         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04792         * Useless label L00520 removed
                      (          xyz.asm):04793         * Line xyz.c:1238: return with value
                      (          xyz.asm):04794         * Line xyz.c:1238: function call: Error()
1675 EC5E             (          xyz.asm):04795                 LDD     -2,U            variable e, declared at xyz.c:1237
1677 3406             (          xyz.asm):04796                 PSHS    B,A             argument 3 of Error(): int
1679 AE48             (          xyz.asm):04797                 LDX     8,U             get pointer value
167B EC84             (          xyz.asm):04798                 LDD     ,X
167D 3406             (          xyz.asm):04799                 PSHS    B,A             argument 2 of Error(): char *
167F EC44             (          xyz.asm):04800                 LDD     4,U             variable i, declared at xyz.c:1234
1681 3406             (          xyz.asm):04801                 PSHS    B,A             argument 1 of Error(): struct picolInterp *
1683 17EA22           (          xyz.asm):04802                 LBSR    _Error
1686 3266             (          xyz.asm):04803                 LEAS    6,S
1688 200F             (          xyz.asm):04804                 BRA     L00081          return (xyz.c:1238)
     168A             (          xyz.asm):04805         L00521  EQU     *               else
                      (          xyz.asm):04806         * Useless label L00522 removed
                      (          xyz.asm):04807         * Line xyz.c:1239: function call: picolSetResult()
168A 308D15BA         (          xyz.asm):04808                 LEAX    S00095,PCR      ""
                      (          xyz.asm):04809         * optim: optimizePshsOps
168E EC44             (          xyz.asm):04810                 LDD     4,U             variable i, declared at xyz.c:1234
1690 3416             (          xyz.asm):04811                 PSHS    X,B,A           optim: optimizePshsOps
1692 171026           (          xyz.asm):04812                 LBSR    _picolSetResult
1695 3264             (          xyz.asm):04813                 LEAS    4,S
                      (          xyz.asm):04814         * Line xyz.c:1240: return with value
1697 4F               (          xyz.asm):04815                 CLRA
1698 5F               (          xyz.asm):04816                 CLRB
                      (          xyz.asm):04817         * optim: branchToNextLocation
     1699             (          xyz.asm):04818         L00081  EQU     *               end of picolCommandSleep()
1699 32C4             (          xyz.asm):04819                 LEAS    ,U
169B 35C0             (          xyz.asm):04820                 PULS    U,PC
                      (          xyz.asm):04821         * END FUNCTION picolCommandSleep(): defined at xyz.c:1234
     169D             (          xyz.asm):04822         funcend_picolCommandSleep       EQU *
     006A             (          xyz.asm):04823         funcsize_picolCommandSleep      EQU     funcend_picolCommandSleep-_picolCommandSleep
                      (          xyz.asm):04824         
                      (          xyz.asm):04825         
                      (          xyz.asm):04826         *******************************************************************************
                      (          xyz.asm):04827         
                      (          xyz.asm):04828         * FUNCTION picolCommandWait(): defined at xyz.c:1208
     169D             (          xyz.asm):04829         _picolCommandWait       EQU     *
169D 3440             (          xyz.asm):04830                 PSHS    U
169F 1713AA           (          xyz.asm):04831                 LBSR    _stkcheck
16A2 FFBC             (          xyz.asm):04832                 FDB     -68             argument for _stkcheck
16A4 33E4             (          xyz.asm):04833                 LEAU    ,S
16A6 327C             (          xyz.asm):04834                 LEAS    -4,S
                      (          xyz.asm):04835         * Formal parameters and locals:
                      (          xyz.asm):04836         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):04837         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):04838         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):04839         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):04840         *   child_id: int; 2 bytes at -4,U
                      (          xyz.asm):04841         *   e: int; 2 bytes at -2,U
                      (          xyz.asm):04842         * Line xyz.c:1209: if
16A8 EC46             (          xyz.asm):04843                 LDD     6,U             variable argc
16AA 10830001         (          xyz.asm):04844                 CMPD    #$01
16AE 2711             (          xyz.asm):04845                 BEQ     L00524
                      (          xyz.asm):04846         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04847         * Useless label L00523 removed
                      (          xyz.asm):04848         * Line xyz.c:1209: return with value
                      (          xyz.asm):04849         * Line xyz.c:1209: function call: picolArityErr()
16B0 AE48             (          xyz.asm):04850                 LDX     8,U             get pointer value
16B2 EC84             (          xyz.asm):04851                 LDD     ,X
16B4 3406             (          xyz.asm):04852                 PSHS    B,A             argument 2 of picolArityErr(): char *
16B6 EC44             (          xyz.asm):04853                 LDD     4,U             variable i, declared at xyz.c:1208
16B8 3406             (          xyz.asm):04854                 PSHS    B,A             argument 1 of picolArityErr(): struct picolInterp *
16BA 17F34F           (          xyz.asm):04855                 LBSR    _picolArityErr
16BD 3264             (          xyz.asm):04856                 LEAS    4,S
16BF 2036             (          xyz.asm):04857                 BRA     L00078          return (xyz.c:1209)
     16C1             (          xyz.asm):04858         L00524  EQU     *               else
                      (          xyz.asm):04859         * Useless label L00525 removed
                      (          xyz.asm):04860         * Line xyz.c:1210: init of variable child_id
16C1 4F               (          xyz.asm):04861                 CLRA
16C2 5F               (          xyz.asm):04862                 CLRB
16C3 ED5C             (          xyz.asm):04863                 STD     -4,U            variable child_id
                      (          xyz.asm):04864         * Line xyz.c:1211: init of variable e
                      (          xyz.asm):04865         * Line xyz.c:1211: function call: Os9Wait()
16C5 305C             (          xyz.asm):04866                 LEAX    -4,U            variable child_id, declared at xyz.c:1210
16C7 3410             (          xyz.asm):04867                 PSHS    X               argument 1 of Os9Wait(): int *
16C9 17EB65           (          xyz.asm):04868                 LBSR    _Os9Wait
16CC 3262             (          xyz.asm):04869                 LEAS    2,S
16CE ED5E             (          xyz.asm):04870                 STD     -2,U            variable e
                      (          xyz.asm):04871         * Line xyz.c:1212: if
                      (          xyz.asm):04872         * optim: storeLoad
16D0 C30000           (          xyz.asm):04873                 ADDD    #0
16D3 2715             (          xyz.asm):04874                 BEQ     L00527
                      (          xyz.asm):04875         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04876         * Useless label L00526 removed
                      (          xyz.asm):04877         * Line xyz.c:1212: return with value
                      (          xyz.asm):04878         * Line xyz.c:1212: function call: Error()
16D5 EC5E             (          xyz.asm):04879                 LDD     -2,U            variable e, declared at xyz.c:1211
16D7 3406             (          xyz.asm):04880                 PSHS    B,A             argument 3 of Error(): int
16D9 AE48             (          xyz.asm):04881                 LDX     8,U             get pointer value
16DB EC84             (          xyz.asm):04882                 LDD     ,X
16DD 3406             (          xyz.asm):04883                 PSHS    B,A             argument 2 of Error(): char *
16DF EC44             (          xyz.asm):04884                 LDD     4,U             variable i, declared at xyz.c:1208
16E1 3406             (          xyz.asm):04885                 PSHS    B,A             argument 1 of Error(): struct picolInterp *
16E3 17E9C2           (          xyz.asm):04886                 LBSR    _Error
16E6 3266             (          xyz.asm):04887                 LEAS    6,S
16E8 200D             (          xyz.asm):04888                 BRA     L00078          return (xyz.c:1212)
     16EA             (          xyz.asm):04889         L00527  EQU     *               else
                      (          xyz.asm):04890         * Useless label L00528 removed
                      (          xyz.asm):04891         * Line xyz.c:1213: return with value
                      (          xyz.asm):04892         * Line xyz.c:1213: function call: ResultD()
16EA EC5C             (          xyz.asm):04893                 LDD     -4,U            variable child_id, declared at xyz.c:1210
16EC 3406             (          xyz.asm):04894                 PSHS    B,A             argument 2 of ResultD(): int
16EE EC44             (          xyz.asm):04895                 LDD     4,U             variable i, declared at xyz.c:1208
16F0 3406             (          xyz.asm):04896                 PSHS    B,A             argument 1 of ResultD(): struct picolInterp *
16F2 17EC1C           (          xyz.asm):04897                 LBSR    _ResultD
16F5 3264             (          xyz.asm):04898                 LEAS    4,S
                      (          xyz.asm):04899         * optim: branchToNextLocation
     16F7             (          xyz.asm):04900         L00078  EQU     *               end of picolCommandWait()
16F7 32C4             (          xyz.asm):04901                 LEAS    ,U
16F9 35C0             (          xyz.asm):04902                 PULS    U,PC
                      (          xyz.asm):04903         * END FUNCTION picolCommandWait(): defined at xyz.c:1208
     16FB             (          xyz.asm):04904         funcend_picolCommandWait        EQU *
     005E             (          xyz.asm):04905         funcsize_picolCommandWait       EQU     funcend_picolCommandWait-_picolCommandWait
                      (          xyz.asm):04906         
                      (          xyz.asm):04907         
                      (          xyz.asm):04908         *******************************************************************************
                      (          xyz.asm):04909         
                      (          xyz.asm):04910         * FUNCTION picolCommandWhile(): defined at xyz.c:932
     16FB             (          xyz.asm):04911         _picolCommandWhile      EQU     *
16FB 3440             (          xyz.asm):04912                 PSHS    U
16FD 17134C           (          xyz.asm):04913                 LBSR    _stkcheck
1700 FFBE             (          xyz.asm):04914                 FDB     -66             argument for _stkcheck
1702 33E4             (          xyz.asm):04915                 LEAU    ,S
1704 327E             (          xyz.asm):04916                 LEAS    -2,S
                      (          xyz.asm):04917         * Formal parameters and locals:
                      (          xyz.asm):04918         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):04919         *   argc: int; 2 bytes at 6,U
                      (          xyz.asm):04920         *   argv: char **; 2 bytes at 8,U
                      (          xyz.asm):04921         *   pd: void *; 2 bytes at 10,U
                      (          xyz.asm):04922         * Line xyz.c:933: if
1706 EC46             (          xyz.asm):04923                 LDD     6,U             variable argc
1708 10830003         (          xyz.asm):04924                 CMPD    #$03
170C 2712             (          xyz.asm):04925                 BEQ     L00530
                      (          xyz.asm):04926         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04927         * Useless label L00529 removed
                      (          xyz.asm):04928         * Line xyz.c:933: return with value
                      (          xyz.asm):04929         * Line xyz.c:933: function call: picolArityErr()
170E AE48             (          xyz.asm):04930                 LDX     8,U             get pointer value
1710 EC84             (          xyz.asm):04931                 LDD     ,X
1712 3406             (          xyz.asm):04932                 PSHS    B,A             argument 2 of picolArityErr(): char *
1714 EC44             (          xyz.asm):04933                 LDD     4,U             variable i, declared at xyz.c:932
1716 3406             (          xyz.asm):04934                 PSHS    B,A             argument 1 of picolArityErr(): struct picolInterp *
1718 17F2F1           (          xyz.asm):04935                 LBSR    _picolArityErr
171B 3264             (          xyz.asm):04936                 LEAS    4,S
171D 16006C           (          xyz.asm):04937                 LBRA    L00056          return (xyz.c:933)
     1720             (          xyz.asm):04938         L00530  EQU     *               else
                      (          xyz.asm):04939         * Useless label L00531 removed
                      (          xyz.asm):04940         * Line xyz.c:934: while
1720 160066           (          xyz.asm):04941                 LBRA    L00533          jump to while condition
     1723             (          xyz.asm):04942         L00532  EQU     *               while body
                      (          xyz.asm):04943         * Line xyz.c:935: init of variable retcode
                      (          xyz.asm):04944         * Line xyz.c:935: function call: picolEval()
1723 AE48             (          xyz.asm):04945                 LDX     8,U             get pointer value
1725 3002             (          xyz.asm):04946                 LEAX    2,X             add index (1) multiplied by pointed object size (2)
1727 EC84             (          xyz.asm):04947                 LDD     ,X
1729 3406             (          xyz.asm):04948                 PSHS    B,A             argument 2 of picolEval(): char *
172B EC44             (          xyz.asm):04949                 LDD     4,U             variable i, declared at xyz.c:932
172D 3406             (          xyz.asm):04950                 PSHS    B,A             argument 1 of picolEval(): struct picolInterp *
172F 1700BE           (          xyz.asm):04951                 LBSR    _picolEval
1732 3264             (          xyz.asm):04952                 LEAS    4,S
1734 ED5E             (          xyz.asm):04953                 STD     -2,U            variable retcode
                      (          xyz.asm):04954         * Line xyz.c:936: if
                      (          xyz.asm):04955         * optim: storeLoad
1736 C30000           (          xyz.asm):04956                 ADDD    #0
1739 2705             (          xyz.asm):04957                 BEQ     L00536
                      (          xyz.asm):04958         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04959         * Useless label L00535 removed
                      (          xyz.asm):04960         * Line xyz.c:936: return with value
173B EC5E             (          xyz.asm):04961                 LDD     -2,U            variable retcode, declared at xyz.c:935
173D 16004C           (          xyz.asm):04962                 LBRA    L00056          return (xyz.c:936)
     1740             (          xyz.asm):04963         L00536  EQU     *               else
                      (          xyz.asm):04964         * Useless label L00537 removed
                      (          xyz.asm):04965         * Line xyz.c:937: if
                      (          xyz.asm):04966         * Line xyz.c:937: function call: atoi()
1740 AE44             (          xyz.asm):04967                 LDX     4,U             variable i
1742 EC06             (          xyz.asm):04968                 LDD     6,X             member result of picolInterp
1744 3406             (          xyz.asm):04969                 PSHS    B,A             argument 1 of atoi(): char *
1746 17ECE6           (          xyz.asm):04970                 LBSR    _atoi
1749 3262             (          xyz.asm):04971                 LEAS    2,S
174B C30000           (          xyz.asm):04972                 ADDD    #0
174E 2735             (          xyz.asm):04973                 BEQ     L00539
                      (          xyz.asm):04974         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04975         * Useless label L00538 removed
                      (          xyz.asm):04976         * Line xyz.c:938: if
1750 4F               (          xyz.asm):04977                 CLRA
1751 C604             (          xyz.asm):04978                 LDB     #$04            decimal 4 signed
1753 3406             (          xyz.asm):04979                 PSHS    B,A
                      (          xyz.asm):04980         * Line xyz.c:938: assignment: =
                      (          xyz.asm):04981         * Line xyz.c:938: function call: picolEval()
1755 AE48             (          xyz.asm):04982                 LDX     8,U             get pointer value
1757 3004             (          xyz.asm):04983                 LEAX    4,X             add index (2) multiplied by pointed object size (2)
1759 EC84             (          xyz.asm):04984                 LDD     ,X
175B 3406             (          xyz.asm):04985                 PSHS    B,A             argument 2 of picolEval(): char *
175D EC44             (          xyz.asm):04986                 LDD     4,U             variable i, declared at xyz.c:932
175F 3406             (          xyz.asm):04987                 PSHS    B,A             argument 1 of picolEval(): struct picolInterp *
1761 17008C           (          xyz.asm):04988                 LBSR    _picolEval
1764 3264             (          xyz.asm):04989                 LEAS    4,S
1766 ED5E             (          xyz.asm):04990                 STD     -2,U
1768 10A3E1           (          xyz.asm):04991                 CMPD    ,S++
176B 2602             (          xyz.asm):04992                 BNE     L00541
                      (          xyz.asm):04993         * optim: condBranchOverUncondBranch
                      (          xyz.asm):04994         * Useless label L00540 removed
176D 201A             (          xyz.asm):04995                 BRA     L00533          continue
                      (          xyz.asm):04996         * optim: instrFollowingUncondBranch
     176F             (          xyz.asm):04997         L00541  EQU     *               else
                      (          xyz.asm):04998         * Line xyz.c:939: if
176F EC5E             (          xyz.asm):04999                 LDD     -2,U            variable retcode, declared at xyz.c:935
                      (          xyz.asm):05000         * optim: loadCmpZeroBeqOrBne
1771 2602             (          xyz.asm):05001                 BNE     L00544
                      (          xyz.asm):05002         * optim: condBranchOverUncondBranch
                      (          xyz.asm):05003         * Useless label L00543 removed
1773 2014             (          xyz.asm):05004                 BRA     L00533          continue
                      (          xyz.asm):05005         * optim: instrFollowingUncondBranch
     1775             (          xyz.asm):05006         L00544  EQU     *               else
                      (          xyz.asm):05007         * Line xyz.c:940: if
1775 EC5E             (          xyz.asm):05008                 LDD     -2,U            variable retcode
1777 10830003         (          xyz.asm):05009                 CMPD    #$03
177B 2604             (          xyz.asm):05010                 BNE     L00547
                      (          xyz.asm):05011         * optim: condBranchOverUncondBranch
                      (          xyz.asm):05012         * Useless label L00546 removed
                      (          xyz.asm):05013         * Line xyz.c:940: return with value
177D 4F               (          xyz.asm):05014                 CLRA
177E 5F               (          xyz.asm):05015                 CLRB
177F 200B             (          xyz.asm):05016                 BRA     L00056          return (xyz.c:940)
                      (          xyz.asm):05017         * optim: instrFollowingUncondBranch
     1781             (          xyz.asm):05018         L00547  EQU     *               else
                      (          xyz.asm):05019         * Line xyz.c:941: return with value
1781 EC5E             (          xyz.asm):05020                 LDD     -2,U            variable retcode, declared at xyz.c:935
1783 2007             (          xyz.asm):05021                 BRA     L00056          return (xyz.c:941)
                      (          xyz.asm):05022         * Useless label L00548 removed
                      (          xyz.asm):05023         * Useless label L00545 removed
                      (          xyz.asm):05024         * Useless label L00542 removed
                      (          xyz.asm):05025         * optim: instrFollowingUncondBranch
     1785             (          xyz.asm):05026         L00539  EQU     *               else
                      (          xyz.asm):05027         * Line xyz.c:943: return with value
1785 4F               (          xyz.asm):05028                 CLRA
1786 5F               (          xyz.asm):05029                 CLRB
1787 2003             (          xyz.asm):05030                 BRA     L00056          return (xyz.c:943)
                      (          xyz.asm):05031         * Useless label L00549 removed
     1789             (          xyz.asm):05032         L00533  EQU     *               while condition at xyz.c:934
1789 16FF97           (          xyz.asm):05033                 LBRA    L00532          go to start of while body
                      (          xyz.asm):05034         * Useless label L00534 removed
     178C             (          xyz.asm):05035         L00056  EQU     *               end of picolCommandWhile()
178C 32C4             (          xyz.asm):05036                 LEAS    ,U
178E 35C0             (          xyz.asm):05037                 PULS    U,PC
                      (          xyz.asm):05038         * END FUNCTION picolCommandWhile(): defined at xyz.c:932
     1790             (          xyz.asm):05039         funcend_picolCommandWhile       EQU *
     0095             (          xyz.asm):05040         funcsize_picolCommandWhile      EQU     funcend_picolCommandWhile-_picolCommandWhile
                      (          xyz.asm):05041         
                      (          xyz.asm):05042         
                      (          xyz.asm):05043         *******************************************************************************
                      (          xyz.asm):05044         
                      (          xyz.asm):05045         * FUNCTION picolDropCallFrame(): defined at xyz.c:955
     1790             (          xyz.asm):05046         _picolDropCallFrame     EQU     *
1790 3440             (          xyz.asm):05047                 PSHS    U
1792 1712B7           (          xyz.asm):05048                 LBSR    _stkcheck
1795 FFBA             (          xyz.asm):05049                 FDB     -70             argument for _stkcheck
1797 33E4             (          xyz.asm):05050                 LEAU    ,S
1799 327A             (          xyz.asm):05051                 LEAS    -6,S
                      (          xyz.asm):05052         * Formal parameters and locals:
                      (          xyz.asm):05053         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):05054         *   cf: struct picolCallFrame *; 2 bytes at -6,U
                      (          xyz.asm):05055         *   v: struct picolVar *; 2 bytes at -4,U
                      (          xyz.asm):05056         *   t: struct picolVar *; 2 bytes at -2,U
                      (          xyz.asm):05057         * Line xyz.c:956: init of variable cf
179B AE44             (          xyz.asm):05058                 LDX     4,U             variable i
179D EC02             (          xyz.asm):05059                 LDD     2,X             member callframe of picolInterp
179F ED5A             (          xyz.asm):05060                 STD     -6,U            variable cf
                      (          xyz.asm):05061         * Line xyz.c:957: init of variable v
                      (          xyz.asm):05062         * optim: optimizeIndexedX
17A1 ECD8FA           (          xyz.asm):05063                 LDD     [-6,U]          optim: optimizeIndexedX
17A4 ED5C             (          xyz.asm):05064                 STD     -4,U            variable v
                      (          xyz.asm):05065         * Line xyz.c:958: while
17A6 2029             (          xyz.asm):05066                 BRA     L00551          jump to while condition
     17A8             (          xyz.asm):05067         L00550  EQU     *               while body
                      (          xyz.asm):05068         * Line xyz.c:959: assignment: =
17A8 AE5C             (          xyz.asm):05069                 LDX     -4,U            variable v
17AA EC04             (          xyz.asm):05070                 LDD     4,X             member next of picolVar
17AC ED5E             (          xyz.asm):05071                 STD     -2,U
                      (          xyz.asm):05072         * Line xyz.c:960: function call: free()
17AE AE5C             (          xyz.asm):05073                 LDX     -4,U            variable v
17B0 EC84             (          xyz.asm):05074                 LDD     ,X              member name of picolVar
17B2 3406             (          xyz.asm):05075                 PSHS    B,A             argument 1 of free(): char *
17B4 17EE6C           (          xyz.asm):05076                 LBSR    _free
17B7 3262             (          xyz.asm):05077                 LEAS    2,S
                      (          xyz.asm):05078         * Line xyz.c:961: function call: free()
17B9 AE5C             (          xyz.asm):05079                 LDX     -4,U            variable v
17BB EC02             (          xyz.asm):05080                 LDD     2,X             member val of picolVar
17BD 3406             (          xyz.asm):05081                 PSHS    B,A             argument 1 of free(): char *
17BF 17EE61           (          xyz.asm):05082                 LBSR    _free
17C2 3262             (          xyz.asm):05083                 LEAS    2,S
                      (          xyz.asm):05084         * Line xyz.c:962: function call: free()
17C4 EC5C             (          xyz.asm):05085                 LDD     -4,U            variable v, declared at xyz.c:957
17C6 3406             (          xyz.asm):05086                 PSHS    B,A             argument 1 of free(): struct picolVar *
17C8 17EE58           (          xyz.asm):05087                 LBSR    _free
17CB 3262             (          xyz.asm):05088                 LEAS    2,S
                      (          xyz.asm):05089         * Line xyz.c:963: assignment: =
                      (          xyz.asm):05090         * optim: stripConsecutiveLoadsToSameReg
17CD EC5E             (          xyz.asm):05091                 LDD     -2,U
17CF ED5C             (          xyz.asm):05092                 STD     -4,U
     17D1             (          xyz.asm):05093         L00551  EQU     *               while condition at xyz.c:958
17D1 EC5C             (          xyz.asm):05094                 LDD     -4,U            variable v, declared at xyz.c:957
                      (          xyz.asm):05095         * optim: loadCmpZeroBeqOrBne
17D3 26D3             (          xyz.asm):05096                 BNE     L00550
                      (          xyz.asm):05097         * optim: branchToNextLocation
                      (          xyz.asm):05098         * Useless label L00552 removed
                      (          xyz.asm):05099         * Line xyz.c:965: assignment: =
17D5 AE5A             (          xyz.asm):05100                 LDX     -6,U            variable cf
17D7 EC02             (          xyz.asm):05101                 LDD     2,X             member parent of picolCallFrame
17D9 3406             (          xyz.asm):05102                 PSHS    B,A
17DB AE44             (          xyz.asm):05103                 LDX     4,U             variable i
17DD 3002             (          xyz.asm):05104                 LEAX    2,X             member callframe of picolInterp
17DF 3506             (          xyz.asm):05105                 PULS    A,B             retrieve value to store
17E1 ED84             (          xyz.asm):05106                 STD     ,X
                      (          xyz.asm):05107         * Line xyz.c:966: function call: free()
17E3 EC5A             (          xyz.asm):05108                 LDD     -6,U            variable cf, declared at xyz.c:956
17E5 3406             (          xyz.asm):05109                 PSHS    B,A             argument 1 of free(): struct picolCallFrame *
17E7 17EE39           (          xyz.asm):05110                 LBSR    _free
17EA 3262             (          xyz.asm):05111                 LEAS    2,S
                      (          xyz.asm):05112         * Useless label L00058 removed
17EC 32C4             (          xyz.asm):05113                 LEAS    ,U
17EE 35C0             (          xyz.asm):05114                 PULS    U,PC
                      (          xyz.asm):05115         * END FUNCTION picolDropCallFrame(): defined at xyz.c:955
     17F0             (          xyz.asm):05116         funcend_picolDropCallFrame      EQU *
     0060             (          xyz.asm):05117         funcsize_picolDropCallFrame     EQU     funcend_picolDropCallFrame-_picolDropCallFrame
                      (          xyz.asm):05118         
                      (          xyz.asm):05119         
                      (          xyz.asm):05120         *******************************************************************************
                      (          xyz.asm):05121         
                      (          xyz.asm):05122         * FUNCTION picolEval(): defined at xyz.c:772
     17F0             (          xyz.asm):05123         _picolEval      EQU     *
17F0 3440             (          xyz.asm):05124                 PSHS    U
17F2 171257           (          xyz.asm):05125                 LBSR    _stkcheck
17F5 FED8             (          xyz.asm):05126                 FDB     -296            argument for _stkcheck
17F7 33E4             (          xyz.asm):05127                 LEAU    ,S
17F9 32E9FF18         (          xyz.asm):05128                 LEAS    -232,S
                      (          xyz.asm):05129         * Formal parameters and locals:
                      (          xyz.asm):05130         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):05131         *   t: char *; 2 bytes at 6,U
                      (          xyz.asm):05132         *   p: struct picolParser; 14 bytes at -222,U
                      (          xyz.asm):05133         *   argc: int; 2 bytes at -208,U
                      (          xyz.asm):05134         *   j: int; 2 bytes at -206,U
                      (          xyz.asm):05135         *   argv: char **; 2 bytes at -204,U
                      (          xyz.asm):05136         *   errbuf: char[]; 200 bytes at -202,U
                      (          xyz.asm):05137         *   retcode: int; 2 bytes at -2,U
                      (          xyz.asm):05138         * Line xyz.c:774: init of variable argc
17FD 4F               (          xyz.asm):05139                 CLRA
17FE 5F               (          xyz.asm):05140                 CLRB
17FF EDC9FF30         (          xyz.asm):05141                 STD     -208,U          variable argc
                      (          xyz.asm):05142         * Line xyz.c:775: init of variable argv
                      (          xyz.asm):05143         * optim: stripExtraClrA_B
                      (          xyz.asm):05144         * optim: stripExtraClrA_B
1803 EDC9FF34         (          xyz.asm):05145                 STD     -204,U          variable argv
                      (          xyz.asm):05146         * Line xyz.c:777: init of variable retcode
                      (          xyz.asm):05147         * optim: stripExtraClrA_B
                      (          xyz.asm):05148         * optim: stripExtraClrA_B
1807 ED5E             (          xyz.asm):05149                 STD     -2,U            variable retcode
                      (          xyz.asm):05150         * Line xyz.c:778: function call: picolSetResult()
1809 308D143B         (          xyz.asm):05151                 LEAX    S00095,PCR      ""
                      (          xyz.asm):05152         * optim: optimizePshsOps
180D EC44             (          xyz.asm):05153                 LDD     4,U             variable i, declared at xyz.c:772
180F 3416             (          xyz.asm):05154                 PSHS    X,B,A           optim: optimizePshsOps
1811 170EA7           (          xyz.asm):05155                 LBSR    _picolSetResult
1814 3264             (          xyz.asm):05156                 LEAS    4,S
                      (          xyz.asm):05157         * Line xyz.c:779: function call: picolInitParser()
1816 EC46             (          xyz.asm):05158                 LDD     6,U             variable t, declared at xyz.c:772
1818 3406             (          xyz.asm):05159                 PSHS    B,A             argument 2 of picolInitParser(): char *
181A 30C9FF22         (          xyz.asm):05160                 LEAX    -222,U          variable p, declared at xyz.c:773
181E 3410             (          xyz.asm):05161                 PSHS    X               argument 1 of picolInitParser(): struct picolParser *
1820 170556           (          xyz.asm):05162                 LBSR    _picolInitParser
1823 3264             (          xyz.asm):05163                 LEAS    4,S
                      (          xyz.asm):05164         * Line xyz.c:780: while
1825 16035E           (          xyz.asm):05165                 LBRA    L00554          jump to while condition
     1828             (          xyz.asm):05166         L00553  EQU     *               while body
                      (          xyz.asm):05167         * Line xyz.c:783: init of variable prevtype
1828 ECC9FF2C         (          xyz.asm):05168                 LDD     -212,U          member type of picolParser, via variable p
182C EDC9FF20         (          xyz.asm):05169                 STD     -224,U          variable prevtype
                      (          xyz.asm):05170         * Line xyz.c:784: function call: picolGetToken()
1830 30C9FF22         (          xyz.asm):05171                 LEAX    -222,U          variable p, declared at xyz.c:773
1834 3410             (          xyz.asm):05172                 PSHS    X               argument 1 of picolGetToken(): struct picolParser *
1836 1703CF           (          xyz.asm):05173                 LBSR    _picolGetToken
1839 3262             (          xyz.asm):05174                 LEAS    2,S
                      (          xyz.asm):05175         * Line xyz.c:785: if
183B 4F               (          xyz.asm):05176                 CLRA
183C C606             (          xyz.asm):05177                 LDB     #$06            decimal 6 signed
                      (          xyz.asm):05178         * optim: optimize16BitCompares
                      (          xyz.asm):05179         * optim: optimize16BitCompares
183E 10A3C9FF2C       (          xyz.asm):05180                 CMPD    -212,U          optim: optimize16BitCompares
1843 2603             (          xyz.asm):05181                 BNE     L00557          optim: optimize16BitCompares
                      (          xyz.asm):05182         * optim: condBranchOverUncondBranch
                      (          xyz.asm):05183         * Useless label L00556 removed
1845 160341           (          xyz.asm):05184                 LBRA    L00555          break
     1848             (          xyz.asm):05185         L00557  EQU     *               else
                      (          xyz.asm):05186         * Useless label L00558 removed
                      (          xyz.asm):05187         * Line xyz.c:786: assignment: =
                      (          xyz.asm):05188         * optim: optimizeStackOperations5
                      (          xyz.asm):05189         * optim: optimizeStackOperations5
                      (          xyz.asm):05190         * optim: optimizeStackOperations5
                      (          xyz.asm):05191         * optim: optimizeStackOperations4
                      (          xyz.asm):05192         * optim: optimizeStackOperations4
1848 ECC9FF2A         (          xyz.asm):05193                 LDD     -214,U          member end of picolParser, via variable p
184C A3C9FF28         (          xyz.asm):05194                 SUBD    -216,U          optim: optimizeStackOperations4
1850 C30001           (          xyz.asm):05195                 ADDD    #$01            optim: optimizeStackOperations5
1853 EDC9FF1E         (          xyz.asm):05196                 STD     -226,U
                      (          xyz.asm):05197         * Line xyz.c:787: if
                      (          xyz.asm):05198         * optim: storeLoad
1857 C30000           (          xyz.asm):05199                 ADDD    #0
185A 2C06             (          xyz.asm):05200                 BGE     L00560
                      (          xyz.asm):05201         * optim: condBranchOverUncondBranch
                      (          xyz.asm):05202         * Useless label L00559 removed
                      (          xyz.asm):05203         * Line xyz.c:787: assignment: =
185C 4F               (          xyz.asm):05204                 CLRA
185D 5F               (          xyz.asm):05205                 CLRB
185E EDC9FF1E         (          xyz.asm):05206                 STD     -226,U
     1862             (          xyz.asm):05207         L00560  EQU     *               else
                      (          xyz.asm):05208         * Useless label L00561 removed
                      (          xyz.asm):05209         * Line xyz.c:788: assignment: =
                      (          xyz.asm):05210         * Line xyz.c:788: function call: malloc()
1862 ECC9FF1E         (          xyz.asm):05211                 LDD     -226,U          variable tlen
1866 C30001           (          xyz.asm):05212                 ADDD    #$01            1
1869 3406             (          xyz.asm):05213                 PSHS    B,A             argument 1 of malloc(): int
186B 17EFDC           (          xyz.asm):05214                 LBSR    _malloc
186E 3262             (          xyz.asm):05215                 LEAS    2,S
1870 EDC9FF1C         (          xyz.asm):05216                 STD     -228,U
                      (          xyz.asm):05217         * Line xyz.c:789: function call: memcpy()
1874 ECC9FF1E         (          xyz.asm):05218                 LDD     -226,U          variable tlen, declared at xyz.c:782
1878 3406             (          xyz.asm):05219                 PSHS    B,A             argument 3 of memcpy(): int
187A ECC9FF28         (          xyz.asm):05220                 LDD     -216,U          member start of picolParser, via variable p
187E 3406             (          xyz.asm):05221                 PSHS    B,A             argument 2 of memcpy(): char *
1880 ECC9FF1C         (          xyz.asm):05222                 LDD     -228,U          variable t, declared at xyz.c:781
1884 3406             (          xyz.asm):05223                 PSHS    B,A             argument 1 of memcpy(): char *
1886 17F11E           (          xyz.asm):05224                 LBSR    _memcpy
1889 3266             (          xyz.asm):05225                 LEAS    6,S
                      (          xyz.asm):05226         * Line xyz.c:790: assignment: =
188B 4F               (          xyz.asm):05227                 CLRA
                      (          xyz.asm):05228         * CLRB  optim: optimizeStackOperations1
                      (          xyz.asm):05229         * PSHS B optim: optimizeStackOperations1
188C AEC9FF1C         (          xyz.asm):05230                 LDX     -228,U          pointer t
1890 ECC9FF1E         (          xyz.asm):05231                 LDD     -226,U          variable tlen
1894 308B             (          xyz.asm):05232                 LEAX    D,X             add byte offset
1896 C600             (          xyz.asm):05233                 LDB     #0              optim: optimizeStackOperations1
1898 E784             (          xyz.asm):05234                 STB     ,X
                      (          xyz.asm):05235         * Line xyz.c:791: if
                      (          xyz.asm):05236         * LDD #$03 optim: optimizeStackOperations1
                      (          xyz.asm):05237         * PSHS B,A optim: optimizeStackOperations1
189A ECC9FF2C         (          xyz.asm):05238                 LDD     -212,U          member type of picolParser, via variable p
189E 10830003         (          xyz.asm):05239                 CMPD    #3              optim: optimizeStackOperations1
18A2 10260071         (          xyz.asm):05240                 LBNE    L00563
                      (          xyz.asm):05241         * optim: condBranchOverUncondBranch
                      (          xyz.asm):05242         * Useless label L00562 removed
                      (          xyz.asm):05243         * Line xyz.c:792: init of variable v
                      (          xyz.asm):05244         * Line xyz.c:792: function call: picolGetVar()
18A6 ECC9FF1C         (          xyz.asm):05245                 LDD     -228,U          variable t, declared at xyz.c:781
18AA 3406             (          xyz.asm):05246                 PSHS    B,A             argument 2 of picolGetVar(): char *
18AC EC44             (          xyz.asm):05247                 LDD     4,U             variable i, declared at xyz.c:772
18AE 3406             (          xyz.asm):05248                 PSHS    B,A             argument 1 of picolGetVar(): struct picolInterp *
18B0 170446           (          xyz.asm):05249                 LBSR    _picolGetVar
18B3 3264             (          xyz.asm):05250                 LEAS    4,S
18B5 EDC9FF1A         (          xyz.asm):05251                 STD     -230,U          variable v
                      (          xyz.asm):05252         * Line xyz.c:793: if
                      (          xyz.asm):05253         * optim: storeLoad
18B9 C30000           (          xyz.asm):05254                 ADDD    #0
18BC 263A             (          xyz.asm):05255                 BNE     L00565
                      (          xyz.asm):05256         * optim: branchToNextLocation
                      (          xyz.asm):05257         * Useless label L00564 removed
                      (          xyz.asm):05258         * Line xyz.c:794: function call: snprintf_s()
18BE ECC9FF1C         (          xyz.asm):05259                 LDD     -228,U          variable t, declared at xyz.c:781
18C2 3406             (          xyz.asm):05260                 PSHS    B,A             argument 4 of snprintf_s(): char *
18C4 308D139E         (          xyz.asm):05261                 LEAX    S00097,PCR      "No such variable \'%s\'"
                      (          xyz.asm):05262         * optim: optimizePshsOps
18C8 4F               (          xyz.asm):05263                 CLRA
18C9 C6C8             (          xyz.asm):05264                 LDB     #$C8            decimal 200 signed
18CB 3416             (          xyz.asm):05265                 PSHS    X,B,A           optim: optimizePshsOps
18CD 30C9FF36         (          xyz.asm):05266                 LEAX    -202,U          address of array errbuf
18D1 3410             (          xyz.asm):05267                 PSHS    X               argument 1 of snprintf_s(): char[]
18D3 171094           (          xyz.asm):05268                 LBSR    _snprintf_s
18D6 3268             (          xyz.asm):05269                 LEAS    8,S
                      (          xyz.asm):05270         * Line xyz.c:795: function call: free()
18D8 ECC9FF1C         (          xyz.asm):05271                 LDD     -228,U          variable t, declared at xyz.c:781
18DC 3406             (          xyz.asm):05272                 PSHS    B,A             argument 1 of free(): char *
18DE 17ED42           (          xyz.asm):05273                 LBSR    _free
18E1 3262             (          xyz.asm):05274                 LEAS    2,S
                      (          xyz.asm):05275         * Line xyz.c:796: function call: picolSetResult()
18E3 30C9FF36         (          xyz.asm):05276                 LEAX    -202,U          address of array errbuf
                      (          xyz.asm):05277         * optim: optimizePshsOps
18E7 EC44             (          xyz.asm):05278                 LDD     4,U             variable i, declared at xyz.c:772
18E9 3416             (          xyz.asm):05279                 PSHS    X,B,A           optim: optimizePshsOps
18EB 170DCD           (          xyz.asm):05280                 LBSR    _picolSetResult
18EE 3264             (          xyz.asm):05281                 LEAS    4,S
                      (          xyz.asm):05282         * Line xyz.c:797: assignment: =
18F0 4F               (          xyz.asm):05283                 CLRA
18F1 C601             (          xyz.asm):05284                 LDB     #$01            decimal 1 signed
18F3 ED5E             (          xyz.asm):05285                 STD     -2,U
                      (          xyz.asm):05286         * Line xyz.c:798: goto err
18F5 160291           (          xyz.asm):05287                 LBRA    L00049
     18F8             (          xyz.asm):05288         L00565  EQU     *               else
                      (          xyz.asm):05289         * Useless label L00566 removed
                      (          xyz.asm):05290         * Line xyz.c:800: function call: free()
18F8 ECC9FF1C         (          xyz.asm):05291                 LDD     -228,U          variable t, declared at xyz.c:781
18FC 3406             (          xyz.asm):05292                 PSHS    B,A             argument 1 of free(): char *
18FE 17ED22           (          xyz.asm):05293                 LBSR    _free
1901 3262             (          xyz.asm):05294                 LEAS    2,S
                      (          xyz.asm):05295         * Line xyz.c:801: assignment: =
                      (          xyz.asm):05296         * Line xyz.c:801: function call: strdup()
1903 AEC9FF1A         (          xyz.asm):05297                 LDX     -230,U          variable v
1907 EC02             (          xyz.asm):05298                 LDD     2,X             member val of picolVar
1909 3406             (          xyz.asm):05299                 PSHS    B,A             argument 1 of strdup(): char *
190B 17123C           (          xyz.asm):05300                 LBSR    _strdup
190E 3262             (          xyz.asm):05301                 LEAS    2,S
1910 EDC9FF1C         (          xyz.asm):05302                 STD     -228,U
1914 160066           (          xyz.asm):05303                 LBRA    L00567          jump over else clause
     1917             (          xyz.asm):05304         L00563  EQU     *               else
                      (          xyz.asm):05305         * Line xyz.c:802: if
1917 4F               (          xyz.asm):05306                 CLRA
1918 C602             (          xyz.asm):05307                 LDB     #$02            decimal 2 signed
                      (          xyz.asm):05308         * optim: optimize16BitCompares
                      (          xyz.asm):05309         * optim: optimize16BitCompares
191A 10A3C9FF2C       (          xyz.asm):05310                 CMPD    -212,U          optim: optimize16BitCompares
191F 2634             (          xyz.asm):05311                 BNE     L00569          optim: optimize16BitCompares
                      (          xyz.asm):05312         * optim: condBranchOverUncondBranch
                      (          xyz.asm):05313         * Useless label L00568 removed
                      (          xyz.asm):05314         * Line xyz.c:803: assignment: =
                      (          xyz.asm):05315         * Line xyz.c:803: function call: picolEval()
1921 ECC9FF1C         (          xyz.asm):05316                 LDD     -228,U          variable t, declared at xyz.c:781
1925 3406             (          xyz.asm):05317                 PSHS    B,A             argument 2 of picolEval(): char *
1927 EC44             (          xyz.asm):05318                 LDD     4,U             variable i, declared at xyz.c:772
1929 3406             (          xyz.asm):05319                 PSHS    B,A             argument 1 of picolEval(): struct picolInterp *
192B 17FEC2           (          xyz.asm):05320                 LBSR    _picolEval
192E 3264             (          xyz.asm):05321                 LEAS    4,S
1930 ED5E             (          xyz.asm):05322                 STD     -2,U
                      (          xyz.asm):05323         * Line xyz.c:804: function call: free()
1932 ECC9FF1C         (          xyz.asm):05324                 LDD     -228,U          variable t, declared at xyz.c:781
1936 3406             (          xyz.asm):05325                 PSHS    B,A             argument 1 of free(): char *
1938 17ECE8           (          xyz.asm):05326                 LBSR    _free
193B 3262             (          xyz.asm):05327                 LEAS    2,S
                      (          xyz.asm):05328         * Line xyz.c:805: if
193D EC5E             (          xyz.asm):05329                 LDD     -2,U            variable retcode, declared at xyz.c:777
                      (          xyz.asm):05330         * optim: loadCmpZeroBeqOrBne
193F 2703             (          xyz.asm):05331                 BEQ     L00571
                      (          xyz.asm):05332         * optim: condBranchOverUncondBranch
                      (          xyz.asm):05333         * Useless label L00570 removed
                      (          xyz.asm):05334         * Line xyz.c:805: goto err
1941 160245           (          xyz.asm):05335                 LBRA    L00049
     1944             (          xyz.asm):05336         L00571  EQU     *               else
                      (          xyz.asm):05337         * Useless label L00572 removed
                      (          xyz.asm):05338         * Line xyz.c:806: assignment: =
                      (          xyz.asm):05339         * Line xyz.c:806: function call: strdup()
1944 AE44             (          xyz.asm):05340                 LDX     4,U             variable i
1946 EC06             (          xyz.asm):05341                 LDD     6,X             member result of picolInterp
1948 3406             (          xyz.asm):05342                 PSHS    B,A             argument 1 of strdup(): char *
194A 1711FD           (          xyz.asm):05343                 LBSR    _strdup
194D 3262             (          xyz.asm):05344                 LEAS    2,S
194F EDC9FF1C         (          xyz.asm):05345                 STD     -228,U
1953 2028             (          xyz.asm):05346                 BRA     L00573          jump over else clause
     1955             (          xyz.asm):05347         L00569  EQU     *               else
                      (          xyz.asm):05348         * Line xyz.c:807: if
1955 ECC9FF2C         (          xyz.asm):05349                 LDD     -212,U          member type of picolParser, via variable p
                      (          xyz.asm):05350         * optim: loadCmpZeroBeqOrBne
1959 2602             (          xyz.asm):05351                 BNE     L00575
                      (          xyz.asm):05352         * optim: condBranchOverUncondBranch
                      (          xyz.asm):05353         * Useless label L00574 removed
195B 2020             (          xyz.asm):05354                 BRA     L00576          jump over else clause
     195D             (          xyz.asm):05355         L00575  EQU     *               else
                      (          xyz.asm):05356         * Line xyz.c:809: if
195D 4F               (          xyz.asm):05357                 CLRA
195E C604             (          xyz.asm):05358                 LDB     #$04            decimal 4 signed
                      (          xyz.asm):05359         * optim: optimize16BitCompares
                      (          xyz.asm):05360         * optim: optimize16BitCompares
1960 10A3C9FF2C       (          xyz.asm):05361                 CMPD    -212,U          optim: optimize16BitCompares
1965 2616             (          xyz.asm):05362                 BNE     L00578          optim: optimize16BitCompares
                      (          xyz.asm):05363         * optim: condBranchOverUncondBranch
                      (          xyz.asm):05364         * Useless label L00577 removed
                      (          xyz.asm):05365         * Line xyz.c:810: assignment: =
1967 ECC9FF2C         (          xyz.asm):05366                 LDD     -212,U          member type of picolParser, via variable p
196B EDC9FF20         (          xyz.asm):05367                 STD     -224,U
                      (          xyz.asm):05368         * Line xyz.c:811: function call: free()
196F ECC9FF1C         (          xyz.asm):05369                 LDD     -228,U          variable t, declared at xyz.c:781
1973 3406             (          xyz.asm):05370                 PSHS    B,A             argument 1 of free(): char *
1975 17ECAB           (          xyz.asm):05371                 LBSR    _free
1978 3262             (          xyz.asm):05372                 LEAS    2,S
197A 160209           (          xyz.asm):05373                 LBRA    L00554          continue
     197D             (          xyz.asm):05374         L00578  EQU     *               else
                      (          xyz.asm):05375         * Useless label L00579 removed
     197D             (          xyz.asm):05376         L00576  EQU     *               end if
     197D             (          xyz.asm):05377         L00573  EQU     *               end if
     197D             (          xyz.asm):05378         L00567  EQU     *               end if
                      (          xyz.asm):05379         * Line xyz.c:815: if
197D 4F               (          xyz.asm):05380                 CLRA
197E C605             (          xyz.asm):05381                 LDB     #$05            decimal 5 signed
                      (          xyz.asm):05382         * optim: optimize16BitCompares
                      (          xyz.asm):05383         * optim: optimize16BitCompares
1980 10A3C9FF2C       (          xyz.asm):05384                 CMPD    -212,U          optim: optimize16BitCompares
1985 102600D9         (          xyz.asm):05385                 LBNE    L00581          optim: optimize16BitCompares
                      (          xyz.asm):05386         * optim: condBranchOverUncondBranch
                      (          xyz.asm):05387         * Useless label L00580 removed
                      (          xyz.asm):05388         * Line xyz.c:817: function call: free()
1989 ECC9FF1C         (          xyz.asm):05389                 LDD     -228,U          variable t, declared at xyz.c:781
198D 3406             (          xyz.asm):05390                 PSHS    B,A             argument 1 of free(): char *
198F 17EC91           (          xyz.asm):05391                 LBSR    _free
1992 3262             (          xyz.asm):05392                 LEAS    2,S
                      (          xyz.asm):05393         * Line xyz.c:818: assignment: =
1994 ECC9FF2C         (          xyz.asm):05394                 LDD     -212,U          member type of picolParser, via variable p
1998 EDC9FF20         (          xyz.asm):05395                 STD     -224,U
                      (          xyz.asm):05396         * Line xyz.c:819: if
199C ECC9FF30         (          xyz.asm):05397                 LDD     -208,U          variable argc, declared at xyz.c:774
                      (          xyz.asm):05398         * optim: loadCmpZeroBeqOrBne
19A0 10270073         (          xyz.asm):05399                 LBEQ    L00583
                      (          xyz.asm):05400         * optim: condBranchOverUncondBranch
                      (          xyz.asm):05401         * Useless label L00582 removed
                      (          xyz.asm):05402         * Line xyz.c:820: if
                      (          xyz.asm):05403         * Line xyz.c:820: assignment: =
                      (          xyz.asm):05404         * Line xyz.c:820: function call: picolGetCommand()
19A4 AEC9FF34         (          xyz.asm):05405                 LDX     -204,U          get pointer value
19A8 EC84             (          xyz.asm):05406                 LDD     ,X
19AA 3406             (          xyz.asm):05407                 PSHS    B,A             argument 2 of picolGetCommand(): char *
19AC EC44             (          xyz.asm):05408                 LDD     4,U             variable i, declared at xyz.c:772
19AE 3406             (          xyz.asm):05409                 PSHS    B,A             argument 1 of picolGetCommand(): struct picolInterp *
19B0 17021A           (          xyz.asm):05410                 LBSR    _picolGetCommand
19B3 3264             (          xyz.asm):05411                 LEAS    4,S
19B5 EDC9FF1A         (          xyz.asm):05412                 STD     -230,U
19B9 C30000           (          xyz.asm):05413                 ADDD    #0
19BC 262F             (          xyz.asm):05414                 BNE     L00585
                      (          xyz.asm):05415         * optim: condBranchOverUncondBranch
                      (          xyz.asm):05416         * Useless label L00584 removed
                      (          xyz.asm):05417         * Line xyz.c:821: function call: snprintf_s()
                      (          xyz.asm):05418         * optim: optimizeIndexedX
19BE ECD9FF34         (          xyz.asm):05419                 LDD     [-204,U]        optim: optimizeIndexedX
19C2 3406             (          xyz.asm):05420                 PSHS    B,A             argument 4 of snprintf_s(): char *
19C4 308D12B4         (          xyz.asm):05421                 LEAX    S00098,PCR      "No such command \'%s\'"
                      (          xyz.asm):05422         * optim: optimizePshsOps
19C8 4F               (          xyz.asm):05423                 CLRA
19C9 C6C8             (          xyz.asm):05424                 LDB     #$C8            decimal 200 signed
19CB 3416             (          xyz.asm):05425                 PSHS    X,B,A           optim: optimizePshsOps
19CD 30C9FF36         (          xyz.asm):05426                 LEAX    -202,U          address of array errbuf
19D1 3410             (          xyz.asm):05427                 PSHS    X               argument 1 of snprintf_s(): char[]
19D3 170F94           (          xyz.asm):05428                 LBSR    _snprintf_s
19D6 3268             (          xyz.asm):05429                 LEAS    8,S
                      (          xyz.asm):05430         * Line xyz.c:822: function call: picolSetResult()
19D8 30C9FF36         (          xyz.asm):05431                 LEAX    -202,U          address of array errbuf
                      (          xyz.asm):05432         * optim: optimizePshsOps
19DC EC44             (          xyz.asm):05433                 LDD     4,U             variable i, declared at xyz.c:772
19DE 3416             (          xyz.asm):05434                 PSHS    X,B,A           optim: optimizePshsOps
19E0 170CD8           (          xyz.asm):05435                 LBSR    _picolSetResult
19E3 3264             (          xyz.asm):05436                 LEAS    4,S
                      (          xyz.asm):05437         * Line xyz.c:823: assignment: =
19E5 4F               (          xyz.asm):05438                 CLRA
19E6 C601             (          xyz.asm):05439                 LDB     #$01            decimal 1 signed
19E8 ED5E             (          xyz.asm):05440                 STD     -2,U
                      (          xyz.asm):05441         * Line xyz.c:824: goto err
19EA 16019C           (          xyz.asm):05442                 LBRA    L00049
     19ED             (          xyz.asm):05443         L00585  EQU     *               else
                      (          xyz.asm):05444         * Useless label L00586 removed
                      (          xyz.asm):05445         * Line xyz.c:826: assignment: =
                      (          xyz.asm):05446         * Line xyz.c:826: function call through pointer
19ED AEC9FF1A         (          xyz.asm):05447                 LDX     -230,U          variable c
19F1 AE04             (          xyz.asm):05448                 LDX     4,X             optim: transformPshsDPshsD
19F3 3410             (          xyz.asm):05449                 PSHS    X               optim: transformPshsDPshsD
19F5 AEC9FF34         (          xyz.asm):05450                 LDX     -204,U          optim: transformPshsDPshsD
19F9 3410             (          xyz.asm):05451                 PSHS    X               optim: transformPshsDPshsD
19FB AEC9FF30         (          xyz.asm):05452                 LDX     -208,U          optim: transformPshsDPshsD
                      (          xyz.asm):05453         * optim: optimizePshsOps
19FF EC44             (          xyz.asm):05454                 LDD     4,U             variable i, declared at xyz.c:772
1A01 3416             (          xyz.asm):05455                 PSHS    X,B,A           optim: optimizePshsOps
1A03 AEC9FF1A         (          xyz.asm):05456                 LDX     -230,U          variable c
1A07 AE02             (          xyz.asm):05457                 LDX     2,X             optim: removeTfrDX
                      (          xyz.asm):05458         * optim: removeTfrDX
1A09 AD84             (          xyz.asm):05459                 JSR     ,X
1A0B 3268             (          xyz.asm):05460                 LEAS    8,S
1A0D ED5E             (          xyz.asm):05461                 STD     -2,U
                      (          xyz.asm):05462         * Line xyz.c:827: if
                      (          xyz.asm):05463         * optim: storeLoad
1A0F C30000           (          xyz.asm):05464                 ADDD    #0
1A12 2703             (          xyz.asm):05465                 BEQ     L00588
                      (          xyz.asm):05466         * optim: condBranchOverUncondBranch
                      (          xyz.asm):05467         * Useless label L00587 removed
                      (          xyz.asm):05468         * Line xyz.c:827: goto err
1A14 160172           (          xyz.asm):05469                 LBRA    L00049
     1A17             (          xyz.asm):05470         L00588  EQU     *               else
                      (          xyz.asm):05471         * Useless label L00589 removed
     1A17             (          xyz.asm):05472         L00583  EQU     *               else
                      (          xyz.asm):05473         * Useless label L00590 removed
                      (          xyz.asm):05474         * Line xyz.c:830: for init
                      (          xyz.asm):05475         * Line xyz.c:830: assignment: =
1A17 4F               (          xyz.asm):05476                 CLRA
1A18 5F               (          xyz.asm):05477                 CLRB
1A19 EDC9FF32         (          xyz.asm):05478                 STD     -206,U
1A1D 2020             (          xyz.asm):05479                 BRA     L00592          jump to for condition
     1A1F             (          xyz.asm):05480         L00591  EQU     *
                      (          xyz.asm):05481         * Line xyz.c:830: for body
                      (          xyz.asm):05482         * Line xyz.c:830: function call: free()
1A1F AEC9FF34         (          xyz.asm):05483                 LDX     -204,U          pointer argv
1A23 ECC9FF32         (          xyz.asm):05484                 LDD     -206,U          variable j
1A27 58               (          xyz.asm):05485                 LSLB
1A28 49               (          xyz.asm):05486                 ROLA
1A29 308B             (          xyz.asm):05487                 LEAX    D,X             add byte offset
1A2B EC84             (          xyz.asm):05488                 LDD     ,X              get r-value
1A2D 3406             (          xyz.asm):05489                 PSHS    B,A             argument 1 of free(): char *
1A2F 17EBF1           (          xyz.asm):05490                 LBSR    _free
1A32 3262             (          xyz.asm):05491                 LEAS    2,S
                      (          xyz.asm):05492         * Useless label L00593 removed
                      (          xyz.asm):05493         * Line xyz.c:830: for increment(s)
1A34 ECC9FF32         (          xyz.asm):05494                 LDD     -206,U
1A38 C30001           (          xyz.asm):05495                 ADDD    #1
1A3B EDC9FF32         (          xyz.asm):05496                 STD     -206,U
     1A3F             (          xyz.asm):05497         L00592  EQU     *
                      (          xyz.asm):05498         * Line xyz.c:830: for condition
1A3F ECC9FF32         (          xyz.asm):05499                 LDD     -206,U          variable j
1A43 10A3C9FF30       (          xyz.asm):05500                 CMPD    -208,U          variable argc
1A48 2DD5             (          xyz.asm):05501                 BLT     L00591
                      (          xyz.asm):05502         * optim: branchToNextLocation
                      (          xyz.asm):05503         * Useless label L00594 removed
                      (          xyz.asm):05504         * Line xyz.c:831: function call: free()
1A4A ECC9FF34         (          xyz.asm):05505                 LDD     -204,U          variable argv, declared at xyz.c:775
1A4E 3406             (          xyz.asm):05506                 PSHS    B,A             argument 1 of free(): char **
1A50 17EBD0           (          xyz.asm):05507                 LBSR    _free
1A53 3262             (          xyz.asm):05508                 LEAS    2,S
                      (          xyz.asm):05509         * Line xyz.c:832: assignment: =
1A55 4F               (          xyz.asm):05510                 CLRA
1A56 5F               (          xyz.asm):05511                 CLRB
1A57 EDC9FF34         (          xyz.asm):05512                 STD     -204,U
                      (          xyz.asm):05513         * Line xyz.c:833: assignment: =
                      (          xyz.asm):05514         * optim: stripExtraClrA_B
                      (          xyz.asm):05515         * optim: stripExtraClrA_B
1A5B EDC9FF30         (          xyz.asm):05516                 STD     -208,U
1A5F 160124           (          xyz.asm):05517                 LBRA    L00554          continue
     1A62             (          xyz.asm):05518         L00581  EQU     *               else
                      (          xyz.asm):05519         * Useless label L00595 removed
                      (          xyz.asm):05520         * Line xyz.c:837: if
1A62 ECC9FF20         (          xyz.asm):05521                 LDD     -224,U          variable prevtype
1A66 10830004         (          xyz.asm):05522                 CMPD    #$04
1A6A 270A             (          xyz.asm):05523                 BEQ     L00596
                      (          xyz.asm):05524         * optim: branchToNextLocation
                      (          xyz.asm):05525         * Useless label L00598 removed
1A6C ECC9FF20         (          xyz.asm):05526                 LDD     -224,U          variable prevtype
1A70 10830005         (          xyz.asm):05527                 CMPD    #$05
1A74 2647             (          xyz.asm):05528                 BNE     L00597
                      (          xyz.asm):05529         * optim: condBranchOverUncondBranch
     1A76             (          xyz.asm):05530         L00596  EQU     *               then
                      (          xyz.asm):05531         * Line xyz.c:838: assignment: =
                      (          xyz.asm):05532         * Line xyz.c:838: function call: realloc()
1A76 4F               (          xyz.asm):05533                 CLRA
1A77 C602             (          xyz.asm):05534                 LDB     #$02            constant expression: 2 decimal, unsigned
1A79 1F01             (          xyz.asm):05535                 TFR     D,X             optim: stripExtraPulsX
1A7B ECC9FF30         (          xyz.asm):05536                 LDD     -208,U          variable argc
1A7F C30001           (          xyz.asm):05537                 ADDD    #$01            1
                      (          xyz.asm):05538         * optim: stripExtraPulsX
1A82 17137B           (          xyz.asm):05539                 LBSR    MUL16
1A85 3406             (          xyz.asm):05540                 PSHS    B,A             argument 2 of realloc(): unsigned int
1A87 ECC9FF34         (          xyz.asm):05541                 LDD     -204,U          variable argv, declared at xyz.c:775
1A8B 3406             (          xyz.asm):05542                 PSHS    B,A             argument 1 of realloc(): char **
1A8D 170DCF           (          xyz.asm):05543                 LBSR    _realloc
1A90 3264             (          xyz.asm):05544                 LEAS    4,S
1A92 EDC9FF34         (          xyz.asm):05545                 STD     -204,U
                      (          xyz.asm):05546         * Line xyz.c:839: assignment: =
1A96 ECC9FF1C         (          xyz.asm):05547                 LDD     -228,U          variable t, declared at xyz.c:781
1A9A 3406             (          xyz.asm):05548                 PSHS    B,A
1A9C AEC9FF34         (          xyz.asm):05549                 LDX     -204,U          pointer argv
1AA0 ECC9FF30         (          xyz.asm):05550                 LDD     -208,U          variable argc
1AA4 58               (          xyz.asm):05551                 LSLB
1AA5 49               (          xyz.asm):05552                 ROLA
1AA6 308B             (          xyz.asm):05553                 LEAX    D,X             add byte offset
1AA8 3506             (          xyz.asm):05554                 PULS    A,B             retrieve value to store
1AAA ED84             (          xyz.asm):05555                 STD     ,X
1AAC 30C9FF30         (          xyz.asm):05556                 LEAX    -208,U          variable argc, declared at xyz.c:774
1AB0 EC84             (          xyz.asm):05557                 LDD     ,X
1AB2 C30001           (          xyz.asm):05558                 ADDD    #1
1AB5 ED84             (          xyz.asm):05559                 STD     ,X
1AB7 830001           (          xyz.asm):05560                 SUBD    #1              post increment yields initial value
1ABA 1600C1           (          xyz.asm):05561                 LBRA    L00599          jump over else clause
     1ABD             (          xyz.asm):05562         L00597  EQU     *               else
                      (          xyz.asm):05563         * Line xyz.c:842: init of variable oldlen
                      (          xyz.asm):05564         * Line xyz.c:842: function call: strlen()
1ABD AEC9FF34         (          xyz.asm):05565                 LDX     -204,U          pointer argv
                      (          xyz.asm):05566         * optim: stripExtraPulsX
1AC1 ECC9FF30         (          xyz.asm):05567                 LDD     -208,U          variable argc
1AC5 C3FFFF           (          xyz.asm):05568                 ADDD    #$FFFF          65535
1AC8 58               (          xyz.asm):05569                 LSLB
1AC9 49               (          xyz.asm):05570                 ROLA
                      (          xyz.asm):05571         * optim: stripExtraPulsX
1ACA 308B             (          xyz.asm):05572                 LEAX    D,X             add byte offset
1ACC EC84             (          xyz.asm):05573                 LDD     ,X              get r-value
1ACE 3406             (          xyz.asm):05574                 PSHS    B,A             argument 1 of strlen(): char *
1AD0 1710AC           (          xyz.asm):05575                 LBSR    _strlen
1AD3 3262             (          xyz.asm):05576                 LEAS    2,S
1AD5 EDC9FF18         (          xyz.asm):05577                 STD     -232,U          variable oldlen
                      (          xyz.asm):05578         * Line xyz.c:842: init of variable tlen
                      (          xyz.asm):05579         * Line xyz.c:842: function call: strlen()
1AD9 ECC9FF1C         (          xyz.asm):05580                 LDD     -228,U          variable t, declared at xyz.c:781
1ADD 3406             (          xyz.asm):05581                 PSHS    B,A             argument 1 of strlen(): char *
1ADF 17109D           (          xyz.asm):05582                 LBSR    _strlen
1AE2 3262             (          xyz.asm):05583                 LEAS    2,S
1AE4 EDC9FF1A         (          xyz.asm):05584                 STD     -230,U          variable tlen
                      (          xyz.asm):05585         * Line xyz.c:843: assignment: =
                      (          xyz.asm):05586         * Line xyz.c:843: function call: realloc()
1AE8 8E0001           (          xyz.asm):05587                 LDX     #$01            optim: transformPshsDPshsD
1AEB 3410             (          xyz.asm):05588                 PSHS    X               optim: transformPshsDPshsD
                      (          xyz.asm):05589         * optim: optimizeStackOperations4
                      (          xyz.asm):05590         * optim: optimizeStackOperations4
1AED ECC9FF18         (          xyz.asm):05591                 LDD     -232,U          variable oldlen, declared at xyz.c:842
1AF1 E3C9FF1A         (          xyz.asm):05592                 ADDD    -230,U          optim: optimizeStackOperations4
1AF5 E3E1             (          xyz.asm):05593                 ADDD    ,S++
1AF7 3406             (          xyz.asm):05594                 PSHS    B,A             argument 2 of realloc(): int
1AF9 AEC9FF34         (          xyz.asm):05595                 LDX     -204,U          pointer argv
                      (          xyz.asm):05596         * optim: stripExtraPulsX
1AFD ECC9FF30         (          xyz.asm):05597                 LDD     -208,U          variable argc
1B01 C3FFFF           (          xyz.asm):05598                 ADDD    #$FFFF          65535
1B04 58               (          xyz.asm):05599                 LSLB
1B05 49               (          xyz.asm):05600                 ROLA
                      (          xyz.asm):05601         * optim: stripExtraPulsX
1B06 308B             (          xyz.asm):05602                 LEAX    D,X             add byte offset
1B08 EC84             (          xyz.asm):05603                 LDD     ,X              get r-value
1B0A 3406             (          xyz.asm):05604                 PSHS    B,A             argument 1 of realloc(): char *
1B0C 170D50           (          xyz.asm):05605                 LBSR    _realloc
1B0F 3264             (          xyz.asm):05606                 LEAS    4,S
1B11 3406             (          xyz.asm):05607                 PSHS    B,A
1B13 AEC9FF34         (          xyz.asm):05608                 LDX     -204,U          pointer argv
                      (          xyz.asm):05609         * optim: stripExtraPulsX
1B17 ECC9FF30         (          xyz.asm):05610                 LDD     -208,U          variable argc
1B1B C3FFFF           (          xyz.asm):05611                 ADDD    #$FFFF          65535
1B1E 58               (          xyz.asm):05612                 LSLB
1B1F 49               (          xyz.asm):05613                 ROLA
                      (          xyz.asm):05614         * optim: stripExtraPulsX
1B20 308B             (          xyz.asm):05615                 LEAX    D,X             add byte offset
1B22 3506             (          xyz.asm):05616                 PULS    A,B             retrieve value to store
1B24 ED84             (          xyz.asm):05617                 STD     ,X
                      (          xyz.asm):05618         * Line xyz.c:844: function call: memcpy()
1B26 AEC9FF1A         (          xyz.asm):05619                 LDX     -230,U          optim: transformPshsDPshsD
1B2A 3410             (          xyz.asm):05620                 PSHS    X               optim: transformPshsDPshsD
1B2C AEC9FF1C         (          xyz.asm):05621                 LDX     -228,U          optim: transformPshsDPshsD
                      (          xyz.asm):05622         * optim: optimizePshsOps
1B30 ECC9FF18         (          xyz.asm):05623                 LDD     -232,U          variable oldlen, declared at xyz.c:842
1B34 3416             (          xyz.asm):05624                 PSHS    X,B,A           optim: optimizePshsOps
1B36 AEC9FF34         (          xyz.asm):05625                 LDX     -204,U          pointer argv
                      (          xyz.asm):05626         * optim: stripExtraPulsX
1B3A ECC9FF30         (          xyz.asm):05627                 LDD     -208,U          variable argc
1B3E C3FFFF           (          xyz.asm):05628                 ADDD    #$FFFF          65535
1B41 58               (          xyz.asm):05629                 LSLB
1B42 49               (          xyz.asm):05630                 ROLA
                      (          xyz.asm):05631         * optim: stripExtraPulsX
1B43 308B             (          xyz.asm):05632                 LEAX    D,X             add byte offset
1B45 EC84             (          xyz.asm):05633                 LDD     ,X              get r-value
1B47 E3E1             (          xyz.asm):05634                 ADDD    ,S++
1B49 3406             (          xyz.asm):05635                 PSHS    B,A             argument 1 of memcpy(): char *
1B4B 17EE59           (          xyz.asm):05636                 LBSR    _memcpy
1B4E 3266             (          xyz.asm):05637                 LEAS    6,S
                      (          xyz.asm):05638         * Line xyz.c:845: assignment: =
1B50 4F               (          xyz.asm):05639                 CLRA
1B51 5F               (          xyz.asm):05640                 CLRB
1B52 3404             (          xyz.asm):05641                 PSHS    B
1B54 AEC9FF34         (          xyz.asm):05642                 LDX     -204,U          pointer argv
                      (          xyz.asm):05643         * optim: stripExtraPulsX
1B58 ECC9FF30         (          xyz.asm):05644                 LDD     -208,U          variable argc
1B5C C3FFFF           (          xyz.asm):05645                 ADDD    #$FFFF          65535
1B5F 58               (          xyz.asm):05646                 LSLB
1B60 49               (          xyz.asm):05647                 ROLA
                      (          xyz.asm):05648         * optim: stripExtraPulsX
1B61 308B             (          xyz.asm):05649                 LEAX    D,X             add byte offset
1B63 AE84             (          xyz.asm):05650                 LDX     ,X              optim: removeTfrDX
                      (          xyz.asm):05651         * optim: removeTfrDX
                      (          xyz.asm):05652         * optim: stripExtraPulsX
                      (          xyz.asm):05653         * optim: optimizeStackOperations4
                      (          xyz.asm):05654         * optim: optimizeStackOperations4
1B65 ECC9FF18         (          xyz.asm):05655                 LDD     -232,U          variable oldlen, declared at xyz.c:842
1B69 E3C9FF1A         (          xyz.asm):05656                 ADDD    -230,U          optim: optimizeStackOperations4
                      (          xyz.asm):05657         * optim: stripExtraPulsX
1B6D 308B             (          xyz.asm):05658                 LEAX    D,X             add byte offset
1B6F E6E0             (          xyz.asm):05659                 LDB     ,S+
1B71 E784             (          xyz.asm):05660                 STB     ,X
                      (          xyz.asm):05661         * Line xyz.c:846: function call: free()
1B73 ECC9FF1C         (          xyz.asm):05662                 LDD     -228,U          variable t, declared at xyz.c:781
1B77 3406             (          xyz.asm):05663                 PSHS    B,A             argument 1 of free(): char *
1B79 17EAA7           (          xyz.asm):05664                 LBSR    _free
1B7C 3262             (          xyz.asm):05665                 LEAS    2,S
     1B7E             (          xyz.asm):05666         L00599  EQU     *               end if
                      (          xyz.asm):05667         * Line xyz.c:848: assignment: =
1B7E ECC9FF2C         (          xyz.asm):05668                 LDD     -212,U          member type of picolParser, via variable p
1B82 EDC9FF20         (          xyz.asm):05669                 STD     -224,U
     1B86             (          xyz.asm):05670         L00554  EQU     *               while condition at xyz.c:780
1B86 16FC9F           (          xyz.asm):05671                 LBRA    L00553          go to start of while body
     1B89             (          xyz.asm):05672         L00555  EQU     *               after end of while starting at xyz.c:780
                      (          xyz.asm):05673         * Line xyz.c:851: labeled statement
     1B89             (          xyz.asm):05674         L00049  EQU     *               label err, declared at xyz.c:850
                      (          xyz.asm):05675         * Line xyz.c:851: for init
                      (          xyz.asm):05676         * Line xyz.c:851: assignment: =
1B89 4F               (          xyz.asm):05677                 CLRA
1B8A 5F               (          xyz.asm):05678                 CLRB
1B8B EDC9FF32         (          xyz.asm):05679                 STD     -206,U
1B8F 2020             (          xyz.asm):05680                 BRA     L00601          jump to for condition
     1B91             (          xyz.asm):05681         L00600  EQU     *
                      (          xyz.asm):05682         * Line xyz.c:851: for body
                      (          xyz.asm):05683         * Line xyz.c:851: function call: free()
1B91 AEC9FF34         (          xyz.asm):05684                 LDX     -204,U          pointer argv
1B95 ECC9FF32         (          xyz.asm):05685                 LDD     -206,U          variable j
1B99 58               (          xyz.asm):05686                 LSLB
1B9A 49               (          xyz.asm):05687                 ROLA
1B9B 308B             (          xyz.asm):05688                 LEAX    D,X             add byte offset
1B9D EC84             (          xyz.asm):05689                 LDD     ,X              get r-value
1B9F 3406             (          xyz.asm):05690                 PSHS    B,A             argument 1 of free(): char *
1BA1 17EA7F           (          xyz.asm):05691                 LBSR    _free
1BA4 3262             (          xyz.asm):05692                 LEAS    2,S
                      (          xyz.asm):05693         * Useless label L00602 removed
                      (          xyz.asm):05694         * Line xyz.c:851: for increment(s)
1BA6 ECC9FF32         (          xyz.asm):05695                 LDD     -206,U
1BAA C30001           (          xyz.asm):05696                 ADDD    #1
1BAD EDC9FF32         (          xyz.asm):05697                 STD     -206,U
     1BB1             (          xyz.asm):05698         L00601  EQU     *
                      (          xyz.asm):05699         * Line xyz.c:851: for condition
1BB1 ECC9FF32         (          xyz.asm):05700                 LDD     -206,U          variable j
1BB5 10A3C9FF30       (          xyz.asm):05701                 CMPD    -208,U          variable argc
1BBA 2DD5             (          xyz.asm):05702                 BLT     L00600
                      (          xyz.asm):05703         * optim: branchToNextLocation
                      (          xyz.asm):05704         * Useless label L00603 removed
                      (          xyz.asm):05705         * Line xyz.c:852: function call: free()
1BBC ECC9FF34         (          xyz.asm):05706                 LDD     -204,U          variable argv, declared at xyz.c:775
1BC0 3406             (          xyz.asm):05707                 PSHS    B,A             argument 1 of free(): char **
1BC2 17EA5E           (          xyz.asm):05708                 LBSR    _free
1BC5 3262             (          xyz.asm):05709                 LEAS    2,S
                      (          xyz.asm):05710         * Line xyz.c:853: return with value
1BC7 EC5E             (          xyz.asm):05711                 LDD     -2,U            variable retcode, declared at xyz.c:777
                      (          xyz.asm):05712         * optim: branchToNextLocation
                      (          xyz.asm):05713         * Useless label L00050 removed
1BC9 32C4             (          xyz.asm):05714                 LEAS    ,U
1BCB 35C0             (          xyz.asm):05715                 PULS    U,PC
                      (          xyz.asm):05716         * END FUNCTION picolEval(): defined at xyz.c:772
     1BCD             (          xyz.asm):05717         funcend_picolEval       EQU *
     03DD             (          xyz.asm):05718         funcsize_picolEval      EQU     funcend_picolEval-_picolEval
                      (          xyz.asm):05719         
                      (          xyz.asm):05720         
                      (          xyz.asm):05721         *******************************************************************************
                      (          xyz.asm):05722         
                      (          xyz.asm):05723         * FUNCTION picolGetCommand(): defined at xyz.c:745
     1BCD             (          xyz.asm):05724         _picolGetCommand        EQU     *
1BCD 3440             (          xyz.asm):05725                 PSHS    U
1BCF 170E7A           (          xyz.asm):05726                 LBSR    _stkcheck
1BD2 FFBE             (          xyz.asm):05727                 FDB     -66             argument for _stkcheck
1BD4 33E4             (          xyz.asm):05728                 LEAU    ,S
1BD6 327E             (          xyz.asm):05729                 LEAS    -2,S
                      (          xyz.asm):05730         * Formal parameters and locals:
                      (          xyz.asm):05731         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):05732         *   name: const char *; 2 bytes at 6,U
                      (          xyz.asm):05733         *   c: struct picolCmd *; 2 bytes at -2,U
                      (          xyz.asm):05734         * Line xyz.c:746: init of variable c
1BD8 AE44             (          xyz.asm):05735                 LDX     4,U             variable i
1BDA EC04             (          xyz.asm):05736                 LDD     4,X             member commands of picolInterp
1BDC ED5E             (          xyz.asm):05737                 STD     -2,U            variable c
                      (          xyz.asm):05738         * Line xyz.c:747: while
1BDE 201E             (          xyz.asm):05739                 BRA     L00605          jump to while condition
     1BE0             (          xyz.asm):05740         L00604  EQU     *               while body
                      (          xyz.asm):05741         * Line xyz.c:748: if
                      (          xyz.asm):05742         * Line xyz.c:748: function call: strcasecmp()
1BE0 EC46             (          xyz.asm):05743                 LDD     6,U             variable name, declared at xyz.c:745
1BE2 3406             (          xyz.asm):05744                 PSHS    B,A             argument 2 of strcasecmp(): const char *
1BE4 AE5E             (          xyz.asm):05745                 LDX     -2,U            variable c
1BE6 EC84             (          xyz.asm):05746                 LDD     ,X              member name of picolCmd
1BE8 3406             (          xyz.asm):05747                 PSHS    B,A             argument 1 of strcasecmp(): char *
1BEA 170E6A           (          xyz.asm):05748                 LBSR    _strcasecmp
1BED 3264             (          xyz.asm):05749                 LEAS    4,S
1BEF C30000           (          xyz.asm):05750                 ADDD    #0
1BF2 2604             (          xyz.asm):05751                 BNE     L00608
                      (          xyz.asm):05752         * optim: condBranchOverUncondBranch
                      (          xyz.asm):05753         * Useless label L00607 removed
                      (          xyz.asm):05754         * Line xyz.c:748: return with value
1BF4 EC5E             (          xyz.asm):05755                 LDD     -2,U            variable c, declared at xyz.c:746
1BF6 200C             (          xyz.asm):05756                 BRA     L00047          return (xyz.c:748)
     1BF8             (          xyz.asm):05757         L00608  EQU     *               else
                      (          xyz.asm):05758         * Useless label L00609 removed
                      (          xyz.asm):05759         * Line xyz.c:749: assignment: =
1BF8 AE5E             (          xyz.asm):05760                 LDX     -2,U            variable c
1BFA EC06             (          xyz.asm):05761                 LDD     6,X             member next of picolCmd
1BFC ED5E             (          xyz.asm):05762                 STD     -2,U
     1BFE             (          xyz.asm):05763         L00605  EQU     *               while condition at xyz.c:747
1BFE EC5E             (          xyz.asm):05764                 LDD     -2,U            variable c, declared at xyz.c:746
                      (          xyz.asm):05765         * optim: loadCmpZeroBeqOrBne
1C00 26DE             (          xyz.asm):05766                 BNE     L00604
                      (          xyz.asm):05767         * optim: branchToNextLocation
                      (          xyz.asm):05768         * Useless label L00606 removed
                      (          xyz.asm):05769         * Line xyz.c:751: return with value
1C02 4F               (          xyz.asm):05770                 CLRA
1C03 5F               (          xyz.asm):05771                 CLRB
                      (          xyz.asm):05772         * optim: branchToNextLocation
     1C04             (          xyz.asm):05773         L00047  EQU     *               end of picolGetCommand()
1C04 32C4             (          xyz.asm):05774                 LEAS    ,U
1C06 35C0             (          xyz.asm):05775                 PULS    U,PC
                      (          xyz.asm):05776         * END FUNCTION picolGetCommand(): defined at xyz.c:745
     1C08             (          xyz.asm):05777         funcend_picolGetCommand EQU *
     003B             (          xyz.asm):05778         funcsize_picolGetCommand        EQU     funcend_picolGetCommand-_picolGetCommand
                      (          xyz.asm):05779         
                      (          xyz.asm):05780         
                      (          xyz.asm):05781         *******************************************************************************
                      (          xyz.asm):05782         
                      (          xyz.asm):05783         * FUNCTION picolGetToken(): defined at xyz.c:673
     1C08             (          xyz.asm):05784         _picolGetToken  EQU     *
1C08 3440             (          xyz.asm):05785                 PSHS    U
1C0A 170E3F           (          xyz.asm):05786                 LBSR    _stkcheck
1C0D FFC0             (          xyz.asm):05787                 FDB     -64             argument for _stkcheck
1C0F 33E4             (          xyz.asm):05788                 LEAU    ,S
                      (          xyz.asm):05789         * Formal parameters and locals:
                      (          xyz.asm):05790         *   p: struct picolParser *; 2 bytes at 4,U
                      (          xyz.asm):05791         * Line xyz.c:703: labeled statement
     1C11             (          xyz.asm):05792         L00041  EQU     *               label TOP, declared at xyz.c:674
                      (          xyz.asm):05793         * Line xyz.c:675: while
1C11 1600DE           (          xyz.asm):05794                 LBRA    L00611          jump to while condition
     1C14             (          xyz.asm):05795         L00610  EQU     *               while body
                      (          xyz.asm):05796         * Line xyz.c:676: if
1C14 AE44             (          xyz.asm):05797                 LDX     4,U             variable p
1C16 EC04             (          xyz.asm):05798                 LDD     4,X             member len of picolParser
                      (          xyz.asm):05799         * optim: loadCmpZeroBeqOrBne
1C18 262B             (          xyz.asm):05800                 BNE     L00614
                      (          xyz.asm):05801         * optim: branchToNextLocation
                      (          xyz.asm):05802         * Useless label L00613 removed
                      (          xyz.asm):05803         * Line xyz.c:677: if
1C1A 4F               (          xyz.asm):05804                 CLRA
                      (          xyz.asm):05805         * optim: removeUselessOps
                      (          xyz.asm):05806         * PSHS B,A optim: optimizeStackOperations1
1C1B AE44             (          xyz.asm):05807                 LDX     4,U             variable p
1C1D EC0A             (          xyz.asm):05808                 LDD     10,X            member type of picolParser
1C1F 10830005         (          xyz.asm):05809                 CMPD    #5              optim: optimizeStackOperations1
1C23 2714             (          xyz.asm):05810                 BEQ     L00616
                      (          xyz.asm):05811         * optim: condBranchOverUncondBranch
                      (          xyz.asm):05812         * Useless label L00617 removed
1C25 4F               (          xyz.asm):05813                 CLRA
                      (          xyz.asm):05814         * optim: removeUselessOps
                      (          xyz.asm):05815         * PSHS B,A optim: optimizeStackOperations1
1C26 AE44             (          xyz.asm):05816                 LDX     4,U             variable p
1C28 EC0A             (          xyz.asm):05817                 LDD     10,X            member type of picolParser
1C2A 10830006         (          xyz.asm):05818                 CMPD    #6              optim: optimizeStackOperations1
1C2E 2709             (          xyz.asm):05819                 BEQ     L00616
                      (          xyz.asm):05820         * optim: condBranchOverUncondBranch
                      (          xyz.asm):05821         * Useless label L00615 removed
                      (          xyz.asm):05822         * Line xyz.c:678: assignment: =
1C30 4F               (          xyz.asm):05823                 CLRA
1C31 C605             (          xyz.asm):05824                 LDB     #$05            decimal 5 signed
                      (          xyz.asm):05825         * optim: stripUselessPushPull
1C33 AE44             (          xyz.asm):05826                 LDX     4,U             variable p
                      (          xyz.asm):05827         * optim: optimizeLeax
                      (          xyz.asm):05828         * optim: stripUselessPushPull
1C35 ED0A             (          xyz.asm):05829                 STD     10,X            optim: optimizeLeax
1C37 2007             (          xyz.asm):05830                 BRA     L00618          jump over else clause
     1C39             (          xyz.asm):05831         L00616  EQU     *               else
                      (          xyz.asm):05832         * Line xyz.c:680: assignment: =
1C39 4F               (          xyz.asm):05833                 CLRA
1C3A C606             (          xyz.asm):05834                 LDB     #$06            decimal 6 signed
                      (          xyz.asm):05835         * optim: stripUselessPushPull
1C3C AE44             (          xyz.asm):05836                 LDX     4,U             variable p
                      (          xyz.asm):05837         * optim: optimizeLeax
                      (          xyz.asm):05838         * optim: stripUselessPushPull
1C3E ED0A             (          xyz.asm):05839                 STD     10,X            optim: optimizeLeax
     1C40             (          xyz.asm):05840         L00618  EQU     *               end if
                      (          xyz.asm):05841         * Line xyz.c:681: return with value
1C40 4F               (          xyz.asm):05842                 CLRA
1C41 5F               (          xyz.asm):05843                 CLRB
1C42 1600B0           (          xyz.asm):05844                 LBRA    L00042          return (xyz.c:681)
     1C45             (          xyz.asm):05845         L00614  EQU     *               else
                      (          xyz.asm):05846         * Useless label L00619 removed
                      (          xyz.asm):05847         * Line xyz.c:683: switch
1C45 AE44             (          xyz.asm):05848                 LDX     4,U             variable p
                      (          xyz.asm):05849         * optim: optimizeLdx
                      (          xyz.asm):05850         * optim: removeTfrDX
1C47 E69802           (          xyz.asm):05851                 LDB     [2,X]           optim: optimizeLdx
                      (          xyz.asm):05852         * Switch at xyz.c:683: IF_ELSE=51, JUMP_TABLE=186
1C4A C120             (          xyz.asm):05853                 CMPB    #$20            case 32
1C4C 2725             (          xyz.asm):05854                 BEQ     L00621
1C4E C109             (          xyz.asm):05855                 CMPB    #$09            case 9
1C50 2721             (          xyz.asm):05856                 BEQ     L00622
1C52 C10D             (          xyz.asm):05857                 CMPB    #$0D            case 13
1C54 271D             (          xyz.asm):05858                 BEQ     L00623
1C56 C10A             (          xyz.asm):05859                 CMPB    #$0A            case 10
1C58 2737             (          xyz.asm):05860                 BEQ     L00624
1C5A C13B             (          xyz.asm):05861                 CMPB    #$3B            case 59
1C5C 2733             (          xyz.asm):05862                 BEQ     L00625
1C5E C15B             (          xyz.asm):05863                 CMPB    #$5B            case 91
1C60 1027004B         (          xyz.asm):05864                 LBEQ    L00626
1C64 C124             (          xyz.asm):05865                 CMPB    #$24            case 36
1C66 10270050         (          xyz.asm):05866                 LBEQ    L00627
1C6A C123             (          xyz.asm):05867                 CMPB    #$23            case 35
1C6C 10270055         (          xyz.asm):05868                 LBEQ    L00628
1C70 160074           (          xyz.asm):05869                 LBRA    L00629          switch default
     1C73             (          xyz.asm):05870         L00621  EQU     *               case 32
     1C73             (          xyz.asm):05871         L00622  EQU     *               case 9
     1C73             (          xyz.asm):05872         L00623  EQU     *               case 13
                      (          xyz.asm):05873         * Line xyz.c:685: if
1C73 AE44             (          xyz.asm):05874                 LDX     4,U             variable p
1C75 EC0C             (          xyz.asm):05875                 LDD     12,X            member insidequote of picolParser
                      (          xyz.asm):05876         * optim: loadCmpZeroBeqOrBne
1C77 270C             (          xyz.asm):05877                 BEQ     L00631
                      (          xyz.asm):05878         * optim: condBranchOverUncondBranch
                      (          xyz.asm):05879         * Useless label L00630 removed
                      (          xyz.asm):05880         * Line xyz.c:685: return with value
                      (          xyz.asm):05881         * Line xyz.c:685: function call: picolParseString()
1C79 EC44             (          xyz.asm):05882                 LDD     4,U             variable p, declared at xyz.c:673
1C7B 3406             (          xyz.asm):05883                 PSHS    B,A             argument 1 of picolParseString(): struct picolParser *
1C7D 1704DB           (          xyz.asm):05884                 LBSR    _picolParseString
1C80 3262             (          xyz.asm):05885                 LEAS    2,S
1C82 160070           (          xyz.asm):05886                 LBRA    L00042          return (xyz.c:685)
     1C85             (          xyz.asm):05887         L00631  EQU     *               else
                      (          xyz.asm):05888         * Useless label L00632 removed
                      (          xyz.asm):05889         * Line xyz.c:686: return with value
                      (          xyz.asm):05890         * Line xyz.c:686: function call: picolParseSep()
1C85 EC44             (          xyz.asm):05891                 LDD     4,U             variable p, declared at xyz.c:673
1C87 3406             (          xyz.asm):05892                 PSHS    B,A             argument 1 of picolParseSep(): struct picolParser *
1C89 170445           (          xyz.asm):05893                 LBSR    _picolParseSep
1C8C 3262             (          xyz.asm):05894                 LEAS    2,S
1C8E 160064           (          xyz.asm):05895                 LBRA    L00042          return (xyz.c:686)
     1C91             (          xyz.asm):05896         L00624  EQU     *               case 10
     1C91             (          xyz.asm):05897         L00625  EQU     *               case 59
                      (          xyz.asm):05898         * Line xyz.c:688: if
1C91 AE44             (          xyz.asm):05899                 LDX     4,U             variable p
1C93 EC0C             (          xyz.asm):05900                 LDD     12,X            member insidequote of picolParser
                      (          xyz.asm):05901         * optim: loadCmpZeroBeqOrBne
1C95 270C             (          xyz.asm):05902                 BEQ     L00634
                      (          xyz.asm):05903         * optim: condBranchOverUncondBranch
                      (          xyz.asm):05904         * Useless label L00633 removed
                      (          xyz.asm):05905         * Line xyz.c:688: return with value
                      (          xyz.asm):05906         * Line xyz.c:688: function call: picolParseString()
1C97 EC44             (          xyz.asm):05907                 LDD     4,U             variable p, declared at xyz.c:673
1C99 3406             (          xyz.asm):05908                 PSHS    B,A             argument 1 of picolParseString(): struct picolParser *
1C9B 1704BD           (          xyz.asm):05909                 LBSR    _picolParseString
1C9E 3262             (          xyz.asm):05910                 LEAS    2,S
1CA0 160052           (          xyz.asm):05911                 LBRA    L00042          return (xyz.c:688)
     1CA3             (          xyz.asm):05912         L00634  EQU     *               else
                      (          xyz.asm):05913         * Useless label L00635 removed
                      (          xyz.asm):05914         * Line xyz.c:689: return with value
                      (          xyz.asm):05915         * Line xyz.c:689: function call: picolParseEol()
1CA3 EC44             (          xyz.asm):05916                 LDD     4,U             variable p, declared at xyz.c:673
1CA5 3406             (          xyz.asm):05917                 PSHS    B,A             argument 1 of picolParseEol(): struct picolParser *
1CA7 17038B           (          xyz.asm):05918                 LBSR    _picolParseEol
1CAA 3262             (          xyz.asm):05919                 LEAS    2,S
1CAC 160046           (          xyz.asm):05920                 LBRA    L00042          return (xyz.c:689)
     1CAF             (          xyz.asm):05921         L00626  EQU     *               case 91
                      (          xyz.asm):05922         * Line xyz.c:691: return with value
                      (          xyz.asm):05923         * Line xyz.c:691: function call: picolParseCommand()
1CAF EC44             (          xyz.asm):05924                 LDD     4,U             variable p, declared at xyz.c:673
1CB1 3406             (          xyz.asm):05925                 PSHS    B,A             argument 1 of picolParseCommand(): struct picolParser *
1CB3 1701FA           (          xyz.asm):05926                 LBSR    _picolParseCommand
1CB6 3262             (          xyz.asm):05927                 LEAS    2,S
1CB8 203B             (          xyz.asm):05928                 BRA     L00042          return (xyz.c:691)
     1CBA             (          xyz.asm):05929         L00627  EQU     *               case 36
                      (          xyz.asm):05930         * Line xyz.c:693: return with value
                      (          xyz.asm):05931         * Line xyz.c:693: function call: picolParseVar()
1CBA EC44             (          xyz.asm):05932                 LDD     4,U             variable p, declared at xyz.c:673
1CBC 3406             (          xyz.asm):05933                 PSHS    B,A             argument 1 of picolParseVar(): struct picolParser *
1CBE 170646           (          xyz.asm):05934                 LBSR    _picolParseVar
1CC1 3262             (          xyz.asm):05935                 LEAS    2,S
1CC3 2030             (          xyz.asm):05936                 BRA     L00042          return (xyz.c:693)
     1CC5             (          xyz.asm):05937         L00628  EQU     *               case 35
                      (          xyz.asm):05938         * Line xyz.c:695: if
1CC5 4F               (          xyz.asm):05939                 CLRA
                      (          xyz.asm):05940         * optim: removeUselessOps
                      (          xyz.asm):05941         * PSHS B,A optim: optimizeStackOperations1
1CC6 AE44             (          xyz.asm):05942                 LDX     4,U             variable p
1CC8 EC0A             (          xyz.asm):05943                 LDD     10,X            member type of picolParser
1CCA 10830005         (          xyz.asm):05944                 CMPD    #5              optim: optimizeStackOperations1
1CCE 260C             (          xyz.asm):05945                 BNE     L00637
                      (          xyz.asm):05946         * optim: condBranchOverUncondBranch
                      (          xyz.asm):05947         * Useless label L00636 removed
                      (          xyz.asm):05948         * Line xyz.c:696: function call: picolParseComment()
1CD0 EC44             (          xyz.asm):05949                 LDD     4,U             variable p, declared at xyz.c:673
1CD2 3406             (          xyz.asm):05950                 PSHS    B,A             argument 1 of picolParseComment(): struct picolParser *
1CD4 170321           (          xyz.asm):05951                 LBSR    _picolParseComment
1CD7 3262             (          xyz.asm):05952                 LEAS    2,S
                      (          xyz.asm):05953         * Line xyz.c:697: goto TOP
1CD9 16FF35           (          xyz.asm):05954                 LBRA    L00041
     1CDC             (          xyz.asm):05955         L00637  EQU     *               else
                      (          xyz.asm):05956         * Useless label L00638 removed
                      (          xyz.asm):05957         * Line xyz.c:699: return with value
                      (          xyz.asm):05958         * Line xyz.c:699: function call: picolParseString()
1CDC EC44             (          xyz.asm):05959                 LDD     4,U             variable p, declared at xyz.c:673
1CDE 3406             (          xyz.asm):05960                 PSHS    B,A             argument 1 of picolParseString(): struct picolParser *
1CE0 170478           (          xyz.asm):05961                 LBSR    _picolParseString
1CE3 3262             (          xyz.asm):05962                 LEAS    2,S
1CE5 200E             (          xyz.asm):05963                 BRA     L00042          return (xyz.c:699)
     1CE7             (          xyz.asm):05964         L00629  EQU     *               default
                      (          xyz.asm):05965         * Line xyz.c:701: return with value
                      (          xyz.asm):05966         * Line xyz.c:701: function call: picolParseString()
1CE7 EC44             (          xyz.asm):05967                 LDD     4,U             variable p, declared at xyz.c:673
1CE9 3406             (          xyz.asm):05968                 PSHS    B,A             argument 1 of picolParseString(): struct picolParser *
1CEB 17046D           (          xyz.asm):05969                 LBSR    _picolParseString
1CEE 3262             (          xyz.asm):05970                 LEAS    2,S
1CF0 2003             (          xyz.asm):05971                 BRA     L00042          return (xyz.c:701)
                      (          xyz.asm):05972         * Useless label L00620 removed
     1CF2             (          xyz.asm):05973         L00611  EQU     *               while condition at xyz.c:675
1CF2 16FF1F           (          xyz.asm):05974                 LBRA    L00610          go to start of while body
                      (          xyz.asm):05975         * Useless label L00612 removed
                      (          xyz.asm):05976         * Line xyz.c:704: return with value
                      (          xyz.asm):05977         * optim: instrFollowingUncondBranch
                      (          xyz.asm):05978         * optim: instrFollowingUncondBranch
                      (          xyz.asm):05979         * optim: branchToNextLocation
     1CF5             (          xyz.asm):05980         L00042  EQU     *               end of picolGetToken()
1CF5 32C4             (          xyz.asm):05981                 LEAS    ,U
1CF7 35C0             (          xyz.asm):05982                 PULS    U,PC
                      (          xyz.asm):05983         * END FUNCTION picolGetToken(): defined at xyz.c:673
     1CF9             (          xyz.asm):05984         funcend_picolGetToken   EQU *
     00F1             (          xyz.asm):05985         funcsize_picolGetToken  EQU     funcend_picolGetToken-_picolGetToken
                      (          xyz.asm):05986         
                      (          xyz.asm):05987         
                      (          xyz.asm):05988         *******************************************************************************
                      (          xyz.asm):05989         
                      (          xyz.asm):05990         * FUNCTION picolGetVar(): defined at xyz.c:721
     1CF9             (          xyz.asm):05991         _picolGetVar    EQU     *
1CF9 3440             (          xyz.asm):05992                 PSHS    U
1CFB 170D4E           (          xyz.asm):05993                 LBSR    _stkcheck
1CFE FFBE             (          xyz.asm):05994                 FDB     -66             argument for _stkcheck
1D00 33E4             (          xyz.asm):05995                 LEAU    ,S
1D02 327E             (          xyz.asm):05996                 LEAS    -2,S
                      (          xyz.asm):05997         * Formal parameters and locals:
                      (          xyz.asm):05998         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):05999         *   name: const char *; 2 bytes at 6,U
                      (          xyz.asm):06000         *   v: struct picolVar *; 2 bytes at -2,U
                      (          xyz.asm):06001         * Line xyz.c:722: init of variable v
1D04 AE44             (          xyz.asm):06002                 LDX     4,U             variable i
                      (          xyz.asm):06003         * optim: optimizeLdx
                      (          xyz.asm):06004         * optim: removeTfrDX
1D06 EC9802           (          xyz.asm):06005                 LDD     [2,X]           optim: optimizeLdx
1D09 ED5E             (          xyz.asm):06006                 STD     -2,U            variable v
                      (          xyz.asm):06007         * Line xyz.c:723: while
1D0B 201E             (          xyz.asm):06008                 BRA     L00640          jump to while condition
     1D0D             (          xyz.asm):06009         L00639  EQU     *               while body
                      (          xyz.asm):06010         * Line xyz.c:724: if
                      (          xyz.asm):06011         * Line xyz.c:724: function call: strcasecmp()
1D0D EC46             (          xyz.asm):06012                 LDD     6,U             variable name, declared at xyz.c:721
1D0F 3406             (          xyz.asm):06013                 PSHS    B,A             argument 2 of strcasecmp(): const char *
1D11 AE5E             (          xyz.asm):06014                 LDX     -2,U            variable v
1D13 EC84             (          xyz.asm):06015                 LDD     ,X              member name of picolVar
1D15 3406             (          xyz.asm):06016                 PSHS    B,A             argument 1 of strcasecmp(): char *
1D17 170D3D           (          xyz.asm):06017                 LBSR    _strcasecmp
1D1A 3264             (          xyz.asm):06018                 LEAS    4,S
1D1C C30000           (          xyz.asm):06019                 ADDD    #0
1D1F 2604             (          xyz.asm):06020                 BNE     L00643
                      (          xyz.asm):06021         * optim: condBranchOverUncondBranch
                      (          xyz.asm):06022         * Useless label L00642 removed
                      (          xyz.asm):06023         * Line xyz.c:724: return with value
1D21 EC5E             (          xyz.asm):06024                 LDD     -2,U            variable v, declared at xyz.c:722
1D23 200C             (          xyz.asm):06025                 BRA     L00045          return (xyz.c:724)
     1D25             (          xyz.asm):06026         L00643  EQU     *               else
                      (          xyz.asm):06027         * Useless label L00644 removed
                      (          xyz.asm):06028         * Line xyz.c:725: assignment: =
1D25 AE5E             (          xyz.asm):06029                 LDX     -2,U            variable v
1D27 EC04             (          xyz.asm):06030                 LDD     4,X             member next of picolVar
1D29 ED5E             (          xyz.asm):06031                 STD     -2,U
     1D2B             (          xyz.asm):06032         L00640  EQU     *               while condition at xyz.c:723
1D2B EC5E             (          xyz.asm):06033                 LDD     -2,U            variable v, declared at xyz.c:722
                      (          xyz.asm):06034         * optim: loadCmpZeroBeqOrBne
1D2D 26DE             (          xyz.asm):06035                 BNE     L00639
                      (          xyz.asm):06036         * optim: branchToNextLocation
                      (          xyz.asm):06037         * Useless label L00641 removed
                      (          xyz.asm):06038         * Line xyz.c:727: return with value
1D2F 4F               (          xyz.asm):06039                 CLRA
1D30 5F               (          xyz.asm):06040                 CLRB
                      (          xyz.asm):06041         * optim: branchToNextLocation
     1D31             (          xyz.asm):06042         L00045  EQU     *               end of picolGetVar()
1D31 32C4             (          xyz.asm):06043                 LEAS    ,U
1D33 35C0             (          xyz.asm):06044                 PULS    U,PC
                      (          xyz.asm):06045         * END FUNCTION picolGetVar(): defined at xyz.c:721
     1D35             (          xyz.asm):06046         funcend_picolGetVar     EQU *
     003C             (          xyz.asm):06047         funcsize_picolGetVar    EQU     funcend_picolGetVar-_picolGetVar
                      (          xyz.asm):06048         
                      (          xyz.asm):06049         
                      (          xyz.asm):06050         *******************************************************************************
                      (          xyz.asm):06051         
                      (          xyz.asm):06052         * FUNCTION picolInitInterp(): defined at xyz.c:707
     1D35             (          xyz.asm):06053         _picolInitInterp        EQU     *
1D35 3440             (          xyz.asm):06054                 PSHS    U
1D37 170D12           (          xyz.asm):06055                 LBSR    _stkcheck
1D3A FFC0             (          xyz.asm):06056                 FDB     -64             argument for _stkcheck
1D3C 33E4             (          xyz.asm):06057                 LEAU    ,S
                      (          xyz.asm):06058         * Formal parameters and locals:
                      (          xyz.asm):06059         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):06060         * Line xyz.c:708: assignment: =
1D3E 4F               (          xyz.asm):06061                 CLRA
1D3F 5F               (          xyz.asm):06062                 CLRB
                      (          xyz.asm):06063         * optim: stripUselessPushPull
1D40 AE44             (          xyz.asm):06064                 LDX     4,U             variable i
                      (          xyz.asm):06065         * optim: stripUselessPushPull
1D42 ED84             (          xyz.asm):06066                 STD     ,X
                      (          xyz.asm):06067         * Line xyz.c:709: assignment: =
                      (          xyz.asm):06068         * Line xyz.c:709: function call: malloc()
1D44 C604             (          xyz.asm):06069                 LDB     #$04            optim: removeAndOrMulAddSub
1D46 3406             (          xyz.asm):06070                 PSHS    B,A             argument 1 of malloc(): unsigned int
1D48 17EAFF           (          xyz.asm):06071                 LBSR    _malloc
1D4B 3262             (          xyz.asm):06072                 LEAS    2,S
                      (          xyz.asm):06073         * optim: stripUselessPushPull
1D4D AE44             (          xyz.asm):06074                 LDX     4,U             variable i
                      (          xyz.asm):06075         * optim: optimizeLeax
                      (          xyz.asm):06076         * optim: stripUselessPushPull
1D4F ED02             (          xyz.asm):06077                 STD     2,X             optim: optimizeLeax
                      (          xyz.asm):06078         * Line xyz.c:710: assignment: =
1D51 4F               (          xyz.asm):06079                 CLRA
1D52 5F               (          xyz.asm):06080                 CLRB
                      (          xyz.asm):06081         * optim: stripUselessPushPull
1D53 AE44             (          xyz.asm):06082                 LDX     4,U             variable i
                      (          xyz.asm):06083         * optim: optimizeLdx
                      (          xyz.asm):06084         * optim: removeTfrDX
                      (          xyz.asm):06085         * optim: stripUselessPushPull
1D55 ED9802           (          xyz.asm):06086                 STD     [2,X]           optim: optimizeLdx
                      (          xyz.asm):06087         * Line xyz.c:711: assignment: =
                      (          xyz.asm):06088         * optim: removeClr
                      (          xyz.asm):06089         * optim: removeClr
1D58 3406             (          xyz.asm):06090                 PSHS    B,A
1D5A AE44             (          xyz.asm):06091                 LDX     4,U             variable i
1D5C AE02             (          xyz.asm):06092                 LDX     2,X             optim: removeTfrDX
                      (          xyz.asm):06093         * optim: removeTfrDX
                      (          xyz.asm):06094         * optim: optimizeLeax
1D5E 3506             (          xyz.asm):06095                 PULS    A,B             retrieve value to store
1D60 ED02             (          xyz.asm):06096                 STD     2,X             optim: optimizeLeax
                      (          xyz.asm):06097         * Line xyz.c:712: assignment: =
                      (          xyz.asm):06098         * optim: removeClr
                      (          xyz.asm):06099         * optim: removeClr
                      (          xyz.asm):06100         * optim: stripUselessPushPull
1D62 AE44             (          xyz.asm):06101                 LDX     4,U             variable i
                      (          xyz.asm):06102         * optim: optimizeLeax
                      (          xyz.asm):06103         * optim: stripUselessPushPull
1D64 ED04             (          xyz.asm):06104                 STD     4,X             optim: optimizeLeax
                      (          xyz.asm):06105         * Line xyz.c:713: assignment: =
                      (          xyz.asm):06106         * Line xyz.c:713: function call: strdup()
1D66 308D0EDE         (          xyz.asm):06107                 LEAX    S00095,PCR      ""
1D6A 3410             (          xyz.asm):06108                 PSHS    X               argument 1 of strdup(): const char[]
1D6C 170DDB           (          xyz.asm):06109                 LBSR    _strdup
1D6F 3262             (          xyz.asm):06110                 LEAS    2,S
                      (          xyz.asm):06111         * optim: stripUselessPushPull
1D71 AE44             (          xyz.asm):06112                 LDX     4,U             variable i
                      (          xyz.asm):06113         * optim: optimizeLeax
                      (          xyz.asm):06114         * optim: stripUselessPushPull
1D73 ED06             (          xyz.asm):06115                 STD     6,X             optim: optimizeLeax
                      (          xyz.asm):06116         * Useless label L00043 removed
1D75 32C4             (          xyz.asm):06117                 LEAS    ,U
1D77 35C0             (          xyz.asm):06118                 PULS    U,PC
                      (          xyz.asm):06119         * END FUNCTION picolInitInterp(): defined at xyz.c:707
     1D79             (          xyz.asm):06120         funcend_picolInitInterp EQU *
     0044             (          xyz.asm):06121         funcsize_picolInitInterp        EQU     funcend_picolInitInterp-_picolInitInterp
                      (          xyz.asm):06122         
                      (          xyz.asm):06123         
                      (          xyz.asm):06124         *******************************************************************************
                      (          xyz.asm):06125         
                      (          xyz.asm):06126         * FUNCTION picolInitParser(): defined at xyz.c:520
     1D79             (          xyz.asm):06127         _picolInitParser        EQU     *
1D79 3440             (          xyz.asm):06128                 PSHS    U
1D7B 170CCE           (          xyz.asm):06129                 LBSR    _stkcheck
1D7E FFC0             (          xyz.asm):06130                 FDB     -64             argument for _stkcheck
1D80 33E4             (          xyz.asm):06131                 LEAU    ,S
                      (          xyz.asm):06132         * Formal parameters and locals:
                      (          xyz.asm):06133         *   p: struct picolParser *; 2 bytes at 4,U
                      (          xyz.asm):06134         *   text: char *; 2 bytes at 6,U
                      (          xyz.asm):06135         * Line xyz.c:521: assignment: =
                      (          xyz.asm):06136         * Line xyz.c:521: assignment: =
1D82 EC46             (          xyz.asm):06137                 LDD     6,U             variable text, declared at xyz.c:520
                      (          xyz.asm):06138         * optim: stripUselessPushPull
1D84 AE44             (          xyz.asm):06139                 LDX     4,U             variable p
                      (          xyz.asm):06140         * optim: optimizeLeax
                      (          xyz.asm):06141         * optim: stripUselessPushPull
1D86 ED02             (          xyz.asm):06142                 STD     2,X             optim: optimizeLeax
                      (          xyz.asm):06143         * optim: stripUselessPushPull
1D88 AE44             (          xyz.asm):06144                 LDX     4,U             variable p
                      (          xyz.asm):06145         * optim: stripUselessPushPull
1D8A ED84             (          xyz.asm):06146                 STD     ,X
                      (          xyz.asm):06147         * Line xyz.c:522: assignment: =
                      (          xyz.asm):06148         * Line xyz.c:522: function call: strlen()
1D8C EC46             (          xyz.asm):06149                 LDD     6,U             variable text, declared at xyz.c:520
1D8E 3406             (          xyz.asm):06150                 PSHS    B,A             argument 1 of strlen(): char *
1D90 170DEC           (          xyz.asm):06151                 LBSR    _strlen
1D93 3262             (          xyz.asm):06152                 LEAS    2,S
                      (          xyz.asm):06153         * optim: stripUselessPushPull
1D95 AE44             (          xyz.asm):06154                 LDX     4,U             variable p
                      (          xyz.asm):06155         * optim: optimizeLeax
                      (          xyz.asm):06156         * optim: stripUselessPushPull
1D97 ED04             (          xyz.asm):06157                 STD     4,X             optim: optimizeLeax
                      (          xyz.asm):06158         * Line xyz.c:523: assignment: =
1D99 4F               (          xyz.asm):06159                 CLRA
1D9A 5F               (          xyz.asm):06160                 CLRB
                      (          xyz.asm):06161         * optim: stripUselessPushPull
1D9B AE44             (          xyz.asm):06162                 LDX     4,U             variable p
                      (          xyz.asm):06163         * optim: optimizeLeax
                      (          xyz.asm):06164         * optim: stripUselessPushPull
1D9D ED06             (          xyz.asm):06165                 STD     6,X             optim: optimizeLeax
                      (          xyz.asm):06166         * Line xyz.c:523: assignment: =
                      (          xyz.asm):06167         * optim: removeClr
                      (          xyz.asm):06168         * optim: removeClr
                      (          xyz.asm):06169         * optim: stripUselessPushPull
1D9F AE44             (          xyz.asm):06170                 LDX     4,U             variable p
                      (          xyz.asm):06171         * optim: optimizeLeax
                      (          xyz.asm):06172         * optim: stripUselessPushPull
1DA1 ED08             (          xyz.asm):06173                 STD     8,X             optim: optimizeLeax
                      (          xyz.asm):06174         * Line xyz.c:523: assignment: =
                      (          xyz.asm):06175         * optim: removeClr
                      (          xyz.asm):06176         * optim: removeClr
                      (          xyz.asm):06177         * optim: stripUselessPushPull
1DA3 AE44             (          xyz.asm):06178                 LDX     4,U             variable p
                      (          xyz.asm):06179         * optim: optimizeLeax
                      (          xyz.asm):06180         * optim: stripUselessPushPull
1DA5 ED0C             (          xyz.asm):06181                 STD     12,X            optim: optimizeLeax
                      (          xyz.asm):06182         * Line xyz.c:524: assignment: =
1DA7 C605             (          xyz.asm):06183                 LDB     #$05            optim: removeAndOrMulAddSub
                      (          xyz.asm):06184         * optim: stripUselessPushPull
1DA9 AE44             (          xyz.asm):06185                 LDX     4,U             variable p
                      (          xyz.asm):06186         * optim: optimizeLeax
                      (          xyz.asm):06187         * optim: stripUselessPushPull
1DAB ED0A             (          xyz.asm):06188                 STD     10,X            optim: optimizeLeax
                      (          xyz.asm):06189         * Useless label L00033 removed
1DAD 32C4             (          xyz.asm):06190                 LEAS    ,U
1DAF 35C0             (          xyz.asm):06191                 PULS    U,PC
                      (          xyz.asm):06192         * END FUNCTION picolInitParser(): defined at xyz.c:520
     1DB1             (          xyz.asm):06193         funcend_picolInitParser EQU *
     0038             (          xyz.asm):06194         funcsize_picolInitParser        EQU     funcend_picolInitParser-_picolInitParser
                      (          xyz.asm):06195         
                      (          xyz.asm):06196         
                      (          xyz.asm):06197         *******************************************************************************
                      (          xyz.asm):06198         
                      (          xyz.asm):06199         * FUNCTION picolParseBrace(): defined at xyz.c:597
     1DB1             (          xyz.asm):06200         _picolParseBrace        EQU     *
1DB1 3440             (          xyz.asm):06201                 PSHS    U
1DB3 170C96           (          xyz.asm):06202                 LBSR    _stkcheck
1DB6 FFBE             (          xyz.asm):06203                 FDB     -66             argument for _stkcheck
1DB8 33E4             (          xyz.asm):06204                 LEAU    ,S
1DBA 327E             (          xyz.asm):06205                 LEAS    -2,S
                      (          xyz.asm):06206         * Formal parameters and locals:
                      (          xyz.asm):06207         *   p: struct picolParser *; 2 bytes at 4,U
                      (          xyz.asm):06208         *   level: int; 2 bytes at -2,U
                      (          xyz.asm):06209         * Line xyz.c:598: init of variable level
1DBC 4F               (          xyz.asm):06210                 CLRA
1DBD C601             (          xyz.asm):06211                 LDB     #$01            1
1DBF ED5E             (          xyz.asm):06212                 STD     -2,U            variable level
                      (          xyz.asm):06213         * Line xyz.c:599: assignment: =
1DC1 AE44             (          xyz.asm):06214                 LDX     4,U             variable p
1DC3 3002             (          xyz.asm):06215                 LEAX    2,X             member p of picolParser
1DC5 EC84             (          xyz.asm):06216                 LDD     ,X
1DC7 C30001           (          xyz.asm):06217                 ADDD    #1
1DCA ED84             (          xyz.asm):06218                 STD     ,X
                      (          xyz.asm):06219         * optim: stripUselessPushPull
1DCC AE44             (          xyz.asm):06220                 LDX     4,U             variable p
                      (          xyz.asm):06221         * optim: optimizeLeax
                      (          xyz.asm):06222         * optim: stripUselessPushPull
1DCE ED06             (          xyz.asm):06223                 STD     6,X             optim: optimizeLeax
1DD0 AE44             (          xyz.asm):06224                 LDX     4,U             variable p
1DD2 3004             (          xyz.asm):06225                 LEAX    4,X             member len of picolParser
1DD4 EC84             (          xyz.asm):06226                 LDD     ,X
1DD6 830001           (          xyz.asm):06227                 SUBD    #1
1DD9 ED84             (          xyz.asm):06228                 STD     ,X
1DDB C30001           (          xyz.asm):06229                 ADDD    #1              post increment yields initial value
                      (          xyz.asm):06230         * Line xyz.c:600: while
1DDE 1600C8           (          xyz.asm):06231                 LBRA    L00646          jump to while condition
     1DE1             (          xyz.asm):06232         L00645  EQU     *               while body
                      (          xyz.asm):06233         * Line xyz.c:601: if
1DE1 4F               (          xyz.asm):06234                 CLRA
                      (          xyz.asm):06235         * optim: removeUselessOps
                      (          xyz.asm):06236         * PSHS B,A optim: optimizeStackOperations1
1DE2 AE44             (          xyz.asm):06237                 LDX     4,U             variable p
1DE4 EC04             (          xyz.asm):06238                 LDD     4,X             member len of picolParser
1DE6 10830002         (          xyz.asm):06239                 CMPD    #2              optim: optimizeStackOperations1
1DEA 2D2C             (          xyz.asm):06240                 BLT     L00649
                      (          xyz.asm):06241         * optim: condBranchOverUncondBranch
                      (          xyz.asm):06242         * Useless label L00650 removed
1DEC C65C             (          xyz.asm):06243                 LDB     #$5C            optim: lddToLDB
1DEE 1D               (          xyz.asm):06244                 SEX                     promotion of binary operand
1DEF 3406             (          xyz.asm):06245                 PSHS    B,A
1DF1 AE44             (          xyz.asm):06246                 LDX     4,U             variable p
                      (          xyz.asm):06247         * optim: optimizeLdx
                      (          xyz.asm):06248         * optim: removeTfrDX
1DF3 E69802           (          xyz.asm):06249                 LDB     [2,X]           optim: optimizeLdx
1DF6 1D               (          xyz.asm):06250                 SEX                     promotion of binary operand
1DF7 10A3E1           (          xyz.asm):06251                 CMPD    ,S++
1DFA 261C             (          xyz.asm):06252                 BNE     L00649
                      (          xyz.asm):06253         * optim: condBranchOverUncondBranch
                      (          xyz.asm):06254         * Useless label L00648 removed
1DFC AE44             (          xyz.asm):06255                 LDX     4,U             variable p
1DFE 3002             (          xyz.asm):06256                 LEAX    2,X             member p of picolParser
1E00 EC84             (          xyz.asm):06257                 LDD     ,X
1E02 C30001           (          xyz.asm):06258                 ADDD    #1
1E05 ED84             (          xyz.asm):06259                 STD     ,X
                      (          xyz.asm):06260         * optim: removeUselessOps
1E07 AE44             (          xyz.asm):06261                 LDX     4,U             variable p
1E09 3004             (          xyz.asm):06262                 LEAX    4,X             member len of picolParser
1E0B EC84             (          xyz.asm):06263                 LDD     ,X
1E0D 830001           (          xyz.asm):06264                 SUBD    #1
1E10 ED84             (          xyz.asm):06265                 STD     ,X
1E12 C30001           (          xyz.asm):06266                 ADDD    #1              post increment yields initial value
1E15 160078           (          xyz.asm):06267                 LBRA    L00651          jump over else clause
     1E18             (          xyz.asm):06268         L00649  EQU     *               else
                      (          xyz.asm):06269         * Line xyz.c:603: if
1E18 AE44             (          xyz.asm):06270                 LDX     4,U             variable p
1E1A EC04             (          xyz.asm):06271                 LDD     4,X             member len of picolParser
                      (          xyz.asm):06272         * optim: loadCmpZeroBeqOrBne
1E1C 2712             (          xyz.asm):06273                 BEQ     L00652
                      (          xyz.asm):06274         * optim: branchToNextLocation
                      (          xyz.asm):06275         * Useless label L00654 removed
1E1E C67D             (          xyz.asm):06276                 LDB     #$7D            optim: lddToLDB
1E20 1D               (          xyz.asm):06277                 SEX                     promotion of binary operand
1E21 3406             (          xyz.asm):06278                 PSHS    B,A
1E23 AE44             (          xyz.asm):06279                 LDX     4,U             variable p
                      (          xyz.asm):06280         * optim: optimizeLdx
                      (          xyz.asm):06281         * optim: removeTfrDX
1E25 E69802           (          xyz.asm):06282                 LDB     [2,X]           optim: optimizeLdx
1E28 1D               (          xyz.asm):06283                 SEX                     promotion of binary operand
1E29 10A3E1           (          xyz.asm):06284                 CMPD    ,S++
1E2C 10260047         (          xyz.asm):06285                 LBNE    L00653
                      (          xyz.asm):06286         * optim: condBranchOverUncondBranch
     1E30             (          xyz.asm):06287         L00652  EQU     *               then
1E30 305E             (          xyz.asm):06288                 LEAX    -2,U            variable level, declared at xyz.c:598
1E32 EC84             (          xyz.asm):06289                 LDD     ,X
1E34 830001           (          xyz.asm):06290                 SUBD    #1
1E37 ED84             (          xyz.asm):06291                 STD     ,X
                      (          xyz.asm):06292         * optim: stripOpToDeadReg
                      (          xyz.asm):06293         * Line xyz.c:605: if
1E39 EC5E             (          xyz.asm):06294                 LDD     -2,U            variable level, declared at xyz.c:598
                      (          xyz.asm):06295         * optim: loadCmpZeroBeqOrBne
1E3B 2706             (          xyz.asm):06296                 BEQ     L00655
                      (          xyz.asm):06297         * optim: branchToNextLocation
                      (          xyz.asm):06298         * Useless label L00657 removed
1E3D AE44             (          xyz.asm):06299                 LDX     4,U             variable p
1E3F EC04             (          xyz.asm):06300                 LDD     4,X             member len of picolParser
                      (          xyz.asm):06301         * optim: loadCmpZeroBeqOrBne
1E41 2632             (          xyz.asm):06302                 BNE     L00656
                      (          xyz.asm):06303         * optim: condBranchOverUncondBranch
     1E43             (          xyz.asm):06304         L00655  EQU     *               then
                      (          xyz.asm):06305         * Line xyz.c:606: assignment: =
1E43 4F               (          xyz.asm):06306                 CLRA
                      (          xyz.asm):06307         * optim: removeUselessOps
                      (          xyz.asm):06308         * PSHS B,A optim: optimizeStackOperations1
1E44 AE44             (          xyz.asm):06309                 LDX     4,U             variable p
1E46 EC02             (          xyz.asm):06310                 LDD     2,X             member p of picolParser
1E48 830001           (          xyz.asm):06311                 SUBD    #1              optim: optimizeStackOperations1
                      (          xyz.asm):06312         * optim: stripUselessPushPull
1E4B AE44             (          xyz.asm):06313                 LDX     4,U             variable p
                      (          xyz.asm):06314         * optim: optimizeLeax
                      (          xyz.asm):06315         * optim: stripUselessPushPull
1E4D ED08             (          xyz.asm):06316                 STD     8,X             optim: optimizeLeax
                      (          xyz.asm):06317         * Line xyz.c:607: if
1E4F AE44             (          xyz.asm):06318                 LDX     4,U             variable p
1E51 EC04             (          xyz.asm):06319                 LDD     4,X             member len of picolParser
                      (          xyz.asm):06320         * optim: loadCmpZeroBeqOrBne
1E53 2716             (          xyz.asm):06321                 BEQ     L00659
                      (          xyz.asm):06322         * optim: condBranchOverUncondBranch
                      (          xyz.asm):06323         * Useless label L00658 removed
1E55 AE44             (          xyz.asm):06324                 LDX     4,U             variable p
1E57 3002             (          xyz.asm):06325                 LEAX    2,X             member p of picolParser
1E59 EC84             (          xyz.asm):06326                 LDD     ,X
1E5B C30001           (          xyz.asm):06327                 ADDD    #1
1E5E ED84             (          xyz.asm):06328                 STD     ,X
                      (          xyz.asm):06329         * optim: removeUselessOps
1E60 AE44             (          xyz.asm):06330                 LDX     4,U             variable p
1E62 3004             (          xyz.asm):06331                 LEAX    4,X             member len of picolParser
1E64 EC84             (          xyz.asm):06332                 LDD     ,X
1E66 830001           (          xyz.asm):06333                 SUBD    #1
1E69 ED84             (          xyz.asm):06334                 STD     ,X
                      (          xyz.asm):06335         * optim: removeUselessOps
     1E6B             (          xyz.asm):06336         L00659  EQU     *               else
                      (          xyz.asm):06337         * Useless label L00660 removed
                      (          xyz.asm):06338         * Line xyz.c:610: assignment: =
1E6B 4F               (          xyz.asm):06339                 CLRA
1E6C C601             (          xyz.asm):06340                 LDB     #$01            decimal 1 signed
                      (          xyz.asm):06341         * optim: stripUselessPushPull
1E6E AE44             (          xyz.asm):06342                 LDX     4,U             variable p
                      (          xyz.asm):06343         * optim: optimizeLeax
                      (          xyz.asm):06344         * optim: stripUselessPushPull
1E70 ED0A             (          xyz.asm):06345                 STD     10,X            optim: optimizeLeax
                      (          xyz.asm):06346         * Line xyz.c:611: return with value
                      (          xyz.asm):06347         * optim: removeClr
1E72 5F               (          xyz.asm):06348                 CLRB
1E73 2037             (          xyz.asm):06349                 BRA     L00038          return (xyz.c:611)
     1E75             (          xyz.asm):06350         L00656  EQU     *               else
                      (          xyz.asm):06351         * Useless label L00661 removed
1E75 2019             (          xyz.asm):06352                 BRA     L00662          jump over else clause
     1E77             (          xyz.asm):06353         L00653  EQU     *               else
                      (          xyz.asm):06354         * Line xyz.c:613: if
1E77 C67B             (          xyz.asm):06355                 LDB     #$7B            optim: lddToLDB
1E79 1D               (          xyz.asm):06356                 SEX                     promotion of binary operand
1E7A 3406             (          xyz.asm):06357                 PSHS    B,A
1E7C AE44             (          xyz.asm):06358                 LDX     4,U             variable p
                      (          xyz.asm):06359         * optim: optimizeLdx
                      (          xyz.asm):06360         * optim: removeTfrDX
1E7E E69802           (          xyz.asm):06361                 LDB     [2,X]           optim: optimizeLdx
1E81 1D               (          xyz.asm):06362                 SEX                     promotion of binary operand
1E82 10A3E1           (          xyz.asm):06363                 CMPD    ,S++
1E85 2609             (          xyz.asm):06364                 BNE     L00664
                      (          xyz.asm):06365         * optim: condBranchOverUncondBranch
                      (          xyz.asm):06366         * Useless label L00663 removed
1E87 305E             (          xyz.asm):06367                 LEAX    -2,U            variable level, declared at xyz.c:598
1E89 EC84             (          xyz.asm):06368                 LDD     ,X
1E8B C30001           (          xyz.asm):06369                 ADDD    #1
1E8E ED84             (          xyz.asm):06370                 STD     ,X
                      (          xyz.asm):06371         * optim: removeUselessOps
     1E90             (          xyz.asm):06372         L00664  EQU     *               else
                      (          xyz.asm):06373         * Useless label L00665 removed
     1E90             (          xyz.asm):06374         L00662  EQU     *               end if
     1E90             (          xyz.asm):06375         L00651  EQU     *               end if
1E90 AE44             (          xyz.asm):06376                 LDX     4,U             variable p
1E92 3002             (          xyz.asm):06377                 LEAX    2,X             member p of picolParser
1E94 EC84             (          xyz.asm):06378                 LDD     ,X
1E96 C30001           (          xyz.asm):06379                 ADDD    #1
1E99 ED84             (          xyz.asm):06380                 STD     ,X
                      (          xyz.asm):06381         * optim: removeUselessOps
1E9B AE44             (          xyz.asm):06382                 LDX     4,U             variable p
1E9D 3004             (          xyz.asm):06383                 LEAX    4,X             member len of picolParser
1E9F EC84             (          xyz.asm):06384                 LDD     ,X
1EA1 830001           (          xyz.asm):06385                 SUBD    #1
1EA4 ED84             (          xyz.asm):06386                 STD     ,X
1EA6 C30001           (          xyz.asm):06387                 ADDD    #1              post increment yields initial value
     1EA9             (          xyz.asm):06388         L00646  EQU     *               while condition at xyz.c:600
1EA9 16FF35           (          xyz.asm):06389                 LBRA    L00645          go to start of while body
                      (          xyz.asm):06390         * Useless label L00647 removed
                      (          xyz.asm):06391         * Line xyz.c:617: return with value
                      (          xyz.asm):06392         * optim: instrFollowingUncondBranch
                      (          xyz.asm):06393         * optim: instrFollowingUncondBranch
                      (          xyz.asm):06394         * optim: branchToNextLocation
     1EAC             (          xyz.asm):06395         L00038  EQU     *               end of picolParseBrace()
1EAC 32C4             (          xyz.asm):06396                 LEAS    ,U
1EAE 35C0             (          xyz.asm):06397                 PULS    U,PC
                      (          xyz.asm):06398         * END FUNCTION picolParseBrace(): defined at xyz.c:597
     1EB0             (          xyz.asm):06399         funcend_picolParseBrace EQU *
     00FF             (          xyz.asm):06400         funcsize_picolParseBrace        EQU     funcend_picolParseBrace-_picolParseBrace
                      (          xyz.asm):06401         
                      (          xyz.asm):06402         
                      (          xyz.asm):06403         *******************************************************************************
                      (          xyz.asm):06404         
                      (          xyz.asm):06405         * FUNCTION picolParseCommand(): defined at xyz.c:549
     1EB0             (          xyz.asm):06406         _picolParseCommand      EQU     *
1EB0 3440             (          xyz.asm):06407                 PSHS    U
1EB2 170B97           (          xyz.asm):06408                 LBSR    _stkcheck
1EB5 FFBC             (          xyz.asm):06409                 FDB     -68             argument for _stkcheck
1EB7 33E4             (          xyz.asm):06410                 LEAU    ,S
1EB9 327C             (          xyz.asm):06411                 LEAS    -4,S
                      (          xyz.asm):06412         * Formal parameters and locals:
                      (          xyz.asm):06413         *   p: struct picolParser *; 2 bytes at 4,U
                      (          xyz.asm):06414         *   level: int; 2 bytes at -4,U
                      (          xyz.asm):06415         *   blevel: int; 2 bytes at -2,U
                      (          xyz.asm):06416         * Line xyz.c:550: init of variable level
1EBB 4F               (          xyz.asm):06417                 CLRA
1EBC C601             (          xyz.asm):06418                 LDB     #$01            1
1EBE ED5C             (          xyz.asm):06419                 STD     -4,U            variable level
                      (          xyz.asm):06420         * Line xyz.c:551: init of variable blevel
                      (          xyz.asm):06421         * optim: stripExtraClrA_B
1EC0 5F               (          xyz.asm):06422                 CLRB
1EC1 ED5E             (          xyz.asm):06423                 STD     -2,U            variable blevel
                      (          xyz.asm):06424         * Line xyz.c:552: assignment: =
1EC3 AE44             (          xyz.asm):06425                 LDX     4,U             variable p
1EC5 3002             (          xyz.asm):06426                 LEAX    2,X             member p of picolParser
1EC7 EC84             (          xyz.asm):06427                 LDD     ,X
1EC9 C30001           (          xyz.asm):06428                 ADDD    #1
1ECC ED84             (          xyz.asm):06429                 STD     ,X
                      (          xyz.asm):06430         * optim: stripUselessPushPull
1ECE AE44             (          xyz.asm):06431                 LDX     4,U             variable p
                      (          xyz.asm):06432         * optim: optimizeLeax
                      (          xyz.asm):06433         * optim: stripUselessPushPull
1ED0 ED06             (          xyz.asm):06434                 STD     6,X             optim: optimizeLeax
1ED2 AE44             (          xyz.asm):06435                 LDX     4,U             variable p
1ED4 3004             (          xyz.asm):06436                 LEAX    4,X             member len of picolParser
1ED6 EC84             (          xyz.asm):06437                 LDD     ,X
1ED8 830001           (          xyz.asm):06438                 SUBD    #1
1EDB ED84             (          xyz.asm):06439                 STD     ,X
1EDD C30001           (          xyz.asm):06440                 ADDD    #1              post increment yields initial value
                      (          xyz.asm):06441         * Line xyz.c:553: while
1EE0 1600D4           (          xyz.asm):06442                 LBRA    L00667          jump to while condition
     1EE3             (          xyz.asm):06443         L00666  EQU     *               while body
                      (          xyz.asm):06444         * Line xyz.c:554: if
1EE3 AE44             (          xyz.asm):06445                 LDX     4,U             variable p
1EE5 EC04             (          xyz.asm):06446                 LDD     4,X             member len of picolParser
                      (          xyz.asm):06447         * optim: loadCmpZeroBeqOrBne
1EE7 2603             (          xyz.asm):06448                 BNE     L00670
                      (          xyz.asm):06449         * optim: condBranchOverUncondBranch
                      (          xyz.asm):06450         * Useless label L00669 removed
1EE9 1600CE           (          xyz.asm):06451                 LBRA    L00668          break
                      (          xyz.asm):06452         * optim: instrFollowingUncondBranch
     1EEC             (          xyz.asm):06453         L00670  EQU     *               else
                      (          xyz.asm):06454         * Line xyz.c:556: if
1EEC C65B             (          xyz.asm):06455                 LDB     #$5B            optim: lddToLDB
1EEE 1D               (          xyz.asm):06456                 SEX                     promotion of binary operand
1EEF 3406             (          xyz.asm):06457                 PSHS    B,A
1EF1 AE44             (          xyz.asm):06458                 LDX     4,U             variable p
                      (          xyz.asm):06459         * optim: optimizeLdx
                      (          xyz.asm):06460         * optim: removeTfrDX
1EF3 E69802           (          xyz.asm):06461                 LDB     [2,X]           optim: optimizeLdx
1EF6 1D               (          xyz.asm):06462                 SEX                     promotion of binary operand
1EF7 10A3E1           (          xyz.asm):06463                 CMPD    ,S++
1EFA 2613             (          xyz.asm):06464                 BNE     L00673
                      (          xyz.asm):06465         * optim: condBranchOverUncondBranch
                      (          xyz.asm):06466         * Useless label L00674 removed
1EFC EC5E             (          xyz.asm):06467                 LDD     -2,U            variable blevel, declared at xyz.c:551
                      (          xyz.asm):06468         * optim: loadCmpZeroBeqOrBne
1EFE 260F             (          xyz.asm):06469                 BNE     L00673
                      (          xyz.asm):06470         * optim: condBranchOverUncondBranch
                      (          xyz.asm):06471         * Useless label L00672 removed
1F00 305C             (          xyz.asm):06472                 LEAX    -4,U            variable level, declared at xyz.c:550
1F02 EC84             (          xyz.asm):06473                 LDD     ,X
1F04 C30001           (          xyz.asm):06474                 ADDD    #1
1F07 ED84             (          xyz.asm):06475                 STD     ,X
1F09 830001           (          xyz.asm):06476                 SUBD    #1              post increment yields initial value
1F0C 16008F           (          xyz.asm):06477                 LBRA    L00675          jump over else clause
     1F0F             (          xyz.asm):06478         L00673  EQU     *               else
                      (          xyz.asm):06479         * Line xyz.c:558: if
1F0F C65D             (          xyz.asm):06480                 LDB     #$5D            optim: lddToLDB
1F11 1D               (          xyz.asm):06481                 SEX                     promotion of binary operand
1F12 3406             (          xyz.asm):06482                 PSHS    B,A
1F14 AE44             (          xyz.asm):06483                 LDX     4,U             variable p
                      (          xyz.asm):06484         * optim: optimizeLdx
                      (          xyz.asm):06485         * optim: removeTfrDX
1F16 E69802           (          xyz.asm):06486                 LDB     [2,X]           optim: optimizeLdx
1F19 1D               (          xyz.asm):06487                 SEX                     promotion of binary operand
1F1A 10A3E1           (          xyz.asm):06488                 CMPD    ,S++
1F1D 2618             (          xyz.asm):06489                 BNE     L00677
                      (          xyz.asm):06490         * optim: condBranchOverUncondBranch
                      (          xyz.asm):06491         * Useless label L00678 removed
1F1F EC5E             (          xyz.asm):06492                 LDD     -2,U            variable blevel, declared at xyz.c:551
                      (          xyz.asm):06493         * optim: loadCmpZeroBeqOrBne
1F21 2614             (          xyz.asm):06494                 BNE     L00677
                      (          xyz.asm):06495         * optim: condBranchOverUncondBranch
                      (          xyz.asm):06496         * Useless label L00676 removed
                      (          xyz.asm):06497         * Line xyz.c:559: if
1F23 305C             (          xyz.asm):06498                 LEAX    -4,U            variable level, declared at xyz.c:550
1F25 EC84             (          xyz.asm):06499                 LDD     ,X
1F27 830001           (          xyz.asm):06500                 SUBD    #1
1F2A ED84             (          xyz.asm):06501                 STD     ,X
1F2C C30000           (          xyz.asm):06502                 ADDD    #0
1F2F 2603             (          xyz.asm):06503                 BNE     L00680
                      (          xyz.asm):06504         * optim: branchToNextLocation
                      (          xyz.asm):06505         * Useless label L00679 removed
1F31 160086           (          xyz.asm):06506                 LBRA    L00668          break
     1F34             (          xyz.asm):06507         L00680  EQU     *               else
                      (          xyz.asm):06508         * Useless label L00681 removed
1F34 160067           (          xyz.asm):06509                 LBRA    L00682          jump over else clause
     1F37             (          xyz.asm):06510         L00677  EQU     *               else
                      (          xyz.asm):06511         * Line xyz.c:560: if
1F37 C65C             (          xyz.asm):06512                 LDB     #$5C            optim: lddToLDB
1F39 1D               (          xyz.asm):06513                 SEX                     promotion of binary operand
1F3A 3406             (          xyz.asm):06514                 PSHS    B,A
1F3C AE44             (          xyz.asm):06515                 LDX     4,U             variable p
                      (          xyz.asm):06516         * optim: optimizeLdx
                      (          xyz.asm):06517         * optim: removeTfrDX
1F3E E69802           (          xyz.asm):06518                 LDB     [2,X]           optim: optimizeLdx
1F41 1D               (          xyz.asm):06519                 SEX                     promotion of binary operand
1F42 10A3E1           (          xyz.asm):06520                 CMPD    ,S++
1F45 261C             (          xyz.asm):06521                 BNE     L00684
                      (          xyz.asm):06522         * optim: condBranchOverUncondBranch
                      (          xyz.asm):06523         * Useless label L00683 removed
1F47 AE44             (          xyz.asm):06524                 LDX     4,U             variable p
1F49 3002             (          xyz.asm):06525                 LEAX    2,X             member p of picolParser
1F4B EC84             (          xyz.asm):06526                 LDD     ,X
1F4D C30001           (          xyz.asm):06527                 ADDD    #1
1F50 ED84             (          xyz.asm):06528                 STD     ,X
                      (          xyz.asm):06529         * optim: removeUselessOps
1F52 AE44             (          xyz.asm):06530                 LDX     4,U             variable p
1F54 3004             (          xyz.asm):06531                 LEAX    4,X             member len of picolParser
1F56 EC84             (          xyz.asm):06532                 LDD     ,X
1F58 830001           (          xyz.asm):06533                 SUBD    #1
1F5B ED84             (          xyz.asm):06534                 STD     ,X
1F5D C30001           (          xyz.asm):06535                 ADDD    #1              post increment yields initial value
1F60 16003B           (          xyz.asm):06536                 LBRA    L00685          jump over else clause
     1F63             (          xyz.asm):06537         L00684  EQU     *               else
                      (          xyz.asm):06538         * Line xyz.c:562: if
1F63 C67B             (          xyz.asm):06539                 LDB     #$7B            optim: lddToLDB
1F65 1D               (          xyz.asm):06540                 SEX                     promotion of binary operand
1F66 3406             (          xyz.asm):06541                 PSHS    B,A
1F68 AE44             (          xyz.asm):06542                 LDX     4,U             variable p
                      (          xyz.asm):06543         * optim: optimizeLdx
                      (          xyz.asm):06544         * optim: removeTfrDX
1F6A E69802           (          xyz.asm):06545                 LDB     [2,X]           optim: optimizeLdx
1F6D 1D               (          xyz.asm):06546                 SEX                     promotion of binary operand
1F6E 10A3E1           (          xyz.asm):06547                 CMPD    ,S++
1F71 260E             (          xyz.asm):06548                 BNE     L00687
                      (          xyz.asm):06549         * optim: condBranchOverUncondBranch
                      (          xyz.asm):06550         * Useless label L00686 removed
1F73 305E             (          xyz.asm):06551                 LEAX    -2,U            variable blevel, declared at xyz.c:551
1F75 EC84             (          xyz.asm):06552                 LDD     ,X
1F77 C30001           (          xyz.asm):06553                 ADDD    #1
1F7A ED84             (          xyz.asm):06554                 STD     ,X
1F7C 830001           (          xyz.asm):06555                 SUBD    #1              post increment yields initial value
1F7F 201D             (          xyz.asm):06556                 BRA     L00688          jump over else clause
     1F81             (          xyz.asm):06557         L00687  EQU     *               else
                      (          xyz.asm):06558         * Line xyz.c:564: if
1F81 C67D             (          xyz.asm):06559                 LDB     #$7D            optim: lddToLDB
1F83 1D               (          xyz.asm):06560                 SEX                     promotion of binary operand
1F84 3406             (          xyz.asm):06561                 PSHS    B,A
1F86 AE44             (          xyz.asm):06562                 LDX     4,U             variable p
                      (          xyz.asm):06563         * optim: optimizeLdx
                      (          xyz.asm):06564         * optim: removeTfrDX
1F88 E69802           (          xyz.asm):06565                 LDB     [2,X]           optim: optimizeLdx
1F8B 1D               (          xyz.asm):06566                 SEX                     promotion of binary operand
1F8C 10A3E1           (          xyz.asm):06567                 CMPD    ,S++
1F8F 260D             (          xyz.asm):06568                 BNE     L00690
                      (          xyz.asm):06569         * optim: condBranchOverUncondBranch
                      (          xyz.asm):06570         * Useless label L00689 removed
                      (          xyz.asm):06571         * Line xyz.c:565: if
1F91 EC5E             (          xyz.asm):06572                 LDD     -2,U            variable blevel, declared at xyz.c:551
                      (          xyz.asm):06573         * optim: loadCmpZeroBeqOrBne
1F93 2709             (          xyz.asm):06574                 BEQ     L00692
                      (          xyz.asm):06575         * optim: condBranchOverUncondBranch
                      (          xyz.asm):06576         * Useless label L00691 removed
1F95 305E             (          xyz.asm):06577                 LEAX    -2,U            variable blevel, declared at xyz.c:551
1F97 EC84             (          xyz.asm):06578                 LDD     ,X
1F99 830001           (          xyz.asm):06579                 SUBD    #1
1F9C ED84             (          xyz.asm):06580                 STD     ,X
                      (          xyz.asm):06581         * optim: removeUselessOps
     1F9E             (          xyz.asm):06582         L00692  EQU     *               else
                      (          xyz.asm):06583         * Useless label L00693 removed
     1F9E             (          xyz.asm):06584         L00690  EQU     *               else
                      (          xyz.asm):06585         * Useless label L00694 removed
     1F9E             (          xyz.asm):06586         L00688  EQU     *               end if
     1F9E             (          xyz.asm):06587         L00685  EQU     *               end if
     1F9E             (          xyz.asm):06588         L00682  EQU     *               end if
     1F9E             (          xyz.asm):06589         L00675  EQU     *               end if
                      (          xyz.asm):06590         * Useless label L00671 removed
1F9E AE44             (          xyz.asm):06591                 LDX     4,U             variable p
1FA0 3002             (          xyz.asm):06592                 LEAX    2,X             member p of picolParser
1FA2 EC84             (          xyz.asm):06593                 LDD     ,X
1FA4 C30001           (          xyz.asm):06594                 ADDD    #1
1FA7 ED84             (          xyz.asm):06595                 STD     ,X
                      (          xyz.asm):06596         * optim: removeUselessOps
1FA9 AE44             (          xyz.asm):06597                 LDX     4,U             variable p
1FAB 3004             (          xyz.asm):06598                 LEAX    4,X             member len of picolParser
1FAD EC84             (          xyz.asm):06599                 LDD     ,X
1FAF 830001           (          xyz.asm):06600                 SUBD    #1
1FB2 ED84             (          xyz.asm):06601                 STD     ,X
1FB4 C30001           (          xyz.asm):06602                 ADDD    #1              post increment yields initial value
     1FB7             (          xyz.asm):06603         L00667  EQU     *               while condition at xyz.c:553
1FB7 16FF29           (          xyz.asm):06604                 LBRA    L00666          go to start of while body
     1FBA             (          xyz.asm):06605         L00668  EQU     *               after end of while starting at xyz.c:553
                      (          xyz.asm):06606         * Line xyz.c:569: assignment: =
                      (          xyz.asm):06607         * optim: optimizeStackOperations5
                      (          xyz.asm):06608         * optim: optimizeStackOperations5
                      (          xyz.asm):06609         * optim: optimizeStackOperations5
1FBA AE44             (          xyz.asm):06610                 LDX     4,U             variable p
1FBC EC02             (          xyz.asm):06611                 LDD     2,X             member p of picolParser
1FBE 830001           (          xyz.asm):06612                 SUBD    #$01            optim: optimizeStackOperations5
                      (          xyz.asm):06613         * optim: stripUselessPushPull
1FC1 AE44             (          xyz.asm):06614                 LDX     4,U             variable p
                      (          xyz.asm):06615         * optim: optimizeLeax
                      (          xyz.asm):06616         * optim: stripUselessPushPull
1FC3 ED08             (          xyz.asm):06617                 STD     8,X             optim: optimizeLeax
                      (          xyz.asm):06618         * Line xyz.c:570: assignment: =
1FC5 4F               (          xyz.asm):06619                 CLRA
1FC6 C602             (          xyz.asm):06620                 LDB     #$02            decimal 2 signed
                      (          xyz.asm):06621         * optim: stripUselessPushPull
1FC8 AE44             (          xyz.asm):06622                 LDX     4,U             variable p
                      (          xyz.asm):06623         * optim: optimizeLeax
                      (          xyz.asm):06624         * optim: stripUselessPushPull
1FCA ED0A             (          xyz.asm):06625                 STD     10,X            optim: optimizeLeax
                      (          xyz.asm):06626         * Line xyz.c:571: if
1FCC C65D             (          xyz.asm):06627                 LDB     #$5D            optim: lddToLDB
1FCE 1D               (          xyz.asm):06628                 SEX                     promotion of binary operand
1FCF 3406             (          xyz.asm):06629                 PSHS    B,A
1FD1 AE44             (          xyz.asm):06630                 LDX     4,U             variable p
                      (          xyz.asm):06631         * optim: optimizeLdx
                      (          xyz.asm):06632         * optim: removeTfrDX
1FD3 E69802           (          xyz.asm):06633                 LDB     [2,X]           optim: optimizeLdx
1FD6 1D               (          xyz.asm):06634                 SEX                     promotion of binary operand
1FD7 10A3E1           (          xyz.asm):06635                 CMPD    ,S++
1FDA 2616             (          xyz.asm):06636                 BNE     L00696
                      (          xyz.asm):06637         * optim: condBranchOverUncondBranch
                      (          xyz.asm):06638         * Useless label L00695 removed
1FDC AE44             (          xyz.asm):06639                 LDX     4,U             variable p
1FDE 3002             (          xyz.asm):06640                 LEAX    2,X             member p of picolParser
1FE0 EC84             (          xyz.asm):06641                 LDD     ,X
1FE2 C30001           (          xyz.asm):06642                 ADDD    #1
1FE5 ED84             (          xyz.asm):06643                 STD     ,X
                      (          xyz.asm):06644         * optim: removeUselessOps
1FE7 AE44             (          xyz.asm):06645                 LDX     4,U             variable p
1FE9 3004             (          xyz.asm):06646                 LEAX    4,X             member len of picolParser
1FEB EC84             (          xyz.asm):06647                 LDD     ,X
1FED 830001           (          xyz.asm):06648                 SUBD    #1
1FF0 ED84             (          xyz.asm):06649                 STD     ,X
                      (          xyz.asm):06650         * optim: removeUselessOps
     1FF2             (          xyz.asm):06651         L00696  EQU     *               else
                      (          xyz.asm):06652         * Useless label L00697 removed
                      (          xyz.asm):06653         * Line xyz.c:574: return with value
1FF2 4F               (          xyz.asm):06654                 CLRA
1FF3 5F               (          xyz.asm):06655                 CLRB
                      (          xyz.asm):06656         * optim: branchToNextLocation
                      (          xyz.asm):06657         * Useless label L00036 removed
1FF4 32C4             (          xyz.asm):06658                 LEAS    ,U
1FF6 35C0             (          xyz.asm):06659                 PULS    U,PC
                      (          xyz.asm):06660         * END FUNCTION picolParseCommand(): defined at xyz.c:549
     1FF8             (          xyz.asm):06661         funcend_picolParseCommand       EQU *
     0148             (          xyz.asm):06662         funcsize_picolParseCommand      EQU     funcend_picolParseCommand-_picolParseCommand
                      (          xyz.asm):06663         
                      (          xyz.asm):06664         
                      (          xyz.asm):06665         *******************************************************************************
                      (          xyz.asm):06666         
                      (          xyz.asm):06667         * FUNCTION picolParseComment(): defined at xyz.c:666
     1FF8             (          xyz.asm):06668         _picolParseComment      EQU     *
1FF8 3440             (          xyz.asm):06669                 PSHS    U
1FFA 170A4F           (          xyz.asm):06670                 LBSR    _stkcheck
1FFD FFC0             (          xyz.asm):06671                 FDB     -64             argument for _stkcheck
1FFF 33E4             (          xyz.asm):06672                 LEAU    ,S
                      (          xyz.asm):06673         * Formal parameters and locals:
                      (          xyz.asm):06674         *   p: struct picolParser *; 2 bytes at 4,U
                      (          xyz.asm):06675         * Line xyz.c:667: while
2001 2016             (          xyz.asm):06676                 BRA     L00699          jump to while condition
     2003             (          xyz.asm):06677         L00698  EQU     *               while body
2003 AE44             (          xyz.asm):06678                 LDX     4,U             variable p
2005 3002             (          xyz.asm):06679                 LEAX    2,X             member p of picolParser
2007 EC84             (          xyz.asm):06680                 LDD     ,X
2009 C30001           (          xyz.asm):06681                 ADDD    #1
200C ED84             (          xyz.asm):06682                 STD     ,X
                      (          xyz.asm):06683         * optim: removeUselessOps
200E AE44             (          xyz.asm):06684                 LDX     4,U             variable p
2010 3004             (          xyz.asm):06685                 LEAX    4,X             member len of picolParser
2012 EC84             (          xyz.asm):06686                 LDD     ,X
2014 830001           (          xyz.asm):06687                 SUBD    #1
2017 ED84             (          xyz.asm):06688                 STD     ,X
                      (          xyz.asm):06689         * optim: removeUselessOps
     2019             (          xyz.asm):06690         L00699  EQU     *               while condition at xyz.c:667
2019 AE44             (          xyz.asm):06691                 LDX     4,U             variable p
201B EC04             (          xyz.asm):06692                 LDD     4,X             member len of picolParser
                      (          xyz.asm):06693         * optim: loadCmpZeroBeqOrBne
201D 2710             (          xyz.asm):06694                 BEQ     L00700
                      (          xyz.asm):06695         * optim: condBranchOverUncondBranch
                      (          xyz.asm):06696         * Useless label L00701 removed
201F C60A             (          xyz.asm):06697                 LDB     #$0A            optim: lddToLDB
2021 1D               (          xyz.asm):06698                 SEX                     promotion of binary operand
2022 3406             (          xyz.asm):06699                 PSHS    B,A
2024 AE44             (          xyz.asm):06700                 LDX     4,U             variable p
                      (          xyz.asm):06701         * optim: optimizeLdx
                      (          xyz.asm):06702         * optim: removeTfrDX
2026 E69802           (          xyz.asm):06703                 LDB     [2,X]           optim: optimizeLdx
2029 1D               (          xyz.asm):06704                 SEX                     promotion of binary operand
202A 10A3E1           (          xyz.asm):06705                 CMPD    ,S++
202D 26D4             (          xyz.asm):06706                 BNE     L00698
                      (          xyz.asm):06707         * optim: branchToNextLocation
     202F             (          xyz.asm):06708         L00700  EQU     *               after end of while starting at xyz.c:667
                      (          xyz.asm):06709         * Line xyz.c:670: return with value
202F 4F               (          xyz.asm):06710                 CLRA
2030 5F               (          xyz.asm):06711                 CLRB
                      (          xyz.asm):06712         * optim: branchToNextLocation
                      (          xyz.asm):06713         * Useless label L00040 removed
2031 32C4             (          xyz.asm):06714                 LEAS    ,U
2033 35C0             (          xyz.asm):06715                 PULS    U,PC
                      (          xyz.asm):06716         * END FUNCTION picolParseComment(): defined at xyz.c:666
     2035             (          xyz.asm):06717         funcend_picolParseComment       EQU *
     003D             (          xyz.asm):06718         funcsize_picolParseComment      EQU     funcend_picolParseComment-_picolParseComment
                      (          xyz.asm):06719         
                      (          xyz.asm):06720         
                      (          xyz.asm):06721         *******************************************************************************
                      (          xyz.asm):06722         
                      (          xyz.asm):06723         * FUNCTION picolParseEol(): defined at xyz.c:537
     2035             (          xyz.asm):06724         _picolParseEol  EQU     *
2035 3440             (          xyz.asm):06725                 PSHS    U
2037 170A12           (          xyz.asm):06726                 LBSR    _stkcheck
203A FFC0             (          xyz.asm):06727                 FDB     -64             argument for _stkcheck
203C 33E4             (          xyz.asm):06728                 LEAU    ,S
                      (          xyz.asm):06729         * Formal parameters and locals:
                      (          xyz.asm):06730         *   p: struct picolParser *; 2 bytes at 4,U
                      (          xyz.asm):06731         * Line xyz.c:538: assignment: =
203E AE44             (          xyz.asm):06732                 LDX     4,U             variable p
2040 EC02             (          xyz.asm):06733                 LDD     2,X             member p of picolParser
                      (          xyz.asm):06734         * optim: stripUselessPushPull
2042 AE44             (          xyz.asm):06735                 LDX     4,U             variable p
                      (          xyz.asm):06736         * optim: optimizeLeax
                      (          xyz.asm):06737         * optim: stripUselessPushPull
2044 ED06             (          xyz.asm):06738                 STD     6,X             optim: optimizeLeax
                      (          xyz.asm):06739         * Line xyz.c:540: while
2046 201C             (          xyz.asm):06740                 BRA     L00703          jump to while condition
     2048             (          xyz.asm):06741         L00702  EQU     *               while body
2048 AE44             (          xyz.asm):06742                 LDX     4,U             variable p
204A 3002             (          xyz.asm):06743                 LEAX    2,X             member p of picolParser
204C EC84             (          xyz.asm):06744                 LDD     ,X
204E C30001           (          xyz.asm):06745                 ADDD    #1
2051 ED84             (          xyz.asm):06746                 STD     ,X
2053 830001           (          xyz.asm):06747                 SUBD    #1              post increment yields initial value
2056 AE44             (          xyz.asm):06748                 LDX     4,U             variable p
2058 3004             (          xyz.asm):06749                 LEAX    4,X             member len of picolParser
205A EC84             (          xyz.asm):06750                 LDD     ,X
205C 830001           (          xyz.asm):06751                 SUBD    #1
205F ED84             (          xyz.asm):06752                 STD     ,X
2061 C30001           (          xyz.asm):06753                 ADDD    #1              post increment yields initial value
     2064             (          xyz.asm):06754         L00703  EQU     *               while condition at xyz.c:540
2064 C620             (          xyz.asm):06755                 LDB     #$20            optim: lddToLDB
2066 1D               (          xyz.asm):06756                 SEX                     promotion of binary operand
2067 3406             (          xyz.asm):06757                 PSHS    B,A
2069 AE44             (          xyz.asm):06758                 LDX     4,U             variable p
                      (          xyz.asm):06759         * optim: optimizeLdx
                      (          xyz.asm):06760         * optim: removeTfrDX
206B E69802           (          xyz.asm):06761                 LDB     [2,X]           optim: optimizeLdx
206E 1D               (          xyz.asm):06762                 SEX                     promotion of binary operand
206F 10A3E1           (          xyz.asm):06763                 CMPD    ,S++
2072 27D4             (          xyz.asm):06764                 BEQ     L00702
                      (          xyz.asm):06765         * optim: branchToNextLocation
                      (          xyz.asm):06766         * Useless label L00708 removed
2074 C609             (          xyz.asm):06767                 LDB     #$09            optim: lddToLDB
2076 1D               (          xyz.asm):06768                 SEX                     promotion of binary operand
2077 3406             (          xyz.asm):06769                 PSHS    B,A
2079 AE44             (          xyz.asm):06770                 LDX     4,U             variable p
                      (          xyz.asm):06771         * optim: optimizeLdx
                      (          xyz.asm):06772         * optim: removeTfrDX
207B E69802           (          xyz.asm):06773                 LDB     [2,X]           optim: optimizeLdx
207E 1D               (          xyz.asm):06774                 SEX                     promotion of binary operand
207F 10A3E1           (          xyz.asm):06775                 CMPD    ,S++
2082 27C4             (          xyz.asm):06776                 BEQ     L00702
                      (          xyz.asm):06777         * optim: branchToNextLocation
                      (          xyz.asm):06778         * Useless label L00707 removed
2084 C60A             (          xyz.asm):06779                 LDB     #$0A            optim: lddToLDB
2086 1D               (          xyz.asm):06780                 SEX                     promotion of binary operand
2087 3406             (          xyz.asm):06781                 PSHS    B,A
2089 AE44             (          xyz.asm):06782                 LDX     4,U             variable p
                      (          xyz.asm):06783         * optim: optimizeLdx
                      (          xyz.asm):06784         * optim: removeTfrDX
208B E69802           (          xyz.asm):06785                 LDB     [2,X]           optim: optimizeLdx
208E 1D               (          xyz.asm):06786                 SEX                     promotion of binary operand
208F 10A3E1           (          xyz.asm):06787                 CMPD    ,S++
2092 1027FFB2         (          xyz.asm):06788                 LBEQ    L00702
                      (          xyz.asm):06789         * optim: branchToNextLocation
                      (          xyz.asm):06790         * Useless label L00706 removed
2096 C60D             (          xyz.asm):06791                 LDB     #$0D            optim: lddToLDB
2098 1D               (          xyz.asm):06792                 SEX                     promotion of binary operand
2099 3406             (          xyz.asm):06793                 PSHS    B,A
209B AE44             (          xyz.asm):06794                 LDX     4,U             variable p
                      (          xyz.asm):06795         * optim: optimizeLdx
                      (          xyz.asm):06796         * optim: removeTfrDX
209D E69802           (          xyz.asm):06797                 LDB     [2,X]           optim: optimizeLdx
20A0 1D               (          xyz.asm):06798                 SEX                     promotion of binary operand
20A1 10A3E1           (          xyz.asm):06799                 CMPD    ,S++
20A4 1027FFA0         (          xyz.asm):06800                 LBEQ    L00702
                      (          xyz.asm):06801         * optim: branchToNextLocation
                      (          xyz.asm):06802         * Useless label L00705 removed
20A8 C63B             (          xyz.asm):06803                 LDB     #$3B            optim: lddToLDB
20AA 1D               (          xyz.asm):06804                 SEX                     promotion of binary operand
20AB 3406             (          xyz.asm):06805                 PSHS    B,A
20AD AE44             (          xyz.asm):06806                 LDX     4,U             variable p
                      (          xyz.asm):06807         * optim: optimizeLdx
                      (          xyz.asm):06808         * optim: removeTfrDX
20AF E69802           (          xyz.asm):06809                 LDB     [2,X]           optim: optimizeLdx
20B2 1D               (          xyz.asm):06810                 SEX                     promotion of binary operand
20B3 10A3E1           (          xyz.asm):06811                 CMPD    ,S++
20B6 1027FF8E         (          xyz.asm):06812                 LBEQ    L00702
                      (          xyz.asm):06813         * optim: branchToNextLocation
                      (          xyz.asm):06814         * Useless label L00704 removed
                      (          xyz.asm):06815         * Line xyz.c:544: assignment: =
                      (          xyz.asm):06816         * optim: optimizeStackOperations5
                      (          xyz.asm):06817         * optim: optimizeStackOperations5
                      (          xyz.asm):06818         * optim: optimizeStackOperations5
20BA AE44             (          xyz.asm):06819                 LDX     4,U             variable p
20BC EC02             (          xyz.asm):06820                 LDD     2,X             member p of picolParser
20BE 830001           (          xyz.asm):06821                 SUBD    #$01            optim: optimizeStackOperations5
                      (          xyz.asm):06822         * optim: stripUselessPushPull
20C1 AE44             (          xyz.asm):06823                 LDX     4,U             variable p
                      (          xyz.asm):06824         * optim: optimizeLeax
                      (          xyz.asm):06825         * optim: stripUselessPushPull
20C3 ED08             (          xyz.asm):06826                 STD     8,X             optim: optimizeLeax
                      (          xyz.asm):06827         * Line xyz.c:545: assignment: =
20C5 4F               (          xyz.asm):06828                 CLRA
20C6 C605             (          xyz.asm):06829                 LDB     #$05            decimal 5 signed
                      (          xyz.asm):06830         * optim: stripUselessPushPull
20C8 AE44             (          xyz.asm):06831                 LDX     4,U             variable p
                      (          xyz.asm):06832         * optim: optimizeLeax
                      (          xyz.asm):06833         * optim: stripUselessPushPull
20CA ED0A             (          xyz.asm):06834                 STD     10,X            optim: optimizeLeax
                      (          xyz.asm):06835         * Line xyz.c:546: return with value
                      (          xyz.asm):06836         * optim: removeClr
20CC 5F               (          xyz.asm):06837                 CLRB
                      (          xyz.asm):06838         * optim: branchToNextLocation
                      (          xyz.asm):06839         * Useless label L00035 removed
20CD 32C4             (          xyz.asm):06840                 LEAS    ,U
20CF 35C0             (          xyz.asm):06841                 PULS    U,PC
                      (          xyz.asm):06842         * END FUNCTION picolParseEol(): defined at xyz.c:537
     20D1             (          xyz.asm):06843         funcend_picolParseEol   EQU *
     009C             (          xyz.asm):06844         funcsize_picolParseEol  EQU     funcend_picolParseEol-_picolParseEol
                      (          xyz.asm):06845         
                      (          xyz.asm):06846         
                      (          xyz.asm):06847         *******************************************************************************
                      (          xyz.asm):06848         
                      (          xyz.asm):06849         * FUNCTION picolParseSep(): defined at xyz.c:527
     20D1             (          xyz.asm):06850         _picolParseSep  EQU     *
20D1 3440             (          xyz.asm):06851                 PSHS    U
20D3 170976           (          xyz.asm):06852                 LBSR    _stkcheck
20D6 FFC0             (          xyz.asm):06853                 FDB     -64             argument for _stkcheck
20D8 33E4             (          xyz.asm):06854                 LEAU    ,S
                      (          xyz.asm):06855         * Formal parameters and locals:
                      (          xyz.asm):06856         *   p: struct picolParser *; 2 bytes at 4,U
                      (          xyz.asm):06857         * Line xyz.c:528: assignment: =
20DA AE44             (          xyz.asm):06858                 LDX     4,U             variable p
20DC EC02             (          xyz.asm):06859                 LDD     2,X             member p of picolParser
                      (          xyz.asm):06860         * optim: stripUselessPushPull
20DE AE44             (          xyz.asm):06861                 LDX     4,U             variable p
                      (          xyz.asm):06862         * optim: optimizeLeax
                      (          xyz.asm):06863         * optim: stripUselessPushPull
20E0 ED06             (          xyz.asm):06864                 STD     6,X             optim: optimizeLeax
                      (          xyz.asm):06865         * Line xyz.c:529: while
20E2 201C             (          xyz.asm):06866                 BRA     L00710          jump to while condition
     20E4             (          xyz.asm):06867         L00709  EQU     *               while body
20E4 AE44             (          xyz.asm):06868                 LDX     4,U             variable p
20E6 3002             (          xyz.asm):06869                 LEAX    2,X             member p of picolParser
20E8 EC84             (          xyz.asm):06870                 LDD     ,X
20EA C30001           (          xyz.asm):06871                 ADDD    #1
20ED ED84             (          xyz.asm):06872                 STD     ,X
20EF 830001           (          xyz.asm):06873                 SUBD    #1              post increment yields initial value
20F2 AE44             (          xyz.asm):06874                 LDX     4,U             variable p
20F4 3004             (          xyz.asm):06875                 LEAX    4,X             member len of picolParser
20F6 EC84             (          xyz.asm):06876                 LDD     ,X
20F8 830001           (          xyz.asm):06877                 SUBD    #1
20FB ED84             (          xyz.asm):06878                 STD     ,X
20FD C30001           (          xyz.asm):06879                 ADDD    #1              post increment yields initial value
     2100             (          xyz.asm):06880         L00710  EQU     *               while condition at xyz.c:529
2100 C620             (          xyz.asm):06881                 LDB     #$20            optim: lddToLDB
2102 1D               (          xyz.asm):06882                 SEX                     promotion of binary operand
2103 3406             (          xyz.asm):06883                 PSHS    B,A
2105 AE44             (          xyz.asm):06884                 LDX     4,U             variable p
                      (          xyz.asm):06885         * optim: optimizeLdx
                      (          xyz.asm):06886         * optim: removeTfrDX
2107 E69802           (          xyz.asm):06887                 LDB     [2,X]           optim: optimizeLdx
210A 1D               (          xyz.asm):06888                 SEX                     promotion of binary operand
210B 10A3E1           (          xyz.asm):06889                 CMPD    ,S++
210E 27D4             (          xyz.asm):06890                 BEQ     L00709
                      (          xyz.asm):06891         * optim: branchToNextLocation
                      (          xyz.asm):06892         * Useless label L00714 removed
2110 C609             (          xyz.asm):06893                 LDB     #$09            optim: lddToLDB
2112 1D               (          xyz.asm):06894                 SEX                     promotion of binary operand
2113 3406             (          xyz.asm):06895                 PSHS    B,A
2115 AE44             (          xyz.asm):06896                 LDX     4,U             variable p
                      (          xyz.asm):06897         * optim: optimizeLdx
                      (          xyz.asm):06898         * optim: removeTfrDX
2117 E69802           (          xyz.asm):06899                 LDB     [2,X]           optim: optimizeLdx
211A 1D               (          xyz.asm):06900                 SEX                     promotion of binary operand
211B 10A3E1           (          xyz.asm):06901                 CMPD    ,S++
211E 27C4             (          xyz.asm):06902                 BEQ     L00709
                      (          xyz.asm):06903         * optim: branchToNextLocation
                      (          xyz.asm):06904         * Useless label L00713 removed
2120 C60A             (          xyz.asm):06905                 LDB     #$0A            optim: lddToLDB
2122 1D               (          xyz.asm):06906                 SEX                     promotion of binary operand
2123 3406             (          xyz.asm):06907                 PSHS    B,A
2125 AE44             (          xyz.asm):06908                 LDX     4,U             variable p
                      (          xyz.asm):06909         * optim: optimizeLdx
                      (          xyz.asm):06910         * optim: removeTfrDX
2127 E69802           (          xyz.asm):06911                 LDB     [2,X]           optim: optimizeLdx
212A 1D               (          xyz.asm):06912                 SEX                     promotion of binary operand
212B 10A3E1           (          xyz.asm):06913                 CMPD    ,S++
212E 1027FFB2         (          xyz.asm):06914                 LBEQ    L00709
                      (          xyz.asm):06915         * optim: branchToNextLocation
                      (          xyz.asm):06916         * Useless label L00712 removed
2132 C60D             (          xyz.asm):06917                 LDB     #$0D            optim: lddToLDB
2134 1D               (          xyz.asm):06918                 SEX                     promotion of binary operand
2135 3406             (          xyz.asm):06919                 PSHS    B,A
2137 AE44             (          xyz.asm):06920                 LDX     4,U             variable p
                      (          xyz.asm):06921         * optim: optimizeLdx
                      (          xyz.asm):06922         * optim: removeTfrDX
2139 E69802           (          xyz.asm):06923                 LDB     [2,X]           optim: optimizeLdx
213C 1D               (          xyz.asm):06924                 SEX                     promotion of binary operand
213D 10A3E1           (          xyz.asm):06925                 CMPD    ,S++
2140 1027FFA0         (          xyz.asm):06926                 LBEQ    L00709
                      (          xyz.asm):06927         * optim: branchToNextLocation
                      (          xyz.asm):06928         * Useless label L00711 removed
                      (          xyz.asm):06929         * Line xyz.c:532: assignment: =
                      (          xyz.asm):06930         * optim: optimizeStackOperations5
                      (          xyz.asm):06931         * optim: optimizeStackOperations5
                      (          xyz.asm):06932         * optim: optimizeStackOperations5
2144 AE44             (          xyz.asm):06933                 LDX     4,U             variable p
2146 EC02             (          xyz.asm):06934                 LDD     2,X             member p of picolParser
2148 830001           (          xyz.asm):06935                 SUBD    #$01            optim: optimizeStackOperations5
                      (          xyz.asm):06936         * optim: stripUselessPushPull
214B AE44             (          xyz.asm):06937                 LDX     4,U             variable p
                      (          xyz.asm):06938         * optim: optimizeLeax
                      (          xyz.asm):06939         * optim: stripUselessPushPull
214D ED08             (          xyz.asm):06940                 STD     8,X             optim: optimizeLeax
                      (          xyz.asm):06941         * Line xyz.c:533: assignment: =
214F 4F               (          xyz.asm):06942                 CLRA
2150 C604             (          xyz.asm):06943                 LDB     #$04            decimal 4 signed
                      (          xyz.asm):06944         * optim: stripUselessPushPull
2152 AE44             (          xyz.asm):06945                 LDX     4,U             variable p
                      (          xyz.asm):06946         * optim: optimizeLeax
                      (          xyz.asm):06947         * optim: stripUselessPushPull
2154 ED0A             (          xyz.asm):06948                 STD     10,X            optim: optimizeLeax
                      (          xyz.asm):06949         * Line xyz.c:534: return with value
                      (          xyz.asm):06950         * optim: removeClr
2156 5F               (          xyz.asm):06951                 CLRB
                      (          xyz.asm):06952         * optim: branchToNextLocation
                      (          xyz.asm):06953         * Useless label L00034 removed
2157 32C4             (          xyz.asm):06954                 LEAS    ,U
2159 35C0             (          xyz.asm):06955                 PULS    U,PC
                      (          xyz.asm):06956         * END FUNCTION picolParseSep(): defined at xyz.c:527
     215B             (          xyz.asm):06957         funcend_picolParseSep   EQU *
     008A             (          xyz.asm):06958         funcsize_picolParseSep  EQU     funcend_picolParseSep-_picolParseSep
                      (          xyz.asm):06959         
                      (          xyz.asm):06960         
                      (          xyz.asm):06961         *******************************************************************************
                      (          xyz.asm):06962         
                      (          xyz.asm):06963         * FUNCTION picolParseString(): defined at xyz.c:620
     215B             (          xyz.asm):06964         _picolParseString       EQU     *
215B 3440             (          xyz.asm):06965                 PSHS    U
215D 1708EC           (          xyz.asm):06966                 LBSR    _stkcheck
2160 FFBE             (          xyz.asm):06967                 FDB     -66             argument for _stkcheck
2162 33E4             (          xyz.asm):06968                 LEAU    ,S
2164 327E             (          xyz.asm):06969                 LEAS    -2,S
                      (          xyz.asm):06970         * Formal parameters and locals:
                      (          xyz.asm):06971         *   p: struct picolParser *; 2 bytes at 4,U
                      (          xyz.asm):06972         *   newword: int; 2 bytes at -2,U
                      (          xyz.asm):06973         * Line xyz.c:621: init of variable newword
2166 4F               (          xyz.asm):06974                 CLRA
                      (          xyz.asm):06975         * optim: removeUselessOps
                      (          xyz.asm):06976         * PSHS B,A optim: optimizeStackOperations1
2167 AE44             (          xyz.asm):06977                 LDX     4,U             variable p
2169 EC0A             (          xyz.asm):06978                 LDD     10,X            member type of picolParser
216B 10830004         (          xyz.asm):06979                 CMPD    #4              optim: optimizeStackOperations1
216F 2703             (          xyz.asm):06980                 BEQ     L00719          if true
2171 5F               (          xyz.asm):06981                 CLRB
2172 2002             (          xyz.asm):06982                 BRA     L00720          false
     2174             (          xyz.asm):06983         L00719  EQU     *
2174 C601             (          xyz.asm):06984                 LDB     #1
     2176             (          xyz.asm):06985         L00720  EQU     *
2176 5D               (          xyz.asm):06986                 TSTB                    ||
2177 2613             (          xyz.asm):06987                 BNE     L00717          || yields true
2179 4F               (          xyz.asm):06988                 CLRA
                      (          xyz.asm):06989         * optim: removeUselessOps
                      (          xyz.asm):06990         * PSHS B,A optim: optimizeStackOperations1
217A AE44             (          xyz.asm):06991                 LDX     4,U             variable p
217C EC0A             (          xyz.asm):06992                 LDD     10,X            member type of picolParser
217E 10830005         (          xyz.asm):06993                 CMPD    #5              optim: optimizeStackOperations1
2182 2703             (          xyz.asm):06994                 BEQ     L00721          if true
2184 5F               (          xyz.asm):06995                 CLRB
2185 2002             (          xyz.asm):06996                 BRA     L00722          false
     2187             (          xyz.asm):06997         L00721  EQU     *
2187 C601             (          xyz.asm):06998                 LDB     #1
     2189             (          xyz.asm):06999         L00722  EQU     *
2189 5D               (          xyz.asm):07000                 TSTB                    ||
218A 2700             (          xyz.asm):07001                 BEQ     L00718
     218C             (          xyz.asm):07002         L00717  EQU     *               || at xyz.c:621 yields true, B != 0
     218C             (          xyz.asm):07003         L00718  EQU     *
218C 5D               (          xyz.asm):07004                 TSTB                    ||
218D 2613             (          xyz.asm):07005                 BNE     L00715          || yields true
218F 4F               (          xyz.asm):07006                 CLRA
                      (          xyz.asm):07007         * optim: removeUselessOps
                      (          xyz.asm):07008         * PSHS B,A optim: optimizeStackOperations1
2190 AE44             (          xyz.asm):07009                 LDX     4,U             variable p
2192 EC0A             (          xyz.asm):07010                 LDD     10,X            member type of picolParser
2194 10830001         (          xyz.asm):07011                 CMPD    #1              optim: optimizeStackOperations1
2198 2703             (          xyz.asm):07012                 BEQ     L00723          if true
219A 5F               (          xyz.asm):07013                 CLRB
219B 2002             (          xyz.asm):07014                 BRA     L00724          false
     219D             (          xyz.asm):07015         L00723  EQU     *
219D C601             (          xyz.asm):07016                 LDB     #1
     219F             (          xyz.asm):07017         L00724  EQU     *
219F 5D               (          xyz.asm):07018                 TSTB                    ||
21A0 2700             (          xyz.asm):07019                 BEQ     L00716
     21A2             (          xyz.asm):07020         L00715  EQU     *               || at xyz.c:621 yields true, B != 0
     21A2             (          xyz.asm):07021         L00716  EQU     *
21A2 4F               (          xyz.asm):07022                 CLRA
21A3 ED5E             (          xyz.asm):07023                 STD     -2,U            variable newword
                      (          xyz.asm):07024         * Line xyz.c:622: if
                      (          xyz.asm):07025         * optim: storeLoad
21A5 5D               (          xyz.asm):07026                 TSTB                    optim: removeAndOrMulAddSub
21A6 271C             (          xyz.asm):07027                 BEQ     L00726
                      (          xyz.asm):07028         * optim: condBranchOverUncondBranch
                      (          xyz.asm):07029         * Useless label L00727 removed
21A8 C67B             (          xyz.asm):07030                 LDB     #$7B            optim: lddToLDB
21AA 1D               (          xyz.asm):07031                 SEX                     promotion of binary operand
21AB 3406             (          xyz.asm):07032                 PSHS    B,A
21AD AE44             (          xyz.asm):07033                 LDX     4,U             variable p
                      (          xyz.asm):07034         * optim: optimizeLdx
                      (          xyz.asm):07035         * optim: removeTfrDX
21AF E69802           (          xyz.asm):07036                 LDB     [2,X]           optim: optimizeLdx
21B2 1D               (          xyz.asm):07037                 SEX                     promotion of binary operand
21B3 10A3E1           (          xyz.asm):07038                 CMPD    ,S++
21B6 260C             (          xyz.asm):07039                 BNE     L00726
                      (          xyz.asm):07040         * optim: condBranchOverUncondBranch
                      (          xyz.asm):07041         * Useless label L00725 removed
                      (          xyz.asm):07042         * Line xyz.c:622: return with value
                      (          xyz.asm):07043         * Line xyz.c:622: function call: picolParseBrace()
21B8 EC44             (          xyz.asm):07044                 LDD     4,U             variable p, declared at xyz.c:620
21BA 3406             (          xyz.asm):07045                 PSHS    B,A             argument 1 of picolParseBrace(): struct picolParser *
21BC 17FBF2           (          xyz.asm):07046                 LBSR    _picolParseBrace
21BF 3262             (          xyz.asm):07047                 LEAS    2,S
21C1 16013F           (          xyz.asm):07048                 LBRA    L00039          return (xyz.c:622)
                      (          xyz.asm):07049         * optim: instrFollowingUncondBranch
     21C4             (          xyz.asm):07050         L00726  EQU     *               else
                      (          xyz.asm):07051         * Line xyz.c:623: if
21C4 EC5E             (          xyz.asm):07052                 LDD     -2,U            variable newword, declared at xyz.c:621
                      (          xyz.asm):07053         * optim: loadCmpZeroBeqOrBne
21C6 272D             (          xyz.asm):07054                 BEQ     L00730
                      (          xyz.asm):07055         * optim: condBranchOverUncondBranch
                      (          xyz.asm):07056         * Useless label L00731 removed
21C8 C622             (          xyz.asm):07057                 LDB     #$22            optim: lddToLDB
21CA 1D               (          xyz.asm):07058                 SEX                     promotion of binary operand
21CB 3406             (          xyz.asm):07059                 PSHS    B,A
21CD AE44             (          xyz.asm):07060                 LDX     4,U             variable p
                      (          xyz.asm):07061         * optim: optimizeLdx
                      (          xyz.asm):07062         * optim: removeTfrDX
21CF E69802           (          xyz.asm):07063                 LDB     [2,X]           optim: optimizeLdx
21D2 1D               (          xyz.asm):07064                 SEX                     promotion of binary operand
21D3 10A3E1           (          xyz.asm):07065                 CMPD    ,S++
21D6 261D             (          xyz.asm):07066                 BNE     L00730
                      (          xyz.asm):07067         * optim: condBranchOverUncondBranch
                      (          xyz.asm):07068         * Useless label L00729 removed
                      (          xyz.asm):07069         * Line xyz.c:624: assignment: =
21D8 4F               (          xyz.asm):07070                 CLRA
21D9 C601             (          xyz.asm):07071                 LDB     #$01            decimal 1 signed
                      (          xyz.asm):07072         * optim: stripUselessPushPull
21DB AE44             (          xyz.asm):07073                 LDX     4,U             variable p
                      (          xyz.asm):07074         * optim: optimizeLeax
                      (          xyz.asm):07075         * optim: stripUselessPushPull
21DD ED0C             (          xyz.asm):07076                 STD     12,X            optim: optimizeLeax
21DF AE44             (          xyz.asm):07077                 LDX     4,U             variable p
21E1 3002             (          xyz.asm):07078                 LEAX    2,X             member p of picolParser
21E3 EC84             (          xyz.asm):07079                 LDD     ,X
21E5 C30001           (          xyz.asm):07080                 ADDD    #1
21E8 ED84             (          xyz.asm):07081                 STD     ,X
                      (          xyz.asm):07082         * optim: removeUselessOps
21EA AE44             (          xyz.asm):07083                 LDX     4,U             variable p
21EC 3004             (          xyz.asm):07084                 LEAX    4,X             member len of picolParser
21EE EC84             (          xyz.asm):07085                 LDD     ,X
21F0 830001           (          xyz.asm):07086                 SUBD    #1
21F3 ED84             (          xyz.asm):07087                 STD     ,X
                      (          xyz.asm):07088         * optim: removeUselessOps
     21F5             (          xyz.asm):07089         L00730  EQU     *               else
                      (          xyz.asm):07090         * Useless label L00732 removed
                      (          xyz.asm):07091         * Useless label L00728 removed
                      (          xyz.asm):07092         * Line xyz.c:627: assignment: =
21F5 AE44             (          xyz.asm):07093                 LDX     4,U             variable p
21F7 EC02             (          xyz.asm):07094                 LDD     2,X             member p of picolParser
                      (          xyz.asm):07095         * optim: stripUselessPushPull
21F9 AE44             (          xyz.asm):07096                 LDX     4,U             variable p
                      (          xyz.asm):07097         * optim: optimizeLeax
                      (          xyz.asm):07098         * optim: stripUselessPushPull
21FB ED06             (          xyz.asm):07099                 STD     6,X             optim: optimizeLeax
                      (          xyz.asm):07100         * Line xyz.c:628: while
21FD 160100           (          xyz.asm):07101                 LBRA    L00734          jump to while condition
     2200             (          xyz.asm):07102         L00733  EQU     *               while body
                      (          xyz.asm):07103         * Line xyz.c:629: if
2200 AE44             (          xyz.asm):07104                 LDX     4,U             variable p
2202 EC04             (          xyz.asm):07105                 LDD     4,X             member len of picolParser
                      (          xyz.asm):07106         * optim: loadCmpZeroBeqOrBne
2204 2615             (          xyz.asm):07107                 BNE     L00737
                      (          xyz.asm):07108         * optim: condBranchOverUncondBranch
                      (          xyz.asm):07109         * Useless label L00736 removed
                      (          xyz.asm):07110         * Line xyz.c:630: assignment: =
2206 4F               (          xyz.asm):07111                 CLRA
                      (          xyz.asm):07112         * optim: removeUselessOps
                      (          xyz.asm):07113         * PSHS B,A optim: optimizeStackOperations1
2207 AE44             (          xyz.asm):07114                 LDX     4,U             variable p
2209 EC02             (          xyz.asm):07115                 LDD     2,X             member p of picolParser
220B 830001           (          xyz.asm):07116                 SUBD    #1              optim: optimizeStackOperations1
                      (          xyz.asm):07117         * optim: stripUselessPushPull
220E AE44             (          xyz.asm):07118                 LDX     4,U             variable p
                      (          xyz.asm):07119         * optim: optimizeLeax
                      (          xyz.asm):07120         * optim: stripUselessPushPull
2210 ED08             (          xyz.asm):07121                 STD     8,X             optim: optimizeLeax
                      (          xyz.asm):07122         * Line xyz.c:631: assignment: =
2212 4F               (          xyz.asm):07123                 CLRA
2213 5F               (          xyz.asm):07124                 CLRB
                      (          xyz.asm):07125         * optim: stripUselessPushPull
2214 AE44             (          xyz.asm):07126                 LDX     4,U             variable p
                      (          xyz.asm):07127         * optim: optimizeLeax
                      (          xyz.asm):07128         * optim: stripUselessPushPull
2216 ED0A             (          xyz.asm):07129                 STD     10,X            optim: optimizeLeax
                      (          xyz.asm):07130         * Line xyz.c:632: return with value
                      (          xyz.asm):07131         * optim: removeClr
                      (          xyz.asm):07132         * optim: removeClr
2218 1600E8           (          xyz.asm):07133                 LBRA    L00039          return (xyz.c:632)
     221B             (          xyz.asm):07134         L00737  EQU     *               else
                      (          xyz.asm):07135         * Useless label L00738 removed
                      (          xyz.asm):07136         * Line xyz.c:634: switch
221B AE44             (          xyz.asm):07137                 LDX     4,U             variable p
                      (          xyz.asm):07138         * optim: optimizeLdx
                      (          xyz.asm):07139         * optim: removeTfrDX
221D E69802           (          xyz.asm):07140                 LDB     [2,X]           optim: optimizeLdx
                      (          xyz.asm):07141         * Switch at xyz.c:634: IF_ELSE=57, JUMP_TABLE=188
2220 C15C             (          xyz.asm):07142                 CMPB    #$5C            case 92
2222 2733             (          xyz.asm):07143                 BEQ     L00740
2224 C124             (          xyz.asm):07144                 CMPB    #$24            case 36
2226 10270054         (          xyz.asm):07145                 LBEQ    L00741
222A C15B             (          xyz.asm):07146                 CMPB    #$5B            case 91
222C 1027004E         (          xyz.asm):07147                 LBEQ    L00742
2230 C120             (          xyz.asm):07148                 CMPB    #$20            case 32
2232 1027005D         (          xyz.asm):07149                 LBEQ    L00743
2236 C109             (          xyz.asm):07150                 CMPB    #$09            case 9
2238 10270057         (          xyz.asm):07151                 LBEQ    L00744
223C C10A             (          xyz.asm):07152                 CMPB    #$0A            case 10
223E 10270051         (          xyz.asm):07153                 LBEQ    L00745
2242 C10D             (          xyz.asm):07154                 CMPB    #$0D            case 13
2244 1027004B         (          xyz.asm):07155                 LBEQ    L00746
2248 C13B             (          xyz.asm):07156                 CMPB    #$3B            case 59
224A 10270045         (          xyz.asm):07157                 LBEQ    L00747
224E C122             (          xyz.asm):07158                 CMPB    #$22            case 34
2250 1027005D         (          xyz.asm):07159                 LBEQ    L00748
2254 160090           (          xyz.asm):07160                 LBRA    L00739          switch default
     2257             (          xyz.asm):07161         L00740  EQU     *               case 92
                      (          xyz.asm):07162         * Line xyz.c:636: if
2257 4F               (          xyz.asm):07163                 CLRA
                      (          xyz.asm):07164         * optim: removeUselessOps
                      (          xyz.asm):07165         * PSHS B,A optim: optimizeStackOperations1
2258 AE44             (          xyz.asm):07166                 LDX     4,U             variable p
225A EC04             (          xyz.asm):07167                 LDD     4,X             member len of picolParser
225C 10830002         (          xyz.asm):07168                 CMPD    #2              optim: optimizeStackOperations1
2260 2D19             (          xyz.asm):07169                 BLT     L00750
                      (          xyz.asm):07170         * optim: condBranchOverUncondBranch
                      (          xyz.asm):07171         * Useless label L00749 removed
2262 AE44             (          xyz.asm):07172                 LDX     4,U             variable p
2264 3002             (          xyz.asm):07173                 LEAX    2,X             member p of picolParser
2266 EC84             (          xyz.asm):07174                 LDD     ,X
2268 C30001           (          xyz.asm):07175                 ADDD    #1
226B ED84             (          xyz.asm):07176                 STD     ,X
                      (          xyz.asm):07177         * optim: removeUselessOps
226D AE44             (          xyz.asm):07178                 LDX     4,U             variable p
226F 3004             (          xyz.asm):07179                 LEAX    4,X             member len of picolParser
2271 EC84             (          xyz.asm):07180                 LDD     ,X
2273 830001           (          xyz.asm):07181                 SUBD    #1
2276 ED84             (          xyz.asm):07182                 STD     ,X
2278 C30001           (          xyz.asm):07183                 ADDD    #1              post increment yields initial value
     227B             (          xyz.asm):07184         L00750  EQU     *               else
                      (          xyz.asm):07185         * Useless label L00751 removed
227B 160069           (          xyz.asm):07186                 LBRA    L00739          break
     227E             (          xyz.asm):07187         L00741  EQU     *               case 36
     227E             (          xyz.asm):07188         L00742  EQU     *               case 91
                      (          xyz.asm):07189         * Line xyz.c:641: assignment: =
227E 4F               (          xyz.asm):07190                 CLRA
                      (          xyz.asm):07191         * optim: removeUselessOps
                      (          xyz.asm):07192         * PSHS B,A optim: optimizeStackOperations1
227F AE44             (          xyz.asm):07193                 LDX     4,U             variable p
2281 EC02             (          xyz.asm):07194                 LDD     2,X             member p of picolParser
2283 830001           (          xyz.asm):07195                 SUBD    #1              optim: optimizeStackOperations1
                      (          xyz.asm):07196         * optim: stripUselessPushPull
2286 AE44             (          xyz.asm):07197                 LDX     4,U             variable p
                      (          xyz.asm):07198         * optim: optimizeLeax
                      (          xyz.asm):07199         * optim: stripUselessPushPull
2288 ED08             (          xyz.asm):07200                 STD     8,X             optim: optimizeLeax
                      (          xyz.asm):07201         * Line xyz.c:642: assignment: =
228A 4F               (          xyz.asm):07202                 CLRA
228B 5F               (          xyz.asm):07203                 CLRB
                      (          xyz.asm):07204         * optim: stripUselessPushPull
228C AE44             (          xyz.asm):07205                 LDX     4,U             variable p
                      (          xyz.asm):07206         * optim: optimizeLeax
                      (          xyz.asm):07207         * optim: stripUselessPushPull
228E ED0A             (          xyz.asm):07208                 STD     10,X            optim: optimizeLeax
                      (          xyz.asm):07209         * Line xyz.c:643: return with value
                      (          xyz.asm):07210         * optim: removeClr
                      (          xyz.asm):07211         * optim: removeClr
2290 160070           (          xyz.asm):07212                 LBRA    L00039          return (xyz.c:643)
     2293             (          xyz.asm):07213         L00743  EQU     *               case 32
     2293             (          xyz.asm):07214         L00744  EQU     *               case 9
     2293             (          xyz.asm):07215         L00745  EQU     *               case 10
     2293             (          xyz.asm):07216         L00746  EQU     *               case 13
     2293             (          xyz.asm):07217         L00747  EQU     *               case 59
                      (          xyz.asm):07218         * Line xyz.c:645: if
2293 AE44             (          xyz.asm):07219                 LDX     4,U             variable p
2295 EC0C             (          xyz.asm):07220                 LDD     12,X            member insidequote of picolParser
                      (          xyz.asm):07221         * optim: loadCmpZeroBeqOrBne
2297 2615             (          xyz.asm):07222                 BNE     L00753
                      (          xyz.asm):07223         * optim: branchToNextLocation
                      (          xyz.asm):07224         * Useless label L00752 removed
                      (          xyz.asm):07225         * Line xyz.c:646: assignment: =
2299 4F               (          xyz.asm):07226                 CLRA
                      (          xyz.asm):07227         * optim: removeUselessOps
                      (          xyz.asm):07228         * PSHS B,A optim: optimizeStackOperations1
229A AE44             (          xyz.asm):07229                 LDX     4,U             variable p
229C EC02             (          xyz.asm):07230                 LDD     2,X             member p of picolParser
229E 830001           (          xyz.asm):07231                 SUBD    #1              optim: optimizeStackOperations1
                      (          xyz.asm):07232         * optim: stripUselessPushPull
22A1 AE44             (          xyz.asm):07233                 LDX     4,U             variable p
                      (          xyz.asm):07234         * optim: optimizeLeax
                      (          xyz.asm):07235         * optim: stripUselessPushPull
22A3 ED08             (          xyz.asm):07236                 STD     8,X             optim: optimizeLeax
                      (          xyz.asm):07237         * Line xyz.c:647: assignment: =
22A5 4F               (          xyz.asm):07238                 CLRA
22A6 5F               (          xyz.asm):07239                 CLRB
                      (          xyz.asm):07240         * optim: stripUselessPushPull
22A7 AE44             (          xyz.asm):07241                 LDX     4,U             variable p
                      (          xyz.asm):07242         * optim: optimizeLeax
                      (          xyz.asm):07243         * optim: stripUselessPushPull
22A9 ED0A             (          xyz.asm):07244                 STD     10,X            optim: optimizeLeax
                      (          xyz.asm):07245         * Line xyz.c:648: return with value
                      (          xyz.asm):07246         * optim: removeClr
                      (          xyz.asm):07247         * optim: removeClr
22AB 160055           (          xyz.asm):07248                 LBRA    L00039          return (xyz.c:648)
     22AE             (          xyz.asm):07249         L00753  EQU     *               else
                      (          xyz.asm):07250         * Useless label L00754 removed
22AE 160036           (          xyz.asm):07251                 LBRA    L00739          break
     22B1             (          xyz.asm):07252         L00748  EQU     *               case 34
                      (          xyz.asm):07253         * Line xyz.c:652: if
22B1 AE44             (          xyz.asm):07254                 LDX     4,U             variable p
22B3 EC0C             (          xyz.asm):07255                 LDD     12,X            member insidequote of picolParser
                      (          xyz.asm):07256         * optim: loadCmpZeroBeqOrBne
22B5 2730             (          xyz.asm):07257                 BEQ     L00756
                      (          xyz.asm):07258         * optim: condBranchOverUncondBranch
                      (          xyz.asm):07259         * Useless label L00755 removed
                      (          xyz.asm):07260         * Line xyz.c:653: assignment: =
22B7 4F               (          xyz.asm):07261                 CLRA
                      (          xyz.asm):07262         * optim: removeUselessOps
                      (          xyz.asm):07263         * PSHS B,A optim: optimizeStackOperations1
22B8 AE44             (          xyz.asm):07264                 LDX     4,U             variable p
22BA EC02             (          xyz.asm):07265                 LDD     2,X             member p of picolParser
22BC 830001           (          xyz.asm):07266                 SUBD    #1              optim: optimizeStackOperations1
                      (          xyz.asm):07267         * optim: stripUselessPushPull
22BF AE44             (          xyz.asm):07268                 LDX     4,U             variable p
                      (          xyz.asm):07269         * optim: optimizeLeax
                      (          xyz.asm):07270         * optim: stripUselessPushPull
22C1 ED08             (          xyz.asm):07271                 STD     8,X             optim: optimizeLeax
                      (          xyz.asm):07272         * Line xyz.c:654: assignment: =
22C3 4F               (          xyz.asm):07273                 CLRA
22C4 5F               (          xyz.asm):07274                 CLRB
                      (          xyz.asm):07275         * optim: stripUselessPushPull
22C5 AE44             (          xyz.asm):07276                 LDX     4,U             variable p
                      (          xyz.asm):07277         * optim: optimizeLeax
                      (          xyz.asm):07278         * optim: stripUselessPushPull
22C7 ED0A             (          xyz.asm):07279                 STD     10,X            optim: optimizeLeax
22C9 AE44             (          xyz.asm):07280                 LDX     4,U             variable p
22CB 3002             (          xyz.asm):07281                 LEAX    2,X             member p of picolParser
22CD EC84             (          xyz.asm):07282                 LDD     ,X
22CF C30001           (          xyz.asm):07283                 ADDD    #1
22D2 ED84             (          xyz.asm):07284                 STD     ,X
                      (          xyz.asm):07285         * optim: removeUselessOps
22D4 AE44             (          xyz.asm):07286                 LDX     4,U             variable p
22D6 3004             (          xyz.asm):07287                 LEAX    4,X             member len of picolParser
22D8 EC84             (          xyz.asm):07288                 LDD     ,X
22DA 830001           (          xyz.asm):07289                 SUBD    #1
22DD ED84             (          xyz.asm):07290                 STD     ,X
                      (          xyz.asm):07291         * optim: removeUselessOps
                      (          xyz.asm):07292         * Line xyz.c:656: assignment: =
22DF 4F               (          xyz.asm):07293                 CLRA
22E0 5F               (          xyz.asm):07294                 CLRB
                      (          xyz.asm):07295         * optim: stripUselessPushPull
22E1 AE44             (          xyz.asm):07296                 LDX     4,U             variable p
                      (          xyz.asm):07297         * optim: optimizeLeax
                      (          xyz.asm):07298         * optim: stripUselessPushPull
22E3 ED0C             (          xyz.asm):07299                 STD     12,X            optim: optimizeLeax
                      (          xyz.asm):07300         * Line xyz.c:657: return with value
                      (          xyz.asm):07301         * optim: removeClr
                      (          xyz.asm):07302         * optim: removeClr
22E5 201C             (          xyz.asm):07303                 BRA     L00039          return (xyz.c:657)
     22E7             (          xyz.asm):07304         L00756  EQU     *               else
                      (          xyz.asm):07305         * Useless label L00757 removed
                      (          xyz.asm):07306         * optim: branchToNextLocation
     22E7             (          xyz.asm):07307         L00739  EQU     *               end of switch
22E7 AE44             (          xyz.asm):07308                 LDX     4,U             variable p
22E9 3002             (          xyz.asm):07309                 LEAX    2,X             member p of picolParser
22EB EC84             (          xyz.asm):07310                 LDD     ,X
22ED C30001           (          xyz.asm):07311                 ADDD    #1
22F0 ED84             (          xyz.asm):07312                 STD     ,X
                      (          xyz.asm):07313         * optim: removeUselessOps
22F2 AE44             (          xyz.asm):07314                 LDX     4,U             variable p
22F4 3004             (          xyz.asm):07315                 LEAX    4,X             member len of picolParser
22F6 EC84             (          xyz.asm):07316                 LDD     ,X
22F8 830001           (          xyz.asm):07317                 SUBD    #1
22FB ED84             (          xyz.asm):07318                 STD     ,X
22FD C30001           (          xyz.asm):07319                 ADDD    #1              post increment yields initial value
     2300             (          xyz.asm):07320         L00734  EQU     *               while condition at xyz.c:628
2300 16FEFD           (          xyz.asm):07321                 LBRA    L00733          go to start of while body
                      (          xyz.asm):07322         * Useless label L00735 removed
                      (          xyz.asm):07323         * Line xyz.c:663: return with value
                      (          xyz.asm):07324         * optim: instrFollowingUncondBranch
                      (          xyz.asm):07325         * optim: instrFollowingUncondBranch
                      (          xyz.asm):07326         * optim: branchToNextLocation
     2303             (          xyz.asm):07327         L00039  EQU     *               end of picolParseString()
2303 32C4             (          xyz.asm):07328                 LEAS    ,U
2305 35C0             (          xyz.asm):07329                 PULS    U,PC
                      (          xyz.asm):07330         * END FUNCTION picolParseString(): defined at xyz.c:620
     2307             (          xyz.asm):07331         funcend_picolParseString        EQU *
     01AC             (          xyz.asm):07332         funcsize_picolParseString       EQU     funcend_picolParseString-_picolParseString
                      (          xyz.asm):07333         
                      (          xyz.asm):07334         
                      (          xyz.asm):07335         *******************************************************************************
                      (          xyz.asm):07336         
                      (          xyz.asm):07337         * FUNCTION picolParseVar(): defined at xyz.c:577
     2307             (          xyz.asm):07338         _picolParseVar  EQU     *
2307 3440             (          xyz.asm):07339                 PSHS    U
2309 170740           (          xyz.asm):07340                 LBSR    _stkcheck
230C FFC0             (          xyz.asm):07341                 FDB     -64             argument for _stkcheck
230E 33E4             (          xyz.asm):07342                 LEAU    ,S
                      (          xyz.asm):07343         * Formal parameters and locals:
                      (          xyz.asm):07344         *   p: struct picolParser *; 2 bytes at 4,U
                      (          xyz.asm):07345         * Line xyz.c:578: assignment: =
2310 AE44             (          xyz.asm):07346                 LDX     4,U             variable p
2312 3002             (          xyz.asm):07347                 LEAX    2,X             member p of picolParser
2314 EC84             (          xyz.asm):07348                 LDD     ,X
2316 C30001           (          xyz.asm):07349                 ADDD    #1
2319 ED84             (          xyz.asm):07350                 STD     ,X
                      (          xyz.asm):07351         * optim: stripUselessPushPull
231B AE44             (          xyz.asm):07352                 LDX     4,U             variable p
                      (          xyz.asm):07353         * optim: optimizeLeax
                      (          xyz.asm):07354         * optim: stripUselessPushPull
231D ED06             (          xyz.asm):07355                 STD     6,X             optim: optimizeLeax
231F AE44             (          xyz.asm):07356                 LDX     4,U             variable p
2321 3004             (          xyz.asm):07357                 LEAX    4,X             member len of picolParser
2323 EC84             (          xyz.asm):07358                 LDD     ,X
2325 830001           (          xyz.asm):07359                 SUBD    #1
2328 ED84             (          xyz.asm):07360                 STD     ,X
232A C30001           (          xyz.asm):07361                 ADDD    #1              post increment yields initial value
                      (          xyz.asm):07362         * Line xyz.c:579: while
232D 16008F           (          xyz.asm):07363                 LBRA    L00759          jump to while condition
     2330             (          xyz.asm):07364         L00758  EQU     *               while body
                      (          xyz.asm):07365         * Line xyz.c:581: if
2330 C661             (          xyz.asm):07366                 LDB     #$61            optim: lddToLDB
2332 1D               (          xyz.asm):07367                 SEX                     promotion of binary operand
2333 3406             (          xyz.asm):07368                 PSHS    B,A
2335 AE44             (          xyz.asm):07369                 LDX     4,U             variable p
                      (          xyz.asm):07370         * optim: optimizeLdx
                      (          xyz.asm):07371         * optim: removeTfrDX
2337 E69802           (          xyz.asm):07372                 LDB     [2,X]           optim: optimizeLdx
233A 1D               (          xyz.asm):07373                 SEX                     promotion of binary operand
233B 10A3E1           (          xyz.asm):07374                 CMPD    ,S++
233E 2D12             (          xyz.asm):07375                 BLT     L00765
                      (          xyz.asm):07376         * optim: condBranchOverUncondBranch
                      (          xyz.asm):07377         * Useless label L00766 removed
2340 C67A             (          xyz.asm):07378                 LDB     #$7A            optim: lddToLDB
2342 1D               (          xyz.asm):07379                 SEX                     promotion of binary operand
2343 3406             (          xyz.asm):07380                 PSHS    B,A
2345 AE44             (          xyz.asm):07381                 LDX     4,U             variable p
                      (          xyz.asm):07382         * optim: optimizeLdx
                      (          xyz.asm):07383         * optim: removeTfrDX
2347 E69802           (          xyz.asm):07384                 LDB     [2,X]           optim: optimizeLdx
234A 1D               (          xyz.asm):07385                 SEX                     promotion of binary operand
234B 10A3E1           (          xyz.asm):07386                 CMPD    ,S++
234E 102F0050         (          xyz.asm):07387                 LBLE    L00761
                      (          xyz.asm):07388         * optim: branchToNextLocation
     2352             (          xyz.asm):07389         L00765  EQU     *
2352 C641             (          xyz.asm):07390                 LDB     #$41            optim: lddToLDB
2354 1D               (          xyz.asm):07391                 SEX                     promotion of binary operand
2355 3406             (          xyz.asm):07392                 PSHS    B,A
2357 AE44             (          xyz.asm):07393                 LDX     4,U             variable p
                      (          xyz.asm):07394         * optim: optimizeLdx
                      (          xyz.asm):07395         * optim: removeTfrDX
2359 E69802           (          xyz.asm):07396                 LDB     [2,X]           optim: optimizeLdx
235C 1D               (          xyz.asm):07397                 SEX                     promotion of binary operand
235D 10A3E1           (          xyz.asm):07398                 CMPD    ,S++
2360 2D10             (          xyz.asm):07399                 BLT     L00764
                      (          xyz.asm):07400         * optim: condBranchOverUncondBranch
                      (          xyz.asm):07401         * Useless label L00767 removed
2362 C65A             (          xyz.asm):07402                 LDB     #$5A            optim: lddToLDB
2364 1D               (          xyz.asm):07403                 SEX                     promotion of binary operand
2365 3406             (          xyz.asm):07404                 PSHS    B,A
2367 AE44             (          xyz.asm):07405                 LDX     4,U             variable p
                      (          xyz.asm):07406         * optim: optimizeLdx
                      (          xyz.asm):07407         * optim: removeTfrDX
2369 E69802           (          xyz.asm):07408                 LDB     [2,X]           optim: optimizeLdx
236C 1D               (          xyz.asm):07409                 SEX                     promotion of binary operand
236D 10A3E1           (          xyz.asm):07410                 CMPD    ,S++
2370 2F30             (          xyz.asm):07411                 BLE     L00761
                      (          xyz.asm):07412         * optim: branchToNextLocation
     2372             (          xyz.asm):07413         L00764  EQU     *
2372 C630             (          xyz.asm):07414                 LDB     #$30            optim: lddToLDB
2374 1D               (          xyz.asm):07415                 SEX                     promotion of binary operand
2375 3406             (          xyz.asm):07416                 PSHS    B,A
2377 AE44             (          xyz.asm):07417                 LDX     4,U             variable p
                      (          xyz.asm):07418         * optim: optimizeLdx
                      (          xyz.asm):07419         * optim: removeTfrDX
2379 E69802           (          xyz.asm):07420                 LDB     [2,X]           optim: optimizeLdx
237C 1D               (          xyz.asm):07421                 SEX                     promotion of binary operand
237D 10A3E1           (          xyz.asm):07422                 CMPD    ,S++
2380 2D10             (          xyz.asm):07423                 BLT     L00763
                      (          xyz.asm):07424         * optim: condBranchOverUncondBranch
                      (          xyz.asm):07425         * Useless label L00768 removed
2382 C639             (          xyz.asm):07426                 LDB     #$39            optim: lddToLDB
2384 1D               (          xyz.asm):07427                 SEX                     promotion of binary operand
2385 3406             (          xyz.asm):07428                 PSHS    B,A
2387 AE44             (          xyz.asm):07429                 LDX     4,U             variable p
                      (          xyz.asm):07430         * optim: optimizeLdx
                      (          xyz.asm):07431         * optim: removeTfrDX
2389 E69802           (          xyz.asm):07432                 LDB     [2,X]           optim: optimizeLdx
238C 1D               (          xyz.asm):07433                 SEX                     promotion of binary operand
238D 10A3E1           (          xyz.asm):07434                 CMPD    ,S++
2390 2F10             (          xyz.asm):07435                 BLE     L00761
                      (          xyz.asm):07436         * optim: branchToNextLocation
     2392             (          xyz.asm):07437         L00763  EQU     *
2392 C65F             (          xyz.asm):07438                 LDB     #$5F            optim: lddToLDB
2394 1D               (          xyz.asm):07439                 SEX                     promotion of binary operand
2395 3406             (          xyz.asm):07440                 PSHS    B,A
2397 AE44             (          xyz.asm):07441                 LDX     4,U             variable p
                      (          xyz.asm):07442         * optim: optimizeLdx
                      (          xyz.asm):07443         * optim: removeTfrDX
2399 E69802           (          xyz.asm):07444                 LDB     [2,X]           optim: optimizeLdx
239C 1D               (          xyz.asm):07445                 SEX                     promotion of binary operand
239D 10A3E1           (          xyz.asm):07446                 CMPD    ,S++
23A0 261B             (          xyz.asm):07447                 BNE     L00762
                      (          xyz.asm):07448         * optim: condBranchOverUncondBranch
     23A2             (          xyz.asm):07449         L00761  EQU     *               then
23A2 AE44             (          xyz.asm):07450                 LDX     4,U             variable p
23A4 3002             (          xyz.asm):07451                 LEAX    2,X             member p of picolParser
23A6 EC84             (          xyz.asm):07452                 LDD     ,X
23A8 C30001           (          xyz.asm):07453                 ADDD    #1
23AB ED84             (          xyz.asm):07454                 STD     ,X
                      (          xyz.asm):07455         * optim: removeUselessOps
23AD AE44             (          xyz.asm):07456                 LDX     4,U             variable p
23AF 3004             (          xyz.asm):07457                 LEAX    4,X             member len of picolParser
23B1 EC84             (          xyz.asm):07458                 LDD     ,X
23B3 830001           (          xyz.asm):07459                 SUBD    #1
23B6 ED84             (          xyz.asm):07460                 STD     ,X
23B8 C30001           (          xyz.asm):07461                 ADDD    #1              post increment yields initial value
23BB 2002             (          xyz.asm):07462                 BRA     L00759          continue
     23BD             (          xyz.asm):07463         L00762  EQU     *               else
                      (          xyz.asm):07464         * Useless label L00769 removed
23BD 2003             (          xyz.asm):07465                 BRA     L00760          break
     23BF             (          xyz.asm):07466         L00759  EQU     *               while condition at xyz.c:579
23BF 16FF6E           (          xyz.asm):07467                 LBRA    L00758          go to start of while body
     23C2             (          xyz.asm):07468         L00760  EQU     *               after end of while starting at xyz.c:579
                      (          xyz.asm):07469         * Line xyz.c:587: if
23C2 AE44             (          xyz.asm):07470                 LDX     4,U             variable p
23C4 EC02             (          xyz.asm):07471                 LDD     2,X             member p of picolParser
23C6 3406             (          xyz.asm):07472                 PSHS    B,A
23C8 AE44             (          xyz.asm):07473                 LDX     4,U             variable p
23CA EC06             (          xyz.asm):07474                 LDD     6,X             member start of picolParser
23CC 10A3E1           (          xyz.asm):07475                 CMPD    ,S++
23CF 2619             (          xyz.asm):07476                 BNE     L00771
                      (          xyz.asm):07477         * optim: condBranchOverUncondBranch
                      (          xyz.asm):07478         * Useless label L00770 removed
                      (          xyz.asm):07479         * Line xyz.c:588: assignment: =
                      (          xyz.asm):07480         * Line xyz.c:588: assignment: =
23D1 4F               (          xyz.asm):07481                 CLRA
                      (          xyz.asm):07482         * optim: removeUselessOps
                      (          xyz.asm):07483         * PSHS B,A optim: optimizeStackOperations1
23D2 AE44             (          xyz.asm):07484                 LDX     4,U             variable p
23D4 EC02             (          xyz.asm):07485                 LDD     2,X             member p of picolParser
23D6 830001           (          xyz.asm):07486                 SUBD    #1              optim: optimizeStackOperations1
                      (          xyz.asm):07487         * optim: stripUselessPushPull
23D9 AE44             (          xyz.asm):07488                 LDX     4,U             variable p
                      (          xyz.asm):07489         * optim: optimizeLeax
                      (          xyz.asm):07490         * optim: stripUselessPushPull
23DB ED08             (          xyz.asm):07491                 STD     8,X             optim: optimizeLeax
                      (          xyz.asm):07492         * optim: stripUselessPushPull
23DD AE44             (          xyz.asm):07493                 LDX     4,U             variable p
                      (          xyz.asm):07494         * optim: optimizeLeax
                      (          xyz.asm):07495         * optim: stripUselessPushPull
23DF ED06             (          xyz.asm):07496                 STD     6,X             optim: optimizeLeax
                      (          xyz.asm):07497         * Line xyz.c:589: assignment: =
23E1 4F               (          xyz.asm):07498                 CLRA
23E2 C601             (          xyz.asm):07499                 LDB     #$01            decimal 1 signed
                      (          xyz.asm):07500         * optim: stripUselessPushPull
23E4 AE44             (          xyz.asm):07501                 LDX     4,U             variable p
                      (          xyz.asm):07502         * optim: optimizeLeax
                      (          xyz.asm):07503         * optim: stripUselessPushPull
23E6 ED0A             (          xyz.asm):07504                 STD     10,X            optim: optimizeLeax
23E8 2015             (          xyz.asm):07505                 BRA     L00772          jump over else clause
     23EA             (          xyz.asm):07506         L00771  EQU     *               else
                      (          xyz.asm):07507         * Line xyz.c:591: assignment: =
23EA 4F               (          xyz.asm):07508                 CLRA
23EB C601             (          xyz.asm):07509                 LDB     #$01            decimal 1 signed
                      (          xyz.asm):07510         * PSHS B,A optim: optimizeStackOperations1
23ED AE44             (          xyz.asm):07511                 LDX     4,U             variable p
23EF EC02             (          xyz.asm):07512                 LDD     2,X             member p of picolParser
23F1 830001           (          xyz.asm):07513                 SUBD    #1              optim: optimizeStackOperations1
                      (          xyz.asm):07514         * optim: stripUselessPushPull
23F4 AE44             (          xyz.asm):07515                 LDX     4,U             variable p
                      (          xyz.asm):07516         * optim: optimizeLeax
                      (          xyz.asm):07517         * optim: stripUselessPushPull
23F6 ED08             (          xyz.asm):07518                 STD     8,X             optim: optimizeLeax
                      (          xyz.asm):07519         * Line xyz.c:592: assignment: =
23F8 4F               (          xyz.asm):07520                 CLRA
23F9 C603             (          xyz.asm):07521                 LDB     #$03            decimal 3 signed
                      (          xyz.asm):07522         * optim: stripUselessPushPull
23FB AE44             (          xyz.asm):07523                 LDX     4,U             variable p
                      (          xyz.asm):07524         * optim: optimizeLeax
                      (          xyz.asm):07525         * optim: stripUselessPushPull
23FD ED0A             (          xyz.asm):07526                 STD     10,X            optim: optimizeLeax
     23FF             (          xyz.asm):07527         L00772  EQU     *               end if
                      (          xyz.asm):07528         * Line xyz.c:594: return with value
23FF 4F               (          xyz.asm):07529                 CLRA
2400 5F               (          xyz.asm):07530                 CLRB
                      (          xyz.asm):07531         * optim: branchToNextLocation
                      (          xyz.asm):07532         * Useless label L00037 removed
2401 32C4             (          xyz.asm):07533                 LEAS    ,U
2403 35C0             (          xyz.asm):07534                 PULS    U,PC
                      (          xyz.asm):07535         * END FUNCTION picolParseVar(): defined at xyz.c:577
     2405             (          xyz.asm):07536         funcend_picolParseVar   EQU *
     00FE             (          xyz.asm):07537         funcsize_picolParseVar  EQU     funcend_picolParseVar-_picolParseVar
                      (          xyz.asm):07538         
                      (          xyz.asm):07539         
                      (          xyz.asm):07540         *******************************************************************************
                      (          xyz.asm):07541         
                      (          xyz.asm):07542         * FUNCTION picolRegisterCommand(): defined at xyz.c:754
     2405             (          xyz.asm):07543         _picolRegisterCommand   EQU     *
2405 3440             (          xyz.asm):07544                 PSHS    U
2407 170642           (          xyz.asm):07545                 LBSR    _stkcheck
240A FEF6             (          xyz.asm):07546                 FDB     -266            argument for _stkcheck
240C 33E4             (          xyz.asm):07547                 LEAU    ,S
240E 32E9FF36         (          xyz.asm):07548                 LEAS    -202,S
                      (          xyz.asm):07549         * Formal parameters and locals:
                      (          xyz.asm):07550         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):07551         *   name: const char *; 2 bytes at 6,U
                      (          xyz.asm):07552         *   f: int (*)(struct picolInterp *, int, char **, void *); 2 bytes at 8,U
                      (          xyz.asm):07553         *   privdata: void *; 2 bytes at 10,U
                      (          xyz.asm):07554         *   c: struct picolCmd *; 2 bytes at -202,U
                      (          xyz.asm):07555         *   errbuf: char[]; 200 bytes at -200,U
                      (          xyz.asm):07556         * Line xyz.c:755: init of variable c
                      (          xyz.asm):07557         * Line xyz.c:755: function call: picolGetCommand()
2412 EC46             (          xyz.asm):07558                 LDD     6,U             variable name, declared at xyz.c:754
2414 3406             (          xyz.asm):07559                 PSHS    B,A             argument 2 of picolGetCommand(): const char *
2416 EC44             (          xyz.asm):07560                 LDD     4,U             variable i, declared at xyz.c:754
2418 3406             (          xyz.asm):07561                 PSHS    B,A             argument 1 of picolGetCommand(): struct picolInterp *
241A 17F7B0           (          xyz.asm):07562                 LBSR    _picolGetCommand
241D 3264             (          xyz.asm):07563                 LEAS    4,S
241F EDC9FF36         (          xyz.asm):07564                 STD     -202,U          variable c
                      (          xyz.asm):07565         * Line xyz.c:757: if
                      (          xyz.asm):07566         * optim: storeLoad
2423 C30000           (          xyz.asm):07567                 ADDD    #0
2426 272A             (          xyz.asm):07568                 BEQ     L00774
                      (          xyz.asm):07569         * optim: condBranchOverUncondBranch
                      (          xyz.asm):07570         * Useless label L00773 removed
                      (          xyz.asm):07571         * Line xyz.c:758: function call: snprintf_s()
2428 EC46             (          xyz.asm):07572                 LDD     6,U             variable name, declared at xyz.c:754
242A 3406             (          xyz.asm):07573                 PSHS    B,A             argument 4 of snprintf_s(): const char *
242C 308D0819         (          xyz.asm):07574                 LEAX    S00096,PCR      "Command \'%s\' already defined"
                      (          xyz.asm):07575         * optim: optimizePshsOps
2430 4F               (          xyz.asm):07576                 CLRA
2431 C6C8             (          xyz.asm):07577                 LDB     #$C8            decimal 200 signed
2433 3416             (          xyz.asm):07578                 PSHS    X,B,A           optim: optimizePshsOps
2435 30C9FF38         (          xyz.asm):07579                 LEAX    -200,U          address of array errbuf
2439 3410             (          xyz.asm):07580                 PSHS    X               argument 1 of snprintf_s(): char[]
243B 17052C           (          xyz.asm):07581                 LBSR    _snprintf_s
243E 3268             (          xyz.asm):07582                 LEAS    8,S
                      (          xyz.asm):07583         * Line xyz.c:759: function call: picolSetResult()
2440 30C9FF38         (          xyz.asm):07584                 LEAX    -200,U          address of array errbuf
                      (          xyz.asm):07585         * optim: optimizePshsOps
2444 EC44             (          xyz.asm):07586                 LDD     4,U             variable i, declared at xyz.c:754
2446 3416             (          xyz.asm):07587                 PSHS    X,B,A           optim: optimizePshsOps
2448 170270           (          xyz.asm):07588                 LBSR    _picolSetResult
244B 3264             (          xyz.asm):07589                 LEAS    4,S
                      (          xyz.asm):07590         * Line xyz.c:760: return with value
244D 4F               (          xyz.asm):07591                 CLRA
244E C601             (          xyz.asm):07592                 LDB     #$01            decimal 1 signed
2450 203F             (          xyz.asm):07593                 BRA     L00048          return (xyz.c:760)
     2452             (          xyz.asm):07594         L00774  EQU     *               else
                      (          xyz.asm):07595         * Useless label L00775 removed
                      (          xyz.asm):07596         * Line xyz.c:762: assignment: =
                      (          xyz.asm):07597         * Line xyz.c:762: function call: malloc()
2452 4F               (          xyz.asm):07598                 CLRA
2453 C608             (          xyz.asm):07599                 LDB     #$08            constant expression: 8 decimal, unsigned
2455 3406             (          xyz.asm):07600                 PSHS    B,A             argument 1 of malloc(): unsigned int
2457 17E3F0           (          xyz.asm):07601                 LBSR    _malloc
245A 3262             (          xyz.asm):07602                 LEAS    2,S
245C EDC9FF36         (          xyz.asm):07603                 STD     -202,U
                      (          xyz.asm):07604         * Line xyz.c:763: assignment: =
                      (          xyz.asm):07605         * Line xyz.c:763: function call: strdup()
2460 EC46             (          xyz.asm):07606                 LDD     6,U             variable name, declared at xyz.c:754
2462 3406             (          xyz.asm):07607                 PSHS    B,A             argument 1 of strdup(): const char *
2464 1706E3           (          xyz.asm):07608                 LBSR    _strdup
2467 3262             (          xyz.asm):07609                 LEAS    2,S
                      (          xyz.asm):07610         * optim: stripUselessPushPull
                      (          xyz.asm):07611         * optim: optimizeLdx
                      (          xyz.asm):07612         * optim: stripUselessPushPull
2469 EDD9FF36         (          xyz.asm):07613                 STD     [-202,U]        optim: optimizeLdx
                      (          xyz.asm):07614         * Line xyz.c:764: assignment: =
246D EC48             (          xyz.asm):07615                 LDD     8,U             variable f, declared at xyz.c:754
                      (          xyz.asm):07616         * optim: stripUselessPushPull
246F AEC9FF36         (          xyz.asm):07617                 LDX     -202,U          variable c
                      (          xyz.asm):07618         * optim: optimizeLeax
                      (          xyz.asm):07619         * optim: stripUselessPushPull
2473 ED02             (          xyz.asm):07620                 STD     2,X             optim: optimizeLeax
                      (          xyz.asm):07621         * Line xyz.c:765: assignment: =
2475 EC4A             (          xyz.asm):07622                 LDD     10,U            variable privdata, declared at xyz.c:754
                      (          xyz.asm):07623         * optim: stripUselessPushPull
2477 AEC9FF36         (          xyz.asm):07624                 LDX     -202,U          variable c
                      (          xyz.asm):07625         * optim: optimizeLeax
                      (          xyz.asm):07626         * optim: stripUselessPushPull
247B ED04             (          xyz.asm):07627                 STD     4,X             optim: optimizeLeax
                      (          xyz.asm):07628         * Line xyz.c:766: assignment: =
247D AE44             (          xyz.asm):07629                 LDX     4,U             variable i
247F EC04             (          xyz.asm):07630                 LDD     4,X             member commands of picolInterp
                      (          xyz.asm):07631         * optim: stripUselessPushPull
2481 AEC9FF36         (          xyz.asm):07632                 LDX     -202,U          variable c
                      (          xyz.asm):07633         * optim: optimizeLeax
                      (          xyz.asm):07634         * optim: stripUselessPushPull
2485 ED06             (          xyz.asm):07635                 STD     6,X             optim: optimizeLeax
                      (          xyz.asm):07636         * Line xyz.c:767: assignment: =
2487 ECC9FF36         (          xyz.asm):07637                 LDD     -202,U          variable c, declared at xyz.c:755
                      (          xyz.asm):07638         * optim: stripUselessPushPull
248B AE44             (          xyz.asm):07639                 LDX     4,U             variable i
                      (          xyz.asm):07640         * optim: optimizeLeax
                      (          xyz.asm):07641         * optim: stripUselessPushPull
248D ED04             (          xyz.asm):07642                 STD     4,X             optim: optimizeLeax
                      (          xyz.asm):07643         * Line xyz.c:768: return with value
248F 4F               (          xyz.asm):07644                 CLRA
2490 5F               (          xyz.asm):07645                 CLRB
                      (          xyz.asm):07646         * optim: branchToNextLocation
     2491             (          xyz.asm):07647         L00048  EQU     *               end of picolRegisterCommand()
2491 32C4             (          xyz.asm):07648                 LEAS    ,U
2493 35C0             (          xyz.asm):07649                 PULS    U,PC
                      (          xyz.asm):07650         * END FUNCTION picolRegisterCommand(): defined at xyz.c:754
     2495             (          xyz.asm):07651         funcend_picolRegisterCommand    EQU *
     0090             (          xyz.asm):07652         funcsize_picolRegisterCommand   EQU     funcend_picolRegisterCommand-_picolRegisterCommand
                      (          xyz.asm):07653         
                      (          xyz.asm):07654         
                      (          xyz.asm):07655         *******************************************************************************
                      (          xyz.asm):07656         
                      (          xyz.asm):07657         * FUNCTION picolRegisterCoreCommands(): defined at xyz.c:1243
     2495             (          xyz.asm):07658         _picolRegisterCoreCommands      EQU     *
2495 3440             (          xyz.asm):07659                 PSHS    U
2497 1705B2           (          xyz.asm):07660                 LBSR    _stkcheck
249A FFAA             (          xyz.asm):07661                 FDB     -86             argument for _stkcheck
249C 33E4             (          xyz.asm):07662                 LEAU    ,S
249E 32E8EA           (          xyz.asm):07663                 LEAS    -22,S
                      (          xyz.asm):07664         * Formal parameters and locals:
                      (          xyz.asm):07665         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):07666         *   j: int; 2 bytes at -22,U
                      (          xyz.asm):07667         *   name: const char *[]; 20 bytes at -20,U
                      (          xyz.asm):07668         * Line xyz.c:1244: init of variable name
                      (          xyz.asm):07669         * Element 0 of array (element type is const char *)
24A1 308D08B3         (          xyz.asm):07670                 LEAX    S00115,PCR      "+"
24A5 AFC8EC           (          xyz.asm):07671                 STX     -20,U           offset in variable name
                      (          xyz.asm):07672         * Element 1 of array (element type is const char *)
24A8 308D08AE         (          xyz.asm):07673                 LEAX    S00116,PCR      "-"
24AC AFC8EE           (          xyz.asm):07674                 STX     -18,U           offset in variable name
                      (          xyz.asm):07675         * Element 2 of array (element type is const char *)
24AF 308D08A9         (          xyz.asm):07676                 LEAX    S00117,PCR      "*"
24B3 AF50             (          xyz.asm):07677                 STX     -16,U           offset in variable name
                      (          xyz.asm):07678         * Element 3 of array (element type is const char *)
24B5 308D08A5         (          xyz.asm):07679                 LEAX    S00118,PCR      "/"
24B9 AF52             (          xyz.asm):07680                 STX     -14,U           offset in variable name
                      (          xyz.asm):07681         * Element 4 of array (element type is const char *)
24BB 308D08A1         (          xyz.asm):07682                 LEAX    S00119,PCR      ">"
24BF AF54             (          xyz.asm):07683                 STX     -12,U           offset in variable name
                      (          xyz.asm):07684         * Element 5 of array (element type is const char *)
24C1 308D089D         (          xyz.asm):07685                 LEAX    S00120,PCR      ">="
24C5 AF56             (          xyz.asm):07686                 STX     -10,U           offset in variable name
                      (          xyz.asm):07687         * Element 6 of array (element type is const char *)
24C7 308D089A         (          xyz.asm):07688                 LEAX    S00121,PCR      "<"
24CB AF58             (          xyz.asm):07689                 STX     -8,U            offset in variable name
                      (          xyz.asm):07690         * Element 7 of array (element type is const char *)
24CD 308D0896         (          xyz.asm):07691                 LEAX    S00122,PCR      "<="
24D1 AF5A             (          xyz.asm):07692                 STX     -6,U            offset in variable name
                      (          xyz.asm):07693         * Element 8 of array (element type is const char *)
24D3 308D0893         (          xyz.asm):07694                 LEAX    S00123,PCR      "=="
24D7 AF5C             (          xyz.asm):07695                 STX     -4,U            offset in variable name
                      (          xyz.asm):07696         * Element 9 of array (element type is const char *)
24D9 308D0890         (          xyz.asm):07697                 LEAX    S00124,PCR      "!="
24DD AF5E             (          xyz.asm):07698                 STX     -2,U            offset in variable name
                      (          xyz.asm):07699         * Line xyz.c:1245: for init
                      (          xyz.asm):07700         * Line xyz.c:1245: assignment: =
24DF 4F               (          xyz.asm):07701                 CLRA
24E0 5F               (          xyz.asm):07702                 CLRB
24E1 EDC8EA           (          xyz.asm):07703                 STD     -22,U
24E4 202A             (          xyz.asm):07704                 BRA     L00777          jump to for condition
     24E6             (          xyz.asm):07705         L00776  EQU     *
                      (          xyz.asm):07706         * Line xyz.c:1246: for body
                      (          xyz.asm):07707         * Line xyz.c:1246: function call: picolRegisterCommand()
24E6 4F               (          xyz.asm):07708                 CLRA
24E7 5F               (          xyz.asm):07709                 CLRB
24E8 3406             (          xyz.asm):07710                 PSHS    B,A             argument 4 of picolRegisterCommand(): int
24EA 308DEC82         (          xyz.asm):07711                 LEAX    _picolCommandMath,PCR   address of picolCommandMath(), defined at xyz.c:864
24EE 3410             (          xyz.asm):07712                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):07713         * optim: optimizeTfrPush
24F0 30C8EC           (          xyz.asm):07714                 LEAX    -20,U           address of array name
24F3 ECC8EA           (          xyz.asm):07715                 LDD     -22,U           variable j
24F6 58               (          xyz.asm):07716                 LSLB
24F7 49               (          xyz.asm):07717                 ROLA
24F8 308B             (          xyz.asm):07718                 LEAX    D,X             add byte offset
24FA EC84             (          xyz.asm):07719                 LDD     ,X              get r-value
24FC 3406             (          xyz.asm):07720                 PSHS    B,A             argument 2 of picolRegisterCommand(): const char *
24FE EC44             (          xyz.asm):07721                 LDD     4,U             variable i, declared at xyz.c:1243
2500 3406             (          xyz.asm):07722                 PSHS    B,A             argument 1 of picolRegisterCommand(): struct picolInterp *
2502 17FF00           (          xyz.asm):07723                 LBSR    _picolRegisterCommand
2505 3268             (          xyz.asm):07724                 LEAS    8,S
                      (          xyz.asm):07725         * Useless label L00778 removed
                      (          xyz.asm):07726         * Line xyz.c:1245: for increment(s)
2507 ECC8EA           (          xyz.asm):07727                 LDD     -22,U
250A C30001           (          xyz.asm):07728                 ADDD    #1
250D EDC8EA           (          xyz.asm):07729                 STD     -22,U
     2510             (          xyz.asm):07730         L00777  EQU     *
                      (          xyz.asm):07731         * Line xyz.c:1245: for condition
2510 ECC8EA           (          xyz.asm):07732                 LDD     -22,U           variable j
2513 1083000A         (          xyz.asm):07733                 CMPD    #$0A
2517 2DCD             (          xyz.asm):07734                 BLT     L00776
                      (          xyz.asm):07735         * optim: branchToNextLocation
                      (          xyz.asm):07736         * Useless label L00779 removed
                      (          xyz.asm):07737         * Line xyz.c:1247: function call: picolRegisterCommand()
2519 4F               (          xyz.asm):07738                 CLRA
251A 5F               (          xyz.asm):07739                 CLRB
251B 3406             (          xyz.asm):07740                 PSHS    B,A             argument 4 of picolRegisterCommand(): int
251D 308DF06F         (          xyz.asm):07741                 LEAX    _picolCommandSet,PCR    address of picolCommandSet(), defined at xyz.c:884
2521 3410             (          xyz.asm):07742                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):07743         * optim: optimizeTfrPush
2523 308D0849         (          xyz.asm):07744                 LEAX    S00125,PCR      "set"
                      (          xyz.asm):07745         * optim: optimizePshsOps
2527 EC44             (          xyz.asm):07746                 LDD     4,U             variable i, declared at xyz.c:1243
2529 3416             (          xyz.asm):07747                 PSHS    X,B,A           optim: optimizePshsOps
252B 17FED7           (          xyz.asm):07748                 LBSR    _picolRegisterCommand
252E 3268             (          xyz.asm):07749                 LEAS    8,S
                      (          xyz.asm):07750         * Line xyz.c:1248: function call: picolRegisterCommand()
2530 4F               (          xyz.asm):07751                 CLRA
2531 5F               (          xyz.asm):07752                 CLRB
2532 3406             (          xyz.asm):07753                 PSHS    B,A             argument 4 of picolRegisterCommand(): int
2534 308DEE99         (          xyz.asm):07754                 LEAX    _picolCommandPuts,PCR   address of picolCommandPuts(), defined at xyz.c:902
2538 3410             (          xyz.asm):07755                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):07756         * optim: optimizeTfrPush
253A 308D0836         (          xyz.asm):07757                 LEAX    S00126,PCR      "puts"
                      (          xyz.asm):07758         * optim: optimizePshsOps
253E EC44             (          xyz.asm):07759                 LDD     4,U             variable i, declared at xyz.c:1243
2540 3416             (          xyz.asm):07760                 PSHS    X,B,A           optim: optimizePshsOps
2542 17FEC0           (          xyz.asm):07761                 LBSR    _picolRegisterCommand
2545 3268             (          xyz.asm):07762                 LEAS    8,S
                      (          xyz.asm):07763         * Line xyz.c:1249: function call: picolRegisterCommand()
2547 4F               (          xyz.asm):07764                 CLRA
2548 5F               (          xyz.asm):07765                 CLRB
2549 3406             (          xyz.asm):07766                 PSHS    B,A             argument 4 of picolRegisterCommand(): int
254B 308DEA22         (          xyz.asm):07767                 LEAX    _picolCommandIf,PCR     address of picolCommandIf(), defined at xyz.c:923
254F 3410             (          xyz.asm):07768                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):07769         * optim: optimizeTfrPush
2551 308D0824         (          xyz.asm):07770                 LEAX    S00127,PCR      "if"
                      (          xyz.asm):07771         * optim: optimizePshsOps
2555 EC44             (          xyz.asm):07772                 LDD     4,U             variable i, declared at xyz.c:1243
2557 3416             (          xyz.asm):07773                 PSHS    X,B,A           optim: optimizePshsOps
2559 17FEA9           (          xyz.asm):07774                 LBSR    _picolRegisterCommand
255C 3268             (          xyz.asm):07775                 LEAS    8,S
                      (          xyz.asm):07776         * Line xyz.c:1250: function call: picolRegisterCommand()
255E 4F               (          xyz.asm):07777                 CLRA
255F 5F               (          xyz.asm):07778                 CLRB
2560 3406             (          xyz.asm):07779                 PSHS    B,A             argument 4 of picolRegisterCommand(): int
2562 308DF195         (          xyz.asm):07780                 LEAX    _picolCommandWhile,PCR  address of picolCommandWhile(), defined at xyz.c:932
2566 3410             (          xyz.asm):07781                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):07782         * optim: optimizeTfrPush
2568 308D0810         (          xyz.asm):07783                 LEAX    S00128,PCR      "while"
                      (          xyz.asm):07784         * optim: optimizePshsOps
256C EC44             (          xyz.asm):07785                 LDD     4,U             variable i, declared at xyz.c:1243
256E 3416             (          xyz.asm):07786                 PSHS    X,B,A           optim: optimizePshsOps
2570 17FE92           (          xyz.asm):07787                 LBSR    _picolRegisterCommand
2573 3268             (          xyz.asm):07788                 LEAS    8,S
                      (          xyz.asm):07789         * Line xyz.c:1251: function call: picolRegisterCommand()
2575 4F               (          xyz.asm):07790                 CLRA
2576 5F               (          xyz.asm):07791                 CLRB
2577 3406             (          xyz.asm):07792                 PSHS    B,A             argument 4 of picolRegisterCommand(): int
2579 308DEF5D         (          xyz.asm):07793                 LEAX    _picolCommandRetCodes,PCR       address of picolCommandRetCodes(), defined at xyz.c:948
257D 3410             (          xyz.asm):07794                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):07795         * optim: optimizeTfrPush
257F 308D073B         (          xyz.asm):07796                 LEAX    S00103,PCR      "break"
                      (          xyz.asm):07797         * optim: optimizePshsOps
2583 EC44             (          xyz.asm):07798                 LDD     4,U             variable i, declared at xyz.c:1243
2585 3416             (          xyz.asm):07799                 PSHS    X,B,A           optim: optimizePshsOps
2587 17FE7B           (          xyz.asm):07800                 LBSR    _picolRegisterCommand
258A 3268             (          xyz.asm):07801                 LEAS    8,S
                      (          xyz.asm):07802         * Line xyz.c:1252: function call: picolRegisterCommand()
258C 4F               (          xyz.asm):07803                 CLRA
258D 5F               (          xyz.asm):07804                 CLRB
258E 3406             (          xyz.asm):07805                 PSHS    B,A             argument 4 of picolRegisterCommand(): int
2590 308DEF46         (          xyz.asm):07806                 LEAX    _picolCommandRetCodes,PCR       address of picolCommandRetCodes(), defined at xyz.c:948
2594 3410             (          xyz.asm):07807                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):07808         * optim: optimizeTfrPush
2596 308D072A         (          xyz.asm):07809                 LEAX    S00104,PCR      "continue"
                      (          xyz.asm):07810         * optim: optimizePshsOps
259A EC44             (          xyz.asm):07811                 LDD     4,U             variable i, declared at xyz.c:1243
259C 3416             (          xyz.asm):07812                 PSHS    X,B,A           optim: optimizePshsOps
259E 17FE64           (          xyz.asm):07813                 LBSR    _picolRegisterCommand
25A1 3268             (          xyz.asm):07814                 LEAS    8,S
                      (          xyz.asm):07815         * Line xyz.c:1253: function call: picolRegisterCommand()
25A3 4F               (          xyz.asm):07816                 CLRA
25A4 5F               (          xyz.asm):07817                 CLRB
25A5 3406             (          xyz.asm):07818                 PSHS    B,A             argument 4 of picolRegisterCommand(): int
25A7 308DEDB6         (          xyz.asm):07819                 LEAX    _picolCommandProc,PCR   address of picolCommandProc(), defined at xyz.c:1004
25AB 3410             (          xyz.asm):07820                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):07821         * optim: optimizeTfrPush
25AD 308D07D1         (          xyz.asm):07822                 LEAX    S00129,PCR      "proc"
                      (          xyz.asm):07823         * optim: optimizePshsOps
25B1 EC44             (          xyz.asm):07824                 LDD     4,U             variable i, declared at xyz.c:1243
25B3 3416             (          xyz.asm):07825                 PSHS    X,B,A           optim: optimizePshsOps
25B5 17FE4D           (          xyz.asm):07826                 LBSR    _picolRegisterCommand
25B8 3268             (          xyz.asm):07827                 LEAS    8,S
                      (          xyz.asm):07828         * Line xyz.c:1254: function call: picolRegisterCommand()
25BA 4F               (          xyz.asm):07829                 CLRA
25BB 5F               (          xyz.asm):07830                 CLRB
25BC 3406             (          xyz.asm):07831                 PSHS    B,A             argument 4 of picolRegisterCommand(): int
25BE 308DEF76         (          xyz.asm):07832                 LEAX    _picolCommandReturn,PCR address of picolCommandReturn(), defined at xyz.c:1012
25C2 3410             (          xyz.asm):07833                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):07834         * optim: optimizeTfrPush
25C4 308D07BF         (          xyz.asm):07835                 LEAX    S00130,PCR      "return"
                      (          xyz.asm):07836         * optim: optimizePshsOps
25C8 EC44             (          xyz.asm):07837                 LDD     4,U             variable i, declared at xyz.c:1243
25CA 3416             (          xyz.asm):07838                 PSHS    X,B,A           optim: optimizePshsOps
25CC 17FE36           (          xyz.asm):07839                 LBSR    _picolRegisterCommand
25CF 3268             (          xyz.asm):07840                 LEAS    8,S
                      (          xyz.asm):07841         * Line xyz.c:1255: function call: picolRegisterCommand()
25D1 4F               (          xyz.asm):07842                 CLRA
25D2 5F               (          xyz.asm):07843                 CLRB
25D3 3406             (          xyz.asm):07844                 PSHS    B,A             argument 4 of picolRegisterCommand(): int
25D5 308DEA26         (          xyz.asm):07845                 LEAX    _picolCommandInfo,PCR   address of picolCommandInfo(), defined at xyz.c:1024
25D9 3410             (          xyz.asm):07846                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):07847         * optim: optimizeTfrPush
25DB 308D07AF         (          xyz.asm):07848                 LEAX    S00131,PCR      "info"
                      (          xyz.asm):07849         * optim: optimizePshsOps
25DF EC44             (          xyz.asm):07850                 LDD     4,U             variable i, declared at xyz.c:1243
25E1 3416             (          xyz.asm):07851                 PSHS    X,B,A           optim: optimizePshsOps
25E3 17FE1F           (          xyz.asm):07852                 LBSR    _picolRegisterCommand
25E6 3268             (          xyz.asm):07853                 LEAS    8,S
                      (          xyz.asm):07854         * Line xyz.c:1256: function call: picolRegisterCommand()
25E8 4F               (          xyz.asm):07855                 CLRA
25E9 5F               (          xyz.asm):07856                 CLRB
25EA 3406             (          xyz.asm):07857                 PSHS    B,A             argument 4 of picolRegisterCommand(): int
25EC 308DE833         (          xyz.asm):07858                 LEAX    _picolCommandForEach,PCR        address of picolCommandForEach(), defined at xyz.c:1125
25F0 3410             (          xyz.asm):07859                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):07860         * optim: optimizeTfrPush
25F2 308D079D         (          xyz.asm):07861                 LEAX    S00132,PCR      "foreach"
                      (          xyz.asm):07862         * optim: optimizePshsOps
25F6 EC44             (          xyz.asm):07863                 LDD     4,U             variable i, declared at xyz.c:1243
25F8 3416             (          xyz.asm):07864                 PSHS    X,B,A           optim: optimizePshsOps
25FA 17FE08           (          xyz.asm):07865                 LBSR    _picolRegisterCommand
25FD 3268             (          xyz.asm):07866                 LEAS    8,S
                      (          xyz.asm):07867         * Line xyz.c:1257: function call: picolRegisterCommand()
25FF 4F               (          xyz.asm):07868                 CLRA
2600 5F               (          xyz.asm):07869                 CLRB
2601 3406             (          xyz.asm):07870                 PSHS    B,A             argument 4 of picolRegisterCommand(): int
2603 308DE5EE         (          xyz.asm):07871                 LEAX    _picolCommandCatch,PCR  address of picolCommandCatch(), defined at xyz.c:1114
2607 3410             (          xyz.asm):07872                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):07873         * optim: optimizeTfrPush
2609 308D078E         (          xyz.asm):07874                 LEAX    S00133,PCR      "catch"
                      (          xyz.asm):07875         * optim: optimizePshsOps
260D EC44             (          xyz.asm):07876                 LDD     4,U             variable i, declared at xyz.c:1243
260F 3416             (          xyz.asm):07877                 PSHS    X,B,A           optim: optimizePshsOps
2611 17FDF1           (          xyz.asm):07878                 LBSR    _picolRegisterCommand
2614 3268             (          xyz.asm):07879                 LEAS    8,S
                      (          xyz.asm):07880         * Line xyz.c:1258: function call: picolRegisterCommand()
2616 4F               (          xyz.asm):07881                 CLRA
2617 5F               (          xyz.asm):07882                 CLRB
2618 3406             (          xyz.asm):07883                 PSHS    B,A             argument 4 of picolRegisterCommand(): int
261A 308DEB21         (          xyz.asm):07884                 LEAX    _picolCommandList,PCR   address of picolCommandList(), defined at xyz.c:1164
261E 3410             (          xyz.asm):07885                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):07886         * optim: optimizeTfrPush
2620 308D077D         (          xyz.asm):07887                 LEAX    S00134,PCR      "list"
                      (          xyz.asm):07888         * optim: optimizePshsOps
2624 EC44             (          xyz.asm):07889                 LDD     4,U             variable i, declared at xyz.c:1243
2626 3416             (          xyz.asm):07890                 PSHS    X,B,A           optim: optimizePshsOps
2628 17FDDA           (          xyz.asm):07891                 LBSR    _picolRegisterCommand
262B 3268             (          xyz.asm):07892                 LEAS    8,S
                      (          xyz.asm):07893         * Line xyz.c:1260: function call: picolRegisterCommand()
262D 4F               (          xyz.asm):07894                 CLRA
262E 5F               (          xyz.asm):07895                 CLRB
262F 3406             (          xyz.asm):07896                 PSHS    B,A             argument 4 of picolRegisterCommand(): int
2631 308DE796         (          xyz.asm):07897                 LEAX    _picolCommandExit,PCR   address of picolCommandExit(), defined at xyz.c:1018
2635 3410             (          xyz.asm):07898                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):07899         * optim: optimizeTfrPush
2637 308D076B         (          xyz.asm):07900                 LEAX    S00135,PCR      "exit"
                      (          xyz.asm):07901         * optim: optimizePshsOps
263B EC44             (          xyz.asm):07902                 LDD     4,U             variable i, declared at xyz.c:1243
263D 3416             (          xyz.asm):07903                 PSHS    X,B,A           optim: optimizePshsOps
263F 17FDC3           (          xyz.asm):07904                 LBSR    _picolRegisterCommand
2642 3268             (          xyz.asm):07905                 LEAS    8,S
                      (          xyz.asm):07906         * Line xyz.c:1261: function call: picolRegisterCommand()
2644 4F               (          xyz.asm):07907                 CLRA
2645 5F               (          xyz.asm):07908                 CLRB
2646 3406             (          xyz.asm):07909                 PSHS    B,A             argument 4 of picolRegisterCommand(): int
2648 308DE62D         (          xyz.asm):07910                 LEAX    _picolCommandChain,PCR  address of picolCommandChain(), defined at xyz.c:1185
264C 3410             (          xyz.asm):07911                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):07912         * optim: optimizeTfrPush
264E 308D0759         (          xyz.asm):07913                 LEAX    S00136,PCR      "chain"
                      (          xyz.asm):07914         * optim: optimizePshsOps
2652 EC44             (          xyz.asm):07915                 LDD     4,U             variable i, declared at xyz.c:1243
2654 3416             (          xyz.asm):07916                 PSHS    X,B,A           optim: optimizePshsOps
2656 17FDAC           (          xyz.asm):07917                 LBSR    _picolRegisterCommand
2659 3268             (          xyz.asm):07918                 LEAS    8,S
                      (          xyz.asm):07919         * Line xyz.c:1262: function call: picolRegisterCommand()
265B 4F               (          xyz.asm):07920                 CLRA
265C 5F               (          xyz.asm):07921                 CLRB
265D 3406             (          xyz.asm):07922                 PSHS    B,A             argument 4 of picolRegisterCommand(): int
265F 308DE87A         (          xyz.asm):07923                 LEAX    _picolCommandFork,PCR   address of picolCommandFork(), defined at xyz.c:1196
2663 3410             (          xyz.asm):07924                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):07925         * optim: optimizeTfrPush
2665 308D0748         (          xyz.asm):07926                 LEAX    S00137,PCR      "fork"
                      (          xyz.asm):07927         * optim: optimizePshsOps
2669 EC44             (          xyz.asm):07928                 LDD     4,U             variable i, declared at xyz.c:1243
266B 3416             (          xyz.asm):07929                 PSHS    X,B,A           optim: optimizePshsOps
266D 17FD95           (          xyz.asm):07930                 LBSR    _picolRegisterCommand
2670 3268             (          xyz.asm):07931                 LEAS    8,S
                      (          xyz.asm):07932         * Line xyz.c:1263: function call: picolRegisterCommand()
2672 4F               (          xyz.asm):07933                 CLRA
2673 5F               (          xyz.asm):07934                 CLRB
2674 3406             (          xyz.asm):07935                 PSHS    B,A             argument 4 of picolRegisterCommand(): int
2676 308DF023         (          xyz.asm):07936                 LEAX    _picolCommandWait,PCR   address of picolCommandWait(), defined at xyz.c:1208
267A 3410             (          xyz.asm):07937                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):07938         * optim: optimizeTfrPush
267C 308D0736         (          xyz.asm):07939                 LEAX    S00138,PCR      "wait"
                      (          xyz.asm):07940         * optim: optimizePshsOps
2680 EC44             (          xyz.asm):07941                 LDD     4,U             variable i, declared at xyz.c:1243
2682 3416             (          xyz.asm):07942                 PSHS    X,B,A           optim: optimizePshsOps
2684 17FD7E           (          xyz.asm):07943                 LBSR    _picolRegisterCommand
2687 3268             (          xyz.asm):07944                 LEAS    8,S
                      (          xyz.asm):07945         * Line xyz.c:1264: function call: picolRegisterCommand()
2689 4F               (          xyz.asm):07946                 CLRA
268A 5F               (          xyz.asm):07947                 CLRB
268B 3406             (          xyz.asm):07948                 PSHS    B,A             argument 4 of picolRegisterCommand(): int
268D 308DE6CA         (          xyz.asm):07949                 LEAX    _picolCommandDup,PCR    address of picolCommandDup(), defined at xyz.c:1216
2691 3410             (          xyz.asm):07950                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):07951         * optim: optimizeTfrPush
2693 308D0724         (          xyz.asm):07952                 LEAX    S00139,PCR      "dup"
                      (          xyz.asm):07953         * optim: optimizePshsOps
2697 EC44             (          xyz.asm):07954                 LDD     4,U             variable i, declared at xyz.c:1243
2699 3416             (          xyz.asm):07955                 PSHS    X,B,A           optim: optimizePshsOps
269B 17FD67           (          xyz.asm):07956                 LBSR    _picolRegisterCommand
269E 3268             (          xyz.asm):07957                 LEAS    8,S
                      (          xyz.asm):07958         * Line xyz.c:1265: function call: picolRegisterCommand()
26A0 4F               (          xyz.asm):07959                 CLRA
26A1 5F               (          xyz.asm):07960                 CLRB
26A2 3406             (          xyz.asm):07961                 PSHS    B,A             argument 4 of picolRegisterCommand(): int
26A4 308DE649         (          xyz.asm):07962                 LEAX    _picolCommandClose,PCR  address of picolCommandClose(), defined at xyz.c:1225
26A8 3410             (          xyz.asm):07963                 PSHS    X               optim: optimizeTfrPush
                      (          xyz.asm):07964         * optim: optimizeTfrPush
26AA 308D0711         (          xyz.asm):07965                 LEAX    S00140,PCR      "close"
                      (          xyz.asm):07966         * optim: optimizePshsOps
26AE EC44             (          xyz.asm):07967                 LDD     4,U             variable i, declared at xyz.c:1243
26B0 3416             (          xyz.asm):07968                 PSHS    X,B,A           optim: optimizePshsOps
26B2 17FD50           (          xyz.asm):07969                 LBSR    _picolRegisterCommand
26B5 3268             (          xyz.asm):07970                 LEAS    8,S
                      (          xyz.asm):07971         * Useless label L00082 removed
26B7 32C4             (          xyz.asm):07972                 LEAS    ,U
26B9 35C0             (          xyz.asm):07973                 PULS    U,PC
                      (          xyz.asm):07974         * END FUNCTION picolRegisterCoreCommands(): defined at xyz.c:1243
     26BB             (          xyz.asm):07975         funcend_picolRegisterCoreCommands       EQU *
     0226             (          xyz.asm):07976         funcsize_picolRegisterCoreCommands      EQU     funcend_picolRegisterCoreCommands-_picolRegisterCoreCommands
                      (          xyz.asm):07977         
                      (          xyz.asm):07978         
                      (          xyz.asm):07979         *******************************************************************************
                      (          xyz.asm):07980         
                      (          xyz.asm):07981         * FUNCTION picolSetResult(): defined at xyz.c:716
     26BB             (          xyz.asm):07982         _picolSetResult EQU     *
26BB 3440             (          xyz.asm):07983                 PSHS    U
26BD 17038C           (          xyz.asm):07984                 LBSR    _stkcheck
26C0 FFC0             (          xyz.asm):07985                 FDB     -64             argument for _stkcheck
26C2 33E4             (          xyz.asm):07986                 LEAU    ,S
                      (          xyz.asm):07987         * Formal parameters and locals:
                      (          xyz.asm):07988         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):07989         *   s: const char *; 2 bytes at 6,U
                      (          xyz.asm):07990         * Line xyz.c:717: function call: free()
26C4 AE44             (          xyz.asm):07991                 LDX     4,U             variable i
26C6 EC06             (          xyz.asm):07992                 LDD     6,X             member result of picolInterp
26C8 3406             (          xyz.asm):07993                 PSHS    B,A             argument 1 of free(): char *
26CA 17DF56           (          xyz.asm):07994                 LBSR    _free
26CD 3262             (          xyz.asm):07995                 LEAS    2,S
                      (          xyz.asm):07996         * Line xyz.c:718: assignment: =
                      (          xyz.asm):07997         * Line xyz.c:718: function call: strdup()
26CF EC46             (          xyz.asm):07998                 LDD     6,U             variable s, declared at xyz.c:716
26D1 3406             (          xyz.asm):07999                 PSHS    B,A             argument 1 of strdup(): const char *
26D3 170474           (          xyz.asm):08000                 LBSR    _strdup
26D6 3262             (          xyz.asm):08001                 LEAS    2,S
                      (          xyz.asm):08002         * optim: stripUselessPushPull
26D8 AE44             (          xyz.asm):08003                 LDX     4,U             variable i
                      (          xyz.asm):08004         * optim: optimizeLeax
                      (          xyz.asm):08005         * optim: stripUselessPushPull
26DA ED06             (          xyz.asm):08006                 STD     6,X             optim: optimizeLeax
                      (          xyz.asm):08007         * Useless label L00044 removed
26DC 32C4             (          xyz.asm):08008                 LEAS    ,U
26DE 35C0             (          xyz.asm):08009                 PULS    U,PC
                      (          xyz.asm):08010         * END FUNCTION picolSetResult(): defined at xyz.c:716
     26E0             (          xyz.asm):08011         funcend_picolSetResult  EQU *
     0025             (          xyz.asm):08012         funcsize_picolSetResult EQU     funcend_picolSetResult-_picolSetResult
                      (          xyz.asm):08013         
                      (          xyz.asm):08014         
                      (          xyz.asm):08015         *******************************************************************************
                      (          xyz.asm):08016         
                      (          xyz.asm):08017         * FUNCTION picolSetVar(): defined at xyz.c:730
     26E0             (          xyz.asm):08018         _picolSetVar    EQU     *
26E0 3440             (          xyz.asm):08019                 PSHS    U
26E2 170367           (          xyz.asm):08020                 LBSR    _stkcheck
26E5 FFBE             (          xyz.asm):08021                 FDB     -66             argument for _stkcheck
26E7 33E4             (          xyz.asm):08022                 LEAU    ,S
26E9 327E             (          xyz.asm):08023                 LEAS    -2,S
                      (          xyz.asm):08024         * Formal parameters and locals:
                      (          xyz.asm):08025         *   i: struct picolInterp *; 2 bytes at 4,U
                      (          xyz.asm):08026         *   name: const char *; 2 bytes at 6,U
                      (          xyz.asm):08027         *   val: const char *; 2 bytes at 8,U
                      (          xyz.asm):08028         *   v: struct picolVar *; 2 bytes at -2,U
                      (          xyz.asm):08029         * Line xyz.c:731: init of variable v
                      (          xyz.asm):08030         * Line xyz.c:731: function call: picolGetVar()
26EB EC46             (          xyz.asm):08031                 LDD     6,U             variable name, declared at xyz.c:730
26ED 3406             (          xyz.asm):08032                 PSHS    B,A             argument 2 of picolGetVar(): const char *
26EF EC44             (          xyz.asm):08033                 LDD     4,U             variable i, declared at xyz.c:730
26F1 3406             (          xyz.asm):08034                 PSHS    B,A             argument 1 of picolGetVar(): struct picolInterp *
26F3 17F603           (          xyz.asm):08035                 LBSR    _picolGetVar
26F6 3264             (          xyz.asm):08036                 LEAS    4,S
26F8 ED5E             (          xyz.asm):08037                 STD     -2,U            variable v
                      (          xyz.asm):08038         * Line xyz.c:732: if
                      (          xyz.asm):08039         * optim: storeLoad
26FA C30000           (          xyz.asm):08040                 ADDD    #0
26FD 271A             (          xyz.asm):08041                 BEQ     L00781
                      (          xyz.asm):08042         * optim: condBranchOverUncondBranch
                      (          xyz.asm):08043         * Useless label L00780 removed
                      (          xyz.asm):08044         * Line xyz.c:733: function call: free()
26FF AE5E             (          xyz.asm):08045                 LDX     -2,U            variable v
2701 EC02             (          xyz.asm):08046                 LDD     2,X             member val of picolVar
2703 3406             (          xyz.asm):08047                 PSHS    B,A             argument 1 of free(): char *
2705 17DF1B           (          xyz.asm):08048                 LBSR    _free
2708 3262             (          xyz.asm):08049                 LEAS    2,S
                      (          xyz.asm):08050         * Line xyz.c:734: assignment: =
                      (          xyz.asm):08051         * Line xyz.c:734: function call: strdup()
270A EC48             (          xyz.asm):08052                 LDD     8,U             variable val, declared at xyz.c:730
270C 3406             (          xyz.asm):08053                 PSHS    B,A             argument 1 of strdup(): const char *
270E 170439           (          xyz.asm):08054                 LBSR    _strdup
2711 3262             (          xyz.asm):08055                 LEAS    2,S
                      (          xyz.asm):08056         * optim: stripUselessPushPull
2713 AE5E             (          xyz.asm):08057                 LDX     -2,U            variable v
                      (          xyz.asm):08058         * optim: optimizeLeax
                      (          xyz.asm):08059         * optim: stripUselessPushPull
2715 ED02             (          xyz.asm):08060                 STD     2,X             optim: optimizeLeax
2717 2036             (          xyz.asm):08061                 BRA     L00782          jump over else clause
     2719             (          xyz.asm):08062         L00781  EQU     *               else
                      (          xyz.asm):08063         * Line xyz.c:736: assignment: =
                      (          xyz.asm):08064         * Line xyz.c:736: function call: malloc()
2719 4F               (          xyz.asm):08065                 CLRA
271A C606             (          xyz.asm):08066                 LDB     #$06            constant expression: 6 decimal, unsigned
271C 3406             (          xyz.asm):08067                 PSHS    B,A             argument 1 of malloc(): unsigned int
271E 17E129           (          xyz.asm):08068                 LBSR    _malloc
2721 3262             (          xyz.asm):08069                 LEAS    2,S
2723 ED5E             (          xyz.asm):08070                 STD     -2,U
                      (          xyz.asm):08071         * Line xyz.c:737: assignment: =
                      (          xyz.asm):08072         * Line xyz.c:737: function call: strdup()
2725 EC46             (          xyz.asm):08073                 LDD     6,U             variable name, declared at xyz.c:730
2727 3406             (          xyz.asm):08074                 PSHS    B,A             argument 1 of strdup(): const char *
2729 17041E           (          xyz.asm):08075                 LBSR    _strdup
272C 3262             (          xyz.asm):08076                 LEAS    2,S
                      (          xyz.asm):08077         * optim: stripUselessPushPull
272E AE5E             (          xyz.asm):08078                 LDX     -2,U            variable v
                      (          xyz.asm):08079         * optim: stripUselessPushPull
2730 ED84             (          xyz.asm):08080                 STD     ,X
                      (          xyz.asm):08081         * Line xyz.c:738: assignment: =
                      (          xyz.asm):08082         * Line xyz.c:738: function call: strdup()
2732 EC48             (          xyz.asm):08083                 LDD     8,U             variable val, declared at xyz.c:730
2734 3406             (          xyz.asm):08084                 PSHS    B,A             argument 1 of strdup(): const char *
2736 170411           (          xyz.asm):08085                 LBSR    _strdup
2739 3262             (          xyz.asm):08086                 LEAS    2,S
                      (          xyz.asm):08087         * optim: stripUselessPushPull
273B AE5E             (          xyz.asm):08088                 LDX     -2,U            variable v
                      (          xyz.asm):08089         * optim: optimizeLeax
                      (          xyz.asm):08090         * optim: stripUselessPushPull
273D ED02             (          xyz.asm):08091                 STD     2,X             optim: optimizeLeax
                      (          xyz.asm):08092         * Line xyz.c:739: assignment: =
273F AE44             (          xyz.asm):08093                 LDX     4,U             variable i
                      (          xyz.asm):08094         * optim: optimizeLdx
                      (          xyz.asm):08095         * optim: removeTfrDX
2741 EC9802           (          xyz.asm):08096                 LDD     [2,X]           optim: optimizeLdx
                      (          xyz.asm):08097         * optim: stripUselessPushPull
2744 AE5E             (          xyz.asm):08098                 LDX     -2,U            variable v
                      (          xyz.asm):08099         * optim: optimizeLeax
                      (          xyz.asm):08100         * optim: stripUselessPushPull
2746 ED04             (          xyz.asm):08101                 STD     4,X             optim: optimizeLeax
                      (          xyz.asm):08102         * Line xyz.c:740: assignment: =
2748 EC5E             (          xyz.asm):08103                 LDD     -2,U            variable v, declared at xyz.c:731
                      (          xyz.asm):08104         * optim: stripUselessPushPull
274A AE44             (          xyz.asm):08105                 LDX     4,U             variable i
                      (          xyz.asm):08106         * optim: optimizeLdx
                      (          xyz.asm):08107         * optim: removeTfrDX
                      (          xyz.asm):08108         * optim: stripUselessPushPull
274C ED9802           (          xyz.asm):08109                 STD     [2,X]           optim: optimizeLdx
     274F             (          xyz.asm):08110         L00782  EQU     *               end if
                      (          xyz.asm):08111         * Line xyz.c:742: return with value
274F 4F               (          xyz.asm):08112                 CLRA
2750 5F               (          xyz.asm):08113                 CLRB
                      (          xyz.asm):08114         * optim: branchToNextLocation
                      (          xyz.asm):08115         * Useless label L00046 removed
2751 32C4             (          xyz.asm):08116                 LEAS    ,U
2753 35C0             (          xyz.asm):08117                 PULS    U,PC
                      (          xyz.asm):08118         * END FUNCTION picolSetVar(): defined at xyz.c:730
     2755             (          xyz.asm):08119         funcend_picolSetVar     EQU *
     0075             (          xyz.asm):08120         funcsize_picolSetVar    EQU     funcend_picolSetVar-_picolSetVar
                      (          xyz.asm):08121         
                      (          xyz.asm):08122         
                      (          xyz.asm):08123         *******************************************************************************
                      (          xyz.asm):08124         
                      (          xyz.asm):08125         * FUNCTION printf_d(): defined at xyz.c:241
     2755             (          xyz.asm):08126         _printf_d       EQU     *
2755 3440             (          xyz.asm):08127                 PSHS    U
2757 1702F2           (          xyz.asm):08128                 LBSR    _stkcheck
275A FEF8             (          xyz.asm):08129                 FDB     -264            argument for _stkcheck
275C 33E4             (          xyz.asm):08130                 LEAU    ,S
275E 32E9FF38         (          xyz.asm):08131                 LEAS    -200,S
                      (          xyz.asm):08132         * Formal parameters and locals:
                      (          xyz.asm):08133         *   fmt: const char *; 2 bytes at 4,U
                      (          xyz.asm):08134         *   x: int; 2 bytes at 6,U
                      (          xyz.asm):08135         *   buf: char[]; 200 bytes at -200,U
                      (          xyz.asm):08136         * Line xyz.c:243: function call: snprintf_d()
2762 AE46             (          xyz.asm):08137                 LDX     6,U             optim: transformPshsDPshsD
2764 3410             (          xyz.asm):08138                 PSHS    X               optim: transformPshsDPshsD
2766 AE44             (          xyz.asm):08139                 LDX     4,U             optim: transformPshsDPshsD
                      (          xyz.asm):08140         * optim: optimizePshsOps
2768 4F               (          xyz.asm):08141                 CLRA
2769 C6C8             (          xyz.asm):08142                 LDB     #$C8            decimal 200 signed
276B 3416             (          xyz.asm):08143                 PSHS    X,B,A           optim: optimizePshsOps
276D 30C9FF38         (          xyz.asm):08144                 LEAX    -200,U          address of array buf
2771 3410             (          xyz.asm):08145                 PSHS    X               argument 1 of snprintf_d(): char[]
2773 17013E           (          xyz.asm):08146                 LBSR    _snprintf_d
2776 3268             (          xyz.asm):08147                 LEAS    8,S
                      (          xyz.asm):08148         * Line xyz.c:244: function call: puts()
2778 30C9FF38         (          xyz.asm):08149                 LEAX    -200,U          address of array buf
277C 3410             (          xyz.asm):08150                 PSHS    X               argument 1 of puts(): char[]
277E 1700C7           (          xyz.asm):08151                 LBSR    _puts
2781 3262             (          xyz.asm):08152                 LEAS    2,S
                      (          xyz.asm):08153         * Useless label L00020 removed
2783 32C4             (          xyz.asm):08154                 LEAS    ,U
2785 35C0             (          xyz.asm):08155                 PULS    U,PC
                      (          xyz.asm):08156         * END FUNCTION printf_d(): defined at xyz.c:241
     2787             (          xyz.asm):08157         funcend_printf_d        EQU *
     0032             (          xyz.asm):08158         funcsize_printf_d       EQU     funcend_printf_d-_printf_d
                      (          xyz.asm):08159         
                      (          xyz.asm):08160         
                      (          xyz.asm):08161         *******************************************************************************
                      (          xyz.asm):08162         
                      (          xyz.asm):08163         * FUNCTION printf_s(): defined at xyz.c:247
     2787             (          xyz.asm):08164         _printf_s       EQU     *
2787 3440             (          xyz.asm):08165                 PSHS    U
2789 1702C0           (          xyz.asm):08166                 LBSR    _stkcheck
278C FEF8             (          xyz.asm):08167                 FDB     -264            argument for _stkcheck
278E 33E4             (          xyz.asm):08168                 LEAU    ,S
2790 32E9FF38         (          xyz.asm):08169                 LEAS    -200,S
                      (          xyz.asm):08170         * Formal parameters and locals:
                      (          xyz.asm):08171         *   fmt: const char *; 2 bytes at 4,U
                      (          xyz.asm):08172         *   s: const char *; 2 bytes at 6,U
                      (          xyz.asm):08173         *   buf: char[]; 200 bytes at -200,U
                      (          xyz.asm):08174         * Line xyz.c:249: function call: snprintf_s()
2794 AE46             (          xyz.asm):08175                 LDX     6,U             optim: transformPshsDPshsD
2796 3410             (          xyz.asm):08176                 PSHS    X               optim: transformPshsDPshsD
2798 AE44             (          xyz.asm):08177                 LDX     4,U             optim: transformPshsDPshsD
                      (          xyz.asm):08178         * optim: optimizePshsOps
279A 4F               (          xyz.asm):08179                 CLRA
279B C6C8             (          xyz.asm):08180                 LDB     #$C8            decimal 200 signed
279D 3416             (          xyz.asm):08181                 PSHS    X,B,A           optim: optimizePshsOps
279F 30C9FF38         (          xyz.asm):08182                 LEAX    -200,U          address of array buf
27A3 3410             (          xyz.asm):08183                 PSHS    X               argument 1 of snprintf_s(): char[]
27A5 1701C2           (          xyz.asm):08184                 LBSR    _snprintf_s
27A8 3268             (          xyz.asm):08185                 LEAS    8,S
                      (          xyz.asm):08186         * Line xyz.c:250: function call: puts()
27AA 30C9FF38         (          xyz.asm):08187                 LEAX    -200,U          address of array buf
27AE 3410             (          xyz.asm):08188                 PSHS    X               argument 1 of puts(): char[]
27B0 170095           (          xyz.asm):08189                 LBSR    _puts
27B3 3262             (          xyz.asm):08190                 LEAS    2,S
                      (          xyz.asm):08191         * Useless label L00021 removed
27B5 32C4             (          xyz.asm):08192                 LEAS    ,U
27B7 35C0             (          xyz.asm):08193                 PULS    U,PC
                      (          xyz.asm):08194         * END FUNCTION printf_s(): defined at xyz.c:247
     27B9             (          xyz.asm):08195         funcend_printf_s        EQU *
     0032             (          xyz.asm):08196         funcsize_printf_s       EQU     funcend_printf_s-_printf_s
                      (          xyz.asm):08197         
                      (          xyz.asm):08198         
                      (          xyz.asm):08199         *******************************************************************************
                      (          xyz.asm):08200         
                      (          xyz.asm):08201         * FUNCTION puthex(): defined at xyz.c:93
     27B9             (          xyz.asm):08202         _puthex EQU     *
27B9 3440             (          xyz.asm):08203                 PSHS    U
27BB 17028E           (          xyz.asm):08204                 LBSR    _stkcheck
27BE FFB5             (          xyz.asm):08205                 FDB     -75             argument for _stkcheck
27C0 33E4             (          xyz.asm):08206                 LEAU    ,S
27C2 3275             (          xyz.asm):08207                 LEAS    -11,S
                      (          xyz.asm):08208         * Formal parameters and locals:
                      (          xyz.asm):08209         *   prefix: char; 1 byte at 5,U
                      (          xyz.asm):08210         *   a: int; 2 bytes at 6,U
                      (          xyz.asm):08211         *   buf: char[]; 9 bytes at -11,U
                      (          xyz.asm):08212         *   x: unsigned int; 2 bytes at -2,U
                      (          xyz.asm):08213         * Line xyz.c:95: init of variable x
27C4 EC46             (          xyz.asm):08214                 LDD     6,U             variable a, declared at xyz.c:93
27C6 ED5E             (          xyz.asm):08215                 STD     -2,U            variable x
                      (          xyz.asm):08216         * Line xyz.c:96: assignment: =
27C8 4F               (          xyz.asm):08217                 CLRA
27C9 5F               (          xyz.asm):08218                 CLRB
                      (          xyz.asm):08219         * optim: stripExtraPushPullB
                      (          xyz.asm):08220         * optim: optimizeLeax
                      (          xyz.asm):08221         * optim: stripExtraPushPullB
27CA E75D             (          xyz.asm):08222                 STB     -3,U            optim: optimizeLeax
                      (          xyz.asm):08223         * Line xyz.c:97: assignment: =
27CC C629             (          xyz.asm):08224                 LDB     #$29            optim: removeAndOrMulAddSub
                      (          xyz.asm):08225         * optim: stripExtraPushPullB
27CE 305C             (          xyz.asm):08226                 LEAX    -4,U            index 7 in array buf[]
                      (          xyz.asm):08227         * optim: stripExtraPushPullB
27D0 E784             (          xyz.asm):08228                 STB     ,X
                      (          xyz.asm):08229         * Line xyz.c:98: assignment: =
                      (          xyz.asm):08230         * Line xyz.c:98: function call: hexchar()
27D2 EC5E             (          xyz.asm):08231                 LDD     -2,U            variable x
27D4 4F               (          xyz.asm):08232                 CLRA                    optim: andA_B0
27D5 C40F             (          xyz.asm):08233                 ANDB    #$0F
                      (          xyz.asm):08234         * optim: stripExtraClrA_B
27D7 3406             (          xyz.asm):08235                 PSHS    B,A             argument 1 of hexchar(): unsigned char
27D9 17DF36           (          xyz.asm):08236                 LBSR    _hexchar
27DC 3262             (          xyz.asm):08237                 LEAS    2,S
                      (          xyz.asm):08238         * optim: stripExtraPushPullB
27DE 305B             (          xyz.asm):08239                 LEAX    -5,U            index 6 in array buf[]
                      (          xyz.asm):08240         * optim: stripExtraPushPullB
27E0 E784             (          xyz.asm):08241                 STB     ,X
                      (          xyz.asm):08242         * Line xyz.c:98: assignment: =
27E2 EC5E             (          xyz.asm):08243                 LDD     -2,U            variable x, declared at xyz.c:95
27E4 44               (          xyz.asm):08244                 LSRA
27E5 56               (          xyz.asm):08245                 RORB
27E6 44               (          xyz.asm):08246                 LSRA
27E7 56               (          xyz.asm):08247                 RORB
27E8 44               (          xyz.asm):08248                 LSRA
27E9 56               (          xyz.asm):08249                 RORB
27EA 44               (          xyz.asm):08250                 LSRA
27EB 56               (          xyz.asm):08251                 RORB
27EC ED5E             (          xyz.asm):08252                 STD     -2,U
                      (          xyz.asm):08253         * Line xyz.c:99: assignment: =
                      (          xyz.asm):08254         * Line xyz.c:99: function call: hexchar()
                      (          xyz.asm):08255         * optim: storeLoad
27EE 4F               (          xyz.asm):08256                 CLRA                    optim: andA_B0
27EF C40F             (          xyz.asm):08257                 ANDB    #$0F
                      (          xyz.asm):08258         * optim: stripExtraClrA_B
27F1 3406             (          xyz.asm):08259                 PSHS    B,A             argument 1 of hexchar(): unsigned char
27F3 17DF1C           (          xyz.asm):08260                 LBSR    _hexchar
27F6 3262             (          xyz.asm):08261                 LEAS    2,S
                      (          xyz.asm):08262         * optim: stripExtraPushPullB
27F8 305A             (          xyz.asm):08263                 LEAX    -6,U            index 5 in array buf[]
                      (          xyz.asm):08264         * optim: stripExtraPushPullB
27FA E784             (          xyz.asm):08265                 STB     ,X
                      (          xyz.asm):08266         * Line xyz.c:99: assignment: =
27FC EC5E             (          xyz.asm):08267                 LDD     -2,U            variable x, declared at xyz.c:95
27FE 44               (          xyz.asm):08268                 LSRA
27FF 56               (          xyz.asm):08269                 RORB
2800 44               (          xyz.asm):08270                 LSRA
2801 56               (          xyz.asm):08271                 RORB
2802 44               (          xyz.asm):08272                 LSRA
2803 56               (          xyz.asm):08273                 RORB
2804 44               (          xyz.asm):08274                 LSRA
2805 56               (          xyz.asm):08275                 RORB
2806 ED5E             (          xyz.asm):08276                 STD     -2,U
                      (          xyz.asm):08277         * Line xyz.c:100: assignment: =
                      (          xyz.asm):08278         * Line xyz.c:100: function call: hexchar()
                      (          xyz.asm):08279         * optim: storeLoad
2808 4F               (          xyz.asm):08280                 CLRA                    optim: andA_B0
2809 C40F             (          xyz.asm):08281                 ANDB    #$0F
                      (          xyz.asm):08282         * optim: stripExtraClrA_B
280B 3406             (          xyz.asm):08283                 PSHS    B,A             argument 1 of hexchar(): unsigned char
280D 17DF02           (          xyz.asm):08284                 LBSR    _hexchar
2810 3262             (          xyz.asm):08285                 LEAS    2,S
                      (          xyz.asm):08286         * optim: stripExtraPushPullB
2812 3059             (          xyz.asm):08287                 LEAX    -7,U            index 4 in array buf[]
                      (          xyz.asm):08288         * optim: stripExtraPushPullB
2814 E784             (          xyz.asm):08289                 STB     ,X
                      (          xyz.asm):08290         * Line xyz.c:100: assignment: =
2816 EC5E             (          xyz.asm):08291                 LDD     -2,U            variable x, declared at xyz.c:95
2818 44               (          xyz.asm):08292                 LSRA
2819 56               (          xyz.asm):08293                 RORB
281A 44               (          xyz.asm):08294                 LSRA
281B 56               (          xyz.asm):08295                 RORB
281C 44               (          xyz.asm):08296                 LSRA
281D 56               (          xyz.asm):08297                 RORB
281E 44               (          xyz.asm):08298                 LSRA
281F 56               (          xyz.asm):08299                 RORB
2820 ED5E             (          xyz.asm):08300                 STD     -2,U
                      (          xyz.asm):08301         * Line xyz.c:101: assignment: =
                      (          xyz.asm):08302         * Line xyz.c:101: function call: hexchar()
                      (          xyz.asm):08303         * optim: storeLoad
2822 4F               (          xyz.asm):08304                 CLRA                    optim: andA_B0
2823 C40F             (          xyz.asm):08305                 ANDB    #$0F
                      (          xyz.asm):08306         * optim: stripExtraClrA_B
2825 3406             (          xyz.asm):08307                 PSHS    B,A             argument 1 of hexchar(): unsigned char
2827 17DEE8           (          xyz.asm):08308                 LBSR    _hexchar
282A 3262             (          xyz.asm):08309                 LEAS    2,S
                      (          xyz.asm):08310         * optim: stripExtraPushPullB
                      (          xyz.asm):08311         * optim: optimizeLeax
                      (          xyz.asm):08312         * optim: stripExtraPushPullB
282C E758             (          xyz.asm):08313                 STB     -8,U            optim: optimizeLeax
                      (          xyz.asm):08314         * Line xyz.c:102: assignment: =
282E 4F               (          xyz.asm):08315                 CLRA
282F C63D             (          xyz.asm):08316                 LDB     #$3D            decimal 61 signed
                      (          xyz.asm):08317         * optim: stripExtraPushPullB
                      (          xyz.asm):08318         * optim: optimizeLeax
                      (          xyz.asm):08319         * optim: stripExtraPushPullB
2831 E757             (          xyz.asm):08320                 STB     -9,U            optim: optimizeLeax
                      (          xyz.asm):08321         * Line xyz.c:103: assignment: =
2833 E645             (          xyz.asm):08322                 LDB     5,U             variable prefix, declared at xyz.c:93
                      (          xyz.asm):08323         * optim: stripExtraPushPullB
                      (          xyz.asm):08324         * optim: optimizeLeax
                      (          xyz.asm):08325         * optim: stripExtraPushPullB
2835 E756             (          xyz.asm):08326                 STB     -10,U           optim: optimizeLeax
                      (          xyz.asm):08327         * Line xyz.c:104: assignment: =
                      (          xyz.asm):08328         * optim: stripExtraClrA_B
2837 C628             (          xyz.asm):08329                 LDB     #$28            decimal 40 signed
                      (          xyz.asm):08330         * optim: stripExtraPushPullB
                      (          xyz.asm):08331         * optim: optimizeLeax
                      (          xyz.asm):08332         * optim: stripExtraPushPullB
2839 E755             (          xyz.asm):08333                 STB     -11,U           optim: optimizeLeax
                      (          xyz.asm):08334         * Line xyz.c:105: function call: puts()
283B 3055             (          xyz.asm):08335                 LEAX    -11,U           address of array buf
283D 3410             (          xyz.asm):08336                 PSHS    X               argument 1 of puts(): char[]
283F 170006           (          xyz.asm):08337                 LBSR    _puts
2842 3262             (          xyz.asm):08338                 LEAS    2,S
                      (          xyz.asm):08339         * Useless label L00009 removed
2844 32C4             (          xyz.asm):08340                 LEAS    ,U
2846 35C0             (          xyz.asm):08341                 PULS    U,PC
                      (          xyz.asm):08342         * END FUNCTION puthex(): defined at xyz.c:93
     2848             (          xyz.asm):08343         funcend_puthex  EQU *
     008F             (          xyz.asm):08344         funcsize_puthex EQU     funcend_puthex-_puthex
                      (          xyz.asm):08345         
                      (          xyz.asm):08346         
                      (          xyz.asm):08347         *******************************************************************************
                      (          xyz.asm):08348         
                      (          xyz.asm):08349         * FUNCTION puts(): defined at xyz.c:68
     2848             (          xyz.asm):08350         _puts   EQU     *
                      (          xyz.asm):08351         * Formal parameters and locals:
                      (          xyz.asm):08352         *   s: const char *; 2 bytes at 4,U
                      (          xyz.asm):08353         * Line xyz.c:69: inline assembly
                      (          xyz.asm):08354         * Inline assembly:
                      (          xyz.asm):08355         
                      (          xyz.asm):08356         
2848 3460             (          xyz.asm):08357           pshs y,u
284A AE66             (          xyz.asm):08358           ldx 6,s ; arg1: string to write, for strlen.
284C 3410             (          xyz.asm):08359           pshs x ; push arg1 for strlen
284E 17032E           (          xyz.asm):08360           lbsr _strlen ; see how much to puts.
2851 3262             (          xyz.asm):08361           leas 2,s ; drop 1 arg after strlen
2853 1F02             (          xyz.asm):08362           tfr d,y ; max size (strlen) in y
2855 AE66             (          xyz.asm):08363           ldx 6,s ; arg1: string to write.
2857 4F               (          xyz.asm):08364           clra ; a = path ...
2858 4C               (          xyz.asm):08365           inca ; a = path 1
2859 103F8C           (          xyz.asm):08366           os9 I_WritLn
285C 35E0             (          xyz.asm):08367           puls y,u,pc
                      (          xyz.asm):08368         
                      (          xyz.asm):08369         
                      (          xyz.asm):08370         * End of inline assembly.
                      (          xyz.asm):08371         * Useless label L00007 removed
285E 39               (          xyz.asm):08372                 RTS
                      (          xyz.asm):08373         * END FUNCTION puts(): defined at xyz.c:68
     285F             (          xyz.asm):08374         funcend_puts    EQU *
     0017             (          xyz.asm):08375         funcsize_puts   EQU     funcend_puts-_puts
                      (          xyz.asm):08376         
                      (          xyz.asm):08377         
                      (          xyz.asm):08378         *******************************************************************************
                      (          xyz.asm):08379         
                      (          xyz.asm):08380         * FUNCTION realloc(): defined at xyz.c:347
     285F             (          xyz.asm):08381         _realloc        EQU     *
285F 3440             (          xyz.asm):08382                 PSHS    U
2861 1701E8           (          xyz.asm):08383                 LBSR    _stkcheck
2864 FFBC             (          xyz.asm):08384                 FDB     -68             argument for _stkcheck
2866 33E4             (          xyz.asm):08385                 LEAU    ,S
2868 327C             (          xyz.asm):08386                 LEAS    -4,S
                      (          xyz.asm):08387         * Formal parameters and locals:
                      (          xyz.asm):08388         *   p: void *; 2 bytes at 4,U
                      (          xyz.asm):08389         *   n: int; 2 bytes at 6,U
                      (          xyz.asm):08390         *   h: struct Head *; 2 bytes at -4,U
                      (          xyz.asm):08391         *   z: void *; 2 bytes at -2,U
                      (          xyz.asm):08392         * Line xyz.c:350: init of variable h
286A 4F               (          xyz.asm):08393                 CLRA
286B C601             (          xyz.asm):08394                 LDB     #$01            decimal 1 signed
286D 1F01             (          xyz.asm):08395                 TFR     D,X             optim: pushLoadDLoadX
286F EC44             (          xyz.asm):08396                 LDD     4,U             variable p, declared at xyz.c:347
                      (          xyz.asm):08397         *
2871 3406             (          xyz.asm):08398                 PSHS    B,A             save left side (the pointer)
2873 CC0006           (          xyz.asm):08399                 LDD     #6              size of array element
2876 170587           (          xyz.asm):08400                 LBSR    MUL16           multiply array index by size of array element, result in D
2879 1F01             (          xyz.asm):08401                 TFR     D,X             right side in X
287B 3506             (          xyz.asm):08402                 PULS    A,B             pointer in D
287D 3410             (          xyz.asm):08403                 PSHS    X               right side on stack
287F A3E1             (          xyz.asm):08404                 SUBD    ,S++            subtract integer from pointer
2881 ED5C             (          xyz.asm):08405                 STD     -4,U            variable h
                      (          xyz.asm):08406         * Line xyz.c:351: if
2883 AE5C             (          xyz.asm):08407                 LDX     -4,U            variable h
                      (          xyz.asm):08408         * optim: optimizeStackOperations4
                      (          xyz.asm):08409         * optim: optimizeStackOperations4
2885 EC46             (          xyz.asm):08410                 LDD     6,U             variable n, declared at xyz.c:347
2887 10A303           (          xyz.asm):08411                 CMPD    3,X             optim: optimizeStackOperations4
288A 2E04             (          xyz.asm):08412                 BGT     L00784
                      (          xyz.asm):08413         * optim: condBranchOverUncondBranch
                      (          xyz.asm):08414         * Useless label L00783 removed
                      (          xyz.asm):08415         * Line xyz.c:353: return with value
288C EC44             (          xyz.asm):08416                 LDD     4,U             variable p, declared at xyz.c:347
288E 2020             (          xyz.asm):08417                 BRA     L00025          return (xyz.c:353)
     2890             (          xyz.asm):08418         L00784  EQU     *               else
                      (          xyz.asm):08419         * Useless label L00785 removed
                      (          xyz.asm):08420         * Line xyz.c:356: init of variable z
                      (          xyz.asm):08421         * Line xyz.c:356: function call: malloc()
2890 EC46             (          xyz.asm):08422                 LDD     6,U             variable n, declared at xyz.c:347
2892 3406             (          xyz.asm):08423                 PSHS    B,A             argument 1 of malloc(): int
2894 17DFB3           (          xyz.asm):08424                 LBSR    _malloc
2897 3262             (          xyz.asm):08425                 LEAS    2,S
2899 ED5E             (          xyz.asm):08426                 STD     -2,U            variable z
                      (          xyz.asm):08427         * Line xyz.c:357: function call: memcpy()
289B AE5C             (          xyz.asm):08428                 LDX     -4,U            variable h
289D EC03             (          xyz.asm):08429                 LDD     3,X             member cap of Head
289F 3406             (          xyz.asm):08430                 PSHS    B,A             argument 3 of memcpy(): int
28A1 EC44             (          xyz.asm):08431                 LDD     4,U             variable p, declared at xyz.c:347
28A3 3406             (          xyz.asm):08432                 PSHS    B,A             argument 2 of memcpy(): void *
28A5 EC5E             (          xyz.asm):08433                 LDD     -2,U            variable z, declared at xyz.c:356
28A7 3406             (          xyz.asm):08434                 PSHS    B,A             argument 1 of memcpy(): void *
28A9 17E0FB           (          xyz.asm):08435                 LBSR    _memcpy
28AC 3266             (          xyz.asm):08436                 LEAS    6,S
                      (          xyz.asm):08437         * Line xyz.c:359: return with value
28AE EC5E             (          xyz.asm):08438                 LDD     -2,U            variable z, declared at xyz.c:356
                      (          xyz.asm):08439         * optim: branchToNextLocation
     28B0             (          xyz.asm):08440         L00025  EQU     *               end of realloc()
28B0 32C4             (          xyz.asm):08441                 LEAS    ,U
28B2 35C0             (          xyz.asm):08442                 PULS    U,PC
                      (          xyz.asm):08443         * END FUNCTION realloc(): defined at xyz.c:347
     28B4             (          xyz.asm):08444         funcend_realloc EQU *
     0055             (          xyz.asm):08445         funcsize_realloc        EQU     funcend_realloc-_realloc
                      (          xyz.asm):08446         
                      (          xyz.asm):08447         
                      (          xyz.asm):08448         *******************************************************************************
                      (          xyz.asm):08449         
                      (          xyz.asm):08450         * FUNCTION snprintf_d(): defined at xyz.c:212
     28B4             (          xyz.asm):08451         _snprintf_d     EQU     *
28B4 3440             (          xyz.asm):08452                 PSHS    U
28B6 170193           (          xyz.asm):08453                 LBSR    _stkcheck
28B9 FFAF             (          xyz.asm):08454                 FDB     -81             argument for _stkcheck
28BB 33E4             (          xyz.asm):08455                 LEAU    ,S
28BD 32E8EF           (          xyz.asm):08456                 LEAS    -17,S
                      (          xyz.asm):08457         * Formal parameters and locals:
                      (          xyz.asm):08458         *   buf: char *; 2 bytes at 4,U
                      (          xyz.asm):08459         *   max: int; 2 bytes at 6,U
                      (          xyz.asm):08460         *   fmt: const char *; 2 bytes at 8,U
                      (          xyz.asm):08461         *   x: int; 2 bytes at 10,U
                      (          xyz.asm):08462         *   tmp: char[]; 8 bytes at -10,U
                      (          xyz.asm):08463         *   z: const char *; 2 bytes at -2,U
                      (          xyz.asm):08464         * Line xyz.c:216: if
28C0 EC4A             (          xyz.asm):08465                 LDD     10,U            variable x, declared at xyz.c:212
                      (          xyz.asm):08466         * optim: loadCmpZeroBeqOrBne
28C2 2609             (          xyz.asm):08467                 BNE     L00787
                      (          xyz.asm):08468         * optim: condBranchOverUncondBranch
                      (          xyz.asm):08469         * Useless label L00786 removed
                      (          xyz.asm):08470         * Line xyz.c:217: assignment: =
28C4 308D02F6         (          xyz.asm):08471                 LEAX    S00086,PCR      "0"
                      (          xyz.asm):08472         * optim: optimizeTfrOp
28C8 AF5E             (          xyz.asm):08473                 STX     -2,U            optim: optimizeTfrOp
28CA 160084           (          xyz.asm):08474                 LBRA    L00788          jump over else clause
     28CD             (          xyz.asm):08475         L00787  EQU     *               else
                      (          xyz.asm):08476         * Line xyz.c:219: init of variable neg
28CD 6F51             (          xyz.asm):08477                 CLR     -15,U           variable neg
                      (          xyz.asm):08478         * Line xyz.c:220: init of variable p
28CF 305D             (          xyz.asm):08479                 LEAX    -3,U            offset 7 in array tmp
                      (          xyz.asm):08480         * optim: optimizeTfrOp
28D1 AF52             (          xyz.asm):08481                 STX     -14,U           optim: optimizeTfrOp
                      (          xyz.asm):08482         * Line xyz.c:221: assignment: =
28D3 4F               (          xyz.asm):08483                 CLRA
                      (          xyz.asm):08484         * CLRB  optim: optimizeStackOperations1
                      (          xyz.asm):08485         * PSHS B optim: optimizeStackOperations1
28D4 3052             (          xyz.asm):08486                 LEAX    -14,U           variable p, declared at xyz.c:220
28D6 EC84             (          xyz.asm):08487                 LDD     ,X
28D8 830001           (          xyz.asm):08488                 SUBD    #1
28DB ED84             (          xyz.asm):08489                 STD     ,X
28DD C30001           (          xyz.asm):08490                 ADDD    #1              post increment yields initial value
28E0 1F01             (          xyz.asm):08491                 TFR     D,X
28E2 C600             (          xyz.asm):08492                 LDB     #0              optim: optimizeStackOperations1
28E4 E784             (          xyz.asm):08493                 STB     ,X
                      (          xyz.asm):08494         * Line xyz.c:223: if
28E6 EC4A             (          xyz.asm):08495                 LDD     10,U            variable x
28E8 C30000           (          xyz.asm):08496                 ADDD    #0
28EB 2C10             (          xyz.asm):08497                 BGE     L00790
                      (          xyz.asm):08498         * optim: condBranchOverUncondBranch
                      (          xyz.asm):08499         * Useless label L00789 removed
                      (          xyz.asm):08500         * Line xyz.c:224: assignment: =
28ED 4F               (          xyz.asm):08501                 CLRA
28EE C601             (          xyz.asm):08502                 LDB     #$01            decimal 1 signed
28F0 E751             (          xyz.asm):08503                 STB     -15,U
                      (          xyz.asm):08504         * Line xyz.c:225: assignment: =
28F2 EC4A             (          xyz.asm):08505                 LDD     10,U            variable x, declared at xyz.c:212
28F4 43               (          xyz.asm):08506                 COMA
28F5 53               (          xyz.asm):08507                 COMB
28F6 C30001           (          xyz.asm):08508                 ADDD    #1
28F9 ED54             (          xyz.asm):08509                 STD     -12,U
28FB 2004             (          xyz.asm):08510                 BRA     L00791          jump over else clause
     28FD             (          xyz.asm):08511         L00790  EQU     *               else
                      (          xyz.asm):08512         * Line xyz.c:227: assignment: =
                      (          xyz.asm):08513         * optim: stripConsecutiveLoadsToSameReg
28FD EC4A             (          xyz.asm):08514                 LDD     10,U
28FF ED54             (          xyz.asm):08515                 STD     -12,U
     2901             (          xyz.asm):08516         L00791  EQU     *               end if
                      (          xyz.asm):08517         * Line xyz.c:229: while
2901 202C             (          xyz.asm):08518                 BRA     L00793          jump to while condition
     2903             (          xyz.asm):08519         L00792  EQU     *               while body
                      (          xyz.asm):08520         * Line xyz.c:230: init of variable r
2903 AE54             (          xyz.asm):08521                 LDX     -12,U           left
2905 4F               (          xyz.asm):08522                 CLRA
2906 C60A             (          xyz.asm):08523                 LDB     #$0A            right
2908 17054E           (          xyz.asm):08524                 LBSR    DIV16
290B EDC8EF           (          xyz.asm):08525                 STD     -17,U           variable r
                      (          xyz.asm):08526         * Line xyz.c:231: assignment: =
290E EC54             (          xyz.asm):08527                 LDD     -12,U           variable y, declared at xyz.c:222
2910 17057B           (          xyz.asm):08528                 LBSR    DIV16BY10
2913 ED54             (          xyz.asm):08529                 STD     -12,U
                      (          xyz.asm):08530         * Line xyz.c:232: assignment: =
                      (          xyz.asm):08531         * optim: optimizeStackOperations4
                      (          xyz.asm):08532         * optim: optimizeStackOperations4
2915 C630             (          xyz.asm):08533                 LDB     #$30            optim: lddToLDB
2917 1D               (          xyz.asm):08534                 SEX                     promotion of binary operand
2918 E3C8EF           (          xyz.asm):08535                 ADDD    -17,U           optim: optimizeStackOperations4
291B 3404             (          xyz.asm):08536                 PSHS    B
291D 3052             (          xyz.asm):08537                 LEAX    -14,U           variable p, declared at xyz.c:220
291F EC84             (          xyz.asm):08538                 LDD     ,X
2921 830001           (          xyz.asm):08539                 SUBD    #1
2924 ED84             (          xyz.asm):08540                 STD     ,X
2926 C30001           (          xyz.asm):08541                 ADDD    #1              post increment yields initial value
2929 1F01             (          xyz.asm):08542                 TFR     D,X
292B E6E0             (          xyz.asm):08543                 LDB     ,S+
292D E784             (          xyz.asm):08544                 STB     ,X
     292F             (          xyz.asm):08545         L00793  EQU     *               while condition at xyz.c:229
292F EC54             (          xyz.asm):08546                 LDD     -12,U           variable y, declared at xyz.c:222
                      (          xyz.asm):08547         * optim: loadCmpZeroBeqOrBne
2931 26D0             (          xyz.asm):08548                 BNE     L00792
                      (          xyz.asm):08549         * optim: branchToNextLocation
                      (          xyz.asm):08550         * Useless label L00794 removed
                      (          xyz.asm):08551         * Line xyz.c:234: if
2933 E651             (          xyz.asm):08552                 LDB     -15,U           variable neg, declared at xyz.c:219
                      (          xyz.asm):08553         * optim: loadCmpZeroBeqOrBne
2935 2713             (          xyz.asm):08554                 BEQ     L00796
                      (          xyz.asm):08555         * optim: condBranchOverUncondBranch
                      (          xyz.asm):08556         * Useless label L00795 removed
                      (          xyz.asm):08557         * Line xyz.c:234: assignment: =
2937 4F               (          xyz.asm):08558                 CLRA
                      (          xyz.asm):08559         * LDB #$2D optim: optimizeStackOperations1
                      (          xyz.asm):08560         * PSHS B optim: optimizeStackOperations1
2938 3052             (          xyz.asm):08561                 LEAX    -14,U           variable p, declared at xyz.c:220
293A EC84             (          xyz.asm):08562                 LDD     ,X
293C 830001           (          xyz.asm):08563                 SUBD    #1
293F ED84             (          xyz.asm):08564                 STD     ,X
2941 C30001           (          xyz.asm):08565                 ADDD    #1              post increment yields initial value
2944 1F01             (          xyz.asm):08566                 TFR     D,X
2946 C62D             (          xyz.asm):08567                 LDB     #45             optim: optimizeStackOperations1
2948 E784             (          xyz.asm):08568                 STB     ,X
     294A             (          xyz.asm):08569         L00796  EQU     *               else
                      (          xyz.asm):08570         * Useless label L00797 removed
                      (          xyz.asm):08571         * Line xyz.c:235: assignment: =
294A EC52             (          xyz.asm):08572                 LDD     -14,U           variable p
294C C30001           (          xyz.asm):08573                 ADDD    #$01            1
294F ED5E             (          xyz.asm):08574                 STD     -2,U
     2951             (          xyz.asm):08575         L00788  EQU     *               end if
                      (          xyz.asm):08576         * Line xyz.c:238: function call: snprintf_s()
2951 EC5E             (          xyz.asm):08577                 LDD     -2,U            variable z, declared at xyz.c:214
2953 3406             (          xyz.asm):08578                 PSHS    B,A             argument 4 of snprintf_s(): const char *
2955 EC48             (          xyz.asm):08579                 LDD     8,U             variable fmt, declared at xyz.c:212
2957 3406             (          xyz.asm):08580                 PSHS    B,A             argument 3 of snprintf_s(): const char *
2959 EC46             (          xyz.asm):08581                 LDD     6,U             variable max, declared at xyz.c:212
295B 3406             (          xyz.asm):08582                 PSHS    B,A             argument 2 of snprintf_s(): int
295D EC44             (          xyz.asm):08583                 LDD     4,U             variable buf, declared at xyz.c:212
295F 3406             (          xyz.asm):08584                 PSHS    B,A             argument 1 of snprintf_s(): char *
2961 170006           (          xyz.asm):08585                 LBSR    _snprintf_s
2964 3268             (          xyz.asm):08586                 LEAS    8,S
                      (          xyz.asm):08587         * Useless label L00019 removed
2966 32C4             (          xyz.asm):08588                 LEAS    ,U
2968 35C0             (          xyz.asm):08589                 PULS    U,PC
                      (          xyz.asm):08590         * END FUNCTION snprintf_d(): defined at xyz.c:212
     296A             (          xyz.asm):08591         funcend_snprintf_d      EQU *
     00B6             (          xyz.asm):08592         funcsize_snprintf_d     EQU     funcend_snprintf_d-_snprintf_d
                      (          xyz.asm):08593         
                      (          xyz.asm):08594         
                      (          xyz.asm):08595         *******************************************************************************
                      (          xyz.asm):08596         
                      (          xyz.asm):08597         * FUNCTION snprintf_s(): defined at xyz.c:186
     296A             (          xyz.asm):08598         _snprintf_s     EQU     *
296A 3440             (          xyz.asm):08599                 PSHS    U
296C 1700DD           (          xyz.asm):08600                 LBSR    _stkcheck
296F FFBA             (          xyz.asm):08601                 FDB     -70             argument for _stkcheck
2971 33E4             (          xyz.asm):08602                 LEAU    ,S
2973 327A             (          xyz.asm):08603                 LEAS    -6,S
                      (          xyz.asm):08604         * Formal parameters and locals:
                      (          xyz.asm):08605         *   buf: char *; 2 bytes at 4,U
                      (          xyz.asm):08606         *   max: int; 2 bytes at 6,U
                      (          xyz.asm):08607         *   fmt: const char *; 2 bytes at 8,U
                      (          xyz.asm):08608         *   s: const char *; 2 bytes at 10,U
                      (          xyz.asm):08609         *   flen: int; 2 bytes at -6,U
                      (          xyz.asm):08610         *   slen: int; 2 bytes at -4,U
                      (          xyz.asm):08611         *   p: char *; 2 bytes at -2,U
                      (          xyz.asm):08612         * Line xyz.c:187: init of variable flen
                      (          xyz.asm):08613         * Line xyz.c:187: function call: strlen()
2975 EC48             (          xyz.asm):08614                 LDD     8,U             variable fmt, declared at xyz.c:186
2977 3406             (          xyz.asm):08615                 PSHS    B,A             argument 1 of strlen(): const char *
2979 170203           (          xyz.asm):08616                 LBSR    _strlen
297C 3262             (          xyz.asm):08617                 LEAS    2,S
297E ED5A             (          xyz.asm):08618                 STD     -6,U            variable flen
                      (          xyz.asm):08619         * Line xyz.c:188: init of variable slen
                      (          xyz.asm):08620         * Line xyz.c:188: function call: strlen()
2980 EC4A             (          xyz.asm):08621                 LDD     10,U            variable s, declared at xyz.c:186
2982 3406             (          xyz.asm):08622                 PSHS    B,A             argument 1 of strlen(): const char *
2984 1701F8           (          xyz.asm):08623                 LBSR    _strlen
2987 3262             (          xyz.asm):08624                 LEAS    2,S
2989 ED5C             (          xyz.asm):08625                 STD     -4,U            variable slen
                      (          xyz.asm):08626         * Line xyz.c:189: if
                      (          xyz.asm):08627         * optim: optimize16BitStackOps1
                      (          xyz.asm):08628         * optim: optimize16BitStackOps1
                      (          xyz.asm):08629         * optim: optimizeStackOperations5
                      (          xyz.asm):08630         * optim: optimizeStackOperations5
                      (          xyz.asm):08631         * optim: optimizeStackOperations5
                      (          xyz.asm):08632         * optim: optimizeStackOperations4
                      (          xyz.asm):08633         * optim: optimizeStackOperations4
298B EC5A             (          xyz.asm):08634                 LDD     -6,U            variable flen, declared at xyz.c:187
298D E35C             (          xyz.asm):08635                 ADDD    -4,U            optim: optimizeStackOperations4
298F 830001           (          xyz.asm):08636                 SUBD    #$01            optim: optimizeStackOperations5
2992 10A346           (          xyz.asm):08637                 CMPD    6,U             optim: optimize16BitStackOps1
2995 2F35             (          xyz.asm):08638                 BLE     L00799
                      (          xyz.asm):08639         * optim: condBranchOverUncondBranch
                      (          xyz.asm):08640         * Useless label L00798 removed
                      (          xyz.asm):08641         * Line xyz.c:190: function call: puthex()
2997 EC5A             (          xyz.asm):08642                 LDD     -6,U            variable flen, declared at xyz.c:187
2999 3406             (          xyz.asm):08643                 PSHS    B,A             argument 2 of puthex(): int
299B C666             (          xyz.asm):08644                 LDB     #$66            optim: lddToLDB
299D 1D               (          xyz.asm):08645                 SEX                     promoting byte argument to word
299E 3406             (          xyz.asm):08646                 PSHS    B,A             argument 1 of puthex(): char
29A0 17FE16           (          xyz.asm):08647                 LBSR    _puthex
29A3 3264             (          xyz.asm):08648                 LEAS    4,S
                      (          xyz.asm):08649         * Line xyz.c:191: function call: puthex()
29A5 EC5C             (          xyz.asm):08650                 LDD     -4,U            variable slen, declared at xyz.c:188
29A7 3406             (          xyz.asm):08651                 PSHS    B,A             argument 2 of puthex(): int
29A9 C673             (          xyz.asm):08652                 LDB     #$73            optim: lddToLDB
29AB 1D               (          xyz.asm):08653                 SEX                     promoting byte argument to word
29AC 3406             (          xyz.asm):08654                 PSHS    B,A             argument 1 of puthex(): char
29AE 17FE08           (          xyz.asm):08655                 LBSR    _puthex
29B1 3264             (          xyz.asm):08656                 LEAS    4,S
                      (          xyz.asm):08657         * Line xyz.c:192: function call: puthex()
29B3 EC46             (          xyz.asm):08658                 LDD     6,U             variable max, declared at xyz.c:186
29B5 3406             (          xyz.asm):08659                 PSHS    B,A             argument 2 of puthex(): int
29B7 C66D             (          xyz.asm):08660                 LDB     #$6D            optim: lddToLDB
29B9 1D               (          xyz.asm):08661                 SEX                     promoting byte argument to word
29BA 3406             (          xyz.asm):08662                 PSHS    B,A             argument 1 of puthex(): char
29BC 17FDFA           (          xyz.asm):08663                 LBSR    _puthex
29BF 3264             (          xyz.asm):08664                 LEAS    4,S
                      (          xyz.asm):08665         * Line xyz.c:193: function call: panic()
29C1 308D01E1         (          xyz.asm):08666                 LEAX    S00085,PCR      "buf overflow snprintf_s"
29C5 3410             (          xyz.asm):08667                 PSHS    X               argument 1 of panic(): const char[]
29C7 17E014           (          xyz.asm):08668                 LBSR    _panic
29CA 3262             (          xyz.asm):08669                 LEAS    2,S
     29CC             (          xyz.asm):08670         L00799  EQU     *               else
                      (          xyz.asm):08671         * Useless label L00800 removed
                      (          xyz.asm):08672         * Line xyz.c:196: init of variable p
29CC EC44             (          xyz.asm):08673                 LDD     4,U             variable buf, declared at xyz.c:186
29CE ED5E             (          xyz.asm):08674                 STD     -2,U            variable p
                      (          xyz.asm):08675         * Line xyz.c:197: while
29D0 160056           (          xyz.asm):08676                 LBRA    L00802          jump to while condition
     29D3             (          xyz.asm):08677         L00801  EQU     *               while body
                      (          xyz.asm):08678         * Line xyz.c:198: if
29D3 C625             (          xyz.asm):08679                 LDB     #$25            optim: lddToLDB
29D5 1D               (          xyz.asm):08680                 SEX                     promotion of binary operand
29D6 3406             (          xyz.asm):08681                 PSHS    B,A
                      (          xyz.asm):08682         * optim: optimizeLdx
29D8 E6D808           (          xyz.asm):08683                 LDB     [8,U]           optim: optimizeLdx
29DB 1D               (          xyz.asm):08684                 SEX                     promotion of binary operand
29DC 10A3E1           (          xyz.asm):08685                 CMPD    ,S++
29DF 1026003A         (          xyz.asm):08686                 LBNE    L00805
                      (          xyz.asm):08687         * optim: condBranchOverUncondBranch
                      (          xyz.asm):08688         * Useless label L00807 removed
29E3 AE48             (          xyz.asm):08689                 LDX     8,U             get pointer value
                      (          xyz.asm):08690         * optim: optimizeLeax
29E5 E601             (          xyz.asm):08691                 LDB     1,X             optim: optimizeLeax
29E7 1D               (          xyz.asm):08692                 SEX                     promotion of binary operand
29E8 3406             (          xyz.asm):08693                 PSHS    B,A
29EA C661             (          xyz.asm):08694                 LDB     #$61            optim: lddToLDB
29EC 1D               (          xyz.asm):08695                 SEX                     promotion of binary operand
29ED 10A3E1           (          xyz.asm):08696                 CMPD    ,S++
29F0 2E2B             (          xyz.asm):08697                 BGT     L00805
                      (          xyz.asm):08698         * optim: condBranchOverUncondBranch
                      (          xyz.asm):08699         * Useless label L00806 removed
29F2 C67A             (          xyz.asm):08700                 LDB     #$7A            optim: lddToLDB
29F4 1D               (          xyz.asm):08701                 SEX                     promotion of binary operand
29F5 3406             (          xyz.asm):08702                 PSHS    B,A
29F7 AE48             (          xyz.asm):08703                 LDX     8,U             get pointer value
                      (          xyz.asm):08704         * optim: optimizeLeax
29F9 E601             (          xyz.asm):08705                 LDB     1,X             optim: optimizeLeax
29FB 1D               (          xyz.asm):08706                 SEX                     promotion of binary operand
29FC 10A3E1           (          xyz.asm):08707                 CMPD    ,S++
29FF 2E1C             (          xyz.asm):08708                 BGT     L00805
                      (          xyz.asm):08709         * optim: condBranchOverUncondBranch
                      (          xyz.asm):08710         * Useless label L00804 removed
                      (          xyz.asm):08711         * Line xyz.c:199: assignment: +=
2A01 EC48             (          xyz.asm):08712                 LDD     8,U             variable fmt
2A03 C30002           (          xyz.asm):08713                 ADDD    #$02            += operator at xyz.c:199
2A06 ED48             (          xyz.asm):08714                 STD     8,U
                      (          xyz.asm):08715         * Line xyz.c:200: while
2A08 200C             (          xyz.asm):08716                 BRA     L00809          jump to while condition
     2A0A             (          xyz.asm):08717         L00808  EQU     *               while body
                      (          xyz.asm):08718         * Line xyz.c:200: assignment: =
2A0A AE4A             (          xyz.asm):08719                 LDX     10,U            get pointer s
2A0C E680             (          xyz.asm):08720                 LDB     ,X+             indirection with post-increment
2A0E AF4A             (          xyz.asm):08721                 STX     10,U            store incremented pointer s
                      (          xyz.asm):08722         * optim: stripExtraPushPullB
2A10 AE5E             (          xyz.asm):08723                 LDX     -2,U            get pointer p
                      (          xyz.asm):08724         * optimiz: optimizePostIncrement
                      (          xyz.asm):08725         * optimiz: optimizePostIncrement
2A12 E780             (          xyz.asm):08726                 STB     ,X+             optimiz: optimizePostIncrement
                      (          xyz.asm):08727         * optim: stripExtraPushPullB
2A14 AF5E             (          xyz.asm):08728                 STX     -2,U            optimiz: optimizePostIncrement
     2A16             (          xyz.asm):08729         L00809  EQU     *               while condition at xyz.c:200
                      (          xyz.asm):08730         * optim: optimizeIndexedX
2A16 E6D80A           (          xyz.asm):08731                 LDB     [10,U]          optim: optimizeIndexedX
                      (          xyz.asm):08732         * optim: loadCmpZeroBeqOrBne
2A19 26EF             (          xyz.asm):08733                 BNE     L00808
                      (          xyz.asm):08734         * optim: branchToNextLocation
                      (          xyz.asm):08735         * Useless label L00810 removed
2A1B 2013             (          xyz.asm):08736                 BRA     L00803          break
                      (          xyz.asm):08737         * optim: instrFollowingUncondBranch
     2A1D             (          xyz.asm):08738         L00805  EQU     *               else
                      (          xyz.asm):08739         * Line xyz.c:203: assignment: =
2A1D AE48             (          xyz.asm):08740                 LDX     8,U             get pointer fmt
2A1F E680             (          xyz.asm):08741                 LDB     ,X+             indirection with post-increment
2A21 AF48             (          xyz.asm):08742                 STX     8,U             store incremented pointer fmt
                      (          xyz.asm):08743         * optim: stripExtraPushPullB
2A23 AE5E             (          xyz.asm):08744                 LDX     -2,U            get pointer p
                      (          xyz.asm):08745         * optimiz: optimizePostIncrement
                      (          xyz.asm):08746         * optimiz: optimizePostIncrement
2A25 E780             (          xyz.asm):08747                 STB     ,X+             optimiz: optimizePostIncrement
                      (          xyz.asm):08748         * optim: stripExtraPushPullB
2A27 AF5E             (          xyz.asm):08749                 STX     -2,U            optimiz: optimizePostIncrement
                      (          xyz.asm):08750         * Useless label L00811 removed
     2A29             (          xyz.asm):08751         L00802  EQU     *               while condition at xyz.c:197
                      (          xyz.asm):08752         * optim: optimizeIndexedX
2A29 E6D808           (          xyz.asm):08753                 LDB     [8,U]           optim: optimizeIndexedX
                      (          xyz.asm):08754         * optim: loadCmpZeroBeqOrBne
2A2C 1026FFA3         (          xyz.asm):08755                 LBNE    L00801
                      (          xyz.asm):08756         * optim: branchToNextLocation
     2A30             (          xyz.asm):08757         L00803  EQU     *               after end of while starting at xyz.c:197
                      (          xyz.asm):08758         * Line xyz.c:206: while
2A30 200C             (          xyz.asm):08759                 BRA     L00813          jump to while condition
     2A32             (          xyz.asm):08760         L00812  EQU     *               while body
                      (          xyz.asm):08761         * Line xyz.c:207: assignment: =
2A32 AE48             (          xyz.asm):08762                 LDX     8,U             get pointer fmt
2A34 E680             (          xyz.asm):08763                 LDB     ,X+             indirection with post-increment
2A36 AF48             (          xyz.asm):08764                 STX     8,U             store incremented pointer fmt
                      (          xyz.asm):08765         * optim: stripExtraPushPullB
2A38 AE5E             (          xyz.asm):08766                 LDX     -2,U            get pointer p
                      (          xyz.asm):08767         * optimiz: optimizePostIncrement
                      (          xyz.asm):08768         * optimiz: optimizePostIncrement
2A3A E780             (          xyz.asm):08769                 STB     ,X+             optimiz: optimizePostIncrement
                      (          xyz.asm):08770         * optim: stripExtraPushPullB
2A3C AF5E             (          xyz.asm):08771                 STX     -2,U            optimiz: optimizePostIncrement
     2A3E             (          xyz.asm):08772         L00813  EQU     *               while condition at xyz.c:206
                      (          xyz.asm):08773         * optim: optimizeIndexedX
2A3E E6D808           (          xyz.asm):08774                 LDB     [8,U]           optim: optimizeIndexedX
                      (          xyz.asm):08775         * optim: loadCmpZeroBeqOrBne
2A41 26EF             (          xyz.asm):08776                 BNE     L00812
                      (          xyz.asm):08777         * optim: branchToNextLocation
                      (          xyz.asm):08778         * Useless label L00814 removed
                      (          xyz.asm):08779         * Line xyz.c:209: assignment: =
2A43 4F               (          xyz.asm):08780                 CLRA
2A44 5F               (          xyz.asm):08781                 CLRB
                      (          xyz.asm):08782         * optim: stripExtraPushPullB
                      (          xyz.asm):08783         * optim: optimizeLdx
                      (          xyz.asm):08784         * optim: stripExtraPushPullB
2A45 E7D8FE           (          xyz.asm):08785                 STB     [-2,U]          optim: optimizeLdx
                      (          xyz.asm):08786         * Useless label L00018 removed
2A48 32C4             (          xyz.asm):08787                 LEAS    ,U
2A4A 35C0             (          xyz.asm):08788                 PULS    U,PC
                      (          xyz.asm):08789         * END FUNCTION snprintf_s(): defined at xyz.c:186
     2A4C             (          xyz.asm):08790         funcend_snprintf_s      EQU *
     00E2             (          xyz.asm):08791         funcsize_snprintf_s     EQU     funcend_snprintf_s-_snprintf_s
                      (          xyz.asm):08792         
                      (          xyz.asm):08793         
                      (          xyz.asm):08794         *******************************************************************************
                      (          xyz.asm):08795         
                      (          xyz.asm):08796         * FUNCTION stkcheck(): defined at xyz.c:255
     2A4C             (          xyz.asm):08797         _stkcheck       EQU     *
                      (          xyz.asm):08798         * Line xyz.c:256: inline assembly
                      (          xyz.asm):08799         * Inline assembly:
                      (          xyz.asm):08800         
                      (          xyz.asm):08801         
2A4C 3410             (          xyz.asm):08802           pshs x
2A4E AE62             (          xyz.asm):08803           ldx 2,s ; get the return PC
2A50 3002             (          xyz.asm):08804           leax 2,x ; add 2 to it
2A52 AF62             (          xyz.asm):08805           stx 2,s ; put it back
2A54 3590             (          xyz.asm):08806           puls x,pc ; and use it to return.
                      (          xyz.asm):08807         
                      (          xyz.asm):08808         
                      (          xyz.asm):08809         * End of inline assembly.
                      (          xyz.asm):08810         * Useless label L00022 removed
2A56 39               (          xyz.asm):08811                 RTS
                      (          xyz.asm):08812         * END FUNCTION stkcheck(): defined at xyz.c:255
     2A57             (          xyz.asm):08813         funcend_stkcheck        EQU *
     000B             (          xyz.asm):08814         funcsize_stkcheck       EQU     funcend_stkcheck-_stkcheck
                      (          xyz.asm):08815         
                      (          xyz.asm):08816         
                      (          xyz.asm):08817         *******************************************************************************
                      (          xyz.asm):08818         
                      (          xyz.asm):08819         * FUNCTION strcasecmp(): defined at xyz.c:160
     2A57             (          xyz.asm):08820         _strcasecmp     EQU     *
2A57 3440             (          xyz.asm):08821                 PSHS    U
2A59 17FFF0           (          xyz.asm):08822                 LBSR    _stkcheck
2A5C FFC0             (          xyz.asm):08823                 FDB     -64             argument for _stkcheck
2A5E 33E4             (          xyz.asm):08824                 LEAU    ,S
                      (          xyz.asm):08825         * Formal parameters and locals:
                      (          xyz.asm):08826         *   a: const char *; 2 bytes at 4,U
                      (          xyz.asm):08827         *   b: const char *; 2 bytes at 6,U
                      (          xyz.asm):08828         * Line xyz.c:161: while
2A60 160062           (          xyz.asm):08829                 LBRA    L00816          jump to while condition
     2A63             (          xyz.asm):08830         L00815  EQU     *               while body
                      (          xyz.asm):08831         * Line xyz.c:162: if
                      (          xyz.asm):08832         * Line xyz.c:162: function call: Up()
2A63 AE46             (          xyz.asm):08833                 LDX     6,U             get address for indirection of variable b
2A65 E684             (          xyz.asm):08834                 LDB     ,X              indirection
2A67 1D               (          xyz.asm):08835                 SEX                     promoting byte argument to word
2A68 3406             (          xyz.asm):08836                 PSHS    B,A             argument 1 of Up(): const char
2A6A 17D983           (          xyz.asm):08837                 LBSR    _Up
2A6D 3262             (          xyz.asm):08838                 LEAS    2,S
2A6F 4F               (          xyz.asm):08839                 CLRA                    promotion of binary operand
2A70 3406             (          xyz.asm):08840                 PSHS    B,A
                      (          xyz.asm):08841         * Line xyz.c:162: function call: Up()
2A72 AE44             (          xyz.asm):08842                 LDX     4,U             get address for indirection of variable a
2A74 E684             (          xyz.asm):08843                 LDB     ,X              indirection
2A76 1D               (          xyz.asm):08844                 SEX                     promoting byte argument to word
2A77 3406             (          xyz.asm):08845                 PSHS    B,A             argument 1 of Up(): const char
2A79 17D974           (          xyz.asm):08846                 LBSR    _Up
2A7C 3262             (          xyz.asm):08847                 LEAS    2,S
2A7E 4F               (          xyz.asm):08848                 CLRA                    promotion of binary operand
2A7F 3261             (          xyz.asm):08849                 LEAS    1,S             disregard MSB
2A81 E1E0             (          xyz.asm):08850                 CMPB    ,S+             compare with LSB
2A83 2406             (          xyz.asm):08851                 BHS     L00819
                      (          xyz.asm):08852         * optim: condBranchOverUncondBranch
                      (          xyz.asm):08853         * Useless label L00818 removed
                      (          xyz.asm):08854         * Line xyz.c:162: return with value
2A85 CCFFFF           (          xyz.asm):08855                 LDD     #$FFFF          constant expression: 65535 decimal, signed
2A88 160096           (          xyz.asm):08856                 LBRA    L00014          return (xyz.c:162)
     2A8B             (          xyz.asm):08857         L00819  EQU     *               else
                      (          xyz.asm):08858         * Useless label L00820 removed
                      (          xyz.asm):08859         * Line xyz.c:163: if
                      (          xyz.asm):08860         * Line xyz.c:163: function call: Up()
2A8B AE46             (          xyz.asm):08861                 LDX     6,U             get address for indirection of variable b
2A8D E684             (          xyz.asm):08862                 LDB     ,X              indirection
2A8F 1D               (          xyz.asm):08863                 SEX                     promoting byte argument to word
2A90 3406             (          xyz.asm):08864                 PSHS    B,A             argument 1 of Up(): const char
2A92 17D95B           (          xyz.asm):08865                 LBSR    _Up
2A95 3262             (          xyz.asm):08866                 LEAS    2,S
2A97 4F               (          xyz.asm):08867                 CLRA                    promotion of binary operand
2A98 3406             (          xyz.asm):08868                 PSHS    B,A
                      (          xyz.asm):08869         * Line xyz.c:163: function call: Up()
2A9A AE44             (          xyz.asm):08870                 LDX     4,U             get address for indirection of variable a
2A9C E684             (          xyz.asm):08871                 LDB     ,X              indirection
2A9E 1D               (          xyz.asm):08872                 SEX                     promoting byte argument to word
2A9F 3406             (          xyz.asm):08873                 PSHS    B,A             argument 1 of Up(): const char
2AA1 17D94C           (          xyz.asm):08874                 LBSR    _Up
2AA4 3262             (          xyz.asm):08875                 LEAS    2,S
2AA6 4F               (          xyz.asm):08876                 CLRA                    promotion of binary operand
2AA7 3261             (          xyz.asm):08877                 LEAS    1,S             disregard MSB
2AA9 E1E0             (          xyz.asm):08878                 CMPB    ,S+             compare with LSB
2AAB 2306             (          xyz.asm):08879                 BLS     L00822
                      (          xyz.asm):08880         * optim: condBranchOverUncondBranch
                      (          xyz.asm):08881         * Useless label L00821 removed
                      (          xyz.asm):08882         * Line xyz.c:163: return with value
2AAD 4F               (          xyz.asm):08883                 CLRA
2AAE C601             (          xyz.asm):08884                 LDB     #$01            constant expression: 1 decimal, signed
2AB0 16006E           (          xyz.asm):08885                 LBRA    L00014          return (xyz.c:163)
     2AB3             (          xyz.asm):08886         L00822  EQU     *               else
                      (          xyz.asm):08887         * Useless label L00823 removed
2AB3 3044             (          xyz.asm):08888                 LEAX    4,U             variable a, declared at xyz.c:160
2AB5 EC84             (          xyz.asm):08889                 LDD     ,X
2AB7 C30001           (          xyz.asm):08890                 ADDD    #1
2ABA ED84             (          xyz.asm):08891                 STD     ,X
                      (          xyz.asm):08892         * optim: removeUselessOps
2ABC 3046             (          xyz.asm):08893                 LEAX    6,U             variable b, declared at xyz.c:160
2ABE EC84             (          xyz.asm):08894                 LDD     ,X
2AC0 C30001           (          xyz.asm):08895                 ADDD    #1
2AC3 ED84             (          xyz.asm):08896                 STD     ,X
                      (          xyz.asm):08897         * optim: removeUselessOps
     2AC5             (          xyz.asm):08898         L00816  EQU     *               while condition at xyz.c:161
                      (          xyz.asm):08899         * optim: optimizeIndexedX
2AC5 E6D804           (          xyz.asm):08900                 LDB     [4,U]           optim: optimizeIndexedX
                      (          xyz.asm):08901         * optim: loadCmpZeroBeqOrBne
2AC8 2707             (          xyz.asm):08902                 BEQ     L00817
                      (          xyz.asm):08903         * optim: condBranchOverUncondBranch
                      (          xyz.asm):08904         * Useless label L00824 removed
                      (          xyz.asm):08905         * optim: optimizeIndexedX
2ACA E6D806           (          xyz.asm):08906                 LDB     [6,U]           optim: optimizeIndexedX
                      (          xyz.asm):08907         * optim: loadCmpZeroBeqOrBne
2ACD 1026FF92         (          xyz.asm):08908                 LBNE    L00815
                      (          xyz.asm):08909         * optim: branchToNextLocation
     2AD1             (          xyz.asm):08910         L00817  EQU     *               after end of while starting at xyz.c:161
                      (          xyz.asm):08911         * Line xyz.c:167: if
                      (          xyz.asm):08912         * Line xyz.c:167: function call: Up()
2AD1 AE46             (          xyz.asm):08913                 LDX     6,U             get address for indirection of variable b
2AD3 E684             (          xyz.asm):08914                 LDB     ,X              indirection
2AD5 1D               (          xyz.asm):08915                 SEX                     promoting byte argument to word
2AD6 3406             (          xyz.asm):08916                 PSHS    B,A             argument 1 of Up(): const char
2AD8 17D915           (          xyz.asm):08917                 LBSR    _Up
2ADB 3262             (          xyz.asm):08918                 LEAS    2,S
2ADD 4F               (          xyz.asm):08919                 CLRA                    promotion of binary operand
2ADE 3406             (          xyz.asm):08920                 PSHS    B,A
                      (          xyz.asm):08921         * Line xyz.c:167: function call: Up()
2AE0 AE44             (          xyz.asm):08922                 LDX     4,U             get address for indirection of variable a
2AE2 E684             (          xyz.asm):08923                 LDB     ,X              indirection
2AE4 1D               (          xyz.asm):08924                 SEX                     promoting byte argument to word
2AE5 3406             (          xyz.asm):08925                 PSHS    B,A             argument 1 of Up(): const char
2AE7 17D906           (          xyz.asm):08926                 LBSR    _Up
2AEA 3262             (          xyz.asm):08927                 LEAS    2,S
2AEC 4F               (          xyz.asm):08928                 CLRA                    promotion of binary operand
2AED 3261             (          xyz.asm):08929                 LEAS    1,S             disregard MSB
2AEF E1E0             (          xyz.asm):08930                 CMPB    ,S+             compare with LSB
2AF1 2405             (          xyz.asm):08931                 BHS     L00826
                      (          xyz.asm):08932         * optim: condBranchOverUncondBranch
                      (          xyz.asm):08933         * Useless label L00825 removed
                      (          xyz.asm):08934         * Line xyz.c:167: return with value
2AF3 CCFFFF           (          xyz.asm):08935                 LDD     #$FFFF          constant expression: 65535 decimal, signed
2AF6 2029             (          xyz.asm):08936                 BRA     L00014          return (xyz.c:167)
     2AF8             (          xyz.asm):08937         L00826  EQU     *               else
                      (          xyz.asm):08938         * Useless label L00827 removed
                      (          xyz.asm):08939         * Line xyz.c:168: if
                      (          xyz.asm):08940         * Line xyz.c:168: function call: Up()
2AF8 AE46             (          xyz.asm):08941                 LDX     6,U             get address for indirection of variable b
2AFA E684             (          xyz.asm):08942                 LDB     ,X              indirection
2AFC 1D               (          xyz.asm):08943                 SEX                     promoting byte argument to word
2AFD 3406             (          xyz.asm):08944                 PSHS    B,A             argument 1 of Up(): const char
2AFF 17D8EE           (          xyz.asm):08945                 LBSR    _Up
2B02 3262             (          xyz.asm):08946                 LEAS    2,S
2B04 4F               (          xyz.asm):08947                 CLRA                    promotion of binary operand
2B05 3406             (          xyz.asm):08948                 PSHS    B,A
                      (          xyz.asm):08949         * Line xyz.c:168: function call: Up()
2B07 AE44             (          xyz.asm):08950                 LDX     4,U             get address for indirection of variable a
2B09 E684             (          xyz.asm):08951                 LDB     ,X              indirection
2B0B 1D               (          xyz.asm):08952                 SEX                     promoting byte argument to word
2B0C 3406             (          xyz.asm):08953                 PSHS    B,A             argument 1 of Up(): const char
2B0E 17D8DF           (          xyz.asm):08954                 LBSR    _Up
2B11 3262             (          xyz.asm):08955                 LEAS    2,S
2B13 4F               (          xyz.asm):08956                 CLRA                    promotion of binary operand
2B14 3261             (          xyz.asm):08957                 LEAS    1,S             disregard MSB
2B16 E1E0             (          xyz.asm):08958                 CMPB    ,S+             compare with LSB
2B18 2305             (          xyz.asm):08959                 BLS     L00829
                      (          xyz.asm):08960         * optim: condBranchOverUncondBranch
                      (          xyz.asm):08961         * Useless label L00828 removed
                      (          xyz.asm):08962         * Line xyz.c:168: return with value
2B1A 4F               (          xyz.asm):08963                 CLRA
2B1B C601             (          xyz.asm):08964                 LDB     #$01            constant expression: 1 decimal, signed
2B1D 2002             (          xyz.asm):08965                 BRA     L00014          return (xyz.c:168)
     2B1F             (          xyz.asm):08966         L00829  EQU     *               else
                      (          xyz.asm):08967         * Useless label L00830 removed
                      (          xyz.asm):08968         * Line xyz.c:169: return with value
2B1F 4F               (          xyz.asm):08969                 CLRA
2B20 5F               (          xyz.asm):08970                 CLRB
                      (          xyz.asm):08971         * optim: branchToNextLocation
     2B21             (          xyz.asm):08972         L00014  EQU     *               end of strcasecmp()
2B21 32C4             (          xyz.asm):08973                 LEAS    ,U
2B23 35C0             (          xyz.asm):08974                 PULS    U,PC
                      (          xyz.asm):08975         * END FUNCTION strcasecmp(): defined at xyz.c:160
     2B25             (          xyz.asm):08976         funcend_strcasecmp      EQU *
     00CE             (          xyz.asm):08977         funcsize_strcasecmp     EQU     funcend_strcasecmp-_strcasecmp
                      (          xyz.asm):08978         
                      (          xyz.asm):08979         
                      (          xyz.asm):08980         *******************************************************************************
                      (          xyz.asm):08981         
                      (          xyz.asm):08982         * FUNCTION strcpy(): defined at xyz.c:171
     2B25             (          xyz.asm):08983         _strcpy EQU     *
2B25 3440             (          xyz.asm):08984                 PSHS    U
2B27 17FF22           (          xyz.asm):08985                 LBSR    _stkcheck
2B2A FFC0             (          xyz.asm):08986                 FDB     -64             argument for _stkcheck
2B2C 33E4             (          xyz.asm):08987                 LEAU    ,S
                      (          xyz.asm):08988         * Formal parameters and locals:
                      (          xyz.asm):08989         *   d: char *; 2 bytes at 4,U
                      (          xyz.asm):08990         *   s: const char *; 2 bytes at 6,U
                      (          xyz.asm):08991         * Line xyz.c:172: while
2B2E 200C             (          xyz.asm):08992                 BRA     L00832          jump to while condition
     2B30             (          xyz.asm):08993         L00831  EQU     *               while body
                      (          xyz.asm):08994         * Line xyz.c:173: assignment: =
2B30 AE46             (          xyz.asm):08995                 LDX     6,U             get pointer s
2B32 E680             (          xyz.asm):08996                 LDB     ,X+             indirection with post-increment
2B34 AF46             (          xyz.asm):08997                 STX     6,U             store incremented pointer s
                      (          xyz.asm):08998         * optim: stripExtraPushPullB
2B36 AE44             (          xyz.asm):08999                 LDX     4,U             get pointer d
                      (          xyz.asm):09000         * optimiz: optimizePostIncrement
                      (          xyz.asm):09001         * optimiz: optimizePostIncrement
2B38 E780             (          xyz.asm):09002                 STB     ,X+             optimiz: optimizePostIncrement
                      (          xyz.asm):09003         * optim: stripExtraPushPullB
2B3A AF44             (          xyz.asm):09004                 STX     4,U             optimiz: optimizePostIncrement
     2B3C             (          xyz.asm):09005         L00832  EQU     *               while condition at xyz.c:172
                      (          xyz.asm):09006         * optim: optimizeIndexedX
2B3C E6D806           (          xyz.asm):09007                 LDB     [6,U]           optim: optimizeIndexedX
                      (          xyz.asm):09008         * optim: loadCmpZeroBeqOrBne
2B3F 26EF             (          xyz.asm):09009                 BNE     L00831
                      (          xyz.asm):09010         * optim: branchToNextLocation
                      (          xyz.asm):09011         * Useless label L00833 removed
                      (          xyz.asm):09012         * Line xyz.c:175: assignment: =
2B41 4F               (          xyz.asm):09013                 CLRA
2B42 5F               (          xyz.asm):09014                 CLRB
                      (          xyz.asm):09015         * optim: stripExtraPushPullB
                      (          xyz.asm):09016         * optim: optimizeLdx
                      (          xyz.asm):09017         * optim: stripExtraPushPullB
2B43 E7D804           (          xyz.asm):09018                 STB     [4,U]           optim: optimizeLdx
                      (          xyz.asm):09019         * Useless label L00015 removed
2B46 32C4             (          xyz.asm):09020                 LEAS    ,U
2B48 35C0             (          xyz.asm):09021                 PULS    U,PC
                      (          xyz.asm):09022         * END FUNCTION strcpy(): defined at xyz.c:171
     2B4A             (          xyz.asm):09023         funcend_strcpy  EQU *
     0025             (          xyz.asm):09024         funcsize_strcpy EQU     funcend_strcpy-_strcpy
                      (          xyz.asm):09025         
                      (          xyz.asm):09026         
                      (          xyz.asm):09027         *******************************************************************************
                      (          xyz.asm):09028         
                      (          xyz.asm):09029         * FUNCTION strdup(): defined at xyz.c:362
     2B4A             (          xyz.asm):09030         _strdup EQU     *
2B4A 3440             (          xyz.asm):09031                 PSHS    U
2B4C 17FEFD           (          xyz.asm):09032                 LBSR    _stkcheck
2B4F FFBC             (          xyz.asm):09033                 FDB     -68             argument for _stkcheck
2B51 33E4             (          xyz.asm):09034                 LEAU    ,S
2B53 327C             (          xyz.asm):09035                 LEAS    -4,S
                      (          xyz.asm):09036         * Formal parameters and locals:
                      (          xyz.asm):09037         *   s: const char *; 2 bytes at 4,U
                      (          xyz.asm):09038         *   n: int; 2 bytes at -4,U
                      (          xyz.asm):09039         *   p: char *; 2 bytes at -2,U
                      (          xyz.asm):09040         * Line xyz.c:363: init of variable n
                      (          xyz.asm):09041         * Line xyz.c:363: function call: strlen()
2B55 EC44             (          xyz.asm):09042                 LDD     4,U             variable s, declared at xyz.c:362
2B57 3406             (          xyz.asm):09043                 PSHS    B,A             argument 1 of strlen(): const char *
2B59 170023           (          xyz.asm):09044                 LBSR    _strlen
2B5C 3262             (          xyz.asm):09045                 LEAS    2,S
2B5E ED5C             (          xyz.asm):09046                 STD     -4,U            variable n
                      (          xyz.asm):09047         * Line xyz.c:364: init of variable p
                      (          xyz.asm):09048         * Line xyz.c:364: function call: malloc()
                      (          xyz.asm):09049         * optim: storeLoad
2B60 C30001           (          xyz.asm):09050                 ADDD    #$01            1
2B63 3406             (          xyz.asm):09051                 PSHS    B,A             argument 1 of malloc(): int
2B65 17DCE2           (          xyz.asm):09052                 LBSR    _malloc
2B68 3262             (          xyz.asm):09053                 LEAS    2,S
2B6A ED5E             (          xyz.asm):09054                 STD     -2,U            variable p
                      (          xyz.asm):09055         * Line xyz.c:365: function call: strcpy()
2B6C EC44             (          xyz.asm):09056                 LDD     4,U             variable s, declared at xyz.c:362
2B6E 3406             (          xyz.asm):09057                 PSHS    B,A             argument 2 of strcpy(): const char *
2B70 EC5E             (          xyz.asm):09058                 LDD     -2,U            variable p, declared at xyz.c:364
2B72 3406             (          xyz.asm):09059                 PSHS    B,A             argument 1 of strcpy(): char *
2B74 17FFAE           (          xyz.asm):09060                 LBSR    _strcpy
2B77 3264             (          xyz.asm):09061                 LEAS    4,S
                      (          xyz.asm):09062         * Line xyz.c:366: return with value
2B79 EC5E             (          xyz.asm):09063                 LDD     -2,U            variable p, declared at xyz.c:364
                      (          xyz.asm):09064         * optim: branchToNextLocation
                      (          xyz.asm):09065         * Useless label L00026 removed
2B7B 32C4             (          xyz.asm):09066                 LEAS    ,U
2B7D 35C0             (          xyz.asm):09067                 PULS    U,PC
                      (          xyz.asm):09068         * END FUNCTION strdup(): defined at xyz.c:362
     2B7F             (          xyz.asm):09069         funcend_strdup  EQU *
     0035             (          xyz.asm):09070         funcsize_strdup EQU     funcend_strdup-_strdup
                      (          xyz.asm):09071         
                      (          xyz.asm):09072         
                      (          xyz.asm):09073         *******************************************************************************
                      (          xyz.asm):09074         
                      (          xyz.asm):09075         * FUNCTION strlen(): defined at xyz.c:177
     2B7F             (          xyz.asm):09076         _strlen EQU     *
2B7F 3440             (          xyz.asm):09077                 PSHS    U
2B81 17FEC8           (          xyz.asm):09078                 LBSR    _stkcheck
2B84 FFBE             (          xyz.asm):09079                 FDB     -66             argument for _stkcheck
2B86 33E4             (          xyz.asm):09080                 LEAU    ,S
2B88 327E             (          xyz.asm):09081                 LEAS    -2,S
                      (          xyz.asm):09082         * Formal parameters and locals:
                      (          xyz.asm):09083         *   p: const char *; 2 bytes at 4,U
                      (          xyz.asm):09084         *   q: const char *; 2 bytes at -2,U
                      (          xyz.asm):09085         * Line xyz.c:178: init of variable q
2B8A EC44             (          xyz.asm):09086                 LDD     4,U             variable p, declared at xyz.c:177
2B8C ED5E             (          xyz.asm):09087                 STD     -2,U            variable q
                      (          xyz.asm):09088         * Line xyz.c:179: while
2B8E 2009             (          xyz.asm):09089                 BRA     L00835          jump to while condition
     2B90             (          xyz.asm):09090         L00834  EQU     *               while body
2B90 305E             (          xyz.asm):09091                 LEAX    -2,U            variable q, declared at xyz.c:178
2B92 EC84             (          xyz.asm):09092                 LDD     ,X
2B94 C30001           (          xyz.asm):09093                 ADDD    #1
2B97 ED84             (          xyz.asm):09094                 STD     ,X
                      (          xyz.asm):09095         * optim: removeUselessOps
     2B99             (          xyz.asm):09096         L00835  EQU     *               while condition at xyz.c:179
                      (          xyz.asm):09097         * optim: optimizeIndexedX
2B99 E6D8FE           (          xyz.asm):09098                 LDB     [-2,U]          optim: optimizeIndexedX
                      (          xyz.asm):09099         * optim: loadCmpZeroBeqOrBne
2B9C 26F2             (          xyz.asm):09100                 BNE     L00834
                      (          xyz.asm):09101         * optim: branchToNextLocation
                      (          xyz.asm):09102         * Useless label L00836 removed
                      (          xyz.asm):09103         * Line xyz.c:180: return with value
                      (          xyz.asm):09104         * optim: optimizeStackOperations4
                      (          xyz.asm):09105         * optim: optimizeStackOperations4
2B9E EC5E             (          xyz.asm):09106                 LDD     -2,U            variable q, declared at xyz.c:178
2BA0 A344             (          xyz.asm):09107                 SUBD    4,U             optim: optimizeStackOperations4
                      (          xyz.asm):09108         * optim: branchToNextLocation
                      (          xyz.asm):09109         * Useless label L00016 removed
2BA2 32C4             (          xyz.asm):09110                 LEAS    ,U
2BA4 35C0             (          xyz.asm):09111                 PULS    U,PC
                      (          xyz.asm):09112         * END FUNCTION strlen(): defined at xyz.c:177
     2BA6             (          xyz.asm):09113         funcend_strlen  EQU *
     0027             (          xyz.asm):09114         funcsize_strlen EQU     funcend_strlen-_strlen
                      (          xyz.asm):09115         
                      (          xyz.asm):09116         
                      (          xyz.asm):09117         
                      (          xyz.asm):09118         
                      (          xyz.asm):09119         
                      (          xyz.asm):09120         
                      (          xyz.asm):09121         
                      (          xyz.asm):09122         
     2BA6             (          xyz.asm):09123         string_literals_start   EQU     *
                      (          xyz.asm):09124         
                      (          xyz.asm):09125         
                      (          xyz.asm):09126         *******************************************************************************
                      (          xyz.asm):09127         
                      (          xyz.asm):09128         * STRING LITERALS
     2BA6             (          xyz.asm):09129         S00085  EQU     *
2BA6 627566206F766572 (          xyz.asm):09130                 FCC     "buf overflow snprintf_s"
     666C6F7720736E70
     72696E74665F73
2BBD 00               (          xyz.asm):09131                 FCB     0
     2BBE             (          xyz.asm):09132         S00086  EQU     *
2BBE 30               (          xyz.asm):09133                 FCC     "0"
2BBF 00               (          xyz.asm):09134                 FCB     0
     2BC0             (          xyz.asm):09135         S00087  EQU     *
2BC0 6D616C6C6F632074 (          xyz.asm):09136                 FCC     "malloc too big"
     6F6F20626967
2BCE 00               (          xyz.asm):09137                 FCB     0
     2BCF             (          xyz.asm):09138         S00088  EQU     *
2BCF 6D616C6C6F633A20 (          xyz.asm):09139                 FCC     "malloc: corrupt magicA"
     636F727275707420
     6D6167696341
2BE5 00               (          xyz.asm):09140                 FCB     0
     2BE6             (          xyz.asm):09141         S00089  EQU     *
2BE6 6D616C6C6F633A20 (          xyz.asm):09142                 FCC     "malloc: corrupt magicZ"
     636F727275707420
     6D616769635A
2BFC 00               (          xyz.asm):09143                 FCB     0
     2BFD             (          xyz.asm):09144         S00090  EQU     *
2BFD 636F727275707420 (          xyz.asm):09145                 FCC     "corrupt cap"
     636170
2C08 00               (          xyz.asm):09146                 FCB     0
     2C09             (          xyz.asm):09147         S00091  EQU     *
2C09 202A6F6F6D2A20   (          xyz.asm):09148                 FCC     " *oom* "
2C10 00               (          xyz.asm):09149                 FCB     0
     2C11             (          xyz.asm):09150         S00092  EQU     *
2C11 667265653A20636F (          xyz.asm):09151                 FCC     "free: corrupt magicA"
     7272757074206D61
     67696341
2C25 00               (          xyz.asm):09152                 FCB     0
     2C26             (          xyz.asm):09153         S00093  EQU     *
2C26 667265653A20636F (          xyz.asm):09154                 FCC     "free: corrupt magicZ"
     7272757074206D61
     6769635A
2C3A 00               (          xyz.asm):09155                 FCB     0
     2C3B             (          xyz.asm):09156         S00094  EQU     *
2C3B 636F727275707420 (          xyz.asm):09157                 FCC     "corrupt free"
     66726565
2C47 00               (          xyz.asm):09158                 FCB     0
     2C48             (          xyz.asm):09159         S00095  EQU     *
2C48 00               (          xyz.asm):09160                 FCB     0
     2C49             (          xyz.asm):09161         S00096  EQU     *
2C49 436F6D6D616E6420 (          xyz.asm):09162                 FCC     "Command '%s' already defined"
     2725732720616C72
     6561647920646566
     696E6564
2C65 00               (          xyz.asm):09163                 FCB     0
     2C66             (          xyz.asm):09164         S00097  EQU     *
2C66 4E6F207375636820 (          xyz.asm):09165                 FCC     "No such variable '%s'"
     7661726961626C65
     2027257327
2C7B 00               (          xyz.asm):09166                 FCB     0
     2C7C             (          xyz.asm):09167         S00098  EQU     *
2C7C 4E6F207375636820 (          xyz.asm):09168                 FCC     "No such command '%s'"
     636F6D6D616E6420
     27257327
2C90 00               (          xyz.asm):09169                 FCB     0
     2C91             (          xyz.asm):09170         S00099  EQU     *
2C91 57726F6E67206E75 (          xyz.asm):09171                 FCC     "Wrong number of args for %s"
     6D626572206F6620
     6172677320666F72
     202573
2CAC 00               (          xyz.asm):09172                 FCB     0
     2CAD             (          xyz.asm):09173         S00100  EQU     *
2CAD 2564             (          xyz.asm):09174                 FCC     "%d"
2CAF 00               (          xyz.asm):09175                 FCB     0
     2CB0             (          xyz.asm):09176         S00101  EQU     *
2CB0 6E6F207375636820 (          xyz.asm):09177                 FCC     "no such var"
     766172
2CBB 00               (          xyz.asm):09178                 FCB     0
     2CBC             (          xyz.asm):09179         S00102  EQU     *
2CBC 0D               (          xyz.asm):09180                 FCB     $0D
2CBD 00               (          xyz.asm):09181                 FCB     0
     2CBE             (          xyz.asm):09182         S00103  EQU     *
2CBE 627265616B       (          xyz.asm):09183                 FCC     "break"
2CC3 00               (          xyz.asm):09184                 FCB     0
     2CC4             (          xyz.asm):09185         S00104  EQU     *
2CC4 636F6E74696E7565 (          xyz.asm):09186                 FCC     "continue"
2CCC 00               (          xyz.asm):09187                 FCB     0
     2CCD             (          xyz.asm):09188         S00105  EQU     *
2CCD 50726F6320272573 (          xyz.asm):09189                 FCC     "Proc '%s' called with wrong arg num"
     272063616C6C6564
     2077697468207772
     6F6E672061726720
     6E756D
2CF0 00               (          xyz.asm):09190                 FCB     0
     2CF1             (          xyz.asm):09191         S00106  EQU     *
2CF1 2070726F63733A20 (          xyz.asm):09192                 FCC     " procs: "
2CF9 00               (          xyz.asm):09193                 FCB     0
     2CFA             (          xyz.asm):09194         S00107  EQU     *
2CFA 20               (          xyz.asm):09195                 FCC     " "
2CFB 00               (          xyz.asm):09196                 FCB     0
     2CFC             (          xyz.asm):09197         S00108  EQU     *
2CFC 206F746865722063 (          xyz.asm):09198                 FCC     " other commands: "
     6F6D6D616E64733A
     20
2D0D 00               (          xyz.asm):09199                 FCB     0
     2D0E             (          xyz.asm):09200         S00109  EQU     *
2D0E 206672616D653A20 (          xyz.asm):09201                 FCC     " frame: "
2D16 00               (          xyz.asm):09202                 FCB     0
     2D17             (          xyz.asm):09203         S00110  EQU     *
2D17 20676C6F62616C73 (          xyz.asm):09204                 FCC     " globals: "
     3A20
2D21 00               (          xyz.asm):09205                 FCB     0
     2D22             (          xyz.asm):09206         S00111  EQU     *
2D22 3D               (          xyz.asm):09207                 FCC     "="
2D23 00               (          xyz.asm):09208                 FCB     0
     2D24             (          xyz.asm):09209         S00112  EQU     *
2D24 25733A204552524F (          xyz.asm):09210                 FCC     "%s: ERROR %d"
     52202564
2D30 00               (          xyz.asm):09211                 FCB     0
     2D31             (          xyz.asm):09212         S00113  EQU     *
2D31 636861696E3A2074 (          xyz.asm):09213                 FCC     "chain: too few args"
     6F6F206665772061
     726773
2D44 00               (          xyz.asm):09214                 FCB     0
     2D45             (          xyz.asm):09215         S00114  EQU     *
2D45 666F726B3A20746F (          xyz.asm):09216                 FCC     "fork: too few args"
     6F20666577206172
     6773
2D57 00               (          xyz.asm):09217                 FCB     0
     2D58             (          xyz.asm):09218         S00115  EQU     *
2D58 2B               (          xyz.asm):09219                 FCC     "+"
2D59 00               (          xyz.asm):09220                 FCB     0
     2D5A             (          xyz.asm):09221         S00116  EQU     *
2D5A 2D               (          xyz.asm):09222                 FCC     "-"
2D5B 00               (          xyz.asm):09223                 FCB     0
     2D5C             (          xyz.asm):09224         S00117  EQU     *
2D5C 2A               (          xyz.asm):09225                 FCC     "*"
2D5D 00               (          xyz.asm):09226                 FCB     0
     2D5E             (          xyz.asm):09227         S00118  EQU     *
2D5E 2F               (          xyz.asm):09228                 FCC     "/"
2D5F 00               (          xyz.asm):09229                 FCB     0
     2D60             (          xyz.asm):09230         S00119  EQU     *
2D60 3E               (          xyz.asm):09231                 FCC     ">"
2D61 00               (          xyz.asm):09232                 FCB     0
     2D62             (          xyz.asm):09233         S00120  EQU     *
2D62 3E3D             (          xyz.asm):09234                 FCC     ">="
2D64 00               (          xyz.asm):09235                 FCB     0
     2D65             (          xyz.asm):09236         S00121  EQU     *
2D65 3C               (          xyz.asm):09237                 FCC     "<"
2D66 00               (          xyz.asm):09238                 FCB     0
     2D67             (          xyz.asm):09239         S00122  EQU     *
2D67 3C3D             (          xyz.asm):09240                 FCC     "<="
2D69 00               (          xyz.asm):09241                 FCB     0
     2D6A             (          xyz.asm):09242         S00123  EQU     *
2D6A 3D3D             (          xyz.asm):09243                 FCC     "=="
2D6C 00               (          xyz.asm):09244                 FCB     0
     2D6D             (          xyz.asm):09245         S00124  EQU     *
2D6D 213D             (          xyz.asm):09246                 FCC     "!="
2D6F 00               (          xyz.asm):09247                 FCB     0
     2D70             (          xyz.asm):09248         S00125  EQU     *
2D70 736574           (          xyz.asm):09249                 FCC     "set"
2D73 00               (          xyz.asm):09250                 FCB     0
     2D74             (          xyz.asm):09251         S00126  EQU     *
2D74 70757473         (          xyz.asm):09252                 FCC     "puts"
2D78 00               (          xyz.asm):09253                 FCB     0
     2D79             (          xyz.asm):09254         S00127  EQU     *
2D79 6966             (          xyz.asm):09255                 FCC     "if"
2D7B 00               (          xyz.asm):09256                 FCB     0
     2D7C             (          xyz.asm):09257         S00128  EQU     *
2D7C 7768696C65       (          xyz.asm):09258                 FCC     "while"
2D81 00               (          xyz.asm):09259                 FCB     0
     2D82             (          xyz.asm):09260         S00129  EQU     *
2D82 70726F63         (          xyz.asm):09261                 FCC     "proc"
2D86 00               (          xyz.asm):09262                 FCB     0
     2D87             (          xyz.asm):09263         S00130  EQU     *
2D87 72657475726E     (          xyz.asm):09264                 FCC     "return"
2D8D 00               (          xyz.asm):09265                 FCB     0
     2D8E             (          xyz.asm):09266         S00131  EQU     *
2D8E 696E666F         (          xyz.asm):09267                 FCC     "info"
2D92 00               (          xyz.asm):09268                 FCB     0
     2D93             (          xyz.asm):09269         S00132  EQU     *
2D93 666F7265616368   (          xyz.asm):09270                 FCC     "foreach"
2D9A 00               (          xyz.asm):09271                 FCB     0
     2D9B             (          xyz.asm):09272         S00133  EQU     *
2D9B 6361746368       (          xyz.asm):09273                 FCC     "catch"
2DA0 00               (          xyz.asm):09274                 FCB     0
     2DA1             (          xyz.asm):09275         S00134  EQU     *
2DA1 6C697374         (          xyz.asm):09276                 FCC     "list"
2DA5 00               (          xyz.asm):09277                 FCB     0
     2DA6             (          xyz.asm):09278         S00135  EQU     *
2DA6 65786974         (          xyz.asm):09279                 FCC     "exit"
2DAA 00               (          xyz.asm):09280                 FCB     0
     2DAB             (          xyz.asm):09281         S00136  EQU     *
2DAB 636861696E       (          xyz.asm):09282                 FCC     "chain"
2DB0 00               (          xyz.asm):09283                 FCB     0
     2DB1             (          xyz.asm):09284         S00137  EQU     *
2DB1 666F726B         (          xyz.asm):09285                 FCC     "fork"
2DB5 00               (          xyz.asm):09286                 FCB     0
     2DB6             (          xyz.asm):09287         S00138  EQU     *
2DB6 77616974         (          xyz.asm):09288                 FCC     "wait"
2DBA 00               (          xyz.asm):09289                 FCB     0
     2DBB             (          xyz.asm):09290         S00139  EQU     *
2DBB 647570           (          xyz.asm):09291                 FCC     "dup"
2DBE 00               (          xyz.asm):09292                 FCB     0
     2DBF             (          xyz.asm):09293         S00140  EQU     *
2DBF 636C6F7365       (          xyz.asm):09294                 FCC     "close"
2DC4 00               (          xyz.asm):09295                 FCB     0
     2DC5             (          xyz.asm):09296         S00141  EQU     *
2DC5 202A616C7068612A (          xyz.asm):09297                 FCC     " *alpha* "
     20
2DCE 00               (          xyz.asm):09298                 FCB     0
     2DCF             (          xyz.asm):09299         S00142  EQU     *
2DCF 202A626574612A20 (          xyz.asm):09300                 FCC     " *beta* "
2DD7 00               (          xyz.asm):09301                 FCB     0
     2DD8             (          xyz.asm):09302         S00143  EQU     *
2DD8 202A67616D6D612A (          xyz.asm):09303                 FCC     " *gamma* "
     20
2DE1 00               (          xyz.asm):09304                 FCB     0
     2DE2             (          xyz.asm):09305         S00144  EQU     *
2DE2 203E7069636F6C3E (          xyz.asm):09306                 FCC     " >picol> "
     20
2DEB 00               (          xyz.asm):09307                 FCB     0
     2DEC             (          xyz.asm):09308         S00145  EQU     *
2DEC 202A454F462A     (          xyz.asm):09309                 FCC     " *EOF*"
2DF2 0D               (          xyz.asm):09310                 FCB     $0D
2DF3 00               (          xyz.asm):09311                 FCB     0
     2DF4             (          xyz.asm):09312         S00146  EQU     *
2DF4 5B25645D203C3C   (          xyz.asm):09313                 FCC     "[%d] <<"
2DFB 00               (          xyz.asm):09314                 FCB     0
     2DFC             (          xyz.asm):09315         S00147  EQU     *
2DFC 3E3E             (          xyz.asm):09316                 FCC     ">>"
2DFE 0D               (          xyz.asm):09317                 FCB     $0D
2DFF 00               (          xyz.asm):09318                 FCB     0
     2E00             (          xyz.asm):09319         string_literals_end     EQU     *
                      (          xyz.asm):09320         
                      (          xyz.asm):09321         
                      (          xyz.asm):09322         *******************************************************************************
                      (          xyz.asm):09323         
                      (          xyz.asm):09324         * READ-ONLY GLOBAL VARIABLES
                      (          xyz.asm):09325         
                      (          xyz.asm):09326         
                      (          xyz.asm):09327         
                      (          xyz.asm):09328         
                      (          xyz.asm):09329         * Multiply D by X, unsigned; return result in D; preserve X.
2E00 3456             (          xyz.asm):09330         MUL16   PSHS    U,X,B,A         U pushed to create 2 temp bytes at 4,S
2E02 E663             (          xyz.asm):09331                 LDB     3,S             low byte of original X
2E04 3D               (          xyz.asm):09332                 MUL
2E05 ED64             (          xyz.asm):09333                 STD     4,S             keep for later
2E07 EC61             (          xyz.asm):09334                 LDD     1,S             low byte of orig D, high byte of orig X
2E09 3D               (          xyz.asm):09335                 MUL
2E0A EB65             (          xyz.asm):09336                 ADDB    5,S             only low byte is needed
2E0C E765             (          xyz.asm):09337                 STB     5,S
2E0E A661             (          xyz.asm):09338                 LDA     1,S             low byte of orig D
2E10 E663             (          xyz.asm):09339                 LDB     3,S             low byte of orig X
2E12 3D               (          xyz.asm):09340                 MUL
2E13 AB65             (          xyz.asm):09341                 ADDA    5,S
2E15 3266             (          xyz.asm):09342                 LEAS    6,S
2E17 39               (          xyz.asm):09343                 RTS
                      (          xyz.asm):09344         
                      (          xyz.asm):09345         
                      (          xyz.asm):09346         * Divide X by D, signed; return quotient in X, remainder in D.
                      (          xyz.asm):09347         * Non-zero remainder is negative iff dividend is negative.
2E18 3416             (          xyz.asm):09348         SDIV16  PSHS    X,B,A
2E1A 6FE2             (          xyz.asm):09349                 CLR     ,-S             counter: number of negative arguments (0..2)
2E1C 6FE2             (          xyz.asm):09350                 CLR     ,-S             boolean: was dividend negative?
2E1E 4D               (          xyz.asm):09351                 TSTA                    is divisor negative?
2E1F 2C09             (          xyz.asm):09352                 BGE     SDIV16_10       if not
2E21 6C61             (          xyz.asm):09353                 INC     1,S
2E23 43               (          xyz.asm):09354                 COMA                    negate divisor
2E24 53               (          xyz.asm):09355                 COMB
2E25 C30001           (          xyz.asm):09356                 ADDD    #1
2E28 ED62             (          xyz.asm):09357                 STD     2,S
2E2A                  (          xyz.asm):09358         SDIV16_10
2E2A EC64             (          xyz.asm):09359                 LDD     4,S             is dividend negative?
2E2C 2C0B             (          xyz.asm):09360                 BGE     SDIV16_20       if not
2E2E 6CE4             (          xyz.asm):09361                 INC     ,S
2E30 6C61             (          xyz.asm):09362                 INC     1,S
2E32 43               (          xyz.asm):09363                 COMA                    negate dividend
2E33 53               (          xyz.asm):09364                 COMB
2E34 C30001           (          xyz.asm):09365                 ADDD    #1
2E37 ED64             (          xyz.asm):09366                 STD     4,S
2E39                  (          xyz.asm):09367         SDIV16_20
2E39 EC62             (          xyz.asm):09368                 LDD     2,S             reload divisor
2E3B AE64             (          xyz.asm):09369                 LDX     4,S             reload dividend
2E3D 170019           (          xyz.asm):09370                 LBSR    DIV16
                      (          xyz.asm):09371         
                      (          xyz.asm):09372         * Counter is 0, 1 or 2. Quotient negative if counter is 1.
2E40 6461             (          xyz.asm):09373                 LSR     1,S             check bit 0 of counter (1 -> negative quotient)
2E42 2409             (          xyz.asm):09374                 BCC     SDIV16_30       quotient not negative
2E44 1E10             (          xyz.asm):09375                 EXG     X,D             put quotient in D and remainder in X
2E46 43               (          xyz.asm):09376                 COMA                    negate quotient
2E47 53               (          xyz.asm):09377                 COMB
2E48 C30001           (          xyz.asm):09378                 ADDD    #1
2E4B 1E10             (          xyz.asm):09379                 EXG     X,D             return quotient and remainder in X and D
                      (          xyz.asm):09380         
2E4D                  (          xyz.asm):09381         SDIV16_30
                      (          xyz.asm):09382         * Negate the remainder if the dividend was negative.
2E4D 6DE4             (          xyz.asm):09383                 TST     ,S              was dividend negative?
2E4F 2705             (          xyz.asm):09384                 BEQ     SDIV16_40       if not
2E51 43               (          xyz.asm):09385                 COMA                    negate remainder
2E52 53               (          xyz.asm):09386                 COMB
2E53 C30001           (          xyz.asm):09387                 ADDD    #1
2E56                  (          xyz.asm):09388         SDIV16_40
2E56 3266             (          xyz.asm):09389                 LEAS    6,S
2E58 39               (          xyz.asm):09390                 RTS
                      (          xyz.asm):09391         
                      (          xyz.asm):09392         * Divide X by D, unsigned; return quotient in X, remainder in D.
2E59 3416             (          xyz.asm):09393         DIV16   PSHS    X,B,A
2E5B C610             (          xyz.asm):09394                 LDB     #16
2E5D 3404             (          xyz.asm):09395                 PSHS    B
2E5F 4F               (          xyz.asm):09396                 CLRA
2E60 5F               (          xyz.asm):09397                 CLRB
2E61 3406             (          xyz.asm):09398                 PSHS    B,A
                      (          xyz.asm):09399         * 0,S=16-bit quotient; 2,S=loop counter;
                      (          xyz.asm):09400         * 3,S=16-bit divisor; 5,S=16-bit dividend
                      (          xyz.asm):09401         
2E63 6866             (          xyz.asm):09402         D16010  LSL     6,S             shift MSB of dividend into carry
2E65 6965             (          xyz.asm):09403                 ROL     5,S             shift carry and MSB of dividend, into carry
2E67 59               (          xyz.asm):09404                 ROLB                    new bit of dividend now in bit 0 of B
2E68 49               (          xyz.asm):09405                 ROLA
2E69 10A363           (          xyz.asm):09406                 CMPD    3,S             does the divisor "fit" into D?
2E6C 2506             (          xyz.asm):09407                 BLO     D16020          if not
2E6E A363             (          xyz.asm):09408                 SUBD    3,S
2E70 1A01             (          xyz.asm):09409                 ORCC    #1              set carry
2E72 2002             (          xyz.asm):09410                 BRA     D16030
2E74 1CFE             (          xyz.asm):09411         D16020  ANDCC   #$FE            reset carry
2E76 6961             (          xyz.asm):09412         D16030  ROL     1,S             shift carry into quotient
2E78 69E4             (          xyz.asm):09413                 ROL     ,S
                      (          xyz.asm):09414         
2E7A 6A62             (          xyz.asm):09415                 DEC     2,S             another bit of the dividend to process?
2E7C 26E5             (          xyz.asm):09416                 BNE     D16010          if yes
                      (          xyz.asm):09417         
2E7E 3510             (          xyz.asm):09418                 PULS    X               quotient to return
2E80 3265             (          xyz.asm):09419                 LEAS    5,S
2E82 39               (          xyz.asm):09420                 RTS
                      (          xyz.asm):09421         
                      (          xyz.asm):09422         * MUL16BY10:  input & output in D.
                      (          xyz.asm):09423         
2E83                  (          xyz.asm):09424         MUL16BY10
2E83 58               (          xyz.asm):09425                 LSLB
2E84 49               (          xyz.asm):09426                 ROLA          ; that's times 2.
2E85 3406             (          xyz.asm):09427                 PSHS D
2E87 58               (          xyz.asm):09428                 LSLB
2E88 49               (          xyz.asm):09429                 ROLA          ; that's times 4.
2E89 58               (          xyz.asm):09430                 LSLB
2E8A 49               (          xyz.asm):09431                 ROLA          ; that's times 8.
2E8B E3E1             (          xyz.asm):09432                 ADDD ,S++      ; 2 + 8 = 10.
2E8D 39               (          xyz.asm):09433                 RTS
                      (          xyz.asm):09434         
                      (          xyz.asm):09435         * Divide D by 10.
                      (          xyz.asm):09436         * Quotient left in D.
                      (          xyz.asm):09437         * Does not preserve X.
                      (          xyz.asm):09438         * Source: Hacker's Delight (Addison-Wesley, 2003, 2012)
                      (          xyz.asm):09439         *         http://www.hackersdelight.org/divcMore.pdf
                      (          xyz.asm):09440         *
2E8E                  (          xyz.asm):09441         DIV16BY10
2E8E 1F01             (          xyz.asm):09442                 TFR     D,X     save n
2E90 44               (          xyz.asm):09443                 LSRA
2E91 56               (          xyz.asm):09444                 RORB            D = n >> 1
2E92 3406             (          xyz.asm):09445                 PSHS    B,A     q := ,S (word)
2E94 44               (          xyz.asm):09446                 LSRA
2E95 56               (          xyz.asm):09447                 RORB            D = n >> 2
2E96 E3E4             (          xyz.asm):09448                 ADDD    ,S
2E98 EDE4             (          xyz.asm):09449                 STD     ,S      q = (n >> 1) + (n >> 2)
2E9A 44               (          xyz.asm):09450                 LSRA
2E9B 56               (          xyz.asm):09451                 RORB
2E9C 44               (          xyz.asm):09452                 LSRA
2E9D 56               (          xyz.asm):09453                 RORB
2E9E 44               (          xyz.asm):09454                 LSRA
2E9F 56               (          xyz.asm):09455                 RORB
2EA0 44               (          xyz.asm):09456                 LSRA
2EA1 56               (          xyz.asm):09457                 RORB
2EA2 E3E4             (          xyz.asm):09458                 ADDD    ,S
2EA4 EDE4             (          xyz.asm):09459                 STD     ,S      D = q + (q >> 4)
2EA6 1F89             (          xyz.asm):09460                 TFR     A,B
2EA8 4F               (          xyz.asm):09461                 CLRA            q >> 8
2EA9 E3E4             (          xyz.asm):09462                 ADDD    ,S
2EAB 44               (          xyz.asm):09463                 LSRA
2EAC 56               (          xyz.asm):09464                 RORB
2EAD 44               (          xyz.asm):09465                 LSRA
2EAE 56               (          xyz.asm):09466                 RORB
2EAF 44               (          xyz.asm):09467                 LSRA
2EB0 56               (          xyz.asm):09468                 RORB            q >> 3
2EB1 EDE4             (          xyz.asm):09469                 STD     ,S
2EB3 58               (          xyz.asm):09470                 LSLB
2EB4 49               (          xyz.asm):09471                 ROLA
2EB5 58               (          xyz.asm):09472                 LSLB
2EB6 49               (          xyz.asm):09473                 ROLA            q << 2
2EB7 E3E4             (          xyz.asm):09474                 ADDD    ,S
2EB9 58               (          xyz.asm):09475                 LSLB
2EBA 49               (          xyz.asm):09476                 ROLA
2EBB 3406             (          xyz.asm):09477                 PSHS    B,A
2EBD 1F10             (          xyz.asm):09478                 TFR     X,D     D = n
2EBF A3E1             (          xyz.asm):09479                 SUBD    ,S++    D = r
2EC1 10830009         (          xyz.asm):09480                 CMPD    #9      r > 9 ?
2EC5 2304             (          xyz.asm):09481                 BLS     DIV16BY10_010
2EC7 C601             (          xyz.asm):09482                 LDB     #1
2EC9 2001             (          xyz.asm):09483                 BRA     DIV16BY10_020
2ECB                  (          xyz.asm):09484         DIV16BY10_010
2ECB 5F               (          xyz.asm):09485                 CLRB
2ECC                  (          xyz.asm):09486         DIV16BY10_020
2ECC A6E4             (          xyz.asm):09487                 LDA     ,S
2ECE EB61             (          xyz.asm):09488                 ADDB    1,S
2ED0 8900             (          xyz.asm):09489                 ADCA    #0
2ED2 3590             (          xyz.asm):09490                 PULS    X,PC    discard q and return D
                      (          xyz.asm):09491         
                      (          xyz.asm):09492         
                      (          xyz.asm):09493         
2ED4 E25D5C           (          xyz.asm):09494             emod
     2ED7             (          xyz.asm):09495         eom equ *
                      (          xyz.asm):09496         
