#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}";

source ${ROOT_DIR}/commons/sh/commons.sh;

echo "================================================================================";
echo "> LINT...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

setIsCI;

setGradleArgs;

setGitProjectName;

CURRENT_DIR=$(pwd);
cd ${ROOT_DIR}/app-android || exit;

if [[ $PROJECT_NAME == "mtransit-for-android" ]]; then

	echo ">> Running lint...";
	${ROOT_DIR}/gradlew :app-android:lintDebug ${GRADLE_ARGS};
	checkResult $?;
	echo ">> Running lint... DONE";
fi

cd $CURRENT_DIR || exit;

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> LINT... DONE";
echo "================================================================================";
