#!/bin/bash
set -x -e 

mkdir -p be/install && cd be

# Build ITK
git clone -b v5.4.0 https://github.com/InsightSoftwareConsortium/ITK.git ITK
cmake \
    -DModule_MorphologicalContourInterpolation=ON \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTING=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=./install \
    -DCMAKE_BUILD_TYPE=Release \
    -B ITK/build \
    ITK
cmake -B ITK/build --target install

# Build VTK
git clone -b v9.3.1 https://github.com/Kitware/VTK.git VTK
cmake \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTING=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DVTK_REQUIRED_OBJCXX_FLAGS="" \
    -DCMAKE_INSTALL_PREFIX=./install \
    -DCMAKE_BUILD_TYPE=Release \
    -B VTK/build \
    VTK
cmake -B VTK/build --target install

# Build Greedy
git clone -b master https://github.com/pyushkevich/greedy.git greedy
cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=./install \
    -DCMAKE_PREFIX_PATH=./install \
    -B greedy/build \
    greedy
cmake -B greedy/build --target install
