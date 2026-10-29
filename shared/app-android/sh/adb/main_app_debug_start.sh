#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR="${SCRIPT_DIR}/../../.."; ROOT_DIR=$(realpath --relative-to="$PWD" "$ROOT_DIR");

source "${ROOT_DIR}/commons/sh/commons.sh";

source "${SCRIPT_DIR}"/adb_setup.sh;
checkResult $?;
source "${SCRIPT_DIR}"/main_app_setup.sh "debug";
checkResult $?;

$ADB shell am start -n "$APP_PKG"/"$APP_ACTIVITY" "$@";
