/* rmencode.c
 *
 * Command-line Reed-Muller encoding utility.
 *
 * By Sebastian Raaphorst, 2002
 * ID#: 1256241
 *
 * $Author: vorpal $
 * $Date: 2002/12/09 04:06:59 $
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "reedmuller.h"
#include "common.h"
#include <errno.h>
#include <limits.h>

static reedmuller rm = 0;
static int *message  = 0;
static int *codeword = 0;

static void cleanup()
{
  reedmuller_free(rm);
#ifdef CSTYLECALLOC
  free(message);
  free(codeword);
#else
  delete [] message;
  delete [] codeword;
#endif
}


int main(int argc, char *argv[])
{
  int i, j;
  int r, m;

  if (argc < 4) {
    fprintf(stderr, "usage: %s r m message1 [message2 [message3 [...]]]\n",
	    argv[0]);
    exit(EXIT_FAILURE);
  }

  /* try to create the reed-muller code and the vectors */
  r = atoi(argv[1]);
  m = atoi(argv[2]);
  if ((!(rm = reedmuller_init(r, m)))
#ifdef CSTYLECALLOC
      || (!(message  = (int*) calloc(rm->k, sizeof(int))))
      || (!(codeword = (int*) calloc(rm->n, sizeof(int))))
#else
      || (!(message  = new int[rm->k]))
      || (!(codeword = new int[rm->n]))
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

  uint32_t maxcode = reedmuller_maxencode(rm);

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
      fprintf(stderr, "converted value to encode (0x%x) is larger than allowed (%u) for this RM code generator\n", conv, maxcode);
      continue;
    } else {
#ifdef OUTPUTINPUT
      printf("%u 0x%x 0b", conv, conv);
#endif
      for (j=0; j < rm->k; ++j) {
#ifdef OUTPUTINPUT
        printf("%d", ((conv>>(rm->k-j-1)) & 0x1));
#endif
        message[(rm->k-j-1)] = (conv>>j) & 0x1;
      }
    }

#ifdef OUTPUTINPUT
    printf("message 0b");
    for (j=0; j < rm->k; ++j)
      printf("%d", message[j]);
    printf(" -> 0b");
#endif

    /* encode it */
    reedmuller_encode(rm, message, codeword);
    char encoded[1024];
    char* ep = encoded;
    for (j=0; j < rm->n; ++j) {
      printf("%d", codeword[j]);
      ep += sprintf(ep,"%d", codeword[j]);
    }
    printf("\n");

    char *p2;
    errno = 0;

    uint32_t conv2 = strtoul(encoded, &p2, 2);
    if (errno != 0 || *p2 != '\0') {
      fprintf(stderr, "unable to convert argument to int type\n");
      continue;
    }

#ifdef DEBUG
    printf("codeword (address)  = %x\n", codeword );
    printf("message  (address)  = %x\n", message  );
    printf("convert  (address)  = %x\n", &conv    );
    printf("*codeword (encoded) = %x\n", *codeword);
    printf("*message  (encode)  = %x\n", *message );
#endif
#ifdef OUTPUTINPUT
    printf("encode  = 0x%x\n",   conv  );
    printf("encoded = 0x%08x\n", conv2 );
#endif
  }

  cleanup();
  exit(EXIT_SUCCESS);
}


/*
 * $Log: rmencode.c,v $
 * Revision 1.3  2002/12/09 04:06:59  vorpal
 * Added changes to allow for decoding.
 * Still have to write rmdecode.c and test.
 *
 * Revision 1.2  2002/11/14 21:05:41  vorpal
 * Tidied up vector reading, and recompiled without debugging defines.
 *
 * Revision 1.1  2002/11/14 21:02:34  vorpal
 * Fixed bugs in reedmuller.c and added command-line encoding app.
 *
 */
