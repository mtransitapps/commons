#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> DEPENDENCY UPDATE > COMMIT CODE CHANGE..";
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

setGitCommitDependencyUpdateEnabled;

if [[ ${MT_GIT_COMMIT_ENABLED} != true && ${MT_GIT_COMMIT_DEPENDENCY_UPDATE_ENABLED} != true ]]; then
  echo "> Git commit NOT enabled.. SKIP (MT_GIT_COMMIT_ENABLED:$MT_GIT_COMMIT_ENABLED|MT_GIT_COMMIT_DEPENDENCY_UPDATE_ENABLED:$MT_GIT_COMMIT_DEPENDENCY_UPDATE_ENABLED)";
  exit 0 # success
fi
echo "> Git commit enabled ...";

cd app-android || exit;
./keys_cleanup.sh; # FAIL OK
cd ..;

setGitUser;

GIT_MSG="CI: dependencies update";
echo "GIT_MSG: $GIT_MSG";

VERSIONS_FILE="gradle/libs.versions.toml";

echo "> GIT commons > add $VERSIONS_FILE...";
git -C commons add -v $VERSIONS_FILE;
checkResult $?;
echo "> GIT commons > add $VERSIONS_FILE... DONE";

echo "> GIT commons > diff staged...";
git -C commons diff -U0 --staged;
checkResult $?;
echo "> GIT commons > diff staged... DONE";

echo "> GIT commons > commit '$GIT_MSG'...";
git -C commons diff-index --quiet HEAD || git -C commons commit -m "$GIT_MSG";
checkResult $?;
echo "> GIT commons > commit '$GIT_MSG'... DONE";

printGitStatus;

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$((AFTER_DATE_SEC-BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> DEPENDENCY UPDATE > COMMIT CODE CHANGE... DONE";
echo "================================================================================";
