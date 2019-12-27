Funcs = {}

def Func(name, codes):
    Funcs[name] = codes

Func('demo', [
        ('arg', 0),
        ('arg', 1),
        ('lit', 100),
        ('mul'),
        ('add'),
        #('ret'),
    ])

Func('main', [
        ('lit', 20),
        ('lit', 10),
        ('call', 'demo', 2),
        ('show'),
        #('ret'),
    ])

def GenOp(code):
    if type(code) == str:
        cmd = code
    elif type(code) == tuple:
        cmd = code[0]
        a1  = code[1] if len(code)>1 else None
        a2  = code[2] if len(code)>2 else None
    else:
        raise Exception('GenOp: bad type: %s: %s' % (type(code), code))

    if cmd == 'arg':
        print '  ldd $%x,U  #arg%d' % (4 + 2*a1, a1)
        print '  pshs d'

    elif cmd == 'lit':
        print '  ldd #$%x   #lit%d' % (a1, a1)
        print '  pshs d'

    elif cmd == 'mul':
        print '  lda 1,s    #mul'
        print '  ldb 3,s'
        print '  mul'
        print '  leas 4,s'
        print '  pshs d'

    elif cmd == 'add':
        print '  puls d     #add'
        print '  addd 0,s'
        print '  std 0,s'

    elif cmd == 'show':
        print '  puls d     #show'
        print '  lbsr PrintDsp'

    elif cmd == 'call':
        print '  lbsr F_%s    #call:%s:%d' % (a1, a1, a2)
        print '  leas $%x,s' % 2*a2
        print '  pshs d'

    else:
        raise Exception('Unknown GenOp: %s' % repr(code))

def Prelude():
    print '''****** Generated code.   Prelude:

    ttl MY_TITLE
    ifp1
    use /dd/defs/deffile
    endc

tylg     set   Prgrm+Objct   
atrv     set   ReEnt+rev
rev      set   $00
edition  set   13

         mod   eom,name,tylg,atrv,start,size

         org   0
readbuff rmb   500
size     equ   .

name     fcs   /xyz/
         fcb   edition

start
        nop
        nop
        nop
        LDU #0
        lbsr F_main
        clra
        clrb
        os9 F$Exit

*************************************
'''


def Middle():
    for name,codes in Funcs.items():
        print ''
        print '***** %s' % name
        print ''
        print 'F_%s PSHS U    * old frame pointer' % name
        print '     TFR S,U   * new frame pointer'

        for c in codes:
            GenOp(c)

        print 'E_%s TFR U,S   * destory frame' % name
        print '     PULS U,PC * end function'
        print '*****'

def Postlude():
    print '''

********************* Postlude:


* putchar(b)
putchar
  pshS A,B,X,Y,U
  leaX 1,S     ; where B was stored
  ldy #1       ; y = just 1 char
  lda #1       ; a = path 1
  os9 I$WritLn ; putchar, trust it works.
  pulS A,B,X,Y,U,PC

* Print D (currently in %04x) and a space.
PrintDsp
  pshS D
  bsr PrintD
  ldb #32
  bsr putchar
  pulS D,PC

* Print D (currently in %04x).
PrintD
  pshS A,B
  pshS B
  tfr A,B
  bsr PrintB
  pulS b
  bsr PrintB
  puls a,b,pc

* Print B (as %02x)
PrintB
  pshS B
  lsrb
  lsrb
  lsrb
  lsrb
  bsr PrintNyb
  pulS B
  pshS B
  bsr PrintNyb
  pulS B,PC

* print low nyb of B.
PrintNyb
  pshS B
  andB #$0f  ; just low nybble
  addB #$30  ; add '0'

  cmpB #$3a  ; is it beyond '9'?
  blt Lpn001
  addB #('A-$3a)  ; covert $3a -> 'A'

Lpn001
  jsr putchar,pcr
  pulS B,PC


         emod
eom      equ   *
         end
'''

Prelude()
Middle()
Postlude()
