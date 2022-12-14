cmake_minimum_required(VERSION 3.13)
# -----------------------------------------------------------------------------
# Basic setup
# -----------------------------------------------------------------------------
set(PROJECT_NAME grpc-project)
project(${PROJECT_NAME} LANGUAGES C CXX)

# set latest standard
# set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_FLAGS "-std=c++2b ${CMAKE_CXX_FLAGS}")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CONFIGURATION_TYPES Debug Release)
add_compile_options(
  # -Wall
  # -Wextra
  # -Wconversion
  # -Wsign-conversion
  $<$<CONFIG:DEBUG>:-g>
  $<$<CONFIG:DEBUG>:-Og>
  $<$<CONFIG:RELEASE>:-O3>
)
# set(CMAKE_CXX_FLAGS_RELEASE_INIT "-O3")
add_link_options()
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/arc)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
# file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/example)

file(GLOB_RECURSE SRCS
  CONFIGURE_DEPENDS
  ${CMAKE_SOURCE_DIR}/src/*.cpp)

file(GLOB_RECURSE HDRS
  CONFIGURE_DEPENDS
  ${CMAKE_SOURCE_DIR}/src/*.h
  ${CMAKE_SOURCE_DIR}/include/*.h
  ${CMAKE_SOURCE_DIR}/src/*.hpp
  ${CMAKE_SOURCE_DIR}/include/*.hpp)

file(GLOB_RECURSE TSTS
  CONFIGURE_DEPENDS
  ${CMAKE_SOURCE_DIR}/test/*.cpp)
# -----------------------------------------------------------------------------
# Configurations
# -----------------------------------------------------------------------------
if (DEFINED PROGRAM_GRPC)
  # LIBRARIES
  set(FETCHCONTENT_QUIET OFF)
  include(FetchContent)

  # gRPC
  FetchContent_Declare(
    gRPC
    GIT_REPOSITORY https://github.com/grpc/grpc
    GIT_TAG v1.48.0
  )
  FetchContent_MakeAvailable(gRPC)

  # Protobuff
  find_package(Protobuf REQUIRED)

  set(PROTO_PATH "${CMAKE_SOURCE_DIR}/protos")
  set(HELLOWORLD_PROTO "${PROTO_PATH}/helloworld.proto")

  set(GENERATED_PROTOBUF_PATH "${CMAKE_BINARY_DIR}/generated")
  file(MAKE_DIRECTORY ${GENERATED_PROTOBUF_PATH})
  set(HELLOWORLD_PB_CPP_FILE "${GENERATED_PROTOBUF_PATH}/helloworld.pb.cc")
  set(HELLOWORLD_PB_H_FILE "${GENERATED_PROTOBUF_PATH}/helloworld.pb.h")
  set(HELLOWORLD_GRPC_PB_CPP_FILE "${GENERATED_PROTOBUF_PATH}/helloworld.grpc.pb.cc")
  set(HELLOWORLD_GRPC_PB_H_FILE "${GENERATED_PROTOBUF_PATH}/helloworld.grpc.pb.h")
  add_custom_command(
    OUTPUT "${HELLOWORLD_PB_H_FILE}"
           "${HELLOWORLD_PB_CPP_FILE}"
           "${HELLOWORLD_GRPC_PB_H_FILE}"
           "${HELLOWORLD_GRPC_PB_CPP_FILE}"
    COMMAND ${PROTOBUF_PROTOC_EXECUTABLE}
    ARGS "--proto_path=${PROTO_PATH}"
         "--cpp_out=${GENERATED_PROTOBUF_PATH}"
         "${HELLOWORLD_PROTO}"
    COMMAND ${PROTOBUF_PROTOC_EXECUTABLE}
    ARGS "--proto_path=${PROTO_PATH}"
         "--grpc_out=${GENERATED_PROTOBUF_PATH}"
         "--plugin=protoc-gen-grpc=${CMAKE_BINARY_DIR}/_deps/grpc-build/grpc_cpp_plugin"
         "${HELLOWORLD_PROTO}"    
  )
  set(GENERATED_PROTOBUF_FILES ${HELLOWORLD_PB_H_FILE} ${HELLOWORLD_PB_CPP_FILE}
      ${HELLOWORLD_GRPC_PB_H_FILE} ${HELLOWORLD_GRPC_PB_CPP_FILE})
  include_directories(${GENERATED_PROTOBUF_PATH})

  # LINKING AND EXECUTABLES
  add_library(helloworld_grpc_proto STATIC ${GENERATED_PROTOBUF_FILES})
  target_link_libraries(helloworld_grpc_proto
    grpc++
    ${PROTOBUFF_LIBRARY})

  foreach(_target
    client server
    async-client async-server)
    add_executable(example_${_target} "${CMAKE_CURRENT_SOURCE_DIR}/src/example/${_target}.cpp")
    target_link_libraries(example_${_target} 
      helloworld_grpc_proto
      grpc++ 
      grpc++_reflection 
      ${PROTOBUF_LIBRARY})
  endforeach()
endif(DEFINED PROGRAM_GRPC)

if (DEFINED PROGRAM_MAIN)
  add_executable(main "src/main.cpp")
endif(DEFINED PROGRAM_MAIN)

# Ignore CMake warning: not used variable
set(ignoreMe "${PROGRAM_MAIN}${PROGRAM_GRPC}")
# Remove configuration variables from cache
unset(PROGRAM_GRPC CACHE)
unset(PROGRAM_MAIN CACHE)
# -----------------------------------------------------------------------------
# Testing
# -----------------------------------------------------------------------------
enable_testing()
# -----------------------------------------------------------------------------
# Formatting
# -----------------------------------------------------------------------------
# clang-format
add_custom_target(clang-format
        COMMAND
        clang-format
        -style=file
        -i
        ${SRCS} ${HDRS} ${TSTS}
        WORKING_DIRECTORY
        ${PROJECT_SOURCE_DIR}
        COMMENT
        "Running clang-format on sources..."
)
