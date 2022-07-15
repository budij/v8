CMAKE_MINIMUM_REQUIRED (VERSION 3.18.3)

#################################################################################
#
# Configurable command line options:
# CMAKE_INSTALL_PREFIX (default: ${CMAKE_CURRENT_BINARY_DIR}/install)
# CMAKE_BUILD_TYPE     (default: Release)
# BuildExtraModules    (default: OFF)
#
#################################################################################

project (v8)
set(VERSION_MAJOR                     "9")
set(VERSION_MINOR                     "1")
set(VERSION_PATCH                     "0")
set(VERSION                           "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")
set(CMAKE_INSTALL_RPATH               "$ORIGIN/../lib:$ORIGIN/")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH ON)
set(CMAKE_MODULE_PATH                 ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")
set(CMAKE_CXX_STANDARD                17)

if (APPLE)
   set(CMAKE_INSTALL_RPATH            "@loader_path/../lib;@loader_path/")
endif(APPLE)

# Override the install path if not specified
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
   get_filename_component(InstallPrefix "${CMAKE_CURRENT_BINARY_DIR}/install" ABSOLUTE )
   set(CMAKE_INSTALL_PREFIX ${InstallPrefix} CACHE PATH "Default install prefix" FORCE)
endif()

set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING INTERNAL FORCE)

if(NOT CMAKE_BUILD_TYPE)
   set(BuildTypeDefault "Release")
   message(STATUS "Setting build type to '${BuildTypeDefault}' as none was specified.")
   set(CMAKE_BUILD_TYPE "${BuildTypeDefault}" CACHE STRING "Choose the type of build." FORCE)
endif()

set(DepotToolsProjectName project_depot_tools)
set(DepotToolsSource ${CMAKE_CURRENT_BINARY_DIR}/dt)
set(DepotToolsLocation ${DepotToolsSource})
set(V8SourceDir ${CMAKE_CURRENT_BINARY_DIR}/vs)
set(V8InstallDir ${CMAKE_INSTALL_PREFIX})

if (WIN32)
   set(ENV{PATH} "${DepotToolsLocation};$ENV{PATH}")
else ()
   set(ENV{PATH} "${DepotToolsLocation}:$ENV{PATH}")
endif(WIN32)

# Find required packages
if (NOT WIN32)
   find_package(Python3 REQUIRED)
   find_package(PkgConfig REQUIRED)
ENDIF(NOT WIN32)

include(_FindV8_)

add_subdirectory(depot_tools)
add_subdirectory(v8)
add_subdirectory(example)

message(STATUS "CMAKE_SOURCE_DIR:   ${CMAKE_SOURCE_DIR}")
message(STATUS "DepotToolsLocation: ${DepotToolsLocation}")
message(STATUS "Path:               $ENV{PATH}")
message(STATUS "V8InstallDir:       ${V8InstallDir}")
