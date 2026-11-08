#!/bin/bash
# Runs INSIDE docker/Dockerfile. Mirrors the linux job of build.yml:
# release build, scripting includes + reapi_amxx_i386.so into publish/, glibc check.
set -euo pipefail
git config --global --add safe.directory '*'

echo "==> Release build"
rm -rf build
CC=gcc CXX=g++ cmake -B build
cmake --build build -j"$(nproc)"

echo "==> publish/ (linux)"
rm -rf publish/addons publish/appversion.h
mkdir -p publish/addons/amxmodx/modules
rsync -a reapi/extra/amxmodx/ publish/addons/amxmodx/
rsync -a reapi/version/reapi_version.inc publish/addons/amxmodx/scripting/include/
cp build/reapi/reapi_amxx_i386.so publish/addons/amxmodx/modules/reapi_amxx_i386.so
cp reapi/version/appversion.h publish/appversion.h

echo "==> GLIBC/ABI compat test"
bash ./reapi/version/glibc_test.sh publish/addons/amxmodx/modules/reapi_amxx_i386.so
