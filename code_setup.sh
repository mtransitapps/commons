#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/..";
source ${SCRIPT_DIR}/commons.sh;

# DEPRECATED: use ./sh/git_setup.sh && ./sh/shared_setup.sh;
# TODO: remove after update mtransitapps/gh-actions/.github/actions/setup)

echo "================================================================================";
echo "> CODE SETUP...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

${SCRIPT_DIR}/sh/git_setup.sh && ${SCRIPT_DIR}/sh/shared_setup.sh;
checkResult $?;

echo "--------------------------------------------------------------------------------";
AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> CODE SETUP... DONE ✓";
echo "================================================================================";
