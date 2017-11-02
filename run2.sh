set -ex
(cd emu; make)

DSK=/home/strick/6809/hg.code.sf.net/nitros9/level1/coco1_yak/nos96809l1coco1_yak_80d.dsk
DSK2=/tmp/dsk2.dsk
cp $DSK $DSK2

go run  bootdisk_to_sbc09_file/bootdisk_to_sbc09_file.go < $DSK > /tmp/boot

rm -rf /tmp/disk
go run grok_os9_disk/grok_os9_disk.go < $DSK  /tmp/disk > _toc

M=/home/strick/6809/hg.code.sf.net/nitros9/level1/coco1_yak/modules

####trap 'reset ; reset' 0 1 2 3

# emu/emu -Lff00 -H10000  -0 -i0 -o0 -t -Z 1222333 \
emu/emu -Lff00 -H10000  -0 -i0 -o0 \
  -d /tmp/boot \
  -f $DSK2 \
  2>/dev/null
