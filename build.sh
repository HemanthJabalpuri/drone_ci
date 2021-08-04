#!/bin/sh

mkdir ~/work

echo "===+++ Cloning kernel sources +++==="
cd ~/work
git clone --depth=1 https://github.com/HemanthJabalpuri/mt6755_aeon6755_66_n_kernel kernel

echo "===+++ Downloading toolchain +++==="
mkdir toolchain && cd toolchain
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 gcc64

echo "===+++ Building kernel +++==="
cd ~/work/kernel
export CROSS_COMPILE=$HOME/work/toolchain/bin/aarch64-linux-android-
export ARCH=arm64 && export SUBARCH=arm64
make aeon6750_66_n_defconfig
make -j$(nproc --all)

echo "===+++ Compiler version +++==="
grep "LINUX_COMPILER" out/include/generated/compile.h

echo "===+++ Uploading kernel +++==="
curl -T out/arch/arm64/boot/Image-dtb https://oshi.at
curl -T out/arch/arm64/boot/mtk.dtb https://oshi.at
