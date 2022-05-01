package emu

// See credits.go

import (
	"github.com/strickyak/doing_os9/gomar/display"
	"github.com/strickyak/doing_os9/gomar/sym"

	"bufio"
	"bytes"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"regexp"
	"strings"
)

var FlagBootImageFilename = flag.String("boot", "boot.mem", "")
var FlagDiskImageFilename = flag.String("disk", "../_disk_", "")
var FlagMaxSteps = flag.Uint64("max", 0, "")
var FlagClock = flag.Uint64("clock", 5*1000*1000, "")
var FlagSwiFatalCoreDump = flag.Bool("swi_fatal_coredump", false, "coredump and stop on plain SWI")

var FlagWatch = flag.String("watch", "", "Sequence of module:addr:reg:message,...")
var FlagTriggerPc = flag.Uint64("trigger_pc", 0xC00D, "")
var FlagTriggerOp = flag.Uint64("trigger_op", 0x17, "")
var FlagTraceOnOS9 = flag.String("trigger_os9", "", "")
var FlagRom = flag.String("rom", "", "filename of rom; write-protect above 0x8000")
var RegexpTraceOnOS9 *regexp.Regexp

type Watch struct {
	Where    string
	Register string
	Message  string
}

var Watches []*Watch

func CompileWatches() {
	for _, s := range strings.Split(*FlagWatch, ",") {
		if s != "" {
			v := strings.Split(s, ":")
			if len(v) != 3 {
				log.Fatalf("Watch was %q, split on colon, len was %d, want 3", v, len(v))
			}
			Watches = append(Watches, &Watch{
				Where:    v[0],
				Register: v[1],
				Message:  v[2],
			})
		}
	}
}

const IRQ_FREQ = (500 * 1000)

const paranoid = false // Do paranoid checks.
const hyp = true       // Use hyperviser code.

// F is for FORMAT (i.e. fmt.Sprintf)
func F(format string, args ...interface{}) string {
	return fmt.Sprintf(format, args...)
}

// L is for LOG (i.e. log.Printf)
func L(format string, args ...interface{}) {
	log.Printf(format, args...)
}

// Z is for Printf to Buffer (i.e. fmt.Fprintf)
func Z(w *bytes.Buffer, format string, args ...interface{}) {
	fmt.Fprintf(w, format, args...)
}

type Word uint16

// EA is Effective Address, which may be a Word or a special value for a register.
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

func FatalCoreDump() {
	const NAME = "/tmp/coredump09"
	fd, err := os.Create(NAME)
	if err != nil {
		log.Fatalf("cannot create %q: %v", NAME, err)
	}
	w := bufio.NewWriter(fd)
	for i := 0; i < 0x10000; i++ {
		w.WriteByte(EA(i).GetB())
	}
	for i := DRegEA; i <= PCRegEA; i++ {
		word := EA(i).GetW()
		w.WriteByte(byte(word >> 8))
		w.WriteByte(byte(word >> 0))
	}
	w.WriteByte(CCRegEA.GetB())
	w.WriteByte(DPRegEA.GetB())
	w.Flush()
	fd.Close()

	fmt.Printf("\nBegin Frame Chain\n")
	fp := EA(URegEA.GetW())
	p := EA(SRegEA.GetW())
	fmt.Printf("S: %04x  U: %04x\n", p, fp)
	gap := int(fp) - int(p)
	for 0 <= gap && gap <= 64 {
		fmt.Printf("\n@%04x: ", int(p))
		if p < fp && ((fp-p)&1) == 1 {
			fmt.Printf("%02x, ", EA(p).GetB())
			p += 1
		}
		for p < fp {
			fmt.Printf("%04x, ", EA(p).GetW())
			p += 2
		}
		if p != fp {
			fmt.Printf("\nMismatched: p %04x != fp %04x\n", p, fp)
			break
		}
		fp = EA(fp.GetW())
		gap = int(fp) - int(p)
	}
	fmt.Printf("\nEnd Frame Chain\n")

	log.Fatalf("EMULATOR CORE DUMPED: %q", NAME)
}

func TfrReg(b byte) EA {
	if 6 == b || b == 7 || b > 11 {
		log.Panicf("Bad TfrReg byte: 0x%x", b)
	}
	return DRegEA + EA(b)
}

var CocodChan chan *display.CocoDisplayParams
var Disp *display.Display

var fdump int
var Steps uint64
var DebugString string

var Os9Description = make(map[int]string) // Describes OS9 kernel call at this big stack addr.

/* 6809 registers */
var ccreg, dpreg byte
var xreg, yreg, ureg, sreg, pcreg Word
var dreg Word

var iflag byte /* flag to indicate prebyte $10 or $11 */
var ireg byte  /* Instruction register */
var pcreg_prev Word

var mem [0x40 * 0x2000]byte

var ixregs = []*Word{&xreg, &yreg, &ureg, &sreg}

var idx byte

/* disassembled instruction buffer */
var dinst bytes.Buffer

/* disassembled operand buffer */
var dops bytes.Buffer

/* instruction cycles */
var cycles int
var cycles_sum int64

var Waiting bool
var irqs_pending byte

var instructionTable []func()

// For using page 0 for system variables.
func SysMemW(a Word) Word {
	if a >= 0x2000 {
		log.Panicf("SysMemW: addr too big: %x", a)
	}
	return HiLo(mem[a], mem[a+1])
}
func SysMemB(a Word) byte {
	if a >= 0x2000 {
		log.Panicf("SysMemW: addr too big: %x", a)
	}
	return mem[a]
}

func GetAReg() byte  { return Hi(dreg) }
func GetBReg() byte  { return Lo(dreg) }
func PutAReg(x byte) { dreg = HiLo(x, Lo(dreg)) }
func PutBReg(x byte) { dreg = HiLo(Hi(dreg), x) }

//////////////////////////////////////////////////////////////

const NMI_PENDING = CC_ENTIRE /* borrow this bit */
const IRQ_PENDING = CC_INHIBIT_IRQ
const FIRQ_PENDING = CC_INHIBIT_FIRQ

const CC_INHIBIT_IRQ = 0x10
const CC_INHIBIT_FIRQ = 0x40
const CC_ENTIRE = 0x80

const VECTOR_IRQ = 0xFFF8
const VECTOR_FIRQ = 0xFFF6
const VECTOR_NMI = 0xFFFC

func Hi(a Word) byte {
	return byte(255 & (a >> 8))
}
func Lo(a Word) byte {
	return byte(255 & a)
}
func HiLo(hi, lo byte) Word {
	return (Word(hi) << 8) | Word(lo)
}
func HiMidLo(hi, mid, lo byte) uint {
	return (uint(hi) << 16) | (uint(mid) << 8) | uint(lo)
}

func SignExtend(a byte) Word {
	if (a & 0x80) != 0 {
		return 0xFF80 | Word(a)
	} else {
		return Word(a)
	}
}

// W is fundamental func to get Word.
func W(addr Word) Word {
	hi := B(addr)
	lo := B(addr + 1)
	return HiLo(hi, lo)
}

func PeekW(addr Word) Word {
	hi := PeekB(addr)
	lo := PeekB(addr + 1)
	return HiLo(hi, lo)
}

// PutW is fundamental func to set Word.
func PutW(addr, x Word) {
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
		return B(Word(addr))
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
		PutB(Word(addr), x)
	}
}

func (addr EA) RegPtrW() *Word {
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

func (addr EA) GetW() Word {
	if (addr & 0xFFFF0000) != 0 {
		p := addr.RegPtrW()
		return *p
	} else {
		return W(Word(addr))
	}
}

func (addr EA) PutW(x Word) {
	if (addr & 0xFFFF0000) != 0 {
		p := addr.RegPtrW()
		*p = x
	} else {
		PutW(Word(addr), x)
	}
}

func ImmByte() byte {
	z := B(pcreg)
	pcreg++
	return z
}
func ImmWord() Word {
	hi := ImmByte()
	lo := ImmByte()
	return HiLo(hi, lo)
}

/* sreg */
func PushByte(b byte) {
	sreg--
	PutB(sreg, b)
}
func PushWord(w Word) {
	PushByte(Lo(w))
	PushByte(Hi(w))
}
func PullByte(bp *byte) {
	*bp = B(sreg)
	sreg++
}
func PullWord(wp *Word) {
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
func PushUWord(w Word) {
	PushUByte(Lo(w))
	PushUByte(Hi(w))
}
func PullUByte(bp *byte) {
	*bp = B(ureg)
	ureg++
}
func PullUWord(wp *Word) {
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

func Os9StringN(addr Word, n Word) string {
	var buf bytes.Buffer
	for i := Word(0); i < n; i++ {
		var ch byte = 0x7F & PeekB(addr+i)
		if '!' <= ch && ch <= '~' {
			buf.WriteByte(ch)
		} else {
			Z(&buf, "{%d}", PeekB(addr+i))
		}
	}
	return buf.String()
}

func Os9String(addr Word) string {
	var buf bytes.Buffer
	for {
		var b byte = PeekB(addr)
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

func Os9StringPhys(addr int) string {
	var buf bytes.Buffer
	for {
		var b byte = mem[addr]
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

func PrintableStringThruEOS(a Word, max Word) string {
	var buf bytes.Buffer
	for i := Word(0); i < max; i++ {
		ch := PeekB(a + i)
		if 32 <= ch && ch < 127 {
			buf.WriteByte(ch)
		} else if ch == '\n' || ch == '\r' {
			buf.WriteByte(ch)
		} else if ch == 0 {
			break
		} else {
			Z(&buf, "{%d}", ch)
		}
		if ch == '\n' || ch == '\r' {
			break
		}
	}
	return buf.String()
}

func PrintableMemory(a Word, max Word) string {
	var buf bytes.Buffer
	scratch := false
	if max > 100 {
		max = 100
	}
	for i := Word(0); i < yreg && i < max; i++ {
		ch := PeekB(a + i)
		if 32 <= ch && ch < 127 {
			buf.WriteByte(ch)
			scratch = false
		} else if ch == '\n' || ch == '\r' {
			buf.WriteByte(ch)
			scratch = false
		} else {
			if !scratch {
				buf.WriteByte('~')
			}
			scratch = true
		}
	}
	return buf.String()
}

func ModuleName(module_loc Word) string {
	name_loc := module_loc + PeekW(module_loc+4)
	return Os9String(name_loc)
}

func Regs() string {
	var buf bytes.Buffer
	Z(&buf, "a=%02x b=%02x x=%04x:%04x y=%04x:%04x u=%04x:%04x s=%04x:%04x,%04x cc=%s dp=%02x #%d",
		GetAReg(), GetBReg(), xreg, PeekW(xreg), yreg, PeekW(yreg), ureg, PeekW(ureg), sreg, PeekW(sreg), PeekW(sreg+2), ccbits(ccreg), dpreg, Steps)
	return buf.String()
}

// Returns a string and whether this operation typically returns to caller.
func DecodeOs9Opcode(b byte) (string, bool) {
	MemoryModules()
	s, p := "", ""
	returns := true
	switch b {
	case 0x00:
		s = "F$Link   : Link to Module"
		p = F("type/lang=%02x module/file='%s'", GetAReg(), Os9String(xreg))

	case 0x01:
		s = "F$Load   : Load Module from File"
		p = F("type/lang=%02x filename='%s'", GetAReg(), Os9String(xreg))

	case 0x02:
		s = "F$UnLink : Unlink Module"
		p = F("u=%04x magic=%04x module='%s'", ureg, PeekW(ureg), ModuleName(ureg))

	case 0x03:
		s = "F$Fork   : Start New Process"
		p = F("Module/file='%s' param=%q lang/type=%x pages=%x", Os9String(xreg), Os9StringN(ureg, yreg), GetAReg(), GetBReg())

	case 0x04:
		s = "F$Wait   : Wait for Child Process to Die"

	case 0x05:
		s = "F$Chain  : Chain Process to New Module"
		p = F("Module/file='%s' param=%q lang/type=%x pages=%x", Os9String(xreg), Os9StringN(ureg, yreg), GetAReg(), GetBReg())

	case 0x06:
		s = "F$Exit   : Terminate Process"
		p = F("status=%x", GetBReg())
		returns = false

	case 0x07:
		s = "F$Mem    : Set Memory Size"
		p = F("desired_size=%x", dreg)

	case 0x08:
		s = "F$Send   : Send Signal to Process"
		p = F("pid=%02x signal=%02x", GetAReg(), GetBReg())

	case 0x09:
		s = "F$Icpt   : Set Signal Intercept"
		p = F("routine=%04x storage=%04x", xreg, ureg)

	case 0x0A:
		s = "F$Sleep  : Suspend Process with Sleep"
		p = F("ticks=%04x", xreg)

	case 0x0B:
		s = "F$SSpd   : Suspend Process with SSpd (unused?)"

	case 0x0C:
		s = "F$ID     : Return Process ID"

	case 0x0D:
		s = "F$SPrior : Set Process Priority"
		p = F("pid=%02x priority=%02x", GetAReg(), GetBReg())

	case 0x0E:
		s = "F$SSWI   : Set Software Interrupt"
		p = F("code=%02x addr=%04x", GetAReg(), xreg)

	case 0x0F:
		s = "F$PErr   : Print Error"

	case 0x10:
		s = "F$PrsNam : Parse Pathlist Name"
		p = F("path='%s'", Os9String(xreg))
	case 0x11:
		s = "F$CmpNam : Compare Two Names"
		p = F("first=%q second=%q", Os9StringN(xreg, Word(GetBReg())), Os9String(yreg))

	case 0x12:
		s = "F$SchBit : Search Bit Map"
		p = F("bitmap=%04x end=%04x first=%x count=%x", xreg, ureg, dreg, yreg)

	case 0x13:
		s = "F$AllBit : Allocate in Bit Map"
		p = F("bitmap=%04x first=%x count=%x", xreg, dreg, yreg)

	case 0x14:
		s = "F$DelBit : Deallocate in Bit Map"
		p = F("bitmap=%04x first=%x count=%x", xreg, dreg, yreg)

	case 0x15:
		s = "F$Time   : Get Current Time"
		p = F("buf=%x", xreg)

	case 0x16:
		s = "F$STime  : Set Current Time"
		p = F("y%d m%d d%d h%d m%d s%d", PeekB(xreg+0), PeekB(xreg+1), PeekB(xreg+2), PeekB(xreg+3), PeekB(xreg+4), PeekB(xreg+5))

	case 0x17:
		s = "F$CRC    : Generate CRC ($1"
		p = F("addr=%04x len=%04x buf=%04x", xreg, yreg, ureg)

	// NitrOS9:

	case 0x27:
		s = "F$VIRQ   : Install/Delete Virtual IRQ"

	case 0x28:
		s = "F$SRqMem : System Memory Request"
		p = F("size=%x", dreg)

	case 0x29:
		s = "F$SRtMem : System Memory Return"

	case 0x2A:
		s = "F$IRQ    : Enter IRQ Polling Table"

	case 0x2B:
		s = "F$IOQu   : Enter I/O Queue"
		p = F("pid=%02x", GetAReg())

	case 0x2C:
		s = "F$AProc  : Enter Active Process Queue"
		p = F("proc=%x", xreg)

	case 0x2D:
		s = "F$NProc  : Start Next Process"
		returns = false

	case 0x2E:
		s = "F$VModul : Validate Module"
		p = F("addr=%04x=%q", xreg, ModuleName(xreg))

	case 0x2F:
		s = "F$Find64 : Find Process/Path Descriptor"
		p = F("base=%04x id=%x", xreg, GetAReg())

	case 0x30:
		s = "F$All64  : Allocate Process/Path Descriptor"
		p = F("table=%x", xreg)

	case 0x31:
		s = "F$Ret64  : Return Process/Path Descriptor"

	case 0x32:
		s = "F$SSvc   : Service Request Table Initialization"

	case 0x33:
		s = "F$IODel  : Delete I/O Module"

		// Level 2:

	case 0x38:
		s = "F$Move   : Move data (low bound first)"
		p = F("srcTask=%x destTask=%x srcPtr=%04x destPtr=%04x size=%04x", GetAReg(), GetBReg(), xreg, ureg, yreg)

	case 0x39:
		s = "F$AllRAM : Allocate RAM blocks"
		p = F("numBlocks=%x", GetBReg())

	case 0x3A:
		s = "F$AllImg : Allocate Image RAM blocks"
		p = F("beginBlock=%x numBlocks=%x processDesc=%04x", GetAReg(), GetBReg(), xreg)

	case 0x3B:
		s = "F$DelImg : Deallocate Image RAM blocks"
		p = F("beginBlock=%x numBlocks=%x processDesc=%04x", GetAReg(), GetBReg(), xreg)

	case 0x3F:
		s = "F$AllTsk : Allocate process Task number"
		p = F("processDesc=%04x", xreg)

	case 0x44:
		s = "F$DATLog : Convert DAT block/offset to Logical Addr"
		p = F("DatImageOffset=%x blockOffset=%x", GetBReg(), xreg)

	case 0x4B:
		s = "F$AllPrc : Allocate Process descriptor"

	case 0x4F:
		s = "F$MapBlk   : Map specific block"
		p = F("beginningBlock=%x numBlocks=%x", xreg, GetBReg())

	case 0x50:
		s = "F$ClrBlk : Clear specific Block"
		p = F("numBlocks=%x firstBlock=%x", GetBReg(), ureg)

	case 0x51:
		s = "F$DelRam : Deallocate RAM blocks"
		p = F("numBlocks=%x firstBlock=%x", GetBReg(), xreg)

	// IOMan:

	case 0x80:
		s = "I$Attach : Attach I/O Device"
		p = F("%04x='%s'", xreg, Os9String(xreg))

	case 0x81:
		s = "I$Detach : Detach I/O Device"
		p = F("%04x", ureg)

	case 0x82:
		s = "I$Dup    : Duplicate Path"
		p = F("$%x", GetAReg())

	case 0x83:
		s = "I$Create : Create New File"
		p = F("%04x='%s'", xreg, Os9String(xreg))

	case 0x84:
		s = "I$Open   : Open Existing File"
		p = F("%04x='%s'", xreg, Os9String(xreg))

	case 0x85:
		s = "I$MakDir : Make Directory File"
		p = F("%04x='%s'", xreg, Os9String(xreg))

	case 0x86:
		s = "I$ChgDir : Change Default Directory"
		p = F("%04x='%s'", xreg, Os9String(xreg))

	case 0x87:
		s = "I$Delete : Delete File"
		p = F("%04x='%s'", xreg, Os9String(xreg))

	case 0x88:
		s = "I$Seek   : Change Current Position"
		p = F("path=%x pos=%04x%04x", GetAReg(), xreg, ureg)

	case 0x89:
		s = "I$Read   : Read Data"
		p = F("path=%x buf=%04x size=%x", GetAReg(), xreg, yreg)

	case 0x8A:
		s = "I$Write  : Write Data"
		if true || !hyp {
			begin, length := xreg, yreg

			WithMmuTask(1, func() {
				p = PrintableMemory(xreg, yreg)
			})

			path_num := GetAReg()
			proc := PeekW(sym.D_Proc)

			var pathDBT, q Word
			var pid, path byte
			if proc != 0 {
				pid = PeekB(proc + sym.P_ID)
				path = PeekB(proc + P_Path + Word(path_num))
				pathDBT = PeekW(sym.D_PthDBT)
				q = PeekW(pathDBT + (Word(path) >> 2))
			}

			p = F("ZYX path_num=%x proc=%x path=%x dbt=%x q=%x @%x#%x %q", path_num, proc, path, pathDBT, q, begin, length, p)
			if q != 0 {
				pd := q + 64*(Word(path)&3)
				dev := PeekW(pd + sym.PD_DEV)
				p += F("pd=%x dev=%x ", pd, dev)
				desc := PeekW(dev + sym.V_DESC)
				name := ModuleName(PeekW(dev + sym.V_DESC))
				p += F("desc=%x=%s ", desc, name)
				if name == "Term" {
					addy := MapAddr(xreg, true)
					sz := int(yreg)
					//fmt.Printf("%s", string(mem[addy:addy+int(uint(yreg))]))
					p += F(" Term: %q", string(mem[addy:addy+sz]))
					fmt.Printf("(%d)<[%s]>", sz, string(mem[addy:addy+sz])) // Bug: if crosses mem block.
				}
			}
			fmt.Printf("proc=%x id=%x XYZ n=%x p=%x {{{%s}}}\n", proc, pid, yreg, xreg, p)
		}

	case 0x8B:
		s = "I$ReadLn : Read Line of ASCII Data"

	case 0x8C:
		s = "I$WritLn : Write Line of ASCII Data"
		{
			// p = F("%q ", EscapeStringThruCrOrMax(xreg, yreg))

			//			if true || !hyp {
			//				path_num := GetAReg()
			//				proc := PeekW(sym.D_Proc)
			//				path := PeekB(proc + P_Path + Word(path_num))
			//				pathDBT := PeekW(sym.D_PthDBT)
			//				q := PeekW(pathDBT + (Word(path) >> 2))
			//				p += F("path_num=%x proc=%x path=%x dbt=%x q=%x ", path_num, proc, path, pathDBT, q)
			//				if q != 0 {
			//					pd := q + 64*(Word(path)&3)
			//					dev := PeekW(pd + sym.PD_DEV)
			//					p += F("pd=%x dev=%x ", pd, dev)
			//					desc := PeekW(dev + sym.V_DESC)
			//					name := ModuleName(PeekW(dev + sym.V_DESC))
			//					p += F("desc=%x=%s ", desc, name)
			//					if name == "Term" {
			//						//fmt.Printf("%s", PrintableStringThruEOS(xreg, yreg))
			//						p += F(" Term: %q", PrintableStringThruCrOrMax(xreg, yreg))
			//					}
			//				}
			//			}

			var path_num byte
			var proc Word
			var path byte
			WithMmuTask(0, func() {
				path_num = GetAReg()
				proc = PeekW(sym.D_Proc)
				path = PeekB(proc + P_Path + Word(path_num))
			})
			WithMmuTask(1, func() {
				str := PrintableStringThruEOS(xreg, yreg)

				//< fmt.Printf("%s", s)
				fmt.Printf("[%d/%d/%d/%q]\n", path_num, proc, path, str)
				p = fmt.Sprintf("[%d/%d/%d/%q]", proc, path_num, path, str)

				for _, ch := range []byte(str) {
					if Disp != nil {
						Disp.PutChar(ch)
					}
				}
			})

		}

	case 0x8D:
		s = "I$GetStt : Get Path Status"
		p = F("path=%x %s", GetAReg(), DecodeOs9GetStat(GetBReg()))

	case 0x8E:
		s = "I$SetStt : Set Path Status"
		p = F("path=%x %s", GetAReg(), DecodeOs9GetStat(GetBReg()))

	case 0x8F:
		s = "I$Close  : Close Path"
		p = F("path=%x", GetAReg())

	case 0x90:
		s = "I$DeletX : Delete from current exec dir"

	}
	if true || s == "" {
		s, _ = sym.SysCallNames[b]
	}
	return F("OS9$%02x <%s> {%s} #%d", b, s, p, Steps), returns
}

// 200 = 0x80 = CLEAR; 033=ESC;  201=F1, 202=F2, 203=BREAK
// 204=up 205=dn 206=left 207=right
const KB_NORMAL = "@ABCDEFGHIJKLMNOPQRSTUVWXYZ\204\205\206\207 0123456789:;,-./\r\200\033\000\000\201\202\000"
const KB_SHIFT = "`abcdefghijklmnopqrstuvwxyz____ 0!\"#$%&'()*+<=>?___..__."
const KB_CTRL = `.................................|.~...^[]..{_}\........`

func keypress(probe byte, ch byte) byte {
	shifted, controlled := false, false
	sense := byte(0)
	probe = ^probe
	for j := uint(0); j < 8; j++ {
		for i := uint(0); i < 7; i++ {
			if KB_NORMAL[i*8+j] == ch {
				if (byte(1<<j) & probe) != 0 {
					sense |= 1 << i
				}
			} else if KB_SHIFT[i*8+j] == ch && ch != '.' {
				if (byte(1<<j) & probe) != 0 {
					sense |= byte(1 << i)
				}
				shifted = true
			} else if KB_CTRL[i*8+j] == ch && ch != '.' {
				if (byte(1<<j) & probe) != 0 {
					sense |= byte(1 << i)
				}
				controlled = true
			}
		}
	}
	if shifted && (probe&0x80) != 0 {
		sense |= 0x40 // Shift key.
	}
	if controlled && (probe&0x10) != 0 {
		sense |= 0x40 // Ctrl key.
	}
	log.Printf("keypress: probe %x char %x sense %x shifted %v", probe, ch, sense, shifted)
	return ^sense
}

func interrupt(vector_addr Word) {
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
var disk_sector_0 [256]byte
var disk_dd_fmt byte // Offset 16.
var disk_i Word

var kbd_ch byte
var kbd_probe byte
var kbd_cycle Word

func assert(b bool) {
	if !b {
		panic("assert failed")
	}
}
func MaybeGetChar() byte {
	return 0
}

func nmi() {
	L("INTERRUPTING with NMI")
	interrupt(VECTOR_NMI)
	irqs_pending &^= NMI_PENDING
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

/*
func printableChar(ch byte) string {
	if ' ' <= ch && ch <= '~' {
		return string(rune(ch))
	} else {
		return F("{%d}", ch)
	}
}
*/

func irq(keystrokes <-chan byte) {
	kbd_cycle++
	L("INTERRUPTING with IRQ (kbd_cycle = %d)", kbd_cycle)
	assert(0 == (ccreg & CC_INHIBIT_IRQ))

	if (kbd_cycle & 1) == 0 {
		ch := inkey(keystrokes)
		kbd_ch = ch
		if kbd_ch != 0 {
			log.Printf("key/irq $%x=%d.", kbd_ch, kbd_ch)
		}

		L("getchar -> ch %x %q kbd_ch %x %q (kbd_cycle = %d)\n", ch, string(rune((ch))), kbd_ch, string(rune((kbd_ch))), kbd_cycle)
	} else {
		kbd_ch = 0
	}
	L("irq -> kbd_ch %x %q (kbd_cycle = %d)\n", kbd_ch, string(rune(kbd_ch)), kbd_cycle)

	interrupt(VECTOR_IRQ)
	irqs_pending &^= IRQ_PENDING
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

// Now follow the posbyte addressing modes. //

func illaddr() EA { // illegal addressing mode, defaults to zero //
	log.Panicf("Illegal Addressing Mode")
	panic(0)
}

var dixreg = []string{"x", "y", "u", "s"}

func ainc() EA {
	Dis_ops(",", dixreg[idx], 2)
	Dis_ops("+", "", 0)
	regPtr := ixregs[idx]
	z := *regPtr
	(*regPtr)++
	return EA(z)
	// return (*ixregs[idx])++;
}

func ainc2() EA {
	// Word temp;
	Dis_ops(",", dixreg[idx], 3)
	Dis_ops("++", "", 0)
	//temp=(*ixregs[idx]);
	//(*ixregs[idx])+=2;
	//return(temp);
	regPtr := ixregs[idx]
	z := *regPtr
	(*regPtr) += 2
	return EA(z)
}

func adec() EA {
	Dis_ops(",-", dixreg[idx], 2)
	// return --(*ixregs[idx]);
	regPtr := ixregs[idx]
	(*regPtr)--
	return EA(*regPtr)
}

func adec2() EA {
	// Word temp;
	Dis_ops(",--", dixreg[idx], 3)
	//(*ixregs[idx])-=2;
	//temp=(*ixregs[idx]);
	//return(temp);
	regPtr := ixregs[idx]
	(*regPtr) -= 2
	return EA(*regPtr)
}

func plus0() EA {
	Dis_ops(",", dixreg[idx], 0)
	return EA(*ixregs[idx])
}

func plusa() EA {
	Dis_ops("a,", dixreg[idx], 1)
	return EA((*ixregs[idx]) + SignExtend(GetAReg()))
}

func plusb() EA {
	Dis_ops("b,", dixreg[idx], 1)
	return EA((*ixregs[idx]) + SignExtend(GetBReg()))
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
	Dis_ops(off, dixreg[idx], 1)
	return EA((*ixregs[idx]) + SignExtend(b))
}

func plusnn() EA {
	w := ImmWord()
	off := F("$%04x,", w)
	Dis_ops(off, dixreg[idx], 4)
	return EA(*ixregs[idx] + w)
}

func plusd() EA {
	Dis_ops("d,", dixreg[idx], 4)
	return EA(*ixregs[idx] + dreg)
}

func npcr() EA {
	b := ImmByte()
	off := F("$%04x,pcr", (pcreg+SignExtend(b))&0xffff)
	Dis_ops(off, "", 1)
	return EA(pcreg + SignExtend(b))
}

func nnpcr() EA {
	w := ImmWord()
	off := F("$%04x,pcr", (pcreg+w)&0xffff)
	Dis_ops(off, "", 5)
	return EA(pcreg + w)
}

func direct() EA {
	w := ImmWord()
	off := F("$%04x", w)
	Dis_ops(off, "", 3)
	return EA(w)
}

func zeropage() EA {
	b := ImmByte()
	off := F("$%02x", b)
	Dis_ops(off, "", 2)
	return EA(HiLo(dpreg, b))
}

func immediate() EA {
	off := F("#$%02x", B(pcreg))
	Dis_ops(off, "", 0)
	z := pcreg
	pcreg++
	return EA(z)
}

func immediate2() EA {
	z := pcreg
	off := F("#$%04x", (Word(B(pcreg))<<8)|Word(B(pcreg+1)))
	Dis_ops(off, "", 0)
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
			Dis_ops("[", "", 3)
		}
		temp := (pbtable[pb&0x0f])()
		if (pb & 0x10) != 0 {
			temp = EA(temp.GetW())
			Dis_ops("]", "", 0)
		}
		return EA(temp)
	} else {
		temp := Word(pb & 0x1f)
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
		Dis_ops(off, dixreg[idx], 1)
		return EA(*ixregs[idx] + temp)
	}
}

func eaddr0() EA { // effective address for NEG..JMP //
	switch (ireg & 0x70) >> 4 {
	case 0:
		return zeropage()
	case 1, 2, 3: //canthappen//
		log.Panicf("UNKNOWN eaddr0: %02x\n", ireg)
		return 0
	case 4:
		Dis_inst_cat("a", -2)
		return ARegEA
	case 5:
		Dis_inst_cat("b", -2)
		return BRegEA
	case 6:
		Dis_inst_cat("", 2)
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
		Dis_inst_cat("", 2)
		return postbyte()
	case 3:
		return direct()
	}
	panic("notreached")
}

func eaddr16() EA { // effective address for 16-bits ops. //
	switch (ireg & 0x30) >> 4 {
	case 0:
		Dis_inst_cat("", -1)
		return immediate2()
	case 1:
		Dis_inst_cat("", -1)
		return zeropage()
	case 2:
		Dis_inst_cat("", 1)
		return postbyte()
	case 3:
		Dis_inst_cat("", -1)
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
func SETNZ16(b Word) {
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

func SETSTATUS(a byte, b byte, res Word) {
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
func CondW(b bool, x, y Word) Word {
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
	var aop, bop, res Word
	Dis_inst("add", CondS(0 != (ireg&0x40), "b", "a"), 2)
	accum := AOrB(ireg & 0x40)
	aop = Word(accum.GetB())
	bop = Word(eaddr8().GetB())
	res = (aop) + (bop)
	SETSTATUS(byte(aop), byte(bop), res)
	accum.PutB(byte(res))
}

func sbc() {
	var aop, bop, res Word
	Dis_inst("sbc", CondS(0 != (ireg&0x40), "b", "a"), 2)
	accum := AOrB(ireg & 0x40)
	aop = Word(accum.GetB())
	bop = Word(eaddr8().GetB())
	res = aop - bop - Word(ccreg&0x01)
	SETSTATUS(byte(aop), byte(bop), res)
	accum.PutB(byte(res))
}

func sub() {
	var aop, bop, res Word
	Dis_inst("sub", CondS(0 != (ireg&0x40), "b", "a"), 2)
	accum := AOrB(ireg & 0x40)
	aop = Word(accum.GetB())
	bop = Word(eaddr8().GetB())
	res = aop - bop
	SETSTATUS(byte(aop), byte(bop), res)
	accum.PutB(byte(res))
}

func adc() {
	var aop, bop, res Word
	Dis_inst("adc", CondS(0 != (ireg&0x40), "b", "a"), 2)
	accum := AOrB(ireg & 0x40)
	aop = Word(accum.GetB())
	bop = Word(eaddr8().GetB())
	res = aop + bop + Word(ccreg&0x01)
	SETSTATUS(byte(aop), byte(bop), res)
	accum.PutB(byte(res))
}

func cmp() {
	var aop, bop, res Word
	Dis_inst("cmp", CondS(0 != (ireg&0x40), "b", "a"), 2)
	accum := AOrB(ireg & 0x40)
	aop = Word(accum.GetB())
	bop = Word(eaddr8().GetB())
	res = aop - bop
	SETSTATUS(byte(aop), byte(bop), res)
}

func and() {
	var aop, bop, res byte
	Dis_inst("and", CondS(0 != (ireg&0x40), "b", "a"), 2)
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
	Dis_inst("or", CondS(0 != (ireg&0x40), "b", "a"), 2)
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
	Dis_inst("eor", CondS(0 != (ireg&0x40), "b", "a"), 2)
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
	Dis_inst("bit", CondS(0 != (ireg&0x40), "b", "a"), 2)
	accum := AOrB(ireg & 0x40)
	aop = (accum.GetB())
	bop = (eaddr8().GetB())
	res = aop & bop
	SETNZ8(res)
	CLV()
}

func ld() {
	Dis_inst("ld", CondS(0 != (ireg&0x40), "b", "a"), 2)
	accum := AOrB(ireg & 0x40)
	res := eaddr8().GetB()
	SETNZ8(res)
	CLV()
	accum.PutB(res)
}

func st() {
	Dis_inst("st", CondS(0 != (ireg&0x40), "b", "a"), 2)
	accum := AOrB(ireg & 0x40)
	res := accum.GetB()
	eaddr8().PutB(res)
	SETNZ8(res)
	CLV()
}

func jsr() {
	Dis_inst("jsr", "", 5)
	Dis_len(-pcreg)
	w := eaddr8()
	Dis_len_incr(pcreg + 1)
	PushWord(pcreg)
	pcreg = Word(w)
}

func bsr() {
	b := ImmByte()
	Dis_inst("bsr", "", 7)
	Dis_len(2)
	PushWord(pcreg)
	pcreg += SignExtend(b)
	off := F("$%04x", pcreg&0xffff)
	Dis_ops(off, "", 0)
}

func neg() {
	var a, r Word

	{
		t := W(pcreg)
		if t == 0 {
			log.Panicf("Executing 0000 instruction at pcreg=%04x", pcreg-1)
			// log.Printf("Warning: Executing 0000 instruction at pcreg=%04x", pcreg-1)
		}
	}

	a = 0
	Dis_inst("neg", "", 4)
	ea := eaddr0()
	a = Word(ea.GetB())
	r = -a
	SETSTATUS(0, byte(a), r)
	ea.PutB(byte(r))
}

func com() {
	Dis_inst("com", "", 4)
	ea := eaddr0()
	r := ^(ea.GetB())
	SETNZ8(r)
	SEC()
	CLV()
	ea.PutB(r)
}

func lsr() {
	Dis_inst("lsr", "", 4)
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
	Dis_inst("ror", "", 4)
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
	Dis_inst("asr", "", 4)
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
	var a, r Word

	Dis_inst("asl", "", 4)
	ea := eaddr0()
	a = Word(ea.GetB())
	r = a << 1
	SETSTATUS(byte(a), byte(a), r)
	ea.PutB(byte(r))
}

func rol() {
	c := (ccreg & 0x01)
	Dis_inst("rol", "", 4)
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
	Dis_inst("inc", "", 4)
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
	Dis_inst("dec", "", 4)
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
	Dis_inst("tst", "", 4)
	ea := eaddr0()
	r := ea.GetB()
	SETNZ8(r)
	CLV()
}

func jmp() {
	Dis_len(-pcreg)
	Dis_inst("jmp", "", 1)
	ea := eaddr0()
	Dis_len_incr(pcreg + 1)
	pcreg = Word(ea)
}

func clr() {
	Dis_inst("clr", "", 4)
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
	Dis_inst("", "", 1)
	(instructionTable[ireg])()
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
	Dis_inst("", "", 1)
	(instructionTable[ireg])()
	iflag = 0
}

func nop() {
	Dis_inst("nop", "", 2)
}

func sync_inst() {
	L("sync_inst")
	Waiting = true
}

func cwai() {
	b := B(pcreg) // Immediate operand //
	ccreg &= b
	pcreg++

	L("Waiting, cwai #$%02x.", b)
	Waiting = true

	Dis_inst("cwai", "", 20)
	off := F("#$%02x", b)
	Dis_ops(off, "", 0)
}

func lbra() {
	w := ImmWord()
	pcreg += w
	Dis_len(3)
	Dis_inst("lbra", "", 5)
	off := F("$%04x", pcreg&0xffff)
	Dis_ops(off, "", 0)
}

func lbsr() {
	Dis_len(3)
	Dis_inst("lbsr", "", 9)
	w := ImmWord()
	PushWord(pcreg)
	pcreg += w
	off := F("$%04x", pcreg)
	Dis_ops(off, "", 0)
}

func daa() {
	var a Word
	Dis_inst("daa", "", 2)
	a = Word(GetAReg())
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
	Dis_inst("orcc", "", 3)
	Dis_ops(off, "", 0)
	ccreg |= b
}

func andcc() {
	b := ImmByte()
	off := F("#$%02x", b)
	Dis_inst("andcc", "", 3)
	Dis_ops(off, "", 0)
	ccreg &= b
}

func mul() {
	w := Word(GetAReg()) * Word(GetBReg())
	Dis_inst("mul", "", 11)
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
	Dis_inst("sex", "", 2)
	w := SignExtend(GetBReg())
	SETNZ16(w)
	dreg = (w)
}

func abx() {
	Dis_inst("abx", "", 3)
	xreg += Word(GetBReg())
}

func rts() {
	Dis_inst("rts", "", 5)
	Dis_len(1)
	PullWord(&pcreg)
}

func rti() {
	stack := MapAddr(sreg, true /*quiet*/)
	describe := Os9Description[stack]

	if *FlagTraceOnOS9 != "" && describe != "" {
		if RegexpTraceOnOS9 == nil {
			RegexpTraceOnOS9 = regexp.MustCompile(*FlagTraceOnOS9)
		}
		if RegexpTraceOnOS9.MatchString(describe) {
			*FlagTraceAfter = 1
		}
	}

	entire := ccreg & CC_ENTIRE
	if entire == 0 {
		Dis_inst("rti", "", 6)
	} else {
		Dis_inst("rti", "", 15)
	}
	Dis_len(1)
	PullByte(&ccreg)
	if entire != 0 {
		PullWord(&dreg)
		PullByte(&dpreg)
		PullWord(&xreg)
		PullWord(&yreg)
		PullWord(&ureg)
	}
	PullWord(&pcreg)

	back3 := B(pcreg - 3)
	back2 := B(pcreg - 2)
	back1 := B(pcreg - 1)
	if back3 == 0x10 && back2 == 0x3f && describe != "" {
		if (ccreg & 1 /* carry bit indicates error */) != 0 {
			errcode := GetBReg()
			L("RETURN ERROR: $%x(%v): OS9KERNEL%d %s #%d", errcode, DecodeOs9Error(errcode), MmuTask, describe, Steps)
			L("\tregs: %s  #%d", Regs(), Steps)
			L("\t%s", ExplainMMU())
		} else {
			switch back1 {
			case 0x82, 0x83, 0x84: // I$Dup, I$Create, I$Open
				describe += F(" -> path $%x", GetAReg())
			}
			L("RETURN OKAY: OS9KERNEL%d %s #%d", MmuTask, describe, Steps)
			L("\tregs: %s  #%d", Regs(), Steps)
			L("\t%s", ExplainMMU())

			if back1 == 0x8B {
				var buf bytes.Buffer
				for i := Word(0); i < yreg; i++ {
					buf.WriteRune(rune(PeekB(xreg + i)))
				}
				L("ReadLn returns: [$%x] %q", buf.Len(), buf.String())
			}
		}

		// Os9Description[stack] = "" // Clear description
		delete(Os9Description, stack)

	}
}

var swi_name = []string{"swi", "swi2", "swi3"}

func swi() {
	Dis_inst(swi_name[iflag], "", 5)
	Dis_len(3 /* Often an extra byte after the SWI opcode */)

	ccreg |= 0x80
	PushWord(pcreg)
	PushWord(ureg)
	PushWord(yreg)
	PushWord(xreg)
	PushByte(dpreg)
	PushWord(dreg)
	PushByte(ccreg)

	var handler Word
	switch iflag {
	case 0: /* SWI */
		if *FlagSwiFatalCoreDump {
			FatalCoreDump()
		}
		ccreg |= 0xd0
		handler = W(0xfffa)
	case 1: /* SWI2 */
		describe, returns := DecodeOs9Opcode(B(pcreg))
		proc := W0(sym.D_Proc)
		pmodul := W0(proc + sym.P_PModul)
		for k := 0; k < 16; k++ {
			L("[%x] %x %c\n", k, B0(pmodul+Word(k)), (0x40 | 0x7F&B0(pmodul+Word(k))))
		}
		for k := 0; k < 16; k++ {
			L("[%x] %x %c\n", k, B1(pmodul+Word(k)), (0x40 | 0x7F&B1(pmodul+Word(k))))
		}
		L("{proc=%x#%x,pmodul=%x} OS9KERNEL%d: %s", proc, B0(proc+sym.P_ID), pmodul, MmuTask, describe)
		L("\tregs: %s", Regs())
		L("\t%s", ExplainMMU())

		stack := MapAddr(sreg, true /*quiet*/)
		if returns {
			Os9Description[stack] = describe
		} else {
			Os9Description[stack] = ""
		}

		handler = W(0xfff4)
	case 2: /* SWI3 */
		handler = W(0xfff2)
	default:
		log.Panicf("bad swi iflag=: %d", iflag)
	}

	if paranoid {
		if handler < 256 {
			log.Panicf("FATAL: Attempted SWI%d with small handler: 0x%04x", handler)
		}
		if handler >= 0xFF00 {
			log.Panicf("FATAL: Attempted SWI%d with large handler: 0x%04x", handler)
		}
	}

	syscall := B(pcreg)
	handled := false

	if hyp && iflag == 1 {
		handled = Os9HypervisorCall(syscall)
	}

	if !handled {
		pcreg = handler
	}
}

const (
	AttachModeDev byte = iota
	AttachModeRead
	AttachModeWrite
	AttachModeReadWrite
)

func Os9HypervisorCall(syscall byte) bool {
	handled := false
	L("Hyp::%x", syscall)
	switch Word(syscall) {
	case sym.I_Attach:
		{
			access_mode := GetAReg()
			dev_name := Os9String(xreg)
			L("Hyp I_Attach %q mode %d", dev_name, access_mode)
		}
	case sym.I_ChgDir:
	case sym.I_Close:
	case sym.I_Create:
	case sym.I_Delete:
	case sym.I_DeletX:
	case sym.I_Detach:
		{
			dev_table := ureg
			L("Hyp I_Detach %04x", dev_table)
		}
	case sym.I_Dup:
		L("Hyp I_Dup %d.", GetAReg())
	case sym.I_GetStt:
	case sym.I_MakDir:
	case sym.I_Open:
	case sym.I_Read:
	case sym.I_ReadLn:
	case sym.I_Seek:
	case sym.I_SetStt:
	case sym.I_Write:
	case sym.I_WritLn:
	}
	if handled {
		sreg += 10
		PullWord(&pcreg)
		pcreg++
	}
	return handled
}

func tfr() {
	Dis_inst("tfr", "", 7)
	b := ImmByte()
	Dis_reg(b)
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
	Dis_inst("exg", "", 8)
	b := ImmByte()
	Dis_reg(b)
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
	var dest Word

	if 0 == iflag {
		b := ImmByte()
		dest = pcreg + SignExtend(b)
		if f {
			pcreg += SignExtend(b)
		}
		Dis_len(2)
	} else {
		w := ImmWord()
		dest = pcreg + w
		if f {
			pcreg += w
		}
		Dis_len(3)
	}
	off := F("$%04x", dest&0xffff)
	Dis_ops(off, "", 0)
}

func NXORV() bool {
	return ((ccreg & 0x08) ^ (ccreg & 0x02)) != 0
}
func IFLAG() bool {
	return iflag != 0
}

func bra() {
	Dis_inst(CondS(IFLAG(), "l", ""), "bra", CondI(IFLAG(), 5, 3))
	br(true)
}

func brn() {
	Dis_inst(CondS(IFLAG(), "l", ""), "brn", CondI(IFLAG(), 5, 3))
	br(false)
}

func bhi() {
	Dis_inst(CondS(IFLAG(), "l", ""), "bhi", CondI(IFLAG(), 5, 3))
	br(0 == (ccreg & 0x05))
}

func bls() {
	Dis_inst(CondS(IFLAG(), "l", ""), "bls", CondI(IFLAG(), 5, 3))
	br(0 != ccreg&0x05)
}

func bcc() {
	Dis_inst(CondS(IFLAG(), "l", ""), "bcc", CondI(IFLAG(), 5, 3))
	br(0 == (ccreg & 0x01))
}

func bcs() {
	Dis_inst(CondS(IFLAG(), "l", ""), "bcs", CondI(IFLAG(), 5, 3))
	br(0 != ccreg&0x01)
}

func bne() {
	Dis_inst(CondS(IFLAG(), "l", ""), "bne", CondI(IFLAG(), 5, 3))
	br(0 == (ccreg & 0x04))
}

func beq() {
	Dis_inst(CondS(IFLAG(), "l", ""), "beq", CondI(IFLAG(), 5, 3))
	br(0 != ccreg&0x04)
}

func bvc() {
	Dis_inst(CondS(IFLAG(), "l", ""), "bvc", CondI(IFLAG(), 5, 3))
	br(0 == (ccreg & 0x02))
}

func bvs() {
	Dis_inst(CondS(IFLAG(), "l", ""), "bvs", CondI(IFLAG(), 5, 3))
	br(0 != ccreg&0x02)
}

func bpl() {
	Dis_inst(CondS(IFLAG(), "l", ""), "bpl", CondI(IFLAG(), 5, 3))
	br(0 == (ccreg & 0x08))
}

func bmi() {
	Dis_inst(CondS(IFLAG(), "l", ""), "bmi", CondI(IFLAG(), 5, 3))
	br(0 != ccreg&0x08)
}

func bge() {
	Dis_inst(CondS(IFLAG(), "l", ""), "bge", CondI(IFLAG(), 5, 3))
	br(!NXORV())
}

func blt() {
	Dis_inst(CondS(IFLAG(), "l", ""), "blt", CondI(IFLAG(), 5, 3))
	br(NXORV())
}

func bgt() {
	Dis_inst(CondS(IFLAG(), "l", ""), "bgt", CondI(IFLAG(), 5, 3))
	br(!(NXORV() || 0 != ccreg&0x04))
}

func ble() {
	Dis_inst(CondS(IFLAG(), "l", ""), "ble", CondI(IFLAG(), 5, 3))
	br(NXORV() || 0 != ccreg&0x04)
}

func leax() {
	Dis_inst("leax", "", 4)
	w := Word(postbyte())
	if w != 0 {
		CLZ()
	} else {
		SEZ()
	}
	xreg = w
}

func leay() {
	Dis_inst("leay", "", 4)
	w := Word(postbyte())
	if w != 0 {
		CLZ()
	} else {
		SEZ()
	}
	yreg = w
}

func leau() {
	Dis_inst("leau", "", 4)
	ureg = Word(postbyte())
}

func leas() {
	Dis_inst("leas", "", 4)
	sreg = Word(postbyte())
}

var reg_for_bit_count = []string{"pc", "u", "y", "x", "dp", "b", "a", "cc"}

func bit_count(b byte) int {
	var mask byte = 0x80
	count := 0
	for i := 0; i <= 7; i++ {
		if (b & mask) != 0 {
			count++
			Dis_ops(CondS(count > 1, ",", ""),
				reg_for_bit_count[i],
				1+CondI(i < 4, 1, 0))
		}
		mask >>= 1
	}
	return count
}

func pshs() {
	b := ImmByte()
	Dis_inst("pshs", "", 5)
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
	Dis_inst("puls", "", 5)
	Dis_len(2)
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
	Dis_inst("pshu", "", 5)
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
	Dis_inst("pulu", "", 5)
	Dis_len(2)
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
	SETNZ16(Word(res))
}

func addd() {
	var aop, bop, res uint32
	Dis_inst("addd", "", 5)
	aop = uint32(dreg)
	ea := eaddr16()
	bop = uint32(ea.GetW())
	res = aop + bop
	SETSTATUSD(aop, bop, res)
	dreg = Word(res)
}

func subd() {
	var aop, bop, res uint32
	if iflag != 0 {
		Dis_inst("cmpd", "", 5)
	} else {
		Dis_inst("subd", "", 5)
	}
	if iflag == 2 {
		aop = uint32(ureg)
		Dis_inst("cmpu", "", 5)
	} else {
		aop = uint32(dreg)
	}
	ea := eaddr16()
	bop = uint32(ea.GetW())
	res = aop - bop
	SETSTATUSD(aop, bop, res)
	if iflag == 0 {
		dreg = Word(res)
	}
}

func cmpx() {
	var aop, bop, res uint32
	switch iflag {
	case 0:
		Dis_inst("cmpx", "", 5)
		aop = uint32(xreg)
	case 1:
		Dis_inst("cmpy", "", 5)
		aop = uint32(yreg)
	case 2:
		Dis_inst("cmps", "", 5)
		aop = uint32(sreg)
	}
	ea := eaddr16()
	bop = uint32(ea.GetW())
	res = aop - bop
	SETSTATUSD(aop, bop, res)
}

func ldd() {
	Dis_inst("ldd", "", 4)
	ea := eaddr16()
	w := ea.GetW()
	SETNZ16(w)
	dreg = w
}

func ldx() {
	if iflag != 0 {
		Dis_inst("ldy", "", 4)
	} else {
		Dis_inst("ldx", "", 4)
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
		Dis_inst("lds", "", 4)
	} else {
		Dis_inst("ldu", "", 4)
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
	Dis_inst("std", "", 4)
	ea := eaddr16()
	w := dreg
	SETNZ16(w)
	ea.PutW(w)
}

func stx() {
	if iflag != 0 {
		Dis_inst("sty", "", 4)
	} else {
		Dis_inst("stx", "", 4)
	}
	ea := eaddr16()
	var w Word
	if iflag == 0 {
		w = xreg
	} else {
		w = yreg
	}
	SETNZ16(w)
	ea.PutW(w)
}

func stu() {
	if iflag == 0 {
		Dis_inst("stu", "", 4)
	} else {
		Dis_inst("sts", "", 4)
	}
	ea := eaddr16()
	var w Word
	if iflag == 0 {
		w = ureg
	} else {
		w = sreg
	}
	SETNZ16(w)
	ea.PutW(w)
}

func ccbits(b byte) string {
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

func init() {
	instructionTable = []func(){
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

const MaxUint64 = 0xFFFFFFFFFFFFFFFF

func Main() {
	CompileWatches()
	SetVerbosityBits(*FlagInitialVerbosity)
	InitHardware()
	keystrokes := make(chan byte, 0)
	go InputRoutine(keystrokes)

	CocodChan := make(chan *display.CocoDisplayParams, 50)
	Disp = display.NewDisplay(mem[:], 80, 25, CocodChan, keystrokes)

	{
		// Open disk image.
		fd, err := os.OpenFile(*FlagDiskImageFilename, os.O_RDWR, 0644)
		if err != nil {
			log.Fatalf("Cannot open disk image: %q: %v", *FlagBootImageFilename, err)
		}
		disk_fd = fd
	}

	{
		// Read disk_sector_0.
		n, err := disk_fd.Read(disk_sector_0[:])
		if err != nil {
			log.Panicf("Bad disk sector read: err=%v", err)
		}
		if n != 256 {
			log.Panicf("Short disk sector read: n=%d", n)
		}

		disk_dd_fmt = disk_sector_0[16]

		tracks_per_sector := int(disk_sector_0[17])*256 + int(disk_sector_0[18])
		if tracks_per_sector != 18 {
			log.Panicf("Not 18 sectors per track: %d.", tracks_per_sector)
		}
	}

	{
		boot, err := ioutil.ReadFile(*FlagBootImageFilename)
		if err != nil {
			log.Fatalf("Cannot read boot image: %q: %v", *FlagDiskImageFilename, err)
		}
		L("boot mem size: %x", len(boot))
		for i, b := range boot {
			PokeB(Word(i+0x100), b)
		}
		DumpAllMemory()
	}
	pcreg = 0x100

	sreg = 0
	dpreg = 0
	iflag = 0

	Dis_len(0)
	cycles_sum = 0

	defer func() {
		Finish()
	}()

	max := uint64(MaxUint64)
	if *FlagMaxSteps > 0 {
		max = *FlagMaxSteps
	}
	stepsUntilTimer := *FlagClock
	early := true
	for Steps = uint64(0); Steps < max; Steps++ {
		if early {
			early = EarlyAction()
		}

		pcreg_prev = pcreg

		if stepsUntilTimer == 0 {
			DoMemoryDumps()
			FireTimerInterrupt()
			stepsUntilTimer = *FlagClock
		} else {
			stepsUntilTimer--
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

				irq(keystrokes)
				CocodChan <- GetCocoDisplayParams()
				continue
			}
		}

		// Take one step.
		cycles = 0

		ireg = B(pcreg)
		if pcreg == Word(*FlagTriggerPc) && ireg == byte(*FlagTriggerOp) {
			*FlagTraceAfter = 1
			SetVerbosityBits(*FlagTraceVerbosity)
			log.Printf("TRIGGERED")
			MemoryModules()
			DoDumpAllMemory()
		}
		pcreg++

		// Process instruction
		HandleBtBug()
		instructionTable[ireg]()
		cycles_sum += int64(cycles)

		if Steps >= *FlagTraceAfter {
			Trace()
		}

		if paranoid && !early {
			ParanoidAsserts()
		}
	} /* next step */
}

func ParanoidAsserts() {
	if pcreg < 0x005E /* D.BtDbg */ {
		log.Panicf("PC in page 0: 0x%x", pcreg)
	}
	if pcreg >= 0xFF00 {
		log.Panicf("PC in page FF: 0x%x", pcreg)
	}
	if pcreg >= 0x0200 && pcreg < 0x04FF {
		log.Panicf("PC in sys data: 0x%x", pcreg)
	}
	if Level == 1 {
		if sreg < 256 {
			log.Panicf("S in page 0: 0x%x", sreg)
		}
	}
	if sreg >= 0xFF00 {
		log.Panicf("S in page FF: 0x%x", sreg)
	}
	if sreg >= 0x0140 && sreg < 0x0400 {
		log.Panicf("S in sys data: 0x%x", sreg)
	}
}
func DoMemoryDumps() {
	log.Printf("# pre timer interrupt #")
	DoDumpAllMemory()
	log.Printf("# pre timer interrupt #")
	DoDumpAllMemoryPhys()
	log.Printf("# pre timer interrupt #")
}

func B0(addr Word) byte {
	var b byte
	WithMmuTask(0, func() {
		b = B(addr)
	})
	log.Printf("==== kern byte @%x -> %x", addr, b)
	return b
}

func W0(addr Word) Word {
	var w Word
	WithMmuTask(0, func() {
		w = W(addr)
	})
	log.Printf("==== kern word @%x -> %x", addr, w)
	return w
}

func B1(addr Word) byte {
	var b byte
	WithMmuTask(1, func() {
		b = B(addr)
	})
	log.Printf("==== kern byte @%x -> %x", addr, b)
	return b
}

func W1(addr Word) Word {
	var w Word
	WithMmuTask(1, func() {
		w = W(addr)
	})
	log.Printf("==== kern word @%x -> %x", addr, w)
	return w
}
