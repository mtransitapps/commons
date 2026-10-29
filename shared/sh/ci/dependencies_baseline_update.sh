#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR=$(cd "${SCRIPT_DIR}/../.." && pwd)

source "${ROOT_DIR}/commons/sh/commons.sh";

echo "================================================================================";
echo "> DEPENDENCIES BASELINE UPDATE...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

COMMONS_DIR="${ROOT_DIR}/commons";

echo "> Update dependencies baselines for 'app-android': ";
"${ROOT_DIR}"/gradlew :app-android:dependencyGuardBaseline;
checkResult $?;
rm -R "${COMMONS_DIR}"/shared-main/app-android/dependencies/;
checkResult $?;
cp -R "${ROOT_DIR}"/app-android/dependencies/ "${COMMONS_DIR}"/shared-main/app-android/;
checkResult $?;
git -C "${COMMONS_DIR}" diff -U0 shared-main/app-android/dependencies/*.txt;

echo "> Update dependencies baselines for 'parser': ";
"${ROOT_DIR}"/gradlew :parser:dependencyGuardBaseline;
checkResult $?;
rm -R "${COMMONS_DIR}"/shared-opt-dir/parser/dependencies/;
checkResult $?;
cp -R "${ROOT_DIR}"/parser/dependencies/ "${COMMONS_DIR}"/shared-opt-dir/parser/;
checkResult $?;
git -C "${COMMONS_DIR}" diff -U0 shared-opt-dir/parser/dependencies/*.txt;

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$((AFTER_DATE_SEC-BEFORE_DATE_SEC));
echo "--------------------------------------------------------------------------------";
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> DEPENDENCIES BASELINE UPDATE... DONE";
echo "================================================================================";
