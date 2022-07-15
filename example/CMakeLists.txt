project(example)

# Set up files
set (${PROJECT_NAME}_sources hello-world.cc)

if (APPLE)
    set(V8_LIBRARIES ${V8InstallDir}/lib/libchrome_zlib.dylib
                     ${V8InstallDir}/lib/libcppgc.dylib
                     ${V8InstallDir}/lib/libicui18n.dylib
                     ${V8InstallDir}/lib/libicuuc.dylib
                     ${V8InstallDir}/lib/libv8_libbase.dylib
                     ${V8InstallDir}/lib/libv8_libplatform.dylib
                     ${V8InstallDir}/lib/libv8.dylib)
elseif (UNIX)
    set(V8_LIBRARIES ${V8InstallDir}/lib/libc++.so
                     ${V8InstallDir}/lib/libchrome_zlib.so
                     ${V8InstallDir}/lib/libcppgc.so
                     ${V8InstallDir}/lib/libicui18n.so
                     ${V8InstallDir}/lib/libicuuc.so
                     ${V8InstallDir}/lib/libv8_libbase.so
                     ${V8InstallDir}/lib/libv8_libplatform.so
                     ${V8_ROOV8InstallDirT_DIR}/lib/libv8.so)
else()
    set(V8_LIBRARIES ${V8InstallDir}/lib/v8_libbase.lib
                     ${V8InstallDir}/lib/v8_libplatform.lib
                     ${V8InstallDir}/lib/v8_monolith.lib)
endif(APPLE)

# create binaries
# ---------------
add_executable(${PROJECT_NAME} ${${PROJECT_NAME}_sources})
target_link_libraries(${PROJECT_NAME} PRIVATE ${V8_LIBRARIES})
target_compile_definitions(${PROJECT_NAME} PRIVATE V8_COMPRESS_POINTERS V8_ENABLE_SANDBOX)

if (UNIX AND NOT APPLE)
   target_link_libraries(${PROJECT_NAME} INTERFACE stdc++fs)
endif()

include_directories(${PROJECT_NAME} INTERFACE $<BUILD_INTERFACE:$<1:${CMAKE_CURRENT_LIST_DIR}>
                                                                $<1:${V8InstallDir}/include/v8>>)
