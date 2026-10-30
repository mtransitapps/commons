#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR=$(cd "${SCRIPT_DIR}/../.." && pwd);

source "${ROOT_DIR}/commons/sh/commons.sh";

echo "================================================================================";
echo "> TEST...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

setIsCI;
setGradleArgs;
setGitProjectName;

echo "> TESTS FOR '$PROJECT_NAME'... ";

"${ROOT_DIR}/gradlew" testAll ${GRADLE_ARGS};
checkResult $?;

if [[ $PROJECT_NAME == "mtransit-for-android" ]]; then
	echo ">> Running dependency guard...";
	"${ROOT_DIR}/gradlew" dependencyGuard ${GRADLE_ARGS};
	checkResult $?;
	echo ">> Running dependency guard... DONE";
fi

echo "> TESTS FOR '$PROJECT_NAME'... DONE";

echo "--------------------------------------------------------------------------------";
AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> TEST... DONE";
echo "================================================================================";
