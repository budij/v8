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
   DEPENDS ${DepotToolsProjectName}
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

ExternalProject_Add_Step(
   ${V8ProjectName}
   v8_build
   COMMAND ${CMAKE_COMMAND} -E env PATH=$ENV{PATH} ninja -C out.gn/x64.${BuildType}
   COMMENT "Build v8 engine"
   WORKING_DIRECTORY ${V8Dir}
   DEPENDEES configure
   DEPENDERS build
)

function (copy_binary step_name binary_name directory_name)
   ExternalProject_Add_Step(
      ${V8ProjectName}
      copy_executables_${step_name}
      COMMAND ${CMAKE_COMMAND} -E copy_if_different ${V8Dir}/out.gn/x64.${BuildType}/${binary_name} ${V8InstallDir}/${directory_name}/${binary_name}
      COMMENT "Copy ${binary_name} to ${directory_name}"
      WORKING_DIRECTORY ${V8Dir}
      DEPENDEES build
   )
endfunction(copy_binary)

make_directory(${V8InstallDir}/bin)
make_directory(${V8InstallDir}/lib)
make_directory(${V8InstallDir}/include)

if (APPLE)
   copy_binary(v8_shell v8_shell bin)
   copy_binary(libv8_libplatform libv8_libplatform.dylib lib)
   copy_binary(libv8_libbase libv8_libbase.dylib lib)
   copy_binary(libv8 libv8.dylib lib)
   copy_binary(libicuuc libicuuc.dylib lib)
   copy_binary(libicui18n libicui18n.dylib lib)
elseif (UNIX)
   copy_binary(v8_shell v8_shell bin)
   copy_binary(libv8_libplatform libv8_libplatform.so lib)
   copy_binary(libv8_libbase libv8_libbase.so lib)
   copy_binary(libv8 libv8.so lib)
   copy_binary(libicuuc libicuuc.so lib)
   copy_binary(libicui18n libicui18n.so lib)
endif(APPLE)

ExternalProject_Add_Step(
   ${V8ProjectName}
   copy_header_files
   COMMAND ${CMAKE_COMMAND} -E copy_directory ${V8Dir}/include ${V8InstallDir}/include
   COMMENT "Copy include files from ${V8Dir}/out.gn/x64.${BuildType}/include to ${V8InstallDir}/include"
   WORKING_DIRECTORY ${V8Dir}
   DEPENDEES build
)
