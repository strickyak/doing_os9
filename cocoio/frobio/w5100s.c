#include <cmoc.h>
#include "frobio/w5100s.h"

// Global storage.
bool wiz_verbose;
byte* hwport;

// Debugging Verbosity.
#define Say    if (wiz_verbose) printf

static int bogus_int_for_delay;
void wiz_delay(int n) {
  for (int i=0; i<n; i++) bogus_int_for_delay += i;
}

static byte peek(word reg) {
  P1 = (byte)(reg >> 8);
  P2 = (byte)(reg);
  byte z = P3;
  Say("[%x->%2x] ", reg, z);
  return z;
}
static word peek_word(word reg) {
  P1 = (byte)(reg >> 8);
  P2 = (byte)(reg);
  byte hi = P3;
  byte lo = P3;
  word z = ((word)(hi) << 8) + lo;
  Say("[%x->%4x] ", reg, z);
  return z;
}
static void poke(word reg, byte value) {
  P1 = (byte)(reg >> 8);
  P2 = (byte)(reg);
  P3 = value;
  Say("[%x<=%2x] ", reg, value);
}
static void poke_word(word reg, word value) {
  P1 = (byte)(reg >> 8);
  P2 = (byte)(reg);
  P3 = (byte)(value >> 8);
  P3 = (byte)(value);
  Say("[%x<=%4x] ", reg, value);
}
static void poke_n(word reg, void* data, word size) {
  byte* from = (byte*) data;
  P1 = (byte)(reg >> 8);
  P2 = (byte)(reg);
  Say("[%x<=== ", reg);
  for (word i=0; i<size; i++) {
    Say("%2x ", *from);
    P3 = *from++;
  }
  Say("] ");
}

void wiz_reset(word wiz_ioport) {
  // Set the global variable used by P0, P1, P2, P3.
  hwport = (byte*) wiz_ioport;

  wiz_delay(42);
  P0 = 128; // Reset
  wiz_delay(42);
  P0 = 3;   // IND=1 AutoIncr=1 BlockPingResponse=0 PPPoE=0
  wiz_delay(42);
}

void wiz_configure(struct FrobioConfig* cf) {
  Say("CONFIGURE ");

  P1 = 0; P2 = 1;  // start at addr 0x0001: Gateway IP.
  Say("gate ");
  poke_n(0x0001/*gateway*/, &cf->ip_gateway, sizeof cf->ip_gateway);

  Say("mask ");
  poke_n(0x0005/*mask*/, &cf->ip_mask, sizeof cf->ip_mask);

  Say("mac ");
  poke_n(0x0009/*ether_mac*/, cf->ether_mac, sizeof cf->ether_mac);

  Say("addr ");
  poke_n(0x000f/*ip_addr*/, &cf->ip_addr, sizeof cf->ip_addr);

  poke(0x001a/*=Rx Memory Size*/, 0x55); // 2k per sock
  poke(0x001b/*=Tx Memory Size*/, 0x55); // 2k per sock

  // Force all 4 sockets to be closed.
  for (byte socknum=0; socknum<4; socknum++) {
      word base = ((word)socknum + 4) << 8;
      poke(base+SockCommand, 0x10/*CLOSE*/);
      poke(base+SockMode, 0x00/*Protocol: Socket Closed*/);
      poke(base+0x001e/*_RXBUF_SIZE*/, 2); // 2KB
      poke(base+0x001f/*_TXBUF_SIZE*/, 2); // 2KB
  }
}

error udp_close(byte socknum) {
  Say("CLOSE: sock=%x ", socknum);
  if (socknum > 3) return 0xf0/*E_UNIT*/;

  word base = ((word)socknum + 4) << 8;
  poke(base+SockCommand, 0x10/*CLOSE*/);
  poke(base+SockMode, 0x00/*Protocol: Socket Closed*/);
  return OKAY;
}

error wiz_arp(ip4addr dest_ip) {
  byte* d = (byte*)&dest_ip;
  Say("\nARP: dest_ip=%d.%d.%d.%d ", d[0], d[1], d[2], d[3]);
  Say("SLPIPR ");
  // Socket-less Peer IP Address Register
  poke_n(0x0050 /*=SLPIPR*/, &dest_ip, sizeof dest_ip);

  // Socketless ARP command.
  byte x = 0;
  do {
    poke(0x005f, 0); // clear interrupt reg
    poke(0x004c/*=SLCR*/, 2/*=ARP*/); // command

    delay(42);
    x = peek(0x005f/*=SLIR socketless interrupt reg*/);
    byte m1 = peek(0x0054);
    byte m2 = peek(0x0055);
    byte m3 = peek(0x0056);
    byte m4 = peek(0x0057);
    byte m5 = peek(0x0058);
    byte m6 = peek(0x0059);
    Say("(arp->(%x) %x:%x:%x:%x:%x:%x) ",
      x, m1, m2, m3, m4, m5, m6);
  } while (!x);
  return (x&2) ? OKAY : 252; // look for ARP ack.
}

word ping_sequence = 100;
error wiz_ping(ip4addr dest_ip) {
  byte* d = (byte*)&dest_ip;
  Say("\nPING: dest_ip=%d.%d.%d.%d ", d[0], d[1], d[2], d[3]);
  Say("SLPIPR ");
  // Socket-less Peer IP Address Register
  poke_n(0x0050 /*=SLPIPR*/, &dest_ip, sizeof dest_ip);

  // Socketless PING command.
  byte x = 0;
  do {
    Say(" Ping(%x) ", ping_sequence);
    poke_word(0x005A, ping_sequence++);
    poke(0x005f, 0); // clear interrupt reg
    poke(0x004c/*=SLCR*/, 1/*=PING*/); // command

    delay(42);
    x = peek(0x005f/*=SLIR socketless interrupt reg*/);
    byte m1 = peek(0x0054);
    byte m2 = peek(0x0055);
    byte m3 = peek(0x0056);
    byte m4 = peek(0x0057);
    byte m5 = peek(0x0058);
    byte m6 = peek(0x0059);
    Say("(ping->(%x) %x:%x:%x:%x:%x:%x) ",
      x, m1, m2, m3, m4, m5, m6);
    delay(42);
  } while (!x);
  return (x&1) ? OKAY : 251; // look for PING ack.
}

error udp_open(byte socknum, word src_port) {
  Say("OPEN: sock=%x src_p=%x ", socknum, src_port);
  if (socknum > 3) return 0xf0/*E_UNIT*/;

  word base = ((word)socknum + 4) << 8;
  word buf = TX_BUF(socknum);
  Say("udp base=%x buf=%x", base, buf);

  byte status = peek(base+SockStatus);
  if (status != 0x00/*SOCK_CLOSED*/) return 0xf6 /*E_NOTRDY*/;

  poke(base+SockMode, 2); // Set UDP Protocol mode.

  Say("src_p ");
  poke_word(base+SockSourcePort, src_port);
  poke(base+0x002c/*_IMR*/, 0xFF); // mask all interrupts.
  poke_word(base+0x002d/*_FRAGR*/, 0); // don't fragment.
  poke(base+0x002f/*_MR2*/, 0x00); // no blocks.

  Say("status->%x ", peek(base+SockStatus));
  Say("cmd:OPEN ");
  poke(base+SockCommand, 1/*=OPEN*/);  // OPEN IT!
  Say("status->%x ", peek(base+SockStatus));
  for(word i = 0; i < 60000; i++) {
    byte status = peek(base+SockStatus);
    if (status == 0x22/*SOCK_UDP*/) return OKAY;
  }
  return 0xfa/*E_DEVBSY*/;
}

error udp_send(byte socknum, byte* payload, word size, ip4addr dest_ip, word dest_port) {
  Say("SEND: sock=%x payload=%x size=%x ", socknum, payload, size);
  byte* d = (byte*)&dest_ip;
  Say(" dest=%d.%d.%d.%d:%d(dec) ", d[0], d[1], d[2], d[3], dest_port);
  if (socknum > 3) return 0xf0/*E_UNIT*/;

  word base = ((word)socknum + 4) << 8;
  word buf = TX_BUF(socknum);

  byte status = peek(base+SockStatus);
  if (status != 0x22/*SOCK_UDP*/) return 0xf6 /*E_NOTRDY*/;

  Say("dest_ip ");
  poke_n(base+SockDestIp, &dest_ip, sizeof dest_ip);
  Say("dest_p ");
  poke_word(base+SockDestPort, dest_port);

  word free = peek_word(base + TxFreeSize);
  Say("SEND: base=%x buf=%x free=%x ", base, buf, free);
  if (free < size) return 255; // no buffer room.

  word tx_r = peek_word(base+TxReadPtr);
  Say("tx_r=%x ", tx_r);
  Say("size=%x ", size);
  Say("tx_r+size=%x ", tx_r+size);
  Say("TX_SIZE=%x ", TX_SIZE);
  word offset = TX_MASK & tx_r;
  if (offset + size >= TX_SIZE) {
    // split across edges of circular buffer.
    word size1 = TX_SIZE - offset;
    word size2 = size - size1;
    poke_n(buf + offset, payload, size1);  // 1st part
    poke_n(buf, payload + size1, size2);   // 2nd part
  } else {
    // contiguous within the buffer.
    poke_n(buf + tx_r, payload, size);  // whole thing
  }
  Say("size ");
  poke_word(base+TxWritePtr, size); // size goes here.
  Say("status->%x ", peek(base+SockStatus));
  sock_show(socknum);
  Say("cmd:SEND ");

  poke(base+SockInterrupt, 0x1f);  // Reset interrupts.
  poke(base+SockCommand, 0x20/*=SEND*/);  // SEND IT!
  Say("status->%x ", peek(base+SockStatus));

  error err = OKAY;
  while(1) {
    byte irq = peek(base+SockInterrupt);
    if (irq) {
      if (irq != 0x10 /*=SENDOK*/) {
        err = 0xf5/*=E_WRITE*/;
      }
      break;
    }
  }
  poke(base+SockInterrupt, 0x1f);  // Reset interrupts.
  return err;
}

error udp_recv(byte socknum, byte* payload, word* size_in_out, ip4addr* from_addr_out, word* from_port_out) {
  Say("RECV: sock=%x payload=%x size=%x ", socknum, payload, *size_in_out);
  if (socknum > 3) return 0xf0/*E_UNIT*/;

  word base = ((word)socknum + 4) << 8;
  word buf = RX_BUF(socknum);
  Say("RECV: base=%x buf=%x ", base, buf);

  byte status = peek(base+SockStatus);
  if (status != 0x22/*SOCK_UDP*/) return 0xf6 /*E_NOTRDY*/;

  poke_word(base+0x000c, 0); // clear Dest IP Addr
  poke_word(base+0x000e, 0); // ...
  poke_word(base+0x0010, 0); // clear Dest port addr

  poke(base+SockInterrupt, 0x1f);  // Reset interrupts.
  poke(base+SockCommand, 0x40/*=RECV*/);  // RECV command.
  Say("status->%x ", peek(base+SockStatus));

  Say(" ====== WAIT ====== ");
  while(1) {
    bool v = wiz_verbose;
    wiz_verbose = 0;
    byte irq = peek(base+SockInterrupt);
    if (irq) {
      wiz_verbose = v;
      poke(base+SockInterrupt, 0x1f);  // Reset interrupts.
      if (irq != 0x04 /*=RECEIVED*/) {
        return 0xf4/*=E_READ*/;
      }
      break;
    }
  }

  word recv_size = peek_word(base+0x0026/*_RX_RSR*/);

  word ptr = peek_word(base+0x0028/*_RX_RD*/);
  struct UdpRecvHeader hdr;
  for (word i = 0; i < sizeof hdr; i++) {
      ((byte*)&hdr)[i] = peek(buf+ptr);
      ptr++;
      ptr &= RX_MASK;
  }
  recv_size -= sizeof hdr;
  if (recv_size > *size_in_out) return 0xed/*E_NORAM*/;
  for (word i = 0; i < recv_size; i++) {
      payload[i] = peek(buf+ptr);
      ptr++;
      ptr &= RX_MASK;
  }

  *size_in_out = hdr.len;
  *from_addr_out = hdr.addr;
  *from_port_out = hdr.port;
  return OKAY;
}

void sock_show(byte socknum) {
  bool v = wiz_verbose;

  if (v) {
      wiz_verbose = 0;
      word base = ((word)socknum + 4) << 8;
      for (byte i = 0; i < 64; i+=16) {
        printf("\n%04x: ", base+i);
        for (byte j = 0; j < 16; j++) {
          byte k = i+j;
          printf("%02x ", peek(base+k));
          if ((j&3)==3) printf(" ");
        }
      }
      wiz_verbose = v;
  }
}
