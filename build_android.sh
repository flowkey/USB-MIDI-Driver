export PATH=$PATH:~/.swiftyrobot

# ensure working dir is local to this script
cd "$(dirname "$0")"

# build Swift Package with Swifty Robot
sr build --verbose | sed 's/^\/root\/host_fs//g'

exit ${PIPESTATUS[0]}
