#!/bin/sh

mkdir ~/work

echo "===+++ Cloning kernel sources +++==="
cd ~/work
git clone --depth=1 https://github.com/99degree/android_kernel_m3note -b m3note_20190813 kernel

echo "===+++ Downloading toolchain +++==="
mkdir toolchain && cd toolchain
#git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 gcc64
git clone --depth=1 https://github.com/nathanchance/gcc-prebuilts -b aarch64-linaro-7.x gcc64

echo "===+++ Building kernel +++==="
cd ~/work/kernel
export CROSS_COMPILE=$HOME/work/toolchain/gcc64/bin/aarch64-linaro-linux-android-
export ARCH=arm64 && export SUBARCH=arm64
make m3_note_defconfig
make -j$(nproc --all)

echo "===+++ Compiler version +++==="
grep "LINUX_COMPILER" out/include/generated/compile.h

echo "===+++ Uploading kernel +++==="
curl -T out/arch/arm64/boot/Image-dtb https://oshi.at
curl -T out/arch/arm64/boot/mtk.dtb https://oshi.at
