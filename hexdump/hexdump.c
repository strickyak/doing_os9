#include <stdio.h>

main()
{
  int x, y, z;
  int ch;
  unsigned char buf[16];

  for (x = 0; x < 0x1000; x++) {
    /* Read in a chunk of 16 bytes, or to EOF */
    for (y=0; y<16; y++) {
      ch = getchar();
      if (ch < 0) break;
      buf[y] = ch;
    }
    /* Print the address of the first byte of the chunk */
    printf("%03x0  ", x);
    /* Print the bytes as hex */
    for (z=0; z<16; z++) {
      if (z < y) {
        printf("%02x ", (unsigned char)buf[z]);
      } else {
        printf("   ");
      }
    }
    printf("   ");
    /* Print the bytes as 7-bit ASCII */
    for (z=0; z<16; z++) {
      if (z < y) {
        int ch = buf[z] & 127;
        if (32 <= ch && ch < 127) {
          printf("%c", ch);
        } else {
          printf("~");
        }
      }
    }
    printf("   ");
    /* Print the bytes as 6-bit VDG characters */
    for (z=0; z<16; z++) {
      if (z < y) {
        int ch = buf[z] & 63;
        ch = (ch < 32) ? ch + 64 : ch;
        printf("%c", ch);
      }
    }
    printf("\n");
  }
}
