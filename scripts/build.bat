@ECHO OFF

REM Navigate to a working directory where you want to build boost
REM Usage: build.bat

SET scriptPath=%~dp0
SET sourceDir=%scriptPath%..\
SET currentPath=%CD%
SET v8=v8
SET currentPathFixed=%currentPath%
SET currentPathFixed=%currentPathFixed:\=/%

REM Build cmake
CALL :PerformBuildSteps %v8%
GOTO :Exit

:RemoveDirectory
SET removeDirName=%~1\MSVC

IF EXIST "%removeDirName%" (
   ECHO Removing "%removeDirName%"
   RMDIR /Q /S "%removeDirName%"
)
EXIT /B 0

:CreateDirectory
SET createDirName=%~1

IF NOT EXIST "%createDirName%" (
   ECHO Creating "%createDirName%"
   MKDIR "%createDirName%"
)

IF NOT EXIST "%createDirName%\MSVC" (
   ECHO Creating "%createDirName%\MSVC"
   MKDIR "%createDirName%\MSVC"
)
EXIT /B 0

:Buildv8
SET buildDirName=%~1
SET currPath=%~2
SET buildType=%~3

CD "%buildDirName%"
ECHO Directory %buildDirName% 2>&1 | tee build.log
ECHO Executing: cmake -G "Visual Studio 17 2022" -A x64 %sourceDir% -DCMAKE_BUILD_TYPE=%buildType% %4 2>&1 | tee -a build.log
CALL cmake -G "Visual Studio 17 2022" -A x64 %sourceDir% -DCMAKE_BUILD_TYPE=%buildType% %4 2>&1 | tee -a build.log
ECHO Executing: cmake --build . --config %buildType% 2>&1 | tee -a build.log
CALL cmake --build . --config %buildType% 2>&1 | tee -a build.log

REM Check if the build is successful
SET CurrentBuildDir=%CD%
CALL :ListDirContent %CurrentBuildDir% %CurrentBuildDir%\install\include
CALL :ListDirContent %CurrentBuildDir% %CurrentBuildDir%\install\include\v8

CD "%currPath%"
EXIT /B 0

:PerformBuildSteps
SET dirName=%1
CALL :RemoveDirectory %dirName%
CALL :CreateDirectory %dirName%
SET dirName=%dirName%\MSVC
CALL :Buildv8 %dirName% %currentPath% Release %2
EXIT /B 0

:ListDirContent
SET CurrentWorkingDir=%1
SET DirName=%2

IF EXIST %DirName% (
   ECHO Executing: DIR %DirName% 2>&1 | tee -a "%CurrentWorkingDir%\build.log"
   DIR %DirName% 2>&1 | tee -a "%CurrentWorkingDir%\build.log"
)
EXIT /B 0

:Exit
