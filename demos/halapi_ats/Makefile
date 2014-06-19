PROJECT = halapi_ats
CLEANFILES = main.c

include ../Makefile.inc

ATS       = patsopt
ATSCFLAGS = -std=c99 -D_XOPEN_SOURCE -Wno-unused-label -Wno-unused-but-set-variable -Wno-implicit-function-declaration -I. -I${PATSHOME} -I${PATSHOME}/ccomp/runtime
CC_FLAGS += $(ATSCFLAGS)

main.c: main.dats
	$(ATS) -o $@ -d $<
