/* rmdecode.c
 *
 * Command-line Reed-Muller decoding utility.
 *
 * By Sebastian Raaphorst, 2002
 * ID#: 1256241
 *
 * $Author: vorpal $
 * $Date: 2002/12/09 04:25:44 $
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "reedmuller.h"
#include "common.h"
#include <errno.h>
#include <limits.h>
#include <memory>
#include <iostream>
#include <iomanip>
#include <sstream>

static reedmuller rm = 0;

#ifndef UNIQUEPTR
static int *received = nullptr;
static int *message  = nullptr;
#else
static std::unique_ptr<int[]> received = nullptr;
static std::unique_ptr<int[]> message  = nullptr;
#endif

static void cleanup()
{
  reedmuller_free(rm);
#ifdef CSTYLECALLOC
  free(received);
  free(message);
#elseif CPPSTYLENEW
  delete [] received;
  delete [] message;
#endif
}


int main(int argc, char *argv[])
{
  int i, j;
  int r, m;

  if (argc < 4) {
    fprintf(stderr, "Usage: %s r m received1 [received2 [received3 [...]]]\n",
	    argv[0]);
    exit(EXIT_FAILURE);
  }

  /* try to create the reed-muller code and the vectors */
  r = atoi(argv[1]);
  m = atoi(argv[2]);
  if ((!(rm = reedmuller_init(r, m)))
#ifdef CSTYLECALLOC
      || (!(received = (int*) calloc(rm->n, sizeof(int))))
      || (!(message  = (int*) calloc(rm->k, sizeof(int))))
#elseif CPPSTYLENEW
      || (!(received = new int[rm->n]))
      || (!(message  = new int[rm->k]))
#else
      || (!(received = std::make_unique<int[]>(rm->n)))
      || (!(message  = std::make_unique<int[]>(rm->k)))
#endif
      ) {
    fprintf(stderr, "Out of memory\n");
    cleanup();
    exit(EXIT_FAILURE);
  }

#ifdef OUTPUTINPUT
  printf("Code parameters for R(%d,%d): n=%d, k=%d\n",
	 rm->r, rm->m, rm->n, rm->k);
  printf("The generator matrix is:\n");
  for (i=0; i < rm->k; ++i) {
    printf("\t");
    for (j=0; j < rm->n; ++j)
      printf("%d ", rm->G[j][i]);
    printf("\n");
  }
  printf("\n");
#endif

  uint32_t maxcode = reedmuller_maxdecode(rm);

  for (i=3; i < argc; ++i) {
    char *p;
    errno = 0;

    std::stringstream conv_b;
    std::stringstream recv_b;

    uint32_t conv = strtoul(argv[i], &p, 2);
    if (errno != 0 || *p != '\0') {
      errno = 0;
      conv = strtoul(argv[i], &p, 0);
      if (errno != 0 || *p != '\0') {
        fprintf(stderr, "Unable to convert argument to int type\n");
        continue;
      }
    }

    if (conv > maxcode) {
      fprintf(stderr, "Converted value to decode (0x%x) is larger than allowed (%u) for this RM code generator\n", conv, maxcode);
      continue;
    } else {
      for (j=0; j < rm->n; ++j) {
        conv_b << ((conv>>(rm->n-j-1)) & 0x1);
#ifdef UNIQUEPTR
        received.get()[(rm->n-j-1)] = (conv>>j) & 0x1;
#else
        received[(rm->n-j-1)] = (conv>>j) & 0x1;
#endif
      }
#ifdef OUTPUTINPUT
      printf("%u 0x%x 0b%s\n", conv, conv, conv_b.str().c_str());
#endif
    }

    for (j=0; j < rm->n; ++j)
#ifdef UNIQUEPTR
      recv_b << received.get()[j];
#else
      recv_b << received[j];
#endif

#ifdef OUTPUTINPUT
    printf("received 0b%s",recv_b.str().c_str());
    printf(" -> 0b");
#endif

    /* decode it */
#ifdef UNIQUEPTR
    int result = reedmuller_decode(rm, received.get(), message.get());
#else
    int result = reedmuller_decode(rm, received, message);
#endif

    if (result) {
      char decoded[1024];
      char* dp = decoded;

      std::stringstream dec_b;
      int v = 0;
      for (j=0; j < rm->k; ++j) {
#ifdef UNIQUEPTR
        v = message.get()[j];
#else
        v = message[j];
#endif
        dec_b << v;
        dp += sprintf(dp,"%d", v);
      }

      char *p2;
      errno = 0;

      uint32_t conv2 = strtoul(decoded, &p2, 2);
      if (errno != 0 || *p2 != '\0') {
        fprintf(stderr, "Unable to convert argument to int type\n");
        continue;
      }
      printf("%s 0x%x (%u)\n",dec_b.str().c_str(),conv2,conv2);

#ifdef DEBUG
      printf("codeword (address)  = %x\n", received );
      printf("message  (address)  = %x\n", message  );
      printf("convert  (address)  = %x\n", &conv    );
#ifdef UNIQUEPTR
      printf("*codeword (encoded) = %x\n", *(received.get()));
      printf("*message  (encode)  = %x\n", *(message.get()) );
#else
      printf("*codeword (encoded) = %x\n", *received);
      printf("*message  (encode)  = %x\n", *message );
#endif
#endif
#ifdef OUTPUTINPUT
      printf("decode  = 0x%08x\n", conv  );
      printf("decoded = 0x%x\n",   conv2 );
#endif
    } else {
#ifdef UNIQUEPTR
      printf("Unable to decode message 0x%08x, probably more than %d errors\n", *(received.get()), reedmuller_strength(rm) );
#else
      printf("Unable to decode message 0x%08x, probably more than %d errors\n", *received, reedmuller_strength(rm) );
#endif
      cleanup();
      exit(EXIT_FAILURE);
    }
  }

  cleanup();
  exit(EXIT_SUCCESS);
}


/*
 * $Log: rmdecode.c,v $
 * Revision 1.1  2002/12/09 04:25:44  vorpal
 * Fixed some glaring errors in reedmuller.c
 * Still need to fix problems with decoding; not doing it properly.
 *
 */
