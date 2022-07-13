# V8

Steps to build V8 from this location: https://github.com/V8/V8
The current release of V8 is 9.1.0

# Prerequisites
These are the list of software application that are required to be installed on the build machine. For more information, please refer to the setup instructions with the respective platforms: [Ubuntu](docs/ubuntu-setup.md) or [Windows](docs/windows-setup.md).

## Required for all platforms:
* Cmake 3.18.3 and above
* git (latest version)

## Required for Windows
* Visual Studio 2019 (Windows)

## Required for Ubuntu
* gcc (linux version 9.3.0)
* g++ (linux version 9.3.0)

# Development with CMake
The project can be configured and built using the CMake tool.

## Configuration
Assuming that the project is checked out in the following *~/projects/v8*, you can execute the following command to configure the cmake project:

### Unix makefile
```shell
cmake -G "Unix Makefiles" ~/projects/v8 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=path/to/install/directory
```

### Visual studio example
```batch
cmake -G "Visual Studio 16 2019" -A x64 projects\v8 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=path\to\install\directory
```

## Building project
You can then build the project from the directory where you execute the above command. This command can be executed as is, regardless of the platform.

```shell
cmake --build . --config Release
```

### Scripts
Scripts for linux and windows have been provided in the Scripts directory. Follow the examples below to build using the provided script. Assumption is that there is a builddir where the build is supposed to happen.

### Unix script
```shell
cd builddir
~/projects/v8/script/build.sh
```

### Windows script
When using the batch script, the script assumes that Visual Studio 2022 is installed. But, if it is not installed, please update the cmake command to use Visual Studio 2019 instead.
```batch
cd builddir
C:\projects\v8\script\build.bat
```

## Produced binaries
The location of the binaries is located in the directory specified by CMAKE_INSTALL_PREFIX option above. If that option is not specified, it is located in the **install** directory where the command above was run.

## Build options and their default values
The following is the options that you can use on the command line to override the build:

Option name | Description | Default value | Command line override example
-- | - | - | -
CMAKE_INSTALL_PREFIX | Target installation directory | ${CMAKE_CURRENT_BINARY_DIR}/install | -DCMAKE_INSTALL_PREFIX=~/projects/output
CMAKE_BUILD_TYPE | Build type (Release; Debug) | Release | -DCMAKE_BUILD_TYPE=Debug
