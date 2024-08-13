@echo on
setlocal enabledelayedexpansion

REM Create build and install directories
mkdir be\install
cd be

REM Read the architecture parameter
REM Check the first command-line parameter
if "%1" == "AMD64" (
    set ARCH=x64
) else (
    set ARCH=Win32
)

REM Download VTK wheel
mkdir -p install/vtk
curl -L vtk-wheel-sdk-9.3.1-cp310-cp310-win_amd64.tar.xz -o ./be/install/vtk/vtk-wheel-sdk.tar.xz
tar -xJvf ./be/install/vtk/vtk-wheel-sdk.tar.xz -C $PWD/be/install/vtk
VTKDIR=$(dirname $(find $PWD/install/vtk -name vtk-config.cmake))




REM
REM git clone -b v9.3.1 https://github.com/Kitware/VTK.git VTK && ^
REM cmake ^
REM     -DBUILD_EXAMPLES=OFF ^
REM     -DBUILD_TESTING=OFF ^
REM     -DBUILD_SHARED_LIBS=OFF ^
REM     -DVTK_MODULE_ENABLE_VTK_IOGeometry=YES ^
REM     -DVTK_MODULE_ENABLE_VTK_IOPLY=YES ^
REM     -DVTK_MODULE_ENABLE_VTK_IOLegacy=YES ^
REM     -DVTK_MODULE_ENABLE_VTK_IOXML=YES ^
REM     -DVTK_MODULE_ENABLE_VTK_CommonCore=YES ^
REM     -DVTK_MODULE_ENABLE_VTK_CommonDataModel=YES ^
REM     -DVTK_MODULE_ENABLE_VTK_CommonExecutionModel=YES ^
REM     -DVTK_MODULE_ENABLE_VTK_FiltersCore=YES ^
REM     -DVTK_BUILD_ALL_MODULES=OFF ^
REM     -DVTK_REQUIRED_OBJCXX_FLAGS="" ^
REM     -DCMAKE_BUILD_TYPE=Release ^
REM     -DCMAKE_INSTALL_PREFIX=.\be\install ^
REM     -B c:\prebuild\vtk ^
REM     VTK && ^
REM cmake --build c:\prebuild\vtk --config Release --target install -- -m
REM if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

REM Build ITK
git clone -b v5.4.0 https://github.com/InsightSoftwareConsortium/ITK.git ITK && ^
cmake ^
    -DModule_MorphologicalContourInterpolation=ON ^
    -DBUILD_EXAMPLES=OFF ^
    -DBUILD_TESTING=OFF ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=.\be\install ^
    -B c:\prebuild\itk ^
    ITK && ^
REM cmake --build c:\prebuild\itk --config Release --target install -- -m
REM if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

REM Build Greedy
git clone -b master https://github.com/pyushkevich/greedy.git greedy && ^
cmake ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH=.\install;.\install\vtk\vtk-9.3.1.data\headers\cmake ^
    -DCMAKE_INSTALL_PREFIX=.\be\install ^
    -B c:\prebuild\greedy ^
    greedy && ^
REM cmake --build c:\prebuild\greedy --config Release --target install -- -m
REM if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

endlocal
