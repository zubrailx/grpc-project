cmake_minimum_required(VERSION 3.13)

set(PROJECT_NAME grpc-project)
# set(EXEC_NAME grpc-exec)
# set(CLIENT_EXEC_NAME grpc-client-exec)
# set(SERVER_EXEC_NAME grpc-server-exec)

project(${PROJECT_NAME} LANGUAGES C CXX)
# add_executable(${EXEC_NAME} src/main.cpp)
# add_executable(${CLIENT_EXEC_NAME} src/client.cpp)
# add_executable(${SERVER_EXEC_NAME} src/server.cpp)

# set latest standard
# set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_FLAGS "-std=c++2b ${CMAKE_CXX_FLAGS}")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CONFIGURATION_TYPES Debug Release)
set(CMAKE_CXX_FLAGS_RELEASE_INIT "-O3")

# add libraries
set(FETCHCONTENT_QUIET OFF)
include(FetchContent)

# GRPC
FetchContent_Declare(
  gRPC
  GIT_REPOSITORY https://github.com/grpc/grpc
  GIT_TAG v1.48.0
)
FetchContent_MakeAvailable(gRPC)

# PROTOBUFF
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
# link_libraries(grpc++_unsecure grpc gpr )

link_libraries(grpc++ grpc++_reflection ${PROTOBUF_LIBRARY})

add_executable(greeter_server src/example/server.cpp ${GENERATED_PROTOBUF_FILES})
add_executable(greeter_client src/example/client.cpp ${GENERATED_PROTOBUF_FILES})
# add_executable(greeter_async_server src/server-async.cpp ${GENERATED_PROTOBUF_FILES})
# add_executable(greeter_async_client src/client-async.cpp ${GENERATED_PROTOBUF_FILES})

#[[ # link libraries
# target_link_libraries(${EXEC_NAME} grpc++)
target_link_libraries(${CLIENT_EXEC_NAME} grpc++)
target_link_libraries(${SERVER_EXEC_NAME} grpc++)

# testing
enable_testing()

# clang-format
add_custom_target(clang-format
        COMMAND
        clang-format
        -style=file
        -i
        ${SRCS} ${HDRS} ${TESTS}
        WORKING_DIRECTORY
        ${PROJECT_SOURCE_DIR}
        COMMENT
        "Running clang-format on sources..."
) ]]
