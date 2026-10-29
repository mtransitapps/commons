#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../.."; ROOT_DIR=$(realpath --relative-to="$PWD" "$ROOT_DIR");

source "${ROOT_DIR}/commons/sh/commons.sh"

./stage_res_current_schedule_stops.sh;
checkResult $?;

./stage_res_next_schedule_stops.sh;
checkResult $?;
