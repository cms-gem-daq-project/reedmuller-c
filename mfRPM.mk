# ifndef INSTALL_PREFIX
# INSTALL_PREFIX=/opt/reedmuller
# endif

# Can we break this dep? only used for getting the build distribution...
PWD          = $(shell pwd)
BUILD_DATE   = $(shell date -u +"%d%m%Y")
RELEASE      = cmsgem
VERSION      = 1.1.1
GITREV       = $(shell git rev-parse --short HEAD)
GIT_VERSION  = $(shell git describe --dirty --always --tags)
PACKAGER     = $(shell id --user --name)

ifndef BUILD_VERSION
BUILD_VERSION=1
endif

ifndef BUILD_COMPILER
BUILD_COMPILER :=$(shell echo $(CC) | sed -e 's/-/_/g')$(shell $(CC) -dumpversion | sed -e 's/\./_/g')
endif

ifndef BUILD_DISTRIBUTION
BUILD_DISTRIBUTION := $(shell /opt/xdaq/config/checkos.sh)
endif

ifndef PACKAGE_VERSION
PACKAGE_VERSION = $(VERSION)
endif

ifndef PACKAGE_RELEASE
#PACKAGE_RELEASE = $(BUILD_VERSION).$(RELEASE).$(BUILD_COMPILER).$(BUILD_DISTRIBUTION)
PACKAGE_RELEASE = $(BUILD_VERSION).$(RELEASE).$(BUILD_DISTRIBUTION).$(BUILD_COMPILER)
endif

REQUIRES_LIST=0
ifneq ($(REQUIRED_PACKAGE_LIST),)
REQUIRES_LIST=1
endif

BUILD_REQUIRES_LIST=0
ifneq ($(BUILD_REQUIRED_PACKAGE_LIST),)
BUILD_REQUIRES_LIST=1
endif

RPM_OPTIONS=--quiet -ba -bl --rpmfcdebug
ifeq ($(ARCH),arm)
	RPM_OPTIONS=--quiet -ba -bl --define "_binary_payload 1"
endif

.PHONY: rpm
rpm: rpmbuild

.PHONY: rpmbuild
rpmbuild: all spec_update
	mkdir -p $(PackagePath)/rpm/RPMBUILD/{RPMS,SPECS,BUILD,SOURCES,SRPMS}
	rpmbuild $(RPM_OPTIONS) \
	    --define "_release $(PACKAGE_RELEASE).$(BUILD_DISTRIBUTION).$(BUILD_COMPILER)" \
	    --define "_requires $(REQUIRES_LIST)" \
	    --define "_build_requires $(BUILD_REQUIRES_LIST)" \
	    --define  "_topdir $(PWD)/rpm/RPMBUILD" $(PackagePath)/rpm/reedmuller.spec \
	    --target "$(ARCH)"
	find  $(PackagePath)/rpm/RPMBUILD -name "*.rpm" -exec mv {} $(PackagePath)/rpm \;

.PHONY: spec_update rpmprep
spec_update: rpmprep
	$(info "Executing GEM specific spec_update")
	@mkdir -p $(PackagePath)/rpm
	if [ -e $(PackagePath)/reedmuller.spec.template ]; then \
		echo found $(PackagePath)/reedmuller.spec.template; \
		cp $(PackagePath)/reedmuller.spec.template $(PackagePath)/rpm/reedmuller.spec; \
	elif [ -e $(ProjectPath)/reedmuller.spec.template ]; then \
		echo found $(ProjectPath)/reedmuller.spec.template; \
		cp $(ProjectPath)/reedmuller.spec.template $(PackagePath)/rpm/reedmuller.spec; \
	else \
		@echo Error unable to find reedmuller.spec.template; \
		exit 0; \
	fi

	sed -i 's#__builddate__#$(BUILD_DATE)#' $(PackagePath)/rpm/reedmuller.spec
	sed -i 's#__release__#$(PACKAGE_RELEASE)#' $(PackagePath)/rpm/reedmuller.spec
	sed -i 's#__version__#$(PACKAGE_VERSION)#' $(PackagePath)/rpm/reedmuller.spec
	sed -i 's#__author__#$(PACKAGER)#' $(PackagePath)/rpm/reedmuller.spec
	sed -i 's#__gitrev__#$(GITREV)#' $(PackagePath)/rpm/reedmuller.spec
	sed -i 's#__prefix__#$(INSTALL_PREFIX)#' $(PackagePath)/rpm/reedmuller.spec
	sed -i 's#__projectdir__#$(ProjectPath)#' $(PackagePath)/rpm/reedmuller.spec
	sed -i 's#__packagedir__#$(PackagePath)#' $(PackagePath)/rpm/reedmuller.spec
	sed -i 's#__platform__#$(BUILD_DISTRIBUTION)#' $(PackagePath)/rpm/reedmuller.spec
	sed -i 's#__buildarch__#$(ARCH)#' $(PackagePath)/rpm/reedmuller.spec
	sed -i 's#__arch__#$(ARCH)#' $(PackagePath)/rpm/reedmuller.spec
	sed -i 's#__requires__#$(REQUIRED_PACKAGE_LIST)#' $(PackagePath)/rpm/reedmuller.spec
	sed -i 's#__build_requires__#$(BUILD_REQUIRED_PACKAGE_LIST)#' $(PackagePath)/rpm/reedmuller.spec

.PHONY: cleanrpm
cleanrpm:
	-rm -rf $(PackagePath)/rpm
