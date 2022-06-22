#define MY_COCOIO_PORT  0xFF68
#define MY_ADDR         IP4ADDR(10, 2, 2, 7)
#define MY_MASK         IP4ADDR(255, 255, 255, 0)
#define MY_GATEWAY      IP4ADDR(10, 2, 2, 1)
#define MY_MAC          "wiznet"

#define SERVER_ADDR      IP4ADDR(10, 2, 2, 2)
#define SERVER_PORT      69

#include <cmoc.h>
#include <assert.h>
#include "frobio/frobio.h"
#include "os9call/os9call.h"
#include "os9call/os9errno.h"
#include "nylib/nylib.h"

#define OP_READ 1
#define OP_WRITE 2
#define OP_DATA 3
#define OP_ACK 4
#define OP_ERROR 5

#define SOCK 0  // device number.

byte packet[2000];

void FatalD(const char* fmt, int d) {
  printf("\n*** ");
  printf(fmt, d);
  exit(255);
}

void Reset() {
  wiz_verbose = 1;

  struct FrobioConfig config;
  config.ip_addr = MY_ADDR;
  config.ip_mask = MY_MASK;
  config.ip_gateway = MY_GATEWAY;
  for (byte i = 0; i < 6; i++ )
    config.ether_mac[i] = MY_MAC[i];

  // Reset and configure.  Test ping.
  wiz_reset(MY_COCOIO_PORT);
  wiz_configure(&config);
  wiz_ping(SERVER_ADDR);
  error err = udp_open(SOCK, 0x6789);
  if (err) FatalD("cannot udp_open: %d\n", err);
}

void SendAck(word block, word tid) {
  word* wp = (word*)packet;
  wp[0] = OP_ACK;
  wp[1] = block;
  error err = udp_send(SOCK, packet, 4, SERVER_ADDR, tid);
  if (err) FatalD("cannot udp_send request: %d\n", err);
}
void SendRequest(word opcode, char* filename, bool ascii) {
  char* p = (char*)packet;
  *(word*)p = opcode;
  p += 2;

  int n = strlen(filename);
  strcpy(p, filename);
  p += n+1;

  const char* mode = ascii ? "netascii" : "octet";
  n = strlen(mode);
  strcpy(p, mode);
  p += n+1;

#if 0
  printf("\n request: ");
  for (byte* q = packet; q < (byte*)p; q++ ) {
    printf("%02x ", *q);
  }
#endif

  error err = udp_send(SOCK, packet, p-(char*)packet, SERVER_ADDR, SERVER_PORT);
  if (err) FatalD("cannot udp_send request: %d\n", err);
}

int Get(char* filename) {
  wiz_verbose = 0;
  SendRequest(OP_READ, filename, /*ascii=*/0);

  while (1) {
    word size = sizeof packet;
    ip4addr from_addr = 0;
    word from_port = 0;
    error err = udp_recv(SOCK, packet, &size, &from_addr, &from_port);
    if (err) FatalD("cannot udp_recv data: %d\n", err);
    word type = ((word*)packet)[0];
    word arg = ((word*)packet)[1];

    // printf("\n GOT %d BYTES FROM %lx:%x", size, from_addr, from_port);
    printf("G:%d:%d,%d ", size, type, arg);
#if 0
    printf("\n got: {");
    for (int i = 0; i < size; i++) {
      printf("%02x ", packet[i]);
      if ((i&3)==3) printf(" ");
      if (i>63) break;
    }
    printf("}\n");
#endif
    switch (type) {
    case OP_DATA:
        // arg is block number.
        word len = size - 4;
        SendAck(arg, from_port);
        // printf(" [recv block %d len %d] ", arg, len);
        if (len < 512) goto END_LOOP;
        break;
    case OP_ERROR:
        // arg is error number.
      printf(" {%s} ", packet+4);
      FatalD("Get() got error %d", arg);
      break;
    default:
      FatalD("Get() did not expect to recv type %d", type);
    }
  }  // while(1)
END_LOOP:
  printf("Get Finished.  ");
  return 0;
}

bool StrEq(const char* a, const char* b) {
  while (*a && *b) {
    if (*a != *b) return 0;
    a++;
    b++;
  }
  return (*a == *b);
}

int main(int argc, char* argv[]) {
  Reset();

    printf("argc = %d\n", argc);
    for (byte i = 0; i < argc; i++) {
      printf("argv [%d] {%s}\n", i, argv[i]);
    }

    if (argc<3) {
      printf("tftp: wants two args\n");
    } else if (StrEq(argv[1], "get")) {
      return Get(argv[2]);
    } else {
      printf("tftp: unknown command\n");
    }
    return 255;
}


#if 0
  char* words[10];
  while (1) {
    char* line = readline();
    if (!line) break;
    printf("<%s>\n", line);
    int count = ny_split(line, words, 10);
    for (byte i = 0; i < count; i++) {
      printf("[%d] {%s}\n", i, words[i]);
    }
    if (count) Command(count, words);
  }
#endif

#if 0
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
#endif


#if 0
void Command(int count, char* w[]) {
  if (w[0][0] == '#') return;  // ignore comment.

  if (!strcmp(w[0], "GET")) {
    if (count != 3) {
      printf("Command `get` expected 2 arguments.\n");
      return;
    }
    printf("okay we will get <%s> <%s>\n", w[1], w[2]);
  } else {
    printf("Unknown command: `%s`\n", w[0]);
  }
}
#endif

