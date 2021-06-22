#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> ASSEMBLE RELEASE..";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

CONFIRM=false;

setIsCI;

setGradleArgs;

IS_SHALLOW=$(git rev-parse --is-shallow-repository);
if [[ "$IS_SHALLOW" == true ]]; then
	echo "> Fetching unshallow GIT repo...";
	git fetch --unshallow;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo "> Error while fetching unshallow GIT repository!";
		exit ${RESULT};
	fi
	echo "> Fetching unshallow GIT repo... DONE";
else
	echo "> Not a shallow GIT repo.";
fi

echo ">> Setup-ing keys...";
./keys_setup.sh;
checkResult $?;
echo ">> Setup-ing keys... DONE";

echo ">> Running bundle release AAB...";
./gradlew :${CURRENT_DIRECTORY}:bundleRelease ${GRADLE_ARGS};
checkResult $?;
echo ">> Running bundle release AAB... DONE";

echo ">> Cleaning keys...";
./keys_cleanup.sh;
checkResult $?;
echo ">> Cleaning keys... DONE";

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> ASSEMBLE RELEASE... DONE";
echo "================================================================================";
