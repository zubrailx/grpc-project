cmake_minimum_required(VERSION 3.13)

set(PROJECT_NAME grpc-project)
set(EXEC_NAME grpc-exec)

project(${PROJECT_NAME} LANGUAGES C CXX)
add_executable(${EXEC_NAME} src/main.cpp)

# set latest standard
set(CMAKE_CXX_STANDARD 23)
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

# link libraries
target_link_libraries(${EXEC_NAME} grpc++)

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
)
