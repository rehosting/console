#!/bin/bash
TARGETLIST=(x86_64-linux-gnu i686-linux-musl mipseb-linux-musl mipsel-linux-musl arm-linux-musleabi aarch64-linux-musl mips64eb-linux-musl mips64el-linux-musl)

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
      SUFFIX="x86_64"
      ;;
    i686-linux-musl)
      SUFFIX="x86"
      ;;
    arm-linux-musleabi)
      SUFFIX="armel"
      ;;
    aarch64-linux-musl)
      SUFFIX="aarch64"
      ;;
    mipsel-linux-musl)
      SUFFIX="mipsel"
      ;;
    mipseb-linux-musl)
      SUFFIX="mipseb"
      ;;
    mips64eb-linux-musl)
      SUFFIX="mips64eb"
      ;;
    mips64el-linux-musl)
      SUFFIX="mips64el"
      ;;
    *)
      echo "Unsupported architecture: $ARCH"
      exit 1
      ;;
  esac
  cp $x ${OUT}/console.${SUFFIX}
done

tar cvzf console.tar.gz ${OUT}
