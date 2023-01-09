// fusec.c -- FUSE file manager.
//
// Copyright 2023 Henry Strickland (strickyak).  MIT License.
//
// This is CMOC source for a Fuse File Manager for NitrOS9 Level II.
// This is a Work In Progress, but basic functionaly works as long as
// things are small (use well under 256 bytes per message) and one
// thing happens at a time.
//
// ( See https://en.wikipedia.org/wiki/Filesystem_in_Userspace )
//
// This compiles with CMOC to assembly, and is then included in fuseman.asm
// as the file _generated_from_fusec_.a
// There is also fuser.asm (the driver) and fuse.asm (the device descriptor).
//
// This won't do much alone.  You need one or more specially-writen daemons,
// which are user mode processes that function as back-end services to implement
// virtual devices for Fuse.  The clients use the normal OS9 I$... filesystem
// operations to communicate with Fuse.
//
// cf. https://en.wikipedia.org/wiki/Filesystem_in_Userspace

/*
   The MIT License (MIT)

Copyright (c) 2023 Henry Strickland

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

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
  word dt_device_driver_module;       // F$DRIV
  struct DeviceVars *dt_device_vars;  // F$STAT
  word dt_device_desc;                // F$DESC
  word dt_fileman;   // V$FMGR
  byte dt_num_users; // V$USRS
  word dt_drivex;    // V$DRIVX
  word dt_fmgrex;    // V$FMGREX
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
  byte link_count;            // PD.CNT = 2
  struct DeviceTableEntry*
        device_table_entry;   // PD.DEV = 3
  byte current_process_id;    // PD.CPR = 5
  struct Regs *regs;          // PD.RGS = 6
  word daemon_buffer;         // PD.BUF = 8
  // offset 10 = PD.FST
  bool is_daemon;  // 10
  bool paused_proc_id;  // 11: 0 if not paused.
  word buf_len;    // 12
  struct PathDesc* peer;  // 14: Daemon's client or Client's daemon.
  bool is_poisoned;  // 16
  // 17
}; // Must be 32 bytes or under in size.

#define DAEMON_NAME_OFFSET_IN_PD 33
#define DAEMON_NAME_MAX 28

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

asm void GameOver() {
  asm {
INF_LOOP bra INF_LOOP
  }
}

#define assert(C) { if (!(C)) { PrintH(" *ASSERT* %s:%d *FAILED*\n", __FILE__,  __LINE__); HyperCoreDump(); GameOver(); } }

#define XXX /**/

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

byte Os9UserTask() {
  byte task = 0;
  asm {
    LDX D.Proc
    LDA P$Task,X
    STA task
  }
  return task;
}

byte Os9SystemTask() {
  byte task = 0;
  asm {
    LDX D.SysPrc
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

void Os9AwakenIOQN(struct PathDesc* pd) {
  errnum err;
  byte to_pid;
  asm {
    PSHS Y,U       ; save frame

    ldx <D.Proc
    lda P$IOQN,x
    sta to_pid
    beq NoOneToWake

    ldb #1         ; Signal 1 is Wake Up
    os9 F$Send

NoOneToWake
    clra
    clrb
    PULS Y,U       ; restore frame
  }
  if (to_pid) {
    PrintH("Os9AwakenIOQN: Sent wakeup from=%x to=%x\n", Os9CurrentProcessId(), to_pid);
  } else {
    PrintH("Os9AwakenIOQN: Zero PD.CPR.");
  }
}

errnum Os9Awaken(struct PathDesc* pd) {
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

errnum Os9SRqMem(word size, word* size_out, word* addr_out) {
  errnum err = OKAY;
  asm {
      pshs y,u
      ldd size
      swi2
      fcb F_SRQMEM
      tfr u,x
      puls y,u
      bcs SRQMEM_BAD
      stx [addr_out]
      std [size_out]
      bra SRQMEM_OK

SRQMEM_BAD
        stb err
SRQMEM_OK
  }
  return err;
}

errnum Os9SRtMem(word size, word addr) {
  errnum err = OKAY;
  asm {
      ldd size
      ldx addr
      pshs y,u
      tfr x,u
      swi2
      puls y,u
      fcb F_SRTMEM
      bcc SRTMEM_OK

      stb err
SRTMEM_OK
  }
  return err;
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

////////////////////////////////////////////////

void MoveToKernel(struct PathDesc* dae, word addr, word size, word header_skip_size) {
  PrintH("MoveToKernel: addr=%x size=%x @@", addr, size);
  assert(dae);
  assert(dae->is_daemon);
  assert(addr);
  assert(size);
  errnum e = Os9Move(size, addr, Os9UserTask(), dae->daemon_buffer + header_skip_size, Os9SystemTask());
  assert(!e);
}

void MoveToUser(struct PathDesc* dae, word addr, word size, word header_skip_size) {
  PrintH("MoveToUser: addr=%x size=%x @@", addr, size);
  assert(dae);
  assert(dae->is_daemon);
  assert(addr);
  assert(size);
  errnum e = Os9Move(size, dae->daemon_buffer + header_skip_size, Os9SystemTask(), addr, Os9UserTask());
  assert(!e);
}

////////////////////////////////////////////////

errnum CopyParsedName(word begin, word end, char* dest, word max_len) {
  // max_len counts null termination.
  assert (end-begin < max_len-1);
  byte task = Os9UserTask();
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
  byte task = Os9UserTask();
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
  // PrintH("ParsedNameEquals(b=%x, e=%x, s=%x)\n", begin, end, s);
  byte task = Os9UserTask();
  word p = begin;
  for (; *s && p < end; p++, s++) {
    byte ch = 0;
    errnum err = Os9LoadByteFromTask(task, p, &ch);
    assert(!err);

    if (ToUpper(ch) != *s) {
      return FALSE;  // does not match.
    }
  }

  // If both termination conditions are true,
  // strings are equal.
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
  // PrintH("FindDaemon => NOT FOUND\n");
  return NULL;

GOT_IT:
  // PrintH("FindDaemon => got\n");
  return got; // NULL;
}

void SwitchProcess(struct PathDesc* from, struct PathDesc* to) {
  byte timeout = 50;
  while (to->paused_proc_id == 0) {
    PrintH("SwitchProcess: sleeping 1 tick: try %x", timeout);
    Os9Sleep(1);
    --timeout;
    assert(timeout > 0);
  }
  // Awaken the "to" process.
  Os9Awaken(to);
  // Now go to sleep.
  Os9Pause(from);
}

void CheckClient(struct PathDesc* cli) {
  assert(cli);
  assert(((word)cli & 63) == 0);
  assert(!cli->is_daemon);
}

void CheckDaemon(struct PathDesc* dae) {
  assert(dae);
  assert(((word)dae & 63) == 0);
  assert(dae->is_daemon);
}

void SetPeer(struct PathDesc* subject, struct PathDesc* object) {
  assert(subject->peer == 0);
  object->link_count++;
  subject->peer = object;
}

void CheckPeer(struct PathDesc* subject, struct PathDesc* object) {
  assert(subject->peer == object);
}

void ClearPeer(struct PathDesc* subject, struct PathDesc* object) {
  assert(subject->peer == object);
  object->link_count--;
  subject->peer = NULL;
}

///////////  DAEMON  ///////////////////////////

errnum OpenDaemon(struct PathDesc* dae, word begin2, word end2) {
  PrintH("OpenDeamon dae=%x entry\n", dae);

  // Must not already be a daemon on this name.
  struct PathDesc *already = FindDaemon(dae->device_table_entry, begin2, end2);
  if (already) {
    PrintH("\nBAD: OpenDeamon already open => err %x\n", E_SHARE);
    return E_SHARE;
  }

  dae->is_daemon = 1;
  dae->peer = NULL;
  dae->current_process_id = Os9CurrentProcessId();

  dae->daemon_buffer = 0;
  word size_out = 0;
  errnum err = Os9SRqMem(0x100, &size_out, &dae->daemon_buffer);
  assert(!err);

  CopyParsedName(begin2, end2, (char*)dae + DAEMON_NAME_OFFSET_IN_PD, DAEMON_NAME_MAX);

  PrintH("OpenDaemon OK: dae=%x %q\n", dae, (char*)dae + DAEMON_NAME_OFFSET_IN_PD);
  dae->current_process_id = 0; // PD.CPR: Nobody owns me.
  return OKAY;
}

// The Daemon process has called Read to get the next operation
// being called by a Client process.
errnum DaemonReadC(struct PathDesc* dae) {
  assert(dae);
  dae->current_process_id = Os9CurrentProcessId();
  errnum err = OKAY;

  // PAUSE FOR REQUEST FROM CLIENT.
  dae->paused_proc_id = Os9CurrentProcessId();
  PrintH("DaemonReadC: Pausing.\n");
  Os9Sleep(0);
  PrintH("DaemonReadC: UnPaused.\n");
  dae->paused_proc_id = 0;

  struct PathDesc* cli = dae->peer;
  CheckClient(cli);
  CheckPeer(cli, dae);

  struct Regs* regs = dae->regs;
  if (cli->buf_len) {
    MoveToUser(dae, regs->rx, cli->buf_len, 0);
  }
  regs->ry = cli->buf_len;

  dae->current_process_id = 0; // PD.CPR: Nobody owns me.
  PrintH("DaemonReadC returns");
  return err;
}

// The Daemon process has called Write to return the results
// of the operation called by the Client process.
errnum DaemonWriteC(struct PathDesc* dae) {
  PrintH("DaemonWriteC: dae=%x ", dae);
  CheckDaemon(dae);
  struct PathDesc* cli = dae->peer;
  CheckClient(cli);
  dae->current_process_id = Os9CurrentProcessId();

  errnum err = OKAY;
  // TODO: Poison on failure, and check for poison.
  // TODO: check a sequence number between cli & dae,
  // to make sure neither has died and been recycled,
  // or else poison the device.

  struct Regs* regs = dae->regs;
  MoveToKernel(dae, regs->rx, regs->ry, 0);
  dae->buf_len = regs->ry;

  // Allow other clients to use the daemon.
  // But the client still remembers its daemon.
  ClearPeer(dae, cli);
  dae->current_process_id = 0; // PD.CPR: Nobody owns me.

  // Time for the client to wake up.
  Os9Awaken(cli);
  Os9AwakenIOQN(cli);

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
  PrintH("OpenClient cli=%x entry", cli);
  cli->is_daemon = 0;
  cli->current_process_id = Os9CurrentProcessId();

  // Daemon must already be open.
  struct PathDesc *dae = FindDaemon(cli->device_table_entry, begin1, end1);
  if (!dae) {
    PrintH("BAD: daemon not open yet => err %x\n", E_SHARE);
    return E_SHARE;
  }
  assert(dae->is_daemon);

  SetPeer(cli, dae);  // Client links to Daemon.
  SetPeer(dae, cli);  // Daemon links to Client.

  struct Fuse2Request* request = (struct Fuse2Request*)(dae->daemon_buffer);
  char* payload = (char*)(request+1);

  request->operation = OP_OPEN; // TODO: distinguish OP_CREATE.
  request->path_num = cli->path_num;
  request->a_reg = cli->regs->ra;
  request->b_reg = cli->regs->rb;
  request->size = cli->regs->rx - original_rx;
  cli->buf_len = request->size + sizeof *request;

  assert(cli->buf_len <= 256);
  MoveToKernel(dae, original_rx, request->size, sizeof *request);

  ////////////////////////
  // Now we switch and let the daemon run.
  SwitchProcess(cli, dae);
  // When we return, the daemon has given us a reply.
  ////////////////////////

  // When we wake up, our regs should be modified
  // by the Daemon if necessary, and our result status.
  struct Fuse2Reply* reply = (struct Fuse2Reply*)(dae->daemon_buffer);

  // Client keeps link to Daemon, until Client is closed.
  cli->current_process_id = 0;

  PrintH("OpenClient: z=%x ret\n", reply->status);
  return reply->status;
}

errnum ClientOperationC(struct PathDesc* cli, byte op) {
  struct PathDesc* dae = cli->peer;
  PrintH("ClientOperationC op=%x cli=%x dae=%x entry\n", op, cli, dae);
  CheckClient(cli);
  CheckDaemon(dae);
  cli->current_process_id = Os9CurrentProcessId();

  CheckPeer(cli, dae);  // Client is already linked to Daemon.
  SetPeer(dae, cli);  // Daemon links to Client during the client operation.

  struct Fuse2Request* request = (struct Fuse2Request*)(dae->daemon_buffer);
  char* payload = (char*)(request+1);

  request->operation = op;
  request->path_num = cli->path_num;
  request->a_reg = cli->regs->ra;
  request->b_reg = cli->regs->rb;
  request->size = cli->regs->ry;
  cli->buf_len = sizeof *request;

  switch (op) {
    case OP_CLOSE:
      break;

    case OP_READ:
    case OP_READLN:
      break;
    case OP_WRITE:
      if (cli->buf_len) {
        cli->buf_len += cli->regs->ry;
        MoveToKernel(dae, cli->regs->rx, cli->buf_len, sizeof *request);
      }
      break;
    case OP_WRITLN:
      if (cli->buf_len) {
        // We will move the entire user process buffer into the kernel buffer,
        // because it will be hard to find terminating characters in user space.
        MoveToKernel(dae, cli->regs->rx, cli->regs->ry + sizeof *request, sizeof *request);

        // WritLn should stop at \r or \n or if we encounter \0.
        word i;
        for (i = 0; i < cli->regs->ry; i++) {
          char ch = payload[i];
          if (ch=='\0') break;
          if (ch=='\n' || ch=='\r') {
            i++;  // Keep the \n or \r
            break;
          }
        }
        // Now adjust the requested size and buf_len to stop at i.
        request->size = i;
        cli->buf_len = i + sizeof *request;
      }
      break;
    default:
      assert(0);
      break;
  }

  PrintH("ClientOperationC: REQUEST op=%x path=%x a=%x b=%x size=%x buf=%x",
      request->operation,
      request->path_num,
      request->a_reg,
      request->b_reg,
      request->size,
      cli->buf_len);

  ////////////////////////
  // Now we switch and let the daemon run.
  SwitchProcess(cli, dae);
  // When we return, the daemon has given us a reply.
  ////////////////////////

  struct Fuse2Reply* reply = (struct Fuse2Reply*)(dae->daemon_buffer);
  payload = (char*)(reply+1);
  // When we wake up:
  if (reply->status == OKAY) {
    switch (op) {
      case OP_CLOSE:
        break;

      case OP_READ:
      case OP_READLN:
        // Copy buffer if non-empty.
        if (reply->size) {
          MoveToUser(dae, cli->regs->rx, reply->size, sizeof *reply);
        }
        cli->regs->ry = reply->size;
        break;

      case OP_WRITE:
      case OP_WRITLN:
        cli->regs->ry = reply->size;
        break;

      default:
        assert(0);
        break;
    }
  }

  cli->current_process_id = 0;
  return reply->status;
}

////////////////////////////////////////////////
///
///  GENERIC "C" FUNCTIONS: could be Daemon or Client.

errnum CreateOrOpenC(struct PathDesc* pd, struct Regs* regs) {
  pd->device_table_entry->dt_num_users = 16; // ARTIFICIALLY KEEP THIS OPEN.
  assert(pd->regs == regs);
  word original_rx = regs->rx;
  pd->buf_len = 0;
  PrintH("CreateOrOpenC: pd=%x regs=%x\n", pd, regs);
  PrintH("@ CreateOrOpenC/ent pd=%x links=%x cpr=%x\n", pd, pd->link_count, pd->current_process_id);

  // Split the path to find 2nd (begin1/end1) and
  // 3rd (begin2/end2) words.  Ignore the 1st ("FUSE").
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
        break;
      default:
        {}// Ignore extra names for now.
    }
  }

  errnum z;
  if (i==3 && ParsedNameEquals(begin1, end1, "DAEMON")) {
    z = OpenDaemon(pd, begin2, end2);
  } else if (i > 1) {
    z = OpenClient(pd, begin1, end1, begin2, end2, original_rx);
  } else {
    PrintH("\nFATAL: CreateOrOpenC: BAD NAME\n");
    z = E_BNAM;
  }
  PrintH("@ CreateOrOpenC/ret pd=%x links=%x cpr=%x z=%x\n", pd, pd->link_count, pd->current_process_id, z);
  return z;
}

errnum CloseC(struct PathDesc* pd, struct Regs* regs) {
  errnum z = 0;
  PrintH("@ CloseC/ent pd=%x links=%x cpr=%x\n", pd, pd->link_count, pd->current_process_id);
  assert(pd->regs == regs);

  if (pd->link_count) {
    Os9AwakenIOQN(pd);
    PrintH("@ CloseC/retEarly pd=%x links=%x cpr=%x z=%x\n", pd, pd->link_count, pd->current_process_id, z);
    return OKAY;
  }

  if (pd->is_daemon) {
    struct PathDesc* dae = pd;
    CheckDaemon(dae);
    errnum err = Os9SRtMem(0x100, dae->daemon_buffer);
    assert(!err);
    bzero(DAEMON_NAME_OFFSET_IN_PD + (char*)dae, DAEMON_NAME_MAX);  // Wipe the daemon name.
    z = OKAY;
  } else {
    struct PathDesc* cli = pd;
    CheckClient(cli);
    z = ClientOperationC(cli, OP_CLOSE);
    ClearPeer(cli, cli->peer); // Finally unlink the daemon when client is closed.
  }
  PrintH("@ CloseC/ret pd=%x links=%x cpr=%x z=%x\n", pd, pd->link_count, pd->current_process_id, z);
  return z;
}

errnum ReadLnC(struct PathDesc* pd, struct Regs* regs) {
  errnum z;
  PrintH("@ ReadLnC/ent pd=%x links=%x cpr=%x\n", pd, pd->link_count, pd->current_process_id);
  assert(pd->regs == regs);
  if (pd->is_daemon) {
    z = E_BMODE;  // Daemon must use Read not ReadLn.
  } else {
    z = ClientOperationC(pd, OP_READLN);
  }
  PrintH("@ ReadLnC/ret pd=%x links=%x cpr=%x z=%x\n", pd, pd->link_count, pd->current_process_id, z);
  return z;
}

errnum WritLnC(struct PathDesc* pd, struct Regs* regs) {
  errnum z;
  PrintH("@ WritLnC/ent pd=%x links=%x cpr=%x\n", pd, pd->link_count, pd->current_process_id);
  assert(pd->regs == regs);
  if (pd->is_daemon) {
    z = E_BMODE; // Daemon must use Write not WritLn.
  } else {
    z = ClientOperationC(pd, OP_WRITLN);
  }
  PrintH("@ WritLnC/ret pd=%x links=%x cpr=%x z=%x\n", pd, pd->link_count, pd->current_process_id, z);
  return z;
}

errnum ReadC(struct PathDesc* pd, struct Regs* regs) {
  errnum z;
  PrintH("@ ReadC/ent pd=%x links=%x cpr=%x\n", pd, pd->link_count, pd->current_process_id);
  assert(pd->regs == regs);
  if (pd->is_daemon) {
    z = DaemonReadC(pd);
  } else {
    z = ClientOperationC(pd, OP_READ);
  }
  PrintH("@ ReadC/ret pd=%x links=%x cpr=%x z=%x\n", pd, pd->link_count, pd->current_process_id, z);
  return z;
}

errnum WriteC(struct PathDesc* pd, struct Regs* regs) {
  errnum z;
  PrintH("@ WriteC/ent pd=%x links=%x cpr=%x\n", pd, pd->link_count, pd->current_process_id);
  assert(pd->regs == regs);
  if (pd->is_daemon) {
    z = DaemonWriteC(pd);
  } else {
    z = ClientOperationC(pd, OP_WRITE);
  }
  PrintH("@ WriteC/ret pd=%x links=%x cpr=%x z=%x\n", pd, pd->link_count, pd->current_process_id, z);
  return z;
}

errnum GetStatC(struct PathDesc* pd, struct Regs* regs) {
  errnum z;
  PrintH("@ GetStatC/ent pd=%x links=%x cpr=%x\n", pd, pd->link_count, pd->current_process_id);
  assert(pd->regs == regs);
  z = 14;
  PrintH("@ GetStatC/ret pd=%x links=%x cpr=%x z=%x\n", pd, pd->link_count, pd->current_process_id, z);
  return z;
}

errnum SetStatC(struct PathDesc* pd, struct Regs* regs) {
  errnum z;
  PrintH("@ SetStatC/ent pd=%x links=%x cpr=%x\n", pd, pd->link_count, pd->current_process_id);
  assert(pd->regs == regs);
  z = 15;
  PrintH("@ SetStatC/ret pd=%x links=%x cpr=%x z=%x\n", pd, pd->link_count, pd->current_process_id, z);
  return z;
}

/////////////// Assembly-to-C Relays

asm CreateOrOpenA() {
  asm {
    PSHS Y,U ; Push U=regs then Y=pathdesc, as args to C fn, and to restore Y and U later.
    LDU #0   ; Terminate frame pointer chain for CMOC.
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
    PSHS Y,U ; Push U=regs then Y=pathdesc, as args to C fn, and to restore Y and U later.
    LDU #0   ; Terminate frame pointer chain for CMOC.
    BSR _CloseC  ; Call C function to do the work.
    LBRA BackToAssembly
  }
}
asm ReadLnA() {
  asm {
    PSHS Y,U ; Push U=regs then Y=pathdesc, as args to C fn, and to restore Y and U later.
    LDU #0   ; Terminate frame pointer chain for CMOC.
    BSR _ReadLnC  ; Call C function to do the work.
    LBRA BackToAssembly
  }
}
asm WritLnA() {
  asm {
    PSHS Y,U ; Push U=regs then Y=pathdesc, as args to C fn, and to restore Y and U later.
    LDU #0   ; Terminate frame pointer chain for CMOC.
    BSR _WritLnC  ; Call C function to do the work.
    LBRA BackToAssembly
  }
}
asm ReadA() {
  asm {
    PSHS Y,U ; Push U=regs then Y=pathdesc, as args to C fn, and to restore Y and U later.
    LDU #0   ; Terminate frame pointer chain for CMOC.
    BSR _ReadC  ; Call C function to do the work.
    LBRA BackToAssembly
  }
}
asm WriteA() {
  asm {
    PSHS Y,U ; Push U=regs then Y=pathdesc, as args to C fn, and to restore Y and U later.
    LDU #0   ; Terminate frame pointer chain for CMOC.
    BSR _WriteC  ; Call C function to do the work.
    LBRA BackToAssembly
  }
}
asm GetStatA() {
  asm {
    PSHS Y,U ; Push U=regs then Y=pathdesc, as args to C fn, and to restore Y and U later.
    LDU #0   ; Terminate frame pointer chain for CMOC.
    BSR _GetStatC  ; Call C function to do the work.
    LBRA BackToAssembly
  }
}
asm SetStatA() {
  asm {
    PSHS Y,U ; Push U=regs then Y=pathdesc, as args to C fn, and to restore Y and U later.
    LDU #0   ; Terminate frame pointer chain for CMOC.
    BSR _SetStatC  ; Call C function to do the work.
    LBRA BackToAssembly
  }
}
