#!/bin/bash

branch=arrow-11.0

applypatch() {
  patch=$1
  patchrepo=$2
  git clone --depth=1 https://github.com/HemanthJabalpuri/${patchrepo} -b $branch
  cd ${patchrepo}
  curl -sL ${patch} | git am
  git push https://HemanthJabalpuri:${PASSWORD}@github.com/HemanthJabalpuri/${patchrepo}.git --all
  cd -
}

# VoLTE patches
applypatch \
  https://github.com/PotatoProject-next/frameworks_base/commit/5db62c3223a698657acafdefda323baa5e773d4c.patch \
  android_frameworks_base 

applypatch \
  https://github.com/PotatoProject-next/frameworks_opt_net_wifi/commit/88773b8285d7962d0add6a9f55c63fc045beb677.patch \
  android_frameworks_opt_net_wifi

applypatch \
  https://github.com/PotatoProject-next/frameworks_opt_net_ims/commit/d2ce9579fc2ba741faf26c56a8e076b5099ac897.patch \
  android_frameworks_opt_net_ims

# Required for booting
applypatch \
  https://github.com/phhusson/platform_external_selinux/commit/f3d5e2eb212ebd4189428d6adb915880573962f9.patch \
  android_external_selinux
