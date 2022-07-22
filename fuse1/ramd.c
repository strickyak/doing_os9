#include <assert.h>
#include <cmoc.h>

#include "os9call/os9call.h"

typedef unsigned char bool;
typedef unsigned char byte;
typedef unsigned char error;
typedef unsigned int word;

#define CHECK(ACTION)                                                         \
  {                                                                           \
    int _err = ACTION;                                                         \
    if (_err) {                                                                \
      printf("\nFAILURE in line %d: %s: error %d\n", __LINE__, #ACTION, _err); \
      exit(_err);                                                              \
    }                                                                         \
  }

char contents[4096];
int contents_len;

char pbuf[200];

byte HexChar(byte a) {
  a = a & 15;
  if (a < 10) return '0' + a;
  return 'A' + a - 10;
}
void PrintX(char** pp, word x) {
  if (x > 15) {
    PrintX(pp, x>>4);
  }
  *(*pp) = HexChar((byte)x);
  ++(*pp);
}
void PrintD(char** pp, word x) {
  if (x > 10) {
    PrintX(pp, x/10);
    x = x%10;
  }
  *(*pp) = (byte)x + '0';
  ++(*pp);
}
void PrintS(char** pp, word x) {
  const char* s = (const char*) x;
  while (*s) {
    *(*pp) = *s++;
    ++(*pp);
  }
}
void PrintQ(char** pp, word x) {
  const char* s = (const char*) x;
  while (*s) {
    if (' ' <= *s && *s <= '~') {
      *(*pp) = *s++;
    } else {
      *(*pp)++ = '{';
      PrintD(pp, *s++);
      *(*pp)++ = '}';
    }
    ++(*pp);
  }
}

void Printf(const char* fmt, ...) {
  word* arg = (word*) &fmt;
  arg++;
  char* p = pbuf;
  const char* s = fmt;
  while (*s) {
    if (*s == '%') {
      s++;
      if (*s == 'x') {
        PrintX(&p, *arg++);
      } else if (*s == 'd') {
        PrintD(&p, *arg++);
      } else if (*s == 's') {
        PrintS(&p, *arg++);
      } else if (*s == 'q') {
        PrintQ(&p, *arg++);
      } else if (*s == '%') {
        *p++ = *s;
      } else {
        *p++ = '?';
        *p++ = *s;
        *p++ = '?';
      }
    } else {
        *p++ = *s;
    }
    s++;
  }
  int written = 0;
  CHECK(Os9WritLn(1/*=stdout*/, pbuf, p - pbuf, &written));
  assert(written = p - pbuf);
}

byte DeHex(byte ch) {
  if ('0' <= ch && ch <= '9') {
    return ch - '0';
  }
  if ('A' <= ch && ch <= 'Z') {
    return ch - 'A' + 10;
  }
  if ('a' <= ch && ch <= 'z') {
    return ch - 'a' + 10;
  }
  assert(0);
}
void PutHexByte(byte** pp, byte b) {
  *(*pp) = HexChar(b >> 4);
  ++(*pp);
  *(*pp) = HexChar(b);
  ++(*pp);
}
void SendStatus(int ram_fd, error status, word len) {
  byte ssbuf[16];
  byte* p = ssbuf;
  PutHexByte(&p, status);
  *p++ = ' ';
  PutHexByte(&p, (byte)(len >> 8));
  PutHexByte(&p, (byte)len);
  *p++ = '\n';
  *p++ = 0;

  int written = 0;
  Printf("@@@@@@@@  Status Status Status Status\n");
  CHECK(Os9WritLn(ram_fd, (const char*) ssbuf, p - ssbuf, &written));
  assert(written = p - ssbuf);
}

char* xp;
char xbuf[200];
void StartParse() { xp = xbuf; }
void SkipSpaces() {
  while (*xp == ' ') {
    xp++;
    assert(xp < xbuf + sizeof xbuf);
  }
}
byte ParseChar() {
  SkipSpaces();
  assert(*xp > ' ');  // cannot be EOS or control char
  return *xp++;
}
byte ParseHexByte() {
  // THIS IS WRONG -- ParseChar does not DeHex it.
  byte a = ParseChar();
  byte b = ParseChar();
  return (a << 4) | b;
}
word ParseHexWord() {
  byte a = ParseHexByte();
  byte b = ParseHexByte();
  return ((word)a << 8) | b;
}
int main() {
  int ram_fd;
  CHECK(Os9Open("/fuse/daemon/ram", 3, &ram_fd));
  Printf("@@@@@@@@ Daemon Opened\n");
  while (1) {
    int len = 0;
    int eee;
    CHECK((eee = Os9ReadLn(ram_fd, xbuf, sizeof xbuf - 1, &len)));
    Printf("@@@@@@@@ Daemon command: err=$%x=%d. len=$%x=%d  xbuf = {{{%q}}}\n",
           eee, eee, len, len, xbuf);
    assert(len > 3);      // sanity.
    xbuf[len + 1] = '\0';  // Ensure NUL-termination.

    StartParse();
    byte op = ParseChar();
    switch (op) {
      case 'o': {  // Open
        Printf("@@@@@@@@  Open\n");
        SendStatus(ram_fd, 0, 0);
        break;
      }
      case 'R': {  // ReadLn
        Printf("@@@@@@@@  ReadLn\n");
        SendStatus(ram_fd, 0, contents_len);
        Printf("@@@@@@@@  ReadLn===WritLn\n");
        CHECK(Os9WritLn(ram_fd, contents, contents_len, &len));
        assert(len == contents_len);
        break;
      }
      case 'W': {  // WritLn
        Printf("@@@@@@@@  WritLn\n");
        Printf("@@@@@@@@  ReadLn===ReadLn\n");
        CHECK(Os9ReadLn(ram_fd, contents, sizeof contents - 1, &contents_len));
        contents[contents_len + 1] = '\0';  // Ensure NUL-termination.
        Printf("@@@@@@@@  Contents {{{%q}}}\n", contents);
        SendStatus(ram_fd, 0, contents_len);
        break;
      }
      case 'C': {  // Close
        Printf("@@@@@@@@  Close\n");
        SendStatus(ram_fd, 0, 0);
        break;
      }
      default: {
        Printf("\n@@@@@@@@ ERROR: Unknown op: $%x `%c`\n", op, op);
        assert(0);
        break;
      }
    }
  }
  /*NOTREACHED*/
  return 0;
}
