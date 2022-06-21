// ny: NitroYak: Yak Libs for NitrOS9

#include "nylib/nylib.h"

bool ny_white(char c) {
  return (byte)c <= ' ';
}

int ny_split(char* s, char* *words_out, int max_words) {
  int count = 0;
  while (count < max_words) {
    while (*s && ny_white(*s)) s++; // skip white space.
    if (!*s) break;
    *words_out++ = s;
    ++count;
    while (*s && !ny_white(*s)) s++; // skip non-white.
    if (!*s) break;
    *s++ = '\0';
  }
  return count;
}
