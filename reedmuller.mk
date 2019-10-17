# Makefile
#
# By Sebastian Raaphorst, 2002
# ID#: 1256241
#
# $Author: vorpal $
# $Date: 2002/12/09 04:25:43 $

BUILD_HOME   := $(shell dirname `pwd`)
Project      := reedmuller-c
Package      := reedmuller
ShortPackage := reedmuller
LongPackage  := $(TargetArch)
PackageName  := $(ShortPackage)
PackagePath  := $(TargetArch)
PackageDir   := pkg/$(Project)
Packager     := Jared Sturdy
Arch         := $(TargetArch)

ProjectPath:=$(BUILD_HOME)/$(Project)

ConfigDir:=$(ProjectPath)/config

include $(ConfigDir)/mfCommonDefs.mk

ifeq ($(Arch),x86_64)
include $(ConfigDir)/mfPythonDefs.mk
CFLAGS=-Wall -pthread -fPIC
CXXFLAGS:=-std=c++11
ADDFLAGS=-std=c++11 -std=gnu++11 -m64
#INSTALL_PATH=/opt/reedmuller
else
include $(ConfigDir)/mfZynq.mk
#INSTALL_PATH=/mnt/persistent/gemdaq
CXXFLAGS:=-std=c++14
ADDFLAGS=-std=gnu++14
endif

## -DDEBUG:
## -DOUTPUTINPUT:
## -DCSTYLECALLOC: use calloc instead of new []
## -DCPPSTYLENEW: use new [] instead of calloc
## -DUNIQUEPTR: use std::unique_ptr<int[]> instead of int*

CFLAGS+=-DCSTYLENEW
CXXFLAGS+=$(CFLAGS)
# CFLAGS+=-ansi
CFLAGS+=-std=c11

ADDFLAGS+=$(OPTFLAGS)

PackageSourceDir:=src
PackageIncludeDir:=include
PackageObjectDir:=$(PackagePath)/obj/linux/$(Arch)
PackageLibraryDir:=$(PackagePath)/lib
PackageExecDir:=$(PackagePath)/bin
PackageDocsDir:=$(PackagePath)/doc/_build/html

REEDMULLER_VER_MAJOR:=$(shell $(ConfigDir)/tag2rel.sh | awk '{split($$0,a," "); print a[1];}' | awk '{split($$0,b,":"); print b[2];}')
REEDMULLER_VER_MINOR:=$(shell $(ConfigDir)/tag2rel.sh | awk '{split($$0,a," "); print a[2];}' | awk '{split($$0,b,":"); print b[2];}')
REEDMULLER_VER_PATCH:=$(shell $(ConfigDir)/tag2rel.sh | awk '{split($$0,a," "); print a[3];}' | awk '{split($$0,b,":"); print b[2];}')

IncludeDirs = $(PackageIncludeDir)
INC=$(IncludeDirs:%=-I%)

LibraryDirs = $(PackageLibraryDir:%=-L%)

TESTS=\
# $(PackageExecDir)/testksubset

PROGS= $(PackageExecDir)/rmencode \
	$(PackageExecDir)/rmdecode

LIBS= $(PackageLibraryDir)/libreedmuller.so

# outputs
SOURCES = $(filter-out $(PackageSourceDir)/rm%.c,$(wildcard $(PackageSourceDir)/*.c))
XSOURCES= $(filter     $(PackageSourceDir)/rm%.c,$(wildcard $(PackageSourceDir)/*.c))
AUTODEPS= $(patsubst   $(PackageSourceDir)/%.c,$(PackageObjectDir)/%.d,$(SOURCES))
OBJECTS = $(patsubst %.d,%.o,$(AUTODEPS))
LIBRARY = $(PackageLibraryDir)/libreedmuller.so

LDFLAGS+=-lm
LDFLAGS+=-shared $(LibraryDirs)

## Override the RPM_DIR variable because we're a special case
RPM_DIR:=$(ProjectPath)/$(LongPackage)/rpm
include $(ConfigDir)/mfRPMRules.mk

$(PackageSpecFile): $(ProjectPath)/spec.template

specificspecupdate: $(PackageSpecFile)
	echo Running specific spec update

# destination path macro we'll use below
df = $(PackageObjectDir)/$(*F)

.PHONY: all clean default
default: all

## @reedmuller Compile all target objects
all: $(PROGS) $(LIBS) $(OBJECTS) $(TESTS)

## @reedmuller Compile all test executables
tests: $(TESTS)

clean:
	rm -rf $(PackageObjectDir) $(PackageLibraryDir) $(PackageExecDir)

## @reedmuller Prepare the package for building the RPM
rpmprep: default

# Define as dependency everything that should cause a rebuild
TarballDependencies = $(LIBRARY) $(PROGS) Makefile reedmuller.mk spec.template

$(PackageSourceTarball): $(TarballDependencies)
	$(MakeDir) $(PackagePath)/$(PackageDir)
ifeq ($(Arch),x86_64)
	echo nothing to do
else
	$(MakeDir) $(PackagePath)/$(PackageDir)/gem-peta-stage/ctp7/$(INSTALL_PATH)/lib
	@cp -rfp $(PackageLibraryDir)/* $(PackagePath)/$(PackageDir)/gem-peta-stage/ctp7/$(INSTALL_PATH)/lib
endif
	$(MakeDir) $(RPM_DIR)
	@cp -rfp spec.template $(PackagePath)
	$(MakeDir) $(PackagePath)/$(PackageDir)/$(LongPackage)
	@cp -rfp --parents $(PackageObjectDir) $(PackagePath)/$(PackageDir)
	@cp -rfp --parents $(PackageLibraryDir) $(PackagePath)/$(PackageDir)
	-cp -rfp --parents $(PackageExecDir) $(PackagePath)/$(PackageDir)
	@cp -rfp $(PackageSourceDir) $(PackagePath)/$(PackageDir)
	@cp -rfp $(PackageIncludeDir) $(PackagePath)/$(PackageDir)
	@cp -rfp reedmuller.mk $(PackagePath)/$(PackageDir)/Makefile
	@cp -rfp $(ProjectPath)/config $(PackagePath)/$(PackageDir)
#	cd $(ProjectPath); cp -rfp --parents xhal/Makefile $(PackagePath)/$(PackageDir)
#	cd $(ProjectPath); cp -rfp --parents xhal/{include,src} $(PackagePath)/$(PackageDir)
	cd $(PackagePath)/$(PackageDir)/..; \
	    tar cjf $(PackageSourceTarball) . ;
#	$(RM) $(PackagePath)/$(PackageDir)

# Main target
$(LIBRARY): $(OBJECTS)
	$(MakeDir) $(@D)
	$(CXX) $(LDFLAGS) -o $(@D)/$(LibraryFull) $^
	$(link-sonames)

$(PackageObjectDir)/%.o: $(PackageSourceDir)/%.c
	$(MakeDir) $(@D)
	$(CXX) $(CXXFLAGS) $(ADDFLAGS) $(INC) -c -MT $@ -MMD -MP -MF $(PackageObjectDir)/$*.Td -o $@ $<
	mv $(@D)/$(*F).Td $(@D)/$(*F).d
#	mv $(PackageObjectDir)/$*.Td $(PackageObjectDir)/$*.d
	touch $@

$(PackageObjectDir)/%.d:
.PRECIOUS: $(PackageObjectDir)/%.d

$(PackageExecDir)/%: $(PackageSourceDir)/%.c $(LIBS)
	$(MakeDir) $(@D)
	$(CXX) $(CXXFLAGS) $(ADDFLAGS) $(INC) $(LDFLAGS) -o $@ $< -lreedmuller

# $(PackageExecDir)/testksubset: $(PackageSourceDir)/testksubset.c $(LIBS)
# 	mkdir -p $(PackageExecDir)
# 	$(CXX) $(CXXFLAGS) $(ADDFLAGS) $(LDFLAGS)  -o $@ $< -L$(PackageLibraryDir) -lreedmuller

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
	@echo ProjectPath  $(ProjectPath)
	@echo PackagePath  $(PackagePath)
	@echo PETA_STAGE   $(PETA_STAGE)
	@echo CC           $(CC)
	@echo CXX          $(CXX)
	@echo CFLAGS       $(CFLAGS)
	@echo CXXFLAGS     $(CXXFLAGS)
	@echo LDFLAGS      $(LDFLAGS)
	@echo INSTALL_PATH $(INSTALL_PATH)

# include by auto dependencies
-include $(AUTODEPS)

#include $(ProjectPath)/mfRPM.mk
