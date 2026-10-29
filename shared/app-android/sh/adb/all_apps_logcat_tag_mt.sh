#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR=$(cd "${SCRIPT_DIR}/../../.." && pwd)

source "${ROOT_DIR}/commons/sh/commons.sh";

source "${SCRIPT_DIR}"/adb_setup.sh;
checkResult $?;

if [ -z "$*" ]; then
    $ADB logcat -s "MT";
else
    $ADB logcat -s "MT" | grep --color "$@";
fi
