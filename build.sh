#!/bin/bash

set -o errexit
set -o nounset
USAGE="Usage: $(basename $0) [-v | --verbose] [ reset | clean | debug | release | toolchain=value ]"

CMAKE=cmake
BUILD=./build
TYPE=DEBUG
BUILD_DIR=$BUILD/debug
CLEAN=
RESET=
VERBOSE=
TOOLCHAIN=
TOOLCHAIN_FILE=  # specify default toolchain and then it can be overriden using toolchain=value arg
JOBS="-j8"

for arg; do
  key=${arg%%=*}
  value=${arg#*=} # file arg without = then [value = key]
  case "$key" in
    --help|-h)    echo $USAGE; exit 0;;
    -v|--verbose) VERBOSE='--log-level=VERBOSE'  ;;
    debug)        TYPE=DEBUG;   BUILD_DIR=$BUILD/debug ;;
    release)      TYPE=RELEASE; BUILD_DIR=$BUILD/release ;;
    clean)        CLEAN=1  ;;
    reset)        RESET=1 ;;
    toolchain)    TOOLCHAIN_FILE=$value ;;
    *)            echo -e "unknown option $key\n$USAGE" >&2;  exit 1 ;;
  esac
done

# override toolchain 
[[ -n $TOOLCHAIN_FILE ]] && TOOLCHAIN=-DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_FILE

# commands
[[ -n $RESET && -d $BUILD_DIR ]] && rm -rf $BUILD_DIR
    
$CMAKE -S . -B $BUILD_DIR --warn-uninitialized -DCMAKE_BUILD_TYPE=$TYPE $TOOLCHAIN

[[ -n $CLEAN ]] && $CMAKE --build $BUILD_DIR --target clean

$CMAKE --build $BUILD_DIR $VERBOSE $JOBS
