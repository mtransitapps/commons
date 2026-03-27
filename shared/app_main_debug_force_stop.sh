#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}"/commons/commons.sh;
source "${SCRIPT_DIR}"/commons/adb_setup.sh;
checkResult $?;
checkResult $?;
source "${SCRIPT_DIR}"/app_main_setup.sh "debug";

$ADB shell am force-stop "$APP_PKG";
