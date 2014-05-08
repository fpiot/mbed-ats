SUBDIRS         = demos/blink demos/blink_ats
LIBMBED_LPC1768 = build/mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM/libmbed.a
BUILDPY_FLAG    = -m LPC1768 -t GCC_ARM

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

.PHONY: all clean
