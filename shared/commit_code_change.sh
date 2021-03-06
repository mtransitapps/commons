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

setGitCommitEnabled;

if [[ ${MT_GIT_COMMIT_ENABLED} != true ]]; then
  echo "> Git commit NOT enabled.. SKIP";
  exit 0 # success
fi
echo "> Git commit enabled ...";

echo "> Cleaning GIT repo...";

cd app-android || exit;
DIRECTORY=$(basename ${PWD});

echo ">> Cleaning keys...";
./keys_cleanup.sh;
echo "RESULT: $? (fail ok/expected)";
echo ">> Cleaning keys... DONE";

cd ..;

echo "> Cleaning GIT repo... DONE";

setGitUser;

GIT_MSG="CI: sync code";
echo "GIT_MSG: $GIT_MSG";

echo "> GIT submodule > add...";
git submodule foreach git add -A;
checkResult $?;
echo "> GIT submodule > add... DONE";
echo "> GIT submodule > commit '$GIT_MSG'...";
# git submodule foreach git commit -q -m "$GIT_MSG";
# git submodule foreach git diff-index --quiet HEAD || git commit -m "$GIT_MSG";
git submodule foreach "git diff-index --quiet HEAD || git commit -m '$GIT_MSG'";
checkResult $?;
echo "> GIT submodule > commit '$GIT_MSG'... DONE";
# TODO ? git submodule foreach git push;

echo "> GIT > add...";
git add -A;
checkResult $?;
echo "> GIT > add... DONE";
echo "> GIT > commit '$GIT_MSG'...";
# git commit -q -m "$GIT_MSG";
git diff-index --quiet HEAD || git commit -m "$GIT_MSG";
checkResult $?;
echo "> GIT > commit '$GIT_MSG'... DONE";

printGitStatus;

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> COMMIT CODE CHANGE... DONE";
echo "================================================================================";
