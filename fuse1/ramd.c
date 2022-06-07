#include <cmoc.h>
#include <assert.h>

#include "os9call/os9call.h"

typedef unsigned char bool;
typedef unsigned char byte;
typedef unsigned char error;
typedef unsigned int word;

char* p;
char buf[200];
char contents[4096];
int contents_len;

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
  printf("@@@@@@@@ Daemon Opened\n");
  while (1) {
    int len = 0;
    byte eee;
    CHECK( (eee = Os9ReadLn(ram_fd, buf, sizeof buf - 1, &len)) );
    printf("@@@@@@@@ Daemon command: err=$%x=%d. len=%d  buf = {{{%s}}}\n", eee, eee, len, buf);
    assert(len > 3);    // sanity.
    buf[len+1] = '\0';  // Ensure NUL-termination.

    StartParse();
    byte op = ParseChar();
    switch (op) {
      case 'o':
        printf("@@@@@@@@  Open\n");
        break;
      case 'R':
        printf("@@@@@@@@  ReadLn\n");
        CHECK( Os9WritLn(ram_fd, contents, contents_len, &len) );
        assert( len == contents_len );
        break;
      case 'W':
        printf("@@@@@@@@  WriteLn\n");
        CHECK( Os9ReadLn(ram_fd, contents, sizeof contents - 1, &contents_len) );
        contents[contents_len+1] = '\0';  // Ensure NUL-termination.
        printf("@@@@@@@@  Contents {{{%s}}}\n", contents);
        break;
      case 'C':
        printf("@@@@@@@@  Close\n");
        break;
      default:
        printf("\n@@@@@@@@ ERROR: Unknown op: $%x `%c`\n", op, op);
        break;
    }
  }
  /*NOTREACHED*/
  return 0;
}

#if 0
asm os9call_dummy() {
  asm {
    use ../os9call/os9call.raw.a
  }
}
#endif
