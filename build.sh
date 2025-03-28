#!/bin/bash
TARGETLIST=(x86_64-linux-gnu i686-linux-musl mipseb-linux-musl mipsel-linux-musl arm-linux-musleabi aarch64-linux-musl mips64eb-linux-musl mips64el-linux-musl  powerpc-linux-musl powerpcle-linux-musl powerpc64-linux-musl powerpc64le-linux-musl riscv32-linux-musl riscv64-linux-musl loongarch64-unknown-linux-gnu)

BUILDDIR=build
mkdir -p $BUILDDIR
echo "Built by $(whoami) on $HOSTNAME at `date`" > $BUILDDIR/buildinfo.txt

for TARGET in "${TARGETLIST[@]}"; do
    echo "Building for $TARGET"
    CC=$TARGET-gcc ARCH=$TARGET BUILD=$BUILDDIR make -j`nproc` all
done

OUT=console
mkdir -p $OUT

for x in $BUILDDIR/console-*; do
  ARCH=$(basename $x | cut -d- -f2-)
  case $ARCH in
    x86_64-linux-gnu)
      ARCH_DIR="x86_64"
      ;;
    i686-linux-musl)
      ARCH_DIR="x86"
      ;;
    arm-linux-musleabi)
      ARCH_DIR="armel"
      ;;
    aarch64-linux-musl)
      ARCH_DIR="aarch64"
      ;;
    mipsel-linux-musl)
      ARCH_DIR="mipsel"
      ;;
    mipseb-linux-musl)
      ARCH_DIR="mipseb"
      ;;
    mips64eb-linux-musl)
      ARCH_DIR="mips64eb"
      ;;
    mips64el-linux-musl)
      ARCH_DIR="mips64el"
      ;;
    powerpc-linux-musl)
      ARCH_DIR="powerpc"
      ;;
    powerpcle-linux-musl)
      ARCH_DIR="powerpcle"
      ;;
    powerpc64-linux-musl)
      ARCH_DIR="powerpc64"
      ;;
    powerpc64le-linux-musl)
      ARCH_DIR="powerpc64le"
      ;;
    riscv32-linux-musl)
      ARCH_DIR="riscv32"
      ;;
    riscv64-linux-musl)
      ARCH_DIR="riscv64"
      ;;
    loongarch64-unknown-linux-gnu)
      ARCH_DIR="loongarch64"
      ;;
    *)
      echo "Unsupported architecture: $ARCH"
      exit 1
      ;;
  esac
  mkdir -p ${OUT}/${ARCH_DIR}
  cp $x ${OUT}/${ARCH_DIR}/console
done
tar cvzf console.tar.gz -C ${OUT} .
