project(example)

# Set up files
set (${PROJECT_NAME}_sources hello-world.cc)

# create binaries
# ---------------
add_executable(${PROJECT_NAME} ${${PROJECT_NAME}_sources})
target_link_libraries(${PROJECT_NAME} PRIVATE V8Lib)

if (UNIX AND NOT APPLE)
   target_link_libraries(${PROJECT_NAME} INTERFACE stdc++fs)
endif()

include_directories(${PROJECT_NAME} INTERFACE $<BUILD_INTERFACE:$<1:${CMAKE_CURRENT_LIST_DIR}>>)

# Adding install destination
# --------------------------
install(TARGETS ${PROJECT_NAME}
        RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
        LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
        ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/static)
