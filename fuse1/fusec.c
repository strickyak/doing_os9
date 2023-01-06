typedef unsigned char bool;
typedef unsigned char byte;
typedef unsigned char errnum;
typedef unsigned int word;

#include "os9.h"
#include "os9errno.h"
#include "fuse2.h"

#define OKAY 0
#define TRUE 1
#define FALSE 0
#define NULL ((void*)0)

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
  // Pre-Defined: 6 bytes.
  byte v_page;  // extended port addr
  word v_port;  // base port addr // REUSE FOR ALL64 BASE ADDR
  byte v_lprc;  // Last Active Process Id (not used?)
  byte v_busy;  // Active process ID (0 == not busy)
  byte v_wake;  // Process ID to wake after command completed

  // Specific to Fuse:
  word base_of_ram64;

  // Actually a full page of 256 bytes will be alloc'ed.
  // So feel free to add more fields here.
};

struct Regs {
  byte rcc, ra, rb, rdp;
  word rx, ry, ru, rpc;
};  // size 12
#define REGS_D(regs) (*(word*)(&(regs)->ra))

enum FuseState {
  FS_NONE,
  FS_DAEMON_LISTENING,
  FS_DAEMON_WORKING,
  FS_CLIENT,
  FS_CLIENT_WAITING,
};

struct PathDesc {
  byte path_num;              // PD.PD = 0
  byte mode;                  // PD.MOD = 1
  byte open_count;            // PD.CNT = 2
  struct DeviceTableEntry*
        device_table_entry;   // PD.DEV = 3
  byte current_process_id;    // PD.CPR = 5
  struct Regs *regs;          // PD.RGS = 6
  word unused_buffer_addr;    // PD.BUF = 8
  // offset 10 = PD.FST
  bool is_daemon;  // 10
  bool paused_proc_id;  // 11: 0 if not paused.
  word buf_start;  // 12
  word buf_len;    // 14
  byte buf_task;   // 16
  byte operation;  // 17
  byte result;  // 18
  struct PathDesc* peer;  // 19: Daemon's client or Client's daemon.
  struct Regs* client_regs; // 21
  // 23
};
#define DAEMON_NAME_OFFSET_IN_PD 50 // bytes 50 to 63
#define DAEMON_NAME_MAX 12

/////////////////  Hypervisor Debugging Support

asm HyperCoreDump() {
  asm {
    SWI
    FCB 100  ; hyperCoreDump
  }
}

void HyperShowRegs() {
  asm {
      swi
      fcb 109
  }
}

void HyperShowMMU() {
  asm {
      swi
      fcb 102
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

void ShowStr(const char* str) {
  asm {
    ldd str
      swi
      fcb 110
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

void PrintH(const char* format, ...) {
  asm {
      swi
      fcb 108
  }
}

#define assert(C) { if (!(C)) { PrintH(" *ASSERT* %s:%d *FAILED* (%s)\n", __FILE__,  __LINE__, #C); HyperCoreDump(); } }
#define BOMB() assert(!"BOMB")

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

word Os9CurrentProcAddr() {
  word addr = 0;
  asm {
    LDX <D.Proc
    STX addr
  }
  return addr;
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

errnum Os9LoadByteFromTask(byte task, word addr, byte* out) {
  errnum err;
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

errnum Os9StoreByteToTask(byte task, word addr, byte in) {
  errnum err;
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

errnum Os9Move(word count, word src, byte srcMap, word dest, byte destMap) {
  errnum err;
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

errnum Os9Send(byte to_pid, byte signal) {
  PrintH(" Send from=%x to=%x signal=%x\n", Os9CurrentProcessId(), to_pid, signal);
  errnum err;
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
  PrintH(" Sent...err=%x\n", err);
  return err;
}
errnum Awaken(struct PathDesc* pd) {
  byte to_pid = pd->paused_proc_id;
  assert(to_pid > 0); // TODO: no need to wake, if 0.
  return Os9Send(to_pid, 1);  // Wakeup Signal.
}

errnum Os9Sleep(word num_ticks) {
  PrintH("Sleep(pid=%x,n=%x)\n", Os9CurrentProcessId(), num_ticks);

  errnum err;
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
  PrintH("UnSleep(pid=%x,n=%x) =>err=%x\n", Os9CurrentProcessId(), num_ticks, err);
  return err;
}

void Os9Pause(struct PathDesc* pd) {
  PrintH(" Pausing path=%x\n", pd->path_num);
  pd->paused_proc_id = Os9CurrentProcessId();
  PrintH(" paused_proc_id=%x current_process_id=%x\n", 
                 pd->paused_proc_id ,  pd->current_process_id);
  //XXX// assert(pd->paused_proc_id == pd->current_process_id);
  Os9Sleep(0);  // until signalled.
  pd->paused_proc_id = 0;
  PrintH(" Un-Paused path=%x\n", pd->path_num);
}

// 64-byte block routines.
errnum Os9All64(word base, word* base_out, word* block_addr, byte* block_num) {
    errnum err = OKAY;
    asm {
        pshs y,u
        ldx base

        swi2
        fcb F_ALL64
        bcs ALL64BAD

        stx [base_out]
        sty [block_addr]
        sta [block_num]
        bra ALL64OK

ALL64BAD
        stb err
ALL64OK
        puls y,u
    }
    return err;
}

errnum Os9Find64(byte block_num, word base, word* block_addr) {
    errnum err = OKAY;
    asm {
        pshs y,u
        lda block_num
        ldx base

        swi2
        fcb F_FIND64
        bcs FIND64BAD

        sty [block_addr]
        bra FIND64OK

FIND64BAD
        stb err
FIND64OK
        puls y,u
    }
    return err;
}

errnum Os9Ret64(byte block_num, word base) {
    errnum err = OKAY;
    asm {
        pshs y,u
        lda block_num
        ldx base

        swi2
        fcb F_RET64
        bcc RET64OK

        stb err
RET64OK
        puls y,u
    }
    return err;
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

errnum Os9PrsNam(word ptr, word* eow_out, word*next_name_out) {
  errnum err;
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

word GetHex(word *pp) {
  byte task = Os9CurrentProcessTask();

  // skip white space.
  while (1) {
    byte b;
    errnum err = Os9LoadByteFromTask(task, *pp, &b);
    assert(!err);
    if (b > ' ') break;
    ++(*pp);
  }
  // accumulate result in z.
  word z = 0;
  while (1) {
    byte b;
    errnum err = Os9LoadByteFromTask(task, *pp, &b);
    assert(!err);
    ++(*pp);

    if ('0' <= b && b <= '9') {
      z = (z << 4) + (b - '0');
    } else if ('A' <= b && b <= 'Z') {
      z = (z << 4) + (b - 'A' + 10);
    } else if ('a' <= b && b <= 'z') {
      z = (z << 4) + (b - 'a' + 10);
    } else {
      return z;
    }
  }
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

errnum CopyParsedName(word begin, word end, char* dest, word max_len) {
  // max_len counts null termination.
  assert (end-begin < max_len-1);
  byte task = Os9CurrentProcessTask();
  byte i = 0;
  for (word p = begin; p < end; p++) {
    byte ch = 0;
    errnum err = Os9LoadByteFromTask(task, p, &ch);
    if (err) return err;
    *dest++ = ToUpper(ch);
  }
  *dest = 0; // terminate
  return OKAY;
}

void ShowParsedName(word current, word begin, word end) {
  byte task = Os9CurrentProcessTask();
  ShowChar('{');
  for (word p = current; p <= end; p++ ) {
    byte ch = 0;
    errnum err = Os9LoadByteFromTask(task, p, &ch);
    assert(!err);
    if (p == begin) ShowChar('~');
    if (p == end) ShowChar('~');
    if (p != end) ShowChar(ch);
  }
  ShowChar('}');
}

// Ignoring case is assumed, when Parsed Name is used.
// The string from begin to end is in the current
// process's task, and may contain high bits.
// The other string s is an upper-case 0-terminated
// C string, in normal memory, with no high bits.
bool ParsedNameEquals(word begin, word end, const char*s) {
  PrintH("\nParsedNameEquals(b=%x, e=%x, s=%x)\n", begin, end, s);
  byte task = Os9CurrentProcessTask();
  word p = begin;
  for (; *s && p < end; p++, s++) {
    byte ch = 0;
    errnum err = Os9LoadByteFromTask(task, p, &ch);
    assert(!err);
    ShowChar(ch); ShowChar(*s); ShowChar('`');

    if (ToUpper(ch) != *s) {
      ShowChar('^');
      return FALSE;  // does not match.
    }
  }

  // If both termination conditions are true,
  // strings are equal.
  ShowChar( (p==end) ? 'T' : 'F' );
  ShowChar( ((*s)==0) ? 'T' : 'F' );
  return (p==end) && ((*s)==0);
}

// FindDaemon traverses all path descriptors looking for
// one that is (1) open (path_num is set),
// (2) has the given device_table_entry (it is a /fuse),
// (3) is a daemon path (the parent_pd is null),
// (4) has the name indicated by begin/end.
struct PathDesc* FindDaemon(struct DeviceTableEntry* dte, word begin, word end) {
  struct PathDesc* got = NULL;
  byte* table = Os9PathDescBaseTable();
  for (byte i = 0; i < 64; i++) {  // how big can it get?
    byte page = table[i];
    if (!page) continue;
    word addr = (word)page << 8;
    for (byte j = 0; j<4; j++) {
      if (i!=0 || j!=0) {
        struct PathDesc* pd = (struct PathDesc*)addr;
        if (pd->path_num && pd->device_table_entry == dte) {
          assert(pd->path_num == 4*i+j);

          if (pd->is_daemon) {
            if (ParsedNameEquals(begin, end, (char*)pd + DAEMON_NAME_OFFSET_IN_PD)) {
              got = pd; // return pd;
              goto GOT_IT;
            }
          }
        }
      }
      addr += 64;
    }
  }

GOT_IT:
  PrintH("FindDaemon => got\n");
  return got; // NULL;
}

#if 0
byte HiNyb(byte x) { return x>>4; }
byte LoNyb(byte x) { return 15 & x; }
byte HiByt(word x) { return *(byte*)&x; }
byte LoByt(word x) { return (byte)x; }
#endif

///////////  DAEMON  ///////////////////////////

errnum OpenDaemon(struct PathDesc* pd, word begin2, word end2) {
  PrintH("OpenDeamon pd=%x entry\n", pd);

  // Must not already be a daemon on this name.
  struct PathDesc *already = FindDaemon(pd->device_table_entry, begin2, end2);
  if (already) {
    PrintH("\nBAD: OpenDeamon already open => err %x\n", E_SHARE);
    return E_SHARE;
  }

  pd->is_daemon = 1;
  pd->peer = NULL;

  CopyParsedName(begin2, end2, (char*)pd + DAEMON_NAME_OFFSET_IN_PD, DAEMON_NAME_MAX);

  PrintH("OpenDaemon OK: pd=%x %q\n", pd, (char*)pd + DAEMON_NAME_OFFSET_IN_PD);
  return OKAY;
}

// The Daemon process has called Read to get the next operation
// being called by a Client process.
errnum DaemonReadC(struct PathDesc* dae) {
  assert(dae);
  errnum err = OKAY;
  struct Regs* regs = dae->regs;

  // PAUSE FOR REQUEST FROM CLIENT.
  dae->paused_proc_id = Os9CurrentProcessId();
  PrintH("DaemonReadC: Pausing.\n");
  Os9Sleep(0);
  PrintH("DaemonReadC: UnPaused.\n");
  dae->paused_proc_id = 0;

  struct PathDesc* cli = dae->peer;
  assert(cli);

  // Assemble the Request object for the deamon process
  // using the operation requested by the client.
  struct Fuse2Request req;
  req.operation = cli->operation;
  req.path_num = cli->path_num;
  req.a_reg = cli->regs->ra;
  req.b_reg = cli->regs->rb;
  req.size = cli->buf_len;
  char* req_header = (char*)&req;

  // Store the Request object in the Daemon's memory buffer
  // one byte at a time.
  for (byte i = 0; i < sizeof req; i++) {
    err = Os9StoreByteToTask(
        dae->buf_task, dae->regs->rx + i, req_header[i]);
    assert(!err);
  }

  switch (req.operation) {
    case OP_READ:
    case OP_READLN:
      {
        assert(cli->buf_start);
        assert(cli->buf_len);
        // The number of bytes the Daemon will read is just
        // the size of the request headaer.
        regs->ry = sizeof req;
      }
      break;
    case OP_WRITE:
    case OP_WRITLN:
      {
        assert(cli->buf_start);
        assert(cli->buf_len);
        // Copy this payload from the client's buffer
        // into the Daemon's buffer, after the header.
        err = Os9Move(req.size,
            cli->buf_start, cli->buf_task,
            dae->buf_start + sizeof(req), dae->buf_task);
        assert(!err);
        // The number of bytes the Daemon will read is
        // the size of the request header plus the size
        // of the payload we just copied.
        regs->ry = req.size + sizeof req;
        err = 55;
      }
      break;
  }

  cli->result = OKAY; // XXX but we don't awaken Client
                      // until Daemon writes.
  return err;
}

// The Daemon process has called Write to return the results
// of the operation called by the Client process.
errnum DaemonWriteC(struct PathDesc* dae) {
  PrintH("DaemonWriteC: dae=%x ", dae);
  assert(dae);
  assert(((unsigned)dae & 63) == 0);
  assert(dae->is_daemon);
  struct PathDesc* cli = dae->peer;
  PrintH(":: cli=%x ", cli);
  PrintH(":: cli->peer=%x\n", cli->peer);
  assert(cli);
  assert(((unsigned)cli & 63) == 0);
  assert(!cli->is_daemon);
  assert(cli->peer == dae);
  PrintH("cli->buf: start=%x len=%x task=%x\n", cli->buf_start, cli->buf_len, cli->buf_task);

  errnum err = OKAY;
  struct Regs* regs = dae->regs;
  // We should still have a client
  assert(cli);
  // And it should be asleep.
  assert(cli->paused_proc_id);
  // TODO: check a sequence number between cli & dae,
  // to make sure neither has died and been recycled,
  // or else poison the device.

  struct Fuse2Reply reply;
  char* reply_header = (char*)&reply;

  for (byte i = 0; i < sizeof reply; i++) {
    byte x;
    err = Os9LoadByteFromTask(
        dae->buf_task, dae->regs->rx + i, &x);
    assert(!err);
    reply_header[i] = x;
  }

  // Client will pick up cli->result and
  // set its own B & CC regs, if nonzero.
  cli->result = reply.status;

  switch (cli->operation) {
      case OP_CREATE:
      case OP_OPEN:
        // IOMAN will set cli->regs->ra to local path num?
        break;
      case OP_CLOSE:
        // Nothing extra to do.
        break;
      case OP_WRITE:
        BOMB();
        break;
      case OP_READ:
      case OP_READLN:
        {
          ShowTaskRam(dae->buf_task, dae->regs->rx);
          cli->regs->ry = reply.size;
          errnum e = Os9Move(reply.size,
              // From the Daemon
              dae->regs->rx + sizeof(reply), dae->buf_task,
              // To the Client
              cli->buf_start, cli->buf_task);
          assert(!e);
          ShowTaskRam(cli->buf_task, cli->buf_start);
        }
        break;
      case OP_WRITLN:
        BOMB();
        break;
      default:
        PrintH("DeamonWriteC: Bad operation: %d", cli->operation);
        BOMB();
  } // switch

  // Allow other clients to use the daemon.
  // But the client still remembers its daemon.
  dae->peer = 0;
  // Time for the client to wake up.
  Awaken(cli);

  return OKAY;
}

/////////// CLIENT ////////////////////////

errnum OpenClient(
    struct PathDesc* cli,
    word begin1,
    word end1,
    word begin2,
    word end2,
    word original_rx) {
  word proc_addr = Os9CurrentProcAddr();
  PrintH("OpenClient proc_addr=%x ", proc_addr);
  ShowRam(proc_addr);

  PrintH("OpenClient cli=%x entry", cli);
  // Daemon must already be open.
  struct PathDesc *dae = FindDaemon(cli->device_table_entry, begin1, end1);
  if (!dae) {
    PrintH("BAD: daemon not open yet => err %x", E_SHARE);
    return E_SHARE;
  }
  assert(dae->is_daemon);

  cli->is_daemon = 0;
  cli->peer = dae;
  assert(dae->peer == 0);
  dae->peer = cli;

  cli->operation = OP_OPEN;
  cli->buf_start = original_rx;
  cli->buf_len = cli->regs->rx - original_rx;
  // cli->buf_task = Os9CurrentProcessTask();
  assert( cli->buf_task == Os9CurrentProcessTask() );

  // Awaken the Daemon, and go to sleep.
  assert(dae->paused_proc_id);
  Awaken(dae);
  Os9Pause(cli);
  // When we wake up, our regs should be modified
  // by the Daemon if necessary, and our result status.
  return cli->result;
}

errnum ClientOperationC(struct PathDesc* cli, byte op) {
  word proc_addr = Os9CurrentProcAddr();
  PrintH("ClientOperationC proc_addr=%x ", proc_addr);
  ShowRam(proc_addr);

  assert(cli);
  assert(((word)cli & 63) == 0);
  struct PathDesc* dae = cli->peer;
  PrintH("ClientOperationC op=%x cli=%x dae=%x entry\n", op, cli, dae);
  assert(dae);
  assert(((word)dae & 63) == 0);
  assert(dae->is_daemon);
  assert(!cli->is_daemon);

  cli->peer = dae;
  assert(dae->peer == 0);
  dae->peer = cli;

  cli->operation = op;

  PrintH("ClientOperationC cli->buf_task=%x currentTask=%x\n", 
     cli->buf_task , Os9CurrentProcessTask());
  assert( cli->buf_task == Os9CurrentProcessTask() );

  switch (op) {
    case OP_READ:
    case OP_READLN:
    case OP_WRITE:
    case OP_WRITLN:
      cli->buf_start = cli->regs->rx;
      cli->buf_len = cli->regs->ry;
      break;
    default:
      cli->buf_start = 0;
      cli->buf_len = 0;
      break;
  }

  // Awaken the Daemon, and go to sleep.
  while (dae->paused_proc_id == 0) {
    PrintH("Client sleeps 1, waiting on dae->paused_proc_id\n");
    Os9Sleep(1); // Wait for Daemon to call Read() again.
  }
  assert(dae->paused_proc_id);
  Awaken(dae);
  Os9Pause(cli);
  // When we wake up, our regs should be modified
  // by the Daemon if necessary, and our result status.
  return cli->result;
}

////////////////////////////////////////////////

errnum CreateOrOpenC(struct PathDesc* pd, struct Regs* regs) {
  word proc_addr = Os9CurrentProcAddr();
  PrintH("CreateOrOpenC proc_addr=%x ", proc_addr);
  ShowRam(proc_addr);

  pd->regs = regs;
  word original_rx = regs->rx;

  pd->current_process_id = Os9CurrentProcessId();
  pd->buf_start = 0;
  pd->buf_len = 0;
  pd->buf_task = Os9CurrentProcessTask();
  PrintH("CreateOrOpenC: pd=%x regs=%x proc=%x task=%x\n",
      pd, regs, pd->current_process_id, pd->buf_task);

  // Split the path to find 2nd (begin1/end1) and
  // 3rd (begin2/end2) words.  Ignore the 1st ("FUSE").
  //X char *begin1=NULL, *end1=NULL, *begin2=NULL, *end2=NULL;
  word begin1=0, end1=0, begin2=0, end2=0;
  byte i = 0;
  errnum err = OKAY;
  for (; i<99; i++) {
    word begin = 0, end = 0;
    word current = regs->rx;
    err = Os9PrsNam(current, &begin, &end);
    regs->rx = end; // important to update rx
    if (err) break;

    PrintH("Parse[%d]: begin=%x end=%x ", i, begin, end);
    ShowParsedName(current, begin, end);
    PrintH("\n");

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
        pd->buf_start = begin2;
        pd->buf_len = (end2 - begin2);
        break;
      default:
        {}// Ignore extra names for now.
    }
  }

  if (i==3 && ParsedNameEquals(begin1, end1, "DAEMON")) {
    return OpenDaemon(pd, begin2, end2);
  } else if (i > 1) {
    return OpenClient(pd, begin1, end1, begin2, end2, original_rx);
  } else {
    PrintH("\nFATAL: CreateOrOpenC: BAD NAME\n");
    BOMB();
    return E_BNAM;
  }
}

errnum CloseC(struct PathDesc* pd, struct Regs* regs) {
  pd->regs = regs;
  if (pd->is_daemon) {
    return 10;
  } else {
    return ClientOperationC(pd, OP_CLOSE);
  }
}

errnum ReadLnC(struct PathDesc* pd, struct Regs* regs) {
  pd->regs = regs;
  if (pd->is_daemon) {
    return E_BMODE;  // Daemon must use Read not ReadLn.
  } else {
    return ClientOperationC(pd, OP_READLN);
  }
}

errnum WritLnC(struct PathDesc* pd, struct Regs* regs) {
  pd->regs = regs;
  if (pd->is_daemon) {
    return E_BMODE; // Daemon must use Write not WritLn.
  } else {
    return ClientOperationC(pd, OP_WRITLN);
  }
}

errnum ReadC(struct PathDesc* pd, struct Regs* regs) {
  pd->regs = regs;
  if (pd->is_daemon) {
    return DaemonReadC(pd);
  } else {
    return ClientOperationC(pd, OP_READ);
  }
}

errnum WriteC(struct PathDesc* pd, struct Regs* regs) {
  pd->regs = regs;
  if (pd->is_daemon) {
    return DaemonWriteC(pd);
  } else {
    return ClientOperationC(pd, OP_WRITE);
  }
}

errnum GetStatC(struct PathDesc* pd, struct Regs* regs) {
  pd->regs = regs;
  return 14;
}

errnum SetStatC(struct PathDesc* pd, struct Regs* regs) {
  pd->regs = regs;
  return 15;
}

/////////////// Assembly-to-C Relays

asm CreateOrOpenA() {
  asm {
    PSHS Y,U ; push pathdesc & regs as args to the "C" function.
    LDU #0   ; begin C frames
    LDD #0
    LDX #0
    LDY #0   ; unneccesary cleanliness
    BSR _CreateOrOpenC  ; Call C function to do the work.

; Shared by all `asm ...A()` functions:
; Returning from the XxxxC() routines,
; the status is in the B register.
BackToAssembly
    CLRA     ; clear the carry bit.
    TSTB     ; we want to set carry if B nonzero.
    BEQ SkipComA  ; skip the COMA
    COMA     ; sets the carry bit.
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
    LBRA BackToAssembly
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
    LBRA BackToAssembly
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
    LBRA BackToAssembly
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
    LBRA BackToAssembly
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
    LBRA BackToAssembly
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
    LBRA BackToAssembly
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
    LBRA BackToAssembly
  }
}
