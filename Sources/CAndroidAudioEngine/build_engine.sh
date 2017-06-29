# chmod +x build_engine.sh
# or
# chmod 777 build_engine.sh

#!/bin/bash

mkdir -p build

echo "Compiling..."
g++ -c Sources/AndroidAudioEngineWrapper.cpp -o .engineBuild/AndroidAudioEngineWrapper.o

echo "Make static lib..."
ar rvs .engineBuild/libAndroidAudioEngineWrapper.a .engineBuild/AndroidAudioEngineWrapper.o

