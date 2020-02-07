// buf.c
//
// Buffers for accumulating strings and list items.

#define INITIAL_CAP 16

struct Buf {
  char *s;
  int n;
};

void BufCheck(struct Buf *p) {
  if (p->n < 0 || p->s == NULL || p->s > 0xC000) {
    panic("BufCheck fails");
  }
};

void BufInit(struct Buf *p) {
  p->s = malloc(INITIAL_CAP);
  p->n = 0;
}

void BufInitWith(struct Buf *p, const char *s) {
  p->s = strdup(s);
  p->n = strlen(s);
}

void BufInitTake(struct Buf *p, char *s) {
  p->s = s;
  p->n = strlen(s);
}

void BufDel(struct Buf *p) {
  // OK to delete more than once, or after BufTake().
  free(p->s);
  p->s = NULL;
  p->n = -1;
}

char *BufFinish(struct Buf *p) {
  BufCheck(p);
  p->s = realloc(p->s, p->n + 1);
  p->s[p->n] = '\0';
  return p->s;
}

const char *BufTake(struct Buf *p) {
  BufCheck(p);
  const char *z = p->s;
  p->s = NULL;
  p->n = -1;
  return z;
}

const char *BufPeek(struct Buf *p) {
  return p->s;
}

void BufAppC(struct Buf *p, char c) {
  BufCheck(p);
  ++p->n;
  p->s = realloc(p->s, p->n);
  p->s[p->n - 1] = c;
}

void BufAppS(struct Buf *p, const char *s, int n) {
  BufCheck(p);
  if (n < 0)
    n = strlen(s);
  p->s = realloc(p->s, p->n + n);
  char *t = p->s + p->n;
  for (int i = 0; i < n; i++) {
    *t++ = *s++;
  }
  p->n += n;
}

// Appending Elements.

void BufAppElemC(struct Buf *p, char c) {
  BufCheck(p);
  if (c <= ' ' || c > 'z' || c == '\\') {
    p->n += 2;
    p->s = realloc(p->s, p->n);
    p->s[p->n - 2] = '\\';
    p->s[p->n - 1] = c;
  } else {
    p->n += 1;
    p->s = realloc(p->s, p->n);
    p->s[p->n - 1] = c;
  }
}

void BufAppElemS(struct Buf *p, const char *s) {
  BufCheck(p);

  // Add space before next element, unless buf is empty.
  if (p->n)
    BufAppC(p, ' ');

  byte clean = true;
  for (const char *t = s; *t; t++) {
    if (*t <= ' ' || *t > 'z' || *t == '\\') {
      clean = false;
      break;
    }
  }
  if (clean && *s) {            // empty strings should not be clean.
    for (const char *t = s; *t; t++) {
      BufAppC(p, *t);
    }
  } else {
    BufAppC(p, '{');
    while (*s) {
      BufAppElemC(p, *s);
      s++;
    }
    BufAppC(p, '}');
  }
}

void BufAppDope(struct Buf *p, const char *s) {
  int n = p->n / sizeof(const char *);
  BufAppS(p, "  ", 2);
  ((const char **) p->s)[n] = s;
}

const char **BufTakeDope(struct Buf *p, int *lenP) {
  *lenP = p->n / sizeof(const char *);
  return (const char **) BufTake(p);
}

// Decoding elements.

// Return length of decoded element.
// Also the end of parsing.
int ElemLen(const char *s, const char **endP) {
  int n = 0;
  if (*s == '{') {
    // brace-wrapped element.
    s++;
    while (*s) {
      if (*s == '}') {
        s++;
        break;
      }
      if (*s == '\\') {
        ++s;                    // extra to jump over the backslash.
        ++n;
      }
      ++s;
      ++n;
    }
    // Warning: truncated element.
    *endP = s;
  } else {
    // bare element.
    const char *t = s;
    while (*t > ' ')
      ++t;
    *endP = t;
    n = t - s;
  }
  return n;
}

// Return decoded element. 
const char *ElemDecode(const char *s) {
  struct Buf buf;
  BufInit(&buf);
  if (*s == '{') {
    // brace-wrapped element.
    s++;
    while (*s) {
      if (*s == '}') {
        s++;
        break;
      }
      if (*s == '\\') {
        ++s;                    // extra to jump over the backslash.
      }
      BufAppC(&buf, *s);
      ++s;
    }
    // Warning: truncated element.
  } else {
    // bare element.
    const char *t = s;
    while (*t > ' ')
      ++t;
    BufAppS(&buf, s, t - s);
  }
  BufFinish(&buf);
  return BufTake(&buf);
}
