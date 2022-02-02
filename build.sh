#!/bin/bash
# Just a basic script U can improvise lateron asper ur need xD 

abort() { echo "$1"; exit 1; }

BRANCH="twrp-11" # choose one of 'twrp-11', 'twrp-10.0-deprecated', 'twrp-9.0' etc
case "$BRANCH" in
  "twrp-10.0-deprecated") ven=omni; MANIFEST="git://github.com/minimal-manifest-twrp/platform_manifest_twrp_${ven}.git -b $BRANCH";;
  "twrp-1"*) ven=twrp; MANIFEST="git://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b $BRANCH";;
  *) ven=omni; MANIFEST="git://github.com/minimal-manifest-twrp/platform_manifest_twrp_${ven}.git -b $BRANCH";;
esac
DT_LINK="https://github.com/HemanthJabalpuri/twrp_TECNO_CE7j -b android-11"
DT_PATH=device/TECNO/CE7j

echo " ===+++ Setting up Build Environment +++==="
apt install openssh-server -y
apt update --fix-missing
apt install openssh-server -y
mkdir ~/twrpBuilding && cd ~/twrpBuilding
DEVICE=${DT_PATH##*\/}

echo " ===+++ Syncing Recovery Sources +++==="
repo init --depth=1 -u $MANIFEST
repo sync
git clone --depth=1 $DT_LINK $DT_PATH

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
OUTFILE=TWRP-${version}-${DEVICE}-$(date "+%Y%m%d-%I%M").zip

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
