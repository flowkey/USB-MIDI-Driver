BUILD_CONFIGURATION="debug" # release | debug
echo "Building Android NoteDetection for $BUILD_CONFIGURATION..."

sr build -c $BUILD_CONFIGURATION | sed 's/\/root\/host_fs//g'
exit ${PIPESTATUS[0]}
