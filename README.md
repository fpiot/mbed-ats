# ATS programing on mbed [![Build Status](https://travis-ci.org/fpiot/mbed-ats.svg)](https://travis-ci.org/fpiot/mbed-ats)

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
