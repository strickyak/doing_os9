#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <memory.h>
#include <sys/types.h>
#include <dirent.h>
#include <time.h>


#include "xmail.h"
#include "sys/types.h"
#include "pwd.h"
#include "sys/stat.h"
#include "sys/dir.h"
#include "errno.h"
struct stat stbuf;
int uid, destuid;
char *myname, *dest, *keyfile[128], line[128];
struct direct dbuf;
char *maildir = "/tmp/secretmail/";
FILE *kf, *mf;
DIR *df;
extern MINT *a[42];
MINT *cd[6][128];
MINT *msg;
char buf[256], eof;
int dbg;
main(argc, argv) char **argv;
{	int i, nmax, len;
	char *p;
	long now;
#if 0
	if(argc != 2)
		xfatal("mail to exactly one person");
	uid = getuid();
	p =getlogin();
	if(p == NULL)
		p = getpwuid(uid)->pw_name;
	myname = malloc(strlen(p)+1);
	strcpy(myname, p);
	dest = argv[1];
#else
	if(argc != 3)
		xfatal("Usage: xsend from-user to-user");
  myname = argv[1];
	dest = argv[2];
#endif
	strcpy(keyfile, maildir);
	strcat(keyfile, dest);
	strcat(keyfile, ".key");
	if(stat(keyfile, &stbuf) <0)
		xfatal("addressee not enrolled");
#if 0
	destuid = getpwnam(dest)->pw_uid;
	if(destuid != stbuf.st_uid)
		fprintf(stderr, "warning: addressee's key file may be subverted\n");
	errno = 0;
#endif
	kf = fopen(keyfile, "r");
	if(kf == NULL)
		xfatal("addressee's key weird");
	df = opendir(maildir);
	if(df == NULL)
	{	perror(maildir);
		exit(1);
	}
	strcpy(line, dest);
	strcat(line, ".%d");
	nmax = -1;

  struct dirent* dirent;
	for(; !(dirent = readdir(df));)
	{
		if(sscanf(dirent->d_name, line, &i) != 1)
			continue;
		if(i>nmax) nmax = i;
	}
	nmax ++;
	for(i=0; i<10; i++)
	{	sprintf(line, "%s%s.%d", maildir, dest, nmax+i);
		if(creat(line, 0666) >= 0) break;
	}
	if(i==10) xfatal("cannot create mail file");
	mf = fopen(line, "w");
	init();
	time(&now);
	sprintf(buf, "From %s %s", myname, ctime(&now) );
#ifdef DBG
	dbg = 1;
#endif
	run();
#if 0
	sprintf(buf, "mail %s <%snotice", dest, maildir);
	system(buf);
#endif
	exit(0);
}
mkcd()
{	int i, j, k, n;
	for(i=0; i<42; i++)
		nin(a[i], kf);
	fclose(kf);
	for(i=0; i<6; i++)
	for(j=0; j<128; j++)
		for(k=j, n=0; k>0 && n<7; n++, k>>=1)
			if(k&01) madd(cd[i][j], a[7*i+n], cd[i][j]);
}
encipher(s) char s[6];
{	int i;
	msub(msg, msg, msg);
	for(i=0; i<6; i++)
		madd(msg, cd[i][s[i]&0177], msg);
}
init()
{	int i, j;
	msg = itom(0);
	for(i=0; i<42; i++)
		a[i] = itom(0);
	for(i=0; i<6; i++)
	for(j=0; j<128; j++)
		cd[i][j] = itom(0);
	mkcd();
}
run()
{	char *p;
	int i, len, eof = 0;
	for(;;)
	{	len = strlen(buf);
		for(i=0; i<len/6; i++)
		{
			encipher(buf+6*i);
			nout(msg, mf);
		}
		p = buf;
		for(i *= 6; i<len; i++)
			*p++ = buf[i];
		if(eof) return;
		fgets(p, sizeof(buf)-6, stdin);
		if(strcmp(p, ".\n") == 0 || feof(stdin))
		{	for(i=0; i<6; i++) *p++ = ' ';
			*p = 0;
			eof = 1;
		}
	}
}
