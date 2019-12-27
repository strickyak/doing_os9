# doing_os9

## gomar/ 

A M6809 emulator in GoLang with Coco1/3 NitrOS9 Level1/2 personalities.

It used "sbc09" (in C) as its starting point.

It's named for OMAR, my homegrown wire-wrapped 6809 system,
built in 1983 in Professor John Peatman's Microprocessor-Based Design lab at Georgia Tech.

## ninth/

Starting a FORTH for 6809, with "relative" pointers, for position-independant code.

## github.com/strickyak/doing_os9/grok_os9_disk/grok_os9_disk.go
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
