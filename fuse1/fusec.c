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
  D_GOT_WORK = 3,     // ReadLn returned a Clop.

  C_POISON = 11,  // daemon death poisons its clients.
  C_IDLE = 12,   // no client stuff pending.
  C_REQUESTING = 13,
  C_REQUESTED = 13,
  C_RESULT = 14,
};

enum ClientOp {
  OP_NONE = 0,     // no operation requested.
  OP_PENDING = 1,  // Daemon is working on it.
  OP_STATUS = 2,   // Daemon set a result status.
  OP_CREATE = 'c',
  OP_OPEN = 'o',
  OP_CLOSE = 'C',
  OP_READLN = 'R',
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
};

struct Regs {
  byte rcc, ra, rb, rdp;
  word rx, ry, ru, rpc;
};  // size 12
struct ShortRegs {
  byte rcc, ra, rb, rdp;
  word rx, ry, ru;  // omit rpc, saves 2 bytes.
};  // size 10
#define REGS_D(regs) (*(word*)(&(regs)->ra))

struct Fuse { // embeds in PathDesc
  byte state;
  bool paused;
  struct PathDesc* parent_pd;  // NULL for daemon,  daemon for client.
  byte num_child;  // how many open clients a daemon has.
  byte current_task;
  struct PathDesc* current_client;
  byte cl_op;     // from client
  error d_status;  // from daemon
  struct ShortRegs cl_regs;
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

void ShowTaskRam(byte task, word addr) {
  asm {
    ldb task
    ldx addr
      swi
      fcb 106
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
    LDD <D.PthDBT
    STD base
  }
  return base;
}

byte Os9CurrentProcessId() {
  byte id = 0;
  asm {
    LDX <D.Proc
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
#if 1
  ShowStr("\r@@@@ SEND pid=");
  ShowHex(Os9CurrentProcessId());
  ShowHex(to_pid);
  ShowHex(signal);
  ShowStr("\r");
#endif
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
error Os9Wake(byte to_pid) {
  return Os9Send(to_pid, 1);
}

error Os9Sleep(word num_ticks) {
#if 1
  ShowStr("\r@@@@ SLEEP pid=");
  ShowHex(Os9CurrentProcessId());
  ShowStr("\r");
#endif

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
#if 1
  ShowStr("\r@@@@ AWAKE pid=");
  ShowHex(Os9CurrentProcessId());
  ShowStr("\r");
#endif
  return err;
}

void Os9Pause(struct PathDesc* pd) {
  ShowStr("\rPAUSING ");
  ShowHex(pd->current_process_id);
  ShowStr("\r");
  pd->fuse.paused = TRUE;
  Os9Sleep(0);  // until signalled.
  pd->fuse.paused = FALSE;
  ShowStr("\rFINISHED PAUSE ");
  ShowHex(pd->current_process_id);
  ShowStr("\r");
}

void memcpy(char* dest, const char* src, word len) {
  asm {
    pshs d,x,y,u
  }
  for (byte i=0; i<(byte)len; i++) {
    dest[i] = src[i];
  }
  asm {
    puls d,x,y,u
  }
  return;
  asm {
memcpy bra _memcpy
  }
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
  ShowStr("@pd@"); ShowHex(pd); ShowChar(13);
  ShowStr("path_num"); ShowHex(pd->path_num); ShowChar(13);
  ShowStr("mode"); ShowHex(pd->mode); ShowChar(13);
  ShowStr("open_count"); ShowHex(pd->open_count); ShowChar(13);
  ShowStr("device_table_entry"); ShowHex(pd->device_table_entry); ShowChar(13);
  ShowStr("current_process_id"); ShowHex(pd->current_process_id); ShowChar(13);
  ShowStr("regs"); ShowHex(pd->regs); ShowChar(13);
  ShowStr("unused_buffer"); ShowHex(pd->unused_buffer); ShowChar(13);
  ShowStr("state"); ShowHex(pd->fuse.state); ShowChar(13);
  ShowStr("paused"); ShowHex(pd->fuse.paused); ShowChar(13);
  ShowStr("parent_pd"); ShowHex(pd->fuse.parent_pd); ShowChar(13);
  ShowStr("num_child"); ShowHex(pd->fuse.num_child); ShowChar(13);
  ShowStr("current_task"); ShowHex(pd->fuse.current_task); ShowChar(13);
  ShowStr("current_client"); ShowHex(pd->fuse.current_client); ShowChar(13);
  ShowStr("cl_op"); ShowHex(pd->fuse.cl_op); ShowChar(13);
  ShowStr("device_type"); ShowHex(pd->device_type); ShowChar(13);
  ShowRegs((struct Regs*) &pd->fuse.cl_regs);
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
  byte task = Os9CurrentProcessTask();
  //ShowStr(s);
  word p = begin;
  for (; *s && p < end; p++, s++) {
    byte ch = 0;
    error err = Os9LoadByteFromTask(task, p, &ch);
    assert(!err);
    //ShowHex(p); ShowHex(s);
    //ShowChar(ch); ShowChar(*s);

    if (ToUpper(ch) != *s) {
      //ShowChar('F');
      return FALSE;  // does not match.
    }
  }

  // If both termination conditions are true,
  // strings are equal.
  //ShowChar('R');
  //ShowHex( ((*s)==0) );
  //ShowHex( (p==end) );
      //ShowChar('R');
  //ShowHex( (p==end) && ((*s)==0) );
  //ShowChar(13);
  //ShowChar(13);
  return (p==end) && ((*s)==0);
}

// FindDaemon traverses all path descriptors looking for
// one that is (1) open (path_num is set),
// (2) has the given device_table_entry (it is a /fuse),
// (3) is a daemon path (the parent_pd is null),
// (4) has the name indicated by begin/end.
struct PathDesc* FindDaemon(struct DeviceTableEntry* dte, word begin, word end) {
  struct PathDesc* got = NULL;
  //ShowStr("\rFindDaemon: ");
  //ShowHex(end-begin);
  // ShowTaskRam(Os9CurrentProcessTask(), begin);
  //ShowStr(" ... table=");
  byte* table = Os9PathDescBaseTable();
  //ShowRam(table);
  //ShowStr(" ...\r");
  for (byte i = 0; i < 64; i++) {  // how big can it get?
    byte page = table[i];
    if (!page) continue;
    word addr = (word)page << 8;
    for (byte j = 0; j<4; j++) {
      if (i!=0 || j!=0) {
        struct PathDesc* pd = (struct PathDesc*)addr;
        //ShowStr("\rfd#"); ShowHex(4*i + j); ShowHex(pd);
          //ShowRam((word)pd);
          //ShowRam((word)pd+32);
        if (pd->path_num && pd->device_table_entry == dte) {
          //ShowStr("--dte--");

          if (!pd->fuse.parent_pd && ParsedNameEquals(begin, end, pd->name)) {
            //ShowStr("---YES---"); ShowHex(pd->path_num); ShowHex(pd);
            assert(pd->path_num == 4*i+j);
            got = pd; // return pd;
          } else {
            //ShowStr("---no---\n");
          }
        }
      }
      addr += 64;
    }
  }

  ShowStr(" FindDaemon -->> ");
  ShowHex(got);
  ShowStr("\r");
  return got; // NULL;
}

////////////////////////////////////////////////

byte Hex(byte x) {
  assert(x<16);
  if (x<10) return '0'+x;
  return 'A'+x-10;
}
byte HiNyb(byte x) { return x>>4; }
byte LoNyb(byte x) { return 15 & x; }
byte HiByt(word x) { return (byte)(x>>8); }
byte LoByt(word x) { return (byte)x; }

void SetDaemonState(struct PathDesc* pd, byte x) {
  ShowStr("\rSetDaemonState: ");
  ShowHex(pd->fuse.state);
  ShowStr(" -->> ");
  pd->fuse.state = x;
  ShowHex(pd->fuse.state);
  ShowStr("\r");
}
void SetClientState(struct PathDesc* pd, byte x) {
  ShowStr("\rSetClientState: ");
  ShowHex(pd->fuse.state);
  ShowStr(" -->> ");
  if (pd->fuse.state != C_POISON) pd->fuse.state = x;
  ShowHex(pd->fuse.state);
  ShowStr("\r");
}
void RecordResultInClient(struct PathDesc* cli,
    struct PathDesc* dae) {
  error err = OKAY;
  switch (cli->fuse.cl_op) {
    case OP_OPEN:
      // Exit: A=path_num; X=byte after pathlist
      cli->fuse.cl_regs.ra = cli->path_num;
      break;
    case OP_READLN: {
      // Enter: A=path_num X=addr Y=max_bytes
      // Exit: Y=bytes_read
        word addr = cli->fuse.cl_regs.rx;
        word max = cli->fuse.cl_regs.ry;
        for (word i = 0; i < max-1; i++) {
          Os9StoreByteToTask(cli->fuse.current_task, addr,
              i==0 ? 'A' : 'a');
          addr++;
        }
        Os9StoreByteToTask(cli->fuse.current_task, addr, 13);
      }
      break;
    case OP_CLOSE:
      break;
    default:
      break;
  }
  cli->fuse.d_status = err;
  cli->fuse.state = C_RESULT;
  Os9Wake(cli->current_process_id);
}
void RecordClientOpInClient(struct PathDesc* cli,
                          byte client_op) {
  // Assert we only call this from Client process.
  // Later we must figure out how to do it, if client ops before daemon readlns.
  assert(Os9CurrentProcessTask() == cli->fuse.current_task);

  cli->fuse.cl_op = client_op;
  // this breaks if not in Client process.
  cli->fuse.cl_regs = *(struct ShortRegs*)cli->regs;
}

void Add(byte ch, struct PathDesc* dae,
         word* ptr, word* remain) {
  if ((*remain) > 0) { --(*remain);
    ShowChar('#'); ShowChar('#'); ShowChar(ch);
    error e = Os9StoreByteToTask(
               dae->fuse.current_task, (*ptr)++, ch);
      assert(!e);
  }
}

void MarshalClientOpToDaemon(struct PathDesc* cli,
                          struct PathDesc* dae) {
  word ptr = dae->regs->rx;
  word remain = dae->regs->ry;

#define ADD(CHAR) Add((CHAR), dae, &ptr, &remain)

#define ADD_BYTE(B) { byte b = (B); ADD(Hex(HiNyb(b))); ADD(Hex(LoNyb(b))); ADD(' '); }

#define ADD_WORD(W) { word w = (W); ADD_BYTE(HiByt(w)); ADD_BYTE(LoByt(w)); ADD(' '); }

  ADD(cli->fuse.cl_op);
  ADD(' ');
  ADD_BYTE(cli->path_num);

  switch (cli->fuse.cl_op) {
    case OP_OPEN:
      {
      ADD_BYTE(cli->regs->ra);  // access mode

      word s = cli->regs->rx;  // pathname string.
      byte ch = 0;
      do {
        error e = Os9LoadByteFromTask(cli->fuse.current_task, s, &ch);
        assert(!e);
        if (!ch) break;
        ADD(ToUpper(ch));

      } while (ch>32 && ch<128);
  }
        break;
    case OP_CLOSE:
      break;
    case OP_READLN:
      break;
        ADD_WORD(cli->regs->ry);  // max bytes to read.
    default:
      ShowStr(" BILBO "); ShowHex(cli);
      ShowPathDesc(cli);
      ShowHex(cli->fuse.cl_op);
      assert(0);
  }
  ADD(13);  // Terminating CR.

  word bytes_used = dae->regs->ry - remain;
  dae->regs->ry = bytes_used;

  SetClientState(cli, C_REQUESTED);
  cli->fuse.cl_op = 0;
  // Os9Wake(cli->current_process_id); // wakeup
}

//////////////////////////////////////


error PerformClient(struct PathDesc* pd, byte op) {
  if (pd->fuse.state == C_POISON) return E_PRCABT;

  RecordClientOpInClient(pd, op);
  SetClientState(pd, C_REQUESTING);
  ShowStr(" NANDO0 "); ShowHex(op);

  do {
    ShowStr(" NANDO1 "); ShowHex(op);
    Os9Wake(pd->fuse.parent_pd->current_process_id);
    ShowStr(" NANDO2 "); ShowHex(op);
    Os9Pause(pd);
    ShowStr(" NANDO3 "); ShowHex(op);
  } while (pd->fuse.state == C_REQUESTING ||
           pd->fuse.state == C_REQUESTED);

  ShowStr(" NANDO4 "); ShowHex(op);

  if (pd->fuse.state == C_POISON) return E_PRCABT;
  assert(pd->fuse.state == C_RESULT);

  // Here we would consume the C_RESULT and change state to C_IDLE.

  SetClientState(pd, C_IDLE);
  return pd->fuse.d_status;  // status from daemon.
}

error OpenDaemon(
    struct PathDesc* pd,
    word begin2,
    word end2) {
  // Must not already be a daemon on this name.
  struct PathDesc *already = FindDaemon(pd->device_table_entry, begin2, end2);
  if (already) return E_SHARE;

  assert(pd);
  pd->fuse.state = D_IDLE;
  pd->fuse.parent_pd = NULL;
  pd->fuse.num_child = 0;
  pd->fuse.current_client = NULL;

  CopyParsedName(begin2, end2, pd->name, sizeof pd->name);

  return OKAY;
}

error OpenClient(
    struct PathDesc* pd,
    char* begin1,
    char* end1,
    char* begin2,
    char* end2) {
  SetClientState(pd, C_IDLE);
  pd->fuse.num_child = 0;
  pd->fuse.current_client = NULL;
  CopyParsedName(begin2, end2, pd->name, sizeof pd->name);

  // Client (child) must already have Daemon (parent).
  struct PathDesc *parent = FindDaemon(pd->device_table_entry, begin1, end1);
  if (!parent) return E_NES;  // non-existing segment.
  // Current Limitation: only one client per parent daemon.
  if (parent->fuse.current_client) return E_SHARE;

  parent->fuse.current_client = pd;
  pd->fuse.parent_pd = parent;
  ++ parent->fuse.num_child;

  return PerformClient(pd, OP_OPEN);
}

////////////////////////////////////////////////

error CreateOrOpenC(struct PathDesc* pd, struct Regs* regs) {
  pd->fuse.current_task = Os9CurrentProcessTask();
#if 1
  ShowStr("\rsizeof Fuse: "); ShowHex(sizeof(struct Fuse));
  ShowStr("\rCreateOrOpen: ");
  ShowChar('P'); ShowHex(pd);
  ShowRam((word)pd);
  ShowRam(32+(word)pd);
  ShowHex(regs);
  ShowRegs(regs);
  ShowPathDesc(pd);
#endif

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
    return OpenDaemon(pd, begin2, end2);
  } else if (i > 1) {
    return OpenClient(pd, begin1, end1, begin2, end2);
  } else {
    assert(0);
    return E_BNAM;
  }
}

error CloseC(struct PathDesc* pd, struct Regs* regs) {
  pd->fuse.current_task = Os9CurrentProcessTask();
  ShowStr("\r##### CLOSING: #####\r"); ShowHex(pd->path_num);
  // ShowRegs(regs);
  // ShowPathDesc(pd);

  error err = OKAY;
  if (pd->fuse.parent_pd) {
    -- pd->fuse.parent_pd->fuse.num_child;
    err = PerformClient(pd, OP_CLOSE);
  }
  if (pd->fuse.current_client) {
      SetClientState(pd->fuse.current_client, C_POISON);
  }

  //? bzero((void*)(&pd->fuse), sizeof(pd->fuse));
  //? bzero(pd->name, sizeof(pd->name));
  ShowStr("\r##### FINISH: CLOSED #####"); ShowHex(pd->path_num);
  ShowStr("\r");
  return err;
}

error ReadLnC(struct PathDesc* pd, struct Regs* regs) {
  ShowStr("\r##### READ LINE: #####"); ShowHex(pd->path_num);
  ShowStr("\r");
  ShowRegs(regs);
  ShowPathDesc(pd);
  pd->fuse.current_task = Os9CurrentProcessTask();
  error err = 0;

#define FINISH(E) { err=(E); goto Finish; }

  switch (pd->fuse.state) {
    case D_IDLE:
      // We want a client and a cl_op to do.
      while (!pd->fuse.current_client || pd->fuse.current_client->fuse.state != C_REQUESTING || !pd->fuse.current_client->fuse.cl_op ) {
        ShowStr("Because cc = "); ShowHex(pd->fuse.current_client);
        if (pd->fuse.current_client) {
          ShowStr("Because cl_op = "); ShowHex(pd->fuse.current_client->fuse.cl_op);
        }
        if (pd->fuse.current_client) Os9Wake(pd->fuse.current_client->current_process_id);
        Os9Pause(pd);
      }
      //+ SetDaemonState(pd, D_GOT_WORK);

      ShowChar('%'); ShowHex(pd->fuse.current_client->fuse.state);
      assert(pd->fuse.current_client->fuse.state == C_REQUESTING);
      SetClientState(pd->fuse.current_client, C_REQUESTED);
ShowStr(" Drequested ");

      MarshalClientOpToDaemon(pd->fuse.current_client, pd);
ShowStr(" Dmarshalled ");
      // Next should come from WriteLn:
      RecordResultInClient(pd->fuse.current_client, pd);
ShowStr(" Dfinish ");
      FINISH( OKAY);
    break;
    case D_GOT_WORK:
      FINISH( 24);
    break;
    case C_POISON:
      FINISH( 25);
    break;
    case C_IDLE:
      err = PerformClient(pd, OP_READLN);
      FINISH(err);
    break;
    case C_REQUESTED:
      FINISH( 27);
    break;
    default:
      FINISH( 28);
  }

Finish:
  ShowStr("\r##### FINISH: READ LINE ##### "); ShowHex(pd->path_num);
  ShowHex(err); ShowStr("\r");
  return err;
}

error WritLnC(struct PathDesc* pd, struct Regs* regs) {
  pd->fuse.current_task = Os9CurrentProcessTask();
  return 20;
}

error ReadC(struct PathDesc* pd, struct Regs* regs) {
  pd->fuse.current_task = Os9CurrentProcessTask();
  // Read same as ReadLn.
  return ReadLnC(pd, regs);
}

error WriteC(struct PathDesc* pd, struct Regs* regs) {
  pd->fuse.current_task = Os9CurrentProcessTask();
  return 19;
}

error GetStatC(struct PathDesc* pd, struct Regs* regs) {
  pd->fuse.current_task = Os9CurrentProcessTask();
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
    }
    break;
    default: {
      return 17;
    }
  }
  return OKAY;
}

error SetStatC(struct PathDesc* pd, struct Regs* regs) {
  pd->fuse.current_task = Os9CurrentProcessTask();
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
