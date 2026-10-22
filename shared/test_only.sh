#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}";

source ${ROOT_DIR}/commons/sh/commons.sh;

echo "================================================================================";
echo "> TEST...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

setGitProjectName;

setIsCI;

setGradleArgs;

setGitProjectName;

echo "> TESTS FOR '$PROJECT_NAME' (GRADLE BUILD)... ";
${ROOT_DIR}/gradlew :commons-java:test ${GRADLE_ARGS}; # build includes test
checkResult $?;

if [[ -d "parser" ]]; then
	${ROOT_DIR}/gradlew :parser:test ${GRADLE_ARGS}; # build includes test
	checkResult $?;
fi

if [[ -d "agency-parser" ]]; then
	${ROOT_DIR}/gradlew :agency-parser:test ${GRADLE_ARGS}; # build includes test
	checkResult $?;
fi

echo "> TESTS FOR '$PROJECT_NAME' (GRADLE BUILD)... DONE";

echo "> TESTS ANDROID APP FOR '$PROJECT_NAME'...";

echo ">> Running test...";
${ROOT_DIR}/gradlew :commons-android:testDebugUnitTest :app-android:testDebugUnitTest ${GRADLE_ARGS};
checkResult $?;
echo ">> Running test... DONE";

if [[ $PROJECT_NAME == "mtransit-for-android" ]]; then
	echo ">> Running dependency guard...";
	${ROOT_DIR}/gradlew :app-android:dependencyGuard :parser:dependencyGuard ${GRADLE_ARGS};
	checkResult $?;
	echo ">> Running dependency guard... DONE";
fi

echo "> TESTS ANDROID APP FOR '$PROJECT_NAME'... DONE";
echo "--------------------------------------------------------------------------------";

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> TEST... DONE";
echo "================================================================================";
