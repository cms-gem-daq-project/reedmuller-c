SUBPACKAGES := \
	rmarm \
        rmcore

SUBPACKAGES.DEBUG    := $(patsubst %,%.debug,    $(SUBPACKAGES))
SUBPACKAGES.RPM      := $(patsubst %,%.rpm,      $(SUBPACKAGES))
SUBPACKAGES.DOC      := $(patsubst %,%.doc,      $(SUBPACKAGES))
SUBPACKAGES.CLEANRPM := $(patsubst %,%.cleanrpm, $(SUBPACKAGES))
SUBPACKAGES.CLEANDOC := $(patsubst %,%.cleandoc, $(SUBPACKAGES))
SUBPACKAGES.CLEAN    := $(patsubst %,%.clean,    $(SUBPACKAGES))

ProjectPath := $(shell pwd)
export ProjectPath

.PHONY: build clean cleanall cleandoc cleanrpm

build: $(SUBPACKAGES)

all: $(SUBPACKAGES) $(SUBPACKAGES.RPM) $(SUBPACKAGES.DOC)

rpm: $(SUBPACKAGES) $(SUBPACKAGES.RPM)

doc: $(SUBPACKAGES.DOC)

cleanrpm: $(SUBPACKAGES.CLEANRPM)

cleandoc: $(SUBPACKAGES.CLEANDOC)

clean: $(SUBPACKAGES.CLEAN)

cleanall: clean cleandoc cleanrpm

$(SUBPACKAGES):
	$(MAKE) -C $@

$(SUBPACKAGES.RPM): $(SUBPACKAGES)
	$(MAKE) -C $(patsubst %.rpm,%, $@) rpm

$(SUBPACKAGES.DOC):
	$(MAKE) -C $(patsubst %.doc,%, $@) doc

$(SUBPACKAGES.CLEANRPM):
	$(MAKE) -C $(patsubst %.cleanrpm,%, $@) cleanrpm

$(SUBPACKAGES.CLEANDOC):
	$(MAKE) -C $(patsubst %.cleandoc,%, $@) cleandoc

$(SUBPACKAGES.CLEAN):
	$(MAKE) -C $(patsubst %.clean,%, $@) clean

.PHONY: $(SUBPACKAGES) \
	$(SUBPACKAGES.INSTALL) \
	$(SUBPACKAGES.CLEAN) \
	$(SUBPACKAGES.DOC) \
	$(SUBPACKAGES.RPM) \
	$(SUBPACKAGES.CLEANRPM) \
	$(SUBPACKAGES.CLEANDOC)

python:

rmarm:

rmcore:

rmcore.RPM: rmarm

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
