#define MY_COCOIO_PORT  0xFF68
#define MY_ADDR         IP4ADDR(10, 2, 2, 7)
#define MY_MASK         IP4ADDR(255, 255, 255, 0)
#define MY_GATEWAY      IP4ADDR(10, 2, 2, 1)
#define MY_MAC          "wiznet"

#include <cmoc.h>
#include <assert.h>
#include "frobio/frobio.h"

char payload[] = "!!!!!! Frobio Frobio Frobio Frobio !!!!!!";
byte buf[1500];

int main() {
  wiz_verbose = 1;
  ip4addr dest_ip = IP4ADDR(10, 2, 2, 2);

  struct FrobioConfig config;
  config.ip_addr = MY_ADDR;
  config.ip_mask = MY_MASK;
  config.ip_gateway = MY_GATEWAY;
  for (byte i = 0; i < 6; i++ ) config.ether_mac[i] = MY_MAC[i];

  // Reset and configure.
  wiz_reset(MY_COCOIO_PORT);
  wiz_configure(&config);

  // Try arp.
  wiz_arp(dest_ip);

  // Try ping 3 times.
  for (byte i = 0; i < 3; i++) {
    wiz_ping(dest_ip);
    printf("\n");
  }

  for (byte socknum = 0; socknum < 1; socknum++ ) {
      // UDP open.
      printf("\n open...");
      error err = udp_open(socknum, 0x9999);
      printf("...opened:err=%x\n", err);
      assert(!err);

      // UDP send.
      payload[10] = '0' + socknum;
      printf("\n send...");
      err = udp_send(socknum, (byte*)payload, sizeof payload, dest_ip, 0x8888);
      printf("...sent:err=%x\n", err);

      word size = 100;
      ip4addr from_addr = 0;
      word from_port = 0;
      printf("\n recv...");
      err = udp_recv(socknum, buf, &size, &from_addr, &from_port);
      printf("...recv:err=%x size=%x\n", err, size);
      if (!err) {
        for (word i = 0; i < size; i++) {
          printf("%02x ", buf[i]);
        }
        printf("\n");
      }
      printf("recv:size=%x from_addr=%lx from_port=%x\n", size, from_addr, from_port);

      // Debugging info.
      sock_show(socknum);

      udp_close(socknum);
  }

  return 0;
}
