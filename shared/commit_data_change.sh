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

setGitCommitEnabled;

if [[ ${MT_GIT_COMMIT_ENABLED} != true ]]; then
  echo "> Git commit NOT enabled.. SKIP";
  exit 0 # success
fi
echo "> Git commit enabled ...";


# ./gradlew androidDependencies ${GRADLE_ARGS};
# checkResult $?;

echo "> Cleaning GIT repo...";

cd app-android || exit;

echo ">> Cleaning keys...";
./keys_cleanup.sh;
echo "RESULT: $? (fail ok/expected)";
echo ">> Cleaning keys... DONE";

cd ..;

echo "> Cleaning GIT repo... DONE";

setGitUser;

GIT_MSG="CI: $(date +'%-B %-d update')";
echo "GIT_MSG: $GIT_MSG";

echo "> GIT app-android > add...";
git -C app-android add -A src/main/play; # release notes...
checkResult $?;
git -C app-android add -A src/main/res/value*; # values, values-fr...
checkResult $?;
if [[ -d "app-android/src/main/res-current" ]]; then # not in main app
  git -C app-android add -A src/main/res-current; # main static schedule # required for non-bike agency modules
  checkResult $?;
  if [[ -d "app-android/src/main/res-next" ]]; then
      git -C app-android add -A src/main/res-next; # next static schedule # optional
      checkResult $?;
  fi
fi
echo "> GIT app-android > add... DONE";
echo "> GIT app-android > commit '$GIT_MSG'...";
# git submodule foreach git commit -q -m "$GIT_MSG";
# git submodule foreach git diff-index --quiet HEAD || git commit -m "$GIT_MSG";
git -C app-android diff --staged --quiet || git -C app-android commit -m "$GIT_MSG";
checkResult $?;
echo "> GIT app-android > commit '$GIT_MSG'... DONE";
# TODO ? git submodule foreach git push;

echo "> GIT > add...";
git add -A;
checkResult $?;
echo "> GIT > add... DONE";
echo "> GIT > commit '$GIT_MSG'...";
# git commit -q -m "$GIT_MSG";
git diff --staged --quiet || git commit -m "$GIT_MSG";
checkResult $?;
echo "> GIT > commit '$GIT_MSG'... DONE";

printGitStatus;

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> COMMIT DATA CHANGE... DONE";
echo "================================================================================";
