set -eux

test -f "$1" && test -s "$1" || {
  echo "No such file: $1" >&2
  exit 13
}

ARGS=''
while [ $# -gt 0 ] ; do
  case "$1" in
    /* ) ARGS="$ARGS $1" ; shift ;;
     * ) ARGS="$ARGS $PWD/$1" ; shift ;;
  esac
done

set $ARGS
echo ONE: $ARGS
COMMAND="$1" ; shift
INPUT="$1" ; shift
echo TWO: , $COMMAND , $INPUT , $ARGS

cd $(dirname $0)

cp -v 'drive/disk2.orig' 'drive/disk2' 
for junk in basic09 runb cobbler asm disasm os9gen format picol p9 xyz mpi megaread
do
  os9 del "drive/disk2,CMDS/$junk"
done

os9 copy -r "$COMMAND" 'drive/disk2,CMDS/zz'
os9 attr -per 'drive/disk2,CMDS/zz'

os9 copy -r -l "$INPUT" "drive/disk2,input"

for x
do
  os9 copy -r "$x" "drive/disk2,$(basename $x)"
done

(
  # echo 'dir -x'
  echo 'dir -e'
  echo 'zz <input #128'
) | os9 copy -r -l /dev/stdin 'drive/disk2,startup'

TRACE=${TRACE:-}
TTL=${TTL:-60s}
ERR=${ERR:-/dev/null}

if test -z "$TRACE"
then
go run -x --tags=coco3,level2 \
  gomar.go \
  -ttl "$TTL" \
  -boot drive/boot2coco3 \
  -disk drive/disk2 \
  2>"$ERR"
else
go run -x --tags=coco3,level2,trace \
  gomar.go \
  --borges ../borges/ \
  --trigger_os9='(?i:fork.*file=.zz)' \
  -ttl "$TTL" \
  -boot drive/boot2coco3 \
  -disk drive/disk2 \
  2>"$ERR"
fi
