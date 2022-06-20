#ifndef _FROBIO_W5100S_H
#define _FROBIO_W5100S_H

#include "frobio/frobio.h"

// Short names for hardware ports depend on `hwport`.
#define P0 hwport[0]  // control reg
#define P1 hwport[1] // addr hi
#define P2 hwport[2] // addr lo
#define P3 hwport[3] // data

// Keep this at the default of 2K for each.
#define TX_SIZE 2048
#define RX_SIZE 2048
#define TX_SHIFT 11
#define RX_SHIFT 11
#define TX_MASK (TX_SIZE - 1)
#define RX_MASK (RX_SIZE - 1)
#define TX_BUF(N) (0x4000 + ((word)(N)<<TX_SHIFT))
#define RX_BUF(N) (0x6000 + ((word)(N)<<RX_SHIFT))

// Socket register offsets:
#define SockMode 0x00
#define SockCommand 0x01
#define SockInterrupt 0x02
#define SockStatus 0x03
#define SockSourcePort 0x04
#define SockDestIp 0x0C
#define SockDestPort 0x10
#define TxFreeSize 0x20
#define TxReadPtr 0x22
#define TxWritePtr 0x24
#define RxSize 0x26
#define RxReadPtr 0x28
#define RxWritePtr 0x2A

#endif // _FROBIO_W5100S_H
