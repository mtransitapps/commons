#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";

exec "${SCRIPT_DIR}/check_data_not_outdated.sh" "$@";
