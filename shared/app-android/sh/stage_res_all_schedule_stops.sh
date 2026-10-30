#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR=$(cd "${SCRIPT_DIR}/../.." && pwd);

source "${ROOT_DIR}/commons/sh/commons.sh"

./stage_res_current_schedule_stops.sh;
checkResult $?;

./stage_res_next_schedule_stops.sh;
checkResult $?;
