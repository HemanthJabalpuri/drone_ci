#!/bin/bash
# Just a basic script U can improvise lateron asper ur need xD 

PBRP=n

abort() { echo "$1"; exit 1; }

DT_PATH=device/infinix/X626
if [ "$PBRP" = "y" ]; then
  REC=PBRP
  MANIFEST="git://github.com/PitchBlackRecoveryProject/manifest_pb.git -b android-10.0"
  DT_LINK="https://github.com/HemanthJabalpuri/twrp_infinix_X687 -b pbrp"
else
  REC=TWRP
  MANIFEST="git://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-9.0"
  DT_LINK="https://github.com/HemanthJabalpuri/twrp_infinix_X626 -b test"
fi
DEVICE=${DT_PATH##*\/}

echo " ===+++ Setting up Build Environment +++==="
apt install openssh-server -y
apt update --fix-missing
apt install openssh-server -y
mkdir ~/twrpBuilding && cd ~/twrpBuilding

echo " ===+++ Syncing Recovery Sources +++==="
repo init --depth=1 -u $MANIFEST -g default,-device,-mips,-darwin,-notdefault 
repo sync -j$(nproc --all)
git clone --depth=1 $DT_LINK $DT_PATH

echo " ===+++ Patching Recovery Sources +++==="
cd bootable/recovery
applyPatch() {
  curl -sL $1 | patch -p1
  [ $? != 0 ] && echo " Patch $1 failed" && exit
}
#applyPatch https://github.com/HemanthJabalpuri/twrp_realme_RMX2194/files/6997950/SkipTrebleCompatibility.patch.txt
#applyPatch https://github.com/HemanthJabalpuri/android_recovery_realme_RMX2185/files/6694299/0001-Super-as-Super-only.patch.txt
#applyPatch https://github.com/HemanthJabalpuri/android_recovery_realme_RMX2185/files/6758394/NotchFix.patch.txt
cd -

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
if [ "$PBRP" = "y" ]; then
  version=$(cat bootable/recovery/variables.h | grep "define PB_MAIN_VERSION" | cut -d \" -f2)
else
  version=$(cat bootable/recovery/variables.h | grep "define TW_MAIN_VERSION_STR" | cut -d \" -f2)
fi
OUTFILE=${REC}-${version}-${DEVICE}-$(date "+%Y%m%d-%I%M").zip

cd out/target/product/$DEVICE
ls -l recovery.img
mv recovery.img ${OUTFILE%.zip}.img
zip -r9 $OUTFILE ${OUTFILE%.zip}.img

curl -T $OUTFILE https://oshi.at
#curl -F "file=@${OUTFILE}" https://file.io
#curl --upload-file $OUTFILE http://transfer.sh/

#curl -sL https://git.io/file-transfer | sh
#./transfer wet $OUTFILE
