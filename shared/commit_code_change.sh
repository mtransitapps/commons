#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> COMMIT CODE CHANGE..";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

CONFIRM=false;

setIsCI;

setGradleArgs;

# ./gradlew androidDependencies ${GRADLE_ARGS};
# checkResult $?;

echo "> Cleaning GIT repo...";

cd app-android || exit;
DIRECTORY=$(basename ${PWD});

echo ">> Cleaning keys...";
./keys_cleanup.sh;
echo "RESULT: $?";
echo ">> Cleaning keys... DONE";

cd ..;

echo "> Cleaning GIT repo... DONE";

GIT_MSG="CI: sync code";
echo "GIT_MSG: $GIT_MSG";

git submodule foreach git add .;
git submodule foreach git commit -q -m "$GIT_MSG";
# TODO ? git submodule foreach git push;
git add .;
git commit -q -m "$GIT_MSG";

echo "DEBUG: ======================="
git status -sb;
git submodule foreach git status -sb;
git log -n 2;
git submodule foreach log -n 2;
echo "DEBUG: ======================="

exit 1; #STOP

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> COMMIT CODE CHANGE... DONE";
echo "================================================================================";
