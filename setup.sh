#!/bin/sh
set -eux

# valid: arm, mipsel, mipseb, mips64eb
ARCH=$1
ABI=

if [ "$ARCH" = "arm" ]; then
ABI=eabi # only for arm
fi

# Firmadyne cross compilers from https://zenodo.org/record/4922202 - arm, mips, mipsel
# works for kernel 4.10
CROSS_CC=/opt/cross/${ARCH}-linux-musl${ABI}/bin/${ARCH}-linux-musl${ABI}-gcc

# Need your own mips64 toolchain or you can grab ours:
#wget --quiet http://panda.re/secret/mips64-linux-musl-cross_gcc-6.5.0.tar.gz -O - | tar -xz -C /opt/cross &&  \
#    mv /opt/cross/mips64-linux-musl-cross /opt/cross/mips64-linux-musl

# this is a mips64 toolchain built using https://github.com/richfelker/musl-cross-make
#BINUTILS_VER = 2.25.1
#GCC_VER = 6.5.0
#MUSL_VER = git-v1.1.24
#GMP_VER = 6.1.0
#MPC_VER = 1.0.3
#MPFR_VER = 3.1.4
#GCC_CONFIG += --enable-languages=c

if [ "$ARCH" = "mips64eb" ]; then
  SHORT_ARCH=mips
  CROSS_CC=/opt/cross/mips64-linux-musl/bin/mips64-linux-musl-gcc
fi



make clean
CC=$CROSS_CC make 

mv console console.$ARCH
