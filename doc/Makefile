# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINXOPTS?=
SPHINXBUILD?=sphinx-build
SOURCEDIR=source
BUILDDIR=build
DOXYREST_PREFIX?=$(CONDA_PREFIX)

.EXPORT_ALL_VARIABLES:

.PHONY: help Makefile
# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: docs
docs: html

.PHONY: doxygen doxyrest
doxygen:
	doxygen reedmuller.cfg

doxyrest: doxygen
	doxyrest -c doxyrest-config.lua

.PHONY: cleandoxygen cleandoxyrest cleanexhale
cleandoxygen:
	rm -rf doxybuild

cleandoxyrest:
	rm -rf source/doxyrest-api

cleanexhale:
	rm -rf exhalebuild
	rm -rf source/exhale-api

.PHONY: clean cleanall
clean:
	rm -rf build

cleanall: clean cleandoxygen cleandoxyrest cleanexhale

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
