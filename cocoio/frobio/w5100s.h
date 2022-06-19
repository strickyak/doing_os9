#ifndef _FROBIO_W5100S_H
#define _FROBIO_W5100S_H

typedef unsigned char bool;
typedef unsigned char byte;
typedef unsigned char error;
typedef unsigned int word;
#define OKAY 0

#define P0 cocoio_port[0]  // control reg
#define P1 cocoio_port[1] // addr hi
#define P2 cocoio_port[2] // addr lo
#define P3 cocoio_port[3] // data

#define TX_SIZE 2048
#define RX_SIZE 2048
#define TX_SHIFT 11
#define RX_SHIFT 11
#define TX_MASK (TX_SIZE - 1)
#define RX_MASK (RX_SIZE - 1)
#define TX_BUF(N) (0x8000 + ((N)<<TX_SHIFT))
#define RX_BUF(N) (0xC000 + ((N)<<RX_SHIFT))

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

void wiz_reset();
void wiz_configure();
void wiz_delay(int n);

error udp_open(byte socket_n, word src_port, byte* dest_ip, word dest_port);
error udp_send(byte socket_n, byte* payload, word size);

#endif // _FROBIO_W5100S_H
