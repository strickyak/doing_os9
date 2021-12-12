// Test for the CoCoIO with the WizNet 5100s chip
//   https://computerconect.com/products/cocoio-network-only-developers-edition
// Copying the logic from
//   github.com/MarkO-555/CoCoIO-NIC-Base-Code/BASIC/COCOIO12.BAS
// C code by Strick.
//   MIT license (see file `LICENSE`).
//   Hint: /opt/yak/cmoc/bin/cmoc --os9 test12.c

#include <cmoc.h>
#include <assert.h>

typedef unsigned char byte;
typedef int word;
typedef int addr;

#define CMD 0xFF68
#define LOC_HI  0xFF69
#define LOC_LO  0xFF6A
#define REG  0xFF6B

// Extract Hi or Lo byte from a word.
byte Hi(word a) { return (byte)(0xFF & (a >> 8)); }
byte Lo(word a) { return (byte)(0xFF & (a)); }

// Peek and Poke a byte to 6809 memory space.
byte Peek(addr a) { return *(byte*)a; }
void Poke(addr a, byte b) { *(byte*)a = b; }

// Reset the chip.
void Reset() { Poke(CMD, 0x80); }
// Enable auto-incrementing location for Gets and Puts.
void Auto() { Poke(CMD, 0x03); }
// Set register location.
void SetLoc(word loc) {
   Poke(LOC_HI, Hi(loc));
   Poke(LOC_LO, Lo(loc));
}
// Get or Put registers.
byte Get() { return Peek(REG); }
void Put(byte b) { Poke(REG, b); }


// GWR: Gateway IP Address.
void SetGateway(byte a, byte b, byte c, byte d) {
  SetLoc(0x0001); Put(a); Put(b); Put(c); Put(d);
}
void GetGateway(byte *a, byte *b, byte *c, byte *d) {
  SetLoc(0x0001); *a=Get(); *b=Get(); *c=Get(); *d=Get();
}
// SUBR: Subnet Mask.
void SetMask(byte a, byte b, byte c, byte d) {
  SetLoc(0x0005); Put(a); Put(b); Put(c); Put(d);
}
void GetMask(byte *a, byte *b, byte *c, byte *d) {
  SetLoc(0x0005); *a=Get(); *b=Get(); *c=Get(); *d=Get();
}
// SHAR: Source Hardware Address.
void SetMac(byte a, byte b, byte c, byte d, byte e, byte f) {
  SetLoc(0x0009); Put(a); Put(b); Put(c); Put(d); Put(e); Put(f);
}
void GetMac(byte *a, byte *b, byte *c, byte *d, byte *e, byte *f) {
  SetLoc(0x000f); *a=Get(); *b=Get(); *c=Get(); *d=Get(); *e=Get(); *f=Get();
}
// SIPR: Source IP.
void SetMyIp(byte a, byte b, byte c, byte d) {
  SetLoc(0x000f); Put(a); Put(b); Put(c); Put(d);
}
void GetMyIp(byte *a, byte *b, byte *c, byte *d) {
  SetLoc(0x000f); *a=Get(); *b=Get(); *c=Get(); *d=Get();
}

int main() {
  SetMac(0, 1, 2, 3, 4, 5);
  SetGateway(10, 1, 2, 3);
  SetMyIp(10, 11, 22, 33);
  SetMask(255, 0, 0, 0);

  byte a, b, c, d, e, f;
  GetMac(&a, &b, &c, &d, &e, &f);
  printf("mac: %02x:%02x:%02x:%02x:%02x:%02x\n", a, b, c, d, e, f);
  GetGateway(&a, &b, &c, &d);
  printf("gateway: %d.%d.%d.%d\n", a, b, c, d);
  GetMyIp(&a, &b, &c, &d);
  printf("my ip: %d.%d.%d.%d\n", a, b, c, d);
  GetMask(&a, &b, &c, &d);
  printf("mask: %d.%d.%d.%d\n", a, b, c, d);
  return 0;
}
