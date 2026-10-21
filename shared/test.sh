#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="$SCRIPT_DIR";

source $ROOT_DIR/commons/sh/commons.sh;

echo "================================================================================";
echo "> TEST ALL...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

./test_only.sh
checkResult $?

./lint_only.sh
checkResult $?

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> TEST ALL... DONE";
echo "================================================================================";
