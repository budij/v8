#!/bin/sh

# Navigate to a working directory where you want to build cmake
# Usage: build.sh

scriptPath=$(dirname "$0")
sourceDir=$scriptPath/../
currentPath=${PWD}
v8=v8

remove_directory()
{
   removeDirName=$1/GNU

   if [ -d "$removeDirName" ]; then
      echo Removing $removeDirName
      rm -rf $removeDirName
   fi
}

create_directory()
{
   createDirName=$1

   if [ ! -d "$createDirName" ]; then
      echo Creating $createDirName
      mkdir $createDirName
   fi
   if [ ! -d "$createDirName/GNU" ]; then
      echo Creating $createDirName/GNU
      mkdir $createDirName/GNU
   fi
}

list_directory_content()
{
   currentWorkingDir=$1
   buildDirName=$2

   if [ -d "$buildDirName" ]; then
      echo Executing in $buildDirName: ls -la 2>&1 | tee -a "$currentWorkingDir/build.log"
      ls -la $buildDirName 2>&1 | tee -a "$currentWorkingDir/build.log"
   fi
}

build_v8()
{
   dirName=$1
   currPath=$2
   buildType=$3
   shift;
   shift;
   shift;
   options=$@
   
   cd $dirName
   echo Directory $dirName 2>&1 | tee build.log
   echo Executing: cmake -G \"Unix Makefiles\" $sourceDir -DCMAKE_BUILD_TYPE=$buildType $options 2>&1 | tee -a build.log
   cmake -G "Unix Makefiles" $sourceDir -DCMAKE_BUILD_TYPE=$buildType $options 2>&1 | tee -a build.log
   echo Executing: cmake --build . --config $buildType 2>&1 | tee -a build.log
   cmake --build . --config $buildType 2>&1 | tee -a build.log
   echo Executing: cmake --build . --config $buildType --target install 2>&1 | tee -a build.log
   cmake --build . --config $buildType --target install 2>&1 | tee -a build.log

   # Check if the build is successful
   currentBuildDir=${PWD}
   list_directory_content $currentBuildDir $currentBuildDir/install/include
   list_directory_content $currentBuildDir $currentBuildDir/install/include/v8

   cd $currPath
}

perform_build_steps()
{
   dirName=$1
   shift;
   options=$@

   remove_directory $dirName
   create_directory $dirName
   dirName=$dirName/GNU
   build_v8 $dirName $currentPath Release $options
}

# Build v8
perform_build_steps $v8
