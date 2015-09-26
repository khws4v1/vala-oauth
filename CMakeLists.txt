cmake_minimum_required(VERSION 2.6)

project(vala-oauth C)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/Vala_CMake/vala)
include(UseVala)

find_program(GLIB_COMPILE_RESOURCES
  NAMES glib-compile-resources
  HINTS ${GLIB_PREFIX})
if (NOT GLIB_COMPILE_RESOURCES)
  message(FATAL "Command not found: glib-compile-resources")
endif()
set(RESOURCE_C ${CMAKE_SOURCE_DIR}/src/resource.c)
set(RESOURCE_FILE ${CMAKE_SOURCE_DIR}/src/resource.xml)
add_custom_command(
  OUTPUT ${RESOURCE_C}
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/src
  COMMAND ${GLIB_COMPILE_RESOURCES} --generate-source --target ${RESOURCE_C} ${RESOURCE_FILE})

find_package(Vala REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED gtk+-3.0)
pkg_check_modules(REST REQUIRED rest-0.7)

add_definitions(${GTK_CFLAGS} ${GTK_CFLAGS_OTHER})
add_definitions(${REST_CFLAGS} ${REST_CFLAGS_OTHER})
link_libraries(${GTK_LIBRARIES})
link_libraries(${REST_LIBRARIES})
link_directories(${GTK_LIBRARY_DIRS})
link_directories(${REST_LIBRARY_DIRS})

vala_precompile(VALA_C
  /src/vala-oauth.vala
  PACKAGES gtk+-3.0 rest-0.7 posix
  OPTIONS --gresources src/resource.xml)

add_executable(vala-oauth ${VALA_C} ${RESOURCE_C})

