#!/bin/bash
# Just a basic script U can improvise lateron asper ur need xD 

abort() { echo "$1"; exit 1; }

BRANCH="twrp-12.1" # choose one of 'twrp-11', 'twrp-10.0-deprecated', 'twrp-9.0' etc
case "$BRANCH" in
  "twrp-10.0-deprecated") ven=omni; MANIFEST="git://github.com/minimal-manifest-twrp/platform_manifest_twrp_${ven}.git -b $BRANCH";;
  "twrp-1"*) ven=twrp; MANIFEST="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b $BRANCH";;
  *) ven=omni; MANIFEST="git://github.com/minimal-manifest-twrp/platform_manifest_twrp_${ven}.git -b $BRANCH";;
esac
DT_LINK="https://github.com/HemanthJabalpuri/twrp_realme_RMX2185 -b twrp12.1-UI2"
DT_PATH=device/realme/RMX2185

echo " ===+++ Setting up Build Environment +++==="
apt install openssh-server -y
apt update --fix-missing
apt install openssh-server -y
mkdir ~/twrpBuilding && cd ~/twrpBuilding
DEVICE=${DT_PATH##*\/}
export TARGET_SUPPORTS_64_BIT_APPS=true

echo " ===+++ Syncing Recovery Sources +++==="
repo init --depth=1 -u $MANIFEST
repo sync
git clone --depth=1 $DT_LINK $DT_PATH

echo " ===+++ Patching Recovery Sources +++==="
#rm -rf bootable/recovery
#git clone --depth=1 https://github.com/HemanthJabalpuri/android_bootable_recovery -b test bootable/recovery
cd bootable/recovery
applyPatch() {
  curl -sL $1 | patch -p1
  [ $? != 0 ] && echo " Patch $1 failed" && exit
}
#applyPatch https://github.com/HemanthJabalpuri/twrp_realme_RMX2185/files/6992094/0001-Provide-an-option-to-skip-compatibility.zip-check.patch-a11.txt
#applyPatch https://github.com/HemanthJabalpuri/twrp_realme_RMX2194/files/6997950/SkipTrebleCompatibility.patch.txt
#applyPatch https://github.com/HemanthJabalpuri/twrp_realme_RMX2185/files/7415929/0001-String-fixes.patch.txt
#applyPatch https://github.com/HemanthJabalpuri/twrp_realme_RMX2185/files/6991161/NotchFix.patch.txt
applyPatch https://github.com/HemanthJabalpuri/android_bootable_recovery/commit/e68410787caeb2473981df53171639e397908cb8.patch
cd -

echo " ===+++ Building Recovery +++==="
export ALLOW_MISSING_DEPENDENCIES=true
. build/envsetup.sh
echo " source build/envsetup.sh done"
if [ "$ven" = "twrp" ]; then lunch twrp_${DEVICE}-eng || abort " lunch failed with exit status $?"
else lunch onmi_${DEVICE}-eng || abort " lunch failed with exit status $?"
fi
echo " lunch ${ven}_${DEVICE}-eng done"
mka recoveryimage || abort " mka failed with exit status $?"
echo " mka recoveryimage done"

# Upload zips & recovery.img (U can improvise lateron adding telegram support etc etc)
echo " ===+++ Uploading Recovery +++==="
version=$(cat bootable/recovery/variables.h | grep "define TW_MAIN_VERSION_STR" | cut -d \" -f2)
#OUTFILE=TWRP-${version}-${DEVICE}-$(date "+%Y%m%d-%I%M").zip
OUTFILE=TWRP-${version}-${DEVICE}-UI2-$(date "+%Y%m%d").zip

cd out/target/product/$DEVICE
ls -l recovery.img
mv recovery.img ${OUTFILE%.zip}.img
zip -r9 $OUTFILE ${OUTFILE%.zip}.img

#curl -T $OUTFILE https://oshi.at
curl -F "file=@${OUTFILE}" https://file.io
#curl --upload-file $OUTFILE http://transfer.sh/
curl bashupload.com -T $OUTFILE
echo " "
curl -sL https://git.io/file-transfer | sh
./transfer wet $OUTFILE
echo " "
