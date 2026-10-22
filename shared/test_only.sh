#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> TEST...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

setIsCI;

setGradleArgs;

setGitProjectName;

echo "> TESTS FOR '$AGENCY_ID' (GRADLE BUILD)... ";

./gradlew testAll ${GRADLE_ARGS}; # build includes test
checkResult $?;

echo "> TESTS FOR '$AGENCY_ID' (GRADLE BUILD)... DONE";

if [[ $PROJECT_NAME == "mtransit-for-android" ]]; then
	echo ">> Running dependency guard...";
	./gradlew dependencyGuard ${GRADLE_ARGS};
	checkResult $?;
	echo ">> Running dependency guard... DONE";
fi

echo "--------------------------------------------------------------------------------";

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> TEST... DONE";
echo "================================================================================";
