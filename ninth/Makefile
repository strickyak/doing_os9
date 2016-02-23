all: ninth

ninth : ninth.asm
	lwasm  --includedir=$$HOME/6809/hg.code.sf.net/nitros9/level1/coco1_yak --includedir=$$HOME/6809/hg.code.sf.net/nitros9/level1/coco1_yak/defs  --format=os9  --pragma=pcaspcr,condundefzero,undefextern,dollarnotlocal,export  ninth.asm  -oninth 
	os9 del  ../_disk_,CMDS/ninth 
	os9 copy ninth  ../_disk_,CMDS/ninth 
	os9 attr  -e -r -w -pe -pr  ../_disk_,CMDS/ninth 
	ci-l *.asm Makefile
