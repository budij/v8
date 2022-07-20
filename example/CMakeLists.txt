include(ExternalProject)

set(CmakeSourceDir      ${CMAKE_SOURCE_DIR})
set(ExampleSourceFolder ${CMAKE_CURRENT_BINARY_DIR}/Example-source)
set(ExampleBuildFolder  ${CMAKE_CURRENT_BINARY_DIR}/Example-build)
set(ExampleInstallDir   ${CMAKE_INSTALL_PREFIX})

ExternalProject_Add(
   project_example
   DOWNLOAD_COMMAND ""
   DOWNLOAD_DIR ${ExampleBuildFolder}
   SOURCE_DIR ${ExampleSourceFolder}
   BINARY_DIR ${ExampleBuildFolder}
   CONFIGURE_COMMAND ${CMAKE_COMMAND} -G ${CMAKE_GENERATOR} ${ExampleSourceFolder}
   BUILD_COMMAND ${CMAKE_COMMAND} --build . --config ${CMAKE_BUILD_TYPE}
   INSTALL_COMMAND ${CMAKE_COMMAND} --build . --config ${CMAKE_BUILD_TYPE} --target install
   INSTALL_DIR ${ExampleInstallDir}
   UPDATE_COMMAND ""
   DEPENDS ${V8ProjectName}
)

file(WRITE "${ExampleSourceFolder}/CMakeLists.txt" "cmake_minimum_required (VERSION 3.18.3)

project(example)

set(CMAKE_INSTALL_RPATH               \"$ORIGIN/../lib:$ORIGIN/\")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH ON)
set(CMAKE_MODULE_PATH                 ${CMAKE_MODULE_PATH} \"${CmakeSourceDir}/cmake\")
set(CMAKE_CXX_STANDARD                17)
set(V8InstallDir                      \"${V8InstallDir}\")
set(CMAKE_MSVC_RUNTIME_LIBRARY        \"MultiThreaded$<$<CONFIG:Debug>:Debug>\")

if (APPLE)
   set(CMAKE_INSTALL_RPATH            \"@loader_path/../lib;@loader_path/\")
endif(APPLE)

include(_FindV8_)

# Set up files
set (\${PROJECT_NAME}_sources ${CMAKE_BINARY_DIR}/vs/v8/samples/hello-world.cc)

# create binaries
# ---------------
add_executable(\${PROJECT_NAME} \${\${PROJECT_NAME}_sources})
target_link_libraries(\${PROJECT_NAME} PRIVATE V8Lib)

if (UNIX AND NOT APPLE)
   target_link_libraries(\${PROJECT_NAME} PRIVATE stdc++fs)
elseif (WIN32)
   target_link_libraries(\${PROJECT_NAME} PRIVATE dbghelp.lib;winmm.lib;ws2_32.lib)
endif(UNIX AND NOT APPLE)

include_directories(\${PROJECT_NAME} INTERFACE $<BUILD_INTERFACE:$<1:${CMAKE_BINARY_DIR}/vs/v8/samples>
                                                                 $<1:${CMAKE_BINARY_DIR}/vs/v8>>)

# Adding install destination
# --------------------------
install(TARGETS \${PROJECT_NAME}
        RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
        LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
        ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/static)
")