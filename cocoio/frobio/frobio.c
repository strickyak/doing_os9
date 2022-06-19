#include <cmoc.h>
#include <assert.h>

#include "frobio/w5100s.h"

byte dest_ip[4] = {192, 168, 8, 148};
char payload[] = "!!!!!! Frobio Frobio Frobio Frobio !!!!!!";

int main() {
  wiz_reset();
  wiz_configure();

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
