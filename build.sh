#!/bin/bash
# Just a basic script U can improvise lateron asper ur need xD 

abort() { echo "$1"; exit 1; }

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
  echo "======+++ Searching $1 +++======"
  ripgrep "$1" .
}

searchLib 'vendor.display.config@1.0'
searchLib 'libdrm'
