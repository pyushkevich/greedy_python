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

REM Build VTK
git clone -b v9.3.1 https://github.com/Kitware/VTK.git VTK && ^
cmake ^
    -DBUILD_EXAMPLES=OFF ^
    -DBUILD_TESTING=OFF ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DVTK_MODULE_ENABLE_VTK_IOGeometry=YES ^
    -DVTK_MODULE_ENABLE_VTK_IOPLY=YES ^
    -DVTK_MODULE_ENABLE_VTK_IOLegacy=YES ^
    -DVTK_MODULE_ENABLE_VTK_IOXML=YES ^
    -DVTK_MODULE_ENABLE_VTK_CommonCore=YES ^
    -DVTK_MODULE_ENABLE_VTK_CommonDataModel=YES ^
    -DVTK_MODULE_ENABLE_VTK_CommonExecutionModel=YES ^
    -DVTK_MODULE_ENABLE_VTK_FiltersCore=YES ^
    -DVTK_BUILD_ALL_MODULES=OFF ^
    -DVTK_REQUIRED_OBJCXX_FLAGS="" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=.\be\install ^
    -B c:\prebuild\vtk ^
    VTK && ^
cmake --build c:\prebuild\vtk --config Release --target install -- -m
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

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
cmake --build c:\prebuild\itk --config Release --target install -- -m
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

REM Build Greedy
git clone -b master https://github.com/pyushkevich/greedy.git greedy && ^
cmake ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH=.\be\install ^
    -DCMAKE_INSTALL_PREFIX=.\be\install ^
    -B c:\prebuild\greedy ^
    greedy && ^
cmake --build c:\prebuild\greedy --config Release --target install -- -m
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

endlocal
