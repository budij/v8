include(ExternalProject)

# List of all gn arguments for Chromium build
# https://gitlab.com/noencoding/OS-X-Chromium-with-proprietary-codecs/-/wikis/List-of-all-gn-arguments-for-Chromium-build

set(V8ProjectName project_V8)
set(V8Dir ${V8SourceDir}/v8)

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
   set(BuildType debug)
   set(IsDebug is_debug=true)
else()
   set(BuildType release)
   set(IsDebug is_debug=false)
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
   # I used this instruction to get this to work for Windows
   # https://stackoverflow.com/questions/67041878/how-do-i-embed-v8-on-windows
   # Apparently, the build for dll for Windows platform using MSVC is always broken.
   # So, we need to build it as a static lib into v8_monolith.lib that can be linked to an application

   set(FetchCommand ${CMAKE_COMMAND} -E env cmd /V /C "set DEPOT_TOOLS_WIN_TOOLCHAIN=0 && set PATH=${PathEnv} && echo PATH=!PATH! && ${DepotToolsLocation}/fetch.bat v8")
   set(SyncCommand ${CMAKE_COMMAND} -E env cmd /V /C "set DEPOT_TOOLS_WIN_TOOLCHAIN=0 && set PATH=${PathEnv} && echo PATH=!PATH! && ${DepotToolsLocation}/gclient.bat sync")
   set(GenerateBuildScriptCommand ${CMAKE_COMMAND} -E env cmd /V /C "set DEPOT_TOOLS_WIN_TOOLCHAIN=0 && set PATH=${PathEnv} && echo PATH=!PATH! && ${DepotToolsLocation}/python.bat tools/dev/v8gen.py x64.${BuildType} -vv -- ${IsDebug} is_component_build=false v8_monolithic=true use_goma=false v8_enable_backtrace=true v8_enable_disassembler=true v8_enable_object_print=true v8_enable_verify_heap=true is_clang=false v8_use_external_startup_data=false")
   set(UpdateZLibBuildCommand ${CMAKE_COMMAND} -E env cmd /V /C "set DEPOT_TOOLS_WIN_TOOLCHAIN=0 && set PATH=${PathEnv} && echo PATH=!PATH! && ${CMAKE_SOURCE_DIR}/scripts/UpdateZLib.bat")
   set(BuildCommand ${CMAKE_COMMAND} -E env cmd /V /C "set DEPOT_TOOLS_WIN_TOOLCHAIN=0 && set PATH=${PathEnv} && echo PATH=!PATH! && ${DepotToolsLocation}/ninja.exe -C out.gn/x64.${BuildType} v8_monolith")
else()
   set(FetchCommand ${CMAKE_COMMAND} -E env PATH="$ENV{PATH}" "${DepotToolsLocation}/fetch" v8)
   set(SyncCommand ${CMAKE_COMMAND} -E env PATH="$ENV{PATH}" "${DepotToolsLocation}/gclient" sync)
   set(GenerateBuildScriptCommand ${CMAKE_COMMAND} -E env PATH="$ENV{PATH}" python3 tools/dev/v8gen.py x64.${BuildType} -- ${IsDebug} is_component_build=true use_goma=false v8_enable_backtrace=true v8_enable_disassembler=true v8_enable_object_print=true v8_enable_verify_heap=true)
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

if (APPLE)
   copy_binary(snapshot_blob snapshot_blob.bin bin snapshot_blob.bin)
   copy_binary(d8                           d8                                 bin d8)
   copy_binary(v8_shell                     v8_shell                           bin v8_shell)

   copy_binary(libcpp_chrome                libc++_chrome.dylib                lib libc++_chrome.dylib)
   copy_binary(libchrome_zlib               libchrome_zlib.dylib               lib libchrome_zlib.dylib)
   copy_binary(libcppgc                     libcppgc.dylib                     lib libcppgc.dylib)
   copy_binary(libicui18n                   libicui18n.dylib                   lib libicui18n.dylib)
   copy_binary(libicui18n_hidden_visibility libicui18n_hidden_visibility.dylib lib libicui18n_hidden_visibility.dylib)
   copy_binary(libicuuc                     libicuuc.dylib                     lib libicuuc.dylib)
   copy_binary(libicuuc_hidden_visibility   libicuuc_hidden_visibility.dylib   lib libicuuc_hidden_visibility.dylib)
   copy_binary(libv8                        libv8.dylib                        lib libv8.dylib)
   copy_binary(libv8_debug_helper           libv8_debug_helper.dylib           lib libv8_debug_helper.dylib)
   copy_binary(libv8_for_testing            libv8_for_testing.dylib            lib libv8_for_testing.dylib)
   copy_binary(libv8_heap_base_for_testing  libv8_heap_base_for_testing.dylib  lib libv8_heap_base_for_testing.dylib)
   copy_binary(libv8_libbase                libv8_libbase.dylib                lib libv8_libbase.dylib)
   copy_binary(libv8_libplatform            libv8_libplatform.dylib            lib libv8_libplatform.dylib)
elseif (UNIX)
   copy_binary(snapshot_blob snapshot_blob.bin bin snapshot_blob.bin)
   copy_binary(d8                           d8                                 bin d8)
   copy_binary(v8_shell                     v8_shell                           bin v8_shell)

   copy_binary(libchrome_zlib               libchrome_zlib.so                  lib libchrome_zlib.so)
   copy_binary(libcppgc                     libcppgc.so                        lib libcppgc.so)
   copy_binary(libcpp                       libc++.so                          lib libc++.so)
   copy_binary(libicui18n                   libicui18n.so                      lib libicui18n.so)
   copy_binary(libicui18n_hidden_visibility libicui18n_hidden_visibility.so    lib libicui18n_hidden_visibility.so)
   copy_binary(libicuuc                     libicuuc.so                        lib libicuuc.so)
   copy_binary(libicuuc_hidden_visibility   libicuuc_hidden_visibility.so      lib libicuuc_hidden_visibility.so)
   copy_binary(libv8                        libv8.so                           lib libv8.so)
   copy_binary(libv8_debug_helper           libv8_debug_helper.so              lib libv8_debug_helper.so)
   copy_binary(libv8_for_testing            libv8_for_testing.so               lib libv8_for_testing.so)
   copy_binary(libv8_heap_base_for_testing  libv8_heap_base_for_testing.so     lib libv8_heap_base_for_testing.so)
   copy_binary(libv8_libbase                libv8_libbase.so                   lib libv8_libbase.so)
   copy_binary(libv8_libplatform            libv8_libplatform.so               lib libv8_libplatform.so)
else()
   copy_binary(dbgcore                      dbgcore.dll                        bin dbgcore.dll)
   copy_binary(dbghelp                      dbghelp.dll                        bin dbghelp.dll)
   copy_binary(msvcp140                     msvcp140.dll                       bin msvcp140.dll)
   copy_binary(ucrtbase                     ucrtbase.dll                       bin ucrtbase.dll)
   copy_binary(vccorlib140                  vccorlib140.dll                    bin vccorlib140.dll)
   copy_binary(vcruntime140                 vcruntime140.dll                   bin vcruntime140.dll)
   copy_binary(vcruntime140_1               vcruntime140_1.dll                 bin vcruntime140_1.dll)

   copy_binary(libv8_libbase                obj/v8_libbase.lib                 lib v8_libbase.lib)
   copy_binary(libv8_libplatform            obj/v8_libplatform.lib             lib v8_libplatform.lib)
   copy_binary(libv8_monolith               obj/v8_monolith.lib                lib v8_monolith.lib)
endif(APPLE)

ExternalProject_Add_Step(
   ${V8ProjectName}
   copy_header_files
   COMMAND ${CMAKE_COMMAND} -E copy_directory ${V8Dir}/include ${V8InstallDir}/include/v8
   COMMENT "Copy include files from ${V8Dir}/include to ${V8InstallDir}/include/v8"
   WORKING_DIRECTORY ${V8Dir}
   DEPENDEES build
)
