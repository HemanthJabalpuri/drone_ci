#!/bin/bash

branch=arrow-11.0

git clone --depth=1 https://github.com/HemanthJabalpuri/android_frameworks_base -b $branch
cd android_frameworks_base
curl -sL https://github.com/PotatoProject-next/frameworks_base/commit/5db62c3223a698657acafdefda323baa5e773d4c.patch | patch -p1
git add -A
git commit -m "https://github.com/PotatoProject-next/frameworks_base/commit/5db62c3223a698657acafdefda323baa5e773d4c.patch"
git push https://HemanthJabalpuri:${PASSWORD}@github.com/HemanthJabalpuri/android_frameworks_base.git --all

echo done
