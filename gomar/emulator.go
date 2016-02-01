/* GOMAR 6809 Emulator.

   Modified by Henry Strickland, 2016, converted to go.
   Based on code with the following copyright:

   6809 Simulator V09.

   Copyright 1994,1995 L.C. Benschop, Eidnhoven The Netherlands.
   This version of the program is distributed under the terms and conditions
   of the GNU General Public License version 2. See the file COPYING.
   THERE IS NO WARRANTY ON THIS PROGRAM!!!

   This program simulates a 6809 processor.

   System dependencies: short must be 16 bits.
                        char  must be 8 bits.
                        long must be more than 16 bits.
                        arrays up to 65536 bytes must be supported.
                        machine must be twos complement.
   Most Unix machines will work. For MSODS you need long pointers
   and you may have to malloc() the mem array of 65536 bytes.

   Special instructions:
   SWI2 writes char to stdout from register B.
   SWI3 reads char from stdout to register B, sets carry at EOF.
               (or when no key available when using term control).
   SWI retains its normal function.
   CWAI and SYNC stop simulator.
   Note: special instructions are gone for now.

   ACIA emulation at port $E000

   Note: BIG_ENDIAN option is no longer needed.
*/

package gomar

import "fmt"

var F = fmt.Sprintf

type Byte uint8
type Word uint16
type SByte int8
type SWord int16

const K64 = 64 * 1024
const K32 = 32 * 1024

type M struct {
  aca,acb Byte
  x,y,u,s,pc Word
  dp,cc,a,b Byte

  ea Word  /* effective address */
  iflag Byte

  mem [K64]Byte
}

func (o *M) GetByte(a Word) Byte { return o.mem[a] }
func (o *M) GetWord(a Word) Word { return (Word(o.GetByte(a))<<8)|Word(o.GetByte(a+1)) }
func (o *M) SetByte(a Word, x Byte) { o.mem[a] = x }
func (o *M) SetByteW(a Word, x Word) { o.mem[a] = Byte(x) }
func (o *M) SetWord(a Word, x Word) { o.mem[a] = Byte(x>>8); o.mem[a+1] = Byte(x) }

func (o *M) GetByteE() Byte { return o.GetByte(o.ea) }
func (o *M) GetWordE() Word { return o.GetWord(o.ea) }
func (o *M) SetByteE(x Byte) { o.SetByte(o.ea, x) }
func (o *M) SetWordE(x Word) { o.SetWord(o.ea, x) }

func (o *M) ImmByte() Byte { z := o.GetByte(o.pc); o.pc+=1; return z }
func (o *M) ImmByteWord() Word { z := o.GetByte(o.pc); o.pc+=1; return Word(SWord(z)) }
func (o *M) ImmWord() Word { z := o.GetWord(o.pc); o.pc+=2; return z }

func (o *M) PushByteS(x Byte) { o.s-=1; o.SetByte(o.s, x) }
func (o *M) PushWordS(x Word) { o.s-=2; o.SetWord(o.s, x) }
func (o *M) PushByteU(x Byte) { o.u-=1; o.SetByte(o.u, x) }
func (o *M) PushWordU(x Word) { o.u-=2; o.SetWord(o.u, x) }

func (o *M) PullByteS() Byte { z := o.GetByte(o.s); o.s+=2; return z }
func (o *M) PullWordS() Word { z := o.GetWord(o.s); o.s+=2; return z }
func (o *M) PullByteU() Byte { z := o.GetByte(o.u); o.u+=2; return z }
func (o *M) PullWordU() Word { z := o.GetWord(o.u); o.u+=2; return z }

func (o *M) GetD() Word { return (Word(o.a)<<8) | Word(o.b) }
func (o *M) SetD(x Word) { o.a = Byte(x>>8); o.b = Byte(x) }

func (o *M) EaDirect() { o.ea = o.ImmByteWord() | (Word(o.dp)<<8) }
func (o *M) EaExtended() { o.ea = o.ImmWord() }
func (o *M) EaImm8() { o.ea = o.pc; o.pc+=1 }
func (o *M) EaImm16() { o.ea = o.pc; o.pc+=2 }

func (o *M) SetStatus(a Byte, b Byte, res Word) {
  if (Word(a)^Word(b)^res) & 0x10 != 0 { o.SEH() } else { o.CLH() }
  if (Word(a)^Word(b)^res^(res>>1)) & 0x80 != 0 { o.SEV() } else { o.CLV() }
  if res & 0x100 != 0 { o.SEC() } else { o.CLC() }
  o.SetNZ8(Byte(res))
}
func (o *M) SetStatusD(a Word, b Word, res int) {
  if (int(a)^int(b)^res^(res>>1)) & 0x8000 != 0 { o.SEV() } else { o.CLV() }
  if res & 0x10000 != 0 { o.SEC() } else { o.CLC() }
  o.SetNZ16(Word(res))
}
// define SETSTATUS(a,b,res) if((a^b^res)&0x10) {o.SEH()} else CLH \
//                           if((a^b^res^(res>>1))&0x80)SEV else CLV \
//                           if(res&0x100)SEC else CLC SETNZ8((Byte)res)

// define SETSTATUSD(a,b,res) {if(res&0x10000) SEC else CLC \
//                            if(((res>>1)^a^b^res)&0x8000) SEV else CLV \
//                            SETNZ16((Word)res)}

// define SETNZ8(b) {if(b)CLZ else SEZ if(b&0x80)SEN else CLN}
// define SETNZ16(b) {if(b)CLZ else SEZ if(b&0x8000)SEN else CLN}
func (o *M) SetNZ8(x Byte) {
  if x != 0 { o.CLZ() } else { o.SEZ() }
  if (x & 0x80) != 0 { o.SEN() } else { o.CLN() }
}
func (o *M) SetNZ16(x Word) {
  if x != 0 { o.CLZ() } else { o.SEZ() }
  if (x & 0x8000) != 0 { o.SEN() } else { o.CLN() }
}

func (o *M) SEC() { o.cc += 0x01 }
func (o *M) CLC() { o.cc &= Byte(255&^0x01) }
func (o *M) SEZ() { o.cc += 0x04 }
func (o *M) CLZ() { o.cc &= Byte(255&^0x04) }
func (o *M) SEN() { o.cc += 0x08 }
func (o *M) CLN() { o.cc &= Byte(255&^0x08) }
func (o *M) SEV() { o.cc += 0x02 }
func (o *M) CLV() { o.cc &= Byte(255&^0x02) }
func (o *M) SEH() { o.cc += 0x20 }
func (o *M) CLH() { o.cc &= Byte(255&^0x20) }
func (o *M) NXORV() bool { return 0 != ((o.cc & 8) ^ ((o.cc & 2)<<2)) }
func (o *M) Branch(cond bool) {
  var tw Word
  if o.iflag > 0 {
    tw = o.ImmWord()
  } else {
    tw = o.ImmByteWord()
  }
  if cond { o.pc += tw }
}

/////////////////////////////////////////////////////////////
// Byte *breg=&aca,*areg=&acb;
// static int tracetrick=0;

// // define GETWORD(a) (mem[a]<<8|mem[(a)+1])
// // define SETBYTE(a,n) {if(!(a&0x8000))mem[a]=n;}
// // define SETWORD(a,n) if(!(a&0x8000)){mem[a]=(n)>>8;mem[(a)+1]=n;}
/* Two bytes of a word are fetched separately because of
   the possible wrap-around at address $ffff and alignment
*/

// define IMMBYTE(b) b=mem[o.pc++];
// define IMMWORD(w) {w=GETWORD(o.pc);o.pc+=2;}

// define o.PushByteS(b) {--o.s;SETBYTE(o.s,b)}
// define o.PushWordS(w) {o.s-=2;SETWORD(o.s,w)}
// define PULLBYTE(b) b=mem[o.s++];
// define PULLWORD(w) {w=GETWORD(o.s);o.s+=2;}
// define o.PushByteU(b) {--o.u;SETBYTE(o.u,b)}
// define o.PushWordU(w) {o.u-=2;SETWORD(o.u,w)}
// define PULUBYTE(b) b=mem[o.u++];
// define PULUWORD(w) {w=GETWORD(o.u);o.u+=2;}

// define SIGNED(b) ((Word)(b&0x80?b|0xff00:b))

// define GETDREG ((o.a<<8)|o.b)
// define SETDREG(n) {o.a=(n)>>8;o.b=(n);}

/* Macros for addressing modes (postbytes have their own code) */
// define DIRECT {IMMBYTE(eaddr) eaddr|=(o.dp<<8);}
// define IMM8 {eaddr=o.pc++;}
// define IMM16 {eaddr=o.pc;o.pc+=2;}
// define EXTENDED {IMMWORD(eaddr)}

/* macros to set status flags */
// define SEC o.cc|=0x01;
// define CLC o.cc&=0xfe;
// define SEZ o.cc|=0x04;
// define CLZ o.cc&=0xfb;
// define SEN o.cc|=0x08;
// define CLN o.cc&=0xf7;
// define SEV o.cc|=0x02;
// define CLV o.cc&=0xfd;
// define SEH o.cc|=0x20;
// define CLH o.cc&=0xdf;

/* set N and Z flags depending on 8 or 16 bit result */
// define SETNZ8(b) {if(b)CLZ else SEZ if(b&0x80)SEN else CLN}
// define SETNZ16(b) {if(b)CLZ else SEZ if(b&0x8000)SEN else CLN}

// define SETSTATUS(a,b,res) if((a^b^res)&0x10) SEH else CLH \
//                           if((a^b^res^(res>>1))&0x80)SEV else CLV \
//                           if(res&0x100)SEC else CLC SETNZ8((Byte)res)

// define SETSTATUSD(a,b,res) {if(res&0x10000) SEC else CLC \
//                            if(((res>>1)^a^b^res)&0x8000) SEV else CLV \
//                            SETNZ16((Word)res)}

/* Macros for branch instructions */
// define BRANCH(f) if(!iflag){IMMBYTE(tb) if(f)o.pc+=SIGNED(tb);}\
//                     else{IMMWORD(tw) if(f)o.pc+=tw;}
// define NXORV  ((o.cc&0x08)^((o.cc&0x02)<<2))

/* MAcros for setting/getting registers in TFR/EXG instructions */
func (o *M) GetReg(reg Byte) Word {
  switch reg {
  case 0: return o.GetD()
  case 1: return o.x
  case 2: return o.y
  case 3: return o.u
  case 4: return o.s
  case 5: return o.pc
  case 8: return Word(o.a)
  case 9: return Word(o.b)
  case 10: return Word(o.cc)
  case 11: return Word(o.dp)
  default: panic(F("Bad GetReg %d", reg))
  }
}

func (o *M) SetReg(val Word, reg Byte) {
  switch reg {
  case 0: o.SetD(val)
  case 1: o.x = val
  case 2: o.y = val
  case 3: o.u = val
  case 4: o.s = val
  case 5: o.pc = val
  case 8: o.a = Byte(val)
  case 9: o.b = Byte(val)
  case 10: o.cc = Byte(val)
  case 11: o.dp = Byte(val)
  default: panic(F("Bad SetReg %d", reg))
  }
}

/* Macros for load and store of accumulators. Can be modified to check
   for port addresses */
// define LOADAC(reg) if((eaddr&0xff00)!=IOPAGE)reg=mem[eaddr];else\
//           reg=do_input(eaddr&0xff);
// define STOREAC(reg) if((eaddr&0xff00)!=IOPAGE)SETBYTE(eaddr,reg)else\
//	   do_output(eaddr&0xff,reg);

// define LOADREGS o.x=xreg;o.y=yreg;\
// o.u=ureg;o.s=sreg;\
// o.pc=pcreg;\
// o.a=*areg;o.b=*breg;\
// o.dp=dpreg;o.cc=ccreg;

// define SAVEREGS xreg=o.x;yreg=o.y;\
// ureg=o.u;sreg=o.s;\
// pcreg=o.pc;\
// *areg=o.a;*breg=o.b;\
// dpreg=o.dp;ccreg=o.cc;


var HasPostByte = []bool{
  /*0*/      false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,
  /*1*/      false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,
  /*2*/      false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,
  /*3*/      true,true,true,true,false,false,false,false,false,false,false,false,false,false,false,false,
  /*4*/      false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,
  /*5*/      false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,
  /*6*/      true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,
  /*7*/      false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,
  /*8*/      false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,
  /*9*/      false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,
  /*A*/      true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,
  /*B*/      false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,
  /*C*/      false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,
  /*D*/      false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,
  /*E*/      true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,
  /*F*/      false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,
}

func (o *M) Step() {
 var tb Byte
 var tw Word
 var ti int
 _, _, _ = tb, tw, ti
 /*
  if(attention) {
   if(tracing && o.pc>=tracelo && o.pc<=tracehi)
              {SAVEREGS do_trace(); }
   if(escape){ SAVEREGS do_escape(); LOADREGS }
   if(irq) {
    if(irq==1&&!(o.cc&0x10)) { // standard IRQ
			 o.PushWordS(o.pc)
			 o.PushWordS(o.u)
                   	 o.PushWordS(o.y)
   			 o.PushWordS(o.x)
   			 o.PushByteS(o.dp)
   			 o.PushByteS(o.b)
   			 o.PushByteS(o.a)
   			 o.PushByteS(o.cc)
   			 o.cc|=0x90;
     			 o.pc=GETWORD(0xfff8);
    }
    if(irq==2&&!(o.cc&0x40)) { // Fast IRQ
			 o.PushWordS(o.pc)
   			 o.PushByteS(o.cc)
   			 o.cc&=0x7f;
    			 o.cc|=0x50;
    			 o.pc=GETWORD(0xfff6);
    }
    if(!tracing)attention=0;
    irq=0;
   }
  }
  */
  o.iflag = 0
  var ireg Byte

 flaginstr:  /* $10 and $11 instructions return here */
  ireg=o.GetByte(o.pc)
  o.pc += 1

  if(HasPostByte[ireg]) {
   var postbyte Byte = o.GetByte(o.pc)
   o.pc += 1

   switch(postbyte) {
    case 0x00: o.ea=o.x;break;
    case 0x01: o.ea=o.x+1;break;
    case 0x02: o.ea=o.x+2;break;
    case 0x03: o.ea=o.x+3;break;
    case 0x04: o.ea=o.x+4;break;
    case 0x05: o.ea=o.x+5;break;
    case 0x06: o.ea=o.x+6;break;
    case 0x07: o.ea=o.x+7;break;
    case 0x08: o.ea=o.x+8;break;
    case 0x09: o.ea=o.x+9;break;
    case 0x0A: o.ea=o.x+10;break;
    case 0x0B: o.ea=o.x+11;break;
    case 0x0C: o.ea=o.x+12;break;
    case 0x0D: o.ea=o.x+13;break;
    case 0x0E: o.ea=o.x+14;break;
    case 0x0F: o.ea=o.x+15;break;
    case 0x10: o.ea=o.x-16;break;
    case 0x11: o.ea=o.x-15;break;
    case 0x12: o.ea=o.x-14;break;
    case 0x13: o.ea=o.x-13;break;
    case 0x14: o.ea=o.x-12;break;
    case 0x15: o.ea=o.x-11;break;
    case 0x16: o.ea=o.x-10;break;
    case 0x17: o.ea=o.x-9;break;
    case 0x18: o.ea=o.x-8;break;
    case 0x19: o.ea=o.x-7;break;
    case 0x1A: o.ea=o.x-6;break;
    case 0x1B: o.ea=o.x-5;break;
    case 0x1C: o.ea=o.x-4;break;
    case 0x1D: o.ea=o.x-3;break;
    case 0x1E: o.ea=o.x-2;break;
    case 0x1F: o.ea=o.x-1;break;
    case 0x20: o.ea=o.y;break;
    case 0x21: o.ea=o.y+1;break;
    case 0x22: o.ea=o.y+2;break;
    case 0x23: o.ea=o.y+3;break;
    case 0x24: o.ea=o.y+4;break;
    case 0x25: o.ea=o.y+5;break;
    case 0x26: o.ea=o.y+6;break;
    case 0x27: o.ea=o.y+7;break;
    case 0x28: o.ea=o.y+8;break;
    case 0x29: o.ea=o.y+9;break;
    case 0x2A: o.ea=o.y+10;break;
    case 0x2B: o.ea=o.y+11;break;
    case 0x2C: o.ea=o.y+12;break;
    case 0x2D: o.ea=o.y+13;break;
    case 0x2E: o.ea=o.y+14;break;
    case 0x2F: o.ea=o.y+15;break;
    case 0x30: o.ea=o.y-16;break;
    case 0x31: o.ea=o.y-15;break;
    case 0x32: o.ea=o.y-14;break;
    case 0x33: o.ea=o.y-13;break;
    case 0x34: o.ea=o.y-12;break;
    case 0x35: o.ea=o.y-11;break;
    case 0x36: o.ea=o.y-10;break;
    case 0x37: o.ea=o.y-9;break;
    case 0x38: o.ea=o.y-8;break;
    case 0x39: o.ea=o.y-7;break;
    case 0x3A: o.ea=o.y-6;break;
    case 0x3B: o.ea=o.y-5;break;
    case 0x3C: o.ea=o.y-4;break;
    case 0x3D: o.ea=o.y-3;break;
    case 0x3E: o.ea=o.y-2;break;
    case 0x3F: o.ea=o.y-1;break;
    case 0x40: o.ea=o.u;break;
    case 0x41: o.ea=o.u+1;break;
    case 0x42: o.ea=o.u+2;break;
    case 0x43: o.ea=o.u+3;break;
    case 0x44: o.ea=o.u+4;break;
    case 0x45: o.ea=o.u+5;break;
    case 0x46: o.ea=o.u+6;break;
    case 0x47: o.ea=o.u+7;break;
    case 0x48: o.ea=o.u+8;break;
    case 0x49: o.ea=o.u+9;break;
    case 0x4A: o.ea=o.u+10;break;
    case 0x4B: o.ea=o.u+11;break;
    case 0x4C: o.ea=o.u+12;break;
    case 0x4D: o.ea=o.u+13;break;
    case 0x4E: o.ea=o.u+14;break;
    case 0x4F: o.ea=o.u+15;break;
    case 0x50: o.ea=o.u-16;break;
    case 0x51: o.ea=o.u-15;break;
    case 0x52: o.ea=o.u-14;break;
    case 0x53: o.ea=o.u-13;break;
    case 0x54: o.ea=o.u-12;break;
    case 0x55: o.ea=o.u-11;break;
    case 0x56: o.ea=o.u-10;break;
    case 0x57: o.ea=o.u-9;break;
    case 0x58: o.ea=o.u-8;break;
    case 0x59: o.ea=o.u-7;break;
    case 0x5A: o.ea=o.u-6;break;
    case 0x5B: o.ea=o.u-5;break;
    case 0x5C: o.ea=o.u-4;break;
    case 0x5D: o.ea=o.u-3;break;
    case 0x5E: o.ea=o.u-2;break;
    case 0x5F: o.ea=o.u-1;break;
    case 0x60: o.ea=o.s;break;
    case 0x61: o.ea=o.s+1;break;
    case 0x62: o.ea=o.s+2;break;
    case 0x63: o.ea=o.s+3;break;
    case 0x64: o.ea=o.s+4;break;
    case 0x65: o.ea=o.s+5;break;
    case 0x66: o.ea=o.s+6;break;
    case 0x67: o.ea=o.s+7;break;
    case 0x68: o.ea=o.s+8;break;
    case 0x69: o.ea=o.s+9;break;
    case 0x6A: o.ea=o.s+10;break;
    case 0x6B: o.ea=o.s+11;break;
    case 0x6C: o.ea=o.s+12;break;
    case 0x6D: o.ea=o.s+13;break;
    case 0x6E: o.ea=o.s+14;break;
    case 0x6F: o.ea=o.s+15;break;
    case 0x70: o.ea=o.s-16;break;
    case 0x71: o.ea=o.s-15;break;
    case 0x72: o.ea=o.s-14;break;
    case 0x73: o.ea=o.s-13;break;
    case 0x74: o.ea=o.s-12;break;
    case 0x75: o.ea=o.s-11;break;
    case 0x76: o.ea=o.s-10;break;
    case 0x77: o.ea=o.s-9;break;
    case 0x78: o.ea=o.s-8;break;
    case 0x79: o.ea=o.s-7;break;
    case 0x7A: o.ea=o.s-6;break;
    case 0x7B: o.ea=o.s-5;break;
    case 0x7C: o.ea=o.s-4;break;
    case 0x7D: o.ea=o.s-3;break;
    case 0x7E: o.ea=o.s-2;break;
    case 0x7F: o.ea=o.s-1;break;
    case 0x80: o.ea=o.x;o.x++;break;
    case 0x81: o.ea=o.x;o.x+=2;break;
    case 0x82: o.x--;o.ea=o.x;break;
    case 0x83: o.x-=2;o.ea=o.x;break;
    case 0x84: o.ea=o.x;break;
    case 0x85: o.ea=o.x+Word(SWord(o.b));break;
    case 0x86: o.ea=o.x+Word(SWord(o.a));break;
    case 0x87: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0x88: o.ea=o.ImmByteWord();o.ea=o.x+o.ea;break;
    case 0x89: o.ea=o.ImmWord();o.ea+=o.x;break;
    case 0x8A: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0x8B: o.ea=o.x+o.GetD();break;
    case 0x8C: o.ea=o.ImmByteWord();o.ea=o.pc+o.ea;break;
    case 0x8D: o.ea=o.ImmWord();o.ea+=o.pc;break;
    case 0x8E: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0x8F: o.ea=o.ImmWord();break;
    case 0x90: o.ea=o.x;o.x++;o.ea=o.GetWordE();break;
    case 0x91: o.ea=o.x;o.x+=2;o.ea=o.GetWordE();break;
    case 0x92: o.x--;o.ea=o.x;o.ea=o.GetWordE();break;
    case 0x93: o.x-=2;o.ea=o.x;o.ea=o.GetWordE();break;
    case 0x94: o.ea=o.x;o.ea=o.GetWordE();break;
    case 0x95: o.ea=o.x+Word(SWord(o.b));o.ea=o.GetWordE();break;
    case 0x96: o.ea=o.x+Word(SWord(o.a));o.ea=o.GetWordE();break;
    case 0x97: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0x98: o.ea=o.ImmByteWord();o.ea=o.x+o.ea;
               o.ea=o.GetWordE();break;
    case 0x99: o.ea=o.ImmWord();o.ea+=o.x;o.ea=o.GetWordE();break;
    case 0x9A: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0x9B: o.ea=o.x+o.GetD();o.ea=o.GetWordE();break;
    case 0x9C: o.ea=o.ImmByteWord();o.ea=o.pc+o.ea;
               o.ea=o.GetWordE();break;
    case 0x9D: o.ea=o.ImmWord();o.ea+=o.pc;o.ea=o.GetWordE();break;
    case 0x9E: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0x9F: o.ea=o.ImmWord();o.ea=o.GetWordE();break;
    case 0xA0: o.ea=o.y;o.y++;break;
    case 0xA1: o.ea=o.y;o.y+=2;break;
    case 0xA2: o.y--;o.ea=o.y;break;
    case 0xA3: o.y-=2;o.ea=o.y;break;
    case 0xA4: o.ea=o.y;break;
    case 0xA5: o.ea=o.y+Word(SWord(o.b));break;
    case 0xA6: o.ea=o.y+Word(SWord(o.a));break;
    case 0xA7: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0xA8: o.ea=o.ImmByteWord();o.ea=o.y+o.ea;break;
    case 0xA9: o.ea=o.ImmWord();o.ea+=o.y;break;
    case 0xAA: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0xAB: o.ea=o.y+o.GetD();break;
    case 0xAC: o.ea=o.ImmByteWord();o.ea=o.pc+o.ea;break;
    case 0xAD: o.ea=o.ImmWord();o.ea+=o.pc;break;
    case 0xAE: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0xAF: o.ea=o.ImmWord();break;
    case 0xB0: o.ea=o.y;o.y++;o.ea=o.GetWordE();break;
    case 0xB1: o.ea=o.y;o.y+=2;o.ea=o.GetWordE();break;
    case 0xB2: o.y--;o.ea=o.y;o.ea=o.GetWordE();break;
    case 0xB3: o.y-=2;o.ea=o.y;o.ea=o.GetWordE();break;
    case 0xB4: o.ea=o.y;o.ea=o.GetWordE();break;
    case 0xB5: o.ea=o.y+Word(SWord(o.b));o.ea=o.GetWordE();break;
    case 0xB6: o.ea=o.y+Word(SWord(o.a));o.ea=o.GetWordE();break;
    case 0xB7: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0xB8: o.ea=o.ImmByteWord();o.ea=o.y+o.ea;
               o.ea=o.GetWordE();break;
    case 0xB9: o.ea=o.ImmWord();o.ea+=o.y;o.ea=o.GetWordE();break;
    case 0xBA: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0xBB: o.ea=o.y+o.GetD();o.ea=o.GetWordE();break;
    case 0xBC: o.ea=o.ImmByteWord();o.ea=o.pc+o.ea;
               o.ea=o.GetWordE();break;
    case 0xBD: o.ea=o.ImmWord();o.ea+=o.pc;o.ea=o.GetWordE();break;
    case 0xBE: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0xBF: o.ea=o.ImmWord();o.ea=o.GetWordE();break;
    case 0xC0: o.ea=o.u;o.u++;break;
    case 0xC1: o.ea=o.u;o.u+=2;break;
    case 0xC2: o.u--;o.ea=o.u;break;
    case 0xC3: o.u-=2;o.ea=o.u;break;
    case 0xC4: o.ea=o.u;break;
    case 0xC5: o.ea=o.u+Word(SWord(o.b));break;
    case 0xC6: o.ea=o.u+Word(SWord(o.a));break;
    case 0xC7: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0xC8: o.ea=o.ImmByteWord();o.ea=o.u+o.ea;break;
    case 0xC9: o.ea=o.ImmWord();o.ea+=o.u;break;
    case 0xCA: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0xCB: o.ea=o.u+o.GetD();break;
    case 0xCC: o.ea=o.ImmByteWord();o.ea=o.pc+o.ea;break;
    case 0xCD: o.ea=o.ImmWord();o.ea+=o.pc;break;
    case 0xCE: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0xCF: o.ea=o.ImmWord();break;
    case 0xD0: o.ea=o.u;o.u++;o.ea=o.GetWordE();break;
    case 0xD1: o.ea=o.u;o.u+=2;o.ea=o.GetWordE();break;
    case 0xD2: o.u--;o.ea=o.u;o.ea=o.GetWordE();break;
    case 0xD3: o.u-=2;o.ea=o.u;o.ea=o.GetWordE();break;
    case 0xD4: o.ea=o.u;o.ea=o.GetWordE();break;
    case 0xD5: o.ea=o.u+Word(SWord(o.b));o.ea=o.GetWordE();break;
    case 0xD6: o.ea=o.u+Word(SWord(o.a));o.ea=o.GetWordE();break;
    case 0xD7: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0xD8: o.ea=o.ImmByteWord();o.ea=o.u+o.ea;
               o.ea=o.GetWordE();break;
    case 0xD9: o.ea=o.ImmWord();o.ea+=o.u;o.ea=o.GetWordE();break;
    case 0xDA: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0xDB: o.ea=o.u+o.GetD();o.ea=o.GetWordE();break;
    case 0xDC: o.ea=o.ImmByteWord();o.ea=o.pc+o.ea;
               o.ea=o.GetWordE();break;
    case 0xDD: o.ea=o.ImmWord();o.ea+=o.pc;o.ea=o.GetWordE();break;
    case 0xDE: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0xDF: o.ea=o.ImmWord();o.ea=o.GetWordE();break;
    case 0xE0: o.ea=o.s;o.s++;break;
    case 0xE1: o.ea=o.s;o.s+=2;break;
    case 0xE2: o.s--;o.ea=o.s;break;
    case 0xE3: o.s-=2;o.ea=o.s;break;
    case 0xE4: o.ea=o.s;break;
    case 0xE5: o.ea=o.s+Word(SWord(o.b));break;
    case 0xE6: o.ea=o.s+Word(SWord(o.a));break;
    case 0xE7: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0xE8: o.ea=o.ImmByteWord();o.ea=o.s+o.ea;break;
    case 0xE9: o.ea=o.ImmWord();o.ea+=o.s;break;
    case 0xEA: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0xEB: o.ea=o.s+o.GetD();break;
    case 0xEC: o.ea=o.ImmByteWord();o.ea=o.pc+o.ea;break;
    case 0xED: o.ea=o.ImmWord();o.ea+=o.pc;break;
    case 0xEE: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0xEF: o.ea=o.ImmWord();break;
    case 0xF0: o.ea=o.s;o.s++;o.ea=o.GetWordE();break;
    case 0xF1: o.ea=o.s;o.s+=2;o.ea=o.GetWordE();break;
    case 0xF2: o.s--;o.ea=o.s;o.ea=o.GetWordE();break;
    case 0xF3: o.s-=2;o.ea=o.s;o.ea=o.GetWordE();break;
    case 0xF4: o.ea=o.s;o.ea=o.GetWordE();break;
    case 0xF5: o.ea=o.s+Word(SWord(o.b));o.ea=o.GetWordE();break;
    case 0xF6: o.ea=o.s+Word(SWord(o.a));o.ea=o.GetWordE();break;
    case 0xF7: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0xF8: o.ea=o.ImmByteWord();o.ea=o.s+o.ea;
               o.ea=o.GetWordE();break;
    case 0xF9: o.ea=o.ImmWord();o.ea+=o.s;o.ea=o.GetWordE();break;
    case 0xFA: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0xFB: o.ea=o.s+o.GetD();o.ea=o.GetWordE();break;
    case 0xFC: o.ea=o.ImmByteWord();o.ea=o.pc+o.ea;
               o.ea=o.GetWordE();break;
    case 0xFD: o.ea=o.ImmWord();o.ea+=o.pc;o.ea=o.GetWordE();break;
    case 0xFE: panic(F("ILLEGAL Prefix: 0x%02x", postbyte))
    case 0xFF: o.ea=o.ImmWord();o.ea=o.GetWordE();break;
   }
  // END IF POSTBYTE
  }


  switch(ireg) {
   case 0x00: /*NEG direct*/ o.EaDirect(); tw=Word(-SWord(o.GetByte(o.ea))); o.SetStatus(0,o.GetByte(o.ea),tw);
                             o.SetByteW(o.ea,tw); break;

   case 0x01: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
   case 0x02: panic(F("ILLEGAL Opcode: 0x%02x", ireg))

   case 0x03: /*COM direct*/ o.EaDirect();  tb=Byte(^SByte(o.GetByte(o.ea))); o.SetNZ8(tb);o.SEC(); o.CLV();
                             o.SetByte(o.ea,tb); break;

   case 0x04: /*LSR direct*/ o.EaDirect()
                             tb=o.mem[o.ea]
                             if(0 != tb&0x01) {o.SEC()} else {o.CLC()}
                             if(0 != tb&0x10){o.SEH()} else {o.CLH()}
                             tb>>=1
                             o.SetNZ8(tb)
                             o.SetByte(o.ea,tb)
   case 0x05: panic(F("ILLEGAL Opcode: 0x%02x", ireg))

   case 0x06: /*ROR direct*/ o.EaDirect()
                             tb=(o.cc&0x01)<<7;
                             if(0 != o.mem[o.ea]&0x01) {o.SEC()} else {o.CLC()}
                             tb2 := (o.mem[o.ea]>>1)+tb
                             o.SetNZ8(tb2)
                             o.SetByte(o.ea,tb2)
   case 0x07: /*ASR direct*/ o.EaDirect()
                             tb=o.mem[o.ea]
                             if(0 != tb&0x01) {o.SEC()} else {o.CLC()}
                             if(0 != tb&0x10){o.SEH()} else {o.CLH()}
                             tb>>=1
                             if(0 != tb&0x40){tb|=0x80}
                             o.SetByte(o.ea,tb)
                             o.SetNZ8(tb)
   case 0x08: /*ASL direct*/ o.EaDirect()
                             tw=Word(SWord(o.mem[o.ea]<<1));
                             o.SetStatus(o.mem[o.ea],o.mem[o.ea],tw)
                             o.SetByteW(o.ea,tw)
   case 0x09: /*ROL direct*/ o.EaDirect()
                             tb=o.mem[o.ea]
                             tw=Word(SWord(o.cc&0x01))
                             if(0 != tb&0x80) {o.SEC()} else {o.CLC()}
                             if(0 != ((tb&0x80)^((tb<<1)&0x80))) {o.SEV()} else {o.CLV()}
                             tb=(tb<<1)+Byte(tw)
                             o.SetNZ8(tb)
                             o.SetByte(o.ea,tb)

   case 0x0A: /*DEC direct*/ o.EaDirect()
             tb=o.mem[o.ea]-1
             if(tb==0x7F) {o.SEV()} else {o.CLV()}
   			     o.SetNZ8(tb)
             o.SetByte(o.ea,tb)
   case 0x0B: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
   case 0x0C: /*INC direct*/ o.EaDirect()
             tb=o.mem[o.ea]+1
             if(tb==0x80) {o.SEV()} else {o.CLV()}
			       o.SetNZ8(tb)
             o.SetByte(o.ea,tb)
   case 0x0D: /*TST direct*/ o.EaDirect(); tb=o.mem[o.ea];o.SetNZ8(tb)
   case 0x0E: /*JMP direct*/ o.EaDirect(); o.pc=o.ea
   case 0x0F: /*CLR direct*/ o.EaDirect(); o.SetByte(o.ea,0)
           o.CLN()
           o.CLV()
           o.SEZ()
           o.CLC()
   case 0x10: /* flag10 */ o.iflag=1; goto flaginstr
   case 0x11: /* flag11 */ o.iflag=2; goto flaginstr
   case 0x12: /* NOP */ break
//QQ   case 0x13: /* SYNC */ while(!irq)
//QQ                           ; /* Wait for IRQ */
//QQ		         if(o.cc&0x40)tracetrick=1;
//QQ		         break;
   case 0x14: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
   case 0x15: panic(F("ILLEGAL Opcode: 0x%02x", ireg))

   case 0x16: /*LBRA*/ o.ea=o.ImmWord(); o.pc+=o.ea
   case 0x17: /*LBSR*/ o.ea=o.ImmWord(); o.PushWordS(o.pc); o.pc+=o.ea

   case 0x18: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
   case 0x19: /* DAA*/ 	tw=Word(SWord(o.a));
			if(0 != o.cc&0x20) {tw+=6;}
			if((tw&0x0f)>9) {tw+=6;}
      if(0 != o.cc&0x01) {tw+=0x60;}
      if((tw&0xf0)>0x90) {tw+=0x60;}
      if(0 != tw&0x100) { o.SEC() }
      o.a=Byte(tw)
   case 0x1A: /* ORCC*/ tb=o.ImmByte(); o.cc|=tb
   case 0x1B: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
   case 0x1C: /* ANDCC*/ tb=o.ImmByte(); o.cc&=tb
   case 0x1D: /* SEX */ tw=Word(SWord(o.b)); o.SetNZ16(tw); o.SetD(tw);

   case 0x1E: /* EXG */ tb=o.ImmByte()
                         var t2 Word
                         tw = o.GetReg(tb>>4)
                         t2 = o.GetReg(tb&15)
                        o.SetReg(t2,tb>>4)
                        o.SetReg(tw,tb&15)
   case 0x1F: /* TFR */ tb=o.ImmByte()
                         tw = o.GetReg(tb>>4)
                         o.SetReg(tw,tb&15)

   case 0x20: /* (L)BRA*/  o.Branch(true)
   case 0x21: /* (L)BRN*/  o.Branch(false)
   case 0x22: /* (L)BHI*/  o.Branch(0 == (o.cc&0x05))
   case 0x23: /* (L)BLS*/  o.Branch(0 != o.cc&0x05)
   case 0x24: /* (L)BCC*/  o.Branch(0 == (o.cc&0x01))
   case 0x25: /* (L)BCS*/  o.Branch(0 != o.cc&0x01)
   case 0x26: /* (L)BNE*/  o.Branch(0 == (o.cc&0x04))
   case 0x27: /* (L)BEQ*/  o.Branch(0 != o.cc&0x04)
   case 0x28: /* (L)BVC*/  o.Branch(0 == (o.cc&0x02))
   case 0x29: /* (L)BVS*/  o.Branch(0 != o.cc&0x02)
   case 0x2A: /* (L)BPL*/  o.Branch(0 == (o.cc&0x08))
   case 0x2B: /* (L)BMI*/  o.Branch(0 != o.cc&0x08)
   case 0x2C: /* (L)BGE*/  o.Branch(!o.NXORV())
   case 0x2D: /* (L)BLT*/  o.Branch(o.NXORV())
   case 0x2E: /* (L)BGT*/  o.Branch(!(o.NXORV() || 0 != o.cc&0x04))
   case 0x2F: /* (L)BLE*/  o.Branch(o.NXORV() || 0 != o.cc&0x04)

   case 0x30: /* LEAX*/ o.x=o.ea; if(0 != o.x) {o.CLZ()} else {o.SEZ()}
   case 0x31: /* LEAY*/ o.y=o.ea; if(0 != o.y) {o.CLZ()} else {o.SEZ()}
   case 0x32: /* LEAS*/ o.s=o.ea;break;
   case 0x33: /* LEAU*/ o.u=o.ea;break;
   case 0x34: /* PSHS*/ tb=o.ImmByte();
   		if(0 != tb&0x80) {o.PushWordS(o.pc)}
	        if(0 != tb&0x40) {o.PushWordS(o.u)}
		if(0 != tb&0x20) {o.PushWordS(o.y)}
	        if(0 != tb&0x10) {o.PushWordS(o.x)}
                if(0 != tb&0x08) {o.PushByteS(o.dp)}
                if(0 != tb&0x04) {o.PushByteS(o.b)}
                if(0 != tb&0x02) {o.PushByteS(o.a)}
                if(0 != tb&0x01) {o.PushByteS(o.cc)}
   case 0x35: /* PULS*/ tb=o.ImmByte();
	        if(0 != tb&0x01) {o.cc = o.PullByteS()}
   		if(0 != tb&0x02) {o.a = o.PullByteS()}
     		if(0 != tb&0x04) {o.b = o.PullByteS()}
   		if(0 != tb&0x08) {o.dp = o.PullByteS()}
     		if(0 != tb&0x10) {o.x = o.PullWordS()}
 		if(0 != tb&0x20) {o.y = o.PullWordS()}
 		if(0 != tb&0x40) {o.u = o.PullWordS()}
 		if(0 != tb&0x80) {o.pc = o.PullWordS()}

/*
 		if(tracetrick&&tb==0xff) { // Arrange fake FIRQ after next insn for hardware tracing
		  tracetrick=0;
		  irq=2;
		  attention=1;
		  goto flaginstr;
 		}
*/
   case 0x36: /* PSHU*/ tb=o.ImmByte();
   		if(0 != tb&0x80) {o.PushWordU(o.pc)}
	        if(0 != tb&0x40) {o.PushWordU(o.s)}
		if(0 != tb&0x20) {o.PushWordU(o.y)}
	        if(0 != tb&0x10) {o.PushWordU(o.x)}
                if(0 != tb&0x08) {o.PushByteU(o.dp)}
                if(0 != tb&0x04) {o.PushByteU(o.b)}
                if(0 != tb&0x02) {o.PushByteU(o.a)}
                if(0 != tb&0x01) {o.PushByteU(o.cc) }
   case 0x37: /* PULU*/ tb=o.ImmByte();
	        if(0 != tb&0x01) {o.cc = o.PullByteU()}
   		if(0 != tb&0x02) {o.a = o.PullByteU()}
     		if(0 != tb&0x04) {o.b = o.PullByteU()}
   		if(0 != tb&0x08) {o.dp = o.PullByteU()}
     		if(0 != tb&0x10) {o.x = o.PullWordU()}
 		if(0 != tb&0x20) {o.y = o.PullWordU()}
 		if(0 != tb&0x40) {o.s = o.PullWordU()}
 		if(0 != tb&0x80) {o.pc = o.PullWordU()}

   case 0x39: /* RTS*/ o.pc=o.PullWordS() 
   case 0x3A: /* ABX*/ o.x+=Word(SWord(o.b)) 
   case 0x3B: /* RTI*/  tb=o.cc&0x80;
			o.cc=o.PullByteS()
			if(tb != 0) {
  			 o.a=o.PullByteS()
  			 o.b=o.PullByteS()
  			 o.dp=o.PullByteS()
  			 o.x=o.PullWordS()
	  		 o.y=o.PullWordS()
  			 o.u=o.PullWordS()
 			}
			o.pc=o.PullWordS() 
   case 0x3C: /* CWAI*/ tb=o.ImmByte();
   			 o.PushWordS(o.pc)
   			 o.PushWordS(o.u)
                   	 o.PushWordS(o.y)
   			 o.PushWordS(o.x)
   			 o.PushByteS(o.dp)
   			 o.PushByteS(o.b)
   			 o.PushByteS(o.a)
   			 o.PushByteS(o.cc)
   			 o.cc&=tb;
         o.cc|=0x80;
         panic(F("UNIMPLEMENTED Opcode: CWAI: 0x%02x", ireg))
         /*
                      while(!(irq==1&&!(o.cc&0x10)||irq==2&&!(o.cc&0x040)))
                           continue; // Wait for irq
                         if(irq==1)o.pc=GETWORD(0xfff8);
                         	else o.pc=GETWORD(0xfff6);
                         irq=0;
                         if(!tracing)attention=0;
   			 */
   case 0x3D: /* MUL*/ 
       tw=Word(SWord(SByte(o.a))*SWord(SByte(o.b)))
       if(0 != tw) {o.CLZ()} else  {o.SEZ()}
       if(0 != tw&0x80)  {o.SEC()} else {o.CLC()}
       o.SetD(tw);

   case 0x3E: panic(F("ILLEGAL Opcode: 0x%02x", ireg))

   case 0x3F: /* SWI (SWI2 SWI3)*/ {
			 o.PushWordS(o.pc)
			 o.PushWordS(o.u)
       o.PushWordS(o.y)
   			 o.PushWordS(o.x)
   			 o.PushByteS(o.dp)
   			 o.PushByteS(o.b)
   			 o.PushByteS(o.a)
   			 o.PushByteS(o.cc)
   			 o.cc|=0x80;
   			 switch(o.iflag) {
                          case 0:o.pc=o.GetWord(0xfffa)
   			                         o.cc|=0x50
                          case 1:o.pc=o.GetWord(0xfff4)
                          case 2:o.pc=o.GetWord(0xfff2)
                         }
		      }

   case 0x40: /*NEGA*/  
       tw=Word(-SWord(SByte(o.a)))
       o.SetStatus(0,o.a,tw)
       o.a=Byte(tw)
   case 0x41: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
   case 0x42: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
   case 0x43: /*COMA*/   
       tb= ^o.a
       o.SetNZ8(tb);
       {o.SEC()}
       {o.CLV()}
       o.a=tb
   case 0x44: /*LSRA*/  
     tb=o.a
     if(0 != tb&0x01) {o.SEC()} else {o.CLC()}
     if(0 != tb&0x10){o.SEH()} else {o.CLH()}
     tb>>=1
     o.SetNZ8(tb)
     o.a=tb
   case 0x45: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
   case 0x46: /*RORA*/  
     tb=(o.cc&0x01)<<7;
     if(0 != o.a&0x01) {o.SEC()} else {o.CLC()}
     o.a=(o.a>>1)+tb
     o.SetNZ8(o.a)

   case 0x47: /*ASRA*/  
     tb=o.a
     if(0 != tb&0x01) {o.SEC()} else {o.CLC()}
     if(0 != tb&0x10){o.SEH()} else {o.CLH()}
     tb>>=1;
     if(0 != tb&0x40) {tb|=0x80}
     o.a=tb
     o.SetNZ8(tb)

   case 0x48: /*ASLA*/  
     tw=Word(SByte(o.a))<<1;
     o.SetStatus(o.a,o.a,tw)
     o.a=Byte(tw);
   case 0x49: /*ROLA*/  
     tb=o.a
     tw= Word(o.cc&0x01)
     if(0 != tb&0x80) {o.SEC()} else {o.CLC()}
     if(0 != ((tb&0x80)^((tb<<1)&0x80))) {o.SEV()} else {o.CLV()}
     tb=Byte(  (Word(SWord(SByte(tb)))<<1)+tw )
     o.SetNZ8(tb)
     o.a=tb

   case 0x4A: /*DECA*/  
     tb=o.a-1
     if(tb==0x7F){o.SEV()} else {o.CLV()}
   	o.SetNZ8(tb) 
    o.a=tb

   case 0x4B: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
   case 0x4C: /*INCA*/  
     tb=o.a+1
     if(tb==0x80){o.SEV()} else {o.CLV()}
     o.SetNZ8(tb)
     o.a=tb
   case 0x4D: /*TSTA*/  
     o.SetNZ8(o.a)

   case 0x4E: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
   case 0x4F: /*CLRA*/  
     o.a=0
     o.CLN()
     o.CLV()
     o.SEZ()
     o.CLC()
   case 0x50: /*NEGB*/  
     tw= Word(SByte(-o.b))
     o.SetStatus(0,o.b,tw)
     o.b=Byte(tw)
   case 0x51: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
   case 0x52: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
   case 0x53: /*COMB*/   
     tb= ^o.b;
     o.SetNZ8(tb)
     {o.SEC()}
     {o.CLV()}
     o.b=tb
   case 0x54: /*LSRB*/  
     tb=o.b
     if(0 != tb&0x01) {o.SEC()} else {o.CLC()}
     if(0 != tb&0x10){o.SEH()} else {o.CLH()}
     tb>>=1
     o.SetNZ8(tb)
     o.b=tb
   case 0x55: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
//QQ   case 0x56: /*RORB*/  tb=(o.cc&0x01)<<7;
//QQ                             if(o.b&0x01) {o.SEC()} else {o.CLC()}
//QQ                             o.b=(o.b>>1)+tb;o.SetNZ8(o.b)
//QQ                       	     break;
//QQ   case 0x57: /*ASRB*/  tb=o.b;if(tb&0x01) {o.SEC()} else {o.CLC()}
//QQ                             if(tb&0x10){o.SEH()} else {o.CLH()} tb>>=1;
//QQ                             if(tb&0x40)tb|=0x80;o.b=tb;o.SetNZ8(tb)
//QQ                             break;
//QQ   case 0x58: /*ASLB*/  tw=o.b<<1;
//QQ                             o.SetStatus(o.b,o.b,tw)
//QQ                             o.b=tw;break;
//QQ   case 0x59: /*ROLB*/  tb=o.b;tw=o.cc&0x01;
//QQ                             if(tb&0x80) {o.SEC()} else {o.CLC()}
//QQ                             if((tb&0x80)^((tb<<1)&0x80)){o.SEV()} else {o.CLV()}
//QQ                             tb=(tb<<1)+tw;o.SetNZ8(tb) o.b=tb;break;
//QQ   case 0x5A: /*DECB*/  tb=o.b-1;if(tb==0x7F){o.SEV()} else {o.CLV()}
//QQ   			     o.SetNZ8(tb) o.b=tb;break;
   case 0x5B: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
//QQ   case 0x5C: /*INCB*/  tb=o.b+1;if(tb==0x80){o.SEV()} else {o.CLV()}
//QQ   			     o.SetNZ8(tb) o.b=tb;break;
//QQ   case 0x5D: /*TSTB*/  o.SetNZ8(o.b) break;
   case 0x5E: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
//QQ   case 0x5F: /*CLRB*/  o.b=0;CLN {o.CLV()} SEZ {o.CLC()} break;
//QQ   case 0x60: /*NEG indexed*/  tw=-o.mem[o.ea];o.SetStatus(0,o.mem[o.ea],tw)
//QQ                             o.SetByteW(o.ea,tw); break;
   case 0x61: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
   case 0x62: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
//QQ   case 0x63: /*COM indexed*/   tb=~o.mem[o.ea];o.SetNZ8(tb); {o.SEC()} {o.CLV()}
//QQ                             o.SetByte(o.ea,tb); break;
//QQ   case 0x64: /*LSR indexed*/  tb=o.mem[o.ea];if(tb&0x01) {o.SEC()} else {o.CLC()}
//QQ                             if(tb&0x10){o.SEH()} else {o.CLH()} tb>>=1;o.SetNZ8(tb)
//QQ                             o.SetByte(o.ea,tb); break;
   case 0x65: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
//QQ   case 0x66: /*ROR indexed*/  tb=(o.cc&0x01)<<7;
//QQ                             if(o.mem[o.ea]&0x01) {o.SEC()} else {o.CLC()}
//QQ                             tw=(o.mem[o.ea]>>1)+tb;o.SetNZ8(tw)
//QQ                             o.SetByteW(o.ea,tw)
//QQ                       	     break;
//QQ   case 0x67: /*ASR indexed*/  tb=o.mem[o.ea];if(tb&0x01) {o.SEC()} else {o.CLC()}
//QQ                             if(tb&0x10){o.SEH()} else {o.CLH()} tb>>=1;
//QQ                             if(tb&0x40)tb|=0x80;o.SetByte(o.ea,tb); o.SetNZ8(tb)
//QQ                             break;
//QQ   case 0x68: /*ASL indexed*/  tw=o.mem[o.ea]<<1;
//QQ                             o.SetStatus(o.mem[o.ea],o.mem[o.ea],tw)
//QQ                             o.SetByteW(o.ea,tw); break;
//QQ   case 0x69: /*ROL indexed*/  tb=o.mem[o.ea];tw=o.cc&0x01;
//QQ                             if(tb&0x80) {o.SEC()} else {o.CLC()}
//QQ                             if((tb&0x80)^((tb<<1)&0x80)){o.SEV()} else {o.CLV()}
//QQ                             tb=(tb<<1)+tw;o.SetNZ8(tb) o.SetByte(o.ea,tb); break;
//QQ   case 0x6A: /*DEC indexed*/  tb=o.mem[o.ea]-1;if(tb==0x7F){o.SEV()} else {o.CLV()}
//QQ   			     o.SetNZ8(tb) o.SetByte(o.ea,tb); break;
   case 0x6B: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
//QQ   case 0x6C: /*INC indexed*/  tb=o.mem[o.ea]+1;if(tb==0x80){o.SEV()} else {o.CLV()}
//QQ   			     o.SetNZ8(tb) o.SetByte(o.ea,tb); break;
//QQ   case 0x6D: /*TST indexed*/  tb=o.mem[o.ea];o.SetNZ8(tb) break;
//QQ   case 0x6E: /*JMP indexed*/  o.pc=o.ea;break;
//QQ   case 0x6F: /*CLR indexed*/  o.SetByte(o.ea,0); CLN {o.CLV()} SEZ {o.CLC()} break;
//QQ   case 0x70: /*NEG ext*/ o.EaExtended(); tw=-o.mem[o.ea];o.SetStatus(0,o.mem[o.ea],tw)
//QQ                             o.SetByteW(o.ea,tw); break;
   case 0x71: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
   case 0x72: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
//QQ   case 0x73: /*COM ext*/ o.EaExtended();  tb=~o.mem[o.ea];o.SetNZ8(tb); {o.SEC()} {o.CLV()}
//QQ                            o.SetByte(o.ea,tb); break;
//QQ   case 0x74: /*LSR ext*/ o.EaExtended(); tb=o.mem[o.ea];if(tb&0x01) {o.SEC()} else {o.CLC()}
//QQ                             if(tb&0x10){o.SEH()} else {o.CLH()} tb>>=1;o.SetNZ8(tb)
//QQ                             o.SetByte(o.ea,tb); break;
   case 0x75: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
//QQ   case 0x76: /*ROR ext*/ o.EaExtended(); tb=(o.cc&0x01)<<7;
//QQ                             if(o.mem[o.ea]&0x01) {o.SEC()} else {o.CLC()}
//QQ                             tw=(o.mem[o.ea]>>1)+tb;o.SetNZ8(tw)
//QQ                             o.SetByteW(o.ea,tw)
//QQ                       	     break;
//QQ   case 0x77: /*ASR ext*/ o.EaExtended(); tb=o.mem[o.ea];if(tb&0x01) {o.SEC()} else {o.CLC()}
//QQ                             if(tb&0x10){o.SEH()} else {o.CLH()} tb>>=1;
//QQ                             if(tb&0x40)tb|=0x80;o.SetByte(o.ea,tb); o.SetNZ8(tb)
//QQ                             break;
//QQ   case 0x78: /*ASL ext*/ o.EaExtended(); tw=o.mem[o.ea]<<1;
//QQ                             o.SetStatus(o.mem[o.ea],o.mem[o.ea],tw)
//QQ                             o.SetByteW(o.ea,tw); break;
//QQ   case 0x79: /*ROL ext*/ o.EaExtended(); tb=o.mem[o.ea];tw=o.cc&0x01;
//QQ                             if(tb&0x80) {o.SEC()} else {o.CLC()}
//QQ                             if((tb&0x80)^((tb<<1)&0x80)){o.SEV()} else {o.CLV()}
//QQ                             tb=(tb<<1)+tw;o.SetNZ8(tb) o.SetByte(o.ea,tb); break;
//QQ   case 0x7A: /*DEC ext*/ o.EaExtended(); tb=o.mem[o.ea]-1;if(tb==0x7F){o.SEV()} else {o.CLV()}
//QQ   			     o.SetNZ8(tb) o.SetByte(o.ea,tb); break;
   case 0x7B: panic(F("ILLEGAL Opcode: 0x%02x", ireg))
//QQ   case 0x7C: /*INC ext*/ o.EaExtended(); tb=o.mem[o.ea]+1;if(tb==0x80){o.SEV()} else {o.CLV()}
//QQ   			     o.SetNZ8(tb) o.SetByte(o.ea,tb); break;
//QQ   case 0x7D: /*TST ext*/ o.EaExtended(); tb=o.mem[o.ea];o.SetNZ8(tb) break;
//QQ   case 0x7E: /*JMP ext*/ o.EaExtended(); o.pc=o.ea;break;
//QQ   case 0x7F: /*CLR ext*/ o.EaExtended(); o.SetByte(o.ea,0); CLN {o.CLV()} SEZ {o.CLC()} break;
//QQ   case 0x80: /*SUBA immediate*/ o.EaImm8(); tw=o.a-o.mem[o.ea];
//QQ                                 o.SetStatus(o.a,o.mem[o.ea],tw)
//QQ                                 o.a=tw;break;
//QQ   case 0x81: /*CMPA immediate*/ o.EaImm8(); tw=o.a-o.mem[o.ea];
//QQ   				 o.SetStatus(o.a,o.mem[o.ea],tw) break;
//QQ   case 0x82: /*SBCA immediate*/ o.EaImm8(); tw=o.a-o.mem[o.ea]-(o.cc&0x01);
//QQ   				 o.SetStatus(o.a,o.mem[o.ea],tw)
//QQ   				 o.a=tw;break;
//QQ   case 0x83: /*SUBD (CMPD CMPU) immediate*/ o.EaImm16();
//QQ                                 {unsigned long res,dreg,breg;
//QQ                                 if(o.iflag==2)dreg=o.u;else dreg=o.GetD();
//QQ                                 breg=o.GetWordE();
//QQ                                 res=dreg-breg;
//QQ                                 SETSTATUSD(dreg,breg,res)
//QQ                                 if(o.iflag==0) o.SetD(res)
//QQ                                 }break;
//QQ   case 0x84: /*ANDA immediate*/ o.EaImm8(); o.a=o.a&o.mem[o.ea];o.SetNZ8(o.a)
//QQ   				 {o.CLV()} break;
//QQ   case 0x85: /*BITA immediate*/ o.EaImm8(); tb=o.a&o.mem[o.ea];o.SetNZ8(tb)
//QQ   				 {o.CLV()} break;
//QQ   case 0x86: /*LDA immediate*/ o.EaImm8(); LOADAC(o.a) {o.CLV()} o.SetNZ8(o.a)
//QQ                                 break;
//QQ   case 0x87: /*STA immediate (for the sake of orthogonality) */ o.EaImm8();
//QQ                                 o.SetNZ8(o.a) {o.CLV()} STOREAC(o.a) break;
//QQ   case 0x88: /*EORA immediate*/ o.EaImm8(); o.a=o.a^o.mem[o.ea];o.SetNZ8(o.a)
//QQ   				 {o.CLV()} break;
//QQ   case 0x89: /*ADCA immediate*/ o.EaImm8(); tw=o.a+o.mem[o.ea]+(o.cc&0x01);
//QQ                                 o.SetStatus(o.a,o.mem[o.ea],tw)
//QQ                                 o.a=tw;break;
//QQ   case 0x8A: /*ORA immediate*/  o.EaImm8(); o.a=o.a|o.mem[o.ea];o.SetNZ8(o.a)
//QQ   				 {o.CLV()} break;
//QQ   case 0x8B: /*ADDA immediate*/ o.EaImm8(); tw=o.a+o.mem[o.ea];
//QQ   				 o.SetStatus(o.a,o.mem[o.ea],tw)
//QQ   				 o.a=tw;break;
//QQ   case 0x8C: /*CMPX (CMPY CMPS) immediate */ o.EaImm16();
//QQ                                 {unsigned long dreg,breg,res;
//QQ   				 if(o.iflag==0)dreg=o.x;else if(o.iflag==1)
//QQ   				 dreg=o.y;else dreg=o.s;breg=o.GetWordE();
//QQ   				 res=dreg-breg;
//QQ   				 SETSTATUSD(dreg,breg,res)
//QQ   				 }break;
//QQ   case 0x8D: /*BSR */   tb=o.ImmByte(); o.PushWordS(o.pc) o.pc+=SIGNED(tb);
//QQ                         break;
//QQ   case 0x8E: /* LDX (LDY) immediate */ o.EaImm16(); tw=o.GetWordE();
//QQ                                  {o.CLV()} o.SetNZ16(tw) if(!o.iflag)o.x=tw; else
//QQ                                  o.y=tw;break;
//QQ   case 0x8F:  /* STX (STY) immediate (orthogonality) */ o.EaImm16();
//QQ                                  if(!o.iflag) tw=o.x; else tw=o.y;
//QQ                                  {o.CLV()} o.SetNZ16(tw) SETWORD(o.ea,tw) break;
//QQ   case 0x90: /*SUBA direct*/ o.EaDirect(); tw=o.a-o.mem[o.ea];
//QQ                                 o.SetStatus(o.a,o.mem[o.ea],tw)
//QQ                                 o.a=tw;break;
//QQ   case 0x91: /*CMPA direct*/ o.EaDirect(); tw=o.a-o.mem[o.ea];
//QQ   				 o.SetStatus(o.a,o.mem[o.ea],tw) break;
//QQ   case 0x92: /*SBCA direct*/ o.EaDirect(); tw=o.a-o.mem[o.ea]-(o.cc&0x01);
//QQ   				 o.SetStatus(o.a,o.mem[o.ea],tw)
//QQ   				 o.a=tw;break;
//QQ   case 0x93: /*SUBD (CMPD CMPU) direct*/ o.EaDirect();
//QQ                                 {unsigned long res,dreg,breg;
//QQ                                 if(o.iflag==2)dreg=o.u;else dreg=o.GetD();
//QQ                                 breg=o.GetWordE();
//QQ                                 res=dreg-breg;
//QQ                                 SETSTATUSD(dreg,breg,res)
//QQ                                 if(o.iflag==0) o.SetD(res)
//QQ                                 }break;
//QQ   case 0x94: /*ANDA direct*/ o.EaDirect(); o.a=o.a&o.mem[o.ea];o.SetNZ8(o.a)
//QQ   				 {o.CLV()} break;
//QQ   case 0x95: /*BITA direct*/ o.EaDirect(); tb=o.a&o.mem[o.ea];o.SetNZ8(tb)
//QQ   				 {o.CLV()} break;
//QQ   case 0x96: /*LDA direct*/ o.EaDirect(); LOADAC(o.a) {o.CLV()} o.SetNZ8(o.a)
//QQ                                 break;
//QQ   case 0x97: /*STA direct */ o.EaDirect();
//QQ                                 o.SetNZ8(o.a) {o.CLV()} STOREAC(o.a) break;
//QQ   case 0x98: /*EORA direct*/ o.EaDirect(); o.a=o.a^o.mem[o.ea];o.SetNZ8(o.a)
//QQ   				 {o.CLV()} break;
//QQ   case 0x99: /*ADCA direct*/ o.EaDirect(); tw=o.a+o.mem[o.ea]+(o.cc&0x01);
//QQ                                 o.SetStatus(o.a,o.mem[o.ea],tw)
//QQ                                 o.a=tw;break;
//QQ   case 0x9A: /*ORA direct*/  o.EaDirect(); o.a=o.a|o.mem[o.ea];o.SetNZ8(o.a)
//QQ   				 {o.CLV()} break;
//QQ   case 0x9B: /*ADDA direct*/ o.EaDirect(); tw=o.a+o.mem[o.ea];
//QQ   				 o.SetStatus(o.a,o.mem[o.ea],tw)
//QQ   				 o.a=tw;break;
//QQ   case 0x9C: /*CMPX (CMPY CMPS) direct */ o.EaDirect();
//QQ                                 {unsigned long dreg,breg,res;
//QQ   				 if(o.iflag==0)dreg=o.x;else if(o.iflag==1)
//QQ   				 dreg=o.y;else dreg=o.s;breg=o.GetWordE();
//QQ   				 res=dreg-breg;
//QQ   				 SETSTATUSD(dreg,breg,res)
//QQ   				 }break;
//QQ   case 0x9D: /*JSR direct */  o.EaDirect();  o.PushWordS(o.pc) o.pc=o.ea;
//QQ                         break;
//QQ   case 0x9E: /* LDX (LDY) direct */ o.EaDirect(); tw=o.GetWordE();
//QQ                                  {o.CLV()} o.SetNZ16(tw) if(!o.iflag)o.x=tw; else
//QQ                                  o.y=tw;break;
//QQ   case 0x9F:  /* STX (STY) direct */ o.EaDirect();
//QQ                                  if(!o.iflag) tw=o.x; else tw=o.y;
//QQ                                  {o.CLV()} o.SetNZ16(tw) SETWORD(o.ea,tw) break;
//QQ   case 0xA0: /*SUBA indexed*/  tw=o.a-o.mem[o.ea];
//QQ                                 o.SetStatus(o.a,o.mem[o.ea],tw)
//QQ                                 o.a=tw;break;
//QQ   case 0xA1: /*CMPA indexed*/  tw=o.a-o.mem[o.ea];
//QQ   				 o.SetStatus(o.a,o.mem[o.ea],tw) break;
//QQ   case 0xA2: /*SBCA indexed*/  tw=o.a-o.mem[o.ea]-(o.cc&0x01);
//QQ   				 o.SetStatus(o.a,o.mem[o.ea],tw)
//QQ   				 o.a=tw;break;
//QQ   case 0xA3: /*SUBD (CMPD CMPU) indexed*/
//QQ                                 {unsigned long res,dreg,breg;
//QQ                                 if(o.iflag==2)dreg=o.u;else dreg=o.GetD();
//QQ                                 breg=o.GetWordE();
//QQ                                 res=dreg-breg;
//QQ                                 SETSTATUSD(dreg,breg,res)
//QQ                                 if(o.iflag==0) o.SetD(res)
//QQ                                 }break;
//QQ   case 0xA4: /*ANDA indexed*/  o.a=o.a&o.mem[o.ea];o.SetNZ8(o.a)
//QQ   				 {o.CLV()} break;
//QQ   case 0xA5: /*BITA indexed*/  tb=o.a&o.mem[o.ea];o.SetNZ8(tb)
//QQ   				 {o.CLV()} break;
//QQ   case 0xA6: /*LDA indexed*/  LOADAC(o.a) {o.CLV()} o.SetNZ8(o.a)
//QQ                                 break;
//QQ   case 0xA7: /*STA indexed */
//QQ                                 o.SetNZ8(o.a) {o.CLV()} STOREAC(o.a) break;
//QQ   case 0xA8: /*EORA indexed*/  o.a=o.a^o.mem[o.ea];o.SetNZ8(o.a)
//QQ   				 {o.CLV()} break;
//QQ   case 0xA9: /*ADCA indexed*/  tw=o.a+o.mem[o.ea]+(o.cc&0x01);
//QQ                                 o.SetStatus(o.a,o.mem[o.ea],tw)
//QQ                                 o.a=tw;break;
//QQ   case 0xAA: /*ORA indexed*/   o.a=o.a|o.mem[o.ea];o.SetNZ8(o.a)
//QQ   				 {o.CLV()} break;
//QQ   case 0xAB: /*ADDA indexed*/  tw=o.a+o.mem[o.ea];
//QQ   				 o.SetStatus(o.a,o.mem[o.ea],tw)
//QQ   				 o.a=tw;break;
//QQ   case 0xAC: /*CMPX (CMPY CMPS) indexed */
//QQ                                 {unsigned long dreg,breg,res;
//QQ   				 if(o.iflag==0)dreg=o.x;else if(o.iflag==1)
//QQ   				 dreg=o.y;else dreg=o.s;breg=o.GetWordE();
//QQ   				 res=dreg-breg;
//QQ   				 SETSTATUSD(dreg,breg,res)
//QQ   				 }break;
//QQ   case 0xAD: /*JSR indexed */    o.PushWordS(o.pc) o.pc=o.ea;
//QQ                         break;
//QQ   case 0xAE: /* LDX (LDY) indexed */  tw=o.GetWordE();
//QQ                                  {o.CLV()} o.SetNZ16(tw) if(!o.iflag)o.x=tw; else
//QQ                                  o.y=tw;break;
//QQ   case 0xAF:  /* STX (STY) indexed */
//QQ                                  if(!o.iflag) tw=o.x; else tw=o.y;
//QQ                                  {o.CLV()} o.SetNZ16(tw) SETWORD(o.ea,tw) break;
//QQ   case 0xB0: /*SUBA ext*/ o.EaExtended(); tw=o.a-o.mem[o.ea];
//QQ                                 o.SetStatus(o.a,o.mem[o.ea],tw)
//QQ                                 o.a=tw;break;
//QQ   case 0xB1: /*CMPA ext*/ o.EaExtended(); tw=o.a-o.mem[o.ea];
//QQ   				 o.SetStatus(o.a,o.mem[o.ea],tw) break;
//QQ   case 0xB2: /*SBCA ext*/ o.EaExtended(); tw=o.a-o.mem[o.ea]-(o.cc&0x01);
//QQ   				 o.SetStatus(o.a,o.mem[o.ea],tw)
//QQ   				 o.a=tw;break;
//QQ   case 0xB3: /*SUBD (CMPD CMPU) ext*/ o.EaExtended();
//QQ                                 {unsigned long res,dreg,breg;
//QQ                                 if(o.iflag==2)dreg=o.u;else dreg=o.GetD();
//QQ                                 breg=o.GetWordE();
//QQ                                 res=dreg-breg;
//QQ                                 SETSTATUSD(dreg,breg,res)
//QQ                                 if(o.iflag==0) o.SetD(res)
//QQ                                 }break;
//QQ   case 0xB4: /*ANDA ext*/ o.EaExtended(); o.a=o.a&o.mem[o.ea];o.SetNZ8(o.a)
//QQ   				 {o.CLV()} break;
//QQ   case 0xB5: /*BITA ext*/ o.EaExtended(); tb=o.a&o.mem[o.ea];o.SetNZ8(tb)
//QQ   				 {o.CLV()} break;
//QQ   case 0xB6: /*LDA ext*/ o.EaExtended(); LOADAC(o.a) {o.CLV()} o.SetNZ8(o.a)
//QQ                                 break;
//QQ   case 0xB7: /*STA ext */ o.EaExtended();
//QQ                                 o.SetNZ8(o.a) {o.CLV()} STOREAC(o.a) break;
//QQ   case 0xB8: /*EORA ext*/ o.EaExtended(); o.a=o.a^o.mem[o.ea];o.SetNZ8(o.a)
//QQ   				 {o.CLV()} break;
//QQ   case 0xB9: /*ADCA ext*/ o.EaExtended(); tw=o.a+o.mem[o.ea]+(o.cc&0x01);
//QQ                                 o.SetStatus(o.a,o.mem[o.ea],tw)
//QQ                                 o.a=tw;break;
//QQ   case 0xBA: /*ORA ext*/  o.EaExtended(); o.a=o.a|o.mem[o.ea];o.SetNZ8(o.a)
//QQ   				 {o.CLV()} break;
//QQ   case 0xBB: /*ADDA ext*/ o.EaExtended(); tw=o.a+o.mem[o.ea];
//QQ   				 o.SetStatus(o.a,o.mem[o.ea],tw)
//QQ   				 o.a=tw;break;
//QQ   case 0xBC: /*CMPX (CMPY CMPS) ext */ o.EaExtended();
//QQ                                 {unsigned long dreg,breg,res;
//QQ   				 if(o.iflag==0)dreg=o.x;else if(o.iflag==1)
//QQ   				 dreg=o.y;else dreg=o.s;breg=o.GetWordE();
//QQ   				 res=dreg-breg;
//QQ   				 SETSTATUSD(dreg,breg,res)
//QQ   				 }break;
//QQ   case 0xBD: /*JSR ext */  o.EaExtended();  o.PushWordS(o.pc) o.pc=o.ea;
//QQ                         break;
//QQ   case 0xBE: /* LDX (LDY) ext */ o.EaExtended(); tw=o.GetWordE();
//QQ                                  {o.CLV()} o.SetNZ16(tw) if(!o.iflag)o.x=tw; else
//QQ                                  o.y=tw;break;
//QQ   case 0xBF:  /* STX (STY) ext */ o.EaExtended();
//QQ                                  if(!o.iflag) tw=o.x; else tw=o.y;
//QQ                                  {o.CLV()} o.SetNZ16(tw) SETWORD(o.ea,tw) break;
//QQ   case 0xC0: /*SUBB immediate*/ o.EaImm8(); tw=o.b-o.mem[o.ea];
//QQ                                 o.SetStatus(o.b,o.mem[o.ea],tw)
//QQ                                 o.b=tw;break;
//QQ   case 0xC1: /*CMPB immediate*/ o.EaImm8(); tw=o.b-o.mem[o.ea];
//QQ   				 o.SetStatus(o.b,o.mem[o.ea],tw) break;
//QQ   case 0xC2: /*SBCB immediate*/ o.EaImm8(); tw=o.b-o.mem[o.ea]-(o.cc&0x01);
//QQ   				 o.SetStatus(o.b,o.mem[o.ea],tw)
//QQ   				 o.b=tw;break;
//QQ   case 0xC3: /*ADDD immediate*/ o.EaImm16();
//QQ                                 {unsigned long res,dreg,breg;
//QQ                                 dreg=o.GetD();
//QQ                                 breg=o.GetWordE();
//QQ                                 res=dreg+breg;
//QQ                                 SETSTATUSD(dreg,breg,res)
//QQ                                 o.SetD(res)
//QQ                                 }break;
//QQ   case 0xC4: /*ANDB immediate*/ o.EaImm8(); o.b=o.b&o.mem[o.ea];o.SetNZ8(o.b)
//QQ   				 {o.CLV()} break;
//QQ   case 0xC5: /*BITB immediate*/ o.EaImm8(); tb=o.b&o.mem[o.ea];o.SetNZ8(tb)
//QQ   				 {o.CLV()} break;
//QQ   case 0xC6: /*LDB immediate*/ o.EaImm8(); LOADAC(o.b) {o.CLV()} o.SetNZ8(o.b)
//QQ                                 break;
//QQ   case 0xC7: /*STB immediate (for the sake of orthogonality) */ o.EaImm8();
//QQ                                 o.SetNZ8(o.b) {o.CLV()} STOREAC(o.b) break;
//QQ   case 0xC8: /*EORB immediate*/ o.EaImm8(); o.b=o.b^o.mem[o.ea];o.SetNZ8(o.b)
//QQ   				 {o.CLV()} break;
//QQ   case 0xC9: /*ADCB immediate*/ o.EaImm8(); tw=o.b+o.mem[o.ea]+(o.cc&0x01);
//QQ                                 o.SetStatus(o.b,o.mem[o.ea],tw)
//QQ                                 o.b=tw;break;
//QQ   case 0xCA: /*ORB immediate*/  o.EaImm8(); o.b=o.b|o.mem[o.ea];o.SetNZ8(o.b)
//QQ   				 {o.CLV()} break;
//QQ   case 0xCB: /*ADDB immediate*/ o.EaImm8(); tw=o.b+o.mem[o.ea];
//QQ   				 o.SetStatus(o.b,o.mem[o.ea],tw)
//QQ   				 o.b=tw;break;
//QQ   case 0xCC: /*LDD immediate */ o.EaImm16(); tw=o.GetWordE();o.SetNZ16(tw)
//QQ   			         {o.CLV()} o.SetD(tw); break;
//QQ   case 0xCD: /*STD immediate (orthogonality) */ o.EaImm16();
//QQ   				 tw=o.GetD(); o.SetNZ16(tw) {o.CLV()}
//QQ   				 SETWORD(o.ea,tw) break;
//QQ   case 0xCE: /* LDU (LDS) immediate */ o.EaImm16(); tw=o.GetWordE();
//QQ                                  {o.CLV()} o.SetNZ16(tw) if(!o.iflag)o.u=tw; else
//QQ                                  o.s=tw;break;
//QQ   case 0xCF:  /* STU (STS) immediate (orthogonality) */ o.EaImm16();
//QQ                                  if(!o.iflag) tw=o.u; else tw=o.s;
//QQ                                  {o.CLV()} o.SetNZ16(tw) SETWORD(o.ea,tw) break;
//QQ   case 0xD0: /*SUBB direct*/ o.EaDirect(); tw=o.b-o.mem[o.ea];
//QQ                                 o.SetStatus(o.b,o.mem[o.ea],tw)
//QQ                                 o.b=tw;break;
//QQ   case 0xD1: /*CMPB direct*/ o.EaDirect(); tw=o.b-o.mem[o.ea];
//QQ   				 o.SetStatus(o.b,o.mem[o.ea],tw) break;
//QQ   case 0xD2: /*SBCB direct*/ o.EaDirect(); tw=o.b-o.mem[o.ea]-(o.cc&0x01);
//QQ   				 o.SetStatus(o.b,o.mem[o.ea],tw)
//QQ   				 o.b=tw;break;
//QQ   case 0xD3: /*ADDD direct*/ o.EaDirect();
//QQ                                 {unsigned long res,dreg,breg;
//QQ                                 dreg=o.GetD();
//QQ                                 breg=o.GetWordE();
//QQ                                 res=dreg+breg;
//QQ                                 SETSTATUSD(dreg,breg,res)
//QQ                                 o.SetD(res)
//QQ                                 }break;
//QQ   case 0xD4: /*ANDB direct*/ o.EaDirect(); o.b=o.b&o.mem[o.ea];o.SetNZ8(o.b)
//QQ   				 {o.CLV()} break;
//QQ   case 0xD5: /*BITB direct*/ o.EaDirect(); tb=o.b&o.mem[o.ea];o.SetNZ8(tb)
//QQ   				 {o.CLV()} break;
//QQ   case 0xD6: /*LDB direct*/ o.EaDirect(); LOADAC(o.b) {o.CLV()} o.SetNZ8(o.b)
//QQ                                 break;
//QQ   case 0xD7: /*STB direct  */ o.EaDirect();
//QQ                                 o.SetNZ8(o.b) {o.CLV()} STOREAC(o.b) break;
//QQ   case 0xD8: /*EORB direct*/ o.EaDirect(); o.b=o.b^o.mem[o.ea];o.SetNZ8(o.b)
//QQ   				 {o.CLV()} break;
//QQ   case 0xD9: /*ADCB direct*/ o.EaDirect(); tw=o.b+o.mem[o.ea]+(o.cc&0x01);
//QQ                                 o.SetStatus(o.b,o.mem[o.ea],tw)
//QQ                                 o.b=tw;break;
//QQ   case 0xDA: /*ORB direct*/  o.EaDirect(); o.b=o.b|o.mem[o.ea];o.SetNZ8(o.b)
//QQ   				 {o.CLV()} break;
//QQ   case 0xDB: /*ADDB direct*/ o.EaDirect(); tw=o.b+o.mem[o.ea];
//QQ   				 o.SetStatus(o.b,o.mem[o.ea],tw)
//QQ   				 o.b=tw;break;
//QQ   case 0xDC: /*LDD direct */ o.EaDirect(); tw=o.GetWordE();o.SetNZ16(tw)
//QQ   			         {o.CLV()} o.SetD(tw); break;
//QQ   case 0xDD: /*STD direct  */ o.EaDirect();
//QQ   				 tw=o.GetD(); o.SetNZ16(tw) {o.CLV()}
//QQ   				 SETWORD(o.ea,tw) break;
//QQ   case 0xDE: /* LDU (LDS) direct */ o.EaDirect(); tw=o.GetWordE();
//QQ                                  {o.CLV()} o.SetNZ16(tw) if(!o.iflag)o.u=tw; else
//QQ                                  o.s=tw;break;
//QQ   case 0xDF:  /* STU (STS) direct  */ o.EaDirect();
//QQ                                  if(!o.iflag) tw=o.u; else tw=o.s;
//QQ                                  {o.CLV()} o.SetNZ16(tw) SETWORD(o.ea,tw) break;
//QQ   case 0xE0: /*SUBB indexed*/  tw=o.b-o.mem[o.ea];
//QQ                                 o.SetStatus(o.b,o.mem[o.ea],tw)
//QQ                                 o.b=tw;break;
//QQ   case 0xE1: /*CMPB indexed*/  tw=o.b-o.mem[o.ea];
//QQ   				 o.SetStatus(o.b,o.mem[o.ea],tw) break;
//QQ   case 0xE2: /*SBCB indexed*/  tw=o.b-o.mem[o.ea]-(o.cc&0x01);
//QQ   				 o.SetStatus(o.b,o.mem[o.ea],tw)
//QQ   				 o.b=tw;break;
//QQ   case 0xE3: /*ADDD indexed*/
//QQ                                 {unsigned long res,dreg,breg;
//QQ                                 dreg=o.GetD();
//QQ                                 breg=o.GetWordE();
//QQ                                 res=dreg+breg;
//QQ                                 SETSTATUSD(dreg,breg,res)
//QQ                                 o.SetD(res)
//QQ                                 }break;
//QQ   case 0xE4: /*ANDB indexed*/  o.b=o.b&o.mem[o.ea];o.SetNZ8(o.b)
//QQ   				 {o.CLV()} break;
//QQ   case 0xE5: /*BITB indexed*/  tb=o.b&o.mem[o.ea];o.SetNZ8(tb)
//QQ   				 {o.CLV()} break;
//QQ   case 0xE6: /*LDB indexed*/  LOADAC(o.b) {o.CLV()} o.SetNZ8(o.b)
//QQ                                 break;
//QQ   case 0xE7: /*STB indexed  */
//QQ                                 o.SetNZ8(o.b) {o.CLV()} STOREAC(o.b) break;
//QQ   case 0xE8: /*EORB indexed*/  o.b=o.b^o.mem[o.ea];o.SetNZ8(o.b)
//QQ   				 {o.CLV()} break;
//QQ   case 0xE9: /*ADCB indexed*/  tw=o.b+o.mem[o.ea]+(o.cc&0x01);
//QQ                                 o.SetStatus(o.b,o.mem[o.ea],tw)
//QQ                                 o.b=tw;break;
//QQ   case 0xEA: /*ORB indexed*/   o.b=o.b|o.mem[o.ea];o.SetNZ8(o.b)
//QQ   				 {o.CLV()} break;
//QQ   case 0xEB: /*ADDB indexed*/  tw=o.b+o.mem[o.ea];
//QQ   				 o.SetStatus(o.b,o.mem[o.ea],tw)
//QQ   				 o.b=tw;break;
//QQ   case 0xEC: /*LDD indexed */  tw=o.GetWordE();o.SetNZ16(tw)
//QQ   			         {o.CLV()} o.SetD(tw); break;
//QQ   case 0xED: /*STD indexed  */
//QQ   				 tw=o.GetD(); o.SetNZ16(tw) {o.CLV()}
//QQ   				 SETWORD(o.ea,tw) break;
//QQ   case 0xEE: /* LDU (LDS) indexed */  tw=o.GetWordE();
//QQ                                  {o.CLV()} o.SetNZ16(tw) if(!o.iflag)o.u=tw; else
//QQ                                  o.s=tw;break;
//QQ   case 0xEF:  /* STU (STS) indexed  */
//QQ                                  if(!o.iflag) tw=o.u; else tw=o.s;
//QQ                                  {o.CLV()} o.SetNZ16(tw) SETWORD(o.ea,tw) break;
//QQ   case 0xF0: /*SUBB ext*/ o.EaExtended(); tw=o.b-o.mem[o.ea];
//QQ                                 o.SetStatus(o.b,o.mem[o.ea],tw)
//QQ                                 o.b=tw;break;
//QQ   case 0xF1: /*CMPB ext*/ o.EaExtended(); tw=o.b-o.mem[o.ea];
//QQ   				 o.SetStatus(o.b,o.mem[o.ea],tw) break;
//QQ   case 0xF2: /*SBCB ext*/ o.EaExtended(); tw=o.b-o.mem[o.ea]-(o.cc&0x01);
//QQ   				 o.SetStatus(o.b,o.mem[o.ea],tw)
//QQ   				 o.b=tw;break;
//QQ   case 0xF3: /*ADDD ext*/ o.EaExtended();
//QQ                                 {unsigned long res,dreg,breg;
//QQ                                 dreg=o.GetD();
//QQ                                 breg=o.GetWordE();
//QQ                                 res=dreg+breg;
//QQ                                 SETSTATUSD(dreg,breg,res)
//QQ                                 o.SetD(res)
//QQ                                 }break;
//QQ   case 0xF4: /*ANDB ext*/ o.EaExtended(); o.b=o.b&o.mem[o.ea];o.SetNZ8(o.b)
//QQ   				 {o.CLV()} break;
//QQ   case 0xF5: /*BITB ext*/ o.EaExtended(); tb=o.b&o.mem[o.ea];o.SetNZ8(tb)
//QQ   				 {o.CLV()} break;
//QQ   case 0xF6: /*LDB ext*/ o.EaExtended(); LOADAC(o.b) {o.CLV()} o.SetNZ8(o.b)
//QQ                                 break;
//QQ   case 0xF7: /*STB ext  */ o.EaExtended();
//QQ                                 o.SetNZ8(o.b) {o.CLV()} STOREAC(o.b) break;
//QQ   case 0xF8: /*EORB ext*/ o.EaExtended(); o.b=o.b^o.mem[o.ea];o.SetNZ8(o.b)
//QQ   				 {o.CLV()} break;
//QQ   case 0xF9: /*ADCB ext*/ o.EaExtended(); tw=o.b+o.mem[o.ea]+(o.cc&0x01);
//QQ                                 o.SetStatus(o.b,o.mem[o.ea],tw)
//QQ                                 o.b=tw;break;
//QQ   case 0xFA: /*ORB ext*/  o.EaExtended(); o.b=o.b|o.mem[o.ea];o.SetNZ8(o.b)
//QQ   				 {o.CLV()} break;
//QQ   case 0xFB: /*ADDB ext*/ o.EaExtended(); tw=o.b+o.mem[o.ea];
//QQ   				 o.SetStatus(o.b,o.mem[o.ea],tw)
//QQ   				 o.b=tw;break;
//QQ   case 0xFC: /*LDD ext */ o.EaExtended(); tw=o.GetWordE();o.SetNZ16(tw)
//QQ   			         {o.CLV()} o.SetD(tw); break;
//QQ   case 0xFD: /*STD ext  */ o.EaExtended();
//QQ   				 tw=o.GetD(); o.SetNZ16(tw) {o.CLV()}
//QQ   				 SETWORD(o.ea,tw) break;
//QQ   case 0xFE: /* LDU (LDS) ext */ o.EaExtended(); tw=o.GetWordE();
//QQ                                  {o.CLV()} o.SetNZ16(tw) if(!o.iflag)o.u=tw; else
//QQ                                  o.s=tw;break;
//QQ   case 0xFF:  /* STU (STS) ext  */ o.EaExtended();
//QQ                                  if(!o.iflag) tw=o.u; else tw=o.s;
//QQ                                  {o.CLV()} o.SetNZ16(tw) SETWORD(o.ea,tw) break;

   default: panic(F("UNIMPLEMENTED Opcode: 0x%02x", ireg))

  }
}
// END
