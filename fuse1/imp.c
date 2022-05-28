typedef unsigned char byte;
typedef unsigned char error;
typedef unsigned int word;

#include "os9.h"
#include "os9errno.h"

struct PathDesc {
  byte pd_path_num;                   // PD.PD = 0
  byte pd_mode;                       // PD.MOD = 1
  byte pd_open_count;                 // PD.CNT = 2
  void* pd_device_table_entry_addr;   // PD.DEV = 3
  byte pd_current_process_id;         // PD.CPR = 5
  struct Regs *pd_callers_regs;   // PD.RGS = 6
  void* pd_buffer_addr;               // PD.BUF = 8
  char pd_storage[22-1];                // PD.FST = 10
  byte pd_fuse_state;
  byte pd_device_type;                // PD.DTP = 32  // required
  // char pd_junk[15];
  // byte pd_fuse_state;
};
#define PDSIZE 64

struct Regs {
  byte rcc, ra, rb, rdp;
  word rx, ry, ru, rpc;
};

////////////////////////////////////////////////

void HPutChar(char ch) {
  asm {
    ldb ch
      clra
      swi
      fcb 104
  }
}

void HPutHex(word num) {
  asm {
    ldd num
      swi
      fcb 103
  }
}

////////////////////////////////////////////////

error Os9ParseName(char* ptr, char** eow_out, char**next_name_out) {
  error e;
  asm {
      LDX ptr
      LEAS -4,S  // room for post-D (6,S), post-Y (+4,S)
      PSHS Y,U   // after pre-Y (2,S) and pre-U (0,S)
                 //
      SWI2
      FCB $10 ; F$PrsNam

*     STD 6,S ; not needed -- D is untouched.
      STY 4,S
      PULS U,Y

      STX [eow_out]         ; post-X
      LDX 0,S               ; post-Y
      STX [next_name_out]

      LEAS 4,S
      BCS PrsNamBad    ; D & Carry still available.
      CLRB    ; OK status
PrsNamBad
      STB e
  }
  return e;
}

////////////////////////////////////////////////

asm CreateOrOpenA() {
  asm {
    PSHS Y,U ; push pathdesc & regs as args to the "C" function.
    BSR _CreateOrOpenC  ; Call C function to do the work.
FinishUp
    CLRA     ; clear the carry bit.
    TSTB     ; we want to set carry if B nonzero.
    BEQ SkipComA  ; skip the COMA, which sets the carry bit.
    COMA
SkipComA
    PULS PC,U,Y
  }
}

error CreateOrOpenC(struct PathDesc* pathdesc, struct Regs* regs) {
  error e;
  do {
    char *eow = 0, *next_name = 0;
    e = Os9ParseName((char*)regs->rx, &eow, &next_name);
    regs->rx = next_name;
  } while (e==0);

  pathdesc->pd_fuse_state = 20;
  return 0;
}

asm CloseA() {
  asm {
    PSHS Y,U ; First push Y=pathdesc, then U=regs
    BSR _CloseC  ; Call C function to do the work.
    LBRA FinishUp
  }
}
error CloseC(struct PathDesc* pathdesc, struct Regs* regs) {
  return 0;
}

asm ReadLnA() {
  asm {
    PSHS Y,U ; First push Y=pathdesc, then U=regs
    BSR _ReadLnC  ; Call C function to do the work.
    LBRA FinishUp
  }
}
error ReadLnC(struct PathDesc* pathdesc, struct Regs* regs) {
  if (pathdesc->pd_fuse_state >= 30) {
    HPutChar('E');
    regs->ry = 0;  // count
    return E_EOF;
  } else {
    HPutChar('R');
    HPutHex(pathdesc->pd_fuse_state);
    pathdesc->pd_fuse_state ++;
    regs->ry = 1;  // count
  }
  return 0;
}

asm WritLnA() {
  asm {
    PSHS Y,U ; First push Y=pathdesc, then U=regs
    BSR _WritLnC  ; Call C function to do the work.
    LBRA FinishUp
  }
}
error WritLnC(struct PathDesc* pathdesc, struct Regs* regs) {
  return 31;
}

asm ReadA() {
  asm {
    PSHS Y,U ; First push Y=pathdesc, then U=regs
    BSR _ReadC  ; Call C function to do the work.
    LBRA FinishUp
  }
}
error ReadC(struct PathDesc* pathdesc, struct Regs* regs) {
  regs->ry = 0;  // count
  return E_EOF;
}

asm WriteA() {
  asm {
    PSHS Y,U ; First push Y=pathdesc, then U=regs
    BSR _WriteC  ; Call C function to do the work.
    LBRA FinishUp
  }
}
error WriteC(struct PathDesc* pathdesc, struct Regs* regs) {
  return 32;
}

asm GetStatA() {
  asm {
    PSHS Y,U ; First push Y=pathdesc, then U=regs
    BSR _GetStatC  ; Call C function to do the work.
    LBRA FinishUp
  }
}
error GetStatC(struct PathDesc* pathdesc, struct Regs* regs) {
  switch (regs->rb) {
    case 1: { // SS.READY
      regs->rb = 0;
      return E_EOF;
    }
    case 6: { // SS.EOF
      regs->rb = 1;
      return 0;
    }
    default: {
      return 255;
    }
  }
}

asm SetStatA() {
  asm {
    PSHS Y,U ; First push Y=pathdesc, then U=regs
    BSR _SetStatC  ; Call C function to do the work.
    LBRA FinishUp
  }
}
error SetStatC(struct PathDesc* pathdesc, struct Regs* regs) {
  return 255;
}

asm xxxA() {
  asm {
    PSHS Y,U ; First push Y=pathdesc, then U=regs
    BSR _xxxC  ; Call C function to do the work.
    LBRA FinishUp
  }
}
error xxxC(struct PathDesc* pathdesc, struct Regs* regs) {
  return 3;
}


/*
#include <cmoc.h>
int main() {
  struct Regs* r = (struct Regs*) 1000;
  printf("%d %d %d %d\n", &r->rcc, &r->ra, &r->rb, &r->rdp);
  printf("%d %d %d %d\n", &r->rx, &r->ry, &r->ru, &r->rpc);

  struct PathDesc * p = (struct PathDesc*)1000;
  printf("0 %d 1 %d 2 %d 3 %d 5 %d 6 %d 8 %d 10 %d 32 %d",
    &p-> pd_path_num,
    &p-> pd_mode,
    &p-> pd_open_count,
    &p-> pd_device_table_entry_addr,
    &p-> pd_current_process_id,
    &p-> pd_callers_regs,
    &p-> pd_buffer_addr,
    &p-> pd_storage,
    &p-> pd_device_type 
  );
                                      //
  return 0;
}
*/
