#include <cmoc.h>
#include <assert.h>

#include "os9call/os9call.h"

typedef unsigned char bool;
typedef unsigned char byte;
typedef unsigned char error;
typedef unsigned int word;

char* p;
char buf[200];

#define CHECK(ACTION) {int err = ACTION; if (err) { printf("\nFAILURE in line %d: %s: error %d\n", __LINE__, #ACTION, err); exit(err); }}

byte DeHex(byte ch) {
  if ('0' <= ch && ch <= '9') { return ch - '0'; }
  if ('A' <= ch && ch <= 'Z') { return ch - 'A' + 10; }
  if ('a' <= ch && ch <= 'z') { return ch - 'a' + 10; }
  assert(0);
}
void StartParse() { p = buf; }
void SkipSpaces() {
  while (*p == ' ') {
    p++;
    assert(p < buf + sizeof buf);
  }
}
byte ParseChar() {
  SkipSpaces();
  assert(*p > ' ');  // cannot be EOS or control char
  return *p++;
}
byte ParseHexByte() {
  byte a = ParseChar();
  byte b = ParseChar();
  return (a<<4) | b;
}
word ParseHexWord() {
  byte a = ParseHexByte();
  byte b = ParseHexByte();
  return ((word)a << 8) | b;
}


int main() {
  int ram_fd;
  CHECK( Os9Open("/fuse/daemon/ram", 3, &ram_fd) );
  while (1) {
    int consumed = 0;
    CHECK( Os9ReadLn(ram_fd, buf, sizeof buf - 1, &consumed) );
    assert(consumed > 1);
    buf[consumed+1] = '\0';

    StartParse();
    byte op = ParseChar();
    switch (op) {
      case 'o':
        printf(" Open ");
        break;
      case 'R':
        printf(" ReadLn ");
        break;
      case 'W':
        printf(" WriteLn ");
        break;
      case 'C':
        printf(" Close ");
        break;
      default:
        printf("\nERROR: Unknown op: $%x `%c`\n", op, op);
        break;
    }
  }
  return 0;
}

#if 0
asm os9call_dummy() {
  asm {
    use ../os9call/os9call.raw.a
  }
}
#endif
