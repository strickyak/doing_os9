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

void wiz_reset() {
  wiz_delay(42);
  P0 = 128; // Reset
  wiz_delay(42);
  P0 = 3;   // IND=1 AutoIncr=1 BlockPingResponse=0 PPPoE=0
  wiz_delay(42);
}

byte peek(word reg) {
  P1 = (byte)(reg >> 8);
  P2 = (byte)(reg);
  return P3;
}
word peek_word(word reg) {
  P1 = (byte)(reg >> 8);
  P2 = (byte)(reg);
  byte hi = P3;
  byte lo = P3;
  return ((word)(hi) << 8) + lo;
}
void poke(word reg, byte value) {
  P1 = (byte)(reg >> 8);
  P2 = (byte)(reg);
  P3 = value;
}
void poke_word(word reg, word value) {
  P1 = (byte)(reg >> 8);
  P2 = (byte)(reg);
  P3 = (byte)(value >> 8);
  P3 = (byte)(value);
}
void poke_n(word reg, byte* data, word size) {
  P1 = (byte)(reg >> 8);
  P2 = (byte)(reg);
  for (word i=0; i<size; i++) P3 = *data++;
}

void wiz_configure() {
  P1 = 0; P2 = 1;  // start at addr 0x0001: Gateway IP.
  for (byte i=0; i<sizeof ip_gate; i++) P3 = ip_gate[i];
  for (byte i=0; i<sizeof ip_mask; i++) P3 = ip_mask[i];
  for (byte i=0; i<sizeof ether_mac; i++) P3 = ether_mac[i];
  for (byte i=0; i<sizeof ip_addr; i++) P3 = ip_addr[i];

  // UDP Unreach Block. TCP RST Block.
  poke(0x0030, 0x60);
}

error udp_open(byte socket_n, word src_port, byte* dest_ip, word dest_port) {
  word regs = ((word)socket_n + 4) << 8;
  poke(regs+SockMode, 2); // Set UDP Protocol mode.

  poke_word(regs+SockSourcePort, src_port);
  poke_n(regs+SockDestIp, dest_ip, /*size=*/4);
  poke_word(regs+SockDestPort, dest_port);

  poke(regs+SockCommand, 1/*=OPEN*/);  // OPEN IT!
  return OKAY;
}

error udp_send(byte socket_n, byte* payload, word size) {
  word regs = ((word)socket_n + 4) << 8;
  word buf = TX_BUF(socket_n);

  word free = TX_MASK & peek_word(TxFreeSize);
  if (free < size) return 255; // no buffer room.

  word tx_r = TX_MASK & peek_word(regs+TxReadPtr);
  if (tx_r + size >= TX_SIZE) {
    // split across edges of circular buffer.
    word size1 = TX_SIZE - tx_r;
    word size2 = size - size1;
    poke_n(buf + tx_r, payload, size1);
    poke_n(buf, payload, size2);
  } else {
    poke_n(buf + tx_r, payload, size);
  }
  poke_word(regs+TxWritePtr, size); // size goes here.
  poke(regs+SockCommand, 0x20/*=SEND*/);  // SEND IT!
  return OKAY;
}
