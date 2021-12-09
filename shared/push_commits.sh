#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> PUSH COMMITS...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

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

# GIT_MSG="CI: sync code";
# echo "GIT_MSG: $GIT_MSG";

echo "> GIT submodule > push...";
# TODO ? not working ? because default token only work for root repository
git submodule foreach git push; # git push fails if there are new changes on remote
checkResult $?;
# git -C app-andrid push;
# checkResult $?;
echo "> GIT submodule > push... DONE";
# echo "> GIT submodule > commit '$GIT_MSG'...";
# # git submodule foreach git commit -q -m "$GIT_MSG";
# # git submodule foreach git diff-index --quiet HEAD || git commit -m "$GIT_MSG";
# git submodule foreach "git diff-index --quiet HEAD || git commit -m '$GIT_MSG'";
# checkResult $?;
# echo "> GIT submodule > commit '$GIT_MSG'... DONE";
# # TODO ? git submodule foreach git push;

echo "> GIT > push...";
git push; # git push fails if there are new changes on remote
checkResult $?;
echo "> GIT > push... DONE";
# echo "> GIT > commit '$GIT_MSG'...";
# # git commit -q -m "$GIT_MSG";
# git diff-index --quiet HEAD || git commit -m "$GIT_MSG";
# checkResult $?;
# echo "> GIT > commit '$GIT_MSG'... DONE";

printGitStatus;

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> PUSH COMMITS... DONE";
echo "================================================================================";
