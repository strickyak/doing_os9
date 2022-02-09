set -eux

cmoc -o z  --os9 -i "$1" arc4.c ssh-arcfour.c

os9 copy -r z ../gomar/drive/disk2,CMDS/z
os9 attr -per ../gomar/drive/disk2,CMDS/z 
echo 'z </term' | os9 copy -r -l /dev/stdin ../gomar/drive/disk2,startup

cd ../gomar ; sh run2.sh
