#!/bin/bash
# Just a basic script U can improvise lateron asper ur need xD 

MANIFEST="git://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-8.1"
DEVICE="Infinix-X573"
DT_LINK="https://github.com/HemanthJabalpuri/android_device_infinix_Infinix-X573 -b test"
DT_PATH=device/realme/$DEVICE
OUTFILE=TWRP-${DEVICE}.zip

echo " ===+++ Setting up Build Environment +++==="
mkdir -p /tmp/recovery
cd /tmp/recovery
apt install openssh-server -y

echo " ===+++ Syncing Recovery Sources +++==="
repo init --depth=1 -u $MANIFEST -g default,-device,-mips,-darwin,-notdefault 
repo sync -j$(nproc --all)
git clone --depth=1 $DT_LINK $DT_PATH

echo " ===+++ Building Recovery +++==="
rm -rf out
source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
export LC_ALL="C"
lunch omni_${DEVICE}-eng && mka recoveryimage

# Upload zips & recovery.img (U can improvise lateron adding telegram support etc etc)
echo " ===+++ Uploading Recovery +++==="
cd out/target/product/$DEVICE
zip -r9 $OUTFILE recovery.img
curl -T $OUTFILE https://oshi.at
