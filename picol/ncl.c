/* ncl: Modified for cmoc for NitrOS9/OS9 by strick */

/* Tcl in ~ 500 lines of code by Salvatore antirez Sanfilippo. BSD licensed */

#define RAM_SIZE 12000
#define BUF_SIZE 200            /* instead of 1024 */
#define MAX_SCRIPT_SIZE 500     /* instead of 8K or 16K */

typedef unsigned char byte;
typedef unsigned int uint;
#define NULL 0
#define false 0
#define true 1

extern int Error(struct picolInterp *i, char *argv0, int err);
extern int ResultD(struct picolInterp *i, int x);

// *INDENT-OFF*

asm void stkcheck() {
	asm {
		pshs x
		ldx 2,s   ; get the return PC
		leax 2,x  ; add 2 to it
		stx 2,s   ; put it back
		puls x,pc ; and use it to return.
	}
}

asm void exit(int status) {
	asm {
		ldd 2,s      ; status code in b.
		os9 F_Exit
	}
}

asm int Os9ReadLn(int path, char* buf, int buflen, int* bytes_read) {
	asm {
		pshs y,u
		lda 7,s      ; path
		ldx 8,s      ; buf
		ldy 10,s      ; buflen
		os9 I_ReadLn
		bcs Os9Err
		sty [12,s]   ; bytes_read
		ldd #0
		puls y,u,pc
	}
}

asm int Os9WritLn(int path, const char* buf, int max, int* bytes_written) {
	asm {
		pshs y,u
		lda 7,s      ; path
		ldx 8,s      ; buf
		ldy 10,s      ; max
		os9 I_WritLn
		bcs Os9Err
		sty [12,s]   ; bytes_written
		ldd #0
		puls y,u,pc
	}
}

asm char* gets(char* buf) {
	asm {
		pshs y,u
		clra         ; path 0
		ldy #200
		ldx 6,s
		os9 I_ReadLn
		bcs returnNULL
		ldd 6,s      ; return buf
		puls y,u,pc
returnNULL	clra         ; return NULL
		clrb
		puls y,u,pc
	}
}

asm void puts(const char* s) {
	asm {
		pshs y,u
		ldx 6,s      ; arg1: string to write, for strlen.
		pshs x       ; push arg1 for strlen
		lbsr _strlen  ; see how much to puts.
		leas 2,s      ; drop 1 arg after strlen
		tfr d,y       ; max size (strlen) in y
		ldx 6,s      ; arg1: string to write.
		clra         ; a = path ...
		inca         ; a = path 1
		os9 I_WritLn
		puls y,u,pc
	}
	// TODO: error checking.
}

asm int Os9Dup(int path, int* new_path) {
	asm {
		pshs y,u
		lda 7,s  ; old path.
		os9 0x82 ; I$Dup
		bcs Os9Err
		tfr a,b  ; new path.
		sex
		std [8,s]
		ldd #0
		puls y,u,pc
	}
}

asm int Os9Close(int path) {
	asm {
		pshs y,u
		lda 7,s  ; path.
		os9 0x8F ; I$Close
		bcs Os9Err
		ldd #0
		puls y,u,pc
	}
}

asm int Os9Sleep(int secs) {
	asm {
		pshs y,u
		ldx 6,s  ; ticks
		os9 0x0A ; I$Sleep
		bcs Os9Err
		ldd #0
		puls y,u,pc
Os9Err
		sex
		puls y,u,pc
	}
}

/*
 * OS9 F$Wait
MACHINE CODE: 103F 04
INPUT: None
OUTPUT: (A) = Deceased child process’ process ID
(B) = Child process’ exit status code
*/

asm int Os9Wait(int* child_id) {
	asm {
		pshs y,u
		os9 0x04 ; F$Wait
		bcs Os9Err
		tfr a,b
		sex
		std [6,s]
		ldd #0
		puls y,u,pc
	}
}

/*
   OS9 F$Fork
MACHINE CODE: 103F 03
INPUT: (X) = Address of module name or file name.
(Y) = Parameter area size.
(U) = Beginning address of the parameter area.
(A) = Language / Type code.
(B) = Optional data area size (pages).
OUTPUT: (X) = Updated past the name string.
(A) = New process ID number.
ERROR OUTPUT: (CC) = C bit set. (B) = Appropriate error code.
*/

asm int Os9Fork(char* program, char* params, int paramlen, int lang_type, int mem_size, int* child_id) {
	asm {
		pshs y,u
		ldx 6,s  ; program
		ldu 8,s  ; params
		ldy 10,s ; paramlen
		lda 13,s  ; lang_type
		ldb 15,s  ; mem_size
		os9 0x03  ; F$Fork
		bcs Os9Err
		tfr a,b    ; move child id to D
		clra
		std [16,s]  ; Store D to *child_id
		clrb        ; return D=0 no error
		puls y,u,pc
	}
}

asm int Os9Chain(char* program, char* params, int paramlen, int lang_type, int mem_size) {
	asm {
		pshs y,u
		ldx 6,s  ; program
		ldu 8,s  ; params
		ldy 10,s ; paramlen
		lda 13,s  ; lang_type
		ldb 15,s  ; mem_size
		os9 0x05  ; F$Chain -- if returns, then it is an error.
		sex         ; extend error B to D
		puls y,u,pc
	}
}

// *INDENT-ON*

char hexchar(byte i)
{
  if (0 <= i && i <= 9)
    return (char) ('0' + i);
  if (10 <= i && i <= 15)
    return (char) ('A' + i - 10);
  return '?';
}

// puthex prints a prefix and a hex number, like `(p=1234)`,
// only using a small buffer.  Quick and reliable for debugging.
void puthex(char prefix, int a)
{
  char buf[9];
  uint x = (uint) a;
  buf[8] = '\0';
  buf[7] = ')';
  buf[6] = hexchar((byte) (x & 15));
  x = (x >> 4);
  buf[5] = hexchar((byte) (x & 15));
  x = (x >> 4);
  buf[4] = hexchar((byte) (x & 15));
  x = (x >> 4);
  buf[3] = hexchar((byte) (x & 15));
  buf[2] = '=';
  buf[1] = prefix;
  buf[0] = '(';
  puts(buf);
}

// panic: print message and exit 5.
void panic(const char *s)
{
  puthex('P', (int) s);
  puts(s);
  exit(5);
}

// Up(c): convert to upper case for 26 ascii letters.
char Up(char c)
{
  return ('a' <= c && c <= 'z') ? c - 32 : c;
}

int atoi(const char *s)
{
  int z = 0;
  byte neg = false;
  if (*s == '-') {
    neg = 1;
    s++;
  }
  if (*s == '0') {
    s++;
    if (*s == 'x') {
      // hex if starts 0x
      while ('0' <= *s && *s <= '9' || 'A' <= Up(*s) && 'F' <= Up(*s)) {
        if ('0' <= *s && *s <= '9') {
          z = z * 16 + (*s - '0');
        } else {
          z = z * 16 + (Up(*s) + 10 - 'A');
        }
        s++;
      }
    } else {
      // octal if starts 0
      while ('0' <= *s && *s <= '7') {
        z = z * 8 + (*s - '0');
        s++;
      }
    }
  } else {
    // else decimal
    while ('0' <= *s && *s <= '9') {
      z = z * 10 + (*s - '0');
      s++;
    }
  }
  return neg ? -z : z;
}

void memcpy(void *d, const void *s, int sz)
{
  char *a = (char *) d;
  const char *b = (const char *) s;
  int i;
  for (i = 0; i < sz; i++)
    *a++ = *b++;
}

int strcasecmp(const char *a, const char *b)
{
  while (*a && *b) {
    if ((byte) Up(*a) < (byte) Up(*b))
      return -1;
    if ((byte) Up(*a) > (byte) Up(*b))
      return +1;
    a++;
    b++;
  }
  // at least one is 0.
  if ((byte) Up(*a) < (byte) Up(*b))
    return -1;
  if ((byte) Up(*a) > (byte) Up(*b))
    return +1;
  return 0;
}

void strcpy(char *d, const char *s)
{
  while (*s) {
    *d++ = *s++;
  }
  *d = '\0';
}

int strlen(const char *p)
{
  const char *q = p;
  while (*q)
    q++;
  return q - p;
}

void bzero(char *p, int n)
{
  for (int i = 0; i < n; i++)
    p[i] = 0;
}

void snprintf_s(char *buf, int max, const char *fmt, const char *s)
{
  int flen = strlen(fmt);
  int slen = strlen(s);
  if (flen + slen - 1 > max) {  // drop '%s' but add '\0', so net minus 1.
    puthex('f', flen);
    puthex('s', slen);
    puthex('m', max);
    panic("buf overflow snprintf_s");
  }

  char *p = buf;
  while (*fmt) {
    if (fmt[0] == '%' && 'a' <= fmt[1] && fmt[1] <= 'z') {      // who cares what letter.
      fmt += 2;
      while (*s)
        *p++ = *s++;
      break;
    } else {
      *p++ = *fmt++;
    }
  }
  while (*fmt) {
    *p++ = *fmt++;
  }
  *p = '\0';
}

void snprintf_d(char *buf, int max, const char *fmt, int x)
{
  char tmp[8];
  const char *z;

  if (x == 0) {
    z = "0";
  } else {
    byte neg = false;
    char *p = tmp + 7;
    *p-- = '\0';
    uint y;
    if (x < 0) {
      neg = true;
      y = -x;
    } else {
      y = x;
    }
    while (y) {
      uint r = y % 10;
      y = y / 10;
      *p-- = (byte) ('0' + r);
    }
    if (neg)
      *p-- = '-';
    z = p + 1;
  }

  snprintf_s(buf, max, fmt, z);
}

void printf_d(const char *fmt, int x)
{
  char buf[BUF_SIZE];
  snprintf_d(buf, BUF_SIZE, fmt, x);
  puts(buf);
}

void printf_s(const char *fmt, const char *s)
{
  char buf[BUF_SIZE];
  snprintf_s(buf, BUF_SIZE, fmt, s);
  puts(buf);
}

////////////////////  Malloc & Free

struct Head {
  char magicA;
  struct Head *next;
  int cap;
  char magicZ;
};

#define NBUCKETS 12             // 8B to 16KB.
int ram_used;
struct Head *ram_roots[NBUCKETS];
char ram[RAM_SIZE];

void *malloc(int n)
{
  //puthex('M', n);
  int i;
  int cap = 8;
  for (i = 0; i < NBUCKETS; i++) {
    if (n <= cap)
      break;
    cap += cap;
  }
  if (i >= 10) {
    puthex('m', n);
    panic("malloc too big");
  }

  // Try an existing unused block.

  struct Head *h = ram_roots[i];
  if (h) {
    if (h->magicA != 'A')
      panic("malloc: corrupt magicA");
    if (h->magicZ != 'Z')
      panic("malloc: corrupt magicZ");
    if (h->cap != cap)
      panic("corrupt cap");
    ram_roots[i] = h->next;
    bzero((char *) (h + 1), cap);
    //puthex('y', (int)(h+1));
    return (void *) (h + 1);
  }

  char *p = ram + ram_used;
  ram_used += cap + sizeof(struct Head);
  if (ram_used > RAM_SIZE) {
    puthex('n', n);
    puthex('c', cap);
    puthex('u', ram_used);
    panic(" *oom* ");
  }
  h = ((struct Head *) p) - 1;
  h->magicA = 'A';
  h->magicZ = 'Z';
  h->cap = cap;
  h->next = NULL;
  //puthex('z', (int)(h+1));
  return (void *) (h + 1);
}

void free(void *p)
{
  if (!p)
    return;

  //puthex('F', (int)p);
  struct Head *h = ((struct Head *) p) - 1;
  if (h->magicA != 'A')
    panic("free: corrupt magicA");
  if (h->magicZ != 'Z')
    panic("free: corrupt magicZ");

  int i;
  int cap = 8;
  for (i = 0; i < 10; i++) {
    if (h->cap == cap)
      break;
    cap += cap;
  }
  if (i >= 10) {
    puthex('c', h->cap);
    panic("corrupt free");
  }

  bzero((char *) p, cap);

  h->next = ram_roots[i];
  ram_roots[i] = h;
}

void *realloc(void *p, int n)
{
  //puthex('R', (int)p);
  //puthex('n', (int)n);
  struct Head *h = ((struct Head *) p) - 1;
  if (n <= h->cap) {
    //puthex('w', (int)p);
    return p;
  }

  void *z = malloc(n);
  memcpy(z, p, h->cap);
  //puthex('x', (int)z);
  return z;
}

char *strdup(const char *s)
{
  int n = strlen(s);
  char *p = (char *) malloc(n + 1);
  strcpy(p, s);
  return p;
}

//////////////////////////

//////////////////////////

// Start actual picol.

enum { PICOL_OK, PICOL_ERR, PICOL_RETURN, PICOL_BREAK, PICOL_CONTINUE };
enum { PT_ESC, PT_STR, PT_CMD, PT_VAR, PT_SEP, PT_EOL, PT_EOF };

struct picolParser {
  char *text;
  char *p;                      /* current text position */
  int len;                      /* remaining length */
  char *start;                  /* token start */
  char *end;                    /* token end */
  int type;                     /* token type, PT_... */
  int insidequote;              /* True if inside " " */
};

struct picolVar {
  char *name, *val;
  struct picolVar *next;
};

struct picolInterp;             /* forward declaration */
typedef int (*picolCmdFunc)(struct picolInterp * i, int argc, char **argv,
                            void *privdata);

struct picolCmd {
  char *name;
  picolCmdFunc func;
  void *privdata;
  struct picolCmd *next;
};

struct picolCallFrame {
  struct picolVar *vars;
  struct picolCallFrame *parent;        /* parent is NULL at top level */
};

struct picolInterp {
  int level;                    /* Level of nesting */
  struct picolCallFrame *callframe;
  struct picolCmd *commands;
  char *result;
};

void picolInitParser(struct picolParser *p, char *text)
{
  p->text = p->p = text;
  p->len = strlen(text);
  p->start = 0;
  p->end = 0;
  p->insidequote = 0;
  p->type = PT_EOL;
}

int picolParseSep(struct picolParser *p)
{
  p->start = p->p;
  while (*p->p == ' ' || *p->p == '\t' || *p->p == '\n' || *p->p == '\r') {
    p->p++;
    p->len--;
  }
  p->end = p->p - 1;
  p->type = PT_SEP;
  return PICOL_OK;
}

int picolParseEol(struct picolParser *p)
{
  p->start = p->p;
  while (*p->p == ' ' || *p->p == '\t' || *p->p == '\n' || *p->p == '\r'
         || *p->p == ';') {
    p->p++;
    p->len--;
  }
  p->end = p->p - 1;
  p->type = PT_EOL;
  return PICOL_OK;
}

int picolParseCommand(struct picolParser *p)
{
  int level = 1;
  int blevel = 0;
  p->start = ++p->p;
  p->len--;
  while (1) {
    if (p->len == 0) {
      break;
    } else if (*p->p == '[' && blevel == 0) {
      level++;
    } else if (*p->p == ']' && blevel == 0) {
      if (!--level)
        break;
    } else if (*p->p == '\\') {
      p->p++;
      p->len--;
    } else if (*p->p == '{') {
      blevel++;
    } else if (*p->p == '}') {
      if (blevel != 0)
        blevel--;
    }
    p->p++;
    p->len--;
  }
  p->end = p->p - 1;
  p->type = PT_CMD;
  if (*p->p == ']') {
    p->p++;
    p->len--;
  }
  return PICOL_OK;
}

int picolParseVar(struct picolParser *p)
{
  p->start = ++p->p;
  p->len--;                     /* skip the $ */
  while (1) {
    if ((*p->p >= 'a' && *p->p <= 'z')
        || (*p->p >= 'A' && *p->p <= 'Z') || (*p->p >= '0' && *p->p <= '9')
        || *p->p == '_') {
      p->p++;
      p->len--;
      continue;
    }
    break;
  }
  if (p->start == p->p) {       /* It's just a single char string "$" */
    p->start = p->end = p->p - 1;
    p->type = PT_STR;
  } else {
    p->end = p->p - 1;
    p->type = PT_VAR;
  }
  return PICOL_OK;
}

int picolParseBrace(struct picolParser *p)
{
  int level = 1;
  p->start = ++p->p;
  p->len--;
  while (1) {
    if (p->len >= 2 && *p->p == '\\') {
      p->p++;
      p->len--;
    } else if (p->len == 0 || *p->p == '}') {
      level--;
      if (level == 0 || p->len == 0) {
        p->end = p->p - 1;
        if (p->len) {
          p->p++;
          p->len--;             /* Skip final closed brace */
        }
        p->type = PT_STR;
        return PICOL_OK;
      }
    } else if (*p->p == '{')
      level++;
    p->p++;
    p->len--;
  }
  return PICOL_OK;              /* unreached */
}

int picolParseString(struct picolParser *p)
{
  int newword = (p->type == PT_SEP || p->type == PT_EOL
                 || p->type == PT_STR);
  if (newword && *p->p == '{')
    return picolParseBrace(p);
  else if (newword && *p->p == '"') {
    p->insidequote = 1;
    p->p++;
    p->len--;
  }
  p->start = p->p;
  while (1) {
    if (p->len == 0) {
      p->end = p->p - 1;
      p->type = PT_ESC;
      return PICOL_OK;
    }
    switch (*p->p) {
    case '\\':
      if (p->len >= 2) {
        p->p++;
        p->len--;
      }
      break;
    case '$':
    case '[':
      p->end = p->p - 1;
      p->type = PT_ESC;
      return PICOL_OK;
    case ' ':
    case '\t':
    case '\n':
    case '\r':
    case ';':
      if (!p->insidequote) {
        p->end = p->p - 1;
        p->type = PT_ESC;
        return PICOL_OK;
      }
      break;
    case '"':
      if (p->insidequote) {
        p->end = p->p - 1;
        p->type = PT_ESC;
        p->p++;
        p->len--;
        p->insidequote = 0;
        return PICOL_OK;
      }
      break;
    }
    p->p++;
    p->len--;
  }
  return PICOL_OK;              /* unreached */
}

int picolParseComment(struct picolParser *p)
{
  while (p->len && *p->p != '\n') {
    p->p++;
    p->len--;
  }
  return PICOL_OK;
}

int picolGetToken(struct picolParser *p)
{
TOP:
  while (1) {
    if (!p->len) {
      if (p->type != PT_EOL && p->type != PT_EOF)
        p->type = PT_EOL;
      else
        p->type = PT_EOF;
      return PICOL_OK;
    }
    switch (*p->p) {
    case ' ':
    case '\t':
    case '\r':
      if (p->insidequote)
        return picolParseString(p);
      return picolParseSep(p);
    case '\n':
    case ';':
      if (p->insidequote)
        return picolParseString(p);
      return picolParseEol(p);
    case '[':
      return picolParseCommand(p);
    case '$':
      return picolParseVar(p);
    case '#':
      if (p->type == PT_EOL) {
        picolParseComment(p);
        goto TOP;               /* continue; */
      }
      return picolParseString(p);
    default:
      return picolParseString(p);
    }
  }
  return PICOL_OK;              /* unreached */
}

void picolInitInterp(struct picolInterp *i)
{
  i->level = 0;
  i->callframe =
      (struct picolCallFrame *) malloc(sizeof(struct picolCallFrame));
  i->callframe->vars = NULL;
  i->callframe->parent = NULL;
  i->commands = NULL;
  i->result = strdup("");
}

void picolSetResult(struct picolInterp *i, const char *s)
{
  free(i->result);
  i->result = strdup(s);
}

struct picolVar *picolGetVar(struct picolInterp *i, const char *name)
{
  struct picolVar *v = i->callframe->vars;
  while (v) {
    if (strcasecmp(v->name, name) == 0)
      return v;
    v = v->next;
  }
  return NULL;
}

int picolSetVar(struct picolInterp *i, const char *name, const char *val)
{
  struct picolVar *v = picolGetVar(i, name);
  if (v) {
    free(v->val);
    v->val = strdup(val);
  } else {
    v = (struct picolVar *) malloc(sizeof(*v));
    v->name = strdup(name);
    v->val = strdup(val);
    v->next = i->callframe->vars;
    i->callframe->vars = v;
  }
  return PICOL_OK;
}

struct picolCmd *picolGetCommand(struct picolInterp *i, const char *name)
{
  struct picolCmd *c = i->commands;
  while (c) {
    if (strcasecmp(c->name, name) == 0)
      return c;
    c = c->next;
  }
  return NULL;
}

int picolRegisterCommand(struct picolInterp *i, const char *name,
                         picolCmdFunc f, void *privdata)
{
  struct picolCmd *c = picolGetCommand(i, name);
  char errbuf[BUF_SIZE];
  if (c) {
    snprintf_s(errbuf, BUF_SIZE, "Command '%s' already defined", name);
    picolSetResult(i, errbuf);
    return PICOL_ERR;
  }
  c = (struct picolCmd *) malloc(sizeof(*c));
  c->name = strdup(name);
  c->func = f;
  c->privdata = privdata;
  c->next = i->commands;
  i->commands = c;
  return PICOL_OK;
}

/* EVAL! */
int picolEval(struct picolInterp *i, char *t)
{
  struct picolParser p;
  int argc = 0, j;
  char **argv = NULL;
  char errbuf[BUF_SIZE];
  int retcode = PICOL_OK;
  picolSetResult(i, "");
  picolInitParser(&p, t);
  while (1) {
    char *t;
    int tlen;
    int prevtype = p.type;
    picolGetToken(&p);
    if (p.type == PT_EOF)
      break;
    tlen = p.end - p.start + 1;
    if (tlen < 0)
      tlen = 0;
    t = (char *) malloc(tlen + 1);
    memcpy(t, p.start, tlen);
    t[tlen] = '\0';
    if (p.type == PT_VAR) {
      struct picolVar *v = picolGetVar(i, t);
      if (!v) {
        snprintf_s(errbuf, BUF_SIZE, "No such variable '%s'", t);
        free(t);
        picolSetResult(i, errbuf);
        retcode = PICOL_ERR;
        goto err;
      }
      free(t);
      t = strdup(v->val);
    } else if (p.type == PT_CMD) {
      retcode = picolEval(i, t);
      free(t);
      if (retcode != PICOL_OK)
        goto err;
      t = strdup(i->result);
    } else if (p.type == PT_ESC) {
      /* XXX: escape handling missing! */
    } else if (p.type == PT_SEP) {
      prevtype = p.type;
      free(t);
      continue;
    }
    /* We have a complete command + args. Call it! */
    if (p.type == PT_EOL) {
      struct picolCmd *c;
      free(t);
      prevtype = p.type;
      if (argc) {
        if ((c = picolGetCommand(i, argv[0])) == NULL) {
          snprintf_s(errbuf, BUF_SIZE, "No such command '%s'", argv[0]);
          picolSetResult(i, errbuf);
          retcode = PICOL_ERR;
          goto err;
        }
        retcode = c->func(i, argc, argv, c->privdata);
        if (retcode != PICOL_OK)
          goto err;
      }
      /* Prepare for the next command */
      for (j = 0; j < argc; j++)
        free(argv[j]);
      free(argv);
      argv = NULL;
      argc = 0;
      continue;
    }
    /* We have a new token, append to the previous or as new arg? */
    if (prevtype == PT_SEP || prevtype == PT_EOL) {
      argv = (char **) realloc(argv, sizeof(char *) * (argc + 1));
      argv[argc] = t;
      argc++;
    } else {                    /* Interpolation */
      int oldlen = strlen(argv[argc - 1]), tlen = strlen(t);
      argv[argc - 1] = (char *) realloc(argv[argc - 1], oldlen + tlen + 1);
      memcpy(argv[argc - 1] + oldlen, t, tlen);
      argv[argc - 1][oldlen + tlen] = '\0';
      free(t);
    }
    prevtype = p.type;
  }
err:
  for (j = 0; j < argc; j++)
    free(argv[j]);
  free(argv);
  return retcode;
}

/* ACTUAL COMMANDS! */
int picolArityErr(struct picolInterp *i, char *name)
{
  char buf[BUF_SIZE];
  snprintf_s(buf, BUF_SIZE, "Wrong number of args for %s", name);
  picolSetResult(i, buf);
  return PICOL_ERR;
}

int picolCommandMath(struct picolInterp *i, int argc, char **argv,
                     void *pd)
{
  char buf[8];
  int a, b, c;
  if (argc != 3)
    return picolArityErr(i, argv[0]);
  a = atoi(argv[1]);
  b = atoi(argv[2]);
  if (argv[0][0] == '+')
    c = a + b;
  else if (argv[0][0] == '-')
    c = a - b;
  else if (argv[0][0] == '*')
    c = a * b;
  else if (argv[0][0] == '/')
    c = a / b;
  else if (argv[0][0] == '>' && argv[0][1] == '\0')
    c = a > b;
  else if (argv[0][0] == '>' && argv[0][1] == '=')
    c = a >= b;
  else if (argv[0][0] == '<' && argv[0][1] == '\0')
    c = a < b;
  else if (argv[0][0] == '<' && argv[0][1] == '=')
    c = a <= b;
  else if (argv[0][0] == '=' && argv[0][1] == '=')
    c = a == b;
  else if (argv[0][0] == '!' && argv[0][1] == '=')
    c = a != b;
  else
    c = 0;                      /* I hate warnings */
  snprintf_d(buf, 8, "%d", c);
  picolSetResult(i, buf);
  return PICOL_OK;
}

int picolCommandSet(struct picolInterp *i, int argc, char **argv, void *pd)
{
  if (argc != 2 && argc != 3)
    return picolArityErr(i, argv[0]);
  if (argc == 2) {
    // with one argument, get var.
    struct picolVar *s = picolGetVar(i, argv[1]);
    if (!s) {
      picolSetResult(i, "no such var");
      return PICOL_ERR;
    }
    picolSetResult(i, s->val);
    return PICOL_OK;
  }
  // with two arguments, set var.
  picolSetVar(i, argv[1], argv[2]);
  picolSetResult(i, argv[2]);
  return PICOL_OK;
}

int picolCommandPuts(struct picolInterp *i, int argc, char **argv,
                     void *pd)
{
  char *argv0 = argv[0];
  byte nonewline = false;
  // any dash argument must be -nonewline.
  if (argc > 2 && argv[1][0] == '-') {
    nonewline = true;
    argc--, argv++;
  }
  if (argc != 2 && argc != 3)
    return picolArityErr(i, argv0);
  // defaults to path 1.
  int path = (argc == 3) ? atoi(argv[1]) : 1;
  int unused;
  int e = Os9WritLn(path, argv[argc - 1], strlen(argv[argc - 1]), &unused);
  if (e)
    return Error(i, argv0, e);
  if (!nonewline) {
    e = Os9WritLn(path, "\r", 1, &unused);
    if (e)
      return Error(i, argv0, e);
  }
  return PICOL_OK;
}

int picolCommandIf(struct picolInterp *i, int argc, char **argv, void *pd)
{
  int retcode;
  if (argc != 3 && argc != 5)
    return picolArityErr(i, argv[0]);
  if ((retcode = picolEval(i, argv[1])) != PICOL_OK)
    return retcode;
  if (atoi(i->result))
    return picolEval(i, argv[2]);
  else if (argc == 5)
    return picolEval(i, argv[4]);
  return PICOL_OK;
}

int picolCommandAnd(struct picolInterp *i, int argc, char **argv, void *pd)
{
  int n = 1;
  for (int j = 1; j < argc; j++) {
    int e = picolEval(i, argv[j]);
    if (e)
      return e;
    n = atoi(i->result);
    if (!n)
      return ResultD(i, 0);
  }
  return ResultD(i, n);
}

int picolCommandOr(struct picolInterp *i, int argc, char **argv, void *pd)
{
  for (int j = 1; j < argc; j++) {
    int e = picolEval(i, argv[j]);
    if (e)
      return e;
    int n = atoi(i->result);
    if (n)
      return ResultD(i, n);
  }
  return ResultD(i, 0);
}

int picolCommandWhile(struct picolInterp *i, int argc, char **argv,
                      void *pd)
{
  if (argc != 3)
    return picolArityErr(i, argv[0]);
  while (1) {
    int retcode = picolEval(i, argv[1]);
    if (retcode != PICOL_OK)
      return retcode;
    if (atoi(i->result)) {
      if ((retcode = picolEval(i, argv[2])) == PICOL_CONTINUE)
        continue;
      else if (retcode == PICOL_OK)
        continue;
      else if (retcode == PICOL_BREAK)
        return PICOL_OK;
      else
        return retcode;
    } else {
      return PICOL_OK;
    }
  }
}

int picolCommandRetCodes(struct picolInterp *i, int argc, char **argv,
                         void *pd)
{
  if (argc != 1)
    return picolArityErr(i, argv[0]);
  if (strcasecmp(argv[0], "break") == 0)
    return PICOL_BREAK;
  else if (strcasecmp(argv[0], "continue") == 0)
    return PICOL_CONTINUE;
  return PICOL_OK;
}

void picolDropCallFrame(struct picolInterp *i)
{
  struct picolCallFrame *cf = i->callframe;
  struct picolVar *v = cf->vars, *t;
  while (v) {
    t = v->next;
    free(v->name);
    free(v->val);
    free(v);
    v = t;
  }
  i->callframe = cf->parent;
  free(cf);
}

int picolCommandCallProc(struct picolInterp *i, int argc, char **argv,
                         void *pd)
{
  char **x = (char **) pd, *alist = x[0], *body = x[1], *p =
      strdup(alist), *tofree;
  struct picolCallFrame *cf =
      (struct picolCallFrame *) malloc(sizeof(*cf));
  int arity = 0, done = 0, errcode = PICOL_OK;
  char errbuf[BUF_SIZE];
  cf->vars = NULL;
  cf->parent = i->callframe;
  i->callframe = cf;
  tofree = p;
  while (1) {
    char *start = p;
    while (*p != ' ' && *p != '\0')
      p++;
    if (*p != '\0' && p == start) {
      p++;
      continue;
    }
    if (p == start)
      break;
    if (*p == '\0')
      done = 1;
    else
      *p = '\0';
    if (++arity > argc - 1)
      goto arityerr;
    picolSetVar(i, start, argv[arity]);
    p++;
    if (done)
      break;
  }
  free(tofree);
  if (arity != argc - 1)
    goto arityerr;
  errcode = picolEval(i, body);
  if (errcode == PICOL_RETURN)
    errcode = PICOL_OK;
  picolDropCallFrame(i);        /* remove the called proc callframe */
  return errcode;
arityerr:
  snprintf_s(errbuf, BUF_SIZE, "Proc '%s' called with wrong arg num",
             argv[0]);
  picolSetResult(i, errbuf);
  picolDropCallFrame(i);        /* remove the called proc callframe */
  return PICOL_ERR;
}

int picolCommandProc(struct picolInterp *i, int argc, char **argv,
                     void *pd)
{
  char **procdata = (char **) malloc(sizeof(char *) * 2);
  if (argc != 4)
    return picolArityErr(i, argv[0]);
  procdata[0] = strdup(argv[2]);        /* arguments list */
  procdata[1] = strdup(argv[3]);        /* procedure body */
  return picolRegisterCommand(i, argv[1], picolCommandCallProc, procdata);
}

int picolCommandReturn(struct picolInterp *i, int argc, char **argv,
                       void *pd)
{
  if (argc != 1 && argc != 2)
    return picolArityErr(i, argv[0]);
  picolSetResult(i, (argc == 2) ? (const char *) argv[1] : "");
  return PICOL_RETURN;
}

int picolCommandExit(struct picolInterp *i, int argc, char **argv,
                     void *pd)
{
  if (argc != 1 && argc != 2)
    return picolArityErr(i, argv[0]);
  exit((argc == 2) ? atoi(argv[1]) : 0);
  return PICOL_OK;
}

int picolCommandInfo(struct picolInterp *i, int argc, char **argv,
                     void *pd)
{
  puts(" procs: ");
  struct picolCmd *c;
  for (c = i->commands; c; c = c->next) {
    if (c->func != picolCommandCallProc)
      continue;
    puts(c->name);
    puts(" ");
    c = c->next;
  }
  puts("\r");

  puts(" other commands: ");
  for (c = i->commands; c; c = c->next) {
    if (c->func == picolCommandCallProc)
      continue;
    puts(c->name);
    puts(" ");
    c = c->next;
  }
  puts("\r");

  struct picolCallFrame *f;
  for (f = i->callframe; f; f = f->parent) {
    puts(f->parent ? " frame: " : " globals: ");
    struct picolVar *v;
    for (v = f->vars; v; v = v->next) {
      puts(v->name);
      puts("=");
      puts(v->val);
      puts(" ");
    }
    puts("\r");
  }

  picolSetResult(i, "");
  return PICOL_OK;
}

char **NewVec()
{
  return (char **) malloc(2);
}

char **AppendVec(char **vec, int veclen, char *s)
{
  vec = (char **) realloc((void *) vec, 2 * (veclen + 1));
  vec[veclen] = s;
  return vec;
}

char *NewBuf()
{
  char *z = (char *) malloc(1);
  z[0] = '\0';
  return z;
}

char *AppendBuf(char *buf, int buflen, char x)
{
  buf = (char *) realloc((void *) buf, buflen + 2);
  buf[buflen] = x;
  buf[buflen + 1] = '\0';
  return buf;
}

int SplitList(char *s, int *argcP, char ***argvP)
{
  char **vec = NewVec();
  int veclen = 0;

  while (*s) {
    while (*s && *s <= 32) {    // skip white
//puthex('s', *s);
      s++;
    }
    char *b = NewBuf();
    int blen = 0;
    while (*s && *s > 32) {     // copy word
//puthex('x', *s);
      b = AppendBuf(b, blen, *s);
      blen++;
      s++;
    }
    if (blen) {
//puthex('v', veclen);
//puthex('v', vec);
      vec = AppendVec(vec, veclen, b);
//puthex('v', vec);
      veclen++;
    }
  }
  *argvP = vec;
  *argcP = veclen;
//puthex('V', vec);
//puthex('L', veclen);
  return PICOL_OK;
}

int picolCommandCatch(struct picolInterp *i, int argc, char **argv,
                      void *pd)
{
  if (argc != 2 && argc != 3)
    return picolArityErr(i, argv[0]);
  char *body = argv[1];
  char *resultVar = (argc == 3) ? argv[2] : (char *) NULL;
  int e = picolEval(i, body);
  if (resultVar) {
    picolSetVar(i, resultVar, i->result);
  }
  return ResultD(i, e);
}

int picolCommandForEach(struct picolInterp *i, int argc, char **argv,
                        void *pd)
{
  if (argc != 4)
    return picolArityErr(i, argv[0]);
  char *var = argv[1];
  char *list = argv[2];
  char *body = argv[3];

  int c = 0;
  char **v = NULL;
  int err = SplitList(list, &c, &v);
  for (int j = 0; j < c; j++) {
    picolSetVar(i, var, v[j]);
    int e = picolEval(i, body);
    if (e == PICOL_CONTINUE)
      continue;
    if (e == PICOL_BREAK)
      break;
    if (e != PICOL_OK)
      return e;
  }

  picolSetResult(i, "");
  return PICOL_OK;
}

char *FormList(int argc, char **argv)
{
  char *b = NewBuf();
  int blen = 0;
  for (int i = 0; i < argc; i++) {
    if (i > 0) {
      b = AppendBuf(b, blen, ' ');
      blen++;
    }
    char *p = argv[i];
    while (*p) {
      b = AppendBuf(b, blen, *p);
      blen++;
      p++;
    }
  }
  return b;
}

int picolCommandList(struct picolInterp *i, int argc, char **argv,
                     void *pd)
{
  char *s = FormList(argc - 1, argv + 1);
  picolSetResult(i, s);
  return PICOL_OK;
}

int Error(struct picolInterp *i, char *argv0, int err)
{
  char buf[32];
  snprintf_s(buf, 32, "%s: ERROR %d", argv0);
  char buf2[32];
  snprintf_d(buf2, 32, buf, err);
  picolSetResult(i, buf2);
  return PICOL_ERR;
}

int ResultD(struct picolInterp *i, int x)
{
  char buf[32];
  snprintf_d(buf, 32, "%d", x);
  picolSetResult(i, buf);
  return PICOL_OK;
}

int picolCommandChain(struct picolInterp *i, int argc, char **argv,
                      void *pd)
{
  if (argc < 2) {
    picolSetResult(i, "chain: too few args");
    return PICOL_ERR;
  }
  char *program = argv[1];
  char *params = FormList(argc - 2, argv + 2);
  int e = Os9Chain(program, params, strlen(params), 0 /*lang_type */ ,
                   0 /*mem_size */ );
  // If returns, it is an error.
  return Error(i, argv[0], e);
}

int picolCommandFork(struct picolInterp *i, int argc, char **argv,
                     void *pd)
{
  if (argc < 2) {
    picolSetResult(i, "fork: too few args");
    return PICOL_ERR;
  }
  char *program = argv[1];
  char *params = FormList(argc - 2, argv + 2);
  int child_id = 0;
  int e = Os9Fork(program, params, strlen(params), 0 /*lang_type */ ,
                  0 /*mem_size */ , &child_id);
  if (e)
    return Error(i, argv[0], e);
  return ResultD(i, child_id);
}

int picolCommandWait(struct picolInterp *i, int argc, char **argv,
                     void *pd)
{
  if (argc != 1)
    return picolArityErr(i, argv[0]);
  int child_id = 0;
  int e = Os9Wait(&child_id);
  if (e)
    return Error(i, argv[0], e);
  return ResultD(i, child_id);
}

int picolCommandDup(struct picolInterp *i, int argc, char **argv, void *pd)
{
  if (argc != 2)
    return picolArityErr(i, argv[0]);
  int new_path = 0;
  int path = atoi(argv[1]);
  int e = Os9Dup(path, &new_path);
  if (e)
    return Error(i, argv[0], e);
  return ResultD(i, new_path);
}

int picolCommandClose(struct picolInterp *i, int argc, char **argv,
                      void *pd)
{
  if (argc != 2)
    return picolArityErr(i, argv[0]);
  int path = atoi(argv[1]);
  int e = Os9Close(path);
  if (e)
    return Error(i, argv[0], e);
  picolSetResult(i, "");
  return PICOL_OK;
}

int picolCommandSleep(struct picolInterp *i, int argc, char **argv,
                      void *pd)
{
  if (argc != 2)
    return picolArityErr(i, argv[0]);
  int ticks = atoi(argv[1]);
  int e = Os9Sleep(ticks);
  if (e)
    return Error(i, argv[0], e);
  picolSetResult(i, "");
  return PICOL_OK;
}

void picolRegisterCoreCommands(struct picolInterp *i)
{
  int j;
  const char *name[] =
      { "+", "-", "*", "/", ">", ">=", "<", "<=", "==", "!=" };
  for (j = 0; j < (int) (sizeof(name) / sizeof(char *)); j++)
    picolRegisterCommand(i, name[j], picolCommandMath, NULL);
  picolRegisterCommand(i, "set", picolCommandSet, NULL);
  picolRegisterCommand(i, "puts", picolCommandPuts, NULL);
  picolRegisterCommand(i, "if", picolCommandIf, NULL);
  picolRegisterCommand(i, "and", picolCommandAnd, NULL);
  picolRegisterCommand(i, "or", picolCommandOr, NULL);
  picolRegisterCommand(i, "while", picolCommandWhile, NULL);
  picolRegisterCommand(i, "break", picolCommandRetCodes, NULL);
  picolRegisterCommand(i, "continue", picolCommandRetCodes, NULL);
  picolRegisterCommand(i, "proc", picolCommandProc, NULL);
  picolRegisterCommand(i, "return", picolCommandReturn, NULL);
  picolRegisterCommand(i, "info", picolCommandInfo, NULL);
  picolRegisterCommand(i, "foreach", picolCommandForEach, NULL);
  picolRegisterCommand(i, "catch", picolCommandCatch, NULL);
  picolRegisterCommand(i, "list", picolCommandList, NULL);
  // low-level os9 commands.
  picolRegisterCommand(i, "exit", picolCommandExit, NULL);
  picolRegisterCommand(i, "chain", picolCommandChain, NULL);
  picolRegisterCommand(i, "fork", picolCommandFork, NULL);
  picolRegisterCommand(i, "wait", picolCommandWait, NULL);
  picolRegisterCommand(i, "dup", picolCommandDup, NULL);
  picolRegisterCommand(i, "close", picolCommandClose, NULL);
}

void ReduceBigraphs(char *s)
{
  char *z = s;                  // read from p, write to z.
  for (char *p = s; *p; p++) {
    if (p[0] == '(') {
      if (p[1] == '(') {
        *z++ = '{';
        p++;
      } else {
        *z++ = '[';
      }
    } else if (p[0] == ')') {
      if (p[1] == ')') {
        *z++ = '}';
        p++;
      } else {
        *z++ = ']';
      }
    } else {
      *z++ = *p;
    }
  }
  *z = '\0';
}

int main()
{
  char line[80];
  struct picolInterp interp;
  puts(" *alpha*");
  picolInitInterp(&interp);
  puts(" *beta*");
  picolRegisterCoreCommands(&interp);
  puts(" *gamma*");

  while (1) {
    int retcode;
    puts(" >NCL> ");
    bzero(line, sizeof line);
    int bytes_read;
    int e = Os9ReadLn(0 /*path */ , line, 80, &bytes_read);
    if (e) {
      puts(" *EOF*\r");
      break;
    }
    ReduceBigraphs(line);
    retcode = picolEval(&interp, line);
    if (interp.result[0] != '\0') {
      snprintf_d(line, 80, "[%d] <<", retcode);
      puts(line);
      puts(interp.result);
      puts(">>\r");
    }
  }
  exit(0);
  return 0;
}
