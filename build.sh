#!/bin/bash
# Just a basic script you can improvise later on as per need.

abort() { echo "$1"; exit 1; }

MANIFEST="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-11"
DT_LINK="https://github.com/HemanthJabalpuri/twrp_realme_RMX3201"
DT_PATH=device/realme/RMX2185

echo " ===+++ Setting up Build Environment +++==="
apt install openssh-server -y
apt update --fix-missing
apt install openssh-server -y
DEVICE=${DT_PATH##*\/}

echo " ===+++ Syncing Recovery Sources +++==="
repo init --depth=1 -u $MANIFEST
repo sync

echo " ===+++ Patching Recovery Sources +++==="
#rm -rf bootable/recovery
#git clone --depth=1 https://github.com/HemanthJabalpuri/android_bootable_recovery -b android-12.1-test bootable/recovery
cd bootable/recovery
applyPatch() {
  curl -sL $1 | patch -p1
  [ $? != 0 ] && echo " Patch $1 failed" && exit
}
applyPatch https://github.com/HemanthJabalpuri/android_bootable_recovery/commit/22e9c22965d25247f809e9325364e174f13ddf0f.patch
applyPatch https://github.com/HemanthJabalpuri/twrp_realme_RMX2185/files/7415929/0001-String-fixes.patch.txt
applyPatch https://github.com/HemanthJabalpuri/twrp_realme_RMX2185/files/9694955/0001-Some-shell-funtions.patch.txt
applyPatch https://github.com/HemanthJabalpuri/twrp_realme_RMX2185/files/7350752/0001-Super-as-Super-only.patch-a11.txt
applyPatch https://github.com/HemanthJabalpuri/twrp_realme_RMX2185/files/9680977/changeNavbarLayout.patch.txt
applyPatch https://github.com/HemanthJabalpuri/twrp_realme_RMX2185/files/9696114/0001-RemoveNoOSinstalledWarning.patch.txt
cd -

echo " ===+++ Building Recovery +++==="
export ALLOW_MISSING_DEPENDENCIES=true
. build/envsetup.sh
echo " source build/envsetup.sh done"

version=$(cat bootable/recovery/variables.h | grep "define TW_MAIN_VERSION_STR" | cut -d \" -f2)
mkdir uploads

build_twrp() {
  rm -rf $DT_PATH
  git clone --depth=1 $DT_LINK -b $1 $DT_PATH
  lunch twrp_${DEVICE}-eng || abort " lunch failed with exit status $?"
  echo " lunch twrp_${DEVICE}-eng done"
  mka clobber
  export TW_DEVICE_VERSION="$2"
  mka recoveryimage || abort " mka failed with exit status $?"
  echo " mka recoveryimage done"

  echo " ===+++ Moving Recovery +++==="
  #OUTFILE=TWRP-${version}-${DEVICE}-$(date "+%Y%m%d-%I%M").zip
  OUTFILE=TWRP-${version}-${3}-${DEVICE}-$(date "+%Y%m%d").zip

  cd out/target/product/$DEVICE
  mv recovery.img ${OUTFILE%.zip}.img
  zip -r9 $OUTFILE ${OUTFILE%.zip}.img
  cd -
  cp out/target/product/$DEVICE/$OUTFILE uploads/
}

build_twrp android-10.0 "test" "test-UI1"

ls -lR uploads
for i in ./uploads/*.zip; do
  # Upload zips & recovery.img (U can improvise lateron adding telegram support etc etc)
  #curl -T $i https://oshi.at
  curl -F "file=@${i}" https://file.io
  #curl --upload-file $i http://transfer.sh/
  curl bashupload.com -T $i
  echo " "
  curl -sL https://git.io/file-transfer | sh
  ./transfer wet $i
  echo " "
done

echo " Done"
