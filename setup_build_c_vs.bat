@echo OFF
setlocal EnableDelayedExpansion

:: Find CMake
where /q cmake.exe
if ERRORLEVEL 1 (
	echo Cannot find cmake.exe! 
	echo Make sure to add [CMake install dir]\bin to PATH
	goto END
) else (
	for /f "tokens=*" %%i in ('where cmake.exe') do set "CMAKE_PATH=%%i"
)

set "VSWHERE_PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
:: Find latest VS install with C++ workload (Component.VC.CoreIde)
if exist "%VSWHERE_PATH%" (
	for /f "tokens=*" %%i in ('"%VSWHERE_PATH%" -latest -requires Microsoft.VisualStudio.Component.VC.CoreIde -property installationPath') do set "VS_PATH=%%i"
) else (
	:: vswhere not found, guessing Visual Studio install path.
	set "VS_PATH=%ProgramFiles%\Microsoft Visual Studio\2022\Community"
	if not exist !VS_PATH!\* set "VS_PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community"
)
set "VCVARS64_PATH=%VS_PATH%\VC\Auxiliary\Build\vcvars64.bat"
if not exist "%VCVARS64_PATH%" (
	echo x64 Native Tools Command Prompt for VS ^(vcvars64.bat^) could not be found!
	echo Make sure Visual Studio ^(2019 or 2022^) with the "Desktop development with C++" workload is installed
	echo https://learn.microsoft.com/en-us/cpp/build/vscpp-step-0-installation?view=msvc-170
	echo ^(DEBUG^) VCVARS64_PATH is "%VCVARS64_PATH%"
	goto END
)

echo.
echo Make sure to run this from the main dir of your Projekt (i.e. where CMakeLists.txt) is!
echo Playdate SDK install path: "%PLAYDATE_SDK_PATH%"
echo CMake was found at: "%CMAKE_PATH%"
echo Visual Studio x64 Native Tools Command Prompt path: "%VCVARS64_PATH%"
echo.

call "%VCVARS64_PATH%"
echo.

echo Creating build directories build_sim and build_device...
mkdir build_sim
mkdir build_device
echo Done.
echo.

echo Running CMake setup for simulator build (VS target)...
echo.
cd build_sim
cmake ..
echo.

echo Running CMake setup for device build...
echo.
cd ..\build_device
cmake .. -G "NMake Makefiles" --toolchain=%PLAYDATE_SDK_PATH%/C_API/buildsupport/arm.cmake
echo.

echo All done!

:END
endlocal
pause