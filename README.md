# doing_os9

github.com/strickyak/doing_os9/grok_os9_disk/grok_os9_disk.go
```
/*
  2   Grok and extract the contnts of a Microware OS-9 (or NitrOS9) disk image (at least, for Motorola 6809).
  3 
  4   Usage:
  5 
  6     go run grok_os9_disk.go [target_dirname] < nitros9/nos96809l1v030208coco_40d_1.dsk
  7 
  8   The command will list and explain the contents of the OS9 disk image on its stdin.
  9 
 10   If an argument is provided, the disk will be unbundled into that Posix directory on your host system.
 11 */
```
