#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> COMMIT DATA CHANGE..";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

CONFIRM=false;

setIsCI;

setGradleArgs;

echo "MT_ORG_GIT_COMMIT_ON: '$MT_ORG_GIT_COMMIT_ON'." # allowed
echo "MT_ORG_GIT_COMMIT_OFF: '$MT_ORG_GIT_COMMIT_OFF'." # forbidden
echo "MT_GIT_COMMIT_ON: '$MT_GIT_COMMIT_ON'." # allowed
echo "MT_GIT_COMMIT_OFF: '$MT_GIT_COMMIT_OFF'." # forbidden

if [[ ${MT_ORG_GIT_COMMIT_OFF} == true ]]; then
  echo "> Git commit disabled (org).. SKIP";
  exit 0 # success
fi

if [[ ${MT_GIT_COMMIT_OFF} == true ]]; then
  echo "> Git commit disabled (project).. SKIP";
  exit 0 # success
fi

if [[ ${MT_ORG_GIT_COMMIT_ON} != true && $MT_GIT_COMMIT_ON != true ]]; then
  echo "> Git commit not enabled (org:'$MT_ORG_GIT_COMMIT_ON'|project:'$MT_GIT_COMMIT_ON').. SKIP";
  exit 0 # success
fi

echo "> Git commit enabled ...";


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

GIT_MSG="CI: $(date +'%-B %-d update')";
echo "GIT_MSG: $GIT_MSG";

echo "> GIT app-android > add...";
git -C app-android add -A src/main/play; # release notes...
checkResult $?;
git -C app-android add -A src/main/res/value*; # values, values-fr...
checkResult $?;
git -C app-android add -A src/main/res-current; # main static schedule # required
checkResult $?;
if [[ -d "app-android/src/main/res-next" ]]; then
    git -C app-android add -A src/main/res-next; # next static schedule # optional
    checkResult $?;
fi
echo "> GIT app-android > add... DONE";
echo "> GIT app-android > commit '$GIT_MSG'...";
# git submodule foreach git commit -q -m "$GIT_MSG";
# git submodule foreach git diff-index --quiet HEAD || git commit -m "$GIT_MSG";
git -C app-android diff-index --quiet HEAD || git -C app-android commit -m "$GIT_MSG";
checkResult $?;
echo "> GIT app-android > commit '$GIT_MSG'... DONE";
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

echo "DEBUG: =======================";
git status -sb;
echo "DEBUG: =======================";
git submodule foreach git status -sb;
echo "DEBUG: =======================";
git log -n 7 --pretty=format:"%h - %an (%ae), %ar (%ad) : %s" --date=iso;
echo "DEBUG: =======================";
git submodule foreach git log -n 7 --pretty=format:"%h - %an (%ae), %ar (%ad) : %s" --date=iso;
echo "DEBUG: =======================";
git diff --cached;
echo "DEBUG: =======================";
git submodule foreach git diff --cached;
echo "DEBUG: =======================";

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> COMMIT DATA CHANGE... DONE";
echo "================================================================================";
