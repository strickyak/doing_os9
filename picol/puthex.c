char hexchar(byte i) {
  if (0 <= i && i <= 9)
    return (char) ('0' + i);
  if (10 <= i && i <= 15)
    return (char) ('A' + i - 10);
  return '?';
}

// puthex prints a prefix and a hex number, like `(p=1234)`,
// only using a small buffer.  Quick and reliable for debugging.
void puthex(char prefix, int a) {
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
void panic(const char *s) {
  pc_trace('*', 0);
  puts(s);
  exit(5);
}
