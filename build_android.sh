export PATH=$PATH:~/.swiftyrobot
sr build --verbose | sed 's/\/root\/host_fs//g'
exit ${PIPESTATUS[0]}
