#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}";

source ${ROOT_DIR}/commons/sh/commons.sh;

echo "================================================================================";
echo "> TEST...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

ROOT_DIR_NAME=$(basename ${ROOT_DIR});
AGENCY_ID=$(basename -s -gradle ${ROOT_DIR_NAME});

setIsCI;

setGradleArgs;

setGitProjectName;

echo "> TESTS FOR '$AGENCY_ID' (GRADLE BUILD)... ";
./gradlew :commons-java:test ${GRADLE_ARGS}; # build includes test
checkResult $?;

if [[ -d "parser" ]]; then
	./gradlew :parser:test ${GRADLE_ARGS}; # build includes test
	checkResult $?;
fi

if [[ -d "agency-parser" ]]; then
	./gradlew :agency-parser:test ${GRADLE_ARGS}; # build includes test
	checkResult $?;
fi

echo "> TESTS FOR '$AGENCY_ID' (GRADLE BUILD)... DONE";

echo "> TESTS ANDROID APP FOR '$AGENCY_ID'...";
CURRENT_DIR=$(pwd);
cd ${ROOT_DIR}/app-android || exit;

echo ">> Running test...";
../gradlew :commons-android:testDebugUnitTest :app-android:testDebugUnitTest ${GRADLE_ARGS};
checkResult $?;
echo ">> Running test... DONE";

if [[ $PROJECT_NAME == "mtransit-for-android" ]]; then
	echo ">> Running dependency guard...";
	../gradlew :app-android:dependencyGuard :parser:dependencyGuard ${GRADLE_ARGS};
	checkResult $?;
	echo ">> Running dependency guard... DONE";
fi

cd $CURRENT_DIR || exit;
echo "> TESTS ANDROID APP FOR '$AGENCY_ID'... DONE";
echo "--------------------------------------------------------------------------------";

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> TEST... DONE";
echo "================================================================================";
