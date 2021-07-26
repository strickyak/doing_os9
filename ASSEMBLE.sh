DEFS="$1"
ASM="$2"


# lwasm-orig --6309 --format=obj --pragma=pcaspcr,condundefzero,undefextern,dollarnotlocal,export --includedir=. --includedir=/home/strick/6809/hg.code.sf.net/nitros9/defs -DNOS9VER=3 -DNOS9MAJ=3 -DNOS9MIN=0 -DNOS9DBG=1 sys6809l2.as -osys6809l2.o -lsys6809l2.o.list

set -x
lwasm-orig --6309 --format=os9 --pragma=pcaspcr,condundefzero,undefextern,dollarnotlocal,export --includedir=. --includedir="$DEFS" -DNOS9VER=3 -DNOS9MAJ=3 -DNOS9MIN=0 -DNOS9DBG=1 "$ASM" -o"$ASM.o+" -l"$ASM.list+"

# HINT: [ ~/go/src/github.com/strickyak/doing_os9/gomar ] $ go run borges/borges.go --outdir ../borges/  /dd/

