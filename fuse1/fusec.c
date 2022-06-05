typedef unsigned char bool;
typedef unsigned char byte;
typedef unsigned char error;
typedef unsigned int word;

#include "os9.h"
#include "os9errno.h"

#define OKAY 0
#define TRUE 1
#define FALSE 0
#define NULL ((void*)0)

enum FuseState {
  D_IDLE = 1,
  D_WAIT_FOR_WORK = 2,  // called ReadLn
  D_GIVEN_WORK = 3,     // ReadLn returned a Clop.
  C_POISON = 16,  // daemon death poisons its clients.
  C_IDLE = 17,   // no client stuff pending.
  C_REQUESTED = 18,  // client made an IO call (a Clop).
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

struct DeviceVars {
  byte v_page;  // extended port addr
  word v_port;  // base port addr
  byte v_lprc;  // Last Active Process Id (not used?)
  byte v_busy;  // Active process ID (0 == not busy)
  byte v_wake;  // Process ID to wake after command completed
  byte v_6;     // Skip spare byte at 6
  byte v_7;     // Skip spare byte at 7
  // Beginning of fileman / driver's vars.
  word fuse_alloc64_base;   // base for alloc 64.
  word fuse_alloc_first;  // wasted first page (for now).
};

struct Fuse { // embeds in PathDesc
  byte fuse_state;
  byte char_hack;
  struct PathDesc* parent_fd;  // NULL for daemon,  daemon for client.
  byte num_child;  // how many open clients a daemon has.
  struct PathDesc* current_client;
};

struct PathDesc {
  byte path_num;              // PD.PD = 0
  byte mode;                  // PD.MOD = 1
  byte open_count;            // PD.CNT = 2
  struct DeviceTableEntry*
        device_table_entry;   // PD.DEV = 3
  byte current_process_id;    // PD.CPR = 5
  struct Regs *regs;          // PD.RGS = 6
  word unused_buffer;         // PD.BUF = 8
  // offset 10 = PD.FST
  struct Fuse fuse;

  char usable[32-10-sizeof(struct Fuse)];

  // offset 32 required for Get/Set Stat.
  byte device_type;           // PD.DTP = 32
  char name[31];  // Can hold 30 chars plus a null.
};

struct Regs {
  byte rcc, ra, rb, rdp;
  word rx, ry, ru, rpc;
};

/////////////////  Hypervisor Debugging Support

asm HyperCoreDump() {
  asm {
    SWI
    FCB 100  ; hyperCoreDump
  }
}

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

#define assert(C) { if (!(C)) { ShowStr(" *ASSERT* "); ShowHex(__LINE__); ShowStr(" *FAILED* " #C); HyperCoreDump(); } }

////////////////////////////////////////////////

// For len is 255 or less.
void bzero(void* addr, byte len) {
  char* p = (char*) addr;
  for (byte i=0; i<len; i++) {
    *p++ = 0;
  }
}

byte ToUpper(byte b) {
  b = b&127; // remove high bit
  if ('a'<= b && b<='z') return b-32;
  return b;
}

asm IrqDisable() {
  asm {
    orcc #IntMasks
    rts
  }
}

asm IrqEnable() {
  asm {
    andcc #^IntMasks
    rts
  }
}

byte* Os9PathDescBaseTable() {
  byte* base;
  asm {
    LDD #D.PthDBT 
    STD base
  }
  return base;
}

byte Os9CurrentProcessId() {
  byte id = 0;
  asm {
    LDX D.Proc
    LDA P$ID,X
    STA id
  }
  return id;
}

byte Os9CurrentProcessTask() {
  byte task = 0;
  asm {
    LDX D.Proc
    LDA P$Task,X
    STA task
  }
  return task;
}

error Os9LoadByteFromTask(byte task, word addr, byte* out) {
  error err;
  asm {
    LDB task
    LDX addr
    PSHS Y,U
    SWI2
    FCB F$LDABX
    PULS Y,U
    STA [out]
    BCS LoadByteBad

    clrb
LoadByteBad
    stb err
  }
  return err;
}

error Os9StoreByteToTask(byte task, word addr, byte in) {
  error err;
  asm {
    LDA in
    LDB task
    LDX addr
    PSHS Y,U
    SWI2
    FCB F$STABX
    PULS Y,U
    BCS StoreByteBad

    clrb
StoreByteBad
    stb err
  }
  return err;
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
  return err;
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
  return err;
}

#if 0
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

    STX [addr_out]   ; was in Y
    STA [index_out]
    CLRB
All64Bad
    STB err
  }
  return err;
}
#endif

#if 0
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
#endif

#if 0
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
#endif

#if 0
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
#endif

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
  ShowStr("@pd@"); ShowHex(pd); ShowChar(13);
  ShowStr("path_num"); ShowHex(pd->path_num); ShowChar(13);
  ShowStr("mode"); ShowHex(pd->mode); ShowChar(13);
  ShowStr("open_count"); ShowHex(pd->open_count); ShowChar(13);
  ShowStr("device_table_entry"); ShowHex(pd->device_table_entry); ShowChar(13);
  ShowStr("current_process_id"); ShowHex(pd->current_process_id); ShowChar(13);
  ShowStr("regs"); ShowHex(pd->regs); ShowChar(13);
  ShowStr("fuse_state"); ShowHex(pd->fuse.fuse_state); ShowChar(13);
  ShowStr("char_hack"); ShowHex(pd->fuse.char_hack); ShowChar(13);
  ShowStr("device_type"); ShowHex(pd->device_type); ShowChar(13);
  ShowChar(13);
  // ShowRam((word)pd->device_table_entry); ShowChar(13);
  ShowDeviceTableEntry((struct DeviceTableEntry*)(pd->device_table_entry));
  ShowChar(13);
}

error CopyParsedName(word begin, word end, char* dest, word max_len) {
  // max_len counts null termination.
  assert (end-begin < max_len-1);
  byte task = Os9CurrentProcessTask();
  byte i = 0;
  for (word p = begin; p < end; p++) {
    byte ch = 0;
    error err = Os9LoadByteFromTask(task, p, &ch);
    if (err) return err;
    *dest++ = ToUpper(ch);
  }
  *dest = 0; // terminate
  return OKAY;
}

void ShowParsedName(word current, word begin, word end) {
  byte task = Os9CurrentProcessTask();
  ShowChar('{'); ShowChar('{'); ShowChar('{');
  ShowHex(end-current);
  ShowHex(end-begin);
  byte ch = 0;
  for (word p = current; p <= end; p++ ) {
    error err = Os9LoadByteFromTask(task, p, &ch);
    assert(!err);
    if (p == begin) ShowChar('~');
    if (p == end) ShowChar('~');
    ShowChar(ch);
  }
  ShowChar('}'); ShowChar('}'); ShowChar('}');
}

// Ignoring case is assumed, when Parsed Name is used.
// The string from begin to end is in the current
// process's task, and may contain high bits.
// The other string s is an upper-case 0-terminated
// C string, in normal memory, with no high bits.
bool ParsedNameEquals(word begin, word end, const char*s) {
  byte pid = Os9CurrentProcessId();
  byte task = Os9CurrentProcessTask();
  ShowStr(s);
  //ShowRam(begin);
  //ShowRam(s);
  word p = begin;
  for (; *s && p < end; p++, s++) {
    byte ch = 0;
    error err = Os9LoadByteFromTask(task, p, &ch);
    assert(!err);
    ShowHex(p); ShowHex(s);
    ShowChar(ch); ShowChar(*s);

    if (ToUpper(ch) != *s) {
      ShowChar('F');
      return FALSE;  // does not match.
    }
  }

  // If both termination conditions are true,
  // strings are equal.
  ShowChar('R');
  ShowHex( ((*s)==0) );
  ShowHex( (p==end) );
      ShowChar('R');
  ShowHex( (p==end) && ((*s)==0) );
  ShowChar(13);
  ShowChar(13);
  return (p==end) && ((*s)==0);
}

////////////////////////////////////////////////

#if 0
word BaseForAlloc64(struct PathDesc* pathdesc) {
  assert(pathdesc);
    struct DeviceTableEntry* dte =
      (struct DeviceTableEntry*)(pathdesc->device_table_entry);
  assert(dte);
    struct DeviceVars *vars = dte->dt_device_vars;
  assert(vars);
    word base = vars->fuse_alloc64_base;
  assert(base);
  return base;
}
#endif

#if 0
struct Daemon* MakeDaemon(word base, word begin, word end) {
  struct Daemon *d = NULL;
  byte index = 0;
  error err = Os9All64(base, &index, (word*)&d);
  assert(!err);
  assert(d->d_id == index);
  err = CopyParsedName(begin, end, d->d_daemon_name, 30);
  assert(!err);
  return d;
}

struct Client* MakeClient(word base, word begin, word end) {
  struct Client *c = NULL;
  byte index = 0;
  error err = Os9All64(base, &index, (word*)&c);
  assert(!err);
  assert(c->c_id == index);
  err = CopyParsedName(begin, end, c->c_client_name, 30);
  assert(!err);
  return c;
}
#endif

// FindDaemon traverses all path descriptors looking for
// one that is (1) open (path_num is set),
// (2) has the given device_table_entry (it is a /fuse),
// (3) is a daemon path (the parent_fd is null),
// (4) has the name indicated by begin/end.
struct PathDesc* FindDaemon(struct DeviceTableEntry* dte, word begin, word end) {
  byte* table = Os9PathDescBaseTable();
  for (byte i = 0; i < 64; i++) {
    byte page = table[i];
    if (!page) continue;
    word addr = (word)page << 8;
    for (byte j = 0; j<4; j++) {
      if (i!=0 || j!=0) {
        struct PathDesc* pd = (struct PathDesc*)addr;
        if (pd->path_num && pd->device_table_entry == dte && !pd->fuse.parent_fd && ParsedNameEquals(begin, end, pd->name)) {
          assert(pd->path_num == 4*i+j);
          return pd;
        }
      }
      addr += 64;
    }
  }
  return NULL;
}

#if 0
void* FindDaemonOrClientByPathDesc(word base, struct PathDesc* pathdesc) {
  for (byte i = 0; i < 64; i++) {
    byte page = ((byte*)base)[i];
    if (!page) continue;
    word addr = (word)page << 8;
    for (byte j = 0; j<4; j++) {
      if (i!=0 || j!=0) {
        // Either Daemon or Client will do.
        struct Daemon* d = (struct Daemon*)addr;
        if (d->d_id!=0 && d->d_pathdesc == pathdesc) {
          assert(d->d_id == 4*i+j);
          return d;
        }
      }
      addr += 64;
    }
  }
  return NULL;
}
#endif

error DaemonOpen(
    struct PathDesc* pd,
    word begin2,
    word end2) {
  // Must not already be a daemon on this name.
  struct PathDesc *already = FindDaemon(pd->device_table_entry, begin2, end2);
  if (already) return E_SHARE;

  assert(pd);
  pd->fuse.fuse_state = D_IDLE;
  pd->fuse.char_hack = 'A';
  pd->fuse.parent_fd = NULL;
  pd->fuse.num_child = 0;
  pd->fuse.current_client = NULL;

  return OKAY;
}

error ClientOpen(
    struct PathDesc* pd,
    char* begin1,
    char* end1,
    char* begin2,
    char* end2) {
  // Client (child) must already have Daemon (parent).
  struct PathDesc *parent = FindDaemon(pd->device_table_entry, begin2, end2);
  if (!parent) return E_NES;  // non-existing segment.

  ++ parent->fuse.num_child;
  pd->fuse.fuse_state = C_IDLE;
  pd->fuse.char_hack = 'A';
  pd->fuse.parent_fd = parent;
  pd->fuse.num_child = 0;
  pd->fuse.current_client = NULL;

  return OKAY;
}

////////////////////////////////////////////////

error CreateOrOpenC(struct PathDesc* pd, struct Regs* regs) {
  pd->regs = regs;
  pd->current_process_id = Os9CurrentProcessId();
#if 1
  ShowStr("\rCreateOrOpen: ");
  ShowChar('P'); ShowHex(pd);
  // ShowRam((word)pd);
  // ShowRam(32+(word)pd);
  ShowRegs(regs);
  ShowPathDesc(pd);
#endif

  pd->fuse.char_hack = 'A';
  pd->fuse.fuse_state = 0;

  char *begin1=NULL, *end1=NULL, *begin2=NULL, *end2=NULL;
  byte i = 0;
  for (; i<64; i++) {
    char *begin = NULL, *end = NULL;

    char* current = (char*) regs->rx;
    error err = Os9PrsNam(current, &begin, &end);
    regs->rx = end;
    if (err) break;

    ShowStr("\rPrsNamLoop: ");
    ShowChar('@');
    ShowHex(err);
    ShowParsedName(current, begin, end);
    ShowStr("\r");

    switch (i) {
      case 0:
        break; // ignore "FUSE".
      case 1:
        begin1 = begin;
        end1 = end;
        break;
      case 2:
        // TODO:  more than one name.
        begin2 = begin;
        end2 = end;
        break;
      default:
        {}// Ignore extra names for now.
    }
  }
  ShowStr("\r i= ");
  ShowHex(i);
  ShowChar(13);
  if (i==3 && ParsedNameEquals(begin1, end1, "DAEMON")) {
    return DaemonOpen(pd, begin2, end2);
  } else if (i > 1) {
    return ClientOpen(pd, begin1, end1, begin2, end2);
  } else {
    assert(0);
    return E_BNAM;
  }
}

error CloseC(struct PathDesc* pd, struct Regs* regs) {
  pd->regs = regs;
  pd->current_process_id = Os9CurrentProcessId();

  if (pd->fuse.parent_fd) {
    -- pd->fuse.parent_fd->fuse.num_child;
  }
  bzero((void*)(&pd->fuse), sizeof(pd->fuse));
  bzero(pd->name, sizeof(pd->name));
  return OKAY;
}

error ClientReadLn(
              struct PathDesc* pd, struct Regs* regs) {
  return 23;
}

error DaemonReadLn(
              struct PathDesc* pd, struct Regs* regs) {
#if 1
  ShowStr(" ReadLn ");
  if (pd->fuse.char_hack >= 'G') {
    ShowStr("*EOF*");
    regs->ry = 0;  // count
    return E_EOF;
  } else {
    // ShowChar('R');
    // ShowHex(pd->fuse.char_hack);
    pd->fuse.char_hack ++;
    regs->ry = 2;  // count
    byte task = Os9CurrentProcessTask();
    Os9StoreByteToTask(task, regs->rx, pd->fuse.char_hack);
    Os9StoreByteToTask(task, regs->rx + 1, 13/*CR*/);
  }
#endif
  return OKAY;
}

error ReadLnC(struct PathDesc* pd, struct Regs* regs) {
  pd->regs = regs;
  pd->current_process_id = Os9CurrentProcessId();
 
  if (pd->fuse.parent_fd) {
    return ClientReadLn(pd, regs);
  } else {
    return DaemonReadLn(pd, regs);
  }
}

error WritLnC(struct PathDesc* pd, struct Regs* regs) {
  pd->regs = regs;
  pd->current_process_id = Os9CurrentProcessId();
  return 20;
}

error ReadC(struct PathDesc* pd, struct Regs* regs) {
  pd->regs = regs;
  pd->current_process_id = Os9CurrentProcessId();
  // Read same as ReadLn.
  return ReadLnC(pd, regs);
}

error WriteC(struct PathDesc* pd, struct Regs* regs) {
  pd->regs = regs;
  pd->current_process_id = Os9CurrentProcessId();
  return 19;
}

error GetStatC(struct PathDesc* pd, struct Regs* regs) {
  pd->regs = regs;
  pd->current_process_id = Os9CurrentProcessId();
  switch (regs->rb) {
    case 1: { // SS.READY
      // On devices that support it, the B register
      // will return the number of characters
      // that are ready to be read.
      // -- Inside Os9 Level II p 5-3-4
      regs->rb = 255;  // always be ready.
    }
    break;
    case 6: { // SS.EOF
        regs->rx = 0;  // MSW of file size: unknown.
        regs->ru = 0;  // LSW of file size: unknown.
        if (pd->fuse.char_hack >= 'G') {
          return E_EOF;
        }
    }
    break;
    default: {
      return 17;
    }
  }
  return 0;
}

error SetStatC(struct PathDesc* pd, struct Regs* regs) {
  pd->regs = regs;
  pd->current_process_id = Os9CurrentProcessId();
  return 18;
}

/////////////// Assembly-to-C Relays

asm CreateOrOpenA() {
  asm {
    DAA      ; Entering CreateOrOpenA
    PSHS Y,U ; push pathdesc & regs as args to the "C" function.
    LDU #0   ; begin C frames
    LDD #0
    LDX #0
    LDY #0   ; unneccesary cleanliness
    BSR _CreateOrOpenC  ; Call C function to do the work.

    // Shared by all `asm ...A()` functions:
FinishUp
    CLRA     ; clear the carry bit.
    TSTB     ; we want to set carry if B nonzero.
    BEQ SkipComA  ; skip the COMA, which sets the carry bit.
    COMA
SkipComA
    PULS PC,U,Y
  }
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