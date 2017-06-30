export PATH=$PATH:~/.swiftyrobot

# ensure working dir is local to this script
cd "$(dirname "$0")"

# build CAndroidAudioEngine
Sources/CAndroidAudioEngine/build.sh

# build Swift Package with Swifty Robot
sr build --verbose