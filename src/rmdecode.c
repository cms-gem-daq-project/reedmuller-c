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


static int read_vector_from_string(char *str, int elems, int *vector)
{
  int i;

#ifdef OUTPUTINPUT
  printf("vector: ");
#endif
  for (i=0; i < elems; ++i) {
    if (!(*str))
      return FALSE;
    vector[i] = str[i] - '0';
#ifdef OUTPUTINPUT
    printf("vector[%d] %d\n",i, str[i]-'0');
#endif
  }

  return TRUE;
}


static void cleanup()
{
  reedmuller_free(rm);
  free(received);
  free(message);
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
      || (!(received = (int*) calloc(rm->n, sizeof(int))))
      || (!(message  = (int*) calloc(rm->k, sizeof(int))))) {
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
    /* /\* make sure that the message is of the appropriate length *\/ */
    /* if (strlen(argv[i]) != rm->n) { */
    /*   fprintf(stderr, "received %s has invalid length %d (needs %d)\n", */
    /*           argv[i], strlen(argv[i]), rm->n); */
    /*   continue; */
    /* } */

    /* /\* read in the message *\/ */
    /* read_vector_from_string(argv[i], rm->n, received); */

    char *p;
    uint32_t num;
    
    errno = 0;

    unsigned long conv = strtoul(argv[i], &p, 2);
    if (errno != 0 || *p != '\0') {
      errno = 0;
      fprintf(stderr, "unable to convert argument to int type from binary assumption\n");
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
      num = conv;    
      printf("%u 0x%x 0b", num, num);
      for (j=0; j < rm->n; ++j) {
        printf("%d", ((num>>j) &0x1));
        received[(rm->n-j-1)] = (num>>j) &0x1;
      }
    }
#ifdef OUTPUTINPUT
    printf("received 0b");
    for (j=0; j < rm->n; ++j)
      printf("%d", received[j]);
    /* printf(" -> 0b"); */
#endif
    printf(" -> 0b");

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
      uint32_t num2;

      errno = 0;

      unsigned long conv2 = strtoul(decoded, &p2, 2);
      if (errno != 0 || *p2 != '\0') {
        fprintf(stderr, "unable to convert argument to int type\n");
        continue;
      } else {
        num2 = conv2;
      }

#ifdef DEBUG
      printf("codeword (address)  = %x\n", received );
      printf("message  (address)  = %x\n", message  );
      printf("convert  (address)  = %x\n", &num     );
      printf("*codeword (encoded) = %x\n", *received);
      printf("*message  (encode)  = %x\n", *message );
#endif
      printf("decode    = %x\n", num      );
      printf("decoded   = %x\n", num2     );
    } else {
      printf("Unable to decode message 0x%08x, probably more than %d errors\n", *received, reedmuller_strength(rm) );
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
