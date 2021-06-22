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
echo "RESULT: $? (fail ok/expected)";
echo ">> Cleaning keys... DONE";

cd ..;

echo "> Cleaning GIT repo... DONE";

if [[ ${IS_CI} = true ]]; then
    git config --global user.name 'MonTransit Bot';
    checkResult $?;
    git config --global user.email '84137772+montransit@users.noreply.github.com';
    checkResult $?;
fi

GIT_MSG="CI: sync code";
echo "GIT_MSG: $GIT_MSG";

echo "> GIT submodule > add...";
git submodule foreach git add -A;
checkResult $?;
echo "> GIT submodule > add... DONE";
echo "> GIT submodule > commit '$GIT_MSG'...";
# git submodule foreach git commit -q -m "$GIT_MSG";
git submodule foreach 'git diff-index --quiet HEAD || git commit -m "${GIT_MSG"';
checkResult $?;
echo "> GIT submodule > commit '$GIT_MSG'... DONE";
# TODO ? git submodule foreach git push;
echo "> GIT > add...";
git add -A;
checkResult $?;
echo "> GIT > add... DONE";
echo "> GIT submodule > commit '$GIT_MSG'...";
# git commit -q -m "$GIT_MSG";
git diff-index --quiet HEAD || git commit -m "$GIT_MSG";
checkResult $?;
echo "> GIT submodule > commit '$GIT_MSG'... DONE";

echo "DEBUG: ======================="
git status -sb;
echo "DEBUG: ======================="
git submodule foreach git status -sb;
echo "DEBUG: ======================="
git log -n 2 --pretty=format:"%h - %an (%ae), %ar (%ad) : %s" --date=iso;
echo "DEBUG: ======================="
git submodule foreach git log -n 2 --pretty=format:"%h - %an (%ae), %ar (%ad) : %s" --date=iso;
echo "DEBUG: ======================="
git diff --cached;
echo "DEBUG: ======================="
git submodule foreach git diff --cached;
echo "DEBUG: ======================="

exit 1; #STOP

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> COMMIT CODE CHANGE... DONE";
echo "================================================================================";
