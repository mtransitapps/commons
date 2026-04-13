#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh

${SCRIPT_DIR}/check_data_not_outdated.sh;
exit $?;
