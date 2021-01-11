set -ex

M=/home/strick/6809/hg.code.sf.net/nitros9/level1/coco1_yak/modules

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
    < _  > __

