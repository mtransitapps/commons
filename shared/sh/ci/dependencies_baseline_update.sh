#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR=$(cd "${SCRIPT_DIR}/../.." && pwd);

source "${ROOT_DIR}/commons/sh/commons.sh";

echo "================================================================================";
echo "> DEPENDENCIES BASELINE UPDATE...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

echo "> Update dependencies baselines for 'app-android': ";
"${ROOT_DIR}"/gradlew :app-android:dependencyGuardBaseline;
checkResult $?;
rm -R "${ROOT_DIR}/commons"/shared-main/app-android/dependencies/;
checkResult $?;
cp -R "${ROOT_DIR}"/app-android/dependencies/ "${ROOT_DIR}/commons"/shared-main/app-android/;
checkResult $?;
git -C "${ROOT_DIR}/commons" diff -U0 shared-main/app-android/dependencies/*.txt;

echo "> Update dependencies baselines for 'parser': ";
"${ROOT_DIR}"/gradlew :parser:dependencyGuardBaseline;
checkResult $?;
rm -R "${ROOT_DIR}/commons"/shared-opt-dir/parser/dependencies/;
checkResult $?;
cp -R "${ROOT_DIR}"/parser/dependencies/ "${ROOT_DIR}/commons"/shared-opt-dir/parser/;
checkResult $?;
git -C "${ROOT_DIR}/commons" diff -U0 shared-opt-dir/parser/dependencies/*.txt;

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$((AFTER_DATE_SEC-BEFORE_DATE_SEC));
echo "--------------------------------------------------------------------------------";
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> DEPENDENCIES BASELINE UPDATE... DONE";
echo "================================================================================";
