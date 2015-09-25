# ATS programing on mbed [![Build Status](https://travis-ci.org/fpiot/mbed-ats.svg)](https://travis-ci.org/fpiot/mbed-ats)

## Application Design

![](draw/mbed_and_ats.png)

## Hardware: [mbed LPC1768](http://mbed.org/platforms/mbed-LPC1768/)

[![](/img/mbed_LPC1768.jpg)](http://mbed.org/platforms/mbed-LPC1768/)

* CPU: NXP LPC1768 (ARM Cortex-M3 32-bit)
* Flash ROM: 512 KiB
* RAM: 32 KiB

Also you could get [compatible boards](http://mbed.org/platforms/Seeeduino-Arch-Pro/).

## Setup environment

### [Debian GNU/Linux](https://www.debian.org/)

Install summon-arm-toolchain.

```
$ git clone https://github.com/vedderb/summon-arm-toolchain.git
$ apt-get install flex bison libgmp3-dev libmpfr-dev libncurses5-dev \
  libmpc-dev autoconf texinfo build-essential libftdi-dev zlib1g-dev \
  git zlib1g-dev python-yaml
$ cd summon-arm-toolchain/
$ ./summon-arm-toolchain
$ export PATH=$HOME/sat/bin:$PATH
```

### Mac OS X

Install gmp package.

```
$ brew install gmp
```

Install GNU toolchain from ARM Cortex-M & Cortex-R processors https://launchpad.net/gcc-arm-embedded.

```
$ wget https://launchpad.net/gcc-arm-embedded/4.8/4.8-2014-q1-update/+download/gcc-arm-none-eabi-4_8-2014q1-20140314-mac.tar.bz2
$ tar xf gcc-arm-none-eabi-4_8-2014q1-20140314-mac.tar.bz2
$ cp -a gcc-arm-none-eabi-4_8-2014q1 /usr/local/gcc-arm-none-eabi
$ export PATH=$PATH:/usr/local/gcc-arm-none-eabi/bin
$ which arm-none-eabi-gcc
/usr/local/gcc-arm-none-eabi/bin/arm-none-eabi-gcc
```

### Windows

T.B.D.


## How to build

Install ATS2 http://www.ats-lang.org/.

```
$ sudo apt-get install libgmp-dev
$ wget http://downloads.sourceforge.net/project/ats2-lang/ats2-lang/ats2-postiats-0.0.8/ATS2-Postiats-0.0.8.tgz
$ tar xf ATS2-Postiats-0.0.8.tgz
$ cd ATS2-Postiats-0.0.8
$ ./configure
$ make
$ sudo make install
$ export PATSHOME=/usr/local/lib/ats2-postiats-0.0.8
```

Compile the ATS source code for mbed.

```
$ cd mbed-ats
$ make
$ file demos/blink_ats/blink_ats.elf
demos/blink_ats/blink_ats.elf: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, not stripped
```

## Write to the flash

Upgrade firmware. Use rev 141212 or later firmware, to support CMSIS-DAP.
(Detail: http://mbed.org/handbook/Firmware-LPC1768-LPC11U24)

Install pyOCD. (Detail: http://mbed.org/blog/entry/Debugging-from-GDB-using-pyOCD/)

```
$ sudo apt-get install python libusb-1.0-0-dev
$ git clone https://github.com/walac/pyusb.git
$ cd pyusb
$ sudo python setup.py install
$ git clone https://github.com/mbedmicro/pyOCD.git
$ cd pyOCD
$ sudo python setup.py install
```

In one terminal, start the connection to the board.

```
$ sudo python pyOCD/test/gdb_test.py
```

In another terminal, connect to the debugger and flash program.

```
$ cd mbed-ats/demos/blink_ats
$ make gdbwrite
```

## How to debug using gdb

T.B.D.

# === Original README ===

=======
mbed SDK
========

[![Build Status](https://travis-ci.org/mbedmicro/mbed.png)](https://travis-ci.org/mbedmicro/mbed/builds)

The mbed Software Development Kit (SDK) is a C/C++ microcontroller software platform relied upon by tens of thousands of
developers to build projects fast.

The SDK is licensed under the permissive Apache 2.0 licence, so you can use it in both commercial and personal projects
with confidence.

The mbed SDK has been designed to provide enough hardware abstraction to be intuitive and concise, yet powerful enough
to build complex projects. It is built on the low-level ARM CMSIS APIs, allowing you to code down to the metal if needed.
In addition to RTOS, USB and Networking libraries, a cookbook of hundreds of reusable peripheral and module libraries
have been built on top of the SDK by the mbed Developer Community.

Documentation
-------------
* [Tools](http://developer.mbed.org/handbook/mbed-tools): how to setup and use the build system.
* [mbed library internals](http://developer.mbed.org/handbook/mbed-library-internals)
* [Adding a new target microcontroller](http://developer.mbed.org/handbook/mbed-SDK-porting)

Supported Microcontrollers and Boards
-------------------------------------
View all on the [mbed Platforms](https://developer.mbed.org/platforms/) page.

NXP:
* [mbed LPC1768](http://developer.mbed.org/platforms/mbed-LPC1768/) (Cortex-M3)
* [u-blox C027 LPC1768](http://developer.mbed.org/platforms/u-blox-C027/) (Cortex-M3)
* [mbed LPC11U24](http://developer.mbed.org/platforms/mbed-LPC11U24/) (Cortex-M0)
* [EA LPC11U35](http://developer.mbed.org/platforms/EA-LPC11U35/) (Cortex-M0)
* mbed LPC2368 (ARM7TDMI-S)
* LPC2460 (ARM7TDMI-S)
* LPC810 (Cortex-M0+)
* [LPC812](http://developer.mbed.org/platforms/NXP-LPC800-MAX/) (Cortex-M0+)
* [EA LPC4088](http://developer.mbed.org/platforms/EA-LPC4088/) (Cortex-M4F)
* [EA LPC4088 DM](http://developer.mbed.org/platforms/EA-LPC4088-Display-Module/) (Cortex-M4F)
* LPC4330 (Cortex-M4F + Cortex-M0)
* [LPC1347](http://developer.mbed.org/platforms/DipCortex-M3/) (Cortex-M3)
* [LPC1114](http://developer.mbed.org/platforms/LPC1114FN28/) (Cortex-M0)
* LPC11C24 (Cortex-M0)
* [LPC1549](https://developer.mbed.org/platforms/LPCXpresso1549/) (Cortex-M3)
* [LPC800-MAX](https://developer.mbed.org/platforms/NXP-LPC800-MAX/) (Cortex-M0+)
* [DipCortex-M0](https://developer.mbed.org/platforms/DipCortex-M0/) (Cortex-M0)
* [DipCortex-M3](https://developer.mbed.org/platforms/DipCortex-M3/) (Cortex-M3)
* [BlueBoard-LPC11U24](https://developer.mbed.org/platforms/BlueBoard-LPC11U24/) (Cortex-M0)
* LPCCAPPUCCINO (Cortex-M0)
* [Arch](https://developer.mbed.org/platforms/Seeeduino-Arch/) (Cortex-M0)
* [Arch GPRS](https://developer.mbed.org/platforms/Seeed-Arch-GPRS/) (Cortex-M0)
* [Arch Pro](https://developer.mbed.org/platforms/Seeeduino-Arch-Pro/) (Cortex-M3)

Freescale:
* [FRDM-KL05Z](https://developer.mbed.org/platforms/FRDM-KL05Z/) (Cortex-M0+)
* [FRDM-KL25Z](http://developer.mbed.org/platforms/KL25Z/) (Cortex-M0+)
* FRDM-KL43Z (Cortex-M0+)
* [FRDM-KL46Z](https://developer.mbed.org/platforms/FRDM-KL46Z/) (Cortex-M0+)
* [FRDM-K20D50M](https://developer.mbed.org/platforms/FRDM-K20D50M/) (Cortex-M4)
* [FRDM-K22F](https://developer.mbed.org/platforms/FRDM-K22F/) (Cortex-M4F)
* [FRDM-K64F](https://developer.mbed.org/platforms/FRDM-K64F/) (Cortex-M4F)

STMicroelectronics:
* [Nucleo-F030R8](https://developer.mbed.org/platforms/ST-Nucleo-F030R8/) (Cortex-M0)
* [Nucleo-F072RB](https://developer.mbed.org/platforms/ST-Nucleo-F072RB/) (Cortex-M0)
* [Nucleo-L053R8](https://developer.mbed.org/platforms/ST-Nucleo-L053R8/) (Cortex-M0+)
* [Nucleo-F103RB](https://developer.mbed.org/platforms/ST-Nucleo-F103RB/) (Cortex-M3)
* [Nucleo-L152RE](https://developer.mbed.org/platforms/ST-Nucleo-L152RE/) (Cortex-M3)
* [Nucleo-F302R8](https://developer.mbed.org/platforms/ST-Nucleo-F302R8/) (Cortex-M4F)
* [Nucleo-F334R8](https://developer.mbed.org/platforms/ST-Nucleo-F334R8/) (Cortex-M4F)
* [Nucleo-F401RE](https://developer.mbed.org/platforms/ST-Nucleo-F401RE/) (Cortex-M4F)
* [Nucleo-F411RE](https://developer.mbed.org/platforms/ST-Nucleo-F411RE/) (Cortex-M4F)
* STM32F4XX (Cortex-M4F)
* STM32F3XX (Cortex-M4F)
* STM32F0-Discovery (Cortex-M0)
* STM32VL-Discovery (Cortex-M3)
* STM32F3-Discovery (Cortex-M4F)
* STM32F4-Discovery (Cortex-M4F)
* STM32F429-Discovery (Cortex-M4F)
* STM32L0-Discovery (Cortex-M0+)
* [Arch Max](https://developer.mbed.org/platforms/Seeed-Arch-Max/) (Cortex-M4F)


Nordic:
* [nRF51822-mKIT](https://developer.mbed.org/platforms/Nordic-nRF51822/) (Cortex-M0)
* [Arch BLE](https://developer.mbed.org/platforms/Seeed-Arch-BLE/) (Cortex-M0)

Renesas:
* [RZ-A1H](http://developer.mbed.org/platforms/Renesas-GR-PEACH/) (Cortex-A9)

Silicon Labs:
* [EFM32 Zero Gecko] (https://developer.mbed.org/platforms/EFM32-Zero-Gecko/) (Cortex-M0+)
* [EFM32 Happy Gecko] (https://developer.mbed.org/platforms/EFM32-Happy-Gecko/) (Cortex-M0+)
* [EFM32 Leopard Gecko] (https://developer.mbed.org/platforms/EFM32-Leopard-Gecko/) (Cortex-M3)
* [EFM32 Giant Gecko] (https://developer.mbed.org/platforms/EFM32-Giant-Gecko/) (Cortex-M3)
* [EFM32 Wonder Gecko] (https://developer.mbed.org/platforms/EFM32-Wonder-Gecko/) (Cortex-M4)


Supported Toolchains and IDEs
-----------------------------
* GCC ARM: [GNU Tools for ARM Embedded Processors](https://launchpad.net/gcc-arm-embedded/4.7/4.7-2012-q4-major)
* ARMCC (standard library and MicroLib): [uVision](http://www.keil.com/uvision/)
* IAR: [IAR Embedded Workbench](http://www.iar.com/en/Products/IAR-Embedded-Workbench/ARM/)
* GCC code_red: [Red Suite](http://www.code-red-tech.com/)
* GCC CodeSourcery: [Sourcery CodeBench](http://www.mentor.com/embedded-software/codesourcery)
* GCC ARM: [Em::Blocks](http://www.emblocks.org/web/)
* GCC ARM: [CooCox CoIDE](http://www.coocox.org/)

API Documentation
-----------------
* [RTOS API](http://developer.mbed.org/handbook/RTOS)
* [TCP/IP Socket API](http://developer.mbed.org/handbook/Socket) (Transports: Ethernet, WiFi, 3G)
* [USB Device API](http://developer.mbed.org/handbook/USBDevice)
* [USB Host API](http://developer.mbed.org/handbook/USBHost)
* [DSP API](http://developer.mbed.org/users/mbed_official/code/mbed-dsp/docs/tip/)
* Flash File Systems: [SD](http://developer.mbed.org/handbook/SDFileSystem), [USB MSD](http://developer.mbed.org/handbook/USBHostMSD), [semihosted](http://developer.mbed.org/handbook/LocalFileSystem)
* [Peripheral Drivers API](http://developer.mbed.org/handbook/Homepage)

Community
---------
For discussing the development of the mbed SDK itself (Addition/support of microcontrollers/toolchains, build and test system, Hardware Abstraction Layer API, etc) please join our [mbed-devel mailing list](https://groups.google.com/forum/?fromgroups#!forum/mbed-devel).

For every topic regarding the use of the mbed SDK, rather than its development, please post on the [mbed.org forum](http://mbed.org/forum/), or the [mbed.org Q&A](http://mbed.org/questions/).

For reporting issues in the mbed libraries please open a ticket on the issue tracker of the relevant [mbed official library](http://mbed.org/users/mbed_official/code/).
