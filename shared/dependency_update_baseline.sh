#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}"/commons/commons.sh;
echo "================================================================================";
echo "> DEPENDENCIES BASELINE UPDATE...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

echo "> Update dependencies baselines for 'app-android': ";
"${SCRIPT_DIR}"/gradlew :app-android:dependencyGuardBaseline;
checkResult $?;
rm -R "${SCRIPT_DIR}"/commons/shared-main/app-android/dependencies/;
checkResult $?;
cp -R "${SCRIPT_DIR}"/app-android/dependencies/ "${SCRIPT_DIR}"/commons/shared-main/app-android/;
checkResult $?;
git -C "${SCRIPT_DIR}"/commons diff -U0 shared-main/app-android/dependencies/*.txt;

echo "> Update dependencies baselines for 'parser': ";
"${SCRIPT_DIR}"/gradlew :parser:dependencyGuardBaseline;
checkResult $?;
rm -R "${SCRIPT_DIR}"/commons/shared-opt-dir/parser/dependencies/;
checkResult $?;
cp -R "${SCRIPT_DIR}"/parser/dependencies/ "${SCRIPT_DIR}"/commons/shared-opt-dir/parser/;
checkResult $?;
git -C "${SCRIPT_DIR}"/commons diff -U0 shared-opt-dir/parser/dependencies/*.txt;

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$((AFTER_DATE_SEC-BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> DEPENDENCIES BASELINE UPDATE... DONE";
echo "================================================================================";
