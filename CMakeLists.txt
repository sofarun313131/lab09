cmake_minimum_required(VERSION 3.11)

# Подключаем HunterGate ДО объявления project()
include("cmake/HunterGate.cmake")
HunterGate(
    URL "https://github.com/cpp-pm/hunter/archive/v0.23.251.tar.gz"
    SHA1 "5659b15dc0884d4b03dbd95710e6a1fa0fc3258d"
)

project(print)

set(PRINT_VERSION_MAJOR 0)
set(PRINT_VERSION_MINOR 1)
set(PRINT_VERSION_PATCH 0)
set(PRINT_VERSION_TWEAK 0)
set(PRINT_VERSION "${PRINT_VERSION_MAJOR}.${PRINT_VERSION_MINOR}.${PRINT_VERSION_PATCH}.${PRINT_VERSION_TWEAK}")
set(PRINT_VERSION_STRING "v${PRINT_VERSION}")

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(BUILD_TESTS "Build tests" OFF)

add_library(print STATIC ${CMAKE_CURRENT_SOURCE_DIR}/sources/print.cpp)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

add_executable(example1 ${CMAKE_CURRENT_SOURCE_DIR}/examples/example1.cpp)
add_executable(example2 ${CMAKE_CURRENT_SOURCE_DIR}/examples/example2.cpp)
target_link_libraries(example1 print)
target_link_libraries(example2 print)

# Подключение утилиты GTest через Hunter
if(BUILD_TESTS)
  enable_testing()
  add_compile_options(-Wno-error=maybe-uninitialized)
  
  # Запрашиваем GTest у Хантера
  hunter_add_package(GTest)
  find_package(GTest CONFIG REQUIRED)
  
  file(GLOB ${PROJECT_NAME}_TEST_SOURCES tests/*.cpp)
  add_executable(check ${${PROJECT_NAME}_TEST_SOURCES})
  
  # Связываем с таргетом GTest::gtest_main (так его экспортирует Hunter)
  target_link_libraries(check GTest::gtest_main print)
  add_test(NAME check COMMAND check)
endif()

# Создание дополнительного исполняемого файла демо-программы
add_executable(demo ${CMAKE_CURRENT_SOURCE_DIR}/demo/main.cpp)
target_link_libraries(demo print)
install(TARGETS demo RUNTIME DESTINATION bin)

include(CPackConfig.cmake)

# Настройки создания пакета (Лабораторная 9)
set(CPACK_GENERATOR "TGZ")
set(CPACK_PACKAGE_VERSION "0.1.0")
include(CPack)
