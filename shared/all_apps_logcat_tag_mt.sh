#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}"/commons/commons.sh;
source "${SCRIPT_DIR}"/commons/adb_setup.sh;
checkResult $?;

if [ -z "$*" ]; then
    $ADB logcat -s "MT";
else
    $ADB logcat -s "MT" | grep --color "$@";
fi
