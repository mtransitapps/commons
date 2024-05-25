#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> DEPENDENCY UPDATE > PUSH COMMITS...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

setIsCI;

setGradleArgs;

setGitCommitEnabled;

setGitCommitDependencyUpdateEnabled;

if [[ ${MT_GIT_COMMIT_ENABLED} != true && ${MT_GIT_COMMIT_DEPENDENCY_UPDATE_ENABLED} != true ]]; then
  echo "> Git commit NOT enabled.. SKIP (MT_GIT_COMMIT_ENABLED:$MT_GIT_COMMIT_ENABLED|MT_GIT_COMMIT_DEPENDENCY_UPDATE_ENABLED:$MT_GIT_COMMIT_DEPENDENCY_UPDATE_ENABLED)";
  exit 0 # success
fi
echo "> Git commit enabled ...";

cd app-android || exit;
echo ">> Cleaning keys...";
./keys_cleanup.sh;
echo "RESULT: $? (fail ok/expected)";
echo ">> Cleaning keys... DONE";
cd ..;

setGitUser;

echo "> GIT commons > push...";
git -C commons push; # git push fails if there are new changes on remote
checkResult $?;
echo "> GIT commons > push... DONE";

printGitStatus;

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> DEPENDENCY UPDATE > PUSH COMMITS... DONE";
echo "================================================================================";
