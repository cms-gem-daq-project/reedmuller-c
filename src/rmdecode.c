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

static reedmuller rm = 0;
static int *received = 0;
static int *message  = 0;

static void cleanup()
{
  reedmuller_free(rm);
#ifdef CSTYLECALLOC
  free(received);
  free(message);
#else
  delete [] received;
  delete [] message;
#endif
}


int main(int argc, char *argv[])
{
  int i, j;
  int r, m;

  if (argc < 4) {
    fprintf(stderr, "usage: %s r m received1 [received2 [received3 [...]]]\n",
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
#else
      || (!(received = new int[rm->n]))
      || (!(message  = new int[rm->k]))
#endif
      ) {
    fprintf(stderr, "out of memory\n");
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

    uint32_t conv = strtoul(argv[i], &p, 2);
    if (errno != 0 || *p != '\0') {
      errno = 0;
      conv = strtoul(argv[i], &p, 0);
      if (errno != 0 || *p != '\0') {
        fprintf(stderr, "unable to convert argument to int type\n");
        continue;
      }
    }

    if (conv > maxcode) {
      fprintf(stderr, "converted value to decode (0x%x) is larger than allowed (%u) for this RM code generator\n", conv, maxcode);
      continue;
    } else {
#ifdef OUTPUTINPUT
      printf("%u 0x%x 0b", conv, conv);
#endif
      for (j=0; j < rm->n; ++j) {
#ifdef OUTPUTINPUT
        printf("%d", ((conv>>(rm->n-j-1)) & 0x1));
#endif
        received[(rm->n-j-1)] = (conv>>j) & 0x1;
      }
    }
#ifdef OUTPUTINPUT
    printf("received 0b");
    for (j=0; j < rm->n; ++j)
      printf("%d", received[j]);
    printf(" -> 0b");
#endif

    /* decode it */
    int result = reedmuller_decode(rm, received, message);

    if (result) {
      char decoded[1024];
      char* dp = decoded;

      for (j=0; j < rm->k; ++j) {
        printf("%d", message[j]);
        dp += sprintf(dp,"%d", message[j]);
      }
      printf("\n");

      char *p2;
      errno = 0;

      uint32_t conv2 = strtoul(decoded, &p2, 2);
      if (errno != 0 || *p2 != '\0') {
        fprintf(stderr, "unable to convert argument to int type\n");
        continue;
      }

#ifdef DEBUG
      printf("codeword (address)  = %x\n", received );
      printf("message  (address)  = %x\n", message  );
      printf("convert  (address)  = %x\n", &conv    );
      printf("*codeword (encoded) = %x\n", *received);
      printf("*message  (encode)  = %x\n", *message );
#endif
#ifdef OUTPUTINPUT
      printf("decode  = 0x%08x\n", conv  );
      printf("decoded = 0x%x\n",   conv2 );
#endif
    } else {
      printf("Unable to decode message 0x%08x, probably more than %d errors\n", *received, reedmuller_strength(rm) );
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
