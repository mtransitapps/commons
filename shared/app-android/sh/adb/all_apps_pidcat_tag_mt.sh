#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR="${SCRIPT_DIR}/../../..";
source "${ROOT_DIR}"/commons/commons.sh;
source "${SCRIPT_DIR}"/pidcat_setup.sh;
checkResult $?;

$PIDCAT --tag MT "$@";
