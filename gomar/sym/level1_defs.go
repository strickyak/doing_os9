// +build level1

// This file was generated by scrape_os9_symbols
package sym

const (
	A_AciaP     = 0xFF68 // A.AciaP
	A_ModP      = 0xFF6C // A.ModP
	A_TermV     = 0xFFC0 // A.TermV
	A_V1        = 0xFFC1 // A.V1
	A_V2        = 0xFFC2 // A.V2
	A_V3        = 0xFFC3 // A.V3
	A_V4        = 0xFFC4 // A.V4
	A_V5        = 0xFFC5 // A.V5
	A_V6        = 0xFFC6 // A.V6
	A_V7        = 0xFFC7 // A.V7
	Bt_Sec      = 0x0000 // Bt.Sec
	Bt_Size     = 0x1080 // Bt.Size
	Bt_Start    = 0xEE00 // Bt.Start
	Bt_Track    = 0x0022 // Bt.Track
	C_BELL      = 0x0007 // C$BELL
	C_BSP       = 0x0008 // C$BSP
	C_Clsall    = 0x0016 // C$Clsall
	C_Clsgr     = 0x0015 // C$Clsgr
	C_COMA      = 0x002C // C$COMA
	C_CR        = 0x000D // C$CR
	C_DEL       = 0x0018 // C$DEL
	C_DELETE    = 0x0010 // C$DELETE
	C_DWN       = 0x001F // C$DWN
	C_EL        = 0x0005 // C$EL
	C_EOF       = 0x001B // C$EOF
	C_FORM      = 0x000C // C$FORM
	C_HOME      = 0x000B // C$HOME
	C_INSERT    = 0x0011 // C$INSERT
	C_INTR      = 0x0003 // C$INTR
	C_LF        = 0x000A // C$LF
	C_LFT       = 0x001D // C$LFT
	C_NULL      = 0x0000 // C$NULL
	C_PAUS      = 0x0017 // C$PAUS
	C_PERD      = 0x002E // C$PERD
	C_PLINE     = 0x0013 // C$PLINE
	C_QUIT      = 0x0005 // C$QUIT
	C_RARR      = 0x0009 // C$RARR
	C_RGT       = 0x001C // C$RGT
	C_RPET      = 0x0001 // C$RPET
	C_RPRT      = 0x0004 // C$RPRT
	C_SHRARR    = 0x0019 // C$SHRARR
	C_SI        = 0x000F // C$SI
	C_SO        = 0x000E // C$SO
	C_SPAC      = 0x0020 // C$SPAC
	C_UP        = 0x001E // C$UP
	C_XOFF      = 0x0013 // C$XOFF
	C_XON       = 0x0011 // C$XON
	COCO_D      = 0x0001 // COCO.D
	D_GSTA      = 0x0009 // D$GSTA
	D_INIT      = 0x0000 // D$INIT
	D_PSTA      = 0x000C // D$PSTA
	D_READ      = 0x0003 // D$READ
	D_TERM      = 0x000F // D$TERM
	D_WRIT      = 0x0006 // D$WRIT
	D_AltIRQ    = 0x006B // D.AltIRQ
	D_AProcQ    = 0x004D // D.AProcQ
	D_Boot      = 0x0083 // D.Boot
	D_BTHI      = 0x0068 // D.BTHI
	D_BTLO      = 0x0066 // D.BTLO
	D_CBStrt    = 0x0071 // D.CBStrt
	D_Clock     = 0x0081 // D.Clock
	D_Clock2    = 0x008A // D.Clock2
	D_CLTb      = 0x0086 // D.CLTb
	D_COCOXT    = 0x0009 // D.COCOXT
	D_CRC       = 0x0089 // D.CRC
	D_Day       = 0x0055 // D.Day
	D_DbgMem    = 0x000A // D.DbgMem
	D_DevTbl    = 0x0060 // D.DevTbl
	D_DMAReq    = 0x006A // D.DMAReq
	D_DskTmr    = 0x006F // D.DskTmr
	D_DWSrvID   = 0x0010 // D.DWSrvID
	D_DWStat    = 0x000E // D.DWStat
	D_DWSubAddr = 0x000C // D.DWSubAddr
	D_FIRQ      = 0x0030 // D.FIRQ
	D_FMBM      = 0x0020 // D.FMBM
	D_Hour      = 0x0056 // D.Hour
	D_Init      = 0x002A // D.Init
	D_IOMH      = 0x005E // D.IOMH
	D_IOML      = 0x005C // D.IOML
	D_IRQ       = 0x0032 // D.IRQ
	D_KbdSta    = 0x006D // D.KbdSta
	D_MDREG     = 0x0088 // D.MDREG
	D_Min       = 0x0057 // D.Min
	D_MLIM      = 0x0024 // D.MLIM
	D_ModDir    = 0x0026 // D.ModDir
	D_Month     = 0x0054 // D.Month
	D_NMI       = 0x0036 // D.NMI
	D_Poll      = 0x003A // D.Poll
	D_PolTbl    = 0x0062 // D.PolTbl
	D_PrcDBT    = 0x0049 // D.PrcDBT
	D_Proc      = 0x004B // D.Proc
	D_PthDBT    = 0x0064 // D.PthDBT
	D_Sec       = 0x0058 // D.Sec
	D_Slice     = 0x0048 // D.Slice
	D_SProcQ    = 0x0051 // D.SProcQ
	D_SvcIRQ    = 0x0038 // D.SvcIRQ
	D_SWI       = 0x0034 // D.SWI
	D_SWI2      = 0x002E // D.SWI2
	D_SWI3      = 0x002C // D.SWI3
	D_SWPage    = 0x0003 // D.SWPage
	D_SysDis    = 0x0046 // D.SysDis
	D_SysIRQ    = 0x003E // D.SysIRQ
	D_SysSvc    = 0x0042 // D.SysSvc
	D_Tick      = 0x0059 // D.Tick
	D_Time      = 0x0053 // D.Time
	D_TSec      = 0x005A // D.TSec
	D_TSlice    = 0x005B // D.TSlice
	D_URtoSs    = 0x0084 // D.URtoSs
	D_UsrDis    = 0x0044 // D.UsrDis
	D_UsrIRQ    = 0x003C // D.UsrIRQ
	D_UsrSvc    = 0x0040 // D.UsrSvc
	D_WDAddr    = 0x0000 // D.WDAddr
	D_WDBtDr    = 0x0002 // D.WDBtDr
	D_WProcQ    = 0x004F // D.WProcQ
	D_XFIRQ     = 0x010F // D.XFIRQ
	D_XIRQ      = 0x010C // D.XIRQ
	D_XNMI      = 0x0109 // D.XNMI
	D_XSWI      = 0x0106 // D.XSWI
	D_XSWI2     = 0x0103 // D.XSWI2
	D_XSWI3     = 0x0100 // D.XSWI3
	D_Year      = 0x0053 // D.Year
	DD_ATT      = 0x000D // DD.ATT
	DD_BIT      = 0x0006 // DD.BIT
	DD_BSZ      = 0x0018 // DD.BSZ
	DD_BT       = 0x0015 // DD.BT
	DD_DAT      = 0x001A // DD.DAT
	DD_DIR      = 0x0008 // DD.DIR
	DD_DSK      = 0x000E // DD.DSK
	DD_FMT      = 0x0010 // DD.FMT
	DD_MAP      = 0x0004 // DD.MAP
	DD_NAM      = 0x001F // DD.NAM
	DD_OPT      = 0x003F // DD.OPT
	DD_OWN      = 0x000B // DD.OWN
	DD_RES      = 0x0013 // DD.RES
	DD_SIZ      = 0x0015 // DD.SIZ
	DD_SPT      = 0x0011 // DD.SPT
	DD_TKS      = 0x0003 // DD.TKS
	DD_TOT      = 0x0000 // DD.TOT
	DIR_        = 0x0080 // DIR.
	DIR_FD      = 0x001D // DIR.FD
	DIR_NM      = 0x0000 // DIR.NM
	DIR_SZ      = 0x0020 // DIR.SZ
	DNS_DTD     = 0x0002 // DNS.DTD
	DNS_FM      = 0x0000 // DNS.FM
	DNS_FM0     = 0x0000 // DNS.FM0
	DNS_MFM     = 0x0001 // DNS.MFM
	DNS_MFM0    = 0x0004 // DNS.MFM0
	DNS_STD     = 0x0000 // DNS.STD
	DT_CDFM     = 0x0005 // DT.CDFM
	DT_NFM      = 0x0004 // DT.NFM
	DT_Pipe     = 0x0002 // DT.Pipe
	DT_RBF      = 0x0001 // DT.RBF
	DT_RFM      = 0x0006 // DT.RFM
	DT_SBF      = 0x0003 // DT.SBF
	DT_SCF      = 0x0000 // DT.SCF
	E_Alias     = 0x00C7 // E$Alias
	E_ArrOvf    = 0x0049 // E$ArrOvf
	E_BadBuf    = 0x00C2 // E$BadBuf
	E_BMCRC     = 0x00E8 // E$BMCRC
	E_BMHP      = 0x00EC // E$BMHP
	E_BMID      = 0x00CD // E$BMID
	E_BMode     = 0x00CB // E$BMode
	E_BNam      = 0x00EB // E$BNam
	E_BPAddr    = 0x00D2 // E$BPAddr
	E_BPNam     = 0x00D7 // E$BPNam
	E_BPNum     = 0x00C9 // E$BPNum
	E_BPrcID    = 0x00E0 // E$BPrcID
	E_BTyp      = 0x00F9 // E$BTyp
	E_BufSiz    = 0x00BF // E$BufSiz
	E_Bug       = 0x00BE // E$Bug
	E_CEF       = 0x00DA // E$CEF
	E_CRC       = 0x00F3 // E$CRC
	E_DeadLk    = 0x00FE // E$DeadLk
	E_DelSP     = 0x00DF // E$DelSP
	E_DevBsy    = 0x00FA // E$DevBsy
	E_DevOvf    = 0x00CC // E$DevOvf
	E_DIDC      = 0x00FB // E$DIDC
	E_DimLrg    = 0x0019 // E$DimLrg
	E_DirFul    = 0x00CE // E$DirFul
	E_DivZer    = 0x002D // E$DivZer
	E_Dn        = 0x00C6 // E$Dn
	E_DNE       = 0x00EE // E$DNE
	E_EndQou    = 0x0029 // E$EndQou
	E_EOF       = 0x00D3 // E$EOF
	E_ExcVrb    = 0x000B // E$ExcVrb
	E_FltOvf    = 0x0032 // E$FltOvf
	E_FNA       = 0x00D6 // E$FNA
	E_Full      = 0x00F8 // E$Full
	E_HangUp    = 0x00DC // E$HangUp
	E_IBA       = 0x00DB // E$IBA
	E_IChRef    = 0x000E // E$IChRef
	E_ICoord    = 0x00BD // E$ICoord
	E_ICOvf     = 0x000D // E$ICOvf
	E_IForkP    = 0x00E6 // E$IForkP
	E_IllA      = 0x0043 // E$IllA
	E_IllArg    = 0x00BB // E$IllArg
	E_IllCmd    = 0x00C0 // E$IllCmd
	E_IllCnt    = 0x0044 // E$IllCnt
	E_IllDec    = 0x0048 // E$IllDec
	E_IllDim    = 0x0015 // E$IllDim
	E_IllExp    = 0x0047 // E$IllExp
	E_IllFOR    = 0x0046 // E$IllFOR
	E_IllInp    = 0x003D // E$IllInp
	E_IllIVr    = 0x004D // E$IllIVr
	E_IllLit    = 0x0016 // E$IllLit
	E_IllMod    = 0x000F // E$IllMod
	E_IllNum    = 0x0010 // E$IllNum
	E_IllOpd    = 0x0012 // E$IllOpd
	E_IllOpr    = 0x0013 // E$IllOpr
	E_IllPNm    = 0x0040 // E$IllPNm
	E_IllPrf    = 0x0011 // E$IllPrf
	E_IllRet    = 0x0017 // E$IllRet
	E_IllRFN    = 0x0014 // E$IllRFN
	E_IllSfx    = 0x0018 // E$IllSfx
	E_IllStC    = 0x000C // E$IllStC
	E_IOConv    = 0x003C // E$IOConv
	E_IOFRpt    = 0x003E // E$IOFRpt
	E_IOFSyn    = 0x003F // E$IOFSyn
	E_IOMism    = 0x003A // E$IOMism
	E_IONum     = 0x003B // E$IONum
	E_IPrcID    = 0x00E0 // E$IPrcID
	E_ISWI      = 0x00E3 // E$ISWI
	E_IWDef     = 0x00C3 // E$IWDef
	E_IWTyp     = 0x00B7 // E$IWTyp
	E_KwnMod    = 0x00E7 // E$KwnMod
	E_LinLrg    = 0x001A // E$LinLrg
	E_LnComp    = 0x0033 // E$LnComp
	E_Lock      = 0x00FC // E$Lock
	E_MemFul    = 0x00CF // E$MemFul
	E_MFull     = 0x0020 // E$MFull
	E_MltLin    = 0x004B // E$MltLin
	E_MltVar    = 0x004C // E$MltVar
	E_MNF       = 0x00DD // E$MNF
	E_ModBsy    = 0x00D1 // E$ModBsy
	E_MulPrc    = 0x002C // E$MulPrc
	E_NEMod     = 0x00EA // E$NEMod
	E_NES       = 0x00D5 // E$NES
	E_NFont     = 0x00B9 // E$NFont
	E_NoAssg    = 0x001B // E$NoAssg
	E_NoChld    = 0x00E2 // E$NoChld
	E_NoComa    = 0x001D // E$NoComa
	E_NoData    = 0x004F // E$NoData
	E_NoDim     = 0x001E // E$NoDim
	E_NoDO      = 0x001F // E$NoDO
	E_NoGoto    = 0x0021 // E$NoGoto
	E_NoLPar    = 0x0022 // E$NoLPar
	E_NoLRef    = 0x0023 // E$NoLRef
	E_NonRcO    = 0x0042 // E$NonRcO
	E_NoOprd    = 0x0024 // E$NoOprd
	E_NoPath    = 0x001C // E$NoPath
	E_NoRAM     = 0x00ED // E$NoRAM
	E_NoRout    = 0x0030 // E$NoRout
	E_NoRPar    = 0x0025 // E$NoRPar
	E_NoTask    = 0x00EF // E$NoTask
	E_NoTHEN    = 0x0026 // E$NoTHEN
	E_NoTO      = 0x0027 // E$NoTO
	E_NotRdy    = 0x00F6 // E$NotRdy
	E_NoVRef    = 0x0028 // E$NoVRef
	E_ParmEr    = 0x0038 // E$ParmEr
	E_PNNF      = 0x00D8 // E$PNNF
	E_Poll      = 0x00CA // E$Poll
	E_PrcAbt    = 0x00E4 // E$PrcAbt
	E_PrcFul    = 0x00E5 // E$PrcFul
	E_PthFul    = 0x00C8 // E$PthFul
	E_Read      = 0x00F4 // E$Read
	E_Sect      = 0x00F1 // E$Sect
	E_Seek      = 0x00F7 // E$Seek
	E_SeekRg    = 0x004E // E$SeekRg
	E_Share     = 0x00FD // E$Share
	E_SLF       = 0x00D9 // E$SLF
	E_StkOvf    = 0x00BA // E$StkOvf
	E_StrOvf    = 0x002F // E$StrOvf
	E_SubLrg    = 0x002A // E$SubLrg
	E_SubOvf    = 0x0035 // E$SubOvf
	E_SubRng    = 0x0037 // E$SubRng
	E_SubUnd    = 0x0036 // E$SubUnd
	E_SysOvf    = 0x0039 // E$SysOvf
	E_TblFul    = 0x00C1 // E$TblFul
	E_TypMis    = 0x002E // E$TypMis
	E_UndLin    = 0x004A // E$UndLin
	E_UndVar    = 0x0031 // E$UndVar
	E_Unit      = 0x00F0 // E$Unit
	E_UnkPrc    = 0x002B // E$UnkPrc
	E_UnkSvc    = 0x00D0 // E$UnkSvc
	E_UnkSym    = 0x000A // E$UnkSym
	E_UnmCnt    = 0x0045 // E$UnmCnt
	E_Up        = 0x00C5 // E$Up
	E_USigP     = 0x00E9 // E$USigP
	E_ValRng    = 0x0034 // E$ValRng
	E_WADef     = 0x00B8 // E$WADef
	E_WP        = 0x00F2 // E$WP
	E_Write     = 0x00F5 // E$Write
	E_WrSub     = 0x0041 // E$WrSub
	E_WUndef    = 0x00C4 // E$WUndef
	EXEC_       = 0x0004 // EXEC.
	F_All64     = 0x0030 // F$All64
	F_AllBit    = 0x0013 // F$AllBit
	F_AProc     = 0x002C // F$AProc
	F_Chain     = 0x0005 // F$Chain
	F_CmpNam    = 0x0011 // F$CmpNam
	F_CRC       = 0x0017 // F$CRC
	F_Debug     = 0x0023 // F$Debug
	F_DelBit    = 0x0014 // F$DelBit
	F_Exit      = 0x0006 // F$Exit
	F_Find64    = 0x002F // F$Find64
	F_Fork      = 0x0003 // F$Fork
	F_Icpt      = 0x0009 // F$Icpt
	F_ID        = 0x000C // F$ID
	F_IODel     = 0x0033 // F$IODel
	F_IOQu      = 0x002B // F$IOQu
	F_IRQ       = 0x002A // F$IRQ
	F_Link      = 0x0000 // F$Link
	F_Load      = 0x0001 // F$Load
	F_Mem       = 0x0007 // F$Mem
	F_NProc     = 0x002D // F$NProc
	F_PErr      = 0x000F // F$PErr
	F_PrsNam    = 0x0010 // F$PrsNam
	F_Ret64     = 0x0031 // F$Ret64
	F_SchBit    = 0x0012 // F$SchBit
	F_Send      = 0x0008 // F$Send
	F_Sleep     = 0x000A // F$Sleep
	F_SPrior    = 0x000D // F$SPrior
	F_SRqMem    = 0x0028 // F$SRqMem
	F_SRtMem    = 0x0029 // F$SRtMem
	F_SSpd      = 0x000B // F$SSpd
	F_SSvc      = 0x0032 // F$SSvc
	F_SSWI      = 0x000E // F$SSWI
	F_STime     = 0x0016 // F$STime
	F_Time      = 0x0015 // F$Time
	F_UnLink    = 0x0002 // F$UnLink
	F_VIRQ      = 0x0027 // F$VIRQ
	F_VModul    = 0x002E // F$VModul
	F_Wait      = 0x0004 // F$Wait
	FD_ATT      = 0x0000 // FD.ATT
	FD_Creat    = 0x000D // FD.Creat
	FD_DAT      = 0x0003 // FD.DAT
	FD_LNK      = 0x0008 // FD.LNK
	FD_LS1      = 0x00FB // FD.LS1
	FD_LS2      = 0x00FA // FD.LS2
	FD_OWN      = 0x0001 // FD.OWN
	FD_SEG      = 0x0010 // FD.SEG
	FD_SIZ      = 0x0009 // FD.SIZ
	FDSL_A      = 0x0000 // FDSL.A
	FDSL_B      = 0x0003 // FDSL.B
	FDSL_S      = 0x0005 // FDSL.S
	FMT_DNS     = 0x0002 // FMT.DNS
	FMT_SIDE    = 0x0001 // FMT.SIDE
	FMT_T0DN    = 0x0020 // FMT.T0DN
	FMT_TDNS    = 0x0004 // FMT.TDNS
	HW_Page     = 0x00FF // HW.Page
	I_Attach    = 0x0080 // I$Attach
	I_ChgDir    = 0x0086 // I$ChgDir
	I_Close     = 0x008F // I$Close
	I_Create    = 0x0083 // I$Create
	I_Delete    = 0x0087 // I$Delete
	I_DeletX    = 0x0090 // I$DeletX
	I_Detach    = 0x0081 // I$Detach
	I_Dup       = 0x0082 // I$Dup
	I_GetStt    = 0x008D // I$GetStt
	I_MakDir    = 0x0085 // I$MakDir
	I_Open      = 0x0084 // I$Open
	I_Read      = 0x0089 // I$Read
	I_ReadLn    = 0x008B // I$ReadLn
	I_Seek      = 0x0088 // I$Seek
	I_SetStt    = 0x008E // I$SetStt
	I_Write     = 0x008A // I$Write
	I_WritLn    = 0x008C // I$WritLn
	ISIZ_       = 0x0020 // ISIZ.
	IT_ALF      = 0x0017 // IT.ALF
	IT_BAU      = 0x0027 // IT.BAU
	IT_BSE      = 0x0024 // IT.BSE
	IT_BSO      = 0x0014 // IT.BSO
	IT_BSP      = 0x001B // IT.BSP
	IT_COL      = 0x002C // IT.COL
	IT_CYL      = 0x0017 // IT.CYL
	IT_D2P      = 0x0028 // IT.D2P
	IT_DEL      = 0x001C // IT.DEL
	IT_DLO      = 0x0015 // IT.DLO
	IT_DNS      = 0x0016 // IT.DNS
	IT_DRV      = 0x0013 // IT.DRV
	IT_DTP      = 0x0012 // IT.DTP
	IT_DUP      = 0x0020 // IT.DUP
	IT_DVC      = 0x0012 // IT.DVC
	IT_EKO      = 0x0016 // IT.EKO
	IT_EOF      = 0x001E // IT.EOF
	IT_EOR      = 0x001D // IT.EOR
	IT_Exten    = 0x0022 // IT.Exten
	IT_ILV      = 0x001F // IT.ILV
	IT_INT      = 0x0022 // IT.INT
	IT_LLDRV    = 0x0028 // IT.LLDRV
	IT_MPI      = 0x002A // IT.MPI
	IT_NUL      = 0x0018 // IT.NUL
	IT_OFS      = 0x0026 // IT.OFS
	IT_OVF      = 0x0025 // IT.OVF
	IT_PAG      = 0x001A // IT.PAG
	IT_PAR      = 0x0026 // IT.PAR
	IT_PAU      = 0x0019 // IT.PAU
	IT_PSC      = 0x0021 // IT.PSC
	IT_QUT      = 0x0023 // IT.QUT
	IT_ROW      = 0x002D // IT.ROW
	IT_RPR      = 0x001F // IT.RPR
	IT_RWC      = 0x0028 // IT.RWC
	IT_SAS      = 0x0020 // IT.SAS
	IT_SCT      = 0x001B // IT.SCT
	IT_SID      = 0x0019 // IT.SID
	IT_SOFF1    = 0x0025 // IT.SOFF1
	IT_SOFF2    = 0x0026 // IT.SOFF2
	IT_SOFF3    = 0x0027 // IT.SOFF3
	IT_SToff    = 0x0024 // IT.SToff
	IT_STP      = 0x0014 // IT.STP
	IT_T0S      = 0x001D // IT.T0S
	IT_TFM      = 0x0021 // IT.TFM
	IT_TYP      = 0x0015 // IT.TYP
	IT_UPC      = 0x0013 // IT.UPC
	IT_VFY      = 0x001A // IT.VFY
	IT_WPC      = 0x0025 // IT.WPC
	IT_XOFF     = 0x002B // IT.XOFF
	IT_XON      = 0x002A // IT.XON
	IT_XTYP     = 0x002E // IT.XTYP
	M_DTyp      = 0x0012 // M$DTyp
	M_Exec      = 0x0009 // M$Exec
	M_FMgr      = 0x0009 // M$FMgr
	M_ID        = 0x0000 // M$ID
	M_ID1       = 0x0087 // M$ID1
	M_ID12      = 0x87CD // M$ID12
	M_ID2       = 0x00CD // M$ID2
	M_IDSize    = 0x0009 // M$IDSize
	M_Mem       = 0x000B // M$Mem
	M_Mode      = 0x000D // M$Mode
	M_Name      = 0x0004 // M$Name
	M_Opt       = 0x0011 // M$Opt
	M_Parity    = 0x0008 // M$Parity
	M_PDev      = 0x000B // M$PDev
	M_Port      = 0x000E // M$Port
	M_Revs      = 0x0007 // M$Revs
	M_Size      = 0x0002 // M$Size
	M_Type      = 0x0006 // M$Type
	MD_ESize    = 0x0004 // MD$ESize
	MD_Link     = 0x0002 // MD$Link
	MD_MPtr     = 0x0000 // MD$MPtr
	MPI_Slct    = 0xFF7F // MPI.Slct
	MPI_Slot    = 0x0003 // MPI.Slot
	P_ADDR      = 0x0007 // P$ADDR
	P_Age       = 0x000C // P$Age
	P_CHAP      = 0x0006 // P$CHAP
	P_CID       = 0x0003 // P$CID
	P_DIO       = 0x001A // P$DIO
	P_ID        = 0x0000 // P$ID
	P_IOQN      = 0x0011 // P$IOQN
	P_IOQP      = 0x0010 // P$IOQP
	P_NIO       = 0x003B // P$NIO
	P_PagCnt    = 0x0008 // P$PagCnt
	P_PATH      = 0x0026 // P$PATH
	P_PID       = 0x0001 // P$PID
	P_PModul    = 0x0012 // P$PModul
	P_Prior     = 0x000B // P$Prior
	P_Queue     = 0x000E // P$Queue
	P_SID       = 0x0002 // P$SID
	P_SigDat    = 0x0039 // P$SigDat
	P_Signal    = 0x0036 // P$Signal
	P_SigVec    = 0x0037 // P$SigVec
	P_Size      = 0x0040 // P$Size
	P_SP        = 0x0004 // P$SP
	P_State     = 0x000D // P$State
	P_SWI       = 0x0014 // P$SWI
	P_SWI2      = 0x0016 // P$SWI2
	P_SWI3      = 0x0018 // P$SWI3
	P_User      = 0x0009 // P$User
	PD_ALF      = 0x0025 // PD.ALF
	PD_ATT      = 0x0033 // PD.ATT
	PD_BAU      = 0x0035 // PD.BAU
	PD_BSE      = 0x0032 // PD.BSE
	PD_BSO      = 0x0022 // PD.BSO
	PD_BSP      = 0x0029 // PD.BSP
	PD_BUF      = 0x0008 // PD.BUF
	PD_CNT      = 0x0002 // PD.CNT
	PD_CP       = 0x000B // PD.CP
	PD_CPR      = 0x0005 // PD.CPR
	PD_CYL      = 0x0025 // PD.CYL
	PD_D2P      = 0x0036 // PD.D2P
	PD_DCP      = 0x003A // PD.DCP
	PD_DEL      = 0x002A // PD.DEL
	PD_DEV      = 0x0003 // PD.DEV
	PD_DFD      = 0x0037 // PD.DFD
	PD_DLO      = 0x0023 // PD.DLO
	PD_DNS      = 0x0024 // PD.DNS
	PD_DRV      = 0x0021 // PD.DRV
	PD_DSK      = 0x001C // PD.DSK
	PD_DTB      = 0x001E // PD.DTB
	PD_DTP      = 0x0020 // PD.DTP
	PD_DUP      = 0x002E // PD.DUP
	PD_DV2      = 0x000A // PD.DV2
	PD_DVT      = 0x003E // PD.DVT
	PD_EKO      = 0x0024 // PD.EKO
	PD_EOF      = 0x002C // PD.EOF
	PD_EOR      = 0x002B // PD.EOR
	PD_ERR      = 0x003A // PD.ERR
	PD_Exten    = 0x0030 // PD.Exten
	PD_FD       = 0x0034 // PD.FD
	PD_FST      = 0x000A // PD.FST
	PD_ILV      = 0x002D // PD.ILV
	PD_INT      = 0x0030 // PD.INT
	PD_MAX      = 0x000D // PD.MAX
	PD_MIN      = 0x000F // PD.MIN
	PD_MOD      = 0x0001 // PD.MOD
	PD_NUL      = 0x0026 // PD.NUL
	PD_OPT      = 0x0020 // PD.OPT
	PD_OVF      = 0x0033 // PD.OVF
	PD_PAG      = 0x0028 // PD.PAG
	PD_PAR      = 0x0034 // PD.PAR
	PD_PAU      = 0x0027 // PD.PAU
	PD_PD       = 0x0000 // PD.PD
	PD_PLP      = 0x003D // PD.PLP
	PD_PSC      = 0x002F // PD.PSC
	PD_PST      = 0x003F // PD.PST
	PD_QUT      = 0x0031 // PD.QUT
	PD_RAW      = 0x000C // PD.RAW
	PD_RGS      = 0x0006 // PD.RGS
	PD_RPR      = 0x002D // PD.RPR
	PD_SAS      = 0x002E // PD.SAS
	PD_SBL      = 0x0013 // PD.SBL
	PD_SBP      = 0x0016 // PD.SBP
	PD_SCT      = 0x0029 // PD.SCT
	PD_SID      = 0x0027 // PD.SID
	PD_SIZ      = 0x000F // PD.SIZ
	PD_SMF      = 0x000A // PD.SMF
	PD_SSZ      = 0x0019 // PD.SSZ
	PD_STM      = 0x0012 // PD.STM
	PD_SToff    = 0x0032 // PD.SToff
	PD_STP      = 0x0022 // PD.STP
	PD_STS      = 0x0010 // PD.STS
	PD_T0S      = 0x002B // PD.T0S
	PD_TBL      = 0x003B // PD.TBL
	PD_TFM      = 0x002F // PD.TFM
	PD_TYP      = 0x0023 // PD.TYP
	PD_UPC      = 0x0021 // PD.UPC
	PD_VFY      = 0x0028 // PD.VFY
	PD_XOFF     = 0x0039 // PD.XOFF
	PD_XON      = 0x0038 // PD.XON
	PEXEC_      = 0x0020 // PEXEC.
	PREAD_      = 0x0008 // PREAD.
	PST_DCD     = 0x0001 // PST.DCD
	PWRIT_      = 0x0010 // PWRIT.
	Q_FLIP      = 0x0002 // Q$FLIP
	Q_MASK      = 0x0003 // Q$MASK
	Q_POLL      = 0x0000 // Q$POLL
	Q_PRTY      = 0x0008 // Q$PRTY
	Q_SERV      = 0x0004 // Q$SERV
	Q_STAT      = 0x0006 // Q$STAT
	R_A         = 0x0001 // R$A
	R_B         = 0x0002 // R$B
	R_CC        = 0x0000 // R$CC
	R_D         = 0x0001 // R$D
	R_DP        = 0x0003 // R$DP
	R_PC        = 0x000A // R$PC
	R_Size      = 0x000C // R$Size
	R_U         = 0x0008 // R$U
	R_X         = 0x0004 // R$X
	R_Y         = 0x0006 // R$Y
	RBF_D       = 0x0001 // RBF.D
	READ_       = 0x0001 // READ.
	S_Abort     = 0x0002 // S$Abort
	S_Alarm     = 0x0005 // S$Alarm
	S_HUP       = 0x0004 // S$HUP
	S_Intrpt    = 0x0003 // S$Intrpt
	S_Kill      = 0x0000 // S$Kill
	S_Wake      = 0x0001 // S$Wake
	S_Window    = 0x0004 // S$Window
	SCF_D       = 0x0001 // SCF.D
	SHARE_      = 0x0040 // SHARE.
	SS_AAGBf    = 0x0080 // SS.AAGBf
	SS_AlfaS    = 0x001C // SS.AlfaS
	SS_AnPal    = 0x009A // SS.AnPal
	SS_AScrn    = 0x008B // SS.AScrn
	SS_Attr     = 0x001C // SS.Attr
	SS_BlkRd    = 0x0014 // SS.BlkRd
	SS_BlkWr    = 0x0015 // SS.BlkWr
	SS_Break    = 0x001D // SS.Break
	SS_CDRel    = 0x009B // SS.CDRel
	SS_CDSig    = 0x009A // SS.CDSig
	SS_CDSta    = 0x0099 // SS.CDSta
	SS_Close    = 0x002A // SS.Close
	SS_ComSt    = 0x0028 // SS.ComSt
	SS_Cursr    = 0x0025 // SS.Cursr
	SS_DCmd     = 0x000D // SS.DCmd
	SS_DevNm    = 0x000E // SS.DevNm
	SS_DfPal    = 0x0097 // SS.DfPal
	SS_DirEnt   = 0x0020 // SS.DirEnt
	SS_DScrn    = 0x008C // SS.DScrn
	SS_DSize    = 0x0026 // SS.DSize
	SS_DStat    = 0x0012 // SS.DStat
	SS_ECC      = 0x00B0 // SS.ECC
	SS_ELog     = 0x0019 // SS.ELog
	SS_EOF      = 0x0006 // SS.EOF
	SS_FBRgs    = 0x0096 // SS.FBRgs
	SS_FD       = 0x000F // SS.FD
	SS_FDInf    = 0x0020 // SS.FDInf
	SS_Feed     = 0x0009 // SS.Feed
	SS_Fill     = 0x00A0 // SS.Fill
	SS_FndBf    = 0x009B // SS.FndBf
	SS_Frz      = 0x000A // SS.Frz
	SS_FScrn    = 0x008D // SS.FScrn
	SS_FSig     = 0x002C // SS.FSig
	SS_GIP      = 0x0094 // SS.GIP
	SS_GIP2     = 0x0099 // SS.GIP2
	SS_Hist     = 0x00A1 // SS.Hist
	SS_HngUp    = 0x002B // SS.HngUp
	SS_Joy      = 0x0013 // SS.Joy
	SS_KySns    = 0x0027 // SS.KySns
	SS_Link     = 0x0007 // SS.Link
	SS_Lock     = 0x0011 // SS.Lock
	SS_MnSel    = 0x0087 // SS.MnSel
	SS_Montr    = 0x0092 // SS.Montr
	SS_Mount    = 0x0082 // SS.Mount
	SS_Mouse    = 0x0089 // SS.Mouse
	SS_MpGPB    = 0x0084 // SS.MpGPB
	SS_MsSig    = 0x008A // SS.MsSig
	SS_Open     = 0x0029 // SS.Open
	SS_Opt      = 0x0000 // SS.Opt
	SS_Palet    = 0x0091 // SS.Palet
	SS_Pos      = 0x0005 // SS.Pos
	SS_PScrn    = 0x008E // SS.PScrn
	SS_RdNet    = 0x0083 // SS.RdNet
	SS_Ready    = 0x0001 // SS.Ready
	SS_Relea    = 0x001B // SS.Relea
	SS_Reset    = 0x0003 // SS.Reset
	SS_Reten    = 0x0016 // SS.Reten
	SS_RFM      = 0x0018 // SS.RFM
	SS_RsBit    = 0x001E // SS.RsBit
	SS_SBar     = 0x0088 // SS.SBar
	SS_ScInf    = 0x008F // SS.ScInf
	SS_ScSiz    = 0x0026 // SS.ScSiz
	SS_ScTyp    = 0x0093 // SS.ScTyp
	SS_SetMF    = 0x0024 // SS.SetMF
	SS_Size     = 0x0002 // SS.Size
	SS_SLGBf    = 0x0081 // SS.SLGBf
	SS_Slots    = 0x0085 // SS.Slots
	SS_SPT      = 0x000B // SS.SPT
	SS_SQD      = 0x000C // SS.SQD
	SS_SSig     = 0x001A // SS.SSig
	SS_Ticks    = 0x0010 // SS.Ticks
	SS_Tone     = 0x0098 // SS.Tone
	SS_ULink    = 0x0008 // SS.ULink
	SS_UMBar    = 0x0095 // SS.UMBar
	SS_VarSect  = 0x0012 // SS.VarSect
	SS_WFM      = 0x0017 // SS.WFM
	SS_WnSet    = 0x0086 // SS.WnSet
	SS_WTrk     = 0x0004 // SS.WTrk
	STP_12ms    = 0x0002 // STP.12ms
	STP_20ms    = 0x0001 // STP.20ms
	STP_30ms    = 0x0000 // STP.30ms
	STP_6ms     = 0x0003 // STP.6ms
	TYP_256     = 0x0000 // TYP.256
	TYP_3       = 0x0001 // TYP.3
	TYP_5       = 0x0000 // TYP.5
	TYP_512     = 0x0004 // TYP.512
	TYP_CCF     = 0x0020 // TYP.CCF
	TYP_FLP     = 0x0000 // TYP.FLP
	TYP_HARD    = 0x0080 // TYP.HARD
	TYP_NCCF    = 0x0000 // TYP.NCCF
	TYP_NSF     = 0x0040 // TYP.NSF
	TYP_SBO     = 0x0002 // TYP.SBO
	TYP_SOF     = 0x0000 // TYP.SOF
	TYPH_1024   = 0x0002 // TYPH.1024
	TYPH_2048   = 0x0003 // TYPH.2048
	TYPH_256    = 0x0000 // TYPH.256
	TYPH_512    = 0x0001 // TYPH.512
	TYPH_DRSV   = 0x000C // TYPH.DRSV
	TYPH_DSQ    = 0x0010 // TYPH.DSQ
	TYPH_SSM    = 0x0003 // TYPH.SSM
	UPDAT_      = 0x0003 // UPDAT.
	V_DESC      = 0x0004 // V$DESC
	V_DRIV      = 0x0000 // V$DRIV
	V_FMGR      = 0x0006 // V$FMGR
	V_STAT      = 0x0002 // V$STAT
	V_USRS      = 0x0008 // V$USRS
	V_BMapSz    = 0x001C // V.BMapSz
	V_BMB       = 0x0017 // V.BMB
	V_BUSY      = 0x0004 // V.BUSY
	V_DEV2      = 0x0009 // V.DEV2
	V_DiskID    = 0x001A // V.DiskID
	V_ERR       = 0x000E // V.ERR
	V_FileHd    = 0x0018 // V.FileHd
	V_INTR      = 0x000B // V.INTR
	V_KANJI     = 0x0011 // V.KANJI
	V_KBUF      = 0x0012 // V.KBUF
	V_LINE      = 0x0007 // V.LINE
	V_LPRC      = 0x0003 // V.LPRC
	V_MapSct    = 0x001D // V.MapSct
	V_MODADR    = 0x0014 // V.MODADR
	V_NDRV      = 0x0006 // V.NDRV
	V_PAGE      = 0x0000 // V.PAGE
	V_PAUS      = 0x0008 // V.PAUS
	V_PCHR      = 0x000D // V.PCHR
	V_PDLHd     = 0x0016 // V.PDLHd
	V_PORT      = 0x0001 // V.PORT
	V_QUIT      = 0x000C // V.QUIT
	V_ResBit    = 0x001E // V.ResBit
	V_RSV       = 0x0018 // V.RSV
	V_SCF       = 0x001D // V.SCF
	V_ScOfst    = 0x0020 // V.ScOfst
	V_ScTkOf    = 0x001F // V.ScTkOf
	V_TkOfst    = 0x0021 // V.TkOfst
	V_TRAK      = 0x0015 // V.TRAK
	V_TYPE      = 0x0006 // V.TYPE
	V_USER      = 0x0006 // V.USER
	V_WAKE      = 0x0005 // V.WAKE
	V_XOFF      = 0x0010 // V.XOFF
	V_XON       = 0x000F // V.XON
	VD_OFS      = 0x0061 // VD.OFS
	VD_STP      = 0x0060 // VD.STP
	Vi_Cnt      = 0x0000 // Vi.Cnt
	Vi_IFlag    = 0x0001 // Vi.IFlag
	Vi_PkSz     = 0x0005 // Vi.PkSz
	Vi_Rst      = 0x0002 // Vi.Rst
	Vi_Stat     = 0x0004 // Vi.Stat
	WRITE_      = 0x0002 // WRITE.
	XX_Size     = 0x0006 // XX.Size
)

var SysCallNames = map[byte]string{
	F_AProc:  "F$AProc",
	F_All64:  "F$All64",
	F_AllBit: "F$AllBit",
	F_CRC:    "F$CRC",
	F_Chain:  "F$Chain",
	F_CmpNam: "F$CmpNam",
	F_Debug:  "F$Debug",
	F_DelBit: "F$DelBit",
	F_Exit:   "F$Exit",
	F_Find64: "F$Find64",
	F_Fork:   "F$Fork",
	F_ID:     "F$ID",
	F_IODel:  "F$IODel",
	F_IOQu:   "F$IOQu",
	F_IRQ:    "F$IRQ",
	F_Icpt:   "F$Icpt",
	F_Link:   "F$Link",
	F_Load:   "F$Load",
	F_Mem:    "F$Mem",
	F_NProc:  "F$NProc",
	F_PErr:   "F$PErr",
	F_PrsNam: "F$PrsNam",
	F_Ret64:  "F$Ret64",
	F_SPrior: "F$SPrior",
	F_SRqMem: "F$SRqMem",
	F_SRtMem: "F$SRtMem",
	F_SSWI:   "F$SSWI",
	F_SSpd:   "F$SSpd",
	F_SSvc:   "F$SSvc",
	F_STime:  "F$STime",
	F_SchBit: "F$SchBit",
	F_Send:   "F$Send",
	F_Sleep:  "F$Sleep",
	F_Time:   "F$Time",
	F_UnLink: "F$UnLink",
	F_VIRQ:   "F$VIRQ",
	F_VModul: "F$VModul",
	F_Wait:   "F$Wait",
	I_Attach: "I$Attach",
	I_ChgDir: "I$ChgDir",
	I_Close:  "I$Close",
	I_Create: "I$Create",
	I_DeletX: "I$DeletX",
	I_Delete: "I$Delete",
	I_Detach: "I$Detach",
	I_Dup:    "I$Dup",
	I_GetStt: "I$GetStt",
	I_MakDir: "I$MakDir",
	I_Open:   "I$Open",
	I_Read:   "I$Read",
	I_ReadLn: "I$ReadLn",
	I_Seek:   "I$Seek",
	I_SetStt: "I$SetStt",
	I_WritLn: "I$WritLn",
	I_Write:  "I$Write",
}

type Slot struct {
	off    uint
	symbol string
}

var Slots_D = []Slot{
	{0x0000, "WDAddr"},
	{0x0002, "WDBtDr"},
	{0x0003, "SWPage"},
	{0x0009, "COCOXT"},
	{0x000a, "DbgMem"},
	{0x000c, "DWSubAddr"},
	{0x000e, "DWStat"},
	{0x0010, "DWSrvID"},
	{0x0020, "FMBM"},
	{0x0024, "MLIM"},
	{0x0026, "ModDir"},
	{0x002a, "Init"},
	{0x002c, "SWI3"},
	{0x002e, "SWI2"},
	{0x0030, "FIRQ"},
	{0x0032, "IRQ"},
	{0x0034, "SWI"},
	{0x0036, "NMI"},
	{0x0038, "SvcIRQ"},
	{0x003a, "Poll"},
	{0x003c, "UsrIRQ"},
	{0x003e, "SysIRQ"},
	{0x0040, "UsrSvc"},
	{0x0042, "SysSvc"},
	{0x0044, "UsrDis"},
	{0x0046, "SysDis"},
	{0x0048, "Slice"},
	{0x0049, "PrcDBT"},
	{0x004b, "Proc"},
	{0x004d, "AProcQ"},
	{0x004f, "WProcQ"},
	{0x0051, "SProcQ"},
	{0x0053, "Year"},
	{0x0054, "Month"},
	{0x0055, "Day"},
	{0x0056, "Hour"},
	{0x0057, "Min"},
	{0x0058, "Sec"},
	{0x0059, "Tick"},
	{0x005a, "TSec"},
	{0x005b, "TSlice"},
	{0x005c, "IOML"},
	{0x005e, "IOMH"},
	{0x0060, "DevTbl"},
	{0x0062, "PolTbl"},
	{0x0064, "PthDBT"},
	{0x0066, "BTLO"},
	{0x0068, "BTHI"},
	{0x006a, "DMAReq"},
	{0x006b, "AltIRQ"},
	{0x006d, "KbdSta"},
	{0x006f, "DskTmr"},
	{0x0071, "CBStrt"},
	{0x0081, "Clock"},
	{0x0083, "Boot"},
	{0x0084, "URtoSs"},
	{0x0086, "CLTb"},
	{0x0088, "MDREG"},
	{0x0089, "CRC"},
	{0x008a, "Clock2"},
	{0x0100, "XSWI3"},
	{0x0103, "XSWI2"},
	{0x0106, "XSWI"},
	{0x0109, "XNMI"},
	{0x010c, "XIRQ"},
	{0x010f, "XFIRQ"},
}
var Slots_P = []Slot{
	{0x0000, "ID"},
	{0x0001, "PID"},
	{0x0002, "SID"},
	{0x0003, "CID"},
	{0x0004, "SP"},
	{0x0006, "CHAP"},
	{0x0007, "ADDR"},
	{0x0008, "PagCnt"},
	{0x0009, "User"},
	{0x000b, "Prior"},
	{0x000c, "Age"},
	{0x000d, "State"},
	{0x000e, "Queue"},
	{0x0010, "IOQP"},
	{0x0011, "IOQN"},
	{0x0012, "PModul"},
	{0x0014, "SWI"},
	{0x0016, "SWI2"},
	{0x0018, "SWI3"},
	{0x001a, "DIO"},
	{0x0026, "PATH"},
	{0x0036, "Signal"},
	{0x0037, "SigVec"},
	{0x0039, "SigDat"},
	{0x003b, "NIO"},
	{0x0040, "Size"},
}
var Slots_PD = []Slot{
	{0x0000, "PD"},
	{0x0001, "MOD"},
	{0x0002, "CNT"},
	{0x0003, "DEV"},
	{0x0005, "CPR"},
	{0x0006, "RGS"},
	{0x0008, "BUF"},
	{0x000a, "SMF"},
	{0x000b, "CP"},
	{0x000c, "RAW"},
	{0x000d, "MAX"},
	{0x000f, "SIZ"},
	{0x0010, "STS"},
	{0x0012, "STM"},
	{0x0013, "SBL"},
	{0x0016, "SBP"},
	{0x0019, "SSZ"},
	{0x001c, "DSK"},
	{0x001e, "DTB"},
	{0x0020, "OPT"},
	{0x0021, "UPC"},
	{0x0022, "STP"},
	{0x0023, "TYP"},
	{0x0024, "EKO"},
	{0x0025, "CYL"},
	{0x0026, "NUL"},
	{0x0027, "SID"},
	{0x0028, "VFY"},
	{0x0029, "SCT"},
	{0x002a, "DEL"},
	{0x002b, "T0S"},
	{0x002c, "EOF"},
	{0x002d, "RPR"},
	{0x002e, "SAS"},
	{0x002f, "TFM"},
	{0x0030, "INT"},
	{0x0031, "QUT"},
	{0x0032, "SToff"},
	{0x0033, "OVF"},
	{0x0034, "PAR"},
	{0x0035, "BAU"},
	{0x0036, "D2P"},
	{0x0037, "DFD"},
	{0x0038, "XON"},
	{0x0039, "XOFF"},
	{0x003a, "ERR"},
	{0x003b, "TBL"},
	{0x003d, "PLP"},
	{0x003e, "DVT"},
	{0x003f, "PST"},
}
var Os9Error = map[byte]string{
	E_Alias:  "E$Alias",
	E_ArrOvf: "E$ArrOvf",
	E_BMCRC:  "E$BMCRC",
	E_BMHP:   "E$BMHP",
	E_BMID:   "E$BMID",
	E_BMode:  "E$BMode",
	E_BNam:   "E$BNam",
	E_BPAddr: "E$BPAddr",
	E_BPNam:  "E$BPNam",
	E_BPNum:  "E$BPNum",
	E_BPrcID: "E$BPrcID",
	E_BTyp:   "E$BTyp",
	E_BadBuf: "E$BadBuf",
	E_BufSiz: "E$BufSiz",
	E_Bug:    "E$Bug",
	E_CEF:    "E$CEF",
	E_CRC:    "E$CRC",
	E_DIDC:   "E$DIDC",
	E_DNE:    "E$DNE",
	E_DeadLk: "E$DeadLk",
	E_DelSP:  "E$DelSP",
	E_DevBsy: "E$DevBsy",
	E_DevOvf: "E$DevOvf",
	E_DimLrg: "E$DimLrg",
	E_DirFul: "E$DirFul",
	E_DivZer: "E$DivZer",
	E_Dn:     "E$Dn",
	E_EOF:    "E$EOF",
	E_EndQou: "E$EndQou",
	E_ExcVrb: "E$ExcVrb",
	E_FNA:    "E$FNA",
	E_FltOvf: "E$FltOvf",
	E_Full:   "E$Full",
	E_HangUp: "E$HangUp",
	E_IBA:    "E$IBA",
	E_ICOvf:  "E$ICOvf",
	E_IChRef: "E$IChRef",
	E_ICoord: "E$ICoord",
	E_IForkP: "E$IForkP",
	E_IOConv: "E$IOConv",
	E_IOFRpt: "E$IOFRpt",
	E_IOFSyn: "E$IOFSyn",
	E_IOMism: "E$IOMism",
	E_IONum:  "E$IONum",
	E_ISWI:   "E$ISWI",
	E_IWDef:  "E$IWDef",
	E_IWTyp:  "E$IWTyp",
	E_IllA:   "E$IllA",
	E_IllArg: "E$IllArg",
	E_IllCmd: "E$IllCmd",
	E_IllCnt: "E$IllCnt",
	E_IllDec: "E$IllDec",
	E_IllDim: "E$IllDim",
	E_IllExp: "E$IllExp",
	E_IllFOR: "E$IllFOR",
	E_IllIVr: "E$IllIVr",
	E_IllInp: "E$IllInp",
	E_IllLit: "E$IllLit",
	E_IllMod: "E$IllMod",
	E_IllNum: "E$IllNum",
	E_IllOpd: "E$IllOpd",
	E_IllOpr: "E$IllOpr",
	E_IllPNm: "E$IllPNm",
	E_IllPrf: "E$IllPrf",
	E_IllRFN: "E$IllRFN",
	E_IllRet: "E$IllRet",
	E_IllSfx: "E$IllSfx",
	E_IllStC: "E$IllStC",
	E_KwnMod: "E$KwnMod",
	E_LinLrg: "E$LinLrg",
	E_LnComp: "E$LnComp",
	E_Lock:   "E$Lock",
	E_MFull:  "E$MFull",
	E_MNF:    "E$MNF",
	E_MemFul: "E$MemFul",
	E_MltLin: "E$MltLin",
	E_MltVar: "E$MltVar",
	E_ModBsy: "E$ModBsy",
	E_MulPrc: "E$MulPrc",
	E_NEMod:  "E$NEMod",
	E_NES:    "E$NES",
	E_NFont:  "E$NFont",
	E_NoAssg: "E$NoAssg",
	E_NoChld: "E$NoChld",
	E_NoComa: "E$NoComa",
	E_NoDO:   "E$NoDO",
	E_NoData: "E$NoData",
	E_NoDim:  "E$NoDim",
	E_NoGoto: "E$NoGoto",
	E_NoLPar: "E$NoLPar",
	E_NoLRef: "E$NoLRef",
	E_NoOprd: "E$NoOprd",
	E_NoPath: "E$NoPath",
	E_NoRAM:  "E$NoRAM",
	E_NoRPar: "E$NoRPar",
	E_NoRout: "E$NoRout",
	E_NoTHEN: "E$NoTHEN",
	E_NoTO:   "E$NoTO",
	E_NoTask: "E$NoTask",
	E_NoVRef: "E$NoVRef",
	E_NonRcO: "E$NonRcO",
	E_NotRdy: "E$NotRdy",
	E_PNNF:   "E$PNNF",
	E_ParmEr: "E$ParmEr",
	E_Poll:   "E$Poll",
	E_PrcAbt: "E$PrcAbt",
	E_PrcFul: "E$PrcFul",
	E_PthFul: "E$PthFul",
	E_Read:   "E$Read",
	E_SLF:    "E$SLF",
	E_Sect:   "E$Sect",
	E_Seek:   "E$Seek",
	E_SeekRg: "E$SeekRg",
	E_Share:  "E$Share",
	E_StkOvf: "E$StkOvf",
	E_StrOvf: "E$StrOvf",
	E_SubLrg: "E$SubLrg",
	E_SubOvf: "E$SubOvf",
	E_SubRng: "E$SubRng",
	E_SubUnd: "E$SubUnd",
	E_SysOvf: "E$SysOvf",
	E_TblFul: "E$TblFul",
	E_TypMis: "E$TypMis",
	E_USigP:  "E$USigP",
	E_UndLin: "E$UndLin",
	E_UndVar: "E$UndVar",
	E_Unit:   "E$Unit",
	E_UnkPrc: "E$UnkPrc",
	E_UnkSvc: "E$UnkSvc",
	E_UnkSym: "E$UnkSym",
	E_UnmCnt: "E$UnmCnt",
	E_Up:     "E$Up",
	E_ValRng: "E$ValRng",
	E_WADef:  "E$WADef",
	E_WP:     "E$WP",
	E_WUndef: "E$WUndef",
	E_WrSub:  "E$WrSub",
	E_Write:  "E$Write",
}
var Os9ErrorName = map[byte]string{
	183: "Illegal window type",
	184: "Window already defined",
	185: "Font Not found",
	186: "Stack Overflow",
	187: "Illegal Argument",
	188: "unused",
	189: "Illegal Coordinates",
	190: "Internal Integrity check",
	191: "Buffer size is too small",
	192: "Illegal Command",
	193: "Screen or Window Table is Full",
	194: "Bad/Undefined buffer number",
	195: "Illegal window definition",
	196: "Window undefined",
	197: "unused",
	198: "unused",
	199: "unused",
	200: "Path Table Full",
	201: "Illegal Path Number",
	202: "Interrupt Polling Table Full",
	203: "Illegal Mode",
	204: "Device Table Full",
	205: "Illegal Module Header",
	206: "Module Directory Full",
	207: "Memory Full",
	208: "Illegal Service Request",
	209: "Module Busy",
	210: "Boundary Error",
	211: "End of File",
	212: "Returning non-allocated memory",
	213: "Non-existing Segment",
	214: "No Permission",
	215: "Bad Path Name",
	216: "Path Name Not Found",
	217: "Segment List Full",
	218: "File Already Exists",
	219: "Illegal Block Address",
	220: "Phone Hangup-Data Carrier Detect lost",
	221: "Module Not Found",
	223: "Suicide Attempt",
	224: "Illegal Process Number",
	226: "No Children",
	227: "Illegal SWI Code",
	228: "Process Aborted",
	229: "Process Table Full",
	230: "Illegal Parameter Area",
	231: "Known module",
	232: "Incorrect Module CRC",
	233: "Signal Error",
	234: "Non-existent Module",
	235: "Bad Name",
	236: "Bad Module Header",
	237: "RAM Full",
	238: "Unknown Process ID",
	239: "No task number available",
	240: "Unit Error",
	241: "Sector Error",
	242: "Write Protect",
	243: "CRC Error",
	244: "Read Error",
	245: "Write Error",
	246: "Not Ready",
	247: "Seek Error",
	248: "Media Full",
	249: "Wrong Type",
	250: "Device Busy",
	251: "Disk ID Change",
	252: "Record is locked-out",
	253: "Non-sharable file busy",
	254: "I/O Deadlock Error",
	1:   "Unconditional Abort",
	2:   "Keyboard Abort",
	3:   "Keyboard Interrupt",
	10:  "Unrecognized Symbol",
	11:  "Excessive Verbage",
	12:  "Illegal Statement Construction",
	13:  "I-code Overflow",
	14:  "Illegal Channel Reference",
	15:  "Illegal Mode (read/write/update)",
	16:  "Illegal Number",
	17:  "Illegal Prefix",
	18:  "Illegal Operand",
	19:  "Illegal Operator",
	20:  "Illegal Record Field Name",
	21:  "Illegal Dimension",
	22:  "Illegal Literal",
	23:  "Illegal Relational",
	24:  "Illegal Type Suffix",
	25:  "Too-large Dimension",
	26:  "Too-large Line Number",
	27:  "Missing Assignment Statement",
	28:  "Missing Path Number",
	29:  "Missing Comma",
	30:  "Missing Dimension",
	31:  "Missing DO Statement",
	32:  "Memory Full",
	33:  "Missing GOTO",
	34:  "Missing Left Parenthesis",
	35:  "Missing Line Reference",
	36:  "Missing Operand",
	37:  "Missing Right Parenthesis",
	38:  "Missing THEN statement",
	39:  "Missing TO",
	40:  "Missing Variable Reference",
	41:  "No Ending Quote",
	42:  "Too Many Subscripts",
	43:  "Unknown Procedure",
	44:  "Multiply-defined Procedure",
	45:  "Divide by Zero",
	46:  "Operand Type Mismatch",
	47:  "String Stack Overflow",
	48:  "Unimplemented Routine",
	49:  "Undefined Variable",
	50:  "Floating Overflow",
	51:  "Line with Compiler Error",
	52:  "Value out of Range for Destination",
	53:  "Subroutine Stack Overflow",
	54:  "Subroutine Stack Underflow",
	55:  "Subscript out of Range",
	56:  "Parameter Error",
	57:  "System Stack Overflow",
	58:  "I/O Type Mismatch",
	59:  "I/O Numeric Input Format Bad",
	60:  "I/O Conversion: Number out of Range",
	61:  "Illegal Input Format",
	62:  "I/O Format Repeat Error",
	63:  "I/O Format Syntax Error",
	64:  "Illegal Path Number",
	65:  "Wrong Number of Subscripts",
	66:  "Non-record-type Operand",
	67:  "Illegal Argument",
	68:  "Illegal Control Structure",
	69:  "Unmatched Control Structure",
	70:  "Illegal FOR Variable",
	71:  "Illegal Expression Type",
	72:  "Illegal Declarative Statement",
	73:  "Array Size Overflow",
	74:  "Undefined Line Number",
	75:  "Multiply-defined Line Number",
	76:  "Multiply-defined Variable",
	77:  "Illegal Input Variable",
	78:  "Seek Out of Range",
	79:  "Missing Data Statement",
}
