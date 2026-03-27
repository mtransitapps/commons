#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}"/commons/commons.sh;
source "${SCRIPT_DIR}"/commons/adb_setup.sh;
checkResult $?;
source "${SCRIPT_DIR}"/app_main_setup.sh "debug";

$ADB shell am start \
  -n "$APP_PKG"/"$APP_ACTIVITY" \
  $@ \
;
