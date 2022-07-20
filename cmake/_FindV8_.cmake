function(FindV8_Func)
   set(V8Proj V8Lib)
   if(TARGET ${V8Proj})
      return()
   endif()

   set(V8_ROOT_DIR ${V8InstallDir})
   set(V8_INCLUDE_DIR ${V8_ROOT_DIR}/include)
   set(V8_LIBS_DIR ${V8_ROOT_DIR}/lib)

   if (APPLE)
      set(V8_LIBRARIES ${V8_LIBS_DIR}/libchrome_zlib.dylib
                       ${V8_LIBS_DIR}/libcppgc.dylib
                       ${V8_LIBS_DIR}/libicui18n.dylib
                       ${V8_LIBS_DIR}/libicuuc.dylib
                       ${V8_LIBS_DIR}/libv8_libbase.dylib
                       ${V8_LIBS_DIR}/libv8_libplatform.dylib
                       ${V8_LIBS_DIR}/libv8.dylib)
   elseif (UNIX)
      set(V8_LIBRARIES ${V8_LIBS_DIR}/libchrome_zlib.so
                       ${V8_LIBS_DIR}/libcppgc.so
                       ${V8_LIBS_DIR}/libicui18n.so
                       ${V8_LIBS_DIR}/libicuuc.so
                       ${V8_LIBS_DIR}/libv8_libbase.so
                       ${V8_LIBS_DIR}/libv8_libplatform.so
                       ${V8_LIBS_DIR}/libv8.so)
   else()
      add_library(ImportedLibBase STATIC IMPORTED GLOBAL)
      set_property(TARGET ImportedLibBase PROPERTY IMPORTED_LOCATION ${V8_LIBS_DIR}/v8_libbase.lib)

      add_library(ImportedLibPlatform STATIC IMPORTED GLOBAL)
      set_property(TARGET ImportedLibPlatform PROPERTY IMPORTED_LOCATION ${V8_LIBS_DIR}/v8_libplatform.lib)

      add_library(ImportedV8Monolith STATIC IMPORTED GLOBAL)
      set_property(TARGET ImportedV8Monolith PROPERTY IMPORTED_LOCATION ${V8_LIBS_DIR}/v8_monolith.lib)
   endif(APPLE)

   # Import as an interface
   add_library(${V8Proj} INTERFACE)

   set (${V8Proj}_headers $<1:${V8_INCLUDE_DIR}/v8/v8.h>)
   target_sources(${V8Proj} INTERFACE $<BUILD_INTERFACE:${${V8Proj}_headers}>)
   target_include_directories(${V8Proj} SYSTEM INTERFACE "$<BUILD_INTERFACE:${V8_INCLUDE_DIR}/v8>")
   target_compile_definitions(${V8Proj} INTERFACE V8_COMPRESS_POINTERS V8_ENABLE_SANDBOX)

   # Add the target link libraries
   if (WIN32)
      target_link_libraries(${V8Proj} INTERFACE ImportedLibBase ImportedLibPlatform ImportedV8Monolith)
   else()
      target_link_libraries(${V8Proj} INTERFACE $<BUILD_INTERFACE:${V8_LIBRARIES}>)
   endif(WIN32)

   message(STATUS "V8_ROOT_DIR:    ${V8_ROOT_DIR}")
   message(STATUS "V8_INCLUDE_DIR: ${V8_INCLUDE_DIR}")
   message(STATUS "V8_LIBS_DIR:    ${V8_LIBS_DIR}")
   message(STATUS "V8_LIBRARIES:   ${V8_LIBRARIES}")
endfunction()

FindV8_Func()