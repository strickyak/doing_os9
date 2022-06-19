#include <cmoc.h>
#include <assert.h>

#include "frobio/w5100s.h"

// byte dest_ip[4] = {192, 168, 86, 36};
byte dest_ip[4] = {10, 2, 2, 2};

char payload[] = "!!!!!! Frobio Frobio Frobio Frobio !!!!!!";

int main() {
  wiz_reset();
  wiz_configure();
  wiz_arp(dest_ip);
  for (byte i = 0; i < 10; i++) {
    wiz_ping(dest_ip);
  }

  byte sock = 0;
  printf(" open...");
  error err = udp_open(sock, 0x9999, dest_ip, 0x8888);
  printf("...opened ");
  assert(!err);
  printf(" send...");
  err = udp_send(sock, (byte*)payload, sizeof payload);
  printf("...sent ");
  assert(!err);

  printf(" delay...");
  delay(1000);
  printf(" delayed...");
  return 0;
}
