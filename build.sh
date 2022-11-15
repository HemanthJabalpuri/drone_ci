#!/bin/bash
# Just a basic script U can improvise lateron asper ur need xD 

abort() { echo "$1"; exit 1; }

apt install openssh-server -y
apt update --fix-missing
apt install openssh-server -y

# sync rom
repo init --depth=1 --no-repo-verify -u https://github.com/crdroidandroid/android.git -b 11.0 -g default,-mips,-darwin,-notdefault
git clone https://github.com/HemanthJabalpuri/local_manifest --depth 1 -b crdroid-11-UI1 .repo/local_manifests
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8

# build rom [4]
source build/envsetup.sh
export changelog_days=365
lunch lineage_RMX2185-userdebug

make sepolicy
make bootimage
make init

echo " "
echo ".......Done......." && exit


apt install megatools -y
apt update --fix-missing
apt install megatools -y
git clone https://github.com/AndroidDumps/Firmware_extractor
cd Firmware_extractor
wget -q "http://bashupload.com/98YY6/out.zip" -O out.zip
#megadl --no-progress 'https://mega.nz/#!r98yWC5L!Jf6y2_kksIzChwatdeG6bA9hJrHvOLo4JP4gmYcEEAY'
echo "$(ls *.zip | head -n 1)"
echo "##############################"
unzip -l out.zip
unzip out.zip -d .
file T62Ex_TF/*
echo "##############################"
#bash extractor.sh "$(ls *.zip | head -n 1)"
#ls -lhR
exit


MANIFEST="git://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-10.0"

echo " ===+++ Setting up Build Environment +++==="
mkdir ~/twrp10
cd ~/twrp10
apt install openssh-server ripgrep -y
apt update --fix-missing
apt install openssh-server ripgrep -y

echo " ===+++ Syncing Recovery Sources +++==="
repo init --depth=1 -u $MANIFEST -g default,-device,-mips,-darwin,-notdefault 
repo sync -j$(nproc --all)

echo " ===+++ Searching for buildable libs +++==="
searchLib() {
  for i in "$@"; do
    echo "======+++ Searching $i +++======"
    rg "$i" .
  done
}

searchLib 'vendor.display.config@1.0' 'libdrm' 'vendor.qti.hardware.tui_comm@1.0'
