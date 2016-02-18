set -ex
(cd emu; make)

DSK=/home/strick/6809/hg.code.sf.net/nitros9/level1/coco1_yak/nos96809l1coco1_yak_80d.dsk

go run  bootdisk_to_sbc09_file/bootdisk_to_sbc09_file.go < $DSK > /tmp/boot

rm -rf /tmp/disk
go run grok_os9_disk/grok_os9_disk.go < $DSK  /tmp/disk > _toc


M=/home/strick/6809/hg.code.sf.net/nitros9/level1/coco1_yak/modules

trap 'reset' 0 1 2 3

# emu/emu -Lff00 -H10000  -0 -i0 -o0 -t -Z 1222333 \
emu/emu -Lff00 -H10000  -0 -i0 -o0 -t -Z 9222333 \
  -d /tmp/boot \
  -f $DSK \
  2>&1 |
tee _ |
go run annotate_trace/annotate_trace.go \
  krn,$M/kernel/krn.list  \
  krnp2,$M/kernel/krnp2.list  \
  ioman,$M/ioman.list  \
  rbf,$M/rbf.mn.list  \
  scf,$M/scf.mn.list  \
  clock,$M/clock_60hz.list  \
  vtio,$M/vtio.dr.list  \
  rb1773,$M/rb1773.dr.list  \
  sysgo,$M/sysgo_dd.list  \
  boot,$M/boot_1773_30ms.list  \
  |
tee __ |
grep Kernel
