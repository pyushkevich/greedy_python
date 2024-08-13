#!/bin/bash
set -x -e 

mkdir -p be/install && cd be

# Build ITK
git clone -b v5.2.1 https://github.com/InsightSoftwareConsortium/ITK.git ITK
cmake \
    -DModule_MorphologicalContourInterpolation=ON \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTING=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=./install \
    -DCMAKE_BUILD_TYPE=Release \
    -B ITK/build \
    ITK

cmake --build ITK/build --target install

# Find VTK header file
VTKDIR=$(dirname $(find $PWD/install/vtk -name vtk-config.cmake))

#git clone -b v9.3.1 https://github.com/Kitware/VTK.git VTK
#cmake \
#    -DBUILD_EXAMPLES=OFF \
#    -DBUILD_TESTING=OFF \
#    -DCMAKE_BUILD_TYPE=Release \
#    -DBUILD_SHARED_LIBS=OFF \
#    -DVTK_REQUIRED_OBJCXX_FLAGS="" \
#    -DCMAKE_INSTALL_PREFIX=./install \
#    -DCMAKE_BUILD_TYPE=Release \
#    -B VTK/build \
#    VTK
#cmake --build VTK/build --target install

# Build Greedy
git clone -b master https://github.com/pyushkevich/greedy.git greedy
cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=./install \
    -DCMAKE_PREFIX_PATH="$PWD/install" \
    -DVTK_DIR=$VTKDIR \
    -B greedy/build \
    greedy

cmake --build greedy/build --target install
