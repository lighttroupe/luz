#
# Makefile to build the C++ helper apps
#
# See README file for dependencies
#

DIRS = input-manager spectrum-analyzer

all:
	for dir in $(DIRS); do make -C $$dir $@; done
