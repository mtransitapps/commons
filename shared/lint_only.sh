#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> LINT...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

CONFIRM=false;

setIsCI;

setGradleArgs;

setGitProjectName;

cd app-android || exit;

if [[ $PROJECT_NAME == "mtransit-for-android" ]]; then

	echo ">> Running lint...";
	../gradlew :app-android:lintDebug ${GRADLE_ARGS};
	RESULT=$?;
	checkResult ${RESULT};
	echo ">> Running lint... DONE";
fi

checkResult ${RESULT};

cd ..;

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> LINT... DONE";
echo "================================================================================";
