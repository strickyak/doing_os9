#ifndef _FUSE1_FUSE2_H_
#define _FUSE1_FUSE2_H_

struct Fuse2Request {
  unsigned char operation;
  unsigned char path_num;
  unsigned char a_reg; // e.g. access mode
  unsigned char b_reg; // e.g. file attrs, Stt code
  unsigned int size; // of payload, to follow.
}; // sizeof == 6
   //
struct Fuse2Reply {
  unsigned char status; // 0 or OS9 error number.
  unsigned int size; // of payload, to follow.
};

enum ClientOp {
  OP_NONE = 0,
  OP_CREATE = 1,
  OP_OPEN = 2,
  OP_CLOSE = 3,
  OP_READ = 4,
  OP_WRITE = 5,
  OP_READLN = 6,
  OP_WRITLN = 7,
};

#endif // _FUSE1_FUSE2_H_
