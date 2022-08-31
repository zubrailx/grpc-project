#!/bin/bash

set -o errexit
set -o nounset
USAGE="Usage:
      \t[-v | --verbose]\n
      \t[debug | release]\n
      \t[reset - rm -rf ./build]\n
      \t[generate - generate buildtree [\`key | key=value\` - cmake variables]]\n
      \t[clean]\n
      \t[target=value]"

CMAKE=cmake
BUILD=./build
TYPE=DEBUG
BUILD_DIR=$BUILD/debug
CLEAN=
RESET=
VERBOSE=
GENERATE=
JOBS="-j8"
CMAKE_BUILDTREE_VARIABLES="" 
CMAKE_BUILDTREE_OPTIONS="" # --warn-uninitialized
CMAKE_BUILD_OPTIONS=""

for arg; do
  key=${arg%%=*}
  value=${arg#*=} # file arg without = then [value = key]
  case "$key" in
    --help|-h|help)    echo -e $USAGE; exit 0;;
    -v|--verbose) VERBOSE='--log-level=VERBOSE'  ;;
    debug)        TYPE=DEBUG;   BUILD_DIR=$BUILD/debug ;;
    release)      TYPE=RELEASE; BUILD_DIR=$BUILD/release ;;
    clean)        CLEAN=1  ;;
    reset)        RESET=1 ;;
    gen|generate)     GENERATE=1 ;;
    target)       CMAKE_BUILD_OPTIONS="$CMAKE_BUILD_OPTIONS --target $value";;
    *)            if [ "$key" = "$value" ]; then
                    CMAKE_BUILDTREE_VARIABLES="$CMAKE_BUILDTREE_VARIABLES $key=''"
                  else
                    CMAKE_BUILDTREE_VARIABLES="$CMAKE_BUILDTREE_VARIABLES $key=$value"
                  fi ;;
  esac
done

# COMMANDS
# Reset
[[ -n $RESET && -d $BUILD_DIR ]] && rm -rf $BUILD_DIR
# Generate
[[ "$GENERATE" -ne 0 ]] && $CMAKE -S . -B $BUILD_DIR $CMAKE_BUILDTREE_OPTIONS -DCMAKE_BUILD_TYPE=$TYPE $CMAKE_BUILDTREE_VARIABLES
# Clean
[[ -n $CLEAN ]] && $CMAKE --build $BUILD_DIR --target clean
# Build
$CMAKE --build $BUILD_DIR $VERBOSE $JOBS $CMAKE_BUILD_OPTIONS
