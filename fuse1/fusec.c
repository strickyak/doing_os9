typedef unsigned char byte;
typedef unsigned char error;
typedef unsigned int word;

#include "os9.h"
#include "os9errno.h"

struct SubDaemon {
  // First 5 bytes are same for Client and Daemon.
  byte d_id;    // zero if inactive record.
  byte d_zero;  // zero for device, nonzero for Client Path.
  byte d_daemon_id;
  byte d_pathdesc;

  byte d_num_clients;
  byte d_x;

  char d_pathname[32];
};

struct SubClient {
  // First 5 bytes are same for Client and Daemon.
  byte c_id;     // zero if inactive record.
  byte c_parent; // zero for device, nonzero for Client Path.
  byte c_client_id;
  byte c_pathdesc;

  byte c_state;
  byte c_client_op;

  word c_arg1;
  word c_arg2;
  word c_arg3;
  word c_arg4;

  word c_result_count;
  byte c_result_status;

  char c_pathname[32];
};

struct DeviceTableEntry {
  word dt_device_driver_module;
  struct DeviceVars *dt_device_vars;
  word dt_device_desc;
  word dt_fileman;
  byte dt_num_users;
  word dt_drivex;
  word dt_fmgrex;
};
#define DEV_TAB_ENTRY_SIZE 13

struct DeviceVars {
  byte v_page;  // extended port addr
  word v_port;  // base port addr
  byte v_lprc;  // Last Active Process Id (not used?)
  byte v_busy;  // Active process ID (0 == not busy)
  byte v_wake;  // Process ID to wake after command completed
  byte v_7;     // Skip spare byte at 7 -- aligns following words better.
  // Beginning of fileman / driver's vars.
  word fuse_alloc_base;   // base for alloc 64.
  word fuse_alloc_first;  // wasted first page (for now).
};

struct PathDesc {
  byte pd_path_num;              // PD.PD = 0
  byte pd_mode;                  // PD.MOD = 1
  byte pd_open_count;            // PD.CNT = 2
  void* pd_device_table_entry;   // PD.DEV = 3
  byte pd_current_process_id;    // PD.CPR = 5
  struct Regs *pd_callers_regs;  // PD.RGS = 6
  void* pd_buffer_addr;          // PD.BUF = 8
  // offset 10 = PD.FST
  byte pd_fuse_state;
  // offset 11
  char pd_usable[32-11];                
  // offset 32 required for Get/Set Stat.
  byte pd_device_type;           // PD.DTP = 32
  char pd_options[31];           // more SetStat/GetStat region.
};
#define PDSIZE 64

struct Regs {
  byte rcc, ra, rb, rdp;
  word rx, ry, ru, rpc;
};

////////////////////////////////////////////////

void ShowChar(char ch) {
  asm {
    ldb ch
      clra
      swi
      fcb 104
  }
}

void ShowHex(word num) {
  asm {
    ldd num
      swi
      fcb 103
  }
}

void ShowRam(word addr) {
  asm {
    ldd addr
      swi
      fcb 105
  }
}

void ShowStr(const char* s) {
  for (; *s; s++) {
    ShowChar(*s);
  }
}

////////////////////////////////////////////////

asm Disable() {
  asm {
    orcc #IntMasks
    rts
  }
}

asm Enable() {
  asm {
    andcc #^IntMasks
    rts
  }
}

error Os9Move(word count, word src, byte srcMap, word dest, byte destMap) {
  error err;
  word dreg = ((word)srcMap << 8) | destMap;
  asm {
    PSHS Y,U

    LDD dest
    PSHS D    ;  temporarily push the U arg.

    LDD dreg
    LDX src
    LDY count

    PULS U    ; must change U last, because it was frame pointer for formal parameters.
    SWI2
    FCB F_MOVE
    PULS Y,U
    bcs MoveBad

    clrb
MoveBad
    stb err
  }
  return err;
}

error Os9Send(byte to_pid, byte signal) {
  error err;
  asm {
    PSHS Y,U       ; save frame
    lda to_pid
    ldb signal
    SWI2
    FCB F$Send
    PULS Y,U       ; restore frame
    BCS SendBad

    CLRB
SendBad
    stb err
  }
}

error Os9Sleep(word num_ticks) {
  error err;
  asm {
    PSHS Y,U       ; save frame
    ldx num_ticks
    SWI2
    FCB F$Sleep
    PULS Y,U       ; restore frame
    BCS SleepBad

    CLRB
SleepBad
    stb err
  }
}

error Os9All64(word base_page, byte* index_out, word* addr_out) {
  error err;
  asm {
    PSHS Y,U       ; save frame
    LDX base_page

    SWI2
    FCB F$All64

    TFR Y,X        ; addr
    PULS Y,U       ; restore frame
    BCS All64Bad

    STX [addr_out]
    STA [index_out]
    CLRB
All64Bad
    STB err
  }
  return err;
}

error Os9Find64(word base_page, byte index_wanted, word* addr_out) {
  error err;
  asm {
    PSHS Y,U       ; save frame
    LDX base_page
    LDA index_wanted

    SWI2
    FCB F$Find64

    TFR Y,X        ; addr
    PULS Y,U       ; restore frame
    BCs Find64Bad

    STX [addr_out]
    CLRB
Find64Bad
    STB err
  }
  return err;
}

error Os9Ret64(word base_page, byte index) {
  error err;
  asm {
    PSHS Y,U       ; save frame
    LDX base_page
    LDA index

    SWI2
    FCB F$Ret64

    TFR Y,X        ; addr
    PULS Y,U       ; restore frame
    BCs Ret64Bad

    CLRB
Ret64Bad
    STB err
  }
  return err;
}

// Probably don't need AllRAM
error Os9AllRAM(byte num_pages, void* *addr_out) {
  error err;
  asm {
    LDB num_pages

    PSHS Y,U
    SWI2
    FCB $39 ; F$AllRAM
    PULS Y,U

    STD [addr_out]
    BCS AllRamBad    ; D & Carry still available.
    CLRB    ; OK status
AllRamBad
    STB err
  }
  return err;
}

error Os9PrsNam(char* ptr, char** eow_out, char**next_name_out) {
  error err;
  asm {
      LDX ptr
      LEAS -6,S  // room for post-U (8,S) post-D (6,S), post-Y (+4,S)
      PSHS Y,U   // after pre-Y (2,S) and pre-U (0,S)
                 //
      SWI2
      FCB $10 ; F$PrsNam

      STY 4,S
*     STD 6,S * not needed
*     STU 8,S * not needed
      PULS U,Y

      STX [eow_out]         ; post-X
      LDX 0,S               ; post-Y
      STX [next_name_out]

      LEAS 6,S
      BCS PrsNamBad    ; D & Carry still available.
      CLRB    ; OK status
PrsNamBad
      STB err
  }
  return err;
}

////////////////////////////////////////////////

void ShowModuleName(word addr) {
  ShowChar('@'); ShowHex(addr);
  word magic = *(word*)addr;
  if (magic != 0x87CD) {
    ShowStr("BAD MAGIC:");
    ShowHex(magic);
    return;
  }
  word name_offset = *(2 + (word*)addr);
  byte ch;
  ShowChar('\'');
  do {
    ch = *(char*)(addr + name_offset);
    ShowChar(ch);
    name_offset++;
  } while ((ch&128) == 0);
  ShowChar('\'');
}

void ShowRegs(struct Regs* rp) {
  ShowChar('@'); ShowHex(rp); ShowChar(13);
  ShowStr("ra"); ShowHex(rp->ra); ShowChar(13);
  ShowStr("rb"); ShowHex(rp->rb); ShowChar(13);
  ShowStr("rx"); ShowHex(rp->rx); ShowChar(13);
  ShowStr("ry"); ShowHex(rp->ry); ShowChar(13);
  ShowStr("ru"); ShowHex(rp->ru); ShowChar(13);
  ShowChar(13);
}

void ShowDeviceTableEntry(struct DeviceTableEntry* dt) {
  ShowChar('@'); ShowHex(dt); ShowChar(13);
  ShowStr("drive_mod"); ShowHex(dt->dt_device_driver_module); ShowModuleName(dt->dt_device_driver_module); ShowChar(13);
  ShowStr("device_vars"); ShowHex(dt->dt_device_vars); ShowChar(13);
  ShowStr("device_desc"); ShowHex(dt->dt_device_desc); ShowModuleName(dt->dt_device_desc); ShowChar(13);
  ShowStr("fileman"); ShowHex(dt->dt_fileman); ShowModuleName(dt->dt_fileman); ShowChar(13);
  ShowStr("num_users"); ShowHex(dt->dt_num_users); ShowChar(13);
  ShowStr("driv ex"); ShowHex(dt->dt_drivex); ShowChar(13);
  ShowStr("fmgr ex"); ShowHex(dt->dt_fmgrex); ShowChar(13);
  ShowChar(13);
}
void ShowPathDesc(struct PathDesc* pd) {
  ShowChar('@'); ShowHex(pd); ShowChar(13);
  ShowStr("path_num"); ShowHex(pd->pd_path_num); ShowChar(13);
  ShowStr("mode"); ShowHex(pd->pd_mode); ShowChar(13);
  ShowStr("open_count"); ShowHex(pd->pd_open_count); ShowChar(13);
  ShowStr("device_table_entry"); ShowHex(pd->pd_device_table_entry); ShowChar(13);
  ShowStr("current_process_id"); ShowHex(pd->pd_current_process_id); ShowChar(13);
  ShowStr("callers_regs"); ShowHex(pd->pd_callers_regs); ShowChar(13);
  ShowStr("buffer_addr"); ShowHex(pd->pd_buffer_addr); ShowChar(13);
  ShowStr("fuse_state"); ShowHex(pd->pd_fuse_state); ShowChar(13);
  ShowStr("device_type"); ShowHex(pd->pd_device_type); ShowChar(13);
  ShowChar(13);
  ShowRam((word)pd->pd_device_table_entry); ShowChar(13);
  ShowDeviceTableEntry((struct DeviceTableEntry*)(pd->pd_device_table_entry));
  ShowChar(13);
}

////////////////////////////////////////////////

asm CreateOrOpenA() {
  asm {
    DAA      ; Entering CreateOrOpenA
    PSHS Y,U ; push pathdesc & regs as args to the "C" function.
    LDU #0   ; begin C frames
    LDD #0
    LDX #0
    LDY #0   ; unneccesary cleanliness
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
  error err;
  ShowChar('P'); ShowHex(pathdesc);
  ShowRam((word)pathdesc);
  ShowRam(32+(word)pathdesc);
  ShowRegs(regs);
  ShowPathDesc(pathdesc);

  // ------------ no this is per path, not once per device -----------------
  // ------------ this should bd All64 out of the AllRAM -------------------
  err = Os9AllRAM(/*nPages=*/1, &pathdesc->pd_buffer_addr);
  ShowChar('A'); ShowHex(pathdesc->pd_buffer_addr); ShowHex(err); 
  if (err) return err;
  pathdesc->pd_fuse_state = 20;

  do {
    char *eow = 0, *next_name = 0;
    err = Os9PrsNam((char*)regs->rx, &eow, &next_name);
    regs->rx = next_name;
  } while (err==0);

  ShowChar('Z');
  return 0;
}

asm CloseA() {
  asm {
    PSHS Y,U ; First push Y=pathdesc, then U=regs
    LDU #0   ; begin C frames
    LDD #0
    LDX #0
    LDY #0   ; unneccesary cleanliness
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
    LDU #0   ; begin C frames
    LDD #0
    LDX #0
    LDY #0   ; unneccesary cleanliness
    BSR _ReadLnC  ; Call C function to do the work.
    LBRA FinishUp
  }
}
error ReadLnC(struct PathDesc* pathdesc, struct Regs* regs) {
  if (pathdesc->pd_fuse_state >= 30) {
    ShowChar('E');
    regs->ry = 0;  // count
    return E_EOF;
  } else {
    ShowChar('R');
    ShowHex(pathdesc->pd_fuse_state);
    pathdesc->pd_fuse_state ++;
    regs->ry = 1;  // count
  }
  return 0;
}

asm WritLnA() {
  asm {
    PSHS Y,U ; First push Y=pathdesc, then U=regs
    LDU #0   ; begin C frames
    LDD #0
    LDX #0
    LDY #0   ; unneccesary cleanliness
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
    LDU #0   ; begin C frames
    LDD #0
    LDX #0
    LDY #0   ; unneccesary cleanliness
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
    LDU #0   ; begin C frames
    LDD #0
    LDX #0
    LDY #0   ; unneccesary cleanliness
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
    LDU #0   ; begin C frames
    LDD #0
    LDX #0
    LDY #0   ; unneccesary cleanliness
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
    LDU #0   ; begin C frames
    LDD #0
    LDX #0
    LDY #0   ; unneccesary cleanliness
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
    LDU #0   ; begin C frames
    LDD #0
    LDX #0
    LDY #0   ; unneccesary cleanliness
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
    &p-> pd_device_table_entry,
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
