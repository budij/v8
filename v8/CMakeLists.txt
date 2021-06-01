include(ExternalProject)

set(V8ProjectName project_V8)
set(V8Dir ${V8SourceDir}/v8)
set(V8InstallDir ${CMAKE_INSTALL_PREFIX})

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
   set(BuildType debug)
else()
   set(BuildType release)
endif()

ExternalProject_Add(
   ${V8ProjectName}
   DOWNLOAD_COMMAND ""
   SOURCE_DIR ${V8SourceDir}
   BINARY_DIR ${V8SourceDir}
   CONFIGURE_COMMAND ""
   BUILD_COMMAND ""
   BUILD_IN_SOURCE 0
   INSTALL_COMMAND ""
   INSTALL_DIR ${V8InstallDir}
   UPDATE_COMMAND ""
)

ExternalProject_Add_Step(
   ${V8ProjectName}
   fetch_v8
   COMMAND ${CMAKE_COMMAND} -E env PATH=$ENV{PATH} fetch v8
   COMMENT "Download source code"
   WORKING_DIRECTORY ${V8SourceDir}
   DEPENDERS download
)

ExternalProject_Add_Step(
   ${V8ProjectName}
   sync_client
   COMMAND ${CMAKE_COMMAND} -E env PATH=$ENV{PATH} gclient sync
   COMMENT "Make sure that the source code is the latest"
   WORKING_DIRECTORY ${V8Dir}
   DEPENDEES download
   DEPENDERS configure
)

ExternalProject_Add_Step(
   ${V8ProjectName}
   generate_build_script
   COMMAND tools/dev/v8gen.py x64.${BuildType} -- is_component_build=true use_goma=false v8_enable_backtrace=true v8_enable_disassembler=true v8_enable_object_print=true v8_enable_verify_heap=true
   COMMENT "Generate build script"
   WORKING_DIRECTORY ${V8Dir}
   DEPENDEES sync_client
   DEPENDERS configure
)

#ExternalProject_Add_Step(
#   ${V8ProjectName}
#   set_dynamic_lib_build
#   COMMAND echo is_component_build = true >> out.gn/x64.${BuildType}/args.gn
#   COMMENT "Set the build so that it is a library build"
#   WORKING_DIRECTORY ${V8Dir}
#   DEPENDEES generate_build_script
#   DEPENDERS configure
#)

#ExternalProject_Add_Step(
#   ${V8ProjectName}
#   v8_build
#   COMMAND ${DepotToolsLocation}/ninja -C out.gn/x64.${BuildType}
#   COMMENT "Build v8 engine"
#   WORKING_DIRECTORY ${V8Dir}
#   DEPENDEES configure
#   DEPENDERS build
#)

ExternalProject_Add_Step(
   ${V8ProjectName}
   v8_build
   COMMAND ${CMAKE_COMMAND} -E env PATH=$ENV{PATH} tools/dev/gm.py x64.${BuildType}.check
   COMMENT "Build v8 engine"
   WORKING_DIRECTORY ${V8Dir}
   DEPENDEES configure
   DEPENDERS build
)
