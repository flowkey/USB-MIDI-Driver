export ANDROID_NDK_HOME='~/Library/Android/sdk/ndk-bundle'
export PATH=$PATH:$ANDROID_NDK_HOME

# ensure working dir is local to this script
cd "$(dirname "$0")"

ndk-build APP_ABI=armeabi-v7a NDK_PROJECT_PATH=$(pwd) APP_BUILD_SCRIPT=$(pwd)/Android.mk
