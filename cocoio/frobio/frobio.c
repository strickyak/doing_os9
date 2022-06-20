#include <cmoc.h>
#include <assert.h>

#include "frobio/w5100s.h"

// byte dest_ip[4] = {192, 168, 86, 36};
byte dest_ip[4] = {10, 2, 2, 2};

char payload[] = "!!!!!! Frobio Frobio Frobio Frobio !!!!!!";

int main() {
  wiz_verbose = 1;
  wiz_reset();
  wiz_configure();
  wiz_arp(dest_ip);
  for (byte i = 0; i < 3; i++) {
    wiz_ping(dest_ip);
    printf("\r");
  }

  byte sock = 0;
  printf("\r open...");
  error err = udp_open(sock, 0x9999, dest_ip, 0x8888);
  printf("...opened:err=%x\n", err);
  assert(!err);
  printf("\r send...");
  err = udp_send(sock, (byte*)payload, sizeof payload);
  printf("...sent:err=%x\n", err);

  wiz_verbose = 0;
  sock_show(sock);
  printf(" delay...");
  wiz_delay(10000);
  printf(" delayed...");
  sock_show(sock);
  return 0;
}
