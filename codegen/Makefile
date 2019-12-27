all:
	python cg.py  > xyz.asm
	sh ../ASSEMBLE.sh  /dd/defs/  xyz.asm
	cp xyz.asm.o+  xyz.o
	os9 copy -r xyz.o  ../disk2,cmds/xyz
	os9 attr  -e -r -w -pe -pr  ../disk2,cmds/xyz 
	go run ../gomar/borges/borges.go  --outdir ../borges/  . 
	echo 250 OKAY

clean:
	rm -f xyz.asm *.list+ *.o *.o+
