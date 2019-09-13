/* 6809 Simulator "GOMAR".

   License: GNU General Public License version 2, see LICENSE for more details.

   Converted to GO LANG by Henry Strickland, 2019,
   based on code with the following copyleft:

   ============================================================================

   created 1994 by L.C. Benschop.
   copyleft (c) 1994-2014 by the sbc09 team, see AUTHORS for more details.
   license: GNU General Public License version 2, see LICENSE for more details.

   This program simulates a 6809 processor.

   System dependencies: short must be 16 bits.
                        char  must be 8 bits.
                        long must be more than 16 bits.
                        arrays up to 65536 bytes must be supported.
                        machine must be twos complement.
   Most Unix machines will work. For MSODS you need long pointers
   and you may have to malloc() the mem array of 65536 bytes.

   Define CPU_BIG_ENDIAN with != 0 if you have a big-endian machine (680x0 etc)
   Usually UNIX systems get this automatically from BIG_ENDIAN and BYTE_ORDER
   definitions ...

   Define TRACE if you want an instruction trace on stderr.
   Define TERM_CONTROL if you want nonblocking non-echoing key input.
   * THIS IS DIRTY !!! *

   Special instructions:
   SWI2 writes char to stdout from register B.
   SWI3 reads char from stdout to register B, sets carry at EOF.
               (or when no key available when using term control).
   SWI retains its normal function.
   CWAI and SYNC stop simulator.

   The program reads a binary image file at $100 and runs it from there.
   The file name must be given on the command line.

   Revisions:
        2012-06-05 johann AT klasek at
                Fixed: com with C "NOT" operator ... 0^(value) did not work!
        2012-06-06
                Fixed: changes from 1994 release (flag handling)
                        reestablished.
        2012-07-15 JK
                New: option parsing, new option -d (dump memory on exit)
        2013-10-07 JK
                New: print ccreg with flag name in lower/upper case depending on flag state.
        2013-10-20 JK
                New: Show instruction disassembling in trace mode.
        2014-07-01 JK
                Fixed: disassembling output: cmpd
        2014-07-11 JK
                Fixed: undocumented tfr/exg register combinations.
                        http://www.6809.org.uk/dragon/illegal-opcodes.shtml

        2016-02-06 Henry Strickland <strickyak>
                Because OS/9 uses SWI2 for kernel calls, allow other SWIs for I/O.
                -i={0,1,2,3} Input char on {none, SWI, SWI2, or SWI3}.
                -o={0,1,2,3} Output char on {none, SWI, SWI2, or SWI3}
                -0  Initialize mem to 00.
                -F  Initialize mem to FF.
                -t  Enable trace.  (Still requires -DTRACE).
                And more.
*/

package emu

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"log"
	"os"
)

const paranoid = true // Do paranoid checks.

var F = fmt.Sprintf
var L = log.Printf
var Z = fmt.Fprintf

type word uint16

// EA is Effective Address, which may be a word or a special value for a register.
type EA uint32

// 16 bit (0x08 bit clear)
const DRegEA EA = 0x10000000
const XRegEA EA = 0x10000001
const YRegEA EA = 0x10000002
const URegEA EA = 0x10000003
const SRegEA EA = 0x10000004
const PCRegEA EA = 0x10000005

// 8 bit (0x08 bit set)
const ARegEA EA = 0x10000008
const BRegEA EA = 0x10000009
const CCRegEA EA = 0x1000000A
const DPRegEA EA = 0x1000000B

func TfrReg(b byte) EA {
	if 6 == b || b == 7 || b > 11 {
		log.Panicf("Bad TfrReg byte: 0x%x", b)
	}
	return DRegEA + EA(b)
}

var fdump int
var steps int64
var TraceMem bool

/* 6809 registers */
var ccreg, dpreg byte
var xreg, yreg, ureg, sreg, pcreg word
var dreg word

var iflag byte /* flag to indicate prebyte $10 or $11 */
var ireg byte  /* Instruction register */
var pcreg_prev word

var mem [16 * 65536]byte

var ixregs = []*word{&xreg, &yreg, &ureg, &sreg}

var idx byte

/* disassembled instruction buffer */
var dinst bytes.Buffer

/* disassembled operand buffer */
var dops bytes.Buffer

/* disassembled instruction len (optional, on demand) */
var da_len word

/* instruction cycles */
var cycles int
var cycles_sum int64

var Waiting bool
var irqs_pending byte

var Instrtable []func()

var Level int

func GetAReg() byte  { return Hi(dreg) }
func GetBReg() byte  { return Lo(dreg) }
func PutAReg(x byte) { dreg = HiLo(x, Lo(dreg)) }
func PutBReg(x byte) { dreg = HiLo(Hi(dreg), x) }

//////////////////////////////////////////////////////////////

const NMI_PENDING = CC_ENTIRE /* borrow this bit */
const IRQ_PENDING = CC_INHIBIT_IRQ
const FIRQ_PENDING = CC_INHIBIT_FIRQ

//? const fillreg = 0xff
//? const wfillreg = 0xffff

const IRQ_FREQ = (10 * 1000)

const CC_INHIBIT_IRQ = 0x10
const CC_INHIBIT_FIRQ = 0x40
const CC_ENTIRE = 0x80

const VECTOR_IRQ = 0xFFF8
const VECTOR_FIRQ = 0xFFF6
const VECTOR_NMI = 0xFFFC

func Hi(a word) byte {
	return byte(255 & (a >> 8))
}
func Lo(a word) byte {
	return byte(255 & a)
}
func HiLo(hi, lo byte) word {
	return (word(hi) << 8) | word(lo)
}

func Signed(a byte) word {
	if (a & 0x80) != 0 {
		return 0xFF80 | word(a)
	} else {
		return word(a)
	}
}

func AddressInDeviceSpace(addr word) bool {
	return (addr&0xFF00) == 0xFF00 && (addr&0xFFF0) != 0xFFF0
}

const MmuDefaultStartPage = 0x00
const MmuDefaultStartAddr = (MmuDefaultStartPage << 13)

var MmuEnable bool
var MmuTask byte
var MmuMap [2][8]byte

func init() {
	for task := 0; task < 2; task++ {
		for slot := 0; slot < 8; slot++ {
			MmuMap[task][slot] = byte(MmuDefaultStartPage + slot)
		}
	}
}

func MapAddr(logical word) int {
	if MmuEnable {
		slot := byte(logical >> 13)
		low := int(logical & 0x1FFF)
		physicalPage := MmuMap[MmuTask][slot]
		z := (int(physicalPage) << 13) | low
		if TraceMem {
			L("\t\t\t\t\t\t MapAddr: %04x -> %06x ... task=%x  slot=%x  page=%x", logical, z, MmuTask, slot, physicalPage)
		}
		return z
	} else {
		z := MmuDefaultStartAddr + int(logical) // TODO -- use pages starting at 0x30?
		if TraceMem {
			L("\t\t\t\t\t\t MapAddr: %04x -> %06x ... default map", logical, z)
		}
		return z
	}
}

// B is fundamental func to get byte.  Hack register access into here.
func B(addr word) byte {
	var z byte
	mapped := MapAddr(addr)
	if AddressInDeviceSpace(addr) {
		z = GetIOByte(addr)
		L("HEY, GetIO (%06x) %04x -> %02x : %c %c", mapped, addr, z, H(z), T(z))
		mem[mapped] = z
	} else {
		z = mem[mapped]
	}
	if TraceMem {
		L("\t\t\t\tGetB (%06x) %04x -> %02x : %c %c", mapped, addr, z, H(z), T(z))
	}
	return z
}

func PeekB(addr word) byte {
	var z byte
	mapped := MapAddr(addr)
	z = mem[mapped]
	return z
}

// PutB is fundamental func to set byte.  Hack register access into here.
func PutB(addr word, x byte) {
	mapped := MapAddr(addr)
	old := mem[mapped]
	mem[mapped] = x
	if TraceMem {
		L("\t\t\t\tPutB (%06x) %04x <- %02x (was %02x)", mapped, addr, x, old)
	}
	if AddressInDeviceSpace(addr) {
		PutIOByte(addr, x)
		L("HEY, PutIO (%06x) %04x <- %02x (was %02x)", mapped, addr, x, old)
	}
}

// W is fundamental func to get word.
func W(addr word) word {
	hi := B(addr)
	lo := B(addr + 1)
	return HiLo(hi, lo)
}

func PeekW(addr word) word {
	hi := PeekB(addr)
	lo := PeekB(addr + 1)
	return HiLo(hi, lo)
}

// PutW is fundamental func to set word.
func PutW(addr, x word) {
	PutB(addr, Hi(x))
	PutB(addr+1, Lo(x))
}

func (addr EA) GetB() byte {
	if (addr & 0xFFFF0000) != 0 {
		switch addr {
		case ARegEA:
			return GetAReg()
		case BRegEA:
			return GetBReg()
		case CCRegEA:
			return ccreg
		case DPRegEA:
			return dpreg
		default:
			log.Panicf("bad B_ea EA: 0x%x", addr)
			return 0
		}
	} else {
		return B(word(addr))
	}
}

func (addr EA) PutB(x byte) {
	if (addr & 0xFFFF0000) != 0 {
		switch addr {
		case ARegEA:
			PutAReg(x)
		case BRegEA:
			PutBReg(x)
		case CCRegEA:
			ccreg = x
		case DPRegEA:
			dpreg = x
		default:
			log.Panicf("bad PutB_ea EA: 0x%x", addr)
		}
	} else {
		PutB(word(addr), x)
	}
}

func (addr EA) RegPtrW() *word {
	switch addr {
	case DRegEA:
		return &dreg
	case XRegEA:
		return &xreg
	case YRegEA:
		return &yreg
	case URegEA:
		return &ureg
	case SRegEA:
		return &sreg
	case PCRegEA:
		return &pcreg
	default:
		log.Panicf("Unknown RegPtr EA: 0x%x", addr)
		return nil
	}
}

func (addr EA) GetW() word {
	if (addr & 0xFFFF0000) != 0 {
		p := addr.RegPtrW()
		return *p
	} else {
		return W(word(addr))
	}
}

func (addr EA) PutW(x word) {
	if (addr & 0xFFFF0000) != 0 {
		p := addr.RegPtrW()
		*p = x
	} else {
		PutW(word(addr), x)
	}
}

func ImmByte() byte {
	z := B(pcreg)
	pcreg++
	return z
}
func ImmWord() word {
	hi := ImmByte()
	lo := ImmByte()
	return HiLo(hi, lo)
}

/* sreg */
func PushByte(b byte) {
	sreg--
	PutB(sreg, b)
}
func PushWord(w word) {
	PushByte(Lo(w))
	PushByte(Hi(w))
}
func PullByte(bp *byte) {
	*bp = B(sreg)
	sreg++
}
func PullWord(wp *word) {
	var hi, lo byte
	PullByte(&hi)
	PullByte(&lo)
	*wp = HiLo(hi, lo)
}

/* ureg */
func PushUByte(b byte) {
	ureg--
	PutB(ureg, b)
}
func PushUWord(w word) {
	PushUByte(Lo(w))
	PushUByte(Hi(w))
}
func PullUByte(bp *byte) {
	*bp = B(ureg)
	ureg++
}
func PullUWord(wp *word) {
	var hi, lo byte
	PullUByte(&hi)
	PullUByte(&lo)
	*wp = HiLo(hi, lo)
}

func DecodeOs9Error(b byte) string {
	s := "???"
	switch b {
	case 0x0A:
		s = "E$UnkSym :Unknown symbol"
		break
	case 0x0B:
		s = "E$ExcVrb :Excessive verbage"
		break
	case 0x0C:
		s = "E$IllStC :Illegal statement construction"
		break
	case 0x0D:
		s = "E$ICOvf  :I-code overflow"
		break
	case 0x0E:
		s = "E$IChRef :Illegal channel reference"
		break
	case 0x0F:
		s = "E$IllMod :Illegal mode"
		break
	case 0x10:
		s = "E$IllNum :Illegal number"
		break
	case 0x11:
		s = "E$IllPrf :Illegal prefix"
		break
	case 0x12:
		s = "E$IllOpd :Illegal operand"
		break
	case 0x13:
		s = "E$IllOpr :Illegal operator"
		break
	case 0x14:
		s = "E$IllRFN :Illegal record field name"
		break
	case 0x15:
		s = "E$IllDim :Illegal dimension"
		break
	case 0x16:
		s = "E$IllLit :Illegal literal"
		break
	case 0x17:
		s = "E$IllRet :Illegal relational"
		break
	case 0x18:
		s = "E$IllSfx :Illegal type suffix"
		break
	case 0x19:
		s = "E$DimLrg :Dimension too large"
		break
	case 0x1A:
		s = "E$LinLrg :Line number too large"
		break
	case 0x1B:
		s = "E$NoAssg :Missing assignment statement"
		break
	case 0x1C:
		s = "E$NoPath :Missing path number"
		break
	case 0x1D:
		s = "E$NoComa :Missing coma"
		break
	case 0x1E:
		s = "E$NoDim  :Missing dimension"
		break
	case 0x1F:
		s = "E$NoDO   :Missing DO statement"
		break
	case 0x20:
		s = "E$MFull  :Memory full"
		break
	case 0x21:
		s = "E$NoGoto :Missing GOTO"
		break
	case 0x22:
		s = "E$NoLPar :Missing left parenthesis"
		break
	case 0x23:
		s = "E$NoLRef :Missing line reference"
		break
	case 0x24:
		s = "E$NoOprd :Missing operand"
		break
	case 0x25:
		s = "E$NoRPar :Missing right parenthesis"
		break
	case 0x26:
		s = "E$NoTHEN :Missing THEN statement"
		break
	case 0x27:
		s = "E$NoTO   :Missing TO statement"
		break
	case 0x28:
		s = "E$NoVRef :Missing variable reference"
		break
	case 0x29:
		s = "E$EndQou :Missing end quote"
		break
	case 0x2A:
		s = "E$SubLrg :Too many subscripts"
		break
	case 0x2B:
		s = "E$UnkPrc :Unknown procedure"
		break
	case 0x2C:
		s = "E$MulPrc :Multiply defined procedure"
		break
	case 0x2D:
		s = "E$DivZer :Divice by zero"
		break
	case 0x2E:
		s = "E$TypMis :Operand type mismatch"
		break
	case 0x2F:
		s = "E$StrOvf :String stack overflow"
		break
	case 0x30:
		s = "E$NoRout :Unimplemented routine"
		break
	case 0x31:
		s = "E$UndVar :Undefined variable"
		break
	case 0x32:
		s = "E$FltOvf :Floating Overflow"
		break
	case 0x33:
		s = "E$LnComp :Line with compiler error"
		break
	case 0x34:
		s = "E$ValRng :Value out of range for destination"
		break
	case 0x35:
		s = "E$SubOvf :Subroutine stack overflow"
		break
	case 0x36:
		s = "E$SubUnd :Subroutine stack underflow"
		break
	case 0x37:
		s = "E$SubRng :Subscript out of range"
		break
	case 0x38:
		s = "E$ParmEr :Paraemter error"
		break
	case 0x39:
		s = "E$SysOvf :System stack overflow"
		break
	case 0x3A:
		s = "E$IOMism :I/O type mismatch"
		break
	case 0x3B:
		s = "E$IONum  :I/O numeric input format bad"
		break
	case 0x3C:
		s = "E$IOConv :I/O conversion: number out of range"
		break
	case 0x3D:
		s = "E$IllInp :Illegal input format"
		break
	case 0x3E:
		s = "E$IOFRpt :I/O format repeat error"
		break
	case 0x3F:
		s = "E$IOFSyn :I/O format syntax error"
		break
	case 0x40:
		s = "E$IllPNm :Illegal path number"
		break
	case 0x41:
		s = "E$WrSub  :Wrong number of subscripts"
		break
	case 0x42:
		s = "E$NonRcO :Non-record type operand"
		break
	case 0x43:
		s = "E$IllA   :Illegal argument"
		break
	case 0x44:
		s = "E$IllCnt :Illegal control structure"
		break
	case 0x45:
		s = "E$UnmCnt :Unmatched control structure"
		break
	case 0x46:
		s = "E$IllFOR :Illegal FOR variable"
		break
	case 0x47:
		s = "E$IllExp :Illegal expression type"
		break
	case 0x48:
		s = "E$IllDec :Illegal declarative statement"
		break
	case 0x49:
		s = "E$ArrOvf :Array size overflow"
		break
	case 0x4A:
		s = "E$UndLin :Undefined line number"
		break
	case 0x4B:
		s = "E$MltLin :Multiply defined line number"
		break
	case 0x4C:
		s = "E$MltVar :Multiply defined variable"
		break
	case 0x4D:
		s = "E$IllIVr :Illegal input variable"
		break
	case 0x4E:
		s = "E$SeekRg :Seek out of range"
		break
	case 0x4F:
		s = "E$NoData :Missing data statement"
		break
	case 0xB7:
		s = "E$IWTyp  :Illegal window type"
		break
	case 0xB8:
		s = "E$WADef  :Window already defined"
		break
	case 0xB9:
		s = "E$NFont  :Font not found"
		break
	case 0xBA:
		s = "E$StkOvf :Stack overflow"
		break
	case 0xBB:
		s = "E$IllArg :Illegal argument"
		break
	case 0xBD:
		s = "E$ICoord :Illegal coordinates"
		break
	case 0xBE:
		s = "E$Bug    :Bug (should never be returned)"
		break
	case 0xBF:
		s = "E$BufSiz :Buffer size is too small"
		break
	case 0xC0:
		s = "E$IllCmd :Illegal command"
		break
	case 0xC1:
		s = "E$TblFul :Screen or window table is full"
		break
	case 0xC2:
		s = "E$BadBuf :Bad/Undefined buffer number"
		break
	case 0xC3:
		s = "E$IWDef  :Illegal window definition"
		break
	case 0xC4:
		s = "E$WUndef :Window undefined"
		break
	case 0xC5:
		s = "E$Up     :Up arrow pressed on SCF I$ReadLn with PD.UP enabled"
		break
	case 0xC6:
		s = "E$Dn     :Down arrow pressed on SCF I$ReadLn with PD.DOWN enabled"
		break
	case 0xC8:
		s = "E$PthFul :Path Table full"
		break
	case 0xC9:
		s = "E$BPNum  :Bad Path Number"
		break
	case 0xCA:
		s = "E$Poll   :Polling Table Full"
		break
	case 0xCB:
		s = "E$BMode  :Bad Mode"
		break
	case 0xCC:
		s = "E$DevOvf :Device Table Overflow"
		break
	case 0xCD:
		s = "E$BMID   :Bad Module ID"
		break
	case 0xCE:
		s = "E$DirFul :Module Directory Full"
		break
	case 0xCF:
		s = "E$MemFul :Process Memory Full"
		break
	case 0xD0:
		s = "E$UnkSvc :Unknown Service Code"
		break
	case 0xD1:
		s = "E$ModBsy :Module Busy"
		break
	case 0xD2:
		s = "E$BPAddr :Bad Page Address"
		break
	case 0xD3:
		s = "E$EOF    :End of File"
		break
	case 0xD5:
		s = "E$NES    :Non-Existing Segment"
		break
	case 0xD6:
		s = "E$FNA    :File Not Accesible"
		break
	case 0xD7:
		s = "E$BPNam  :Bad Path Name"
		break
	case 0xD8:
		s = "E$PNNF   :Path Name Not Found"
		break
	case 0xD9:
		s = "E$SLF    :Segment List Full"
		break
	case 0xDA:
		s = "E$CEF    :Creating Existing File"
		break
	case 0xDB:
		s = "E$IBA    :Illegal Block Address"
		break
	case 0xDC:
		s = "E$HangUp :Carrier Detect Lost"
		break
	case 0xDD:
		s = "E$MNF    :Module Not Found"
		break
	case 0xDF:
		s = "E$DelSP  :Deleting Stack Pointer memory"
		break
	case 0xE0:
		s = "E$IPrcID :Illegal Process ID"
		break
	case 0xE2:
		s = "E$NoChld :No Children"
		break
	case 0xE3:
		s = "E$ISWI   :Illegal SWI code"
		break
	case 0xE4:
		s = "E$PrcAbt :Process Aborted"
		break
	case 0xE5:
		s = "E$PrcFul :Process Table Full"
		break
	case 0xE6:
		s = "E$IForkP :Illegal Fork Parameter"
		break
	case 0xE7:
		s = "E$KwnMod :Known Module"
		break
	case 0xE8:
		s = "E$BMCRC  :Bad Module CRC"
		break
	case 0xE9:
		s = "E$USigP  :Unprocessed Signal Pending"
		break
	case 0xEA:
		s = "E$NEMod  :Non Existing Module"
		break
	case 0xEB:
		s = "E$BNam   :Bad Name"
		break
	case 0xEC:
		s = "E$BMHP   :(bad module header parity)"
		break
	case 0xED:
		s = "E$NoRAM  :No (System) RAM Available"
		break
	case 0xEE:
		s = "E$DNE    :Directory not empty"
		break
	case 0xEF:
		s = "E$NoTask :No available Task number"
		break
	case 0xF0:
		s = "E$Unit   :Illegal Unit (drive)"
		break
	case 0xF1:
		s = "E$Sect   :Bad Sector number"
		break
	case 0xF2:
		s = "E$WP     :Write Protect"
		break
	case 0xF3:
		s = "E$CRC    :Bad Check Sum"
		break
	case 0xF4:
		s = "E$Read   :Read Error"
		break
	case 0xF5:
		s = "E$Write  :Write Error"
		break
	case 0xF6:
		s = "E$NotRdy :Device Not Ready"
		break
	case 0xF7:
		s = "E$Seek   :Seek Error"
		break
	case 0xF8:
		s = "E$Full   :Media Full"
		break
	case 0xF9:
		s = "E$BTyp   :Bad Type (incompatable) media"
		break
	case 0xFA:
		s = "E$DevBsy :Device Busy"
		break
	case 0xFB:
		s = "E$DIDC   :Disk ID Change"
		break
	case 0xFC:
		s = "E$Lock   :Record is busy (locked out)"
		break
	case 0xFD:
		s = "E$Share  :Non-sharable file busy"
		break
	case 0xFE:
		s = "E$DeadLk :I/O Deadlock error"
		break
	}
	return s
}

func DecodeOs9GetStat(b byte) string {
	s := "???"
	switch b {
	case 0x00:
		s = "SS.Opt    : Read/Write PD Options"
		break
	case 0x01:
		s = "SS.Ready  : Check for Device Ready"
		break
	case 0x02:
		s = "SS.Size   : Read/Write File Size"
		break
	case 0x03:
		s = "SS.Reset  : Device Restore"
		break
	case 0x04:
		s = "SS.WTrk   : Device Write Track"
		break
	case 0x05:
		s = "SS.Pos    : Get File Current Position"
		break
	case 0x06:
		s = "SS.EOF    : Test for End of File"
		break
	case 0x07:
		s = "SS.Link   : Link to Status routines"
		break
	case 0x08:
		s = "SS.ULink  : Unlink Status routines"
		break
	case 0x09:
		s = "SS.Feed   : Issue form feed"
		break
	case 0x0A:
		s = "SS.Frz    : Freeze DD. information"
		break
	case 0x0B:
		s = "SS.SPT    : Set DD.TKS to given value"
		break
	case 0x0C:
		s = "SS.SQD    : Sequence down hard disk"
		break
	case 0x0D:
		s = "SS.DCmd   : Send direct command to disk"
		break
	case 0x0E:
		s = "SS.DevNm  : Return Device name (32-bytes at [X])"
		break
	case 0x0F:
		s = "SS.FD     : Return File Descriptor (Y-bytes at [X])"
		break
	case 0x10:
		s = "SS.Ticks  : Set Lockout honor duration"
		break
	case 0x11:
		s = "SS.Lock   : Lock/Release record"
		break
	case 0x12:
		s = "SS.DStat  : Return Display Status (CoCo)"
		break
	case 0x13:
		s = "SS.Joy    : Return Joystick Value (CoCo)"
		break
	case 0x14:
		s = "SS.BlkRd  : Block Read"
		break
	case 0x15:
		s = "SS.BlkWr  : Block Write"
		break
	case 0x16:
		s = "SS.Reten  : Retension cycle"
		break
	case 0x17:
		s = "SS.WFM    : Write File Mark"
		break
	case 0x18:
		s = "SS.RFM    : Read past File Mark"
		break
	case 0x19:
		s = "SS.ELog   : Read Error Log"
		break
	case 0x1A:
		s = "SS.SSig   : Send signal on data ready"
		break
	case 0x1B:
		s = "SS.Relea  : Release device"
		break
	case 0x1C:
		s = "SS.AlfaS  : Return Alfa Display Status (CoCo, SCF/GetStat)"
		break
	case 0x1D:
		s = "SS.Break  : Send break signal out acia"
		break
	case 0x1E:
		s = "SS.RsBit  : Reserve bitmap sector (do not allocate in) LSB(X)=sct#"
		break
	case 0x20:
		s = "SS.DirEnt : Reserve bitmap sector (do not allocate in) LSB(X)=sct#"
		break
	case 0x24:
		s = "SS.SetMF  : Reserve $24 for Gimix G68 (Flex compatability?)"
		break
	case 0x25:
		s = "SS.Cursr  : Cursor information for COCO"
		break
	case 0x26:
		s = "SS.ScSiz  : Return screen size for COCO"
		break
	case 0x27:
		s = "SS.KySns  : Getstat/SetStat for COCO keyboard"
		break
	case 0x28:
		s = "SS.ComSt  : Getstat/SetStat for Baud/Parity"
		break
	case 0x29:
		s = "SS.Open   : SetStat to tell driver a path was opened"
		break
	case 0x2A:
		s = "SS.Close  : SetStat to tell driver a path was closed"
		break
	case 0x2B:
		s = "SS.HngUp  : SetStat to tell driver to hangup phone"
		break
	case 0x2C:
		s = "SS.FSig   : New signal for temp locked files"
		break
	}
	return s
}

func Os9String(addr word) string {
	var buf bytes.Buffer
	for {
		var b byte = B(addr)
		var ch byte = 0x7F & b
		if '!' <= ch && ch <= '~' {
			buf.WriteByte(ch)
		} else {
			break
		}
		if (b & 128) != 0 {
			break
		}
		addr++
	}
	return buf.String()
}

func PrintableStringThruCrOrMax(a word, max word) string {
	var buf bytes.Buffer
	for i := word(0); i < yreg && i < max; i++ {
		ch := B(a + i)
		if 32 <= ch && ch < 127 {
			buf.WriteByte(ch)
		} else if ch == '\n' || ch == '\r' {
			buf.WriteByte('\n')
		} else {
			Z(&buf, "{%d}", ch)
		}
		if ch == '\r' {
			break
		}
	}
	return buf.String()
}

func EscapeStringThruCrOrMax(a word, max word) string {
	var buf bytes.Buffer
	for i := word(0); i < yreg && i < max; i++ {
		ch := B(a + i)
		if 32 <= ch && ch < 127 {
			buf.WriteByte(ch)
		} else {
			Z(&buf, "{%d}", ch)
		}
		if ch == '\r' {
			break
		}
	}
	return buf.String()
}

func ModuleName(a word) string {
	s := a + W(a+4)
	return Os9String(s)
}

type Callback func(*Completion)
type Completion struct {
	callback Callback
	service  byte
	name     string
}

var Os9SysCallCompletion [0x10000]Completion

func DefaultCompleter(cp *Completion) {
	if word(cp.service-1) == F_NProc {
		return // F$NProc does not return to its caller.
	}
	if (ccreg & 1 /* carry bit indicates error */) != 0 {
		errcode := GetBReg()
		// TODO: L( "HEY, Kernel 0x%02x: %s -> ERROR [%02x] %s", cp.service-1, cp.name, errcode, DecodeOs9Error(errcode));
		L("HEY, Kernel 0x%02x: -> ERROR [%02x] %s", cp.service-1, errcode, DecodeOs9Error(errcode))
	} else {
		// TODO: L( "HEY, Kernel 0x%02x: %s -> okay", cp.service-1, cp.name);
		L("HEY, Kernel 0x%02x: -> okay", cp.service-1)
	}
	// TODO: move this to the "rti" instruction, and track by SP.  (would be better with re-entrant code.)
}

func DecodeOs9Opcode(b byte) {
	var buf bytes.Buffer
	Os9AllMemoryModules()
	s := "???"
	switch b {
	case 0x00:
		s = "F$Link   : Link to Module"
		Z(&buf, "type/lang=%02x module/file='%s'", GetAReg(), Os9String(xreg))

		if Os9String(xreg) == "Dir" || Os9String(xreg) == "dir" {
			tracing = true
		}

	case 0x01:
		s = "F$Load   : Load Module from File"
		Z(&buf, "type/lang=%02x filename='%s'", GetAReg(), Os9String(xreg))

	case 0x02:
		s = "F$UnLink : Unlink Module"
		Z(&buf, "u=%04x magic=%04x module='%s'", ureg, W(ureg), ModuleName(ureg))

	case 0x03:
		s = "F$Fork   : Start New Process"
		Z(&buf, "Module/file='%s' paramsize=%x lang/type=%x pages=%x", Os9String(xreg), ureg, GetAReg(), GetBReg())

	case 0x04:
		s = "F$Wait   : Wait for Child Process to Die"

	case 0x05:
		s = "F$Chain  : Chain Process to New Module"
		Z(&buf, "Module/file='%s' paramsize=%x lang/type=%x pages=%x", Os9String(xreg), ureg, GetAReg(), GetBReg())

	case 0x06:
		s = "F$Exit   : Terminate Process"
		Z(&buf, "status=%x", GetBReg())

	case 0x07:
		s = "F$Mem    : Set Memory Size"
		Z(&buf, "desired_size=%x", dreg)

	case 0x08:
		s = "F$Send   : Send Signal to Process"

	case 0x09:
		s = "F$Icpt   : Set Signal Intercept"

	case 0x0A:
		s = "F$Sleep  : Suspend Process"

	case 0x0B:
		s = "F$SSpd   : Suspend Process"

	case 0x0C:
		s = "F$ID     : Return Process ID"

	case 0x0D:
		s = "F$SPrior : Set Process Priority"

	case 0x0E:
		s = "F$SSWI   : Set Software Interrupt"

	case 0x0F:
		s = "F$PErr   : Print Error"

	case 0x10:
		s = "F$PrsNam : Parse Pathlist Name"
		Z(&buf, "path='%s'", Os9String(xreg))
		return
	case 0x11:
		s = "F$CmpNam : Compare Two Names"

	case 0x12:
		s = "F$SchBit : Search Bit Map"

	case 0x13:
		s = "F$AllBit : Allocate in Bit Map"

	case 0x14:
		s = "F$DelBit : Deallocate in Bit Map"

	case 0x15:
		s = "F$Time   : Get Current Time"

	case 0x16:
		s = "F$STime  : Set Current Time"

	case 0x17:
		s = "F$CRC    : Generate CRC ($1"

	// NitrOS9:

	case 0x27:
		s = "F$VIRQ   : Install/Delete Virtual IRQ"

	case 0x28:
		s = "F$SRqMem : System Memory Request"
		Z(&buf, "size=%x", dreg)

	case 0x29:
		s = "F$SRtMem : System Memory Return"

	case 0x2A:
		s = "F$IRQ    : Enter IRQ Polling Table"

	case 0x2B:
		s = "F$IOQu   : Enter I/O Queue"

	case 0x2C:
		s = "F$AProc  : Enter Active Process Queue"
		Z(&buf, "proc=%x\n", xreg)

	case 0x2D:
		s = "F$NProc  : Start Next Process"

	case 0x2E:
		s = "F$VModul : Validate Module"
		Z(&buf, "addr=%04x", xreg)

	case 0x2F:
		s = "F$Find64 : Find Process/Path Descriptor"
		Z(&buf, "base=%04x id=%x", xreg, GetAReg())

	case 0x30:
		s = "F$All64  : Allocate Process/Path Descriptor"
		Z(&buf, "table=%x", xreg)

	case 0x31:
		s = "F$Ret64  : Return Process/Path Descriptor"

	case 0x32:
		s = "F$SSvc   : Service Request Table Initialization"

	case 0x33:
		s = "F$IODel  : Delete I/O Module"

	// IOMan:

	case 0x80:
		s = "I$Attach : Attach I/O Device"
		Z(&buf, "u=%04x magic=%04x module='%s'", ureg, W(ureg), Os9String(ureg+W(ureg+4)))
		return

	case 0x81:
		s = "I$Detach : Detach I/O Device"

	case 0x82:
		s = "I$Dup    : Duplicate Path"

	case 0x83:
		s = "I$Create : Create New File"
		Z(&buf, "X='%s'", Os9String(xreg))
		return

	case 0x84:
		s = "I$Open   : Open Existing File"
		Z(&buf, "X='%s'", Os9String(xreg))
		return

	case 0x85:
		s = "I$MakDir : Make Directory File"
		Z(&buf, "X='%s'", Os9String(xreg))
		return

	case 0x86:
		s = "I$ChgDir : Change Default Directory"
		Z(&buf, "X='%s'", Os9String(xreg))

	case 0x87:
		s = "I$Delete : Delete File"
		Z(&buf, "X='%s'", Os9String(xreg))
		return

	case 0x88:
		s = "I$Seek   : Change Current Position"

	case 0x89:
		s = "I$Read   : Read Data"

	case 0x8A:
		s = "I$Write  : Write Data"
		{
			path_num := GetAReg()
			proc := W(D_Proc)
			path := B(proc + P_PATH + word(path_num))
			pathDBT := W(D_PthDBT)
			q := W(pathDBT + (word(path) >> 2))
			Z(&buf, "..writln..  path_num=%x proc=%x path=%x dbt=%x q=%x\n", path_num, proc, path, pathDBT, q)
			if q != 0 {
				pd := q + 64*(word(path)&3)
				dev := W(pd + PD_DEV)
				Z(&buf, "..writln..  pd=%x dev=%x\n", pd, dev)
				desc := W(dev + V_DESC)
				name := ModuleName(W(dev + V_DESC))
				Z(&buf, "..writln..  desc=%x=%s\n", desc, name)
				if name == "Term" {
					addy := MapAddr(xreg)
					fmt.Printf("%s", string(mem[addy:addy+int(uint(yreg))]))
				}
			}
		}

	case 0x8B:
		s = "I$ReadLn : Read Line of ASCII Data"

	case 0x8C:
		s = "I$WritLn : Write Line of ASCII Data"
		Z(&buf, "HEY, Kernel 0x%02x: %s .... {{{%s}}}\n", b, s, EscapeStringThruCrOrMax(xreg, yreg))
		{
			path_num := GetAReg()
			proc := W(D_Proc)
			path := B(proc + P_PATH + word(path_num))
			pathDBT := W(D_PthDBT)
			q := W(pathDBT + (word(path) >> 2))
			Z(&buf, "..writln..  path_num=%x proc=%x path=%x dbt=%x q=%x\n", path_num, proc, path, pathDBT, q)
			if q != 0 {
				pd := q + 64*(word(path)&3)
				dev := W(pd + PD_DEV)
				Z(&buf, "..writln..  pd=%x dev=%x\n", pd, dev)
				desc := W(dev + V_DESC)
				name := ModuleName(W(dev + V_DESC))
				Z(&buf, "..writln..  desc=%x=%s\n", desc, name)
				if name == "Term" {
					fmt.Printf("%s", PrintableStringThruCrOrMax(xreg, yreg))
				}
			}
		}

	case 0x8D:
		s = "I$GetStt : Get Path Status"
		Z(&buf, "path=%x %s", GetAReg(), DecodeOs9GetStat(GetBReg()))
		return

	case 0x8E:
		s = "I$SetStt : Set Path Status"
		Z(&buf, "path=%x %s", GetAReg(), DecodeOs9GetStat(GetBReg()))
		return

	case 0x8F:
		s = "I$Close  : Close Path"
		Z(&buf, "path=%x", GetAReg())

	case 0x90:
		s = "I$DeletX : Delete from current exec dir"

	}
	L("HEY, Kernel 0x%02x: %s {%s}\n", b, s, buf.String())

	cp := &Os9SysCallCompletion[pcreg+1]
	cp.callback = DefaultCompleter
	cp.service = B(pcreg) + 1
	cp.name = s
}

/*
void DefaultCompleter(struct Completion* cp) {
  if (ccreg&1) { // carry bit indicates error
    byte errcode = *breg;
    fprintf(stderr, "HEY, Kernel 0x%02x -> ERROR [%02x] %s\n", cp->service-1, errcode, DecodeOs9Error(errcode));
  } else {
    fprintf(stderr, "HEY, Kernel 0x%02x -> okay\n", cp->service-1);
  }
}
*/

const KB_NORMAL = "@ABCDEFGHIJKLMNOPQRSTUVWXYZ{}[] 0123456789:;,-./\r\b\000\000\000\000\000\000"
const KB_SHIFT = "@abcdefghijklmnopqrstuvwxyz____ 0!\"#$%&'()*+<=>?\000\000\000\000\000\000\000\000"

func keypress(probe byte, ch byte) byte {
	shifted := false
	sense := byte(0)
	probe = ^probe
	for j := uint(0); j < 8; j++ {
		for i := uint(0); i < 7; i++ {
			if KB_NORMAL[i*8+j] == ch {
				if (byte(1<<j) & probe) != 0 {
					sense |= 1 << i
				}
			}
			if KB_SHIFT[i*8+j] == ch {
				if (byte(1<<j) & probe) != 0 {
					sense |= byte(1 << i)
				}
				shifted = true
			}
		}
	}
	if shifted && (probe&0x80) != 0 {
		sense |= 0x40 // Shift key.
	}
	return ^sense
}

func interrupt(vector_addr word) {
	PushWord(pcreg)
	if vector_addr == VECTOR_FIRQ {
		// Fast IRQ.
		ccreg &= ^byte(CC_ENTIRE)
	} else {
		// Other IRQs.
		PushWord(ureg)
		PushWord(yreg)
		PushWord(xreg)
		PushByte(dpreg)
		PushWord(dreg)
	}
	PushByte(ccreg)
	if vector_addr == VECTOR_FIRQ {
		// Fast IRQ.
		ccreg &= ^byte(CC_ENTIRE)
	} else {
		// Other IRQs.
		ccreg |= byte(CC_ENTIRE)
	}
	// All IRQs.
	ccreg |= (CC_INHIBIT_FIRQ | CC_INHIBIT_IRQ)
	pcreg = W(vector_addr)
}

var prev_disk_command byte
var disk_command byte
var disk_offset int64
var disk_drive byte
var disk_side byte
var disk_sector byte
var disk_track byte
var disk_status byte
var disk_data byte
var disk_control byte
var disk_fd *os.File
var disk_stuff [256]byte
var zero_disk_stuff [256]byte
var disk_i word

var kbd_ch byte
var kbd_probe byte
var kbd_cycle word

func assert(b bool) {
	if !b {
		panic("assert failed")
	}
}
func MaybeGetChar() byte {
	return 0
}

func nmi() {
	L("HEY, INTERRUPTING with NMI")
	interrupt(VECTOR_NMI)
	irqs_pending &= ^byte(NMI_PENDING)
}

func inkey(keystrokes <-chan byte) byte {
	select {
	case _ch, _ok := <-keystrokes:
		if _ok {
			return _ch
		} else {
			Finish()
			os.Exit(0)
			return 0
		}
	default:
		return 0
	}
}

// var remember_ch byte
func irq(keystrokes <-chan byte) {
	kbd_cycle++
	L("HEY, INTERRUPTING with IRQ (kbd_cycle = %d)", kbd_cycle)
	assert(0 == (ccreg & CC_INHIBIT_IRQ))

	if (kbd_cycle & 1) == 0 {
		ch := inkey(keystrokes)
		if ch == 10 || ch == 13 {
			kbd_ch = 13
		} else if 0 < ch && ch < 127 {
			kbd_ch = ch
		} else {
			kbd_ch = 0
		}
		// remember_ch = kbd_ch
		L("HEY, getchar -> ch %x %c kbd_ch %x %c (kbd_cycle = %d)\n", ch, ch, kbd_ch, kbd_ch, kbd_cycle)
		// } else if (kbd_cycle & 7) < 4 {
		// kbd_ch = remember_ch
	} else {
		kbd_ch = 0
	}
	L("HEY, irq -> kbd_ch %x %c (kbd_cycle = %d)\n", kbd_ch, kbd_ch, kbd_cycle)

	interrupt(VECTOR_IRQ)
	irqs_pending &= ^byte(IRQ_PENDING)
}

func GetIOByte(a word) byte {
	var z byte
	switch a {
	/* PIA 0 */

	/*
	   PUTBYTE ff01  <- 00
	   PUTBYTE ff00  <- 00  // inputs
	   PUTBYTE ff03  <- 00
	   PUTBYTE ff02  <- ff  // outputs
	   PUTBYTE ff01  <- 34
	   PUTBYTE ff03  <- 35
	*/

	/* clock_60hz.list:
	   0090 7DFF03           (/home/strick/6809):00227                  tst   PIA0Base+3 get hw byte
	   0093 2B04             (/home/strick/6809):00228                  bmi   L0032      branch if sync flag on
	   0095 6E9F0038         (/home/strick/6809):00229                  jmp   [>D.SvcIRQ] else service other possible IRQ
	   0099 7DFF02           (/home/strick/6809):00230         L0032    tst   PIA0Base+2 clear interrupt
	*/
	case 0xFF00:
		z = 255
		if kbd_ch != 0 {
			z = keypress(kbd_probe, kbd_ch)
			L("HEY, KEYBOARD: %02x {%c} -> %02x\n", kbd_probe, kbd_ch, z)
		} else {
			L("HEY, KEYBOARD: %02x      -> %02x\n", kbd_probe, z)
		}
		return z

	case 0xFF01:
		return 0
	case 0xFF02:
		return kbd_probe /* Reset IRQ when this is read. TODO: multiple sources of IRQ. */
	case 0xFF03:
		return 0x80 /* Negative bit set: Yes the PIA caused IRQ. */

	/* PIA 1 */
	case 0xFF22:
		L("HEY, TODO: Get Io byte 0x%04x\n", a)
		return 0

	case 0xFF48: /* STATREG */
		return 0 /* low bit 0 means Ready, other bits are errors or not ready */

	case 0xFF4B: /* Read Data */
		z = 0
		if disk_i < 256 {
			z = disk_stuff[disk_i]
			L("fnord %x -> %x\n", disk_i, z)
		} else {
			z = 0
		}
		disk_i++
		if disk_i == 257 {
			L("HEY, Read SET NMI_PENDING\n")
			irqs_pending |= NMI_PENDING
			z = 0
			disk_i = 0
		}
		return z

	default:
		L("HEY, UNKNOWN GetIOByte: 0x%04x\n", a)
		return 0
	}
}

func PutIOByte(a word, b byte) {
	switch a {
	default:
		log.Panicf("HEY, UNKNOWN PutIOByte address: 0x%04x", a)

	case 0xFFB0, 0xFFB1:
		L("B0: palettes <- %0x2", b)

	case 0xFFD9:
		L("D9: Cpu Speed <- %0x2", b)

	case 0xFF90:
		MmuEnable = 0 != (b & 0x40)
		L("GIME MmuEnable <- %v", MmuEnable)

	case 0xFF91:
		MmuTask = b & 0x01
		L("GIME MmuEnable <- %v; clock rate <- %v", MmuEnable, 0 != (b&0x40))

	case 0xFF92,
		0xFF93,
		0xFF94,
		0xFF95,
		0xFF96,
		0xFF97,
		0xFF98,
		0xFF99,
		0xFF9A,
		0xFF9B,
		0xFF9C,
		0xFF9D,
		0xFF9E,
		0xFF9F:
		L("GIME %x <= %02x", a, b)

	case 0xFFA0,
		0xFFA1,
		0xFFA2,
		0xFFA3,
		0xFFA4,
		0xFFA5,
		0xFFA6,
		0xFFA7,
		0xFFA8,
		0xFFA9,
		0xFFAA,
		0xFFAB,
		0xFFAC,
		0xFFAD,
		0xFFAE,
		0xFFAF:
		{
			task := byte((a >> 3) & 1)
			slot := byte(a & 7)
			MmuMap[task][slot] = b & 0x3F
			L("GIME MmuMap[%d][%d] <- %02x", task, slot, b)
		}

	case 0xFF02:
		kbd_probe = b

	case 0xFF00,
		0xFF01,
		0xFF03,

		0xFF20,
		0xFF21,
		0xFF22,
		0xFF23:
		L("HEY, TODO: Put IO byte 0x%04x\n", a)
		return

	case 0xFF40: /* CONTROL */
		{
			disk_control = b
			disk_side = CondB(b&0x40 != 0, 1, 0)
			disk_drive = CondB((b&1 != 0), 1, CondB((b&2 != 0), 2, CondB((b&4 != 0), 3, 0)))

			L("CONTROL: disk_command %x (control %x side %x drive %x)\n", disk_command, disk_control, disk_side, disk_drive)
			if b == 0 {
				break
			}

			switch disk_command {
			case 0x80:
				{
					prev_disk_command = disk_command
					disk_offset = 256 * (int64(disk_sector) - 1 + int64(disk_side)*18 + int64(disk_track)*36)
					if disk_drive != 1 {
						log.Panicf("ERROR: R: Drive %d not supported\n", disk_drive)
					}
					if disk_fd == nil {
						log.Panicf("ERROR: R: No file for Disk Read Sector\n")
					}

					disk_stuff = zero_disk_stuff
					_, err := disk_fd.Seek(disk_offset, 0)
					if err != nil {
						log.Panicf("Bad disk sector seek: err=%v", err)
					}
					n, err := disk_fd.Read(disk_stuff[:])
					if err != nil {
						log.Panicf("Bad disk sector read: err=%v", err)
					}
					if n != 256 {
						log.Panicf("Short disk sector read: n=%d", n)
					}

					assert(n == 256)
					disk_i = 0
					L("HEY, READ fnord (Track, Sector-1) %d:%d:%d:%d == %d\n", disk_drive, disk_track, disk_side, disk_sector-1, disk_offset>>8)
				}
			case 0xA0:
				{
					prev_disk_command = disk_command
					disk_offset = 256 * (int64(disk_sector) - 1 + int64(disk_side)*18 + int64(disk_track)*36)
					if disk_drive != 1 {
						log.Panicf("ERROR: W: Drive %d not supported\n", disk_drive)
					}
					if disk_fd == nil {
						log.Panicf("ERROR: W: No file for Disk Read Sector\n")
					}
					disk_stuff = zero_disk_stuff
					_, err := disk_fd.Seek(int64(disk_offset), 0)
					if err != nil {
						log.Panicf("Bad disk sector seek: err=%v", err)
					}

					disk_i = 0
					L("HEY, WRITE fnord (Track, Sector-1) %d:%d:%d:%d == %d\n", disk_drive, disk_track, disk_side, disk_sector-1, disk_offset>>8)
				}
			}
			disk_command = 0
		}
	case 0xFF48:
		{ // CMDREG //
			disk_command = b
			switch b {
			case 0x10:
				{
					disk_track = disk_data
					disk_status = 0
					L("HEY, Seek : %d\n", disk_data)
				}
			case 0x80:
				{ // Read Sector //
					// We have set disk_command.  Next control write defines disk & side. //

				}
			case 0xD0:
				{
					disk_drive = 0
					disk_side = 0
					disk_track = 0
					disk_sector = 0
					disk_i = 0
					disk_stuff = zero_disk_stuff
					L("HEY, Reset Disk\n")
				}
			}
		}
	case 0xFF49: /* TRACK */
		disk_track = b
		L("HEY, Track : %d\n", b)

	case 0xFF4A: /* SECTOR */
		disk_sector = b
		L("HEY, Sector-1 : %d\n", b-1)

	case 0xFF4B:
		{ /* DATA */
			if (prev_disk_command & 0xF0) != 0xA0 {
				disk_i = 0
				disk_data = b
			} // else
			if true {
				if disk_i < 256 {
					L("fnord %x %x <- %x\n", prev_disk_command, disk_i, b)
					disk_stuff[disk_i] = b
					///++disk_i;
				}
			}
			if (prev_disk_command & 0xF0) == 0xA0 {
				if disk_i < 256 {
					disk_i++
				}
				// TODO -- fix writing.
				if disk_i >= 256 {
					L("HEY, Write SET NMI_PENDING\n")
					irqs_pending |= NMI_PENDING
					disk_i = 0

					// TODO -- fix writing.
					n, err := disk_fd.Write(disk_stuff[:])
					if err != nil {
						log.Panicf("Error in disk_fd.Write: %v", err)
					}
					if n != 256 {
						log.Panicf("Error in disk_fd.Write: Short n=%d", n)
					}
					L("HEY, DID_WRITE fnord (Track, Sector-1) %d:%d:%d:%d == %d\n", disk_drive, disk_track, disk_side, disk_sector-1, disk_offset>>8)
				}
			}

		}

	/* VDG */
	case 0xFFC0,
		0xFFC1,
		0xFFC2,
		0xFFC3,
		0xFFC4,
		0xFFC5,
		0xFFC6,
		0xFFC7,
		0xFFC8,
		0xFFC9,
		0xFFCA,
		0xFFCB,
		0xFFCC,
		0xFFCD,
		0xFFCE,
		0xFFCF,

		0xFFD0,
		0xFFD1,
		0xFFD2,
		0xFFD3,
		0xFFDF:
		{
			L("VDG PutByte OK: %x <- %x\n", a, b)
		}
	}
}

func H(ch byte) byte {
	ch &= 0x7F
	if 32 <= ch && ch <= 126 {
		return ch
	} else {
		return ' '
	}
}
func T(ch byte) byte {
	if ch&128 != 0 && 128+32 <= ch && ch <= 128+126 {
		return '+'
	} else {
		return ' '
	}
}

func da_inst(inst string, reg string, cyclecount int) {
	dinst.Reset()
	dops.Reset()
	dinst.WriteString(inst)
	dinst.WriteString(reg)
	cycles += cyclecount
}

func da_inst_cat(inst string, cyclecount int) {
	dinst.WriteString(inst)
	cycles += cyclecount
}

func da_ops(part1 string, part2 string, cyclecount int) {
	dops.WriteString(part1)
	dops.WriteString(part2)
	cycles += cyclecount
}

var reg_for_da_reg = []string{"d", "x", "y", "u", "s", "pc", "?", "?", "a", "b", "cc", "dp", "?", "?", "?", "?"}

func da_reg(b byte) {
	dops.WriteString(reg_for_da_reg[(b>>4)&0xf])
	dops.WriteString(",")
	dops.WriteString(reg_for_da_reg[b&0xf])
}

// Now follow the posbyte addressing modes. //

func illaddr() EA { // illegal addressing mode, defaults to zero //
	log.Panicf("Illegal Addressing Mode")
	panic(0)
}

var dixreg = []string{"x", "y", "u", "s"}

func ainc() EA {
	da_ops(",", dixreg[idx], 2)
	da_ops("+", "", 0)
	regPtr := ixregs[idx]
	z := *regPtr
	(*regPtr)++
	return EA(z)
	// return (*ixregs[idx])++;
}

func ainc2() EA {
	// word temp;
	da_ops(",", dixreg[idx], 3)
	da_ops("++", "", 0)
	//temp=(*ixregs[idx]);
	//(*ixregs[idx])+=2;
	//return(temp);
	regPtr := ixregs[idx]
	z := *regPtr
	(*regPtr) += 2
	return EA(z)
}

func adec() EA {
	da_ops(",-", dixreg[idx], 2)
	// return --(*ixregs[idx]);
	regPtr := ixregs[idx]
	(*regPtr)--
	return EA(*regPtr)
}

func adec2() EA {
	// word temp;
	da_ops(",--", dixreg[idx], 3)
	//(*ixregs[idx])-=2;
	//temp=(*ixregs[idx]);
	//return(temp);
	regPtr := ixregs[idx]
	(*regPtr) -= 2
	return EA(*regPtr)
}

func plus0() EA {
	da_ops(",", dixreg[idx], 0)
	return EA(*ixregs[idx])
}

func plusa() EA {
	da_ops("a,", dixreg[idx], 1)
	return EA((*ixregs[idx]) + Signed(GetAReg()))
}

func plusb() EA {
	da_ops("b,", dixreg[idx], 1)
	return EA((*ixregs[idx]) + Signed(GetBReg()))
}

func plusn() EA {
	off := ""
	b := ImmByte()
	/* negative offsets alway decimal, otherwise hex */
	if (b & 0x80) != 0 {
		off = F("%d,", -(b^0xff)-1)
	} else {
		off = F("$%02x,", b)
	}
	da_ops(off, dixreg[idx], 1)
	return EA((*ixregs[idx]) + Signed(b))
}

func plusnn() EA {
	w := ImmWord()
	off := F("$%04x,", w)
	da_ops(off, dixreg[idx], 4)
	return EA(*ixregs[idx] + w)
}

func plusd() EA {
	da_ops("d,", dixreg[idx], 4)
	return EA(*ixregs[idx] + dreg)
}

func npcr() EA {
	b := ImmByte()
	off := F("$%04x,pcr", (pcreg+Signed(b))&0xffff)
	da_ops(off, "", 1)
	return EA(pcreg + Signed(b))
}

func nnpcr() EA {
	w := ImmWord()
	off := F("$%04x,pcr", (pcreg+w)&0xffff)
	da_ops(off, "", 5)
	return EA(pcreg + w)
}

func direct() EA {
	w := ImmWord()
	off := F("$%04x", w)
	da_ops(off, "", 3)
	return EA(w)
}

func zeropage() EA {
	b := ImmByte()
	off := F("$%02x", b)
	da_ops(off, "", 2)
	return EA(HiLo(dpreg, b))
}

func immediate() EA {
	off := F("#$%02x", B(pcreg))
	da_ops(off, "", 0)
	z := pcreg
	pcreg++
	return EA(z)
}

func immediate2() EA {
	z := pcreg
	off := F("#$%04x", (word(B(pcreg))<<8)|word(B(pcreg+1)))
	da_ops(off, "", 0)
	pcreg += 2
	return EA(z)
}

var pbtable = []func() EA{
	ainc, ainc2, adec, adec2,
	plus0, plusb, plusa, illaddr,
	plusn, plusnn, illaddr, plusd,
	npcr, nnpcr, illaddr, direct}

func postbyte() EA {
	pb := ImmByte()
	idx = ((pb & 0x60) >> 5)
	if (pb & 0x80) != 0 {
		if (pb & 0x10) != 0 {
			da_ops("[", "", 3)
		}
		temp := (pbtable[pb&0x0f])()
		if (pb & 0x10) != 0 {
			temp = EA(temp.GetW())
			da_ops("]", "", 0)
		}
		return EA(temp)
	} else {
		temp := word(pb & 0x1f)
		if (temp & 0x10) != 0 {
			temp |= 0xfff0 /* sign extend */
		}
		var off string
		if (temp & 0x10) != 0 {
			// Use int16 for negative signed number.
			// Sign-extend by or'ing with 0xF0.
			off = F("%d,", int16(0xF0|temp))
			// off = F("%d,", int16(-(temp^0xffff)-1))
		} else {
			off = F("%d,", temp)
		}
		da_ops(off, dixreg[idx], 1)
		return EA(*ixregs[idx] + temp)
	}
}

func eaddr0() EA { // effective address for NEG..JMP //
	switch (ireg & 0x70) >> 4 {
	case 0:
		return zeropage()
	case 1:
	case 2:
	case 3: //canthappen//
		log.Panicf("UNKNOWN eaddr0: %02x\n", ireg)
		return 0

	case 4:
		da_inst_cat("a", -2)
		return ARegEA
	case 5:
		da_inst_cat("b", -2)
		return BRegEA
	case 6:
		da_inst_cat("", 2)
		return postbyte()
	case 7:
		return direct()
	}
	panic("notreached")
}

func eaddr8() EA { // effective address for 8-bits ops. //
	switch (ireg & 0x30) >> 4 {
	case 0:
		return immediate()
	case 1:
		return zeropage()
	case 2:
		da_inst_cat("", 2)
		return postbyte()
	case 3:
		return direct()
	}
	panic("notreached")
}

func eaddr16() EA { // effective address for 16-bits ops. //
	switch (ireg & 0x30) >> 4 {
	case 0:
		da_inst_cat("", -1)
		return immediate2()
	case 1:
		da_inst_cat("", -1)
		return zeropage()
	case 2:
		da_inst_cat("", 1)
		return postbyte()
	case 3:
		da_inst_cat("", -1)
		return direct()
	}
	panic("notreached")
}

func ill() {
	log.Panicf("Illegal Opcode: 0x%x", ireg)
}

// macros to set status flags //
func SEC() { ccreg |= 0x01 }
func CLC() { ccreg &= 0xfe }
func SEZ() { ccreg |= 0x04 }
func CLZ() { ccreg &= 0xfb }
func SEN() { ccreg |= 0x08 }
func CLN() { ccreg &= 0xf7 }
func SEV() { ccreg |= 0x02 }
func CLV() { ccreg &= 0xfd }
func SEH() { ccreg |= 0x20 }
func CLH() { ccreg &= 0xdf }

// set N and Z flags depending on 8 or 16 bit result //
func SETNZ8(b byte) {
	if b != 0 {
		CLZ()
	} else {
		SEZ()
	}
	if (b & 0x80) != 0 {
		SEN()
	} else {
		CLN()
	}
}
func SETNZ16(b word) {
	if b != 0 {
		CLZ()
	} else {
		SEZ()
	}
	if (b & 0x8000) != 0 {
		SEN()
	} else {
		CLN()
	}
}

func SETSTATUS(a byte, b byte, res word) {
	if ((a ^ b ^ byte(res)) & 0x10) != 0 {
		SEH()
	} else {
		CLH()
	}
	if ((a ^ b ^ byte(res) ^ byte(res>>1)) & 0x80) != 0 {
		SEV()
	} else {
		CLV()
	}
	if (res & 0x100) != 0 {
		SEC()
	} else {
		CLC()
	}
	SETNZ8(byte(res))
}

func CondB(b bool, x, y byte) byte {
	if b {
		return x
	} else {
		return y
	}
}
func CondW(b bool, x, y word) word {
	if b {
		return x
	} else {
		return y
	}
}
func CondI(b bool, x, y int) int {
	if b {
		return x
	} else {
		return y
	}
}
func CondS(b bool, x, y string) string {
	if b {
		return x
	} else {
		return y
	}
}

func AOrB(aIfZero byte) EA {
	if aIfZero == 0 {
		return ARegEA
	} else {
		return BRegEA
	}
}

func add() {
	var aop, bop, res word
	da_inst("add", CondS(0 != (ireg&0x40), "b", "a"), 2)
	accum := AOrB(ireg & 0x40)
	aop = word(accum.GetB())
	bop = word(eaddr8().GetB())
	res = (aop) + (bop)
	SETSTATUS(byte(aop), byte(bop), res)
	accum.PutB(byte(res))
}

func sbc() {
	var aop, bop, res word
	da_inst("sbc", CondS(0 != (ireg&0x40), "b", "a"), 2)
	accum := AOrB(ireg & 0x40)
	aop = word(accum.GetB())
	bop = word(eaddr8().GetB())
	res = aop - bop - word(ccreg&0x01)
	SETSTATUS(byte(aop), byte(bop), res)
	accum.PutB(byte(res))
}

func sub() {
	var aop, bop, res word
	da_inst("sub", CondS(0 != (ireg&0x40), "b", "a"), 2)
	accum := AOrB(ireg & 0x40)
	aop = word(accum.GetB())
	bop = word(eaddr8().GetB())
	res = aop - bop
	SETSTATUS(byte(aop), byte(bop), res)
	accum.PutB(byte(res))
}

func adc() {
	var aop, bop, res word
	da_inst("adc", CondS(0 != (ireg&0x40), "b", "a"), 2)
	accum := AOrB(ireg & 0x40)
	aop = word(accum.GetB())
	bop = word(eaddr8().GetB())
	res = aop + bop + word(ccreg&0x01)
	SETSTATUS(byte(aop), byte(bop), res)
	accum.PutB(byte(res))
}

func cmp() {
	var aop, bop, res word
	da_inst("cmp", CondS(0 != (ireg&0x40), "b", "a"), 2)
	accum := AOrB(ireg & 0x40)
	aop = word(accum.GetB())
	bop = word(eaddr8().GetB())
	res = aop - bop
	SETSTATUS(byte(aop), byte(bop), res)
}

func and() {
	var aop, bop, res byte
	da_inst("and", CondS(0 != (ireg&0x40), "b", "a"), 2)
	accum := AOrB(ireg & 0x40)
	aop = (accum.GetB())
	bop = (eaddr8().GetB())
	res = aop & bop
	SETNZ8(res)
	CLV()
	accum.PutB(res)
}
func or() {
	var aop, bop, res byte
	da_inst("or", CondS(0 != (ireg&0x40), "b", "a"), 2)
	accum := AOrB(ireg & 0x40)
	aop = (accum.GetB())
	bop = (eaddr8().GetB())
	res = aop | bop
	SETNZ8(res)
	CLV()
	accum.PutB(res)
}
func eor() {
	var aop, bop, res byte
	da_inst("eor", CondS(0 != (ireg&0x40), "b", "a"), 2)
	accum := AOrB(ireg & 0x40)
	aop = (accum.GetB())
	bop = (eaddr8().GetB())
	res = aop ^ bop
	SETNZ8(res)
	CLV()
	accum.PutB(res)
}
func bit() {
	var aop, bop, res byte
	da_inst("bit", CondS(0 != (ireg&0x40), "b", "a"), 2)
	accum := AOrB(ireg & 0x40)
	aop = (accum.GetB())
	bop = (eaddr8().GetB())
	res = aop & bop
	SETNZ8(res)
	CLV()
}

func ld() {
	da_inst("ld", CondS(0 != (ireg&0x40), "b", "a"), 2)
	accum := AOrB(ireg & 0x40)
	res := eaddr8().GetB()
	SETNZ8(res)
	CLV()
	accum.PutB(res)
}

func st() {
	da_inst("st", CondS(0 != (ireg&0x40), "b", "a"), 2)
	accum := AOrB(ireg & 0x40)
	res := accum.GetB()
	eaddr8().PutB(res)
	SETNZ8(res)
	CLV()
}

func jsr() {
	da_inst("jsr", "", 5)
	da_len = -pcreg
	w := eaddr8()
	da_len += pcreg + 1
	PushWord(pcreg)
	pcreg = word(w)
}

func bsr() {
	b := ImmByte()
	da_inst("bsr", "", 7)
	da_len = 2
	PushWord(pcreg)
	pcreg += Signed(b)
	off := F("$%04x", pcreg&0xffff)
	da_ops(off, "", 0)
}

func neg() {
	var a, r word

	{
		t := W(pcreg)
		if t == 0 {
			log.Panicf("Executing 0000 instruction at pcreg=%04x", pcreg-1)
		}
	}

	a = 0
	da_inst("neg", "", 4)
	ea := eaddr0()
	a = word(ea.GetB())
	r = -a
	SETSTATUS(0, byte(a), r)
	ea.PutB(byte(r))
}

func com() {
	da_inst("com", "", 4)
	ea := eaddr0()
	r := ^(ea.GetB())
	SETNZ8(r)
	SEC()
	CLV()
	ea.PutB(r)
}

func lsr() {
	da_inst("lsr", "", 4)
	ea := eaddr0()
	r := ea.GetB()
	if (r & 0x01) != 0 {
		SEC()
	} else {
		CLC()
	}
	if (r & 0x10) != 0 {
		SEH()
	} else {
		CLH()
	}
	r >>= 1
	SETNZ8(r)
	ea.PutB(r)
}

func ror() {
	c := (ccreg & 0x01) << 7
	da_inst("ror", "", 4)
	ea := eaddr0()
	r := ea.GetB()
	if (r & 0x01) != 0 {
		SEC()
	} else {
		CLC()
	}
	r = (r >> 1) + c
	SETNZ8(r)
	ea.PutB(r)
}

func asr() {
	da_inst("asr", "", 4)
	ea := eaddr0()
	r := ea.GetB()
	if (r & 0x01) != 0 {
		SEC()
	} else {
		CLC()
	}
	if (r & 0x10) != 0 {
		SEH()
	} else {
		CLH()
	}
	r >>= 1
	if (r & 0x40) != 0 {
		r |= 0x80
	}
	SETNZ8(r)
	ea.PutB(r)
}

func asl() {
	var a, r word

	da_inst("asl", "", 4)
	ea := eaddr0()
	a = word(ea.GetB())
	r = a << 1
	SETSTATUS(byte(a), byte(a), r)
	ea.PutB(byte(r))
}

func rol() {
	c := (ccreg & 0x01)
	da_inst("rol", "", 4)
	ea := eaddr0()
	r := ea.GetB()
	if (r & 0x80) != 0 {
		SEC()
	} else {
		CLC()
	}
	if ((r & 0x80) ^ ((r << 1) & 0x80)) != 0 {
		SEV()
	} else {
		CLV()
	}
	r = (r << 1) + c
	SETNZ8(r)
	ea.PutB(r)
}

func inc() {
	da_inst("inc", "", 4)
	ea := eaddr0()
	r := ea.GetB()
	r++
	if r == 0x80 {
		SEV()
	} else {
		CLV()
	}
	SETNZ8(r)
	ea.PutB(r)
}

func dec() {
	da_inst("dec", "", 4)
	ea := eaddr0()
	r := ea.GetB()
	r--
	if r == 0x7f {
		SEV()
	} else {
		CLV()
	}
	SETNZ8(r)
	ea.PutB(r)
}

func tst() {
	da_inst("tst", "", 4)
	ea := eaddr0()
	r := ea.GetB()
	SETNZ8(r)
	CLV()
}

func jmp() {
	da_len = -pcreg
	da_inst("jmp", "", 1)
	ea := eaddr0()
	da_len += pcreg + 1
	pcreg = word(ea)
}

func clr() {
	da_inst("clr", "", 4)
	ea := eaddr0()
	ea.PutB(0)
	CLN()
	CLV()
	SEZ()
	CLC()
}

func flag0() {
	if iflag != 0 { // in case flag already set by previous flag instr don't recurse //
		pcreg--
		return
	}
	iflag = 1
	ireg = B(pcreg)
	pcreg++
	da_inst("", "", 1)
	(Instrtable[ireg])()
	iflag = 0
}

func flag1() {
	if iflag != 0 { // in case flag already set by previous flag instr don't recurse //
		pcreg--
		return
	}
	iflag = 2
	ireg = B(pcreg)
	pcreg++
	da_inst("", "", 1)
	(Instrtable[ireg])()
	iflag = 0
}

func nop() {
	da_inst("nop", "", 2)
}

func sync_inst() {
	L("sync_inst")
	Waiting = true
}

func cwai() {
	b := B(pcreg) // Immediate operand //
	ccreg &= b
	pcreg++

	L("HEY, Waiting, cwai #$%02x.", b)
	Waiting = true

	da_inst("cwai", "", 20)
	off := F("#$%02x", b)
	da_ops(off, "", 0)
}

func lbra() {
	w := ImmWord()
	pcreg += w
	da_len = 3
	da_inst("lbra", "", 5)
	off := F("$%04x", pcreg&0xffff)
	da_ops(off, "", 0)
}

func lbsr() {
	da_len = 3
	da_inst("lbsr", "", 9)
	w := ImmWord()
	PushWord(pcreg)
	pcreg += w
	off := F("$%04x", pcreg)
	da_ops(off, "", 0)
}

func daa() {
	var a word
	da_inst("daa", "", 2)
	a = word(GetAReg())
	if (ccreg & 0x20) != 0 {
		a += 6
	}
	if (a & 0x0f) > 9 {
		a += 6
	}
	if (ccreg & 0x01) != 0 {
		a += 0x60
	}
	if (a & 0xf0) > 0x90 {
		a += 0x60
	}
	if (a & 0x100) != 0 {
		SEC()
	}
	PutAReg(byte(a))
}

func orcc() {
	b := ImmByte()
	off := F("#$%02x", b)
	da_inst("orcc", "", 3)
	da_ops(off, "", 0)
	ccreg |= b
}

func andcc() {
	b := ImmByte()
	off := F("#$%02x", b)
	da_inst("andcc", "", 3)
	da_ops(off, "", 0)
	ccreg &= b
}

func mul() {
	w := word(GetAReg()) * word(GetBReg())
	da_inst("mul", "", 11)
	if (w) != 0 {
		CLZ()
	} else {
		SEZ()
	}
	if (w & 0x80) != 0 {
		SEC()
	} else {
		CLC()
	}
	dreg = (w)
}

func sex() {
	da_inst("sex", "", 2)
	w := Signed(GetBReg())
	SETNZ16(w)
	dreg = (w)
}

func abx() {
	da_inst("abx", "", 3)
	xreg += word(GetBReg())
}

func rts() {
	da_inst("rts", "", 5)
	da_len = 1
	PullWord(&pcreg)
}

func rti() {
	var buf bytes.Buffer
	for i := word(0); i < 20; i++ {
		Z(&buf, "%02x ", B(sreg+i))
	}
	L("pre-rti stack: %s", buf.String())

	entire := ccreg & CC_ENTIRE
	if entire == 0 {
		da_inst("rti", "", 6)
	} else {
		da_inst("rti", "", 15)
	}
	da_len = 1
	PullByte(&ccreg)
	if entire != 0 {
		PullWord(&dreg)
		PullByte(&dpreg)
		PullWord(&xreg)
		PullWord(&yreg)
		PullWord(&ureg)
	}
	PullWord(&pcreg)
}

func DumpAllMemory() {
	var i, j int
	var buf bytes.Buffer
	L("\n#DumpAllMemory(\n")
	for i = 0; i < 0x10000; i += 32 {
		buf.Reset()
		Z(&buf, "%04x: ", i)

		// Look ahead for something interesting on this line.
		something := false
		for j = 0; j < 32; j++ {
			x := PeekB(word(i + j))
			if x != 0 && x != ' ' {
				something = true
				break
			}
		}

		if !something {
			continue
		}

		for j = 0; j < 32; j += 8 {
			Z(&buf,
				"%02x%02x %02x%02x %02x%02x %02x%02x  ",
				PeekB(word(i+j+0)), PeekB(word(i+j+1)), PeekB(word(i+j+2)), PeekB(word(i+j+3)),
				PeekB(word(i+j+4)), PeekB(word(i+j+5)), PeekB(word(i+j+6)), PeekB(word(i+j+7)))
		}
		buf.WriteRune(' ')
		for j = 0; j < 32; j++ {
			ch := PeekB(word(i + j))
			var r rune = '.'
			if ' ' <= ch && ch <= '~' {
				r = rune(ch)
			}
			buf.WriteRune(r)
		}
		L("%s\n", buf.String())
	}
	L("#DumpAllMemory)\n")
}

func DumpPageZero() {
	L("PageZero: FreeBitMap=%x:%x MemoryLimit=%x ModDir=%x RomBase=%x\n",
		W(D_FMBM), W(D_FMBM+2), W(D_MLIM), W(D_ModDir), W(D_Init))
	L("  D_SWI3=%x D_SWI2=%x FIRQ=%x IRQ=%x SWI=%x NMI=%x SvcIRQ=%x Poll=%x\n",
		W(D_SWI3), W(D_SWI2), W(D_FIRQ), W(D_IRQ), W(D_SWI), W(D_NMI), W(D_SvcIRQ), W(D_Poll))
	L("  BTLO=%x BTHI=%x  IO Free Mem Lo=%x Hi=%x D_DevTbl=%x D_PolTbl=%x D_PthDBT=%x D_Proc=%x\n",
		W(D_BTLO), W(D_BTHI), W(D_IOML), W(D_IOMH), W(D_DevTbl), W(D_PolTbl), W(D_PthDBT), W(D_Proc))
	L("  D_Slice=%x D_TSlice=%x\n",
		W(D_Slice), W(D_TSlice))
}

func DumpPathDesc(a word) {
	if 0 == B(a+PD_PD) {
		return
	}
	L("Path @%x: #=%x mode=%x count=%x dev=%x\n", a, B(a+PD_PD), B(a+PD_MOD), B(a+PD_CNT), W(a+PD_DEV))
	L("   curr_process=%x caller_reg_stack=%x buffer=%x  dev_type=%x\n",
		B(a+PD_CPR), B(a+PD_RGS), B(a+PD_BUF), B(a+PD_DTP))

	// the Device Table Entry:
	dev := W(a + PD_DEV)
	var buf bytes.Buffer
	Z(&buf, "   dev: @%x driver_mod=%x=%s ",
		dev, W(dev+V_DRIV), ModuleName(W(dev+V_DRIV)))
	Z(&buf, "driver_static_store=%x descriptor_mod=%x=%s ",
		W(dev+V_STAT), W(dev+V_DESC), ModuleName(W(dev+V_DESC)))
	Z(&buf, "file_man=%x=%s use=%d\n",
		W(dev+V_FMGR), ModuleName(W(dev+V_FMGR)), B(dev+V_USRS))
	L("%s", buf.String())

	if paranoid {
		if B(a+PD_PD) > 10 {
			panic("PD_PD")
		}
		if B(a+PD_CNT) > 20 {
			panic("PD_CNT")
		}
		if B(a+PD_CPR) > 10 {
			panic("PD_CPR")
		}
	}
}

func DumpAllPathDescs() {
	p := W(D_PthDBT)
	if 0 == p {
		return
	}

	for i := word(0); i < 32; i++ {
		q := W(p + i*2)
		if q != 0 {

			for j := word(0); j < 4; j++ {
				k := i*4 + j
				if k == 0 {
					continue
				} // There is no path desc 0 (it's the table).
				DumpPathDesc(q + j*64)
			}

		}
	}
}

func DumpProcDesc(a word) {
	mod := W(a + P_PModul)
	name := mod + W(mod+4)
	L("Process @%x: id=%x pid=%x sid=%x cid=%x module='%s'", a, B(a+P_ID), B(a+P_PID), B(a+P_SID), B(a+P_CID), Os9String(name))
	L("   sp=%x chap=%x Addr=%x PagCnt=%x User=%x Pri=%x Age=%x State=%x",
		W(a+P_SP), B(a+P_CHAP), B(a+P_ADDR), B(a+P_PagCnt), W(a+P_User), B(a+P_Prior), B(a+P_Age), B(a+P_State))
	L("   Queue=%x IOQP=%x IOQN=%x Signal=%x SigVec=%x SigDat=%x",
		W(a+P_Queue), B(a+P_IOQP), B(a+P_IOQN), B(a+P_Signal), B(a+P_SigVec), B(a+P_SigDat))
	L("   DIO %x %x %x %x %x %x PATH %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x",
		W(a+P_DIO), W(a+P_DIO+2), W(a+P_DIO+4),
		W(a+P_DIO+6), W(a+P_DIO+8), W(a+P_DIO+10),
		B(a+P_PATH+0), B(a+P_PATH+1), B(a+P_PATH+2), B(a+P_PATH+3),
		B(a+P_PATH+4), B(a+P_PATH+5), B(a+P_PATH+6), B(a+P_PATH+7),
		B(a+P_PATH+8), B(a+P_PATH+9), B(a+P_PATH+10), B(a+P_PATH+11),
		B(a+P_PATH+12), B(a+P_PATH+13), B(a+P_PATH+14), B(a+P_PATH+15))
	if W(a+P_Queue) != 0 {
		// If current proc, it has no queue.
		// Other procs are in a queue.
		if W(D_Proc) != a {
			DumpProcDesc(W(a + P_Queue))
		}
	}

	if paranoid {
		if B(a+P_ID) > 10 {
			panic("P_ID")
		}
		if B(a+P_PID) > 10 {
			panic("P_PID")
		}
		if B(a+P_SID) > 10 {
			panic("P_SID")
		}
		if B(a+P_CID) > 10 {
			panic("P_CID")
		}
		if W(a+P_User) > 10 {
			panic("P_User")
		}
		for i := word(0); i < 10; i++ {
			if B(a+P_PATH+i) > 10 {
				panic(i)
			}
		}
	}
}

func DumpProcesses() {
	if W(D_Proc) != 0 {
		L("D_Proc: CURRENT:")
		DumpProcDesc(W(D_Proc))
	}
	if W(D_AProcQ) != 0 {
		L("D_AProcQ: Active:")
		DumpProcDesc(W(D_AProcQ))
	}
	if W(D_WProcQ) != 0 {
		L("D_WProcQ: Wait:")
		DumpProcDesc(W(D_WProcQ))
	}
	if W(D_SProcQ) != 0 {
		L("D_SProcQ: Sleep")
		DumpProcDesc(W(D_SProcQ))
	}
}

func Os9AllMemoryModules() {
	// Level 1:
	start := W(0x26)
	limit := W(0x28)
	if Level == 2 {
		start = W(0x44)
		limit = W(0x46)
	}
	i := start
	// DumpAllMemory();
	t := TraceMem
	TraceMem = false
	defer func() { TraceMem = t }()
	DumpAllMemory()
	DumpPageZero()
	DumpProcesses()
	DumpAllPathDescs()
	L("\n#Os9AllMemoryModules(")
	var buf bytes.Buffer
	for ; i < limit; i += 4 {
		mod := W(i)
		if mod != 0 {
			end := mod + W(mod+2)
			name := mod + W(mod+4)
			Z(&buf, "%x:%x:<%s> ", mod, end, Os9String(name))
		}
	}
	L("%s", buf.String())
	L("#Os9AllMemoryModules)")
}

var swi_name = []string{"swi", "swi2", "swi3"}

func swi() {
	swi_num := iflag + 1 // 1, 2, or 3 for SWI, SWI2, or SWI3.

	da_inst(swi_name[iflag], "", 5)
	da_len = 3 /* Often an extra byte after the SWI opcode */

	ccreg |= 0x80
	PushWord(pcreg)
	PushWord(ureg)
	PushWord(yreg)
	PushWord(xreg)
	PushByte(dpreg)
	PushWord(dreg)
	PushByte(ccreg)

	var handler word
	switch swi_num {
	case 1: /* SWI */
		ccreg |= 0xd0
		handler = W(0xfffa)
	case 2: /* SWI2 */
		// assert(GETBYTE(pcreg+0) == 0x3F);
		// fprintf(stderr, "pcreg=%x\n", pcreg);
		DecodeOs9Opcode(B(pcreg))

		handler = W(0xfff4)
	case 3: /* SWI3 */
		handler = W(0xfff2)
	default:
		log.Panicf("bad swi_num: %d", swi_num)
	}
	if paranoid {
		if handler < 256 {
			log.Panicf("FATAL: Attempted SWI%d with small handler: 0x%04x", handler)
		}
		if handler >= 0xFF00 {
			log.Panicf("FATAL: Attempted SWI%d with large handler: 0x%04x", handler)
		}
	}
	pcreg = handler
}

/*
word *wordregs[]={(word*)d_reg,&xreg,&yreg,&ureg,&sreg,&pcreg,&wfillreg,&wfillreg};

#if CPU_BIG_ENDIAN
byte *byteregs[]={d_reg,d_reg+1,&ccreg,&dpreg,&fillreg,&fillreg,&fillreg,&fillreg};
#else
byte *byteregs[]={d_reg+1,d_reg,&ccreg,&dpreg,&fillreg,&fillreg,&fillreg,&fillreg};
#endif
*/

func tfr() {
	da_inst("tfr", "", 7)
	b := ImmByte()
	da_reg(b)
	src := TfrReg(15 & (b >> 4))
	dst := TfrReg(15 & b)
	if (src & 8) != (dst & 8) {
		log.Panicf("tfr with inconsistent sizes; src=%d dst=%d", src, dst)
	}
	if (src & 8) == 0 {
		// 16 bit
		dst.PutW(src.GetW())
	} else {
		// 8 bit
		dst.PutB(src.GetB())
	}
}

func exg() {
	da_inst("exg", "", 8)
	b := ImmByte()
	da_reg(b)
	r1 := TfrReg(15 & (b >> 4))
	r2 := TfrReg(15 & b)
	if (b & 0x80) == 0 {
		// 16 bit
		t1, t2 := r1.GetW(), r2.GetW()
		r1.PutW(t2)
		r2.PutW(t1)
	} else {
		// 8 bit
		t1, t2 := r1.GetB(), r2.GetB()
		r1.PutB(t2)
		r2.PutB(t1)
	}
}

func br(f bool) {
	var dest word

	if 0 == iflag {
		b := ImmByte()
		dest = pcreg + Signed(b)
		if f {
			pcreg += Signed(b)
		}
		da_len = 2
	} else {
		w := ImmWord()
		dest = pcreg + w
		if f {
			pcreg += w
		}
		da_len = 3
	}
	off := F("$%04x", dest&0xffff)
	da_ops(off, "", 0)
}

func NXORV() bool {
	return ((ccreg & 0x08) ^ (ccreg & 0x02)) != 0
}
func IFLAG() bool {
	return iflag != 0
}

func bra() {
	da_inst(CondS(IFLAG(), "l", ""), "bra", CondI(IFLAG(), 5, 3))
	br(true)
}

func brn() {
	da_inst(CondS(IFLAG(), "l", ""), "brn", CondI(IFLAG(), 5, 3))
	br(false)
}

func bhi() {
	da_inst(CondS(IFLAG(), "l", ""), "bhi", CondI(IFLAG(), 5, 3))
	br(0 == (ccreg & 0x05))
}

func bls() {
	da_inst(CondS(IFLAG(), "l", ""), "bls", CondI(IFLAG(), 5, 3))
	br(0 != ccreg&0x05)
}

func bcc() {
	da_inst(CondS(IFLAG(), "l", ""), "bcc", CondI(IFLAG(), 5, 3))
	br(0 == (ccreg & 0x01))
}

func bcs() {
	da_inst(CondS(IFLAG(), "l", ""), "bcs", CondI(IFLAG(), 5, 3))
	br(0 != ccreg&0x01)
}

func bne() {
	da_inst(CondS(IFLAG(), "l", ""), "bne", CondI(IFLAG(), 5, 3))
	br(0 == (ccreg & 0x04))
}

func beq() {
	da_inst(CondS(IFLAG(), "l", ""), "beq", CondI(IFLAG(), 5, 3))
	br(0 != ccreg&0x04)
}

func bvc() {
	da_inst(CondS(IFLAG(), "l", ""), "bvc", CondI(IFLAG(), 5, 3))
	br(0 == (ccreg & 0x02))
}

func bvs() {
	da_inst(CondS(IFLAG(), "l", ""), "bvs", CondI(IFLAG(), 5, 3))
	br(0 != ccreg&0x02)
}

func bpl() {
	da_inst(CondS(IFLAG(), "l", ""), "bpl", CondI(IFLAG(), 5, 3))
	br(0 == (ccreg & 0x08))
}

func bmi() {
	da_inst(CondS(IFLAG(), "l", ""), "bmi", CondI(IFLAG(), 5, 3))
	br(0 != ccreg&0x08)
}

func bge() {
	da_inst(CondS(IFLAG(), "l", ""), "bge", CondI(IFLAG(), 5, 3))
	br(!NXORV())
}

func blt() {
	da_inst(CondS(IFLAG(), "l", ""), "blt", CondI(IFLAG(), 5, 3))
	br(NXORV())
}

func bgt() {
	da_inst(CondS(IFLAG(), "l", ""), "bgt", CondI(IFLAG(), 5, 3))
	br(!(NXORV() || 0 != ccreg&0x04))
}

func ble() {
	da_inst(CondS(IFLAG(), "l", ""), "ble", CondI(IFLAG(), 5, 3))
	br(NXORV() || 0 != ccreg&0x04)
}

func leax() {
	da_inst("leax", "", 4)
	w := word(postbyte())
	if w != 0 {
		CLZ()
	} else {
		SEZ()
	}
	xreg = w
}

func leay() {
	da_inst("leay", "", 4)
	w := word(postbyte())
	if w != 0 {
		CLZ()
	} else {
		SEZ()
	}
	yreg = w
}

func leau() {
	da_inst("leau", "", 4)
	ureg = word(postbyte())
}

func leas() {
	da_inst("leas", "", 4)
	sreg = word(postbyte())
}

var reg_for_bit_count = []string{"pc", "u", "y", "x", "dp", "b", "a", "cc"}

func bit_count(b byte) int {
	var mask byte = 0x80
	count := 0
	for i := 0; i <= 7; i++ {
		if (b & mask) != 0 {
			count++
			da_ops(CondS(count > 1, ",", ""),
				reg_for_bit_count[i],
				1+CondI(i < 4, 1, 0))
		}
		mask >>= 1
	}
	return count
}

func pshs() {
	b := ImmByte()
	da_inst("pshs", "", 5)
	bit_count(b)
	if (b & 0x80) != 0 {
		PushWord(pcreg)
	}
	if (b & 0x40) != 0 {
		PushWord(ureg)
	}
	if (b & 0x20) != 0 {
		PushWord(yreg)
	}
	if (b & 0x10) != 0 {
		PushWord(xreg)
	}
	if (b & 0x08) != 0 {
		PushByte(dpreg)
	}
	if (b & 0x04) != 0 {
		PushByte(GetBReg())
	}
	if (b & 0x02) != 0 {
		PushByte(GetAReg())
	}
	if (b & 0x01) != 0 {
		PushByte(ccreg)
	}
}

func puls() {
	b := ImmByte()
	da_inst("puls", "", 5)
	da_len = 2
	bit_count(b)
	if (b & 0x01) != 0 {
		PullByte(&ccreg)
	}
	if (b & 0x02) != 0 {
		var t byte
		PullByte(&t)
		PutAReg(t)
	}
	if (b & 0x04) != 0 {
		var t byte
		PullByte(&t)
		PutBReg(t)
	}
	if (b & 0x08) != 0 {
		PullByte(&dpreg)
	}
	if (b & 0x10) != 0 {
		PullWord(&xreg)
	}
	if (b & 0x20) != 0 {
		PullWord(&yreg)
	}
	if (b & 0x40) != 0 {
		PullWord(&ureg)
	}
	if (b & 0x80) != 0 {
		PullWord(&pcreg)
	}
}

func pshu() {
	b := ImmByte()
	da_inst("pshu", "", 5)
	bit_count(b)
	if (b & 0x80) != 0 {
		PushUWord(pcreg)
	}
	if (b & 0x40) != 0 {
		PushUWord(sreg)
	}
	if (b & 0x20) != 0 {
		PushUWord(yreg)
	}
	if (b & 0x10) != 0 {
		PushUWord(xreg)
	}
	if (b & 0x08) != 0 {
		PushUByte(dpreg)
	}
	if (b & 0x04) != 0 {
		PushUByte(GetBReg())
	}
	if (b & 0x02) != 0 {
		PushUByte(GetAReg())
	}
	if (b & 0x01) != 0 {
		PushUByte(ccreg)
	}
}

func pulu() {
	b := ImmByte()
	da_inst("pulu", "", 5)
	da_len = 2
	bit_count(b)
	if (b & 0x01) != 0 {
		PullUByte(&ccreg)
	}
	if (b & 0x02) != 0 {
		var t byte
		PullUByte(&t)
		PutAReg(t)
	}
	if (b & 0x04) != 0 {
		var t byte
		PullUByte(&t)
		PutBReg(t)
	}
	if (b & 0x08) != 0 {
		PullUByte(&dpreg)
	}
	if (b & 0x10) != 0 {
		PullUWord(&xreg)
	}
	if (b & 0x20) != 0 {
		PullUWord(&yreg)
	}
	if (b & 0x40) != 0 {
		PullUWord(&sreg)
	}
	if (b & 0x80) != 0 {
		PullUWord(&pcreg)
	}
}

func SETSTATUSD(a, b, res uint32) {
	if (res & 0x10000) != 0 {
		SEC()
	} else {
		CLC()
	}
	if (((res >> 1) ^ a ^ b ^ res) & 0x8000) != 0 {
		SEV()
	} else {
		CLV()
	}
	SETNZ16(word(res))
}

func addd() {
	var aop, bop, res uint32
	da_inst("addd", "", 5)
	aop = uint32(dreg)
	ea := eaddr16()
	bop = uint32(ea.GetW())
	res = aop + bop
	SETSTATUSD(aop, bop, res)
	dreg = word(res)
}

func subd() {
	var aop, bop, res uint32
	if iflag != 0 {
		da_inst("cmpd", "", 5)
	} else {
		da_inst("subd", "", 5)
	}
	if iflag == 2 {
		aop = uint32(ureg)
		da_inst("cmpu", "", 5)
	} else {
		aop = uint32(dreg)
	}
	ea := eaddr16()
	bop = uint32(ea.GetW())
	res = aop - bop
	SETSTATUSD(aop, bop, res)
	if iflag == 0 {
		dreg = word(res)
	}
}

func cmpx() {
	var aop, bop, res uint32
	switch iflag {
	case 0:
		da_inst("cmpx", "", 5)
		aop = uint32(xreg)
	case 1:
		da_inst("cmpy", "", 5)
		aop = uint32(yreg)
	case 2:
		da_inst("cmps", "", 5)
		aop = uint32(sreg)
	}
	ea := eaddr16()
	bop = uint32(ea.GetW())
	res = aop - bop
	SETSTATUSD(aop, bop, res)
}

func ldd() {
	da_inst("ldd", "", 4)
	ea := eaddr16()
	w := ea.GetW()
	SETNZ16(w)
	dreg = w
}

func ldx() {
	if iflag != 0 {
		da_inst("ldy", "", 4)
	} else {
		da_inst("ldx", "", 4)
	}
	ea := eaddr16()
	w := ea.GetW()
	SETNZ16(w)
	if iflag == 0 {
		xreg = w
	} else {
		yreg = w
	}
}

func ldu() {
	if iflag != 0 {
		da_inst("lds", "", 4)
	} else {
		da_inst("ldu", "", 4)
	}
	ea := eaddr16()
	w := ea.GetW()
	SETNZ16(w)
	if iflag == 0 {
		ureg = w
	} else {
		sreg = w
	}
}

func std() {
	da_inst("std", "", 4)
	ea := eaddr16()
	w := dreg
	SETNZ16(w)
	ea.PutW(w)
}

func stx() {
	if iflag != 0 {
		da_inst("sty", "", 4)
	} else {
		da_inst("stx", "", 4)
	}
	ea := eaddr16()
	var w word
	if iflag == 0 {
		w = xreg
	} else {
		w = yreg
	}
	SETNZ16(w)
	ea.PutW(w)
}

func stu() {
	if iflag != 0 {
		da_inst("sts", "", 4)
	} else {
		da_inst("stu", "", 4)
	}
	ea := eaddr16()
	var w word
	if iflag == 0 {
		w = ureg
	} else {
		w = sreg
	}
	SETNZ16(w)
	ea.PutW(w)
}

func dump() {
	err := ioutil.WriteFile("dump.mem", mem[:], 0644)
	if err != nil {
		log.Panicf("cannot write image file: %q", "dump.mem")
	}
}

func to_bin(b byte) string {
	var buf bytes.Buffer
	big := "EFHINZVC"    // bits that are set.
	little := "efhinzvc" // bits that are clear.
	i := 0
	for bm := byte(0x80); bm > 0; bm >>= 1 {
		if b&bm != 0 {
			buf.WriteByte(big[i])
		} else {
			buf.WriteByte(little[i])
		}
		i++
	}

	return buf.String()
}

/* max. bytes of instruction code per trace line */
const I_MAX = 4

func where(addr word) string {
	var buf bytes.Buffer

	start := W(0x26)
	limit := W(0x28)

	for i := start; i < limit; i += 4 {
		mod := W(i)
		if mod != 0 {
			size := W(mod + 2)
			if mod < addr && addr < mod+size {
				cp := mod + W(mod+4)
				for {
					b := B(cp)
					ch := 127 & b
					if '!' <= ch && ch <= '~' {
						buf.WriteByte(ch)
					}
					if (b & 128) != 0 {
						Z(&buf, ",%04x ", addr-mod)
						return buf.String()
					}
					cp++
				}
			}
		}
	}
	return "? "
}

var been_there [0x10000]bool

func trace() {
	var buf bytes.Buffer
	save_pcreg_prev := pcreg_prev
	wh := where(save_pcreg_prev)
	oldnew := CondI(been_there[pcreg_prev], 'o', 'N')
	Z(&buf, "%s%c %04x ", wh, oldnew, pcreg_prev)
	been_there[pcreg_prev] = true

	var ilen int
	if da_len != 0 {
		ilen = int(da_len)
	} else {
		ilen = int(pcreg - pcreg_prev)
		if ilen < 0 {
			ilen = -ilen
		}
	}
	for i := word(0); i < I_MAX; i++ {
		if int(i) < ilen {
			Z(&buf, "%02x", B(pcreg_prev+i))
		} else {
			Z(&buf, "  ")
		}
	}
	Z(&buf, " %-5s %-17s [%02d] ", dinst.String(), dops.String(), cycles)
	Z(&buf, "x=%04x y=%04x u=%04x s=%04x a=%02x b=%02x cc=%s dp=%02x",
		xreg, yreg, ureg, sreg, GetAReg(), GetBReg(), to_bin(ccreg), dpreg)
	Z(&buf, ", s: %04x %04x, #%d",
		word(B(sreg))<<8|word(B(sreg+1)),
		word(B(sreg+2))<<8|word(B(sreg+3)),
		steps)
	log.Printf("%s", buf.String())
	da_len = 0
}

func Finish() {
	L("")
	L("Cycles: %d", cycles_sum)
	dump()
	/*
	    cr();
	    fprintf(stderr,"Cycles: %lu", cycles_sum);
	    cr();
	   #if defined(TERM_CONTROL) && ! defined(TRACE)
	    ///////////// system("stty -raw -nl echo brkint");
	    fcntl(0,F_SETFL,tflags&~O_NDELAY);
	   #endif
	    if (fdump) dump();
	    exit(0);
	*/
}

// STOP
func init() {
	Instrtable = []func(){
		neg, ill, ill, com, lsr, ill, ror, asr,
		asl, rol, dec, ill, inc, tst, jmp, clr,
		flag0, flag1, nop, sync_inst, ill, ill, lbra, lbsr,
		ill, daa, orcc, ill, andcc, sex, exg, tfr,
		bra, brn, bhi, bls, bcc, bcs, bne, beq,
		bvc, bvs, bpl, bmi, bge, blt, bgt, ble,
		leax, leay, leas, leau, pshs, puls, pshu, pulu,
		ill, rts, abx, rti, cwai, mul, ill, swi,
		neg, ill, ill, com, lsr, ill, ror, asr,
		asl, rol, dec, ill, inc, tst, ill, clr,
		neg, ill, ill, com, lsr, ill, ror, asr,
		asl, rol, dec, ill, inc, tst, ill, clr,
		neg, ill, ill, com, lsr, ill, ror, asr,
		asl, rol, dec, ill, inc, tst, jmp, clr,
		neg, ill, ill, com, lsr, ill, ror, asr,
		asl, rol, dec, ill, inc, tst, jmp, clr,
		sub, cmp, sbc, subd, and, bit, ld, st,
		eor, adc, or, add, cmpx, bsr, ldx, stx,
		sub, cmp, sbc, subd, and, bit, ld, st,
		eor, adc, or, add, cmpx, jsr, ldx, stx,
		sub, cmp, sbc, subd, and, bit, ld, st,
		eor, adc, or, add, cmpx, jsr, ldx, stx,
		sub, cmp, sbc, subd, and, bit, ld, st,
		eor, adc, or, add, cmpx, jsr, ldx, stx,
		sub, cmp, sbc, addd, and, bit, ld, st,
		eor, adc, or, add, ldd, std, ldu, stu,
		sub, cmp, sbc, addd, and, bit, ld, st,
		eor, adc, or, add, ldd, std, ldu, stu,
		sub, cmp, sbc, addd, and, bit, ld, st,
		eor, adc, or, add, ldd, std, ldu, stu,
		sub, cmp, sbc, addd, and, bit, ld, st,
		eor, adc, or, add, ldd, std, ldu, stu,
	}
}

type Config struct {
	DiskImageFilename string
	BootImageFilename string
	Level             int
	MaxSteps          int64
	TraceAfter        int64
	Keystrokes        <-chan byte
}

var tracing bool

func Main(cf *Config) {
	fd, err := os.OpenFile(cf.DiskImageFilename, os.O_RDWR, 0644)
	if err != nil {
		log.Fatalf("Cannot open disk image: %q: %v", cf.DiskImageFilename, err)
	}
	disk_fd = fd

	boot, err := ioutil.ReadFile(cf.BootImageFilename)
	if err != nil {
		log.Fatalf("Cannot read boot image: %q: %v", cf.BootImageFilename, err)
	}
	copy(mem[MmuDefaultStartAddr+0x100:], boot)
	defer Finish()

	pcreg = 0x100
	sreg = 0
	dpreg = 0
	iflag = 0

	da_len = 0
	cycles_sum = 0

	Level = cf.Level
	switch Level {
	case 1:
		if PeekB(0xFFFC) != 0x01 {
			log.Fatalf("Level is 2, but PeekB(0xFFFC) != 0x01")
		}
		InitLevel1()
	case 2:
		if PeekB(0xFFFC) != 0xFE {
			log.Fatalf("Level is 2, but PeekB(0xFFFC) != 0xFE")
		}
		InitLevel2()
	default:
		log.Fatalf("Unknown level: %d", Level)
	}

	maxsteps := cf.MaxSteps
	traceAfter := cf.TraceAfter
	for steps = 0; maxsteps == 0 || steps < maxsteps; steps++ {
		pcreg_prev = pcreg

		cp := &Os9SysCallCompletion[pcreg]
		if cp.callback != nil {
			cp.callback(cp)
			cp.callback = nil
			if TraceMem {
				DumpAllMemory()
			}
		}
		if steps%IRQ_FREQ == IRQ_FREQ-1 {
			irqs_pending |= IRQ_PENDING
			Waiting = false
		}

		if Waiting {
			continue
		}

		if (irqs_pending) != 0 {
			if (irqs_pending & NMI_PENDING) != 0 {
				nmi()
				continue
			}
			if (irqs_pending&IRQ_PENDING) != 0 && !(ccreg&CC_INHIBIT_IRQ != 0) {

				irq(cf.Keystrokes)
				continue
			}
		}

		// Take one step.
		cycles = 0
		TraceMem = tracing
		ireg = B(pcreg)
		pcreg++
		(Instrtable[ireg])() /* process instruction */
		TraceMem = false
		cycles_sum += int64(cycles)

		if tracing || traceAfter > 0 && steps >= traceAfter {
			tracing = true
			trace()
		}

		if paranoid && steps > 100000 {
			if pcreg < 0x005E /* D.BtDbg */ {
				log.Panicf("PC in page 0: 0x%x", pcreg)
			}
			if pcreg >= 0xFF00 {
				log.Panicf("PC in page FF: 0x%x", pcreg)
			}
			if pcreg >= 0x0140 && pcreg < 0x04FF {
				log.Panicf("PC in sys data: 0x%x", pcreg)
			}
			if sreg < 256 {
				log.Panicf("S in page 0: 0x%x", sreg)
			}
			if sreg >= 0xFF00 {
				log.Panicf("S in page FF: 0x%x", sreg)
			}
			if sreg >= 0x0140 && sreg < 0x0400 {
				log.Panicf("S in sys data: 0x%x", sreg)
			}
		}
	} /* next step */

	L("FINISHED %d STEPS", steps)
}
