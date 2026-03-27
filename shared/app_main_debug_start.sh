#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}"/commons/commons.sh;
source "${SCRIPT_DIR}"/commons/adb_setup.sh;
checkResult $?;

MAIN_APP_PKG="org.mtransit.android.debug";
MAIN_APP_ACTIVITY="org.mtransit.android.ui.SplashScreenActivity";

$ADB shell am start \
  -n "$MAIN_APP_PKG"/"$MAIN_APP_ACTIVITY" \
  $@ \
;
