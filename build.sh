#!/bin/sh

mkdir ~/work

echo "===+++ Cloning kernel sources +++==="
cd ~/work
git clone --depth=1 https://github.com/HemanthJabalpuri/android_kernel_realme_mt6765 -b android-10.0 kernel

echo "===+++ Downloading toolchain +++==="
mkdir toolchain && cd toolchain
git clone --depth=1 https://github.com/techyminati/android_prebuilts_clang_host_linux-x86_clang-5484270 -b 9.0.3 clang
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 gcc64
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 gcc

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

echo "===+++ Uploading kernel +++==="
curl -T out/arch/arm64/boot/Image https://oshi.at
curl -T out/arch/arm64/boot/mtk.dtb https://oshi.at
