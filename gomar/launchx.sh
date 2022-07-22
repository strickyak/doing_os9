set -eux

# Initial flags (as one long word) passed to gomar.
FLAGS=
DONT=
case "$1" in
  DONT ) DONT=1 ; shift ;;
  -* ) FLAGS="$1" ; shift ;;
esac

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

C2=$(basename "$COMMAND" | tr _ -)
os9 copy -r "$COMMAND" "drive/disk2,CMDS/$C2"
os9 attr -per "drive/disk2,CMDS/$C2"

os9 copy -r -l "$INPUT" "drive/disk2,input"

if test -z "$DONT"
then
    BC=
    for x
    do
      case $x in
        *.bc ) BC=$(basename "$x") ;;
      esac
      os9 copy -r "$x" "drive/disk2,$(basename $x | tr _ - )"
    done
    B2=$(echo $BC | tr _ -)
    (
      echo "echo ====== startup"
      echo "list startup"
      echo "echo ====== input"
      echo "list input"
      echo "echo ======"
      echo "$C2 $B2 <input"
    ) | os9 copy -r -l /dev/stdin 'drive/disk2,startup'
else
    os9 copy -r /dev/null 'drive/disk2,startup'
fi

TRACE=${TRACE:-}
TTL=${TTL:-180s}
ERR=${ERR:-/dev/null}

if test -z "$TRACE"
then
go run -x --tags=coco3,level2 \
  gomar.go \
  -ttl "$TTL" \
  -boot drive/boot2coco3 \
  -disk drive/disk2 \
  $FLAGS \
  2>"$ERR"
else
go run -x --tags=coco3,level2,trace \
  gomar.go \
  --borges ../borges/ \
  --trigger_os9='(?i:fork.*file=.zz)' \
  -ttl "$TTL" \
  -boot drive/boot2coco3 \
  -disk drive/disk2 \
  $FLAGS \
  2>"$ERR"
fi
