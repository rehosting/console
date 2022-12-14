#!/bin/sh
set -eux

# valid: arm, mipsel, mipseb
ARCH=$1
ABI=

if [ "$ARCH" = "arm" ]; then
ABI=eabi # only for arm
fi

# Firmadyne cross compilers from https://zenodo.org/record/4922202
# works for kernel 4.10
CROSS_CC=/opt/cross/fd/${ARCH}-linux-musl${ABI}/bin/${ARCH}-linux-musl${ABI}-gcc


make clean
CC=$CROSS_CC make 

mv console console.$ARCH
