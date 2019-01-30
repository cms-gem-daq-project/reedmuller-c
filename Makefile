# Makefile
#
# By Sebastian Raaphorst, 2002
# ID#: 1256241
#
# $Author: vorpal $
# $Date: 2002/12/09 04:25:43 $

CC=gcc
#CFLAGS=-g3 -ansi -Wall -DDEBUG -DOUTPUTINPUT
CFLAGS=-O0 -g3 -fno-inline -std=c++14 -ansi -Wall

LDFLAGS = -fPIC -shared -lm

TESTS=\
#	testksubset

PROGS=\
	rmencode\
	rmdecode

LIBS=\
	libreedmuller.so

OBJS=\
	matrix.o\
	ksubset.o\
	combination.o\
	vector.o\
	reedmuller.o

all:		$(PROGS) $(LIBS) $(OBJS) $(TESTS)

clean:
		rm -rf *~ $(PROGS) $(OBJS) $(TESTS) $(LIBS)

matrix.o:	matrix.h matrix.c common.h
		$(CC) $(CFLAGS) -o matrix.o -c matrix.c

combination.o:	combination.h combination.c matrix.h common.h
		$(CC) $(CFLAGS) -o combination.o -c combination.c

ksubset.o:	ksubset.h ksubset.c combination.h common.h
		$(CC) $(CFLAGS) -o ksubset.o -c ksubset.c

vector.o:	vector.h vector.c
		$(CC) $(CFLAGS) -o vector.o -c vector.c

reedmuller.o:	reedmuller.h reedmuller.c common.h matrix.h ksubset.h vector.h
		$(CC) $(CFLAGS) -o reedmuller.o -c reedmuller.c

$(LIBS):        $(OBJS)
		$(CC) $(LDFLAGS) -Wl,-soname,$@ -o $@ $^ -L.

testksubset:	testksubset.c common.h $(LIBS)
		$(CC) $(CFLAGS) -o testksubset testksubset.c -L./ -lreedmuller -lm

rmencode:	rmencode.c $(LIBS)
		$(CC) $(CFLAGS) -o rmencode rmencode.c -L./ -lreedmuller -lm

rmdecode:	rmdecode.c $(LIBS)
		$(CC) $(CFLAGS) -o rmdecode rmdecode.c -L./ -lreedmuller -lm

#
# $Log: Makefile,v $
# Revision 1.6  2019/01/30 14:21:43  jsturdy
# Make libreedmuller.so as a shared library
#
# Revision 1.5  2002/12/09 04:25:43  vorpal
# Fixed some glaring errors in reedmuller.c
# Still need to fix problems with decoding; not doing it properly.
#
# Revision 1.4  2002/11/14 21:05:41  vorpal
# Tidied up vector reading, and recompiled without debugging defines.
#
# Revision 1.3  2002/11/14 21:02:34  vorpal
# Fixed bugs in reedmuller.c and added command-line encoding app.
#
# Revision 1.2  2002/11/14 20:28:05  vorpal
# Adding new files to project.
#
# Revision 1.1  2002/11/14 19:10:59  vorpal
# Initial checkin.
#
#
