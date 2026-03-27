#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}"/commons/commons.sh;
source "${SCRIPT_DIR}"/commons/adb_setup.sh;
checkResult $?;

MAIN_APP_PKG="org.mtransit.android.debug";

$ADB shell am force-stop "$MAIN_APP_PKG";
