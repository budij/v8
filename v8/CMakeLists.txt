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

if (WIN32)
   set(FetchCommand ${CMAKE_COMMAND} -E env cmd /V /C "set DEPOT_TOOLS_WIN_TOOLCHAIN=0 && set PATH=${PathEnv} && echo PATH=!PATH! && ${DepotToolsLocation}/fetch.bat v8")
   set(SyncCommand ${CMAKE_COMMAND} -E env cmd /V /C "set DEPOT_TOOLS_WIN_TOOLCHAIN=0 && set PATH=${PathEnv} && echo PATH=!PATH! && ${DepotToolsLocation}/gclient.bat sync")
   set(GenerateBuildScriptCommand ${CMAKE_COMMAND} -E env cmd /V /C "set DEPOT_TOOLS_WIN_TOOLCHAIN=0 && set PATH=${PathEnv} && echo PATH=!PATH! && ${DepotToolsLocation}/python.bat tools/dev/v8gen.py x64.${BuildType} -vv -- v8_static_library=true is_component_build=false use_goma=false v8_enable_backtrace=true v8_enable_disassembler=true v8_enable_object_print=true v8_enable_verify_heap=true")
   set(UpdateZLibBuildCommand ${CMAKE_COMMAND} -E env cmd /V /C "set DEPOT_TOOLS_WIN_TOOLCHAIN=0 && set PATH=${PathEnv} && echo PATH=!PATH! && ${CMAKE_SOURCE_DIR}/scripts/UpdateZLib.bat")
   set(BuildCommand ${CMAKE_COMMAND} -E env cmd /V /C "set DEPOT_TOOLS_WIN_TOOLCHAIN=0 && set PATH=${PathEnv} && echo PATH=!PATH! && ${DepotToolsLocation}/ninja.exe -C out.gn/x64.${BuildType}")
else()
   set(FetchCommand ${CMAKE_COMMAND} -E env PATH="$ENV{PATH}" "${DepotToolsLocation}/fetch" v8)
   set(SyncCommand ${CMAKE_COMMAND} -E env PATH="$ENV{PATH}" "${DepotToolsLocation}/gclient" sync)
   set(GenerateBuildScriptCommand tools/dev/v8gen.py x64.${BuildType} -- v8_static_library=true is_component_build=false use_goma=false v8_enable_backtrace=true v8_enable_disassembler=true v8_enable_object_print=true v8_enable_verify_heap=true)
   set(BuildCommand ${CMAKE_COMMAND} -E env PATH=$ENV{PATH} ninja -C out.gn/x64.${BuildType})
endif(WIN32)

ExternalProject_Add_Step(
   ${V8ProjectName}
   fetch_v8
   COMMAND ${FetchCommand}
   COMMENT "Download source code"
   WORKING_DIRECTORY ${V8SourceDir}
   DEPENDERS download
)

ExternalProject_Add_Step(
   ${V8ProjectName}
   sync_client
   COMMAND ${SyncCommand}
   COMMENT "Make sure that the source code is the latest"
   WORKING_DIRECTORY ${V8Dir}
   DEPENDEES download
   DEPENDERS configure
)

ExternalProject_Add_Step(
   ${V8ProjectName}
   generate_build_script
   COMMAND ${GenerateBuildScriptCommand}
   COMMENT "Generate build script"
   WORKING_DIRECTORY ${V8Dir}
   DEPENDEES sync_client
   DEPENDERS configure
)

if (WIN32)
   ExternalProject_Add_Step(
      ${V8ProjectName}
      update_zlib_build
      COMMAND ${UpdateZLibBuildCommand}
      COMMENT "Update ZLib command to rename the output file"
      WORKING_DIRECTORY ${V8Dir}
      DEPENDEES generate_build_script
      DEPENDERS configure
   )
endif(WIN32)

ExternalProject_Add_Step(
   ${V8ProjectName}
   v8_build
   COMMAND ${BuildCommand}
   COMMENT "Build v8 engine"
   WORKING_DIRECTORY ${V8Dir}
   DEPENDEES configure
   DEPENDERS build
)

function (copy_binary step_name binary_name directory_name destination_name)
   ExternalProject_Add_Step(
      ${V8ProjectName}
      copy_executables_${step_name}
      COMMAND ${CMAKE_COMMAND} -E copy_if_different ${V8Dir}/out.gn/x64.${BuildType}/${binary_name} ${V8InstallDir}/${directory_name}/${destination_name}
      COMMENT "Copy ${binary_name} to ${directory_name}"
      WORKING_DIRECTORY ${V8Dir}
      DEPENDEES build
   )
endfunction(copy_binary)

make_directory(${V8InstallDir}/bin)
make_directory(${V8InstallDir}/lib)
make_directory(${V8InstallDir}/include)
make_directory(${V8InstallDir}/include/v8)
copy_binary(snapshot_blob snapshot_blob.bin bin snapshot_blob.bin)

if (APPLE)
   copy_binary(d8                 d8                                    bin d8)
   copy_binary(v8_shell           v8_shell                              bin v8_shell)

   copy_binary(libicui18n         obj/third_party/icu/libicui18n.a      lib libicui18n.a)
   copy_binary(libicuuc           obj/third_party/icu/libicuuc.a        lib libicuuc.a)
   copy_binary(libchrome_zlib     obj/third_party/zlib/libchrome_zlib.a lib libchrome_zlib.a)
   copy_binary(libv8_init         obj/libv8_init.a                      lib libv8_init.a)
   copy_binary(libv8_initializers obj/libv8_initializers.a              lib libv8_initializers.a)
   copy_binary(libv8_libbase      obj/libv8_libbase.a                   lib libv8_libbase.a)
   copy_binary(libv8_libplatform  obj/libv8_libplatform.a               lib libv8_libplatform.a)
   copy_binary(libv8_snapshot     obj/libv8_snapshot.a                  lib libv8_snapshot.a)
elseif (UNIX)
   copy_binary(d8                 d8                                    bin d8)
   copy_binary(v8_shell           v8_shell                              bin v8_shell)

   copy_binary(libicui18n         obj/third_party/icu/libicui18n.a      lib libicui18n.a)
   copy_binary(libicuuc           obj/third_party/icu/libicuuc.a        lib libicuuc.a)
   copy_binary(libchrome_zlib     obj/third_party/zlib/libchrome_zlib.a lib libchrome_zlib.a)
   copy_binary(libv8_init         obj/libv8_init.a                      lib libv8_init.a)
   copy_binary(libv8_initializers obj/libv8_initializers.a              lib libv8_initializers.a)
   copy_binary(libv8_libbase      obj/libv8_libbase.a                   lib libv8_libbase.a)
   copy_binary(libv8_libplatform  obj/libv8_libplatform.a               lib libv8_libplatform.a)
   copy_binary(libv8_snapshot     obj/libv8_snapshot.a                  lib libv8_snapshot.a)
else()
   copy_binary(d8                  d8.exe                               bin d8.exe)
   copy_binary(v8_shell            v8_shell.exe                         bin v8_shell.exe)
   copy_binary(msvcp140            msvcp140.dll                         bin msvcp140.dll)

   copy_binary(icui18n_lib         obj/third_party/icu/icui18n.lib      lib icui18n.lib)
   copy_binary(icuuc_lib           obj/third_party/icu/icuuc.lib        lib icuuc.lib)
   copy_binary(chrome_zlib_lib     obj/third_party/zlib/chrome_zlib.lib lib chrome_zlib.lib)
   copy_binary(v8_init_lib         obj/v8_init.lib                      lib v8_init.lib)
   copy_binary(v8_initializers_lib obj/v8_initializers.lib              lib v8_initializers.lib)
   copy_binary(v8_libbase_lib      obj/v8_libbase.lib                   lib v8_libbase.lib)
   copy_binary(v8_libplatform_lib  obj/v8_libplatform.lib               lib v8_libplatform.lib)
   copy_binary(v8_snapshot_lib     obj/v8_snapshot.lib                  lib v8_snapshot.lib)
endif(APPLE)

ExternalProject_Add_Step(
   ${V8ProjectName}
   copy_header_files
   COMMAND ${CMAKE_COMMAND} -E copy_directory ${V8Dir}/include ${V8InstallDir}/include/v8
   COMMENT "Copy include files from ${V8Dir}/out.gn/x64.${BuildType}/include to ${V8InstallDir}/include/v8"
   WORKING_DIRECTORY ${V8Dir}
   DEPENDEES build
)
