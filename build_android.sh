#!/bin/bash

set -e

SCRIPT_ROOT=$(cd $(dirname $0); echo -n $PWD) # path of this file

echo "Building Android NoteDetection for $BUILD_CONFIGURATION..."

export CMAKE_BUILD_TYPE="Debug" # Release | Debug | ...
export ANDROID_ABI="armeabi-v7a" 

SWIFT_BUILD=${PATH_TO_SWIFT_TOOLCHAIN:-"../UIKit/swift-android-toolchain/swift-build.sh"}
$SWIFT_BUILD $SCRIPT_ROOT
