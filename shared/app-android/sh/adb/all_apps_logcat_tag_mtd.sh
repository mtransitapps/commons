#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR="${SCRIPT_DIR}/../../..";
source "${ROOT_DIR}"/commons/commons.sh;
source "${SCRIPT_DIR}"/adb_setup.sh;
checkResult $?;

if [ -z "$*" ]; then
    $ADB logcat -s "MTD";
else
    $ADB logcat -s "MTD" | grep --color "$@";
fi
