#!/bin/bash
# Just a basic script U can improvise lateron asper ur need xD 

abort() { echo "$1"; exit 1; }

#apt install python3-pip -y
#apt update --fix-missing
#apt install python3-pip -y
#echo '#### Installing requests ####' && python3 -m pip install requests
#echo '#### Installing pycryptodome ####' && pip3 install --upgrade pycryptodome git+https://github.com/R0rt1z2/realme-ota
# Realme C12 echo '#### Running command ####' && realme-ota RMX2189 RMX2185_11.A.95_0950_202106160103 1 -r 2
#echo '#### Running command ####' && realme-ota RMX2195T2 RMX2195PU_11.A.39_0390_202107122302 1


git clone https://github.com/HemanthJabalpuri/Firmware_extractor
cd Firmware_extractor
wget -q "https://dl-2.svrip.com/files/SM-A035F/INS/SM-A035F_INS_A035FXXU1AVD3_A035FODM1AVD3_A035FXXU1AVD3_A035FXXU1AVD3.zip?key=dkNIbGRKZkxaQVVNOXdEcUx0WVhpSXZyaXJ6akdVbW4rb1M2RjhVZWg4dz06UmxjTjcvaDE3TzRndmN3L242a0JVa2dkZHJRS1hUU3pjT2ZLbnVoQWo5cz06ekdDOHNmQWdxWG05UHlHQVJRckFNQT09Omx6MW9VaHVSSXBBMHltVC9zeFRJRUhNY1BSb3BFQ29VVGNUZEdEaEFJM2UvQUkyRnNhSTNza2IwOXZNYnpGbzFFVWNyUW0wd2haQnJNc3kydlBPM2dtc3ZiUEhJYVR1K3g0Nlk3cHlQNGxrN1EwVUJVUEZaVWJKN2JBQUNCRDFIT1hucTJnaGJvTzlyVHNxM2xtK2xYZ0RjYkpBWGt1Y3FYMmd5bytBV1BHcUFHVFY1dUpzRGJRSG1nZ0tESUJwLw==" -O motog20.zip
bash extractor.sh motog20.zip
ls -lR
exit


apt install openssh-server -y
apt update --fix-missing
apt install openssh-server -y

# sync rom
repo init --depth=1 --no-repo-verify -u https://github.com/crdroidandroid/android.git -b 11.0 -g default,-mips,-darwin,-notdefault
git clone https://github.com/HemanthJabalpuri/local_manifest --depth 1 -b crdroid-11-UI1 .repo/local_manifests
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8

# build rom [4]
source build/envsetup.sh
lunch lineage_RMX2185-userdebug

make sepolicy
make bootimage
make init

echo ".......Done......." && exit

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
