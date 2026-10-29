#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR=$(cd "${SCRIPT_DIR}/../../.." && pwd)

source "${ROOT_DIR}/commons/sh/commons.sh";

source "${SCRIPT_DIR}"/adb_setup.sh;
checkResult $?;
source "${SCRIPT_DIR}"/app_setup.sh;
checkResult $?;

$ADB shell monkey -p "$APP_PKG" -c android.intent.category.LAUNCHER 1;
# $ADB shell am start -n "$APP_PKG"/"$APP_ACTIVITY" "$@"; # different starting activity for main & modules apps
