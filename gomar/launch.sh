set -eux

test -f "$1" && test -s "$1" || {
  echo "No such file: $1" >&2
  exit 13
}

case "$1" in
  /* ) F="$1" ;;
   * ) F="$PWD/$1" ;;
esac

cd $(dirname $0)

cp -v 'drive/disk2.orig' 'drive/disk2' 

os9 copy -r "$F" 'drive/disk2,CMDS/zz'
os9 attr -per 'drive/disk2,CMDS/zz'
## echo 'echo HUOMENTA!' | os9 copy -r -l /dev/stdin 'drive/disk2,startup'
echo 'zz <startup #128' | os9 copy -r -l /dev/stdin 'drive/disk2,startup'

go run -x --tags=coco3,level2,trace \
  gomar.go \
  --borges ../borges/ \
  --trigger_os9='(?i:fork.*file=.zz)' \
  -ttl 60s \
  -boot drive/boot2coco3 \
  -disk drive/disk2 \
  2>_
