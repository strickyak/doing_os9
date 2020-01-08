// Up(c): convert to upper case for 26 ascii letters.
char Up(char c)
{
  return ('a' <= c && c <= 'z') ? c - 32 : c;
}

char Down(char c)
{
  return ('A' <= c && c <= 'Z') ? c + 32 : c;
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

char *strdup(const char *s)
{

  int n = strlen(s);
  char *p = (char *) malloc(n + 1);
  strcpy(p, s);
  return p;
}

char *strdup_upper(const char *s)
{
  int n = strlen(s);
  char *z = (char *) malloc(n + 1);
  char *p = z;
  while (*s) {
    *p++ = Up(*s++);
  }
  return z;
}
