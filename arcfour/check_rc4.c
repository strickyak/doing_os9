#include <cmoc.h>

#include "arc4.h"
#include "ssh-arcfour.h"

typedef unsigned char byte;

byte state[260];

ArcfourContext context;

int main() {
    for (int j=0; j<256; j++) {
        state[j] = (byte)j;
        context.state[j] = (byte)j;
    }
    state[256] = 0;
    state[257] = 0;
    context.x = 0;
    context.y = 0;

    int bad = 0;
    int i;
    for (i=0; i<1000; i++) {
        byte b = arc4_byte(state);    // OS9 ASM
        byte c = (byte) arcfour_byte(&context);  // SSH C
        printf("%3d:  (%3d %3d) %3d  (%3d %3d) %3d\n", i, state[256], state[257], b, context.x, context.y, c);

        if (state[256] != context.x) { bad = -1; }
        if (state[257] != context.y) { bad = -2; }
        if (b != c) { bad = -3; }

        for (int j=0; j<256; j+=16) {
          // printf("[%3d] ", j);
          for (int k=j; k<j+16; k++) {
            // printf("%3d%s%3d ", state[k], state[k]==context.state[k] ? "." : "#", context.state[k]);
            if (state[k] != context.state[k]) bad = k+1;
          }
          // printf("\n");
        }

        if (bad) { break; }
    } 
    printf("%s(%d) i=%d\n", (bad ? "bad" : "good"), bad, i);

    return 0;
}
