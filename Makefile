# Makefile
#
# By Sebastian Raaphorst, 2002
# ID#: 1256241
#
# $Author: vorpal $
# $Date: 2002/12/09 04:25:43 $

ifndef PETA_STAGE
$(error "Error: PETA_STAGE environment variable not set, unable to compile for Zynq.")
endif

CXX=arm-linux-gnueabihf-g++
CC=arm-linux-gnueabihf-g++

CFLAGS= -O0 -g3 -fno-inline -std=c++14 -ansi -fPIC -Wall \
	-march=armv7-a -mfpu=neon -mfloat-abi=hard \
	-mthumb-interwork -mtune=cortex-a9 \
	-DEMBED -Dlinux -D__linux__ -Dunix \
	--sysroot=$(PETA_STAGE) \
	-I$(PETA_STAGE)/usr/include \
	-I$(PETA_STAGE)/include

LDLIBS= -L$(PETA_STAGE)/lib \
	-L$(PETA_STAGE)/usr/lib \
	-L$(PETA_STAGE)/ncurses

LDFLAGS = -fPIC -shared $(LDLIBS) -lm

TESTS=\
# $(BIN_DIR)/testksubset

SRC_DIR=src
OBJ_DIR=$(SRC_DIR)/linux
LIB_DIR=lib
INC_DIR=include
BIN_DIR=bin

PROGS= $(BIN_DIR)/rmencode \
	$(BIN_DIR)/rmdecode

LIBS= $(LIB_DIR)/libreedmuller.so

# outputs
INCDIRS= $(INC_DIR:%=-I%)
LIBDIRS = $(LIB_DIR:%=-L%)
SOURCES = $(filter-out $(SRC_DIR)/rm%.c,$(wildcard $(SRC_DIR)/*.c))
XSOURCES= $(filter     $(SRC_DIR)/rm%.c,$(wildcard $(SRC_DIR)/*.c))
AUTODEPS= $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.d,$(SOURCES))
OBJECTS = $(patsubst %.d,%.o,$(AUTODEPS))
LIBRARY = $(LIB_DIR)/libreedmuller.so

LDFLAGS+= $(LIBDIRS)
$(info INC_DIR $(INC_DIR))
$(info SRC_DIR $(SRC_DIR))
$(info OBJ_DIR $(OBJ_DIR))
$(info LIB_DIR $(LIB_DIR))
$(info BIN_DIR $(BIN_DIR))

$(info INCDIRS $(INCDIRS))
$(info LIBDIRS  $(LIBDIRS))
$(info SOURCES  $(SOURCES))
$(info XSOURCES $(XSOURCES))
$(info AUTODEPS $(AUTODEPS))
$(info OBJECTS  $(OBJECTS))
$(info LIBRARY  $(LIBRARY))

# destination path macro we'll use below
df = $(OBJ_DIR)/$(*F)

.PHONY: all clean
all: $(PROGS) $(LIBS) $(OBJECTS) $(TESTS)

default: $(PROGS) $(LIBS) $(OBJECTS)

tests: $(TESTS)

clean:
	rm -rf *~ $(PROGS) $(OBJECTS) $(TESTS) $(LIBS) $(AUTODEPS)

# Main target
$(LIBRARY): $(OBJECTS)
	mkdir -p $(LIB_DIR)
	$(CC) $(LDFLAGS) -Wl,-soname,libreedmuller.so -o $@ $^

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $(INCDIRS) -MT $@ -MMD -MP -MF $(OBJ_DIR)/$*.Td -o $@ $<
	mv $(OBJ_DIR)/$*.Td $(OBJ_DIR)/$*.d
	touch $@

$(OBJ_DIR)/%.d:
.PRECIOUS: $(OBJ_DIR)/%.d

$(BIN_DIR)/%: $(SRC_DIR)/%.c $(LIBS)
	mkdir -p $(BIN_DIR)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< -lreedmuller $(INCDIRS)

# $(BIN_DIR)/testksubset: $(SRC_DIR)/testksubset.c $(LIBS)
# 	mkdir -p $(BIN_DIR)
# 	$(CC) $(CFLAGS) $(LDFLAGS)  -o $@ $< -L$(LIB_DIR) -lreedmuller

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

# include by auto dependencies
-include $(AUTODEPS)

include ./mfRPM.mk
