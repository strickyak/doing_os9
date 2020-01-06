/* ncl: Modified for cmoc for NitrOS9/OS9 by strick.  BSD licensed */

/* Tcl in ~ 500 lines of code by Salvatore antirez Sanfilippo.  BSD licensed */

#define RAM_SIZE 12000
#define BUF_SIZE 200            /* instead of 1024 */
#define MAX_SCRIPT_SIZE 500     /* instead of 8K or 16K */

#define NULL 0
#define false 0
#define true 1

typedef unsigned char byte;
typedef unsigned int uint;

extern int Error(struct picolInterp *i, char *argv0, int err);
extern int ResultD(struct picolInterp *i, int x);

extern char *malloc(int);
extern void free(void *);
extern char *realloc(void *, int);

// In order to get all code into a single assembly listing for the module,
// we include these C files instead of using the linker to link the usual stuff.

#include "os9.c"

#include "puthex.c"

#include "std.c"

#include "malloc.c"

#include "buf.c"

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

struct picolArray {
  char *name;
  struct picolVar *vars;
  struct picolArray *next;
};

typedef int (*picolCmdFunc)(struct picolInterp * i, int argc, char **argv, void *privdata);

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
  struct picolArray *arrays;
  char *result;
};

void FreeDope(int c, const char **v)
{
  for (int j = 0; j < c; j++)
    free((void *) v[j]);        // Free the strings.
  free(v);                      // Free the vector.
}

#if 0
char **NewVec()
{
  return (char **) malloc(2);
}

char **AppendVec(char **vec, int veclen, char *s)
{
  vec = (char **) realloc(vec, 2 * (veclen + 1));
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
  buf = (char *) realloc(buf, buflen + 2);
  buf[buflen] = x;
  buf[buflen + 1] = '\0';
  return buf;
}

char *AppendBufS(char *buf, int *buflenP, char *s)
{
  while (*s) {
    buf = AppendBuf(buf, *buflenP, *s);
    s++;
    (*buflenP)++;
  }
  return buf;
}

char *AppendList(char *list, char *item)
{
  int n = strlen(list);
  if (n) {
    list = AppendBuf(list, n, ' ');
    n++;
  }
  list = AppendBufS(list, &n, item);
  return list;
}
#endif

void picolInitParser(struct picolParser *p, const char *text)
{
  p->text = p->p = (char *) text;
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
  while (*p->p == ' ' || *p->p == '\t' || *p->p == '\n' || *p->p == '\r' || *p->p == ';') {
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
  int newword = (p->type == PT_SEP || p->type == PT_EOL || p->type == PT_STR);
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
  i->callframe = (struct picolCallFrame *) malloc(sizeof(struct picolCallFrame));
  i->callframe->vars = NULL;
  i->callframe->parent = NULL;
  i->commands = NULL;
  i->arrays = NULL;
  i->result = strdup("");
}

void picolSetResult(struct picolInterp *i, const char *s)
{
  free(i->result);
  i->result = strdup(s);
}

void picolMoveToResult(struct picolInterp *i, const char *s)
{
  free(i->result);
  i->result = (char *) s;
}

struct picolVar *picolGetVarFromRoot(struct picolVar *v, const char *name)
{
  for (; v; v = v->next) {
    if (strcasecmp(v->name, name) == 0)
      return v;
  }
  return NULL;
}

struct picolVar *picolGetVar(struct picolInterp *i, const char *name)
{
  return picolGetVarFromRoot(i->callframe->vars, name);
}

int picolSetVarFromRoot(struct picolVar **root, const char *name, const char *val)
{
  struct picolVar *v = picolGetVarFromRoot(*root, name);
  if (v) {
    free(v->val);
    v->val = strdup(val);
  } else {
    v = (struct picolVar *) malloc(sizeof(*v));
    v->name = strdup(name);
    v->val = strdup(val);
    v->next = *root;
    *root = v;
  }
  return PICOL_OK;
}

int picolSetVar(struct picolInterp *i, const char *name, const char *val)
{
  return picolSetVarFromRoot(&i->callframe->vars, name, val);
}

struct picolCmd *picolGetCommand(struct picolInterp *i, const char *name)
{
  for (struct picolCmd * c = i->commands; c; c = c->next) {
    if (strcasecmp(c->name, name) == 0) {
      return c;
    }
  }
  return NULL;
}

struct picolArray *picolGetArray(struct picolInterp *i, const char *name)
{
  for (struct picolArray * p = i->arrays; p; p = p->next) {
    if (strcasecmp(p->name, name) == 0) {
      return p;
    }
  }
  return NULL;
};

int picolRegisterCommand(struct picolInterp *i, const char *name, picolCmdFunc f, void *privdata)
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
int picolEval(struct picolInterp *i, const char *t)
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

int picolCommandMath(struct picolInterp *i, int argc, char **argv, void *pd)
{
  char m1 = argv[0][0];
  char m2 = argv[0][1];
  char buf[8];
  int a, b, c;
  if (m1 == '+' || m1 == '*') {
    // + and * allow any number of args.
    c = (m1 == '+') ? 0 : 1;
    for (int j = 1; j < argc; j++) {
      b = atoi(argv[j]);
      c = (m1 == '+') ? c + b : c * b;
    }
  } else {
    // The rest apply to only 2 numbers.
    if (argc != 3)
      return picolArityErr(i, argv[0]);
    a = atoi(argv[1]);
    b = atoi(argv[2]);
    if (m1 == '+')
      c = a + b;
    else if (m1 == '-')
      c = a - b;
    else if (m1 == '*')
      c = a * b;
    else if (m1 == '/')
      c = a / b;
    else if (m1 == '>' && m2 == '\0')
      c = a > b;
    else if (m1 == '>' && m2 == '=')
      c = a >= b;
    else if (m1 == '<' && m2 == '\0')
      c = a < b;
    else if (m1 == '<' && m2 == '=')
      c = a <= b;
    else if (m1 == '=' && m2 == '=')
      c = a == b;
    else if (m1 == '!' && m2 == '=')
      c = a != b;
    else
      c = 0;                    /* I hate warnings */
  }
  snprintf_d(buf, 8, "%d", c);
  picolSetResult(i, buf);
  return PICOL_OK;
}

int NotFound(struct picolInterp *i)
{
  picolSetResult(i, "not found");
  return PICOL_ERR;
}

int picolCommandArray(struct picolInterp *i, int argc, char **argv, void *pd)
{
  struct Buf buf;
  BufInit(&buf);

  switch (argc) {
  default:
    return picolArityErr(i, argv[0]);

  case 1:{
      // List arrays.
      for (struct picolArray * p = i->arrays; p; p = p->next) {
        BufAppElemS(&buf, p->name);
      }
      BufFinish(&buf);
      picolMoveToResult(i, BufTake(&buf));
    }
    break;
  case 2:{
      // List keys of named array.
      struct picolArray *array = picolGetArray(i, argv[1]);
      if (!array) {
        return NotFound(i);
      }

      char *list = strdup("");
      for (struct picolVar * q = array->vars; q; q = q->next) {
        BufAppElemS(&buf, q->name);
      }
      BufFinish(&buf);
      picolMoveToResult(i, BufTake(&buf));
    }
    break;
  case 3:{
      struct picolArray *array = picolGetArray(i, argv[1]);
      if (!array) {
        return NotFound(i);
      }
      struct picolVar *var = picolGetVarFromRoot(array->vars, argv[2]);
      if (!var) {
        return NotFound(i);
      }
      picolSetResult(i, var->val);
    }
    break;
  case 4:{
      // Set variable.
      struct picolArray *array = picolGetArray(i, argv[1]);
      if (!array) {
        array = (struct picolArray *) malloc(sizeof *array);
        array->name = strdup(argv[1]);
        array->vars = NULL;
        array->next = i->arrays;
        i->arrays = array;
      }
      picolSetVarFromRoot(&array->vars, argv[2], argv[3]);
    }
    break;
  }
  BufDel(&buf);
  return PICOL_OK;
}

int picolCommandSplit(struct picolInterp *i, int argc, char **argv, void *pd)
{
  char *list = strdup("");
  switch (argc) {
  default:
    return picolArityErr(i, argv[0]);

  case 3:{
      char *s = argv[1];
      char d = argv[2][0];
      struct Buf list;
      BufInit(&list);
      while (*s) {
        struct Buf part;
        BufInit(&part);
        while (*s && *s != d) {
          BufAppC(&part, *s);
          s++;
        }
        if (*s)
          s++;                  // past d.


        BufAppElemS(&list, BufFinish(&part));
        BufDel(&part);
      }
      picolMoveToResult(i, BufTake(&list));
    }
    break;
  }
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

int picolCommandPuts(struct picolInterp *i, int argc, char **argv, void *pd)
{
  char *argv0 = argv[0];        // because argv may increment.
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

int picolCommandWhile(struct picolInterp *i, int argc, char **argv, void *pd)
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

int picolCommandRetCodes(struct picolInterp *i, int argc, char **argv, void *pd)
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

int picolCommandCallProc(struct picolInterp *i, int argc, char **argv, void *pd)
{
  char **x = (char **) pd, *alist = x[0], *body = x[1], *p = strdup(alist), *tofree;
  struct picolCallFrame *cf = (struct picolCallFrame *) malloc(sizeof(*cf));
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
  snprintf_s(errbuf, BUF_SIZE, "Proc '%s' called with wrong arg num", argv[0]);
  picolSetResult(i, errbuf);
  picolDropCallFrame(i);        /* remove the called proc callframe */
  return PICOL_ERR;
}

int picolCommandProc(struct picolInterp *i, int argc, char **argv, void *pd)
{
  char **procdata = (char **) malloc(sizeof(char *) * 2);
  if (argc != 4)
    return picolArityErr(i, argv[0]);
  procdata[0] = strdup(argv[2]);        /* arguments list */
  procdata[1] = strdup(argv[3]);        /* procedure body */
  return picolRegisterCommand(i, argv[1], picolCommandCallProc, procdata);
}

int picolCommandReturn(struct picolInterp *i, int argc, char **argv, void *pd)
{
  if (argc != 1 && argc != 2)
    return picolArityErr(i, argv[0]);
  picolSetResult(i, (argc == 2) ? (const char *) argv[1] : "");
  return PICOL_RETURN;
}

int picolCommandInfo(struct picolInterp *i, int argc, char **argv, void *pd)
{
  puts(" procs: ");
  struct picolCmd *c;
  for (c = i->commands; c; c = c->next) {
    if (c->func != picolCommandCallProc)
      continue;
    puts(c->name);
    puts(" ");
  }
  puts("\r");

  puts(" commands: ");
  for (c = i->commands; c; c = c->next) {
    if (c->func == picolCommandCallProc)
      continue;
    puts(c->name);
    puts(" ");
  }
  puts("\r");

  for (struct picolCallFrame * f = i->callframe; f; f = f->parent) {
    puts(f->parent ? " frame: " : " globals: ");
    for (struct picolVar * v = f->vars; v; v = v->next) {
      puts(v->name);
      puts("=");
      puts(v->val);
      puts(" ");
    }
    puts("\r");
  }

  puts(" arrays:\r");
  for (struct picolArray * array = i->arrays; array; array = array->next) {
    printf_s("   %s: ", array->name);
    for (struct picolVar * v = array->vars; v; v = v->next) {
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

int SplitList(const char *s, int *argcP, const char ***argvP)
{
  struct Buf dope;
  BufInit(&dope);

  while (*s) {
    while (*s && *s <= 32) {    // skip white
      s++;
    }
    if (!s)
      break;

    const char *end;
    int len = ElemLen(s, &end);
    const char *elem = ElemDecode(s);
    s = end;

    BufAppDope(&dope, elem);
  }
  *argvP = BufTakeDope(&dope, argcP);
  return PICOL_OK;
}

int picolCommandEval(struct picolInterp *i, int argc, char **argv, void *pd)
{
  struct Buf buf;
  BufInit(&buf);
  // Join the args simply with spaces.
  for (int j = 1; j < argc; j++) {
    if (j)
      BufAppC(&buf, ' ');
    BufAppS(&buf, argv[j], -1);
  }
  BufFinish(&buf);
  int e = picolEval(i, BufPeek(&buf));
  BufDel(&buf);
  return e;
}

int picolCommandCatch(struct picolInterp *i, int argc, char **argv, void *pd)
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

int picolCommandListIndex(struct picolInterp *i, int argc, char **argv, void *pd)
{
  if (argc != 3)
    return picolArityErr(i, argv[0]);
  char *list = argv[1];
  int j = atoi(argv[2]);

  int c = 0;
  const char **v = NULL;
  int err = SplitList(list, &c, &v);

  if (0 <= j && j < c) {
    picolSetResult(i, v[j]);
  }
  FreeDope(c, v);
  return PICOL_OK;
}

int picolCommandListRange(struct picolInterp *i, int argc, char **argv, void *pd)
{
  if (argc != 4)
    return picolArityErr(i, argv[0]);
  char *list = argv[1];
  int a = atoi(argv[2]);
  int b = atoi(argv[3]);

  int c = 0;
  const char **v = NULL;
  int err = SplitList(list, &c, &v);

  struct Buf result;
  BufInit(&result);
  for (int j = 0; j < c; j++) {
    if (a <= j && j <= b)
      BufAppElemS(&result, v[j]);
  }
  FreeDope(c, v);

  BufFinish(&result);
  picolMoveToResult(i, BufTake(&result));
  return PICOL_OK;
}

int picolCommandForEach(struct picolInterp *i, int argc, char **argv, void *pd)
{
  if (argc != 4)
    return picolArityErr(i, argv[0]);
  char *var = argv[1];
  char *list = argv[2];
  char *body = argv[3];

  int c = 0;
  const char **v = NULL;
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

  FreeDope(c, v);
  picolSetResult(i, "");
  return PICOL_OK;
}

const char *FormList(int argc, char **argv)
{
  struct Buf buf;
  BufInit(&buf);
  for (int i = 0; i < argc; i++) {
    BufAppElemS(&buf, argv[i]);
  }
  BufFinish(&buf);
  return BufTake(&buf);
}

int picolCommandList(struct picolInterp *i, int argc, char **argv, void *pd)
{
  const char *s = FormList(argc - 1, argv + 1);
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

// This currently serves as high-level "exit" and low-level "9exit".
// In the future, if there is cleanup (like flushing IO), a new "exit" will be needed.
int picolCommand9Exit(struct picolInterp *i, int argc, char **argv, void *pd)
{
  if (argc != 1 && argc != 2)
    return picolArityErr(i, argv[0]);
  exit((argc == 2) ? atoi(argv[1]) : 0);
  return PICOL_OK;
}

const char *AddCR(char *s)
{
  int n = strlen(s);
  s = realloc(s, n + 2);
  s[n] = '\r';
  return (const char *) s;
}

int picolCommand9Chain(struct picolInterp *i, int argc, char **argv, void *pd)
{
  if (argc < 2) {
    return picolArityErr(i, argv[0]);
  }
  char *program = argv[1];
  const char *params = FormList(argc - 2, argv + 2);
  params = AddCR((char *) params);
  int e = Os9Chain(program, params, strlen(params), 0 /*lang_type */ ,
                   0 /*mem_size */ );
  // If returns, it is an error.
  return Error(i, argv[0], e);
}

int picolCommand9Fork(struct picolInterp *i, int argc, char **argv, void *pd)
{
  if (argc < 2) {
    return picolArityErr(i, argv[0]);
  }
  char *program = argv[1];
  const char *params = FormList(argc - 2, argv + 2);
  params = AddCR((char *) params);
  int child_id = 0;
  int e = Os9Fork(program, params, strlen(params), 0 /*lang_type */ ,
                  0 /*mem_size */ , &child_id);
  if (e)
    return Error(i, argv[0], e);
  return ResultD(i, child_id);
}

int picolCommand9Wait(struct picolInterp *i, int argc, char **argv, void *pd)
{
  if (argc != 1)
    return picolArityErr(i, argv[0]);
  int child_id = 0;
  int e = Os9Wait(&child_id);
  if (e)
    return Error(i, argv[0], e);
  return ResultD(i, child_id);
}

int picolCommand9Dup(struct picolInterp *i, int argc, char **argv, void *pd)
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

int picolCommand9Close(struct picolInterp *i, int argc, char **argv, void *pd)
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

int picolCommand9Sleep(struct picolInterp *i, int argc, char **argv, void *pd)
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
  const char *mathOps[] = { "+", "-", "*", "/", ">", ">=", "<", "<=", "==", "!=", NULL };
  for (const char **p = mathOps; *p; p++)
    picolRegisterCommand(i, *p, picolCommandMath, NULL);
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
  picolRegisterCommand(i, "eval", picolCommandEval, NULL);
  picolRegisterCommand(i, "catch", picolCommandCatch, NULL);
  picolRegisterCommand(i, "list", picolCommandList, NULL);
  picolRegisterCommand(i, "lindex", picolCommandListIndex, NULL);
  picolRegisterCommand(i, "lrange", picolCommandListRange, NULL);
  picolRegisterCommand(i, "array", picolCommandArray, NULL);
  picolRegisterCommand(i, "split", picolCommandSplit, NULL);
  picolRegisterCommand(i, "exit", picolCommand9Exit, NULL);
  // low-level os9 commands:
  picolRegisterCommand(i, "9exit", picolCommand9Exit, NULL);
  picolRegisterCommand(i, "9chain", picolCommand9Chain, NULL);
  picolRegisterCommand(i, "9fork", picolCommand9Fork, NULL);
  picolRegisterCommand(i, "9wait", picolCommand9Wait, NULL);
  picolRegisterCommand(i, "9dup", picolCommand9Dup, NULL);
  picolRegisterCommand(i, "9close", picolCommand9Close, NULL);
  picolRegisterCommand(i, "9sleep", picolCommand9Sleep, NULL);
  picolEval(i, "proc fib x { if { < $x 2 } { return $x } ; + [fib [- $x 1] ] [fib [- $x 2]] }");
  picolEval(i, "proc tri x { if { < $x 2 } { return $x } ; + $x [tri [- $x 1]] }");
  picolEval(i,
            "proc iota x { set z {}; set i 0; while {< $i $x} { set z \"$z $i\" ; set i [+ $i 1] }; set z}");
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
  struct picolInterp interp;
  picolInitInterp(&interp);
  picolRegisterCoreCommands(&interp);

  while (1) {
    puts(" >NCL> ");
    char line[111];
    bzero(line, sizeof line);
    int bytes_read;
    int e = Os9ReadLn(0 /*path */ , line, 111, &bytes_read);
    if (e) {
      puts(" *EOF*\r");
      break;
    }
    ReduceBigraphs(line);
    e = picolEval(&interp, line);
    if (e) {
      puts(" ERROR: ");
      if (e > 1) {
        printf_d("CODE=%d: ", e);
      }
      puts(interp.result);
      puts("\r");
    } else {
      if (interp.result[0] != '\0') {
        puts(interp.result);
        puts("\r");
      }
    }
  }
  exit(0);
  return 0;
}
