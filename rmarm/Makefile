# Makefile
#
# By Sebastian Raaphorst, 2002
# ID#: 1256241
#
# $Author: vorpal $
# $Date: 2002/12/09 04:25:43 $

PackagePath := $(shell pwd)
ProjectPath := $(PackagePath)/..

## -DDEBUG: 
## -DOUTPUTINPUT: 
## -DCSTYLECALLOC: use calloc instead of new []
## -DCPPSTYLENEW: use new [] instead of calloc
## -DUNIQUEPTR: use std::unique_ptr<int[]> instead of int*
# CFLAGS=-g3 -ansi -Wall -DDEBUG -DOUTPUTINPUT -DCSTYLECALLOC -DCPPSTYLENEW -DUNIQUEPTR
CFLAGS:=-O0 -g3 -fno-inline -fPIC -Wall -DDEBUG -DCPPSTYLENEW
CXXFLAGS:=$(CFLAGS)

ifndef PETA_STAGE
$(error PETA_STAGE environment variable not set, unable to compile for Zynq.)
endif

CXX=arm-linux-gnueabihf-g++
CC=arm-linux-gnueabihf-gcc

CFLAGS+= -march=armv7-a -mfpu=neon -mfloat-abi=hard \
	-mthumb-interwork -mtune=cortex-a9 \
	-DEMBED -Dlinux -D__linux__ -Dunix \
	--sysroot=$(PETA_STAGE) \
	-I$(PETA_STAGE)/usr/include \
	-I$(PETA_STAGE)/include

ARCH=arm
INSTALL_PREFIX=/mnt/persistent/gemdaq
BUILD_DISTRIBUTION=peta
LDLIBS= -L$(PETA_STAGE)/lib \
	-L$(PETA_STAGE)/usr/lib \
	-L$(PETA_STAGE)/ncurses
CCFLAGS+=-std=c11
CXXFLAGS+=-std=c++14

LDFLAGS = -fPIC $(LDLIBS) -lm

TESTS=\
# $(BIN_DIR)/testksubset

SRC_DIR=$(ProjectPath)/src
INC_DIR=$(ProjectPath)/include
OBJ_DIR=obj
LIB_DIR=lib
BIN_DIR=bin

PROGS= $(BIN_DIR)/rmencode \
	$(BIN_DIR)/rmdecode

LIBS= $(LIB_DIR)/libreedmuller.so

# outputs
INCDIRS = $(INC_DIR:%=-I%)
LIBDIRS = $(LIB_DIR:%=-L%)
SOURCES = $(filter-out $(SRC_DIR)/rm%.c,$(wildcard $(SRC_DIR)/*.c))
XSOURCES= $(filter     $(SRC_DIR)/rm%.c,$(wildcard $(SRC_DIR)/*.c))
AUTODEPS= $(patsubst   $(SRC_DIR)/%.c,$(OBJ_DIR)/%.d,$(SOURCES))
OBJECTS = $(patsubst %.d,%.o,$(AUTODEPS))
LIBRARY = $(LIB_DIR)/libreedmuller.so

LDFLAGS+= $(LIBDIRS)

# destination path macro we'll use below
df = $(OBJ_DIR)/$(*F)

.PHONY: all clean
all: $(PROGS) $(LIBS) $(OBJECTS) $(TESTS)

default: $(PROGS) $(LIBS) $(OBJECTS)

tests: $(TESTS)

clean:
	rm -rf $(OBJ_DIR) $(LIB_DIR) $(BIN_DIR)

# Main target
$(LIBRARY): $(OBJECTS)
	mkdir -p $(LIB_DIR)
	$(CXX) $(LDFLAGS) -shared -Wl,-soname,libreedmuller.so -o $@ $^

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	mkdir -p $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $(INCDIRS) -MT $@ -MMD -MP -MF $(OBJ_DIR)/$*.Td -o $@ $<
	mv $(OBJ_DIR)/$*.Td $(OBJ_DIR)/$*.d
	touch $@

$(OBJ_DIR)/%.d:
.PRECIOUS: $(OBJ_DIR)/%.d

$(BIN_DIR)/%: $(SRC_DIR)/%.c $(LIBS)
	mkdir -p $(BIN_DIR)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $< -lreedmuller $(INCDIRS)

# $(BIN_DIR)/testksubset: $(SRC_DIR)/testksubset.c $(LIBS)
# 	mkdir -p $(BIN_DIR)
# 	$(CXX) $(CXXFLAGS) $(LDFLAGS)  -o $@ $< -L$(LIB_DIR) -lreedmuller

#
# $Log: Makefile,v $
# Revision 1.7  2019/02/27 14:21:43  jsturdy
# Adapt for building on Zynq (for CTP7 card) as well as CERN centos7 machine
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

print-env:
	@echo ProjectPath    $(ProjectPath)
	@echo PackagePath    $(PackagePath)
	@echo PETA_STAGE     $(PETA_STAGE)
	@echo CC             $(CC)
	@echo CXX            $(CXX)
	@echo CFLAGS         $(CFLAGS)
	@echo CXXFLAGS       $(CXXFLAGS)
	@echo ARCH           $(ARCH)
	@echo LDFLAGS        $(LDFLAGS)
	@echo INSTALL_PREFIX $(INSTALL_PREFIX)

# include by auto dependencies
-include $(AUTODEPS)

include $(ProjectPath)/mfRPM.mk
