/*
https://stuff.mit.edu/afs/athena/contrib/crypto/src/ssh-1.2.27/arcfour.h

ARCFOUR cipher (based on a cipher posted on the Usenet in Spring-95).
This cipher is widely believed and has been tested to be equivalent
with the RC4 cipher from RSA Data Security, Inc.  (RC4 is a trademark
of RSA Data Security)

*/

/*
 * $Id: ssh-arcfour.h,v 1.1 2022/11/06 03:20:41 strick Exp $
 * $Log: ssh-arcfour.h,v $
 * Revision 1.1  2022/11/06 03:20:41  strick
 * /dev/null
 *
 * Revision 1.1  2022/02/09 18:03:37  strick
 * /dev/null
 *
 * Revision 1.1.1.1  1996/02/18 21:38:11  ylo
 * 	Imported ssh-1.2.13.
 *
 * Revision 1.2  1995/07/13  01:30:25  ylo
 * 	Added cvs log.
 *
 * $Endlog$
 */

#ifndef ARCFOUR_H
#define ARCFOUR_H

typedef struct
{
   unsigned int x;
   unsigned int y;
   unsigned char state[256];
} ArcfourContext;

/* Initializes the context and sets the key. */
void arcfour_init(ArcfourContext *ctx, const unsigned char *key, 
		  unsigned int keylen);

/* Returns the next pseudo-random byte from the arcfour (pseudo-random 
   generator) stream. */
unsigned int arcfour_byte(ArcfourContext *ctx);

/* Encrypts data. */
void arcfour_encrypt(ArcfourContext *ctx, unsigned char *dest, 
		     const unsigned char *src, unsigned int len);

/* Decrypts data. */
void arcfour_decrypt(ArcfourContext *ctx, unsigned char *dest, 
		     const unsigned char *src, unsigned int len);

#endif /* ARCFOUR_H */
