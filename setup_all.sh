#!/bin/bash

set -eux

rm -f console.arm console.armel console.mipsel console.mipseb
./setup.sh arm
./setup.sh mipsel
./setup.sh mipseb

rm -rf consoles || true
mkdir consoles

mv console.arm console.armel
mv console.a* console.m* consoles/
