all: ninth

_force_:
ninth: _force_
	go run ../compile_9th/compile_9th.go < prelude.9th > prelude.asm
	lwasm  --includedir=$$HOME/6809/hg.code.sf.net/nitros9/level1/coco1_yak --includedir=$$HOME/6809/hg.code.sf.net/nitros9/level1/coco1_yak/defs  --format=os9  --pragma=pcaspcr,condundefzero,undefextern,dollarnotlocal,export  ninth.asm  -oninth
	ci-l *.asm Makefile *.9th ../*/*.go
	os9 del  ../_disk_,CMDS/ninth
	os9 copy ninth  ../_disk_,CMDS/ninth
	os9 attr  -e -r -w -pe -pr  ../_disk_,CMDS/ninth
	echo 'Ninth </Term' | tr '\n' '\r' > _startup
	os9 del  ../_disk_,startup
	os9 copy _startup ../_disk_,startup
	os9 attr  -r -w -pr  ../_disk_,startup
