# V8

This repository provides the cmake files required to compile and build V8 engine. The latest version of V8 that has been tested is version 9.9.0. And, the operating systems that have been tested with the script is Windows, Ubuntu, and MacOS.

# Prerequisites
These are the list of software application that are required to be installed on the build machine.

## Required for all platforms
* Cmake 3.18.3 and above
* git (latest version)

## Required for Windows
* Visual Studio 2019 or above
* Windows SDK - 10.1.20348.0

## Required for Ubuntu
* gcc (linux version 9.3.0)
* g++ (linux version 9.3.0)
* Python 3
* PkgConfig

## Required for MacOS
* clang
* Python 3
* PkgConfig

# Building using cmake
There are 2 ways to build this project. Scripts are provided in the [root]/scripts folder for users to easily compile the project. However, users can also choose to manuall configure cmake and build the project. The following steps assumes that the checkout directory for this project is in *~/projects/v8*, and the build directory is in *~/projects/build*.

An example project will also be built to show an example of the cmake file that can be used to compile V8 on other projects. Please review the content of *~/projects/v8/examples/CMakeList.txt* file, and the generated *~/projects/build/v8/GNU/example/Example-source/CMakeList.txt*.

## Using scripts
1. Create a build directory.
```
mkdir ~/projects/build
cd ~/projects/build
```

2. Execute the script from the build directory. The command for both batch and shell scripts are the same. The example below uses shell script example, but the same can be applied in a Windows environment using a batch script. Once the build starts, it will create *v8/GNU* for Linux and MacOS environment, or *v8/MSVC* for Windows environment.
```shell
~/projects/v8/scripts/build.sh
```

3. Wait for the build to complete. Once the build is completed, the output files can be found in the *install/bin* (for binaries), *install/include* (for include headers), and *install/lib* (for the lib files) directories.

## Manually using cmake
1. Configure the project.
```shell
# Unix makefile for linux and MacOS environment
cd ~/projects/build
cmake -G "Unix Makefiles" ~/projects/v8 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=path/to/install/directory
```
```batch
REM Visual studio for Windows environment
cd ~/projects/build
cmake -G "Visual Studio 16 2019" -A x64 projects\v8 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=path\to\install\directory
```

2. Build the project from the *~/projects/build* directory.
```shell
cmake --build . --config Release
```

3. Wait for the build to complete. Once the build is completed, the output files can be found in the *install/bin* (for binaries), *install/include* (for include headers), and *install/lib* (for the lib files) directories.

## Build options and their default values
The following is the options that you can use on the command line to override the build:

Option name | Description | Default value | Command line override example
-- | - | - | -
CMAKE_INSTALL_PREFIX | Target installation directory | ${CMAKE_CURRENT_BINARY_DIR}/install | -DCMAKE_INSTALL_PREFIX=~/projects/output
CMAKE_BUILD_TYPE | Build type (Release; Debug) | Release | -DCMAKE_BUILD_TYPE=Debug
