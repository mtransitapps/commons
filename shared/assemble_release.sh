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

setIsCI;

setGradleArgs;

IS_SHALLOW=$(git rev-parse --is-shallow-repository);
if [[ "$IS_SHALLOW" == true ]]; then
	echo "> Fetching unshallow GIT repo...";
	git fetch -v --unshallow;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo "> Error while fetching unshallow GIT repository!";
		exit ${RESULT};
	fi
	echo "> Fetching unshallow GIT repo... DONE";
else
	echo "> Not a shallow GIT repo.";
fi

cd app-android || exit;
DIRECTORY=$(basename ${PWD});

echo ">> Setup-ing keys...";
./keys_setup.sh;
checkResult $?;
echo ">> Setup-ing keys... DONE";

echo ">> Running bundle release AAB...";
../gradlew :${DIRECTORY}:bundleRelease ${GRADLE_ARGS};
RESULT=$?;
echo ">> Running bundle release AAB... DONE";

echo ">> Running assemble release APK..."; # for GH release
../gradlew :${DIRECTORY}:assembleRelease -PuseGooglePlayUploadKeysProperties=false ${GRADLE_ARGS};
RESULT=$?;
echo ">> Running assemble release APK... DONE";

echo ">> Cleaning keys...";
./keys_cleanup.sh;
checkResult $?;
echo ">> Cleaning keys... DONE";

checkResult $RESULT;

cd ..;

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> ASSEMBLE RELEASE... DONE";
echo "================================================================================";
