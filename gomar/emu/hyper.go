package emu

import (
	"bytes"
	"fmt"
	"log"
	"os"
)

func Nice(ch byte) byte {
	ch = ch & 127
	if ' ' <= ch && ch <= '~' {
		return ch
	}
	return '.'
}

func ShowRegs() {
	fmt.Printf(" REGS{ cc:%02x dp:%02x d:%04x x:%04x y:%04x u:%04x s:%04x pc:%04x }\n",
		ccreg, dpreg, dreg, xreg, yreg, ureg, sreg, pcreg)
}

func ShowRam32(addr Word) {
	fmt.Printf("RAM [%04x]{", addr)
	for i := Word(0); i < 32; i += 2 {
		fmt.Printf("%04x ", PeekW(addr+i))
		if (i&7) == 6 && i < 30 {
			fmt.Printf(" ")
		}
	}
	fmt.Printf("| ")
	for i := Word(0); i < 32; i += 1 {
		fmt.Printf("%c", Nice(PeekB(addr+i)))
		if (i & 7) == 7 {
			fmt.Printf(" ")
		}
	}
	fmt.Printf("}`\n")
}

func PrintH() {
	var_ptr := ureg + 4
	p := PeekW(var_ptr)
	var_ptr += 2
	bb := bytes.NewBuffer(nil)
	for {
		ch := PeekB(p)
		if ch < 9 {
			break
		}
		if ch > 126 {
			break
		}
		if ch == '%' {
			p++
			ch = PeekB(p)
			switch ch {
			case 'x':
				bb.WriteString(fmt.Sprintf("$%04x", PeekW(var_ptr)))
			case 'd':
				bb.WriteString(fmt.Sprintf("%d.", PeekW(var_ptr)))
			case 's':
				sptr := PeekW(var_ptr)
				bb.WriteRune('"')
				for {
					ch2 := PeekB(sptr)
					sptr++
					if ch2 == 0 {
						break
					}
					if ' ' <= ch2 && ch2 <= '~' {
						bb.WriteRune(rune(ch2))
					} else {
						bb.WriteString(fmt.Sprintf("(%d.)", ch2))
					}
					if ch2 > 126 {
						break
					}
				}
				bb.WriteRune('"')
			default:
				bb.WriteRune('%')
				bb.WriteRune(rune(ch))
				var_ptr -= 2
			}
			var_ptr += 2
		} else {
			bb.WriteRune(rune(ch))
		}
		p++
	}
	proc_num := byte(0)
	proc_ptr := PeekW(0x0050)
	if proc_ptr != 0x0000 {
		proc_num = PeekB(proc_ptr)
	}
	fmt.Printf("[ #%d <%x>%s]", Steps, proc_num, bb.String())
	fmt.Fprintf(os.Stderr, "\nPrintH: [ #%d <%x>%s] :PrintH\n", Steps, proc_num, bb.String())

	// If enabled, CoreDump causes NMI to occur? and bad things happen?
	// See #2755703602 at bottom.
	// CoreDump(fmt.Sprintf("/tmp/core#%d", Steps))
}

func HyperOp(hop byte) {
	switch hop {
	case 100: // Fatal
		FatalCoreDump()

	case 101: // Show Frame
		HFrame()

	case 102: // Explain MMU
		fmt.Printf("`MMU[%s]`\n", ExplainMMU())

	case 103: // ShowHex and tick
		fmt.Printf("$%x`", dreg)

	case 104: // ShowChar and tick
		if (dreg & 128) != 0 {
			fmt.Printf("^")
		}
		ch := (byte)(dreg & 127)
		if ' ' <= ch && ch <= '~' {
			fmt.Printf("%c`", ch)
		} else if ch == 10 || ch == 13 {
			fmt.Printf(" (%d)\n`", ch)
		} else {
			fmt.Printf("{%d}`", ch)
		}

	case 105: // Show RAM 32
		ShowRam32(dreg)

	case 106: // Show Task RAM 32
		task := GetBReg()
		addr := xreg
		fmt.Printf("TaskRam [[%x t%x]]{{", addr, task)

		for i := Word(0); i < 32; i += 2 {
			fmt.Printf("%04x ", PeekWWithTask(addr+i, task))
			if (i&7) == 6 && i < 30 {
				fmt.Printf(" ")
			}
		}
		for i := Word(0); i < 32; i += 1 {
			fmt.Printf("%c", Nice(PeekBWithTask(addr+i, task)))
			if (i & 7) == 7 {
				fmt.Printf(" ")
			}
		}
		fmt.Printf("}}`\n")

	case 107: // Exit
		log.Printf("*** GOMAR Hyper Exit: %d", dreg)
		fmt.Printf("*** GOMAR Hyper Exit: %d\n", dreg)
		os.Exit(int(dreg))

	case 108: // PrintH
		PrintH()

	case 109: // ShowRegs
		ShowRegs()

	case 110: // ShowStr
		{
			p := dreg
			bb := bytes.NewBuffer(nil)
			for {
				ch := PeekB(p)
				if ch == 0 {
					break
				}
				if ch == 13 {
					ch = 10
				}
				bb.WriteRune(rune(ch))
				if ch < 10 {
					break
				}
				if ch > 127 {
					break
				}
				p++
			}
			fmt.Printf("[~[%s]~]", bb.String())
		}

	default:
		log.Printf("Unknown HyperOp $%x = $d.", hop, hop)
	}
}

func HFrame() {
	log.Printf("HFrame: S=%x U=%x", sreg, ureg)
	for i := Word(0); i < 256; i += 2 {
		that := PeekW(sreg + i)
		var bb bytes.Buffer
		for j := Word(0); j < 16; j++ {
			fmt.Fprintf(&bb, " %02x", PeekB(that+j))
		}
		log.Printf("   HFrame: %x: %x: %s", sreg+i, that, bb.String())
	}
}

/*


"fuseman.23196624aa"+0425 o cd59:171047   {lbsr  $dda3            }  a=00 b=03 x=e769:0a20 y=5e80:0602 u=57b6:57c4 s=5792:cd5c,e769 cc=Efhinzvc dp=00 #2755703562 {{        LBSR    _PrintH}}


    mmu:1 task:0 [[ 00 3e 09 01  02 03 04 3f || 0e 3e 3e 3e  3e 0b 0c 0d ]] debug=""

"fuseman.23196624aa"+146f o dda3:3440     {pshs  u                }  a=00 b=03 x=e769:0a20 y=5e80:0602 u=57b6:57c4 s=5790:57b6,cd5c cc=Efhinzvc dp=00 #2755703563 {{        PSHS    U}}

"fuseman.23196624aa"+1471 o dda5:33e4     {leau  ,s               }  a=00 b=03 x=e769:0a20 y=5e80:0602 u=5790:57b6 s=5790:57b6,cd5c cc=Efhinzvc dp=00 #2755703564 {{        LEAU    ,S}}

SWI
HyperOp 108.

PrintH: [ #2755703565 <5>
 RETAINED task-> $0003 (e $0000)] :PrintH
"fuseman.23196624aa"+1473 o dda7:3f6c32   {swi                    }  a=00 b=03 x=e769:0a20 y=5e80:0602 u=5790:57b6 s=5790:57b6,cd5c cc=Efhinzvc dp=00 #2755703565 {{      swi}}

"fuseman.23196624aa"+1475 o dda9:32c4     {leas  ,u               }  a=00 b=03 x=e769:0a20 y=5e80:0602 u=5790:57b6 s=5790:57b6,cd5c cc=Efhinzvc dp=00 #2755703566 {{        LEAS    ,U}}

"fuseman.23196624aa"+1477 o ddab:35c0     {puls  pc,u             }  a=00 b=03 x=e769:0a20 y=5e80:0602 u=57b6:57c4 s=5794:e769,0003 cc=Efhinzvc dp=00 #2755703567 {{        PULS    U,PC}}


    mmu:1 task:0 [[ 00 3e 09 01  02 03 04 3f || 0e 3e 3e 3e  3e 0b 0c 0d ]] debug=""

"fuseman.23196624aa"+0428 o cd5c:3266     {leas  6,s              }  a=00 b=03 x=e769:0a20 y=5e80:0602 u=57b6:57c4 s=579a:5e40,0300 cc=Efhinzvc dp=00 #2755703568 {{        LEAS    6,S}}

"fuseman.23196624aa"+042a o cd5e:30c8e7   {leax  -25,u            }  a=00 b=03 x=579d:000f y=5e80:0602 u=57b6:57c4 s=579a:5e40,0300 cc=Efhinzvc dp=00 #2755703569 {{        LEAX    -25,U           member task_map of ClientTmp, via variable tmp}}

"fuseman.23196624aa"+042d o cd61:ec0e     {ldd   14,x             }  a=00 b=08 x=579d:000f y=5e80:0602 u=57b6:57c4 s=579a:5e40,0300 cc=Efhinzvc dp=00 #2755703570 {{        LDD     14,X            optim: optimizeLeaxLdd}}  57ab:0008

"fuseman.23196624aa"+042f o cd63:3406     {pshs  b,a              }  a=00 b=08 x=579d:000f y=5e80:0602 u=57b6:57c4 s=5798:0008,5e40 cc=Efhinzvc dp=00 #2755703571 {{        PSHS    B,A             argument 10 of PrintH(): unsigned int}}

"fuseman.23196624aa"+0431 o cd65:30c8e7   {leax  -25,u            }  a=00 b=08 x=579d:000f y=5e80:0602 u=57b6:57c4 s=5798:0008,5e40 cc=Efhinzvc dp=00 #2755703572 {{        LEAX    -25,U           member task_map of ClientTmp, via variable tmp}}

"fuseman.23196624aa"+0434 o cd68:ec0c     {ldd   12,x             }  a=33 b=3e x=579d:000f y=5e80:0602 u=57b6:57c4 s=5798:0008,5e40 cc=Efhinzvc dp=00 #2755703573 {{        LDD     12,X            optim: optimizeLeaxLdd}}  57a9:333e

"fuseman.23196624aa"+0436 o cd6a:3406     {pshs  b,a              }  a=33 b=3e x=579d:000f y=5e80:0602 u=57b6:57c4 s=5796:333e,0008 cc=Efhinzvc dp=00 #2755703574 {{        PSHS    B,A             argument 9 of PrintH(): unsigned int}}

"fuseman.23196624aa"+0438 o cd6c:30c8e7   {leax  -25,u            }  a=33 b=3e x=579d:000f y=5e80:0602 u=57b6:57c4 s=5796:333e,0008 cc=Efhinzvc dp=00 #2755703575 {{        LEAX    -25,U           member task_map of ClientTmp, via variable tmp}}

"fuseman.23196624aa"+043b o cd6f:ec0a     {ldd   10,x             }  a=33 b=3e x=579d:000f y=5e80:0602 u=57b6:57c4 s=5796:333e,0008 cc=Efhinzvc dp=00 #2755703576 {{        LDD     10,X            optim: optimizeLeaxLdd}}  57a7:333e

"fuseman.23196624aa"+043d o cd71:3406     {pshs  b,a              }  a=33 b=3e x=579d:000f y=5e80:0602 u=57b6:57c4 s=5794:333e,333e cc=Efhinzvc dp=00 #2755703577 {{        PSHS    B,A             argument 8 of PrintH(): unsigned int}}

"fuseman.23196624aa"+043f o cd73:30c8e7   {leax  -25,u            }  a=33 b=3e x=579d:000f y=5e80:0602 u=57b6:57c4 s=5794:333e,333e cc=Efhinzvc dp=00 #2755703578 {{        LEAX    -25,U           member task_map of ClientTmp, via variable tmp}}

"fuseman.23196624aa"+0442 o cd76:ec08     {ldd   8,x              }  a=33 b=3e x=579d:000f y=5e80:0602 u=57b6:57c4 s=5794:333e,333e cc=Efhinzvc dp=00 #2755703579 {{        LDD     8,X             optim: optimizeLeaxLdd}}  57a5:333e

"fuseman.23196624aa"+0444 o cd78:3406     {pshs  b,a              }  a=33 b=3e x=579d:000f y=5e80:0602 u=57b6:57c4 s=5792:333e,333e cc=Efhinzvc dp=00 #2755703580 {{        PSHS    B,A             argument 7 of PrintH(): unsigned int}}

"fuseman.23196624aa"+0446 o cd7a:30c8e7   {leax  -25,u            }  a=33 b=3e x=579d:000f y=5e80:0602 u=57b6:57c4 s=5792:333e,333e cc=Efhinzvc dp=00 #2755703581 {{        LEAX    -25,U           member task_map of ClientTmp, via variable tmp}}

"fuseman.23196624aa"+0449 o cd7d:ec06     {ldd   6,x              }  a=33 b=3e x=579d:000f y=5e80:0602 u=57b6:57c4 s=5792:333e,333e cc=Efhinzvc dp=00 #2755703582 {{        LDD     6,X             optim: optimizeLeaxLdd}}  57a3:333e

"fuseman.23196624aa"+044b o cd7f:3406     {pshs  b,a              }  a=33 b=3e x=579d:000f y=5e80:0602 u=57b6:57c4 s=5790:333e,333e cc=Efhinzvc dp=00 #2755703583 {{        PSHS    B,A             argument 6 of PrintH(): unsigned int}}

"fuseman.23196624aa"+044d o cd81:30c8e7   {leax  -25,u            }  a=33 b=3e x=579d:000f y=5e80:0602 u=57b6:57c4 s=5790:333e,333e cc=Efhinzvc dp=00 #2755703584 {{        LEAX    -25,U           member task_map of ClientTmp, via variable tmp}}

"fuseman.23196624aa"+0450 o cd84:ec04     {ldd   4,x              }  a=33 b=3e x=579d:000f y=5e80:0602 u=57b6:57c4 s=5790:333e,333e cc=Efhinzvc dp=00 #2755703585 {{        LDD     4,X             optim: optimizeLeaxLdd}}  57a1:333e

"fuseman.23196624aa"+0452 o cd86:3406     {pshs  b,a              }  a=33 b=3e x=579d:000f y=5e80:0602 u=57b6:57c4 s=578e:333e,333e cc=Efhinzvc dp=00 #2755703586 {{        PSHS    B,A             argument 5 of PrintH(): unsigned int}}

"fuseman.23196624aa"+0454 o cd88:30c8e7   {leax  -25,u            }  a=33 b=3e x=579d:000f y=5e80:0602 u=57b6:57c4 s=578e:333e,333e cc=Efhinzvc dp=00 #2755703587 {{        LEAX    -25,U           member task_map of ClientTmp, via variable tmp}}

"fuseman.23196624aa"+0457 o cd8b:ec02     {ldd   2,x              }  a=33 b=3e x=579d:000f y=5e80:0602 u=57b6:57c4 s=578e:333e,333e cc=Efhinzvc dp=00 #2755703588 {{        LDD     2,X             optim: optimizeLeaxLdd}}  579f:333e

"fuseman.23196624aa"+0459 o cd8d:3406     {pshs  b,a              }  a=33 b=3e x=579d:000f y=5e80:0602 u=57b6:57c4 s=578c:333e,333e cc=Efhinzvc dp=00 #2755703589 {{        PSHS    B,A             argument 4 of PrintH(): unsigned int}}

"fuseman.23196624aa"+045b o cd8f:ecc8e7   {ldd   -25,u            }  a=00 b=0f x=579d:000f y=5e80:0602 u=57b6:57c4 s=578c:333e,333e cc=Efhinzvc dp=00 #2755703590 {{        LDD     -25,U           optim: optimizeLeax}}  579d:000f

"fuseman.23196624aa"+045e o cd92:3406     {pshs  b,a              }  a=00 b=0f x=579d:000f y=5e80:0602 u=57b6:57c4 s=578a:000f,333e cc=Efhinzvc dp=00 #2755703591 {{        PSHS    B,A             argument 3 of PrintH(): unsigned int}}

"fuseman.23196624aa"+0460 o cd94:e6c8e6   {ldb   -26,u            }  a=00 b=03 x=579d:000f y=5e80:0602 u=57b6:57c4 s=578a:000f,333e cc=Efhinzvc dp=00 #2755703592 {{        LDB     -26,U           member task_num of ClientTmp, via variable tmp}}  579c:03

"fuseman.23196624aa"+0463 o cd97:4f       {clra                   }  a=00 b=03 x=579d:000f y=5e80:0602 u=57b6:57c4 s=578a:000f,333e cc=EfhinZvc dp=00 #2755703593 {{        CLRA                    promoting byte argument to word}}

"fuseman.23196624aa"+0464 o cd98:3406     {pshs  b,a              }  a=00 b=03 x=579d:000f y=5e80:0602 u=57b6:57c4 s=5788:0003,000f cc=EfhinZvc dp=00 #2755703594 {{        PSHS    B,A             argument 2 of PrintH(): unsigned char}}

"fuseman.23196624aa"+0466 o cd9a:308d19e7 {leax  $e785,pcr        }  a=00 b=03 x=e785:2052 y=5e80:0602 u=57b6:57c4 s=5788:0003,000f cc=Efhinzvc dp=00 #2755703595 {{        LEAX    S00116,PCR      " RETAINED Task#=%x Map=%x %x  %x %x  %x %x  %x %x\n"}}

"fuseman.23196624aa"+046a o cd9e:3410     {pshs  x                }  a=00 b=03 x=e785:2052 y=5e80:0602 u=57b6:57c4 s=5786:e785,0003 cc=Efhinzvc dp=00 #2755703596 {{        PSHS    X               argument 1 of PrintH(): const char[]}}

"fuseman.23196624aa"+046c o cda0:171000   {lbsr  $dda3            }  a=00 b=03 x=e785:2052 y=5e80:0602 u=57b6:57c4 s=5784:cda3,e785 cc=Efhinzvc dp=00 #2755703597 {{        LBSR    _PrintH}}


    mmu:1 task:0 [[ 00 3e 09 01  02 03 04 3f || 0e 3e 3e 3e  3e 0b 0c 0d ]] debug=""

"fuseman.23196624aa"+146f o dda3:3440     {pshs  u                }  a=00 b=03 x=e785:2052 y=5e80:0602 u=57b6:57c4 s=5782:57b6,cda3 cc=Efhinzvc dp=00 #2755703598 {{        PSHS    U}}

"fuseman.23196624aa"+1471 o dda5:33e4     {leau  ,s               }  a=00 b=03 x=e785:2052 y=5e80:0602 u=5782:57b6 s=5782:57b6,cda3 cc=Efhinzvc dp=00 #2755703599 {{        LEAU    ,S}}

SWI
HyperOp 108.

PrintH: [ #2755703600 <5> RETAINED Task#=$0003 Map=$000f $333e  $333e $333e  $333e $333e  $333e $0008
] :PrintH
"fuseman.23196624aa"+1473 o dda7:3f6c32   {swi                    }  a=00 b=03 x=e785:2052 y=5e80:0602 u=5782:57b6 s=5782:57b6,cda3 cc=Efhinzvc dp=00 #2755703600 {{      swi}}

INTERRUPTING with NMI
"(FE)"+0000 N fefd:20d8     {bra   $fed7            }  a=00 b=03 x=e785:2052 y=5e80:0602 u=5782:57b6 s=5776:8000,0300 cc=EFhInzvc dp=00 #2755703602 {{}}


    mmu:1 task:0 [[ 00 3e 09 01  02 03 04 3f || 0e 3e 3e 3e  3e 0b 0c 0d ]] debug=""

"(FE)"+0000 N fed7:8e00fc   {ldx   #$00fc           }  a=00 b=03 x=00fc:9c49 y=5e80:0602 u=5782:57b6 s=5776:8000,0300 cc=EFhInzvc dp=00 #2755703603 {{}}  fed8:00fc

"(FE)"+0000 N feda:20af     {bra   $fe8b            }  a=00 b=03 x=00fc:9c49 y=5e80:0602 u=5782:57b6 s=5776:8000,0300 cc=EFhInzvc dp=00 #2755703604 {{}}


    mmu:1 task:0 [[ 00 3e 09 01  02 03 04 3f || 0e 3e 3e 3e  3e 0b 0c 0d ]] debug=""

"(FE)"+0000 o fe8b:4f       {clra                   }  a=00 b=03 x=00fc:9c49 y=5e80:0602 u=5782:57b6 s=5776:8000,0300 cc=EFhInZvc dp=00 #2755703605 {{}}

GIME MmuTask <- 0; clock rate <- false
"(FE)"+0000 o fe8c:b7ff91   {sta   $ff91            }  a=00 b=03 x=00fc:9c49 y=5e80:0602 u=5782:57b6 s=5776:8000,0300 cc=EFhInZvc dp=00 #2755703606 {{}}  ff91:00

"(FE)"+0000 o fe8f:1f8b     {tfr   a,dp             }  a=00 b=03 x=00fc:9c49 y=5e80:0602 u=5782:57b6 s=5776:8000,0300 cc=EFhInZvc dp=00 #2755703607 {{}}

"(FE)"+0000 o fe91:9691     {lda   $91              }  a=00 b=03 x=00fc:9c49 y=5e80:0602 u=5782:57b6 s=5776:8000,0300 cc=EFhInZvc dp=00 #2755703608 {{}}  0091:00

"(FE)"+0000 o fe93:84fe     {anda  #$fe             }  a=00 b=03 x=00fc:9c49 y=5e80:0602 u=5782:57b6 s=5776:8000,0300 cc=EFhInZvc dp=00 #2755703609 {{}}  fe94:fe

"(FE)"+0000 o fe95:9791     {sta   $91              }  a=00 b=03 x=00fc:9c49 y=5e80:0602 u=5782:57b6 s=5776:8000,0300 cc=EFhInZvc dp=00 #2755703610 {{}}  0091:00

GIME MmuTask <- 0; clock rate <- false
"(FE)"+0000 o fe97:b7ff91   {sta   $ff91            }  a=00 b=03 x=00fc:9c49 y=5e80:0602 u=5782:57b6 s=5776:8000,0300 cc=EFhInZvc dp=00 #2755703611 {{}}  ff91:00

"(FE)"+0000 o fe9a:6e94     {jmp   [,x]             }  a=00 b=03 x=00fc:9c49 y=5e80:0602 u=5782:57b6 s=5776:8000,0300 cc=EFhInZvc dp=00 #2755703612 {{}}  00fc:9c49


    mmu:1 task:0 [[ 00 3e 09 01  02 03 04 3f || 0e 3e 3e 3e  3e 0b 0c 0d ]] debug=""

BORGES: Loaded Source: "/home/strick/go/src/github.com/strickyak/doing_os9/borges/rb1773.05a9a4eb50" (613)
"rb1773.05a9a4eb50"+0289 N 9c49:326c     {leas  12,s             }  a=00 b=03 x=00fc:9c49 y=5e80:0602 u=5782:57b6 s=5782:57b6,cda3 cc=EFhInZvc dp=00 #2755703613 {{NMISvc   leas  R$Size,s       Eat register stack}}

"rb1773.05a9a4eb50"+028b N 9c4b:9e4c     {ldx   $4c              }  a=00 b=03 x=0640:0000 y=5e80:0602 u=5782:57b6 s=5782:57b6,cda3 cc=EFhInzvc dp=00 #2755703614 {{         ldx   <D.SysDAT  get pointer to system DAT image}}  004c:0640

"rb1773.05a9a4eb50"+028d N 9c4d:a603     {lda   3,x              }  a=3e b=03 x=0640:0000 y=5e80:0602 u=5782:57b6 s=5782:57b6,cda3 cc=EFhInzvc dp=00 #2755703615 {{         lda   3,x        get block number 1}}  0643:3e

GIME MmuMap[0][1] <- 3e  (was 3e)
"rb1773.05a9a4eb50"+028f N 9c4f:b7ffa1   {sta   $ffa1            }  a=3e b=03 x=0640:0000 y=5e80:0602 u=5782:57b6 s=5782:57b6,cda3 cc=EFhInzvc dp=00 #2755703616 {{         sta   >$FFA1     map it back into memory}}  ffa1:3e

"rb1773.05a9a4eb50"+0292 N 9c52:1caf     {andcc #$af             }  a=3e b=03 x=0640:0000 y=5e80:0602 u=5782:57b6 s=5782:57b6,cda3 cc=Efhinzvc dp=00 #2755703617 {{         andcc #^IntMasks turn IRQ's on again}}

"rb1773.05a9a4eb50"+0294 N 9c54:f6ff48   {ldb   $ff48            }  a=3e b=00 x=0640:0000 y=5e80:0602 u=5782:57b6 s=5782:57b6,cda3 cc=EfhinZvc dp=00 #2755703618 {{         ldb   >DPort+WD_Stat  Get status register}}  ff48:00

"rb1773.05a9a4eb50"+0297 N 9c57:c504     {bitb  #$04             }  a=3e b=00 x=0640:0000 y=5e80:0602 u=5782:57b6 s=5782:57b6,cda3 cc=EfhinZvc dp=00 #2755703619 {{         bitb  #%00000100     Did we lose data in the transfer?}}  9c58:04

"rb1773.05a9a4eb50"+0299 N 9c59:102701   {lbeq  $9d9a            }  a=3e b=00 x=0640:0000 y=5e80:0602 u=5782:57b6 s=5782:57b6,cda3 cc=EfhinZvc dp=00 #2755703620 {{         lbeq  L03B2          Otherwise, check for drive errors}}


    mmu:1 task:0 [[ 00 3e 09 01  02 03 04 3f || 0e 3e 3e 3e  3e 0b 0c 0d ]] debug=""

"rb1773.05a9a4eb50"+03da N 9d9a:c5f8     {bitb  #$f8             }  a=3e b=00 x=0640:0000 y=5e80:0602 u=5782:57b6 s=5782:57b6,cda3 cc=EfhinZvc dp=00 #2755703621 {{L03B2    bitb  #%11111000     any of the error bits set?}}  9d9b:f8

"rb1773.05a9a4eb50"+03dc N 9d9c:270f     {beq   $9dad            }  a=3e b=00 x=0640:0000 y=5e80:0602 u=5782:57b6 s=5782:57b6,cda3 cc=EfhinZvc dp=00 #2755703622 {{         beq   L03CA          No, exit without error}}


    mmu:1 task:0 [[ 00 3e 09 01  02 03 04 3f || 0e 3e 3e 3e  3e 0b 0c 0d ]] debug=""

"rb1773.05a9a4eb50"+03ed N 9dad:5f       {clrb                   }  a=3e b=00 x=0640:0000 y=5e80:0602 u=5782:57b6 s=5782:57b6,cda3 cc=EfhinZvc dp=00 #2755703623 {{L03CA    clrb                 No error & return}}

"rb1773.05a9a4eb50"+03ee N 9dae:39       {rts                    }  a=3e b=00 x=0640:0000 y=5e80:0602 u=5782:57b6 s=5784:cda3,e785 cc=EfhinZvc dp=00 #2755703624 {{         rts   }}


    mmu:1 task:0 [[ 00 3e 09 01  02 03 04 3f || 0e 3e 3e 3e  3e 0b 0c 0d ]] debug=""

"" N 57b6:57       {asrb                   }  a=3e b=00 x=0640:0000 y=5e80:0602 u=5782:57b6 s=5784:cda3,e785 cc=EfhinZvc dp=00 #2755703625 {{}}

"" N 57b7:c4ce     {andb  #$ce             }  a=3e b=00 x=0640:0000 y=5e80:0602 u=5782:57b6 s=5784:cda3,e785 cc=EfhinZvc dp=00 #2755703626 {{}}  57b8:ce

"" N 57b9:e15e     {cmpb  -2,u             }  a=3e b=00 x=0640:0000 y=5e80:0602 u=5782:57b6 s=5784:cda3,e785 cc=EfHinzvC dp=00 #2755703627 {{}}  5780:dd

"" N 57bb:8000     {suba  #$00             }  a=3e b=00 x=0640:0000 y=5e80:0602 u=5782:57b6 s=5784:cda3,e785 cc=Efhinzvc dp=00 #2755703628 {{}}  57bc:00

"" N 57bd:0300     {com   $00              }  a=3e b=00 x=0640:0000 y=5e80:0602 u=5782:57b6 s=5784:cda3,e785 cc=EfhiNzvC dp=00 #2755703629 {{}}  0000:ff

"" N 57bf:0033     {neg   $33              }  a=3e b=00 x=0640:0000 y=5e80:0602 u=5782:57b6 s=5784:cda3,e785 cc=EfhinZvc dp=00 #2755703630 {{}}  0033:00

Illegal Opcode: 0x5e
Finish:
Cycles: 18272769   Steps: 2755703631



Cycles: 18272769   Steps: 2755703631
panic: Illegal Opcode: 0x5e

goroutine 1 [running]:
log.Panicf({0x51e0ec?, 0x4ff4a0?}, {0xc000061d80?, 0x4c7005?, 0x631fc0?})
	/opt/yak/go1.19.3/src/log/log.go:395 +0x67
github.com/strickyak/doing_os9/gomar/emu.ill()
	/home/strick/go/src/github.com/strickyak/doing_os9/gomar/emu/emu.go:1874 +0x5b
github.com/strickyak/doing_os9/gomar/emu.Main()
	/home/strick/go/src/github.com/strickyak/doing_os9/gomar/emu/emu.go:3270 +0x931
main.main()
	/home/strick/go/src/github.com/strickyak/doing_os9/gomar/gomar.go:112 +0x165
exit status 2

*/
