// platform.c
// for NEKOT OS on 6809

#include "forth.h"

FILE stdin[1] = { { 0, }, };
FILE stdout[1] = { { 1, }, };
FILE stderr[1] = { { 2, }, };

void abort() {
    printf("\nFATAL: ABORT.");
    exit(13);
}
void exit(int a) {
    printf("\nEXIT.");
    while (true) {}
}
int feof(FILE* f) { return 0; }
void fflush(FILE* f) {}
int fgetc(FILE* f) { return '*'; }
int fputc(int ch, FILE* f) { return 0; }
int isspace(int ch) { return ch <= 32; }

int printf(const char* fmt, ... ) { return 1; }

int strlen(const char* s) { return 1; }
