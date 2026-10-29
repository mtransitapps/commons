#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR="${SCRIPT_DIR}/../../.."; ROOT_DIR=$(realpath --relative-to="$ROOT_DIR" "$ROOT_DIR");

source "${ROOT_DIR}/commons/sh/commons.sh";

source "${SCRIPT_DIR}"/pidcat_setup.sh;
checkResult $?;
source "${SCRIPT_DIR}"/app_setup.sh;
checkResult $?;

$PIDCAT "$APP_PKG" "$@";
