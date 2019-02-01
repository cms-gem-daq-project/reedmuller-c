INSTALL_PATH = /opt/reedmuller
# Can we break this dep? only used for getting the build distribution...
XDAQ_ROOT    = /opt/xdaq
PWD          = $(shell pwd)
BUILD_DATE   = $(shell date -u +"%d%m%Y")
RELEASE      = cmsgem
VERSION      = 1.0.0

ifndef BUILD_VERSION
BUILD_VERSION=1
endif

ifndef BUILD_DISTRIBUTION
BUILD_DISTRIBUTION := $(shell $(XDAQ_ROOT)/config/checkos.sh)
endif

ifndef PACKAGE_FULL_VERSION
PACKAGE_VERSION = $(VERSION)
endif

ifndef PACKAGE_FULL_RELEASE
PACKAGE_RELEASE = $(BUILD_VERSION).$(RELEASE).$(BUILD_DISTRIBUTION)
endif

REQUIRES_LIST=0
ifneq ($(PACKAGE_REQUIRED_PACKAGE_LIST),)
REQUIRES_LIST=1
endif


.PHONY: spec_update
spec_update:
	$(info "Executing GEM specific spec_update")
	@mkdir -p ./rpm
	if [ -e ./reedmuller.spec.template ]; then \
		echo found reedmuller.spec.template; \
		cp ./reedmuller.spec.template ./rpm/reedmuller.spec; \
        else \
		echo unable to find reedmuller.spec.template; \
                exit 0; \
	fi

	sed -i 's#__builddate__#$(BUILD_DATE)#'        ./rpm/reedmuller.spec
	sed -i 's#__release__#$(PACKAGE_RELEASE)#'     ./rpm/reedmuller.spec
	sed -i 's#__version__#$(PACKAGE_VERSION)#'     ./rpm/reedmuller.spec
	sed -i 's#__prefix__#$(INSTALL_PATH)#'         ./rpm/reedmuller.spec
	sed -i 's#__packagedir__#$(PWD)#'              ./rpm/reedmuller.spec
	sed -i 's#__platform__#$(BUILD_DISTRIBUTION)#' ./rpm/reedmuller.spec

.PHONY: makerpm
makerpm:
	mkdir -p ./rpm/RPMBUILD/{RPMS/$(XDAQ_PLATFORM),SPECS,BUILD,SOURCES,SRPMS}
	rpmbuild  --quiet -ba -bl --define "_requires $(REQUIRES_LIST)" --define  "_topdir $(PWD)/rpm/RPMBUILD" ./rpm/reedmuller.spec
	find  ./rpm/RPMBUILD -name "*.rpm" -exec mv {} ./rpm \;

.PHONY: cleanrpm
cleanrpm:
	-rm -rf ./rpm

.PHONY: rpm
rpm: all spec_update makerpm
