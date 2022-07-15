function(FindV8_Func)
   set(V8Proj V8Lib)
   if(TARGET ${V8Proj})
      return()
   endif()

   set(V8_ROOT_DIR ${V8InstallDir})
   set(V8_INCLUDE_DIR ${V8_ROOT_DIR}/include)
   set(V8_LIBS_DIR ${V8_ROOT_DIR}/lib)

   if (APPLE)
      set(V8_LIBRARIES ${V8_ROOT_DIR}/lib/libchrome_zlib.dylib
                       ${V8_ROOT_DIR}/lib/libcppgc.dylib
                       ${V8_ROOT_DIR}/lib/libicui18n.dylib
                       ${V8_ROOT_DIR}/lib/libicuuc.dylib
                       ${V8_ROOT_DIR}/lib/libv8_libbase.dylib
                       ${V8_ROOT_DIR}/lib/libv8_libplatform.dylib
                       ${V8_ROOT_DIR}/lib/libv8.dylib)
   elseif (UNIX)
      set(V8_LIBRARIES ${V8_ROOT_DIR}/lib/libc++.so
                       ${V8_ROOT_DIR}/lib/libchrome_zlib.so
                       ${V8_ROOT_DIR}/lib/libcppgc.so
                       ${V8_ROOT_DIR}/lib/libicui18n.so
                       ${V8_ROOT_DIR}/lib/libicuuc.so
                       ${V8_ROOT_DIR}/lib/libv8_libbase.so
                       ${V8_ROOT_DIR}/lib/libv8_libplatform.so
                       ${V8_ROOT_DIR}/lib/libv8.so)
   else()
      set(V8_LIBRARIES ${V8_ROOT_DIR}/lib/v8_libbase.lib
                       ${V8_ROOT_DIR}/lib/v8_libplatform.lib
                       ${V8_ROOT_DIR}/lib/v8_monolith.lib)
   endif(APPLE)
   add_library(${V8Proj} INTERFACE)

   set (${V8Proj}_headers $<1:${V8_INCLUDE_DIR}/v8/v8.h>)
   target_sources(${V8Proj} INTERFACE $<BUILD_INTERFACE:${${V8Proj}_headers}>)
   target_include_directories(${V8Proj} SYSTEM INTERFACE "$<BUILD_INTERFACE:${V8_INCLUDE_DIR}/v8>")
   target_link_libraries(${V8Proj} INTERFACE "$<BUILD_INTERFACE:${V8_LIBRARIES}>")
   target_compile_definitions(${V8Proj} INTERFACE V8_COMPRESS_POINTERS V8_ENABLE_SANDBOX)
endfunction()

FindV8_Func()