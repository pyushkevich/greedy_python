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

# Download and build VTK
if [[ $RUNNER_OS == "Linux" && $RUNNER_ARCH == "X64" ]]; then
  VTK_BINARY=vtk-wheel-sdk-9.3.1-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.tar.xz
elif [[ $RUNNER_OS == "macOS" && $RUNNER_ARCH == "X64" ]]; then
  VTK_BINARY=vtk-wheel-sdk-9.3.1-cp310-cp310-macosx_10_10_x86_64.tar.xz
elif [[ $RUNNER_OS == "macOS" && $RUNNER_ARCH == "ARM64" ]]; then
  VTK_BINARY=vtk-wheel-sdk-9.3.1-cp310-cp310-macosx_11_0_arm64.tar.xz
elif [[ $RUNNER_OS == "Windows" && $RUNNER_ARCH == "ARM64" ]]; then
    VTK_BINARY=vtk-wheel-sdk-9.3.1-cp310-cp310-win_amd64.tar.xz
else
  exit 255
fi

# Install VTK from binary wheels provided by Kitware
mkdir -p install/vtk
curl -L https://www.vtk.org/files/release/9.3/${VTK_BINARY} -o ./be/install/vtk/vtk-wheel-sdk.tar.xz
tar -xJvf ./be/install/vtk/vtk-wheel-sdk.tar.xz -C $PWD/be/install/vtk
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
