#include "frobio/w5100s.h"
#include "frobio/config.h"

static byte* cocoio_port = (byte*)(COCOIO_PORT);
static byte ether_mac[6] = ETHER_MAC;
static byte ip_addr[4] = IP_ADDR;
static byte ip_mask[4] = IP_MASK;
static byte ip_gate[4] = IP_GATE;

static int bogus_int_for_delay;
void wiz_delay(int n) {
  for (int i=0; i<n; i++) bogus_int_for_delay += i;
}

byte peek(word reg) {
  P1 = (byte)(reg >> 8);
  P2 = (byte)(reg);
  byte z = P3;
  printf("[%x->%2x] ", reg, z);
  return z;
}
word peek_word(word reg) {
  P1 = (byte)(reg >> 8);
  P2 = (byte)(reg);
  byte hi = P3;
  byte lo = P3;
  word z = ((word)(hi) << 8) + lo;
  printf("[%x->%4x] ", reg, z);
  return z;
}
void poke(word reg, byte value) {
  P1 = (byte)(reg >> 8);
  P2 = (byte)(reg);
  P3 = value;
  printf("[%x<=%2x] ", reg, value);
}
void poke_word(word reg, word value) {
  P1 = (byte)(reg >> 8);
  P2 = (byte)(reg);
  P3 = (byte)(value >> 8);
  P3 = (byte)(value);
  printf("[%x<=%4x] ", reg, value);
}
void poke_n(word reg, byte* data, word size) {
  P1 = (byte)(reg >> 8);
  P2 = (byte)(reg);
  printf("[%x<=== ", reg);
  for (word i=0; i<size; i++) {
    printf("%2x ", *data);
    P3 = *data++;
  }
  printf("] ");
}

void wiz_reset() {
  wiz_delay(42);
  P0 = 128; // Reset
  wiz_delay(42);
  P0 = 3;   // IND=1 AutoIncr=1 BlockPingResponse=0 PPPoE=0
  wiz_delay(42);
}

void wiz_configure() {
  printf("CONFIGURE ");
  P1 = 0; P2 = 1;  // start at addr 0x0001: Gateway IP.
  printf("gate ");
  poke_n(0x0001/*gateway*/, ip_gate, sizeof ip_gate);

  printf("mask ");
  poke_n(0x0005/*mask*/, ip_mask, sizeof ip_mask);

  printf("mac ");
  poke_n(0x0009/*ether_mac*/, ether_mac, sizeof ether_mac);

  printf("addr ");
  poke_n(0x000f/*ip_addr*/, ip_addr, sizeof ip_addr);

  poke(0x001a/*=Rx Memory Size*/, 0x55); // 2k per sock
  poke(0x001b/*=Tx Memory Size*/, 0x55); // 2k per sock

  // UDP Unreach Block. TCP RST Block.
  //// NO //  poke(0x0030, 0x60);
}

error wiz_arp(byte* dest_ip) {
  printf("\nARP: dest_ip=%d.%d.%d.%d ", dest_ip[0], dest_ip[1], dest_ip[2], dest_ip[3]);
  printf("SLPIPR ");
  // Socket-less Peer IP Address Register
  poke_n(0x0050 /*=SLPIPR*/, dest_ip, /*size=*/4);

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
    printf("(arp->(%x) %x:%x:%x:%x:%x:%x) ",
      x, m1, m2, m3, m4, m5, m6);
  } while (!x);
  return (x&2) ? OKAY : 252; // look for ARP ack.
}

word ping_sequence = 100;
error wiz_ping(byte* dest_ip) {
  printf("\nPING: dest_ip=%d.%d.%d.%d ", dest_ip[0], dest_ip[1], dest_ip[2], dest_ip[3]);
  printf("SLPIPR ");
  // Socket-less Peer IP Address Register
  poke_n(0x0050 /*=SLPIPR*/, dest_ip, /*size=*/4);

  // Socketless PING command.
  byte x = 0;
  do {
    printf(" Ping(%x) ", ping_sequence);
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
    printf("(ping->(%x) %x:%x:%x:%x:%x:%x) ",
      x, m1, m2, m3, m4, m5, m6);
    delay(42);
  } while (!x);
  return (x&1) ? OKAY : 251; // look for PING ack.
}

error udp_open(byte socknum, word src_port, byte* dest_ip, word dest_port) {
  printf("OPEN: sock=%x src_p=%x dest_ip=%d.%d.%d.%d dest_p=%x ", socknum, src_port, dest_ip[0],dest_ip[1], dest_ip[2],  dest_ip[3], dest_port);
  word regs = ((word)socknum + 4) << 8;
  printf("udp ");
  poke(regs+SockMode, 2); // Set UDP Protocol mode.

  printf("src_p ");
  poke_word(regs+SockSourcePort, src_port);
  printf("dest_ip ");
  poke_n(regs+SockDestIp, dest_ip, /*size=*/4);
  printf("dest_p ");
  poke_word(regs+SockDestPort, dest_port);

  printf("cmd:OPEN ");
  poke(regs+SockCommand, 1/*=OPEN*/);  // OPEN IT!
  return OKAY;
}

error udp_send(byte socknum, byte* payload, word size) {
  printf("SEND: sock=%x payload=%x size=%x ", socknum, payload, size);
  word regs = ((word)socknum + 4) << 8;
  word buf = TX_BUF(socknum);

  word free = TX_MASK & peek_word(TxFreeSize);
  printf("SEND: regs=%x buf=%x free=%x ", regs, buf, free);
  if (free < size) return 255; // no buffer room.

  word tx_r = TX_MASK & peek_word(regs+TxReadPtr);
  printf("tx_r=%x ", tx_r);
  printf("size=%x ", size);
  printf("tx_r+size=%x ", tx_r+size);
  printf("TX_SIZE=%x ", TX_SIZE);
  if (tx_r + size >= TX_SIZE) {
    // split across edges of circular buffer.
    word size1 = TX_SIZE - tx_r;
    word size2 = size - size1;
    poke_n(buf + tx_r, payload, size1);
    poke_n(buf, payload, size2);
  } else {
    poke_n(buf + tx_r, payload, size);
  }
  printf("size ");
  poke_word(regs+TxWritePtr, size); // size goes here.
  printf("cmd:SEND ");
  poke(regs+SockCommand, 0x20/*=SEND*/);  // SEND IT!
  return OKAY;
}
