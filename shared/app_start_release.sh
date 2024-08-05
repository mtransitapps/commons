#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}"/commons/commons.sh;
source "${SCRIPT_DIR}"/commons/adb_setup.sh;
checkResult $?;
source "${SCRIPT_DIR}"/app_setup.sh;
checkResult $?;

$ADB shell monkey -p "$APP_PKG" -c android.intent.category.LAUNCHER 1
