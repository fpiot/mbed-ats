SUBDIRS         = $(wildcard demos/*_ats)
LIBMBED_LPC1768 = build/mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM/libmbed.a
BUILDPY_FLAG    = -m LPC1768 -t GCC_ARM

ODGS := $(wildcard draw/*.odg)
PNGS := $(patsubst %.odg,%.png,${ODGS})

all: $(LIBMBED_LPC1768)
	@for i in $(SUBDIRS); do \
		$(MAKE) -C $$i $@; \
	done

$(LIBMBED_LPC1768):
	python workspace_tools/build.py $(BUILDPY_FLAG) --rtos --eth --usb_host --usb

clean:
	@for i in $(SUBDIRS); do \
		$(MAKE) -C $$i $@; \
	done
	rm -rf build

%.png: %.odg
	unoconv -n -f png -o $@.tmp $< 2> /dev/null   || \
          unoconv -f png -o $@.tmp $<                 || \
	  unoconv -n -f png -o $@.tmp $< 2> /dev/null || \
          unoconv -f png -o $@.tmp $<
	convert -resize 600x $@.tmp $@
	rm -f $@.tmp

updatefig: $(PNGS)

.PHONY: all clean updatefig
