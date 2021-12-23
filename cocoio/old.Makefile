Y=2

yak$Y.mod : _FORCE
	lwasm --format=os9 -I defs-eouBeta5 --list=yak$Y.list -o yak$Y.mod  yak$Y.asm  

B=../gomar/drive/boot2coco3
D=../gomar/drive/disk2
run: yak$Y.mod
	cp -vf $D /tmp/d
	os9 copy -r yak$Y.mod /tmp/d,CMDS/yak$Y
	os9 attr -per /tmp/d,CMDS/yak$Y
	os9 copy -l -r yak$Y.asm /tmp/d,yak$Y.asm
	echo 'echo _yak$Y_' > /tmp/startup
	os9 copy -l -r /tmp/startup /tmp/d,startup
	cd ../gomar && go run -x --tags=coco3,level2 gomar.go -boot $B -disk /tmp/d 2>_

clean:
	rm -f *.mod *.list

_FORCE:
