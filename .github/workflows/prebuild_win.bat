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

REM Build VTK
git clone -b v9.3.1 https://github.com/Kitware/VTK.git VTK && ^
cmake ^
    -DBUILD_EXAMPLES=OFF ^
    -DBUILD_TESTING=OFF ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DVTK_REQUIRED_OBJCXX_FLAGS="" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=.\be\install ^
    -B c:\prebuild\vtk ^
    VTK && ^
cmake --build c:\prebuild\vtk --config Release --target install -- -m
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

REM Build Greedy
git clone -b master https://github.com/pyushkevich/greedy.git greedy && ^
cmake ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=.\be\install ^
    -B c:\prebuild\greedy ^
    greedy && ^
cmake --build c:\prebuild\greedy --config Release --target install -- -m
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

endlocal
