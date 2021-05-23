#!/bin/bash
# Just a basic script U can improvise lateron asper ur need xD 

MANIFEST="git://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-10.0"
DEVICE=RMX2185
DT_LINK="https://github.com/HemanthJabalpuri/android_recovery_realme_RMX2185 -b ofox"
DT_PATH=device/realme/$DEVICE

echo " ===+++ Setting up Build Environment +++==="
mkdir -p ~/OrangeFox_10
cd ~/OrangeFox_10
apt install openssh-server -y
git clone https://gitlab.com/OrangeFox/misc/scripts
cd scripts
sudo bash setup/android_build_env.sh
sudo bash setup/install_android_sdk.sh

echo " ===+++ Syncing Recovery Sources +++==="
cd ~/OrangeFox_10
git clone https://gitlab.com/OrangeFox/sync.git
cd sync
./get_fox_10.sh ~/OrangeFox_10/fox_10.0
cd ~/OrangeFox_10/fox_10.0
git clone --depth=1 $DT_LINK $DT_PATH

echo " ===+++ Building Recovery +++==="
wget -O ~/OrangeFox_10/Magisk.zip https://github.com/topjohnwu/Magisk/releases/download/v23.0/Magisk-v23.0.apk
rm -rf out
source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true 
export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1 
export LC_ALL="C"
lunch omni_${DEVICE}-eng && mka recoveryimage

# Upload zips & recovery.img (U can improvise lateron adding telegram support etc etc)
echo " ===+++ Uploading Recovery +++==="
cd out/target/product/$DEVICE

transferFile() {
  echo " Uploading $1"
  curl -T $1 https://oshi.at
  if [ $? != 0 ]; then
    if ! [ -f transfer ]; then
      curl -sL https://git.io/file-transfer | sh
    fi
    ./transfer wet $1
    if [ $? != 0 ]; then
      #https://github.com/dutchcoders/transfer.sh/issues/116
      curl --upload-file $1 http://transfer.sh/$OUTFILE
    fi
  fi
}

for i in *.zip; do
  transferFile $i
done
