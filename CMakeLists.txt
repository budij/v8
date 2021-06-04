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

if (WIN32)
   set(ENV{PATH} "${DepotToolsLocation};$ENV{PATH}")
else ()
   set(ENV{PATH} "${DepotToolsLocation}:$ENV{PATH}")
endif(WIN32)

add_subdirectory(depot_tools)
add_subdirectory(v8)

message(STATUS "DepotToolsLocation: ${DepotToolsLocation}")
message(STATUS "Path: $ENV{PATH}")
