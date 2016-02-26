/* 6809 Simulator V09,

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

/* Why not always TRACE? */
#define TRACE 1

#include <stdio.h>
#ifdef TERM_CONTROL
#include <fcntl.h>
int tflags;
#endif
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <string.h>
#include <ctype.h>
#include <assert.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


#include <stdio.h>
#include <sys/select.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

int MaybeGetChar() {
  int n;
  char c = 0;
  static struct timeval tv = {0, 0};
  fd_set set;
  FD_ZERO(&set);
  FD_SET(0, &set);
  n = select(1, &set, NULL, NULL, &tv);
  if (n==0) return 0;
  n = read(0, &c, 1);
  assert(n==1);
  // printf("GOT {%c} %d\n", c, c);
  return c;
}


typedef int bool;
#define false 0
#define true 1

#define IRQ_FREQ (10*1000)

#define CC_INHIBIT_IRQ 0x10
#define CC_INHIBIT_FIRQ 0x40
#define CC_ENTIRE 0x80

#define VECTOR_IRQ 0xFFF8
#define VECTOR_FIRQ 0xFFF6
#define VECTOR_NMI 0xFFFC

// Kernel Direct Page $00
#define D_FMBM         0x0020 // RMB 4 Free memory bit map pointers
#define D_MLIM         0x0024 // RMB 2 Memory limit $24
#define D_ModDir       0x0026 // RMB 4 Module directory $26
#define D_Init         0x002a // RMB 2 Rom base address $2A
#define D_SWI3         0x002c // RMB 2 Swi3 vector $2C
#define D_SWI2         0x002e // RMB 2 Swi2 vector $2E
#define D_FIRQ         0x0030 // RMB 2 Firq vector $30
#define D_IRQ          0x0032 // RMB 2 Irq vector $32
#define D_SWI          0x0034 // RMB 2 Swi vector $34
#define D_NMI          0x0036 // RMB 2 Nmi vector $36
#define D_SvcIRQ       0x0038 // RMB 2 Interrupt service entry $38
#define D_Poll         0x003a // RMB 2 Interrupt polling routine $3A
#define D_UsrIRQ       0x003c // RMB 2 User irq routine $3C
#define D_SysIRQ       0x003e // RMB 2 System irq routine $3E
#define D_UsrSvc       0x0040 // RMB 2 User service request routine $40
#define D_SysSvc       0x0042 // RMB 2 System service request routine $42
#define D_UsrDis       0x0044 // RMB 2 User service request dispatch table
#define D_SysDis       0x0046 // RMB 2 System service reuest dispatch table
#define D_Slice        0x0048 // RMB 1 Process time slice count $48
#define D_PrcDBT       0x0049 // RMB 2 Process descriptor block address  $49
#define D_Proc         0x004b // RMB 2 Process descriptor address $4B
#define D_AProcQ       0x004d // RMB 2 Active process queue $4D
#define D_WProcQ       0x004f // RMB 2 Waiting process queue $4F
#define D_SProcQ       0x0051 // RMB 2 Sleeping process queue $51
#define D_Year         0x0053 // RMB 1 $53
#define D_Month        0x0054 // RMB 1 $54
#define D_Day          0x0055 // RMB 1 $55
#define D_Hour         0x0056 // RMB 1 $56
#define D_Min          0x0057 // RMB 1 $57
#define D_Sec          0x0058 // RMB 1 $58
#define D_Tick         0x0059 // RMB 1 $59
#define D_TSec         0x005a // RMB 1 Ticks / second $5A
#define D_TSlice       0x005b // RMB 1 Ticks / time-slice $5B
#define D_IOML         0x005c // RMB 2 I/O mgr free memory low bound $5C
#define D_IOMH         0x005e // RMB 2 I/O mgr free memory hi  bound $5E
#define D_DevTbl       0x0060 // RMB 2 Device driver table addr $60
#define D_PolTbl       0x0062 // RMB 2 Irq polling table addr $62
#define D_PthDBT       0x0064 // RMB 2 Path descriptor block table addr $64
#define D_BTLO         0x0066 // RMB 2 Bootstrap low address $66
#define D_BTHI         0x0068 // RMB 2 Bootstrap hi address $68
#define D_DMAReq       0x006a // RMB 1 DMA in use flag $6A
#define D_AltIRQ       0x006b // RMB 2  Alternate IRQ vector (CC) $6B
#define D_KbdSta       0x006d // RMB 2  Keyboard scanner static storage (CC) $6D
#define D_DskTmr       0x006f // RMB 2  Disk Motor Timer (CC) $6F
#define D_CBStrt       0x0071 // RMB 16 reserved for CC warmstart ($71)
#define D_Clock        0x0081 // RMB 2  Address of Clock Tick Routine (CC) $81
#define D_Boot         0x0083 // RMB 1  Bootstrap attempted flag
#define D_URtoSs       0x0084 // RMB 2  address of user to system routine (VIRQ) $84
#define D_CLTb         0x0086 // RMB 2  Pointer to clock interrupt table (VIRQ) $86
#define D_MDREG        0x0088 // RMB 1  6309 MD (mode) shadow register $88 (added in V2.01.00)
#define D_CRC          0x0089 // RMB 1  CRC checking mode flag $89 (added in V2.01.00)
#define D_Clock2       0x008a // RMB 2  CC Clock2 entry address

// Process descriptor
#define P_ID       0x0000 // Process ID
#define P_PID      0x0001 // Parent's ID
#define P_SID      0x0002 // Sibling's ID
#define P_CID      0x0003 // Child's ID
#define P_SP       0x0004 // Stack ptr
#define P_CHAP     0x0006 // process chapter number
#define P_ADDR     0x0007 // user address beginning page number
#define P_PagCnt   0x0008 // Memory Page Count
#define P_User     0x0009 // User Index $09
#define P_Prior    0x000b // Priority $0B
#define P_Age      0x000c // Age $0C
#define P_State    0x000d // Status $0D
#define P_Queue    0x000e // Queue Link (Process ptr) $0E
#define P_IOQP     0x0010 // Previous I/O Queue Link (Process ID) $10
#define P_IOQN     0x0011 // Next     I/O Queue Link (Process ID)
#define P_PModul   0x0012 // Primary Module
#define P_SWI      0x0014 // SWI Entry Point
#define P_SWI2     0x0016 // SWI2 Entry Point
#define P_SWI3     0x0018 // SWI3 Entry Point $18
#define P_DIO      0x001a // default I/O ptrs $1A
#define P_PATH     0x0026 // I/O path table $26
#define P_Signal   0x0036 // Signal Code $36
#define P_SigVec   0x0037 // Signal Intercept Vector
#define P_SigDat   0x0039 // Signal Intercept Data Address
#define P_NIO      0x003b // additional dio pointers for net

#define B(i) (mem[a+i])
#define W(i) (((Word)(mem[a+i])<<8)|(Word)(mem[a+i+1]))


void finish();
void trace();

static int fdump=0;
static int tmode = 0;  // Trace enabled?
static long steps = 0;

/* Defaults for backwards compatability. */
static int swi_for_putchar = 2;  /* 1, 2, or 3, for SWI, SWI2, SWI3. */
static int swi_for_getchar = 3;  /* 1, 2, or 3, for SWI, SWI2, SWI3. */

/* Default: no big endian ... */
#ifndef CPU_BIG_ENDIAN
/* check if environment provides some information about this ... */
# if defined(BIG_ENDIAN) && defined(BYTE_ORDER)
#  if BIG_ENDIAN == BYTE_ORDER
#   define CPU_BIG_ENDIAN 1
#  else
#   define CPU_BIG_ENDIAN 0
#  endif
# endif
#endif


typedef unsigned char Byte;
typedef unsigned short Word;

/* 6809 registers */
Byte ccreg,dpreg;
Word xreg,yreg,ureg,sreg,ureg,pcreg;

Byte fillreg = 0xff;
Word wfillreg = 0xffff;

Word pcreg_prev;

Byte d_reg[2];
Word *dreg=(Word *)d_reg;

unsigned int low_reg, high_reg;  /* range for IO HW ports */

/* This is a dirty aliasing trick, but fast! */
#if CPU_BIG_ENDIAN
 Byte *areg=d_reg;
 Byte *breg=d_reg+1;
#else
 Byte *breg=d_reg;
 Byte *areg=d_reg+1;
#endif

int kbd_ch;

/* 6809 memory space */
static Byte mem[65536];

#define GETWORD(a) (mem[a]<<8|mem[(a)+1])
#define SETWORD(a,n) {mem[a]=(n)>>8;mem[(a)+1]=n;}
/* Two bytes of a word are fetched separately because of
   the possible wrap-around at address $ffff and alignment
*/


int iflag; /* flag to indicate prebyte $10 or $11 */
Byte ireg; /* Instruction register */

#define IMMBYTE(b) b=mem[pcreg++];
#define IMMWORD(w) {w=GETWORD(pcreg);pcreg+=2;}

/* sreg */
#define PUSHBYTE(b) mem[--sreg]=b;
#define PUSHWORD(w) {sreg-=2;SETWORD(sreg,w)}
#define PULLBYTE(b) b=mem[sreg++];
#define PULLWORD(w) {w=GETWORD(sreg);sreg+=2;}

/* ureg */
#define PUSHUBYTE(b) mem[--ureg]=b;
#define PUSHUWORD(w) {ureg-=2;SETWORD(ureg,w)}
#define PULLUBYTE(b) b=mem[ureg++];
#define PULLUWORD(w) {w=GETWORD(ureg);ureg+=2;}

#define SIGNED(b) ((Word)(b&0x80?b|0xff00:b))

Word *ixregs[]={&xreg,&yreg,&ureg,&sreg};

static int idx;

/* disassembled instruction buffer */
static char dinst[6];

/* disassembled operand buffer */
static char dops[32];

/* disassembled instruction len (optional, on demand) */
static int da_len;

/* instruction cycles */
static int cycles;
unsigned long cycles_sum;

bool Waiting;
int irqs_pending;
#define NMI_PENDING CC_ENTIRE /* borrow this bit */
#define IRQ_PENDING CC_INHIBIT_IRQ
#define FIRQ_PENDING CC_INHIBIT_FIRQ

struct Completion;
typedef void (*Callback)(struct Completion*);
struct Completion {
  Callback f;
  Byte service;
  Word a, b, c;
} Os9SysCallCompletion[0x10000];

void Os9AllMemoryModules();
void DefaultCompleter(struct Completion* cp);
Byte GETBYTE(Word a);

char* DecodeOs9Error(Byte b) {
  char* s = "???";
  switch (b) {
    case 0x0A: s = "E$UnkSym :Unknown symbol"; break;
    case 0x0B: s = "E$ExcVrb :Excessive verbage"; break;
    case 0x0C: s = "E$IllStC :Illegal statement construction"; break;
    case 0x0D: s = "E$ICOvf  :I-code overflow"; break;
    case 0x0E: s = "E$IChRef :Illegal channel reference"; break;
    case 0x0F: s = "E$IllMod :Illegal mode"; break;
    case 0x10: s = "E$IllNum :Illegal number"; break;
    case 0x11: s = "E$IllPrf :Illegal prefix"; break;
    case 0x12: s = "E$IllOpd :Illegal operand"; break;
    case 0x13: s = "E$IllOpr :Illegal operator"; break;
    case 0x14: s = "E$IllRFN :Illegal record field name"; break;
    case 0x15: s = "E$IllDim :Illegal dimension"; break;
    case 0x16: s = "E$IllLit :Illegal literal"; break;
    case 0x17: s = "E$IllRet :Illegal relational"; break;
    case 0x18: s = "E$IllSfx :Illegal type suffix"; break;
    case 0x19: s = "E$DimLrg :Dimension too large"; break;
    case 0x1A: s = "E$LinLrg :Line number too large"; break;
    case 0x1B: s = "E$NoAssg :Missing assignment statement"; break;
    case 0x1C: s = "E$NoPath :Missing path number"; break;
    case 0x1D: s = "E$NoComa :Missing coma"; break;
    case 0x1E: s = "E$NoDim  :Missing dimension"; break;
    case 0x1F: s = "E$NoDO   :Missing DO statement"; break;
    case 0x20: s = "E$MFull  :Memory full"; break;
    case 0x21: s = "E$NoGoto :Missing GOTO"; break;
    case 0x22: s = "E$NoLPar :Missing left parenthesis"; break;
    case 0x23: s = "E$NoLRef :Missing line reference"; break;
    case 0x24: s = "E$NoOprd :Missing operand"; break;
    case 0x25: s = "E$NoRPar :Missing right parenthesis"; break;
    case 0x26: s = "E$NoTHEN :Missing THEN statement"; break;
    case 0x27: s = "E$NoTO   :Missing TO statement"; break;
    case 0x28: s = "E$NoVRef :Missing variable reference"; break;
    case 0x29: s = "E$EndQou :Missing end quote"; break;
    case 0x2A: s = "E$SubLrg :Too many subscripts"; break;
    case 0x2B: s = "E$UnkPrc :Unknown procedure"; break;
    case 0x2C: s = "E$MulPrc :Multiply defined procedure"; break;
    case 0x2D: s = "E$DivZer :Divice by zero"; break;
    case 0x2E: s = "E$TypMis :Operand type mismatch"; break;
    case 0x2F: s = "E$StrOvf :String stack overflow"; break;
    case 0x30: s = "E$NoRout :Unimplemented routine"; break;
    case 0x31: s = "E$UndVar :Undefined variable"; break;
    case 0x32: s = "E$FltOvf :Floating Overflow"; break;
    case 0x33: s = "E$LnComp :Line with compiler error"; break;
    case 0x34: s = "E$ValRng :Value out of range for destination"; break;
    case 0x35: s = "E$SubOvf :Subroutine stack overflow"; break;
    case 0x36: s = "E$SubUnd :Subroutine stack underflow"; break;
    case 0x37: s = "E$SubRng :Subscript out of range"; break;
    case 0x38: s = "E$ParmEr :Paraemter error"; break;
    case 0x39: s = "E$SysOvf :System stack overflow"; break;
    case 0x3A: s = "E$IOMism :I/O type mismatch"; break;
    case 0x3B: s = "E$IONum  :I/O numeric input format bad"; break;
    case 0x3C: s = "E$IOConv :I/O conversion: number out of range"; break;
    case 0x3D: s = "E$IllInp :Illegal input format"; break;
    case 0x3E: s = "E$IOFRpt :I/O format repeat error"; break;
    case 0x3F: s = "E$IOFSyn :I/O format syntax error"; break;
    case 0x40: s = "E$IllPNm :Illegal path number"; break;
    case 0x41: s = "E$WrSub  :Wrong number of subscripts"; break;
    case 0x42: s = "E$NonRcO :Non-record type operand"; break;
    case 0x43: s = "E$IllA   :Illegal argument"; break;
    case 0x44: s = "E$IllCnt :Illegal control structure"; break;
    case 0x45: s = "E$UnmCnt :Unmatched control structure"; break;
    case 0x46: s = "E$IllFOR :Illegal FOR variable"; break;
    case 0x47: s = "E$IllExp :Illegal expression type"; break;
    case 0x48: s = "E$IllDec :Illegal declarative statement"; break;
    case 0x49: s = "E$ArrOvf :Array size overflow"; break;
    case 0x4A: s = "E$UndLin :Undefined line number"; break;
    case 0x4B: s = "E$MltLin :Multiply defined line number"; break;
    case 0x4C: s = "E$MltVar :Multiply defined variable"; break;
    case 0x4D: s = "E$IllIVr :Illegal input variable"; break;
    case 0x4E: s = "E$SeekRg :Seek out of range"; break;
    case 0x4F: s = "E$NoData :Missing data statement"; break;
    case 0xB7: s = "E$IWTyp  :Illegal window type"; break;
    case 0xB8: s = "E$WADef  :Window already defined"; break;
    case 0xB9: s = "E$NFont  :Font not found"; break;
    case 0xBA: s = "E$StkOvf :Stack overflow"; break;
    case 0xBB: s = "E$IllArg :Illegal argument"; break;
    case 0xBD: s = "E$ICoord :Illegal coordinates"; break;
    case 0xBE: s = "E$Bug    :Bug (should never be returned)"; break;
    case 0xBF: s = "E$BufSiz :Buffer size is too small"; break;
    case 0xC0: s = "E$IllCmd :Illegal command"; break;
    case 0xC1: s = "E$TblFul :Screen or window table is full"; break;
    case 0xC2: s = "E$BadBuf :Bad/Undefined buffer number"; break;
    case 0xC3: s = "E$IWDef  :Illegal window definition"; break;
    case 0xC4: s = "E$WUndef :Window undefined"; break;
    case 0xC5: s = "E$Up     :Up arrow pressed on SCF I$ReadLn with PD.UP enabled"; break;
    case 0xC6: s = "E$Dn     :Down arrow pressed on SCF I$ReadLn with PD.DOWN enabled"; break;
    case 0xC8: s = "E$PthFul :Path Table full"; break;
    case 0xC9: s = "E$BPNum  :Bad Path Number"; break;
    case 0xCA: s = "E$Poll   :Polling Table Full"; break;
    case 0xCB: s = "E$BMode  :Bad Mode"; break;
    case 0xCC: s = "E$DevOvf :Device Table Overflow"; break;
    case 0xCD: s = "E$BMID   :Bad Module ID"; break;
    case 0xCE: s = "E$DirFul :Module Directory Full"; break;
    case 0xCF: s = "E$MemFul :Process Memory Full"; break;
    case 0xD0: s = "E$UnkSvc :Unknown Service Code"; break;
    case 0xD1: s = "E$ModBsy :Module Busy"; break;
    case 0xD2: s = "E$BPAddr :Bad Page Address"; break;
    case 0xD3: s = "E$EOF    :End of File"; break;
    case 0xD5: s = "E$NES    :Non-Existing Segment"; break;
    case 0xD6: s = "E$FNA    :File Not Accesible"; break;
    case 0xD7: s = "E$BPNam  :Bad Path Name"; break;
    case 0xD8: s = "E$PNNF   :Path Name Not Found"; break;
    case 0xD9: s = "E$SLF    :Segment List Full"; break;
    case 0xDA: s = "E$CEF    :Creating Existing File"; break;
    case 0xDB: s = "E$IBA    :Illegal Block Address"; break;
    case 0xDC: s = "E$HangUp :Carrier Detect Lost"; break;
    case 0xDD: s = "E$MNF    :Module Not Found"; break;
    case 0xDF: s = "E$DelSP  :Deleting Stack Pointer memory"; break;
    case 0xE0: s = "E$IPrcID :Illegal Process ID"; break;
    case 0xE2: s = "E$NoChld :No Children"; break;
    case 0xE3: s = "E$ISWI   :Illegal SWI code"; break;
    case 0xE4: s = "E$PrcAbt :Process Aborted"; break;
    case 0xE5: s = "E$PrcFul :Process Table Full"; break;
    case 0xE6: s = "E$IForkP :Illegal Fork Parameter"; break;
    case 0xE7: s = "E$KwnMod :Known Module"; break;
    case 0xE8: s = "E$BMCRC  :Bad Module CRC"; break;
    case 0xE9: s = "E$USigP  :Unprocessed Signal Pending"; break;
    case 0xEA: s = "E$NEMod  :Non Existing Module"; break;
    case 0xEB: s = "E$BNam   :Bad Name"; break;
    case 0xEC: s = "E$BMHP   :(bad module header parity)"; break;
    case 0xED: s = "E$NoRAM  :No (System) RAM Available"; break;
    case 0xEE: s = "E$DNE    :Directory not empty"; break;
    case 0xEF: s = "E$NoTask :No available Task number"; break;
    case 0xF0: s = "E$Unit   :Illegal Unit (drive)"; break;
    case 0xF1: s = "E$Sect   :Bad Sector number"; break;
    case 0xF2: s = "E$WP     :Write Protect"; break;
    case 0xF3: s = "E$CRC    :Bad Check Sum"; break;
    case 0xF4: s = "E$Read   :Read Error"; break;
    case 0xF5: s = "E$Write  :Write Error"; break;
    case 0xF6: s = "E$NotRdy :Device Not Ready"; break;
    case 0xF7: s = "E$Seek   :Seek Error"; break;
    case 0xF8: s = "E$Full   :Media Full"; break;
    case 0xF9: s = "E$BTyp   :Bad Type (incompatable) media"; break;
    case 0xFA: s = "E$DevBsy :Device Busy"; break;
    case 0xFB: s = "E$DIDC   :Disk ID Change"; break;
    case 0xFC: s = "E$Lock   :Record is busy (locked out)"; break;
    case 0xFD: s = "E$Share  :Non-sharable file busy"; break;
    case 0xFE: s = "E$DeadLk :I/O Deadlock error"; break;
  }
  return s;
}

char* DecodeOs9GetStat(Byte b) {
  char* s = "???";
  switch (b) {
    case 0x00: s = "SS.Opt    : Read/Write PD Options"; break;
    case 0x01: s = "SS.Ready  : Check for Device Ready"; break;
    case 0x02: s = "SS.Size   : Read/Write File Size"; break;
    case 0x03: s = "SS.Reset  : Device Restore"; break;
    case 0x04: s = "SS.WTrk   : Device Write Track"; break;
    case 0x05: s = "SS.Pos    : Get File Current Position"; break;
    case 0x06: s = "SS.EOF    : Test for End of File"; break;
    case 0x07: s = "SS.Link   : Link to Status routines"; break;
    case 0x08: s = "SS.ULink  : Unlink Status routines"; break;
    case 0x09: s = "SS.Feed   : Issue form feed"; break;
    case 0x0A: s = "SS.Frz    : Freeze DD. information"; break;
    case 0x0B: s = "SS.SPT    : Set DD.TKS to given value"; break;
    case 0x0C: s = "SS.SQD    : Sequence down hard disk"; break;
    case 0x0D: s = "SS.DCmd   : Send direct command to disk"; break;
    case 0x0E: s = "SS.DevNm  : Return Device name (32-bytes at [X])"; break;
    case 0x0F: s = "SS.FD     : Return File Descriptor (Y-bytes at [X])"; break;
    case 0x10: s = "SS.Ticks  : Set Lockout honor duration"; break;
    case 0x11: s = "SS.Lock   : Lock/Release record"; break;
    case 0x12: s = "SS.DStat  : Return Display Status (CoCo)"; break;
    case 0x13: s = "SS.Joy    : Return Joystick Value (CoCo)"; break;
    case 0x14: s = "SS.BlkRd  : Block Read"; break;
    case 0x15: s = "SS.BlkWr  : Block Write"; break;
    case 0x16: s = "SS.Reten  : Retension cycle"; break;
    case 0x17: s = "SS.WFM    : Write File Mark"; break;
    case 0x18: s = "SS.RFM    : Read past File Mark"; break;
    case 0x19: s = "SS.ELog   : Read Error Log"; break;
    case 0x1A: s = "SS.SSig   : Send signal on data ready"; break;
    case 0x1B: s = "SS.Relea  : Release device"; break;
    case 0x1C: s = "SS.AlfaS  : Return Alfa Display Status (CoCo, SCF/GetStat)"; break;
    case 0x1D: s = "SS.Break  : Send break signal out acia"; break;
    case 0x1E: s = "SS.RsBit  : Reserve bitmap sector (do not allocate in) LSB(X)=sct#"; break;
    case 0x20: s = "SS.DirEnt : Reserve bitmap sector (do not allocate in) LSB(X)=sct#"; break;
    case 0x24: s = "SS.SetMF  : Reserve $24 for Gimix G68 (Flex compatability?)"; break;
    case 0x25: s = "SS.Cursr  : Cursor information for COCO"; break;
    case 0x26: s = "SS.ScSiz  : Return screen size for COCO"; break;
    case 0x27: s = "SS.KySns  : Getstat/SetStat for COCO keyboard"; break;
    case 0x28: s = "SS.ComSt  : Getstat/SetStat for Baud/Parity"; break;
    case 0x29: s = "SS.Open   : SetStat to tell driver a path was opened"; break;
    case 0x2A: s = "SS.Close  : SetStat to tell driver a path was closed"; break;
    case 0x2B: s = "SS.HngUp  : SetStat to tell driver to hangup phone"; break;
    case 0x2C: s = "SS.FSig   : New signal for temp locked files"; break;
  }
  return s;
}
char* Os9String(Word w) {
  static char buf[99];
  char* p = buf;
  while (1) {
    Byte b = GETBYTE(w);
    Byte ch = 127 & b;
    if (33 <= ch && ch < 127) {
      *p++ = ch;
    } else {
      break;
    }
    if (b&128) break;
    ++w;
  }
  *p = 0;
  return buf;
}
char* PrintableStringThruCrOrMax(Word a, Word max) {
  static char buf[9999];
  int i;
  int j = 0;
  memset(buf, 0, sizeof buf);
  for (i=0; i<yreg && i<1024; i++) {
    Byte ch = mem[(Word)(a + i)];
    if (32 <= ch && ch < 127) {
      buf[j] = mem[(Word)(a + i)];
      ++j;
    } else if (ch=='\n' || ch=='\r') {
      sprintf(buf+j, "\n");
    } else {
      sprintf(buf+j, "{%d}", ch);
      j = strlen(buf);
    }
    if (ch == '\r') { break; }
  }
  return buf;
}
char* EscapeStringThruCrOrMax(Word a, Word max) {
  static char buf[9999];
  int i;
  int j = 0;
  memset(buf, 0, sizeof buf);
  for (i=0; i<yreg && i<1024; i++) {
    Byte ch = mem[(Word)(a + i)];
    if (32 <= ch && ch < 127) {
      buf[j] = mem[(Word)(a + i)];
      ++j;
    } else {
      sprintf(buf+j, "{%d}", ch);
      j = strlen(buf);
    }
    if (ch == '\r') { break; }
  }
  return buf;
}
char* ModuleName(Word a) {
  Word s = a + GETWORD(a+4);
  return Os9String(s);
}
void DecodeOs9Opcode(Byte b) {
  struct Completion* cp = &Os9SysCallCompletion[pcreg+1];
  cp->f = DefaultCompleter;
  cp->service = GETBYTE(pcreg)+1;

  Os9AllMemoryModules();
  char* s = "???";
  switch(b) {
    case 0x00: s = "F$Link   : Link to Module";
      fprintf(stderr, "HEY, Kernel 0x%02x: %s .... module='%s'\n", b, s, Os9String(xreg));
      return;
    case 0x01: s = "F$Load   : Load Module from File";
      break;
    case 0x02: s = "F$UnLink : Unlink Module";
      fprintf(stderr, "HEY, Kernel 0x%02x: %s .... u=%04x magic=%04x module='%s'\n", b, s, ureg, GETWORD(ureg), ModuleName(ureg));
      return;
      break;
    case 0x03: s = "F$Fork   : Start New Process";
      fprintf(stderr, "HEY, Kernel 0x%02x: %s .... X='%s'\n", b, s, Os9String(xreg));
      return;
      break;
    case 0x04: s = "F$Wait   : Wait for Child Process to Die";
      break;
    case 0x05: s = "F$Chain  : Chain Process to New Module";
      break;
    case 0x06: s = "F$Exit   : Terminate Process";
      break;
    case 0x07: s = "F$Mem    : Set Memory Size";
      break;
    case 0x08: s = "F$Send   : Send Signal to Process";
      break;
    case 0x09: s = "F$Icpt   : Set Signal Intercept";
      break;
    case 0x0A: s = "F$Sleep  : Suspend Process";
      break;
    case 0x0B: s = "F$SSpd   : Suspend Process";
      break;
    case 0x0C: s = "F$ID     : Return Process ID";
      break;
    case 0x0D: s = "F$SPrior : Set Process Priority";
      break;
    case 0x0E: s = "F$SSWI   : Set Software Interrupt";
      break;
    case 0x0F: s = "F$PErr   : Print Error";
      break;
    case 0x10: s = "F$PrsNam : Parse Pathlist Name";
      fprintf(stderr, "HEY, Kernel 0x%02x: %s .... path='%s'\n", b, s, Os9String(xreg));
      return;
    case 0x11: s = "F$CmpNam : Compare Two Names";
      break;
    case 0x12: s = "F$SchBit : Search Bit Map";
      break;
    case 0x13: s = "F$AllBit : Allocate in Bit Map";
      break;
    case 0x14: s = "F$DelBit : Deallocate in Bit Map";
      break;
    case 0x15: s = "F$Time   : Get Current Time";
      break;
    case 0x16: s = "F$STime  : Set Current Time";
      break;
    case 0x17: s = "F$CRC    : Generate CRC ($1";
      break;

    // NitrOS9:

    case 0x27: s = "F$VIRQ   : Install/Delete Virtual IRQ";
      break;
    case 0x28: s = "F$SRqMem : System Memory Request";
      fprintf(stderr, "HEY, Kernel 0x%02x: %s .... size=%02x%02x\n", b, s, *areg, *breg);
      return;
    case 0x29: s = "F$SRtMem : System Memory Return";
      break;
    case 0x2A: s = "F$IRQ    : Enter IRQ Polling Table";
      break;
    case 0x2B: s = "F$IOQu   : Enter I/O Queue";
      break;
    case 0x2C: s = "F$AProc  : Enter Active Process Queue";
      break;
    case 0x2D: s = "F$NProc  : Start Next Process";
      break;
    case 0x2E: s = "F$VModul : Validate Module";
      fprintf(stderr, "HEY, Kernel 0x%02x: %s .... D=%04x X=%04x\n", b, s, *dreg, xreg);
      return;
    case 0x2F: s = "F$Find64 : Find Process/Path Descriptor";
      break;
    case 0x30: s = "F$All64  : Allocate Process/Path Descriptor";
      break;
    case 0x31: s = "F$Ret64  : Return Process/Path Descriptor";
      break;
    case 0x32: s = "F$SSvc   : Service Request Table Initialization";
      break;
    case 0x33: s = "F$IODel  : Delete I/O Module";
      break;

    // IOMan:

    case 0x80: s = "I$Attach : Attach I/O Device";
      fprintf(stderr, "HEY, Kernel 0x%02x: %s .... u=%04x magic=%04x module='%s'\n", b, s, ureg, GETWORD(ureg), Os9String(ureg+GETWORD(ureg+4)));
      return;
      break;
    case 0x81: s = "I$Detach : Detach I/O Device";
      break;
    case 0x82: s = "I$Dup    : Duplicate Path";
      break;
    case 0x83: s = "I$Create : Create New File";
      fprintf(stderr, "HEY, Kernel 0x%02x: %s .... X='%s'\n", b, s, Os9String(xreg));
      return;
      break;
    case 0x84: s = "I$Open   : Open Existing File";
      fprintf(stderr, "HEY, Kernel 0x%02x: %s .... X='%s'\n", b, s, Os9String(xreg));
      return;
      break;
    case 0x85: s = "I$MakDir : Make Directory File";
      fprintf(stderr, "HEY, Kernel 0x%02x: %s .... X='%s'\n", b, s, Os9String(xreg));
      return;
      break;
    case 0x86: s = "I$ChgDir : Change Default Directory";
      fprintf(stderr, "HEY, Kernel 0x%02x: %s .... X='%s'\n", b, s, Os9String(xreg));
      return;
    case 0x87: s = "I$Delete : Delete File";
      fprintf(stderr, "HEY, Kernel 0x%02x: %s .... X='%s'\n", b, s, Os9String(xreg));
      return;
      break;
    case 0x88: s = "I$Seek   : Change Current Position";
      break;
    case 0x89: s = "I$Read   : Read Data";
      break;
    case 0x8A: s = "I$Write  : Write Data";
      break;
    case 0x8B: s = "I$ReadLn : Read Line of ASCII Data";
      break;
    case 0x8C: s = "I$WritLn : Write Line of ASCII Data";
      fprintf(stderr, "HEY, Kernel 0x%02x: %s .... {{{%s}}}\n", b, s, EscapeStringThruCrOrMax(xreg, yreg));
      printf("%s", PrintableStringThruCrOrMax(xreg, yreg));
      fflush(stdout);
      break;
    case 0x8D: s = "I$GetStt : Get Path Status";
      fprintf(stderr, "HEY, Kernel 0x%02x: %s .... %s\n", b, s, DecodeOs9GetStat(*areg));
      return;
      break;
    case 0x8E: s = "I$SetStt : Set Path Status";
      fprintf(stderr, "HEY, Kernel 0x%02x: %s .... %s\n", b, s, DecodeOs9GetStat(*areg));
      return;
      break;
    case 0x8F: s = "I$Close  : Close Path";
      break;
    case 0x90: s = "I$DeletX : Delete from current exec dir";
      break;
  }
  fprintf(stderr, "HEY, Kernel 0x%02x: %s\n", b, s);
}

void DefaultCompleter(struct Completion* cp) {
  if (ccreg&1) {
    Byte errcode = *breg;
    fprintf(stderr, "HEY, Kernel 0x%02x -> ERROR [%02x] %s\n", cp->service-1, errcode, DecodeOs9Error(errcode));
  } else {
    fprintf(stderr, "HEY, Kernel 0x%02x -> okay\n", cp->service-1);
  }
}

char KB_NORMAL[] = "@ABCDEFGHIJKLMNOPQRSTUVWXYZ{}[] 0123456789:;,-./\r\b\0\0\0\0\0\0";
char KB_SHIFT[] = "_abcdefghijklmnopqrstuvwxyz____ 0!\"#$%&'()*+<=>?\0\0\0\0\0\0\0\0";

Byte keypress(Byte a, char ch) {
  int i, j;
  bool shifted = false;
  Byte probe;
  Byte sense = 0;
  a = ~a;
  for (j=0; j<8; j++) {
      for (i=0; i<7; i++) {
        if (KB_NORMAL[i*8+j] == ch) {
          if ((1<<j) & a) {
            Byte old_sense = sense;
            sense |= 1<<i;
          }
        }
        if (KB_SHIFT[i*8+j] == ch) {
          if ((1<<j) & a) {
            Byte old_sense = sense;
            sense |= 1<<i;
          }
          shifted = true;
        }
      }
  }
  if (shifted && (a & 0x80)) {
    sense |= 0x40;  // Shift key.
  }
  return ~sense;
}

interrupt(Word vector_addr) {
  PUSHWORD(pcreg)
  if (vector_addr == VECTOR_FIRQ) {
    // Fast IRQ.
    ccreg &= ~CC_ENTIRE;
  } else {
    PUSHWORD(ureg)
    // Other IRQs.
    PUSHWORD(yreg)
    PUSHWORD(xreg)
    PUSHBYTE(dpreg)
    PUSHBYTE(*breg)
    PUSHBYTE(*areg)
  }
  PUSHBYTE(ccreg)
  if (vector_addr == VECTOR_FIRQ) {
    // Fast IRQ.
    ccreg &= ~CC_ENTIRE;
  } else {
    // Other IRQs.
    ccreg |= CC_ENTIRE;
  }
  // All IRQs.
  ccreg |= (CC_INHIBIT_FIRQ|CC_INHIBIT_IRQ);
  pcreg = GETWORD(vector_addr);
}

Byte prev_disk_command;
Byte disk_command;
int disk_offset;
Byte disk_drive;
Byte disk_side;
Byte disk_sector;
Byte disk_track;
Byte disk_status;
Byte disk_data;
Byte disk_control;
FILE* disk_fd;
Byte disk_stuff[256];
int disk_i;

Byte kbd_probe;
int kbd_cycle;

nmi() {
  fprintf(stderr,"HEY, INTERRUPTING with NMI\n");
  interrupt(VECTOR_NMI);
  irqs_pending &= ~NMI_PENDING;
}
irq() {
  ++kbd_cycle;
  fprintf(stderr,"HEY, INTERRUPTING with IRQ (kbd_cycle = %d)\n", kbd_cycle);
  assert(!(ccreg&CC_INHIBIT_IRQ));

  if ((kbd_cycle&1) == 0) {
    int ch = MaybeGetChar();
    if (ch == 10 || ch == 13) {
          kbd_ch = 13;
    } else if (0 < ch && ch < 127) {
          kbd_ch = ch;
    } else {
          kbd_ch = 0;
    }
    fprintf(stderr,"HEY, getchar -> ch %x %c kbd_ch %x %c (kbd_cycle = %d)\n", ch, ch, kbd_ch, kbd_ch, kbd_cycle);
  }
  if ((kbd_cycle&1) == 1) {
    kbd_ch = 0;
  }
  fprintf(stderr,"HEY, irq -> kbd_ch %x %c (kbd_cycle = %d)\n", kbd_ch, kbd_ch, kbd_cycle);

  interrupt(VECTOR_IRQ);
  irqs_pending &= ~IRQ_PENDING;
}

Byte GetIOByte(Word a) {
  Byte z;
  switch (a) {
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
      z = 255;
      if (kbd_ch) {
        z = keypress(kbd_probe, kbd_ch);
        fprintf(stderr, "HEY, KEYBOARD: %02x {%c} -> %02x\n", kbd_probe, kbd_ch, z);
      } else {
        fprintf(stderr, "HEY, KEYBOARD: %02x      -> %02x\n", kbd_probe,         z);
      }
      return z;

    case 0xFF01:
      return 0;
    case 0xFF02:
      return kbd_probe;    /* Reset IRQ when this is read. TODO: multiple sources of IRQ. */
    case 0xFF03:
      return 0x80; /* Negative bit set: Yes the PIA caused IRQ. */

    /* PIA 1 */
    case 0xFF22:
      fprintf(stderr, "HEY, TODO: Get Io Byte 0x%04x\n", a);
      return 0;

    case 0xFF48:  /* STATREG */
      return 0;  /* low bit 0 means Ready, other bits are errors or not ready */
      break;
    case 0xFF4B:  /* Read Data */
      z = 0;
      if (disk_i < 256) {
        z = disk_stuff[disk_i];
        fprintf(stderr, "fnord %x -> %x\n", disk_i, z);
      } else {
        z = 0;
      }
      ++disk_i;
      if (disk_i==257) {
        fprintf(stderr, "HEY, Read SET NMI_PENDING\n");
        irqs_pending |= NMI_PENDING;
        z = 0;
        disk_i = 0;
      }
      return z;
    default:
      fprintf(stderr, "HEY, UNKNOWN GetIOByte: 0x%04x\n", a);
      // finish();
      return 0;
  }
}

void PutIOByte(Word a, Byte b) {
  switch (a) {
    default:
      fprintf(stderr, "HEY, UNKNOWN PutIOByte: 0x%04x\n", a);
      finish();

    case 0xFF02:
      kbd_probe = b;

    case 0xFF00:
    case 0xFF01:
    case 0xFF03:

    case 0xFF20:
    case 0xFF21:
    case 0xFF22:
    case 0xFF23:
      fprintf(stderr, "HEY, TODO: Put IO Byte 0x%04x\n", a);
      return;

    case 0xFF40:  /* CONTROL */
      disk_control = b;
      disk_side = (b&0x40) ? 1 : 0;
      disk_drive = (b&1)? 1 : (b&2)? 2: (b&4)? 3: 0;

      fprintf(stderr,"CONTROL: disk_command %x (control %x side %x drive %x)\n", disk_command, disk_control, disk_side, disk_drive);
      if (!b) break;

      switch (disk_command) {
        case 0x80:
          prev_disk_command = disk_command;
          disk_offset = 256 * (disk_sector - 1 + disk_side*18 + disk_track*36);
          if (disk_drive != 1) {
                  fprintf(stderr,"ERROR: R: Drive %d not supported\n", disk_drive);
                  exit(2);
          }
          if (!disk_fd) {
                  fprintf(stderr,"ERROR: R: No file for Disk Read Sector\n");
                  exit(2);
          }
          memset(disk_stuff, 0, 256);
          fseek(disk_fd, disk_offset, 0);
          int n = fread(disk_stuff, 1, 256, disk_fd);
          assert(n==256);
          disk_i = 0;
          fprintf(stderr, "HEY, READ fnord (Track, Sector-1) %d:%d:%d:%d == %d\n", disk_drive, disk_track, disk_side, disk_sector-1, disk_offset>>8);
          break;
        case 0xA0:
          prev_disk_command = disk_command;
          disk_offset = 256 * (disk_sector - 1 + disk_side*18 + disk_track*36);
          if (disk_drive != 1) {
                  fprintf(stderr,"ERROR: W: Drive %d not supported\n", disk_drive);
                  exit(2);
          }
          if (!disk_fd) {
                  fprintf(stderr,"ERROR: W: No file for Disk Read Sector\n");
                  exit(2);
          }
          memset(disk_stuff, 0, 256);
          fseek(disk_fd, disk_offset, 0);
          disk_i = 0;
          fprintf(stderr, "HEY, WRITE fnord (Track, Sector-1) %d:%d:%d:%d == %d\n", disk_drive, disk_track, disk_side, disk_sector-1, disk_offset>>8);
          break;
      }
      disk_command = 0;
      break;
    case 0xFF48:  /* CMDREG */
      disk_command = b;
      switch (b) {
        case 0x10:
          disk_track = disk_data;
          disk_status = 0;
          fprintf(stderr, "HEY, Seek : %d\n", disk_data);
          break;
        case 0x80:  /* Read Sector */
          /* We have set disk_command.  Next control write defines disk & side. */


          break;
        case 0xD0:
          disk_drive = 0;
          disk_side = 0;
          disk_track = 0;
          disk_sector = 0;
          disk_i = 0;
          memset(disk_stuff, 0, 256);
          fprintf(stderr, "HEY, Reset Disk\n");
          break;
      }
      break;
    case 0xFF49:  /* TRACK */
      disk_track = b;
      fprintf(stderr, "HEY, Track : %d\n", b);
      break;
    case 0xFF4A:  /* SECTOR */
      disk_sector = b;
      fprintf(stderr, "HEY, Sector-1 : %d\n", b-1);
      break;
    case 0xFF4B:  /* DATA */
      if ((prev_disk_command & 0xF0) != 0xA0) {
        disk_i = 0;
        disk_data = b;
      } // else
      if (1) {
        if (disk_i < 256) {
          fprintf(stderr, "fnord %x %x <- %x\n", prev_disk_command, disk_i, b);
          disk_stuff[disk_i] = b;
          ///++disk_i;
        }
      }
      if ((prev_disk_command & 0xF0) == 0xA0) {
        if (disk_i < 256) {
          ++disk_i;
        }
        // TODO -- fix writing.
        if (disk_i >= 256) {
          fprintf(stderr, "HEY, Write SET NMI_PENDING\n");
          irqs_pending |= NMI_PENDING;
          disk_i = 0;

          // TODO -- fix writing.
          fwrite(disk_stuff, 1, 256, disk_fd);
          fflush(disk_fd);
          fprintf(stderr, "HEY, DID_WRITE fnord (Track, Sector-1) %d:%d:%d:%d == %d\n", disk_drive, disk_track, disk_side, disk_sector-1, disk_offset>>8);
        }
      }

      break;

    /* VDG */
    case 0xFFC0:
    case 0xFFC1:
    case 0xFFC2:
    case 0xFFC3:
    case 0xFFC4:
    case 0xFFC5:
    case 0xFFC6:
    case 0xFFC7:
    case 0xFFC8:
    case 0xFFC9:
    case 0xFFCA:
    case 0xFFCB:
    case 0xFFCC:
    case 0xFFCD:
    case 0xFFCE:
    case 0xFFCF:

    case 0xFFD0:
    case 0xFFD1:
    case 0xFFD2:
    case 0xFFD3:
    case 0xFFDF:
      fprintf(stderr, "VDG PutByte OK: %x\n", a);
      break;
  }
}

Byte H(Byte ch) {
  ch &= 0x7F;
  if (32 <= ch && ch <= 126) {
    return ch;
  } else {
    return ' ';
  }
}
Byte T(Byte ch) {
  if (ch&128 && 128+32 <= ch && ch <= 128+126) {
    return '+';
  } else {
    return ' ';
  }
}

Byte GETBYTE(Word a) {
  Byte b = mem[a];
  if (low_reg <= a && a < high_reg) {
    b = GetIOByte(a);
    fprintf(stderr, "HEY, GETBYTE %04x -> %02x : %c %c\n", a, b, H(b), T(b));
  }
  return b;
}
Byte GETBYTE_ea(Byte* ea) {
  if (ea == areg) return *ea;
  if (ea == breg) return *ea;

  assert(mem <= ea);
  assert(ea < mem+0x10000);
  Word a = ea - mem;
  Byte z = GETBYTE(a);
  if (0xFF00 <= a && a <= 0xFFFF) {
    fprintf(stderr, "GETBYTE_ea %04x -> %02x : %c %c\n", (int)(ea-mem), z, H(z), T(z));
  }
  return z;
}

void PUTBYTE(Word a, Byte b) {
  Byte old = mem[a];
  mem[a] = b;
  if (low_reg <= a && a < high_reg) {
    PutIOByte(a, b);
    fprintf(stderr, "HEY, PUTBYTE %04x (was %02x) <- %02x\n", a, old, b);
  }
  if (a == 0x7bff) {
    fprintf(stderr, "HEY, DANGER: %x %x <- %x\n", a, old, b);
  }
}

void da_inst(char *inst, char *reg, int cyclecount) {
        *dinst = 0;
        *dops = 0;
        if (inst != NULL) strcat(dinst, inst);
        if (reg != NULL) strcat(dinst, reg);
        cycles += cyclecount;
}

void da_inst_cat(char *inst, int cyclecount) {
        if (inst != NULL) strcat(dinst, inst);
        cycles += cyclecount;
}

void da_ops(char *part1, char* part2, int cyclecount) {
        if (part1 != NULL) strcat(dops, part1);
        if (part2 != NULL) strcat(dops, part2);
        cycles += cyclecount;
}

void da_reg(Byte b)
{
  char *reg[] = { "d", "x", "y", "u", "s", "pc", "?", "?",
                  "a", "b", "cc", "dp", "?", "?", "?", "?" };
  da_ops( reg[(b>>4) & 0xf], ",", 0);
  da_ops( reg[b & 0xf], NULL, 0);
}

/* Now follow the posbyte addressing modes. */

Word illaddr() /* illegal addressing mode, defaults to zero */
{
 fprintf(stderr, "Illegal Addressing Mode.");
#ifdef TRACE
  if (tmode) {
    trace();
  }
#endif
 finish();
 return 0;
}

static char *dixreg[] = { "x", "y", "u", "s" };

Word ainc()
{
 da_ops(",",dixreg[idx],2);
 da_ops("+",NULL,0);
 return (*ixregs[idx])++;
}

Word ainc2()
{
 Word temp;
 da_ops(",",dixreg[idx],3);
 da_ops("++",NULL,0);
 temp=(*ixregs[idx]);
 (*ixregs[idx])+=2;
 return(temp);
}

Word adec()
{
 da_ops(",-",dixreg[idx],2);
 return --(*ixregs[idx]);
}

Word adec2()
{
 Word temp;
 da_ops(",--",dixreg[idx],3);
 (*ixregs[idx])-=2;
 temp=(*ixregs[idx]);
 return(temp);
}

Word plus0()
{
 da_ops(",",dixreg[idx],0);
 return(*ixregs[idx]);
}

Word plusa()
{
 da_ops("a,",dixreg[idx],1);
 return(*ixregs[idx])+SIGNED(*areg);
}

Word plusb()
{
 da_ops("b,",dixreg[idx],1);
 return(*ixregs[idx])+SIGNED(*breg);
}

Word plusn()
{
 Byte b;
 static char off[33];
 IMMBYTE(b)
 /* negative offsets alway decimal, otherwise hex */
 if (b & 0x80) sprintf(off,"%d,", -(b ^ 0xff)-1);
 else sprintf(off,"$%02x,",b);
 da_ops(off,dixreg[idx],1);
 return(*ixregs[idx])+SIGNED(b);
}

Word plusnn()
{
 Word w;
 IMMWORD(w)
 static char off[33];
 sprintf(off,"$%04x,",w);
 da_ops(off,dixreg[idx],4);
 return(*ixregs[idx])+w;
}

Word plusd()
{
 da_ops("d,",dixreg[idx],4);
 return(*ixregs[idx])+*dreg;
}


Word npcr()
{
 Byte b;
 static char off[33];

 IMMBYTE(b)
 sprintf(off,"$%04x,pcr",(pcreg+SIGNED(b))&0xffff);
 da_ops(off,NULL,1);
 return pcreg+SIGNED(b);
}

Word nnpcr()
{
 Word w;
 static char off[33];

 IMMWORD(w)
 sprintf(off,"$%04x,pcr",(pcreg+w)&0xffff);
 da_ops(off,NULL,5);
 return pcreg+w;
}

Word direct()
{
 Word(w);
 static char off[33];

 IMMWORD(w)
 sprintf(off,"$%04x",w);
 da_ops(off,NULL,3);
 return w;
}

Word zeropage()
{
 Byte b;
 static char off[33];

 IMMBYTE(b)
 sprintf(off,"$%02x", b);
 da_ops(off,NULL,2);
 return dpreg<<8|b;
}


Word immediate()
{
 static char off[33];

 sprintf(off,"#$%02x", mem[pcreg]);
 da_ops(off,NULL,0);
 return pcreg++;
}

Word immediate2()
{
 Word temp;
 char off[7];

 temp=pcreg;
 sprintf(off,"#$%04x", (mem[pcreg]<<8)+mem[(pcreg+1)&0xffff]);
 da_ops(off,NULL,0);
 pcreg+=2;
 return temp;
}

Word (*pbtable[])()={ ainc, ainc2, adec, adec2,
                      plus0, plusb, plusa, illaddr,
                      plusn, plusnn, illaddr, plusd,
                      npcr, nnpcr, illaddr, direct, };

Word postbyte()
{
 Byte pb;
 Word temp;
 static char off[33];

 IMMBYTE(pb)
 idx=((pb & 0x60) >> 5);
 if(pb & 0x80) {
  if( pb & 0x10)
        da_ops("[",NULL,3);
  temp=(*pbtable[pb & 0x0f])();
  if( pb & 0x10) {
        temp=GETWORD(temp);
        da_ops("]",NULL,0);
  }
  return temp;
 } else {
  temp=pb & 0x1f;
  if(temp & 0x10) temp|=0xfff0; /* sign extend */
  sprintf(off,"%d,",(temp & 0x10) ? -(temp ^ 0xffff)-1 : temp);
  da_ops(off,dixreg[idx],1);
  return (*ixregs[idx])+temp;
 }
}

Byte * eaddr0() /* effective address for NEG..JMP as byte pointer */
{
 switch( (ireg & 0x70) >> 4)
 {
  case 0: return mem+zeropage();
  case 1:case 2:case 3: /*canthappen*/
      fprintf(stderr, "HEY, UNKNOWN eaddr0: %02x\n", ireg);
      finish();

  case 4: da_inst_cat("a",-2); return areg;
  case 5: da_inst_cat("b",-2); return breg;
  case 6: da_inst_cat(NULL,2); return mem+postbyte();
  case 7: return mem+direct();
 }
}

Word eaddr8()  /* effective address for 8-bits ops. */
{
 switch( (ireg & 0x30) >> 4)
 {
  case 0: return immediate();
  case 1: return zeropage();
  case 2: da_inst_cat(NULL,2); return postbyte();
  case 3: return direct();
 }
}

Word eaddr16() /* effective address for 16-bits ops. */
{
 switch( (ireg & 0x30) >> 4)
 {
  case 0: da_inst_cat(NULL,-1); return immediate2();
  case 1: da_inst_cat(NULL,-1); return zeropage();
  case 2: da_inst_cat(NULL,1); return postbyte();
  case 3: da_inst_cat(NULL,-1); return direct();
 }
}

ill() /* illegal opcode==noop */
{
 fprintf(stderr,"Illegal Opcode\n");
 finish();
}

/* macros to set status flags */
#define SEC ccreg|=0x01;
#define CLC ccreg&=0xfe;
#define SEZ ccreg|=0x04;
#define CLZ ccreg&=0xfb;
#define SEN ccreg|=0x08;
#define CLN ccreg&=0xf7;
#define SEV ccreg|=0x02;
#define CLV ccreg&=0xfd;
#define SEH ccreg|=0x20;
#define CLH ccreg&=0xdf;

/* set N and Z flags depending on 8 or 16 bit result */
#define SETNZ8(b) {if(b)CLZ else SEZ if(b&0x80)SEN else CLN}
#define SETNZ16(b) {if(b)CLZ else SEZ if(b&0x8000)SEN else CLN}

#define SETSTATUS(a,b,res) if((a^b^res)&0x10) SEH else CLH \
                           if((a^b^res^(res>>1))&0x80)SEV else CLV \
                           if(res&0x100)SEC else CLC SETNZ8((Byte)res)

add()
{
 Word aop,bop,res;
 Byte* aaop;
 da_inst("add",(ireg&0x40)?"b":"a",2);
 aaop=(ireg&0x40)?breg:areg;
 aop=*aaop;
 bop=GETBYTE(eaddr8());
 res=aop+bop;
 SETSTATUS(aop,bop,res)
 *aaop=res;
}

sbc()
{
 Word aop,bop,res;
 Byte* aaop;
 da_inst("sbc",(ireg&0x40)?"b":"a",2);
 aaop=(ireg&0x40)?breg:areg;
 aop=*aaop;
 bop=GETBYTE(eaddr8());
 res=aop-bop-(ccreg&0x01);
 SETSTATUS(aop,bop,res)
 *aaop=res;
}

sub()
{
 Word aop,bop,res;
 Byte* aaop;
 da_inst("sub",(ireg&0x40)?"b":"a",2);
 aaop=(ireg&0x40)?breg:areg;
 aop=*aaop;
 bop=GETBYTE(eaddr8());
 res=aop-bop;
 SETSTATUS(aop,bop,res)
 *aaop=res;
}

adc()
{
 Word aop,bop,res;
 Byte* aaop;
 da_inst("adc",(ireg&0x40)?"b":"a",2);
 aaop=(ireg&0x40)?breg:areg;
 aop=*aaop;
 bop=GETBYTE(eaddr8());
 res=aop+bop+(ccreg&0x01);
 SETSTATUS(aop,bop,res)
 *aaop=res;
}

cmp()
{
 Word aop,bop,res;
 Byte* aaop;
 da_inst("cmp",(ireg&0x40)?"b":"a",2);
 aaop=(ireg&0x40)?breg:areg;
 aop=*aaop;
 bop=GETBYTE(eaddr8());
 res=aop-bop;
 SETSTATUS(aop,bop,res)
}

and()
{
 Byte aop,bop,res;
 Byte* aaop;
 da_inst("and",(ireg&0x40)?"b":"a",2);
 aaop=(ireg&0x40)?breg:areg;
 aop=*aaop;
 bop=GETBYTE(eaddr8());
 res=aop&bop;
 SETNZ8(res)
 CLV
 *aaop=res;
}

or()
{
 Byte aop,bop,res;
 Byte* aaop;
 da_inst("or",(ireg&0x40)?"b":"a",2);
 aaop=(ireg&0x40)?breg:areg;
 aop=*aaop;
 bop=GETBYTE(eaddr8());
 res=aop|bop;
 SETNZ8(res)
 CLV
 *aaop=res;
}

eor()
{
 Byte aop,bop,res;
 Byte* aaop;
 da_inst("eor",(ireg&0x40)?"b":"a",2);
 aaop=(ireg&0x40)?breg:areg;
 aop=*aaop;
 bop=GETBYTE(eaddr8());
 res=aop^bop;
 SETNZ8(res)
 CLV
 *aaop=res;
}

bit()
{
 Byte aop,bop,res;
 Byte* aaop;
 da_inst("bit",(ireg&0x40)?"b":"a",2);
 aaop=(ireg&0x40)?breg:areg;
 aop=*aaop;
 bop=GETBYTE(eaddr8());
 res=aop&bop;
 SETNZ8(res)
 CLV
}

ld()
{
 Byte res;
 Byte* aaop;
 da_inst("ld",(ireg&0x40)?"b":"a",2);
 aaop=(ireg&0x40)?breg:areg;
 res=GETBYTE(eaddr8());
 SETNZ8(res)
 CLV
 *aaop=res;
}

st()
{
 Byte res;
 Byte* aaop;
 da_inst("st",(ireg&0x40)?"b":"a",2);
 aaop=(ireg&0x40)?breg:areg;
 res=*aaop;
 PUTBYTE(eaddr8(), res);
 SETNZ8(res)
 CLV
}

jsr()
{
 Word w;

 da_inst("jsr",NULL,5);
 da_len=-pcreg;
 w=eaddr8();
 da_len += pcreg +1;
 PUSHWORD(pcreg)
 pcreg=w;
}

bsr()
{
 Byte b;
 static char off[33];
 
 IMMBYTE(b)
 da_inst("bsr",NULL,7);
 da_len = 2;
 PUSHWORD(pcreg)
 pcreg+=SIGNED(b);
 sprintf(off,"$%04x", pcreg&0xffff);
 da_ops(off,NULL,0);
}

neg()
{
 Byte *ea;
 Word a,r;

 a=0;
 da_inst("neg",NULL,4);
 ea=eaddr0();
 a=GETBYTE_ea(ea);
 r=-a;
 SETSTATUS(0,a,r)
 // *ea=r;
 long gap = ea-mem;  // PUTBYTE_ea
 if (0 <= gap && gap <= 0x10000) {
   /* for memory */
   PUTBYTE((Word)gap, r);
 } else {
   /* for registers */
   *ea = r;
 }
}

com()
{
 Byte *ea;
 Byte r;

 da_inst("com",NULL,4);
 ea=eaddr0();
/*
 fprintf(stderr,"DEBUG: com before r=%02X *ea=%02X\n", r, *ea);
*/
 r= ~GETBYTE_ea(ea);
/*
 fprintf(stderr,"DEBUG: com after r=%02X *ea=%02X\n", r, *ea);
*/
 SETNZ8(r)
 SEC CLV
 // *ea=r;
 long gap = ea-mem;  // PUTBYTE_ea
 if (0 <= gap && gap <= 0x10000) {
   /* for memory */
   PUTBYTE((Word)gap, r);
 } else {
   /* for registers */
   *ea = r;
 }
}

lsr()
{
 Byte *ea;
 Byte r;

 da_inst("lsr",NULL,4);
 ea=eaddr0();
 r=GETBYTE_ea(ea);
 if(r&0x01)SEC else CLC
 if(r&0x10)SEH else CLH
 r>>=1;
 SETNZ8(r)
 // *ea=r;
 long gap = ea-mem;  // PUTBYTE_ea
 if (0 <= gap && gap <= 0x10000) {
   /* for memory */
   PUTBYTE((Word)gap, r);
 } else {
   /* for registers */
   *ea = r;
 }
}

ror()
{
 Byte *ea;
 Byte r,c;

 c=(ccreg&0x01)<<7;
 da_inst("ror",NULL,4);
 ea=eaddr0();
 r=GETBYTE_ea(ea);
 if(r&0x01)SEC else CLC
 r=(r>>1)+c;
 SETNZ8(r)
 // *ea=r;
 long gap = ea-mem;  // PUTBYTE_ea
 if (0 <= gap && gap <= 0x10000) {
   /* for memory */
   PUTBYTE((Word)gap, r);
 } else {
   /* for registers */
   *ea = r;
 }
}

asr()
{
 Byte *ea;
 Byte r;

 da_inst("asr",NULL,4);
 ea=eaddr0();
 r=GETBYTE_ea(ea);
 if(r&0x01)SEC else CLC
 if(r&0x10)SEH else CLH
 r>>=1;
 if(r&0x40)r|=0x80;
 SETNZ8(r)
 //*ea=r;
 long gap = ea-mem;  // PUTBYTE_ea
 if (0 <= gap && gap <= 0x10000) {
   /* for memory */
   PUTBYTE((Word)gap, r);
 } else {
   /* for registers */
   *ea = r;
 }
}

asl()
{
 Byte *ea;
 Word a,r;

 da_inst("asl",NULL,4);
 ea=eaddr0();
 a=GETBYTE_ea(ea);
 r=a<<1;
 SETSTATUS(a,a,r)
 // *ea=r;
 long gap = ea-mem;  // PUTBYTE_ea
 if (0 <= gap && gap <= 0x10000) {
   /* for memory */
   PUTBYTE((Word)gap, r);
 } else {
   /* for registers */
   *ea = r;
 }
}

rol()
{
 Byte *ea;
 Byte r,c;

 c=(ccreg&0x01);
 da_inst("rol",NULL,4);
 ea=eaddr0();
 r=GETBYTE_ea(ea);
 if(r&0x80)SEC else CLC
 if((r&0x80)^((r<<1)&0x80))SEV else CLV
 r=(r<<1)+c;
 SETNZ8(r)
 // *ea=r;
 long gap = ea-mem;  // PUTBYTE_ea
 if (0 <= gap && gap <= 0x10000) {
   /* for memory */
   PUTBYTE((Word)gap, r);
 } else {
   /* for registers */
   *ea = r;
 }
}

inc()
{
 Byte *ea;
 Byte r;

 da_inst("inc",NULL,4);
 ea=eaddr0();
 r=GETBYTE_ea(ea);
 r++;
 if(r==0x80)SEV else CLV
 SETNZ8(r)
 *ea=r;
}

dec()
{
 Byte *ea;
 Byte r;

 da_inst("dec",NULL,4);
 ea=eaddr0();
 r=GETBYTE_ea(ea);
 r--;
 if(r==0x7f)SEV else CLV
 SETNZ8(r)
 *ea=r;
}

tst()
{
 Byte r;
 Byte *ea;

 da_inst("tst",NULL,4);
 ea=eaddr0();
 r=GETBYTE_ea(ea);
 SETNZ8(r)
 CLV
}

jmp()
{
 Byte *ea;

 da_len = -pcreg;
 da_inst("jmp",NULL,1);
 ea=eaddr0();
 da_len += pcreg + 1;
 pcreg=ea-mem;
}

clr()
{
 Byte *ea;

 da_inst("clr",NULL,4);
 ea=eaddr0();
 long gap = ea-mem;
 if (0 <= gap && gap <= 0x10000) {
   /* for memory */
   PUTBYTE((Word)gap, 0);
 } else {
   /* for registers */
   *ea = 0;
 }
 CLN CLV SEZ CLC
}

extern (*instrtable[])();

flag0()
{
 if(iflag) /* in case flag already set by previous flag instr don't recurse */
 {
  pcreg--;
  return;
 }
 iflag=1;
 ireg=mem[pcreg++];
 da_inst(NULL,NULL,1);
 (*instrtable[ireg])();
 iflag=0;
}

flag1()
{
 if(iflag) /* in case flag already set by previous flag instr don't recurse */
 {
  pcreg--;
  return;
 }
 iflag=2;
 ireg=mem[pcreg++];
 da_inst(NULL,NULL,1);
 (*instrtable[ireg])();
 iflag=0;
}

nop()
{
 da_inst("nop",NULL,2);
}

sync_inst()
{
 fprintf(stderr, "HEY, Waiting, sync_inst.\n");
 Waiting = true;
}

cwai()
{
 char off[8];
 Byte b = mem[pcreg];  /* Immediate operand */
 ccreg &= b;
 pcreg++;

 fprintf(stderr, "HEY, Waiting, cwai #$%02x.\n", b);
 Waiting = true;

 da_inst("cwai",NULL,20);
 sprintf(off,"#$%02x", b);
 da_ops(off,NULL,0);
}

lbra()
{
 Word w;
 static char off[33];

 IMMWORD(w)
 pcreg+=w;
 da_len = 3;
 da_inst("lbra",NULL,5);
 sprintf(off,"$%04x", pcreg&0xffff);
 da_ops(off,NULL,0);
}

lbsr()
{
 Word w;
 static char off[33];

 da_len = 3;
 da_inst("lbsr",NULL,9);
 IMMWORD(w)
 PUSHWORD(pcreg)
 pcreg+=w;
 sprintf(off,"$%04x", pcreg&0xffff);
 da_ops(off,NULL,0);
}

daa()
{
 Word a;
 da_inst("daa",NULL,2);
 a=*areg;
 if(ccreg&0x20)a+=6;
 if((a&0x0f)>9)a+=6;
 if(ccreg&0x01)a+=0x60;
 if((a&0xf0)>0x90)a+=0x60;
 if(a&0x100)SEC
 *areg=a;
}

orcc()
{
 Byte b;
 char off[7];
 IMMBYTE(b)
 sprintf(off,"#$%02x", b);
 da_inst("orcc",NULL,3);
 da_ops(off,NULL,0);
 ccreg|=b;
}

andcc()
{
 Byte b;
 static char off[33];
 IMMBYTE(b)
 sprintf(off,"#$%02x", b);
 da_inst("andcc",NULL,3);
 da_ops(off,NULL,0);

 ccreg&=b;
}

mul()
{
 Word w;
 w=*areg * *breg;
 da_inst("mul",NULL,11);
 if(w)CLZ else SEZ
 if(w&0x80) SEC else CLC
 *dreg=w;
}

sex()
{
 Word w;
 da_inst("sex",NULL,2);
 w=SIGNED(*breg);
 SETNZ16(w)
 *dreg=w;
}

abx()
{
 da_inst("abx",NULL,3);
 xreg += *breg;
}

rts()
{
 da_inst("rts",NULL,5);
 da_len = 1;
 PULLWORD(pcreg)
}

rti()
{
 Byte entire;
 entire = ccreg & CC_ENTIRE;
 da_inst("rti",NULL,(entire?15:6));
 da_len = 1;
 PULLBYTE(ccreg)
 if(entire)
 {
  PULLBYTE(*areg)
  PULLBYTE(*breg)
  PULLBYTE(dpreg)
  PULLWORD(xreg)
  PULLWORD(yreg)
  PULLWORD(ureg)
 }
 PULLWORD(pcreg)
}

void DumpAllMemory() {
  int i, j;
  static char buf[200];
  memset(buf, 0, sizeof buf);
  for (i=0; i < 0x10000; i+=32) {
    sprintf(buf, "%04x: ", (unsigned)i);
    for (j=0; j<32; j+=8) {
      sprintf(buf+strlen(buf),
              "%02x%02x %02x%02x %02x%02x %02x%02x  ",
              mem[i+j+0], mem[i+j+1], mem[i+j+2], mem[i+j+3],
              mem[i+j+4], mem[i+j+5], mem[i+j+6], mem[i+j+7]);
    }
    fprintf(stderr, "%s\n", buf);
  }
}


void DumpPageZero() {
  Word a = 0;
  fprintf(stderr, "PageZero: FreeBitMap=%x:%x MemoryLimit=%x ModDir=%x RomBase=%x\n",
                  W(D_FMBM), W(D_FMBM+2), W(D_MLIM), W(D_ModDir), W(D_Init));
  fprintf(stderr, "  D_SWI3=%x D_SWI2=%x FIRQ=%x IRQ=%x SWI=%x NMI=%x SvcIRQ=%x Poll=%x\n",
                  W(D_SWI3), W(D_SWI2), W(D_FIRQ), W(D_IRQ), W(D_SWI), W(D_NMI), W(D_SvcIRQ), W(D_Poll)); 
  fprintf(stderr, "  BTLO=%x BTHI=%x  IO Free Mem Lo=%x Hi=%x D_DevTbl=%x D_PolTbl=%x D_PthDBT=%x D_Proc=%x\n",
                  W(D_BTLO), W(D_BTHI), W(D_IOML), W(D_IOMH), W(D_DevTbl), W(D_PolTbl), W(D_PthDBT), W(D_Proc)); 
  fprintf(stderr, "  D_Slice=%x D_TSlice=%x\n",
                  W(D_Slice), W(D_TSlice));
}

#define   PD_PD       0x00   // RMB 1    Path Number
#define   PD_MOD      0x01   // RMB 1    Mode (Read/Write/Update)
#define   PD_CNT      0x02   // RMB 1    Number of Open Images
#define   PD_DEV      0x03   // RMB 2    Device Table Entry Address
#define   PD_CPR      0x05   // RMB 1    Current Process
#define   PD_RGS      0x06   // RMB 2    Caller's Register Stack
#define   PD_BUF      0x08   // RMB 2    Buffer Address
#define   PD_FST      0x0a   // RMB 32-. File Manager's Storage
#define   PD_DTP      0x20   // RMB 1    Device Type

void DumpPathDesc(Word a) {
  if (!B(PD_PD)) return;
  fprintf(stderr, "Path @%x: #=%x mode=%x count=%x dev=%x\n", a, B(PD_PD), B(PD_MOD), B(PD_CNT), W(PD_DEV));
  fprintf(stderr, "   curr_process=%x caller_reg_stack=%x buffer=%x  dev_type=%x\n",
                  B(PD_CPR), B(PD_RGS), B(PD_BUF), B(PD_DTP)); 
}

void DumpAllPathDescs() {
  int i, j;
  Word a = 0;
  Word p = W(D_PthDBT);
  if (!p) return;
  for (i=0; i<32; i++) {
    Word q = W(p + i*2);
    if (q) {
      for (j=0; j<4; j++) {
        int k = i*4+j;
        if (k==0) continue;
        DumpPathDesc(q + j*64);
      }
    }
  }
}

void DumpProcDesc(Word a) {
  fprintf(stderr, "Process @%x: id=%x pid=%x sid=%x cid=%x\n", a, B(P_ID), B(P_PID), B(P_SID), B(P_CID));
  fprintf(stderr, "   sp=%x chap=%x Addr=%x PagCnt=%x User=%x Pri=%x Age=%x State=%x\n",
                  W(P_SP), B(P_CHAP), B(P_ADDR), B(P_PagCnt), W(P_User), B(P_Prior), B(P_Age), B(P_State));
  Word mod = W(P_PModul);
  Word name = mod + GETWORD(mod+4);
  fprintf(stderr, "   Queue=%x IOQP=%x IOQN=%x PModul='%s' Signal=%x SigVec=%x SigDat=%x\n",
                  W(P_Queue), B(P_IOQP), B(P_IOQN), Os9String(name), B(P_Signal), B(P_SigVec), B(P_SigDat)); 
  fprintf(stderr, "   DIO %x %x %x PATH %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x\n",
                  W(P_DIO), W(P_DIO+2), W(P_DIO+4),
                  B(P_PATH+0), B(P_PATH+1), B(P_PATH+2), B(P_PATH+3),
                  B(P_PATH+4), B(P_PATH+5), B(P_PATH+6), B(P_PATH+7),
                  B(P_PATH+8), B(P_PATH+9), B(P_PATH+10), B(P_PATH+11),
                  B(P_PATH+12), B(P_PATH+13), B(P_PATH+14), B(P_PATH+15));
  if (W(P_Queue)) {
    DumpProcDesc(W(P_Queue));
  }
}

void DumpProcesses() {
  Word a = 0;  // kernel direct page.
  if (W(D_Proc)) {
    fprintf(stderr, "D_Proc:\n");
    DumpProcDesc(W(D_Proc));
  }
  if (W(D_AProcQ)) {
    fprintf(stderr, "D_AProcQ: Active:\n");
    DumpProcDesc(W(D_AProcQ));
  }
  if (W(D_WProcQ)) {
    fprintf(stderr, "D_WProcQ: Wait:\n");
    DumpProcDesc(W(D_WProcQ));
  }
  if (W(D_SProcQ)) {
    fprintf(stderr, "D_SProcQ: Sleep\n");
    DumpProcDesc(W(D_SProcQ));
  }
}

void Os9AllMemoryModules() {
  Word start = GETWORD(0x26);
  Word limit = GETWORD(0x28);
  Word i = start;
  // DumpAllMemory();
  DumpPageZero();
  DumpProcesses();
  DumpAllPathDescs();
  fprintf(stderr, "\nHEY, MODULES: ");
  for (; i < limit; i += 4) {
    Word mod = GETWORD(i);
    if (mod) {
      Word end = mod + GETWORD(mod+2);
      Word name = mod + GETWORD(mod+4);
      fprintf(stderr, "%x:%x:<%s> ", mod, end, Os9String(name));
    }
  }
  fprintf(stderr, "\n\n");
}

swi()
{
 int w;
 int swi_num = iflag + 1; // 1, 2, or 3 for SWI, SWI2, or SWI3.

 da_inst("swi",(iflag==1)?"2":(iflag==2)?"3":"",5);
 da_len = 4;  /* Often an extra info after the SWI opcode */

 if (swi_num == swi_for_putchar) {
  putchar(*breg);
  fflush(stdout);
 } else if (swi_num == swi_for_getchar) {
  w=getchar();
  if(w==EOF)SEC else CLC
  *breg=w;
 } else {
  Word tmp;
  ccreg |= 0x80;
  PUSHWORD(pcreg)
  PUSHWORD(ureg)
  PUSHWORD(yreg)
  PUSHWORD(xreg)
  PUSHBYTE(dpreg)
  PUSHBYTE(*breg)
  PUSHBYTE(*areg)
  PUSHBYTE(ccreg)
  switch(swi_num)
  {
   case 1:  /* SWI */
    ccreg|=0xd0;
    tmp=GETWORD(0xfffa);
    break;
   case 2:  /* SWI2 */
    // assert(GETBYTE(pcreg+0) == 0x3F);
    // fprintf(stderr, "pcreg=%x\n", pcreg);
    DecodeOs9Opcode(GETBYTE(pcreg));

    tmp=GETWORD(0xfff4);
    break;
   case 3:  /* SWI3 */
    tmp=GETWORD(0xfff2);
    break;
  }
  if (!tmp) {
    fprintf(stderr, "FATAL: Attempted SWI%d with zero vector\n", swi_num);
#ifdef TRACE
    trace();
#endif
    /* If vector is still 00, finish & possibly dump. */
    finish();
  }
  pcreg = tmp;
 }
}


Word *wordregs[]={(Word*)d_reg,&xreg,&yreg,&ureg,&sreg,&pcreg,&wfillreg,&wfillreg};

#if CPU_BIG_ENDIAN
Byte *byteregs[]={d_reg,d_reg+1,&ccreg,&dpreg,&fillreg,&fillreg,&fillreg,&fillreg};
#else
Byte *byteregs[]={d_reg+1,d_reg,&ccreg,&dpreg,&fillreg,&fillreg,&fillreg,&fillreg};
#endif

tfr()
{
 Byte b;
 da_inst("tfr",NULL,7);
 IMMBYTE(b)
 da_reg(b);
 Word v;
 // source in higher nibble (highest bit set means 8 bit reg.)
 if(b&0x80) {
  v=*byteregs[(b&0x70)>>4] | (b&0x08 ? 0 : 0xff00);
 } else {
  v=*wordregs[(b&0x70)>>4];
 }
 // dest in lower nibble (highest bit set means 8 bit reg.)
 if(b&0x8) {
  *byteregs[b&0x07]=v&0xff;
  fillreg=0xff;  // keep fillvalue
 } else {
  *wordregs[b&0x07]=v;
  wfillreg = 0xffff;  // keep fillvalue
 }
}

exg()
{
 Byte b;
 Word f;
 Word t;
 da_inst("exg",NULL,8);
 IMMBYTE(b)
 da_reg(b);
 if(b&0x80) {
  f=*byteregs[(b&0x70)>>4] | 0xff00;
 } else {
  f=*wordregs[(b>>4)&0x07];
 }
 if(b&0x8) {
  t=*byteregs[b&0x07] | 0xff00;
 } else {
  t=*wordregs[b&0x07];
 }
 if(b&0x80) {
  *byteregs[(b&0x70)>>4] = t;
  fillreg=0xff;  // keep fillvalue
 } else {
  *wordregs[(b>>4)&0x07] = t;
  wfillreg = 0xffff;  // keep fillvalue
 }
 if(b&0x8) {
  *byteregs[b&0x07] = f;
  fillreg=0xff;  // keep fillvalue
 } else {
  *wordregs[b&0x07] = f;
  wfillreg = 0xffff;  // keep fillvalue
 }
}

br(int f)
{
 Byte b;
 Word w;
 char off[7];
 Word dest;

 if(!iflag) {
  IMMBYTE(b)
  dest = pcreg+SIGNED(b);
  if(f) pcreg+=SIGNED(b);
  da_len = 2;
 } else {
  IMMWORD(w)
  dest = pcreg+w;
  if(f) pcreg+=w;
  da_len = 3;
 }
 sprintf(off,"$%04x", dest&0xffff);
 da_ops(off,NULL,0);
}

#define NXORV  ((ccreg&0x08)^(ccreg&0x02))

bra()
{
 da_inst(iflag?"l":"","bra",iflag?5:3);
 br(1);
}

brn()
{
 da_inst(iflag?"l":"","brn",iflag?5:3);
 br(0);
}

bhi()
{
 da_inst(iflag?"l":"","bhi",iflag?5:3);
 br(!(ccreg&0x05));
}

bls()
{
 da_inst(iflag?"l":"","bls",iflag?5:3);
 br(ccreg&0x05);
}

bcc()
{
 da_inst(iflag?"l":"","bcc",iflag?5:3);
 br(!(ccreg&0x01));
}

bcs()
{
 da_inst(iflag?"l":"","bcs",iflag?5:3);
 br(ccreg&0x01);
}

bne()
{
 da_inst(iflag?"l":"","bne",iflag?5:3);
 br(!(ccreg&0x04));
}

beq()
{
 da_inst(iflag?"l":"","beq",iflag?5:3);
 br(ccreg&0x04);
}

bvc()
{
 da_inst(iflag?"l":"","bvc",iflag?5:3);
 br(!(ccreg&0x02));
}

bvs()
{
 da_inst(iflag?"l":"","bvs",iflag?5:3);
 br(ccreg&0x02);
}

bpl()
{
 da_inst(iflag?"l":"","bpl",iflag?5:3);
 br(!(ccreg&0x08));
}

bmi()
{
 da_inst(iflag?"l":"","bmi",iflag?5:3);
 br(ccreg&0x08);
}

bge()
{
 da_inst(iflag?"l":"","bge",iflag?5:3);
 br(!NXORV);
}

blt()
{
 da_inst(iflag?"l":"","blt",iflag?5:3);
 br(NXORV);
}

bgt()
{
 da_inst(iflag?"l":"","bgt",iflag?5:3);
 br(!(NXORV||ccreg&0x04));
}

ble()
{
 da_inst(iflag?"l":"","ble",iflag?5:3);
 br(NXORV||ccreg&0x04);
}

leax()
{
 Word w;
 da_inst("leax",NULL,4);
 w=postbyte();
 if(w) CLZ else SEZ
 xreg=w;
}

leay()
{
 Word w;
 da_inst("leay",NULL,4);
 w=postbyte();
 if(w) CLZ else SEZ
 yreg=w;
}

leau()
{
 da_inst("leau",NULL,4);
 ureg=postbyte();
}

leas()
{
 da_inst("leas",NULL,4);
 sreg=postbyte();
}


int bit_count(Byte b)
{
  Byte mask=0x80;
  int count=0;
  int i;
  char *reg[] = { "pc", "u", "y", "x", "dp", "b", "a", "cc" };

  for(i=0; i<=7; i++) {
        if (b & mask) {
                count++;
                da_ops(count > 1 ? ",":"", reg[i],1+(i<4?1:0));
        }
        mask >>= 1;
  }
  return count;
}


pshs()
{
 Byte b;
 IMMBYTE(b)
 da_inst("pshs",NULL,5);
 bit_count(b);
 if(b&0x80)PUSHWORD(pcreg)
 if(b&0x40)PUSHWORD(ureg)
 if(b&0x20)PUSHWORD(yreg)
 if(b&0x10)PUSHWORD(xreg)
 if(b&0x08)PUSHBYTE(dpreg)
 if(b&0x04)PUSHBYTE(*breg)
 if(b&0x02)PUSHBYTE(*areg)
 if(b&0x01)PUSHBYTE(ccreg)
}

puls()
{
 Byte b;
 IMMBYTE(b)
 da_inst("puls",NULL,5);
 da_len = 2;
 bit_count(b);
 if(b&0x01)PULLBYTE(ccreg)
 if(b&0x02)PULLBYTE(*areg)
 if(b&0x04)PULLBYTE(*breg)
 if(b&0x08)PULLBYTE(dpreg)
 if(b&0x10)PULLWORD(xreg)
 if(b&0x20)PULLWORD(yreg)
 if(b&0x40)PULLWORD(ureg)
 if(b&0x80)PULLWORD(pcreg)
}

pshu()
{
 Byte b;
 IMMBYTE(b)
 da_inst("pshu",NULL,5);
 bit_count(b);
 if(b&0x80)PUSHUWORD(pcreg)
 if(b&0x40)PUSHUWORD(ureg)
 if(b&0x20)PUSHUWORD(yreg)
 if(b&0x10)PUSHUWORD(xreg)
 if(b&0x08)PUSHUBYTE(dpreg)
 if(b&0x04)PUSHUBYTE(*breg)
 if(b&0x02)PUSHUBYTE(*areg)
 if(b&0x01)PUSHUBYTE(ccreg)
}

pulu()
{
 Byte b;
 IMMBYTE(b)
 da_inst("pulu",NULL,5);
 da_len = 2;
 bit_count(b);
 if(b&0x01)PULLUBYTE(ccreg)
 if(b&0x02)PULLUBYTE(*areg)
 if(b&0x04)PULLUBYTE(*breg)
 if(b&0x08)PULLUBYTE(dpreg)
 if(b&0x10)PULLUWORD(xreg)
 if(b&0x20)PULLUWORD(yreg)
 if(b&0x40)PULLUWORD(ureg)
 if(b&0x80)PULLUWORD(pcreg)
}

#define SETSTATUSD(a,b,res) {if(res&0x10000) SEC else CLC \
                            if(((res>>1)^a^b^res)&0x8000) SEV else CLV \
                            SETNZ16((Word)res)}

addd()
{
 unsigned long aop,bop,res;
 Word ea;
 da_inst("addd",NULL,5);
 aop=*dreg & 0xffff;
 ea=eaddr16();
 bop=GETWORD(ea);
 res=aop+bop;
 SETSTATUSD(aop,bop,res)
 *dreg=res;
}

subd()
{
 unsigned long aop,bop,res;
 Word ea;
 if (iflag) da_inst("cmpd",NULL,5);
 else da_inst("subd",NULL,5);
 if(iflag==2) {
        aop=ureg;
        da_inst("cmpu",NULL,5);
 }
 else aop=*dreg & 0xffff;
 ea=eaddr16();
 bop=GETWORD(ea);
 res=aop-bop;
 SETSTATUSD(aop,bop,res)
 if(iflag==0) *dreg=res; /* subd result */
}

cmpx()
{
 unsigned long aop,bop,res;
 Word ea;
 switch(iflag) {
  case 0:
        da_inst("cmpx",NULL,5);
        aop=xreg;
        break;
  case 1:
        da_inst("cmpy",NULL,5);
        aop=yreg;
        break;
  case 2:
        da_inst("cmps",NULL,5);
        aop=sreg;
 }
 ea=eaddr16();
 bop=GETWORD(ea);
 res=aop-bop;
 SETSTATUSD(aop,bop,res)
}

ldd()
{
 Word ea,w;
 da_inst("ldd",NULL,4);
 ea=eaddr16();
 w=GETWORD(ea);
 SETNZ16(w)
 *dreg=w;
}

ldx()
{
 Word ea,w;
 if (iflag) da_inst("ldy",NULL,4);
 else da_inst("ldx",NULL,4);
 ea=eaddr16();
 w=GETWORD(ea);
 SETNZ16(w)
 if (iflag==0) xreg=w; else yreg=w;
}

ldu()
{
 Word ea,w;
 if (iflag) da_inst("lds",NULL,4);
 else da_inst("ldu",NULL,4);
 ea=eaddr16();
 w=GETWORD(ea);
 SETNZ16(w)
 if (iflag==0) ureg=w; else sreg=w;
}

std()
{
 Word ea,w;
 da_inst("std",NULL,4);
 ea=eaddr16();
 w=*dreg;
 SETNZ16(w)
 SETWORD(ea,w)
}

stx()
{
 Word ea,w;
 if (iflag) da_inst("sty",NULL,4);
 else da_inst("stx",NULL,4);
 ea=eaddr16();
 if (iflag==0) w=xreg; else w=yreg;
 SETNZ16(w)
 SETWORD(ea,w)
}

stu()
{
 Word ea,w;
 if (iflag) da_inst("sts",NULL,4);
 else da_inst("stu",NULL,4);
 ea=eaddr16();
 if (iflag==0) w=ureg; else w=sreg;
 SETNZ16(w)
 SETWORD(ea,w)
}

int (*instrtable[])() = {
 neg , ill , ill , com , lsr , ill , ror , asr ,
 asl , rol , dec , ill , inc , tst , jmp , clr ,
 flag0 , flag1 , nop , sync_inst , ill , ill , lbra , lbsr ,
 ill , daa , orcc , ill , andcc , sex , exg , tfr ,
 bra , brn , bhi , bls , bcc , bcs , bne , beq ,
 bvc , bvs , bpl , bmi , bge , blt , bgt , ble ,
 leax , leay , leas , leau , pshs , puls , pshu , pulu ,
 ill , rts , abx , rti , cwai , mul , ill , swi ,
 neg , ill , ill , com , lsr , ill , ror , asr ,
 asl , rol , dec , ill , inc , tst , ill , clr ,
 neg , ill , ill , com , lsr , ill , ror , asr ,
 asl , rol , dec , ill , inc , tst , ill , clr ,
 neg , ill , ill , com , lsr , ill , ror , asr ,
 asl , rol , dec , ill , inc , tst , jmp , clr ,
 neg , ill , ill , com , lsr , ill , ror , asr ,
 asl , rol , dec , ill , inc , tst , jmp , clr ,
sub , cmp , sbc , subd , and , bit , ld , st ,
eor , adc ,  or , add , cmpx , bsr , ldx , stx ,
sub , cmp , sbc , subd , and , bit , ld , st ,
eor , adc ,  or , add , cmpx , jsr , ldx , stx ,
sub , cmp , sbc , subd , and , bit , ld , st ,
eor , adc ,  or , add , cmpx , jsr , ldx , stx ,
sub , cmp , sbc , subd , and , bit , ld , st ,
eor , adc ,  or , add , cmpx , jsr , ldx , stx ,
sub , cmp , sbc , addd , and , bit , ld , st ,
eor , adc ,  or , add , ldd , std , ldu , stu ,
sub , cmp , sbc , addd , and , bit , ld , st ,
eor , adc ,  or , add , ldd , std , ldu , stu ,
sub , cmp , sbc , addd , and , bit , ld , st ,
eor , adc ,  or , add , ldd , std , ldu , stu ,
sub , cmp , sbc , addd , and , bit , ld , st ,
eor , adc ,  or , add , ldd , std , ldu , stu ,
};

read_image(char* name)
{
 FILE *image;
 if((image=fopen(name,"rb"))!=NULL) {
  int n = fread(mem+0x100,1,0xff00,image);
  assert ( n > 1 );
  fclose(image);
 } else {
  fprintf(stderr,"ERROR: Cannot read image file\n");
  exit(2);
 }
}

dump()
{
 FILE *image;
 if((image=fopen("dump.v09","wb"))!=NULL) {
  fwrite(mem,0x10000,1,image);
  fclose(image);
 }
}

/* E F H I N Z V C */

char *to_bin(Byte b)
{
        static char binstr[9];
        Byte bm;
        char *ccbit="EFHINZVC";
        int i;

        for(bm=0x80, i=0; bm>0; bm >>=1, i++)
                binstr[i] = (b & bm) ? toupper(ccbit[i]) : tolower(ccbit[i]);
        binstr[8] = 0;
        return binstr;
}


void cr() {
   #ifdef TERM_CONTROL
   fprintf(stderr,"%s","\r\n");         /* CR+LF because raw terminal ... */
   #else
   fprintf(stderr,"%s","\n");
   #endif
}

#ifdef TRACE

/* max. bytes of instruction code per trace line */
#define I_MAX 4

void where(int addr) {
  Word start = GETWORD(0x26);
  Word limit = GETWORD(0x28);
  Word i = start;
  for (; i < limit; i += 4) {
    Word mod = GETWORD(i);
    if (mod) {
      Word size = GETWORD(mod+2);
      if (mod < addr && addr < mod+size) {
        Word name = mod + GETWORD(mod+4);
        while(1) {
          int ch = 127 & GETBYTE(name);
          if ('!' <= ch && ch <= '~') {
            fprintf(stderr, "%c", ch);
          } else {
            break;
          }
          if (GETBYTE(name) & 128) {
            fprintf(stderr, ",%04x ", addr-mod);
            return;
          }
          ++name;
        }
      }
    }
  }
  fprintf(stderr, "? ");
}

char been_there[0x10000];
void trace()
{
   int ilen;
   int i;

  if (1) {
   int save_pcreg_prev = pcreg_prev;
   where(save_pcreg_prev);
   int oldnew = been_there[pcreg_prev] ? 'o' : 'N';
   fprintf(stderr,"%c %04x ", oldnew, pcreg_prev);
   been_there[pcreg_prev] = 1;

   if (da_len) ilen = da_len;
   else {
        ilen = pcreg-pcreg_prev; if (ilen < 0) ilen= -ilen;
   }
   for(i=0; i < I_MAX; i++) {
        if (i < ilen) fprintf(stderr,"%02x",mem[(pcreg_prev+i)&0xffff]);
        else fprintf(stderr,"  ");
   }
   fprintf(stderr," %-5s %-17s [%02d] ", dinst, dops, cycles);
   //if((ireg&0xfe)==0x10)
   // fprintf(stderr,"%02x ",mem[pcreg]);else fprintf(stderr,"   ");
   fprintf(stderr,"x=%04x y=%04x u=%04x s=%04x a=%02x b=%02x cc=%s dp=%02x",
                   xreg,yreg,ureg,sreg,*areg,*breg,to_bin(ccreg), dpreg);
   fprintf(stderr,", s: %04x %04x, #%ld",
        mem[sreg]<<8|mem[sreg+1],
        mem[sreg+2]<<8|mem[sreg+3],
        steps
   );
   cr();
  }
  da_len = 0;
}

#endif


static char optstring[]="0Ftdi:o:H:L:Z:f:T:";

main(int argc,char *argv[])
{
 char c;
 int a;
 int zmode = 0, Fmode = 0; // Init to 0, Init to F.
 long maxsteps= 0;
 long tracetrigger= -1;

 while( (c=getopt(argc, argv, optstring)) >=0 ) {
        switch(c) {
          case 'H': {
                unsigned int tmp = 0;
                sscanf(optarg, "%x", &tmp);
                high_reg = tmp;
                }
                break;
          case 'L': {
                unsigned int tmp = 0;
                sscanf(optarg, "%x", &tmp);
                low_reg = tmp;
                }
                break;
          case 'Z':
                maxsteps = atoi(optarg);
                break;
          case '0':
                zmode = 1;
                break;
          case 'F':
                Fmode = 1;
                break;
          case 't':
                tmode = 1;
                break;
          case 'T':
                tracetrigger = atoi(optarg);
                break;
          case 'd':
                fdump = 1;
                break;
          case 'i':
                swi_for_getchar = atoi(optarg);
                break;
          case 'o':
                swi_for_putchar = atoi(optarg);
                break;
          case 'f':
                disk_fd = fopen(optarg, "r+");
                if (!disk_fd) {
                  fprintf(stderr,"ERROR: Cannot open file: %s\n", optarg);
                  exit(2);
                }
                break;
          default:
                fprintf(stderr,"ERROR: Unknown option\n");
                exit(2);
        }
 }

 if (zmode) {
   /* Initialize mem to all zeros. */
   memset(mem, 0x00, sizeof mem);
 } else if (Fmode) {
   /* Initialize mem to all FFs. */
   memset(mem, 0xFF, sizeof mem);
 } else {
   /* initialize memory with pseudo random data ... */
   srandom(time(NULL));
   for(a=0x0100; a<0x10000;a++) {
     mem[(Word)a] = (Byte) (random() & 0xff);
   }
 }

 if (optind < argc) {
   read_image(argv[optind]);
 }
 else {
        fprintf(stderr,"ERROR: Missing image name\n");
        exit(2);
 }

 pcreg=0x100;
 sreg=0;
 dpreg=0;
 iflag=0;
 /* raw disables SIGINT, brkint reenables it ...
  */
#if defined(TERM_CONTROL) /* && ! defined(TRACE) */
  /* raw, but still allow key signaling, especial if ^C is desired
     - if not, remove brkint and isig!
   */
  system("stty -echo nl raw brkint isig");

  tflags=fcntl(0,F_GETFL,0);
  fcntl(0,F_SETFL,tflags|O_NDELAY);
#endif

#ifdef TRACE
 da_len = 0;
#endif
 cycles_sum = 0;
 pcreg_prev = pcreg;

 for(steps = 0; !maxsteps || steps < maxsteps; ((pcreg_prev=pcreg), steps++)){
   if (steps == tracetrigger) {
     tmode = 1;
   }

   struct Completion* cp = &Os9SysCallCompletion[pcreg];
   if (cp->f) {
     cp->f(cp);
     cp->f = NULL;
   }

   if (steps % IRQ_FREQ == IRQ_FREQ - 1) {
     irqs_pending |= IRQ_PENDING;
     Waiting = false;
   }

  if (Waiting) {
    continue;
  }

  if (irqs_pending) {
    if (irqs_pending & NMI_PENDING) {
      nmi();
      continue;
    }
    if ((irqs_pending & IRQ_PENDING) && !(ccreg & CC_INHIBIT_IRQ)) {

      irq();
      continue;
    }
  }

  if (pcreg < 256) {
     fprintf(stderr,"Executing in page 0:  %d", pcreg);
     finish();
  }

  ireg=mem[pcreg++];
  cycles=0;
  (*instrtable[ireg])();                /* process instruction */
  cycles_sum += cycles;

#ifdef TRACE
  if (tmode) {
    trace();
  }
#endif

  pcreg_prev = pcreg;

 } /* next step */
 fprintf(stderr,"FINISHED %ld STEPS\n", steps);
 finish();
}



void finish()
{
 cr();
 fprintf(stderr,"Cycles: %lu", cycles_sum);
 cr();
#if defined(TERM_CONTROL) && ! defined(TRACE)
 ///////////// system("stty -raw -nl echo brkint");
 fcntl(0,F_SETFL,tflags&~O_NDELAY);
#endif
 if (fdump) dump();
 exit(0);
}
