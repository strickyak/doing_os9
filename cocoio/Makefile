all:
	/opt/yak/cmoc/bin/cmoc --os9 test12.c
	os9 copy -l -r test12.c ~/cocosdc/E.DSK,work/test12.c
	os9 copy -r test12 ~/cocosdc/E.DSK,work/test12
	os9 attr -per ~/cocosdc/E.DSK,work/test12
	cp -f ~/cocosdc/E.DSK /media/strick/0403-0201/E.DSK
	sync; sync; sync
