#ifndef _FROBIO_FROBIO_H_
#define _FROBIO_FROBIO_H_

#ifndef NYLIB_OMIT_TYPEDEFS
// Fundamental type definitions for using cmoc.
typedef unsigned char bool;
typedef unsigned char byte;
typedef unsigned char error;
typedef unsigned int word;
typedef unsigned long ip4addr;
#define OKAY (error)0
#define NYLIB_OMIT_TYPEDEFS
#endif

#define IP4ADDR(A,B,C,D) (((ip4addr)((A)&255) << 24) | ((ip4addr)((B)&255) << 16) | ((ip4addr)((C)&255) << 8) | (ip4addr)((D)&255) )

struct FrobioConfig {
    ip4addr ip_addr;
    ip4addr ip_mask;
    ip4addr ip_gateway;
    byte ether_mac[6];
};

// Set this true for spammy verbosity.
extern bool wiz_verbose;

// First call wiz_reset, then call wiz_configure.
void wiz_reset(word wiz_ioport);
void wiz_configure(struct FrobioConfig* cf);

// Non-Socket commands return OKAY or error.
error wiz_arp(ip4addr dest_ip);
error wiz_ping(ip4addr dest_ip);

// Socket commands return OKAY or error.
error udp_open(byte socknum, word src_port);
error udp_send(byte socknum, byte* payload, word size, ip4addr dest_ip, word dest_port);
error udp_recv(byte socknum, byte* payload, word* size_in_out, ip4addr* from_addr_out, word* from_port_out);
error udp_close(byte socknum);

// Extra utilities.
void wiz_delay(int n);
void sock_show(byte socknum);

#endif // _FROBIO_FROBIO_H_
