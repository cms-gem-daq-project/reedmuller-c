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
  free(message);
  free(codeword);
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
      || (!(message  = (int*) calloc(rm->k, sizeof(int))))
      || (!(codeword = (int*) calloc(rm->n, sizeof(int))))) {
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
    /* /\* make sure that the message is of the appropriate length *\/ */
    /* if (strlen(argv[i]) != rm->k) { */
    /*   fprintf(stderr, "message %s has invalid length %d (needs %d)\n", */
    /*           argv[i], strlen(argv[i]), rm->k); */
    /*   continue; */
    /* } */

    /* /\* read in the message *\/ */
    /* read_vector_from_string(argv[i], rm->k, message); */

    char *p;
    uint32_t num;

    errno = 0;
    unsigned long conv = strtoul(argv[i], &p, 2);
    if (errno != 0 || *p != '\0') {
      fprintf(stderr, "unable to convert argument to int type from binary assumption\n");
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
      num = conv;
      printf("%u 0x%x 0b", num, num);
      for (j=0; j < rm->k; ++j) {
        printf("%d", ((num>>j) &0x1));
        message[(rm->k-j-1)] = (num>>j) &0x1;
      }
    }

#ifdef OUTPUTINPUT
    printf("message 0b");
    for (j=0; j < rm->k; ++j)
      printf("%d", message[j]);
    /* printf(" -> 0b"); */
#endif

    printf(" -> 0b");

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
    uint32_t num2;

    errno = 0;

    unsigned long conv2 = strtoul(encoded, &p2, 2);
    if (errno != 0 || *p2 != '\0') {
      fprintf(stderr, "unable to convert argument to int type\n");
      continue;
    } else {
      num2 = conv2;
    }

#ifdef DEBUG
    printf("codeword (address)  = %x\n", codeword );
    printf("message  (address)  = %x\n", message  );
    printf("convert  (address)  = %x\n", &num     );
    printf("*codeword (encoded) = %x\n", *codeword);
    printf("*message  (encode)  = %x\n", *message );
#endif
    printf("encode    = %x\n", num      );
    printf("encoded   = %x\n", num2     );
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
