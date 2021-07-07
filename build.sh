#!/bin/bash
# Just a basic script U can improvise lateron asper ur need xD 

abort() { echo "$1"; exit 1; }

MANIFEST="git://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-10.0"
DEVICE=X687
DT_LINK="https://github.com/HemanthJabalpuri/android_device_infinix_X687"
DT_PATH=device/infinix/$DEVICE

echo " ===+++ Setting up Build Environment +++==="
mkdir ~/twrp10
cd ~/twrp10
apt install openssh-server -y
apt update --fix-missing
apt install openssh-server -y

echo " ===+++ Syncing Recovery Sources +++==="
repo init --depth=1 -u $MANIFEST -g default,-device,-mips,-darwin,-notdefault 
repo sync -j$(nproc --all)
git clone --depth=1 $DT_LINK $DT_PATH

#echo " ===+++ Patching Recovery Sources +++==="
#cd bootable/recovery
#curl -sL https://github.com/HemanthJabalpuri/android_recovery_realme_RMX2185/files/6679948/0001-Provide-an-option-to-skip-compatibility.zip-check.patch.txt | patch -p1 -b
#curl -sL https://github.com/HemanthJabalpuri/android_recovery_realme_RMX2185/files/6694299/0001-Super-as-Super-only.patch.txt | patch -p1 -b
#curl -sL https://github.com/HemanthJabalpuri/android_recovery_realme_RMX2185/files/6758394/NotchFix.patch.txt | patch -p1 -b
#cd -

echo " ===+++ Building Recovery +++==="
rm -rf out
source build/envsetup.sh
echo " source build/envsetup.sh done"
export ALLOW_MISSING_DEPENDENCIES=true
lunch omni_${DEVICE}-eng || abort " lunch failed with exit status $?"
echo " lunch omni_${DEVICE}-eng done"
mka recoveryimage || abort " mka failed with exit status $?"
echo " mka recoveryimage done"

# Upload zips & recovery.img (U can improvise lateron adding telegram support etc etc)
echo " ===+++ Uploading Recovery +++==="
version=$(cat bootable/recovery/variables.h | grep "define TW_MAIN_VERSION_STR" | cut -d \" -f2)
OUTFILE=TWRP-${version}-${DEVICE}-$(date "+%Y%m%d-%I%M").zip

cd out/target/product/$DEVICE
mv recovery.img ${OUTFILE%.zip}.img
zip -r9 $OUTFILE ${OUTFILE%.zip}.img

curl -T $OUTFILE https://oshi.at
#curl -F "file=@${OUTFILE}" https://file.io
#curl --upload-file $OUTFILE http://transfer.sh/
