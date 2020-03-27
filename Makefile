TARGETS := arm x86_64

TARGETS.RPM        := $(patsubst %,%.rpm,         $(TARGETS))
TARGETS.CLEAN      := $(patsubst %,%.clean,       $(TARGETS))
TARGETS.CLEANRPM   := $(patsubst %,%.cleanrpm,    $(TARGETS))
TARGETS.CLEANALLRPM:= $(patsubst %,%.cleanallrpm, $(TARGETS))
TARGETS.CLEANALL   := $(patsubst %,%.cleanall,    $(TARGETS))
TARGETS.CHECKABI   := $(patsubst %,%.checkabi,    $(TARGETS))
TARGETS.INSTALL    := $(patsubst %,%.install,     $(TARGETS))
TARGETS.UNINSTALL  := $(patsubst %,%.uninstall,   $(TARGETS))
TARGETS.RELEASE    := $(patsubst %,%.release,     $(TARGETS))

.PHONY: $(TARGETS) \
	$(TARGETS.RPM) \
	$(TARGETS.CLEAN) \
	$(TARGETS.CLEANRPM) \
	$(TARGETS.CLEANALLRPM) \
	$(TARGETS.CLEANALL) \
	$(TARGETS.CHECKABI) \
	$(TARGETS.INSTALL) \
	$(TARGETS.UNINSTALL) \
	$(TARGETS.RELEASE)

ProjectPath := $(shell pwd)
export ProjectPath

.PHONY: all build default install uninstall rpm release
.PHONY: clean cleanrpm cleanallrpm cleanall

default: all

build: $(TARGETS)

all: $(TARGETS) doc

rpm: $(TARGETS) $(TARGETS.RPM)

clean: $(TARGETS.CLEAN)

cleanall: $(TARGETS.CLEANALL) cleandoc

cleanrpm: $(TARGETS.CLEANRPM)

cleanallrpm: $(TARGETS.CLEANALLRPM)

checkabi: $(TARGETS.CHECKABI)

install: $(TARGETS.INSTALL)

uninstall: $(TARGETS.UNINSTALL)

release: $(TARGETS.RELEASE)

$(TARGETS):
	TargetArch=$@ $(MAKE) -f reedmuller.mk

$(TARGETS.RPM): $(TARGETS)
	TargetArch=$(patsubst %.rpm,%,$@) $(MAKE) -f reedmuller.mk rpm

$(TARGETS.CLEAN):
	TargetArch=$(patsubst %.clean,%,$@) $(MAKE) -f reedmuller.mk clean

$(TARGETS.CLEANRPM):
	TargetArch=$(patsubst %.cleanrpm,%,$@) $(MAKE) -f reedmuller.mk cleanrpm

$(TARGETS.CLEANALLRPM):
	TargetArch=$(patsubst %.cleanallrpm,%,$@) $(MAKE) -f reedmuller.mk cleanallrpm

$(TARGETS.CLEANALL):
	TargetArch=$(patsubst %.cleanall,%,$@) $(MAKE) -f reedmuller.mk cleanall

$(TARGETS.CHECKABI):
	TargetArch=$(patsubst %.checkabi,%,$@) $(MAKE) -f reedmuller.mk checkabi

$(TARGETS.INSTALL): $(TARGETS)
	TargetArch=$(patsubst %.install,%,$@) $(MAKE) -f reedmuller.mk install

$(TARGETS.UNINSTALL):
	TargetArch=$(patsubst %.uninstall,%,$@) $(MAKE) -f reedmuller.mk uninstall

$(TARGETS.RELEASE):
	TargetArch=$(patsubst %.release,%,$@) $(MAKE) -f reedmuller.mk release

#python:

.PHONY: doc cleandoc
doc:
	$(MAKE) -C $@ docs

cleandoc:
	$(MAKE) -C doc cleanall

x86_64:

arm:

ctp7:

bcp:

apx:

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
