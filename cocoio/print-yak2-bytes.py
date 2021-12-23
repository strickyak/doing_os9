LISTING='''
0023 8EFF68           (         yak2.asm):00027                  ldx #$FF68
0026 8680             (         yak2.asm):00028                  lda #$80
0028 8603             (         yak2.asm):00029                  lda #$03
002A A700             (         yak2.asm):00030         Loop     sta 0,x
002C E700             (         yak2.asm):00031                  stb 0,x
002E 6F01             (         yak2.asm):00032                  clr 1,x
0030 6F02             (         yak2.asm):00033                  clr 2,x
0032 E603             (         yak2.asm):00034                  ldb 3,x
0034 20F4             (         yak2.asm):00035                  bra Loop
'''

z = []
for line in LISTING.split('\n'):
    w = line.split()
    if len(w) > 2:
        h=w[1]
        while len(h) > 1:
            z.append(eval('0x%s' % h[:2]))
            h = h[2:]
print z
