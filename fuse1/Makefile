all: fuse.twice ramd _generated_from_fusec_.a fuseman.os9 fuser.os9 fuse.os9 _run

XDEFDIR=/home/strick/go/src/github.com/strickyak/doing_os9/gomar/eouBeta610/udisk/sourcecode/asm/nitros9/
DEFDIR=/dd/asm/nitros9/
R=/tmp/ripdir.fuse1
T=../gomar/drive/disk2

.SUFFIXES: .asm .os9
.asm.os9:
	lwasm-orig --6809 -f os9 -l'$@.list' -I'$(DEFDIR)' -I'.' -o '$@' '$<'

clean:
	rm -f ramd *.o *.s *.list *.lst *.os9  *.map *.link _generated_from_fusec_.*

ramd:
	cmoc -i --os9 -I.. ramd.c ../os9call/os9call.c
fuse.twice:
	cd /sy/frobio/frob2; make -B fuse.twice.os9
	cp /sy/frobio/frob2/fuse.twice.os9 .
	cd /sy/frobio/frob2; make -B x.cat.os9
	cp /sy/frobio/frob2/x.cat.os9 .

_generated_from_fusec_.a :
	cmoc -i -S fusec.c
	sed -n '/SECTION.code/, /ENDSECTION/ p' < fusec.s | egrep -v 'SECTION|EXPORT' > _generated_from_fusec_.a
	sed -n '/SECTION.[cr]od[ea]/, /ENDSECTION/ p' < fusec.s | egrep -v 'SECTION|EXPORT' > _generated_from_fusec_.a


_generated_by_scrape_.a : fuse.os9
	awk -f scrape.awk fuse.os9.list > _generated_by_scrape_.a

_run:
	cp *.os9 /tmp/
	cd ../gomar/borges/ ; go install borges.go
	~/go/bin/borges -outdir '../borges/' -glob '*.os9' .
	cd ~/go/src/github.com/n6il/nitros9/level2/coco3 && export NITROS9DIR=/home/strick/go/src/github.com/n6il/nitros9 ; ( make clean ; make && make NOS9_6809_L2_v030300_coco3_80d.dsk  )
	cd ~/go/src/github.com/n6il/nitros9/level2/coco3 && cp -v NOS9_6809_L2_v030300_coco3_80d.dsk ~/sy/doing_os9/gomar/drive/disk2
	:
	# echo 'ramd #128 & echo SLEEP ; sleep 12 ; echo WAKE; list /fuse/ram/orangutan/monkey ' | os9 copy -r -l /dev/stdin ~/sy/doing_os9/gomar/drive/disk2,/startup
	:
	os9 copy -r fuse.twice.os9 $T,CMDS/fuse.twice
	os9 attr -per $T,CMDS/fuse.twice
	os9 copy -r x.cat.os9 $T,CMDS/x.cat
	os9 attr -per $T,CMDS/x.cat
	echo 'fuse.twice & echo SLEEP_12 ; sleep 12 ; echo WAKE_12; x.cat /FUSE/twice/orangutan/monkey ' | os9 copy -r -l /dev/stdin ~/sy/doing_os9/gomar/drive/disk2,/startup
	:
	# echo 'list /fuse/daemon/foo & echo SLEEP ; sleep 60 ; echo WAKE; list /fuse/foo/eleven ' | os9 copy -r -l /dev/stdin ~/sy/doing_os9/gomar/drive/disk2,/startup
	# echo 'list /fuse/daemon/foo' | os9 copy -r -l /dev/stdin ~/sy/doing_os9/gomar/drive/disk2,/startup
	# echo 'ncl < run.tcl' | os9 copy -r -l /dev/stdin ~/sy/doing_os9/gomar/drive/disk2,/startup
	:
	os9 copy -r ramd $T,CMDS/ramd
	os9 attr -per $T,CMDS/ramd
	## os9 attr -per $T,CMDS/z
	os9 copy -r ../picol/ncl.bin $T,CMDS/ncl
	os9 attr -per $T,CMDS/ncl
	os9 copy -r -l ../picol/nclrc.tcl $T,SYS/nclrc.tcl
	os9 copy -r -l run.tcl $T,run.tcl
	:
	cd ~/sy/doing_os9/gomar &&  sh run2disk2.sh


disk2: all
	rm -f $T
	cp -f ../gomar/drive/NOS9_6809_L2_v030300_coco3_80d.dsk $T
	cat fuseman.os9 fuser.os9 fuse.os9 | os9 copy -r /dev/stdin $T,CMDS/z
	rm -rf $R
	mkdir $R
	os9 copy $T,os9boot /dev/stdout | go run ../find_modules/find_modules.go -ripdir '$R'
	cp -vf fuseman.os9 fuser.os9 fuse.os9 '$R'
	# cat '$R'/*.* | os9 copy -r /dev/stdin $T,os9boot

ci:
	ci -l -m/dev/null -t/dev/null -q *.c *.h *.asm Makefile

#	(echo load z ; echo link fuse ; echo 'date > /fuse/a/b/c') | os9 copy -r -l /dev/stdin  ../gomar/drive/disk2,startup
#(echo load z ; echo 'date > /fuse/a/b/c' ; echo dir /d1) | os9 copy -r -l /dev/stdin  ../gomar/drive/disk2,startup


# 
# + lwasm-orig --help
# Usage: lwasm-orig [OPTION...] INPUTFILE
# lwasm, a HD6309 and MC6809 cross-assembler
# 
#   -3, --6309                  Set assembler to 6309 mode (default)
#       --6800compat            Enable 6800 compatibility instructions,
#                               equivalent to --pragma=6800compat
#   -9, --6809                  Set assembler to 6809 only mode
#   -d, --debug[=LEVEL]         Set debug mode
#   -b, --decb                  Generate DECB .bin format output, equivalent of
#                               --format=decb
#   -D, --define=SYM[=VAL]      Automatically define SYM to be VAL (or 1)
#       --depend                Output a dependency list to stdout; do not do
#                               any actual output though assembly is completed
#                               as usual
#       --dependnoerr           Output a dependency list to stdout; do not do
#                               any actual output though assembly is completed
#                               as usual; don't bail on missing include files
#   -f, --format=TYPE           Select output format: decb, raw, obj, os9
#   -I, --includedir=PATH       Add entry to include path
#   -l, --list[=FILE]           Generate list [to FILE]
#   -m, --map[=FILE]            Generate map [to FILE]
#       --obj                   Generate proprietary object file format for
#                               later linking, equivalent of --format=obj
#   -o, --output=FILE           Output to FILE
#   -p, --pragma=PRAGMA         Set an assembler pragma to any value understood
#                               by the "pragma" pseudo op
#   -P, --preprocess            Preprocess macros and conditionals and output
#                               revised source to stdout
#   -r, --raw                   Generate raw binary format output, equivalent of
#                               --format=raw
#   -s, --symbols               Generate symbol list in listing, no effect
#                               without --list
#       --symbols-nolocals      Same as --symbols but with local labels ignored
#   -t, --tabs=WIDTH            Set tab spacing in listing (0=don't expand tabs)
#       --unicorns              Add sooper sekrit sauce
#   -?, --help                  give this help list
#       --usage                 give a short usage message
#   -V, --version               print program version
# 
# Mandatory or optional arguments to long options are also mandatory or optional
# for any corresponding short options.
# 
# Please report bugs to lost@l-w.ca.
