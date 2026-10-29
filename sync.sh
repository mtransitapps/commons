#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR=$(cd "${SCRIPT_DIR}/.." && pwd);

source "${ROOT_DIR}/commons/sh/commons.sh";

# DEPRECATED: use ./commons/sh/git_setup.sh && ./commons/sh/shared_setup.sh;
# TODO: remove after update 'mtransitapps:mtransit-for-android/.gitlab-ci.yml': https://github.com/mtransitapps/mtransit-for-android/blob/master/.gitlab-ci.yml

echo "================================================================================";
echo "> SYNC...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

${ROOT_DIR}/commons/sh/git_setup.sh && ${ROOT_DIR}/commons/sh/shared_setup.sh;
checkResult $?;

echo "--------------------------------------------------------------------------------";
AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> SYNC... DONE ✓";
echo "================================================================================";
