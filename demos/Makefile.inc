GCC_BIN =
OBJECTS ?= ./main.o
TOPDIR  = ../..
MBEDDIR = $(TOPDIR)/build
SYS_OBJECTS = $(MBEDDIR)/mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM/cmsis_nvic.o $(MBEDDIR)/mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM/system_LPC17xx.o $(MBEDDIR)/mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM/startup_LPC17xx.o $(MBEDDIR)/mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM/board.o $(MBEDDIR)/mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM/retarget.o
INCLUDE_PATHS = -I. -I$(MBEDDIR)/mbed -I$(MBEDDIR)/rtos -I$(MBEDDIR)/net/eth/lwip -I$(MBEDDIR)/net/eth/lwip/include/ipv4 -I$(MBEDDIR)/net/eth/lwip/include -I$(MBEDDIR)/net/eth/lwip-sys
INCLUDE_PATHS += -I$(MBEDDIR)/net/eth/lwip-eth/arch/TARGET_NXP -I$(MBEDDIR)/mbed/TARGET_LPC1768 -I$(MBEDDIR)/mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM -I$(MBEDDIR)/mbed/TARGET_LPC1768/TARGET_NXP -I$(MBEDDIR)/mbed/TARGET_LPC1768/TARGET_NXP/TARGET_LPC176X -I$(MBEDDIR)/mbed/TARGET_LPC1768/TARGET_NXP/TARGET_LPC176X/TARGET_MBED_LPC1768
LIBRARY_PATHS = -L$(MBEDDIR)/mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM 
LIBRARIES = -lmbed 
LINKER_SCRIPT = $(MBEDDIR)/mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM/LPC1768.ld

############################################################################### 
AS      = $(GCC_BIN)arm-none-eabi-as
CC      = $(GCC_BIN)arm-none-eabi-gcc
CPP     = $(GCC_BIN)arm-none-eabi-g++
LD      = $(GCC_BIN)arm-none-eabi-gcc
OBJCOPY = $(GCC_BIN)arm-none-eabi-objcopy
GDB     = $(GCC_BIN)arm-none-eabi-gdb

CPU = -mcpu=cortex-m3 -mthumb
CC_FLAGS = $(CPU) -c -g -fno-common -fmessage-length=0 -Wall -fno-exceptions -ffunction-sections -fdata-sections 
CC_FLAGS += -MMD -MP
CC_SYMBOLS = -DTARGET_LPC1768 -DTARGET_M3 -DTARGET_NXP -DTARGET_LPC176X -DTARGET_MBED_LPC1768 -DTOOLCHAIN_GCC_ARM -DTOOLCHAIN_GCC -D__CORTEX_M3 -DARM_MATH_CM3 -DMBED_BUILD_TIMESTAMP=1399541029.53 -D__MBED__=1 

#LD_FLAGS = -mcpu=cortex-m3 -mthumb -Wl,--gc-sections --specs=nano.specs -u _printf_float -u _scanf_float
LD_FLAGS = -mcpu=cortex-m3 -mthumb -Wl,--gc-sections
LD_SYS_LIBS = -lstdc++ -lsupc++ -lm -lc -lgcc -lnosys

ifeq ($(DEBUG), 1)
  CC_FLAGS += -DDEBUG -O0
else
  CC_FLAGS += -DNDEBUG -Os
endif

all: $(PROJECT).bin

clean:
	rm -f $(PROJECT).bin $(PROJECT).elf $(OBJECTS) $(DEPS) $(CLEANFILES)

.s.o:
	$(AS) $(CPU) -o $@ $<

.c.o:
	$(CC)  $(CC_FLAGS) $(CC_SYMBOLS) -std=gnu99   $(INCLUDE_PATHS) -o $@ $<

.cpp.o:
	$(CPP) $(CC_FLAGS) $(CC_SYMBOLS) -std=gnu++98 $(INCLUDE_PATHS) -o $@ $<


$(PROJECT).elf: $(OBJECTS) $(SYS_OBJECTS)
	$(LD) $(LD_FLAGS) -T$(LINKER_SCRIPT) $(LIBRARY_PATHS) -o $@ $^ $(LIBRARIES) $(LD_SYS_LIBS) $(LIBRARIES) $(LD_SYS_LIBS)

$(PROJECT).bin: $(PROJECT).elf
	$(OBJCOPY) -O binary $< $@

gdbwrite: $(PROJECT).elf
	@echo '#################################################################'
	@echo '##### Use me after running "sudo ./pyOCD/test/gdb_test.py". #####'
	@echo '#################################################################'
	$(GDB) -x $(TOPDIR)/gdbwrite.boot $(PROJECT).elf

gdbattach: all
	@echo '############################################################'
	@echo '##### Use me after running "sudo ./gdbserver4mbed.py". #####'
	@echo '############################################################'
	$(GDB) -x $(TOPDIR)/gdbattach.boot $(PROJECT).elf

DEPS = $(OBJECTS:.o=.d) $(SYS_OBJECTS:.o=.d)
-include $(DEPS)
