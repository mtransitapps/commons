#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR=$(cd "${SCRIPT_DIR}/../../.." && pwd)

source "${ROOT_DIR}/commons/sh/commons.sh";

source "${SCRIPT_DIR}"/adb_setup.sh;
checkResult $?;
source "${SCRIPT_DIR}"/app_setup.sh "debug";
checkResult $?;

$ADB shell pm grant "$APP_PKG" android.permission.POST_NOTIFICATIONS;