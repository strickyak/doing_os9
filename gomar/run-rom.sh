set -x

go run -x --tags=coco3,level2,trace,d,display gomar.go  --rom_a000 /home/strick/6809/ROMS/color64bas.rom  --rom_8000 /home/strick/6809/ROMS/color64extbas.rom  --cart /home/strick/6809/ROMS/DSKBASIC.ROM  -t 1 --basic_text 2>/l

# go run -x --tags=coco3,level2,trace,d,display gomar.go  --rom_a000 /home/strick/6809/ROMS/color64bas.rom  --rom_8000 /home/strick/6809/ROMS/color64extbas.rom  -t 1 --basic_text 2>/l

# go run -x --tags=coco3,level2,trace,d,display gomar.go  --rom_a000 /home/strick/6809/ROMS/Color_Basic_v1.0__1980___Tandy_.rom  -t 1 --basic_text 2>/l
