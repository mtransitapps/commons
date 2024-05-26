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

setIsCI;

setGradleArgs;

setGitProjectName;

setGitCommitEnabled;

if [[ ${MT_GIT_COMMIT_ENABLED} != true ]]; then
  echo "> Git commit NOT enabled.. SKIP";
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

GIT_MSG="CI: $(date +'%-B %-d update')";
echo "GIT_MSG: $GIT_MSG";

APP_ANDROID_PATH="."; # "-C ."
if [[ $GIT_PROJECT_NAME == *"-gradle"* ]]; then # OLD REPO
  APP_ANDROID_PATH="app-android";
fi

SRC_PATH="app-android/src";
if [[ $GIT_PROJECT_NAME == *"-gradle"* ]]; then # OLD REPO
  SRC_PATH="src";
fi

echo "> GIT $APP_ANDROID_PATH > add...";
git -C $APP_ANDROID_PATH add -v -A $SRC_PATH/main/play; # release notes...
checkResult $?;
git -C $APP_ANDROID_PATH add -v -A $SRC_PATH/main/res/value*; # values, values-fr...
checkResult $?;
if [[ -d "app-android/src/main/res-current" ]]; then # not in main app
  git -C $APP_ANDROID_PATH add -v -A $SRC_PATH/main/res-current; # main static schedule # required for non-bike agency modules
  checkResult $?;
  if [[ -d "app-android/src/main/res-next" ]]; then
      git -C $APP_ANDROID_PATH add -v -A $SRC_PATH/main/res-next; # next static schedule # optional
      checkResult $?;
  fi
fi
echo "> GIT $APP_ANDROID_PATH > add... DONE";
echo "> GIT $APP_ANDROID_PATH > commit '$GIT_MSG'...";
# git -C $APP_ANDROID_PATH git commit -q -m "$GIT_MSG";
# git -C $APP_ANDROID_PATH git diff-index --quiet HEAD || git commit -m "$GIT_MSG";
git -C $APP_ANDROID_PATH diff --staged --quiet || git -C $APP_ANDROID_PATH commit -m "$GIT_MSG";
checkResult $?;
echo "> GIT $APP_ANDROID_PATH > commit '$GIT_MSG'... DONE";
# TODO ? git -C $APP_ANDROID_PATH git push;

if [[ $GIT_PROJECT_NAME == *"-gradle"* ]]; then # OLD REPO
  echo "> GIT > add...";
  git add -v -A;
  checkResult $?;
  echo "> GIT > add... DONE";
  echo "> GIT > commit '$GIT_MSG'...";
  # git commit -q -m "$GIT_MSG";
  git diff --staged --quiet || git commit -m "$GIT_MSG";
  checkResult $?;
  echo "> GIT > commit '$GIT_MSG'... DONE";
  # TODO ? git push;
fi

printGitStatus;

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> COMMIT DATA CHANGE... DONE";
echo "================================================================================";
