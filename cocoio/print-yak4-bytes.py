import os
assert 0 == os.system("lwasm -r --list=yak4.list yak4.asm")
assert 0 == os.system("sed 's/     [(]         /(/' yak4.list")

codes = [ord(x) for x in open("a.out").read()]

print '''
10 DATA %s, -1
20 FOR P = 9000 TO 9999
30 READ X
40 IF X<0 THEN 100
50 POKE P, X
60 NEXT P
100 EXEC 9000''' % ', '.join(str(a) for a in codes)
