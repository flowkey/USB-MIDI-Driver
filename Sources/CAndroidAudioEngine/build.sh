export ANDROID_NDK_HOME='~/Library/Android/sdk/ndk-bundle'
export PATH=$PATH:$ANDROID_NDK_HOME
ndk-build APP_ABI=armeabi-v7a NDK_PROJECT_PATH=$(pwd) APP_BUILD_SCRIPT=$(pwd)/Android.mk
