# 1.install toolchain and make tools for build kernel

mkdir -p ~/workspace/source; cd ~/workspace/source;

git clone --depth=1 https://github.com/techyminati/realme8_C25_C25s_Narzo30_Narzo50A_AndroidR_kernel_source kernel-4.14;

mkdir prebuilts; cd prebuilts;
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/build-tools;
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 clang/host/linux-x86;
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 gcc/linux-x86/aarch64/aarch64-linux-android-4.9;

# (4) add toolchain path to PATH environment variable

# 2. export some environment variable and build the kernel and dtb ,mobile model RMX3085 use oppo6785;RMX3191,RM3192,RMX3193 use oppo6768 instead of oppo6785,RMX3195,RMX3197,RMX3430 use oppo6769 instead of oppo6785 below

export SOURCE_ROOT=~/workspace/source
export DEFCONFIG=oppo6769_defconfig
export COMPILE_PLATFORM=oppo6769
export OPPO_COMPILE_PLATFORM=oppo6769
export PATH=${SOURCE_ROOT}/prebuilts/clang/host/linux-x86/clang-r383902b/bin:${SOURCE_ROOT}/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin:/usr/bin:/bin:$PATH
export MAKE_PATH=${SOURCE_ROOT}/prebuilts/build-tools/linux-x86/bin/
export CROSS_COMPILE=${SOURCE_ROOT}/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-androidkernel-
export KERNEL_ARCH=arm64
export KERNEL_DIR=${SOURCE_ROOT}/kernel-4.14
export KERNEL_OUT=${KERNEL_DIR}/../kernel_out
export KERNEL_SRC=${KERNEL_OUT}
export CLANG_TRIPLE=aarch64-linux-gnu-
export OUT_DIR=${KERNEL_OUT}
export ARCH=${KERNEL_ARCH}
export TARGET_INCLUDES=${TARGET_KERNEL_MAKE_CFLAGS}
export TARGET_LINCLUDES=${TARGET_KERNEL_MAKE_LDFLAGS}

export TARGET_KERNEL_MAKE_ENV+="LD=ld.lld NM=llvm-nm OBJCOPY=llvm-objcopy CC=${SOURCE_ROOT}/prebuilts/clang/host/linux-x86/clang-r383902b/bin/clang"

cd ${KERNEL_DIR} && \
${MAKE_PATH}make O=${OUT_DIR} ${TARGET_KERNEL_MAKE_ENV} HOSTLDFLAGS="${TARGET_LINCLUDES}" ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} ${DEFCONFIG}

cd ${OUT_DIR} && \
${MAKE_PATH}make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} HOSTCFLAGS="${TARGET_INCLUDES}" HOSTLDFLAGS="${TARGET_LINCLUDES}" O=${OUT_DIR} ${TARGET_KERNEL_MAKE_ENV}
