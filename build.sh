#!/bin/sh

mkdir ~/work

echo "===+++ Cloning kernel sources +++==="
cd ~/work
git clone --depth=1 https://github.com/HemanthJabalpuri/android_kernel_realme_mt6765 -b android-10.0

echo "===+++ Downloading toolchain +++==="
mkdir toolchain && cd toolchain
wget -q -O clang.tar.gz https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/ee5ad7f5229892ff06b476e5b5a11ca1f39bf3a9/clang-r365631c.tar.gz
#wget -q -O clang.tar.gz https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/tags/android-10.0.0_r47/clang-r353983c.tar.gz
mkdir clang && tar xzf clang.tar.gz -C clang
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 gcc64
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 gcc

echo "===+++ Building kernel +++==="
cd ~/work/kernel
mkdir out
make O=out ARCH=arm64 RMX2185_defconfig

PATH="$HOME/work/toolchain/clang/bin:$HOME/work/toolchain/gcc64/bin:$HOME/work/toolchain/gcc/bin:${PATH}" \
make O=out \
     ARCH=arm64 \
     CC=clang \
     CLANG_TRIPLE=aarch64-linux-gnu- \
     CROSS_COMPILE=aarch64-linux-android- \
     CROSS_COMPILE_ARM32=arm-linux-androideabi- \
     -j$(nproc --all)

echo "===+++ Compiler version +++==="
grep "LINUX_COMPILER" out/include/generated/compile.h

echo "===+++ Uploading kernel +++==="
curl -T out/arch/arm64/boot/Image.gz-dtb https://oshi.at
curl -T out/arch/arm64/boot/mtk.dtb https://oshi.at
