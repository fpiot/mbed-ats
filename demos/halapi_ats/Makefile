PROJECT     = halapi_ats
DATSFILES   = $(wildcard *.dats) $(wildcard libmbedats/DATS/*.dats)
DATSFILES_C = $(patsubst %.dats,%.c,$(DATSFILES))
OBJECTS     = $(patsubst %.dats,%.o,$(DATSFILES))
CLEANFILES  = $(DATSFILES_C)

include ../Makefile.inc

ATS       = patsopt
ATSCFLAGS = -std=c99 -D_XOPEN_SOURCE -Wno-unused-label -Wno-unused-but-set-variable -Wno-implicit-function-declaration -I. -I${PATSHOME} -I${PATSHOME}/ccomp/runtime # -DATS_MEMALLOC_LIBC
CC_FLAGS += $(ATSCFLAGS)

$(DATSFILES_C): %.c: %.dats
	$(ATS) -o $@ -d $<
