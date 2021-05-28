include(ExternalProject)

set(V8ProjectName project_V8)
set(V8SourceDir ${CMAKE_CURRENT_BINARY_DIR}/V8-source)
set(V8BuildDir ${CMAKE_CURRENT_BINARY_DIR}/V8-build)
set(V8InstallDir ${CMAKE_INSTALL_PREFIX})
set(V8Url "https://github.com/V8/V8.git")
set(V8Tag "ac0d7ce")

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
   set(BuildType "Debug")
else()
   set(BuildType "Release")
endif()

ExternalProject_Add(
   ${V8ProjectName}
   DOWNLOAD_COMMAND ""
   SOURCE_DIR ${V8SourceDir}
   BINARY_DIR ${V8BuildDir}
   CONFIGURE_COMMAND ""
   BUILD_COMMAND ""
   BUILD_IN_SOURCE 0
   INSTALL_COMMAND ""
   INSTALL_DIR ${V8InstallDir}
   UPDATE_COMMAND ""
)
