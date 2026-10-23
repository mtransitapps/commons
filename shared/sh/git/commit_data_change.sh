#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../..";

source ${ROOT_DIR}/commons/sh/commons.sh

echo "================================================================================";
echo "> COMMIT DATA CHANGE..";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

setIsCI;

setGradleArgs;

setGitProjectName;

setGitCommitEnabled;

if [[ ${MT_GIT_COMMIT_ENABLED} != true ]]; then
  echo "> Git commit NOT enabled.. SKIP";
  exit 0 # success
fi
echo "> Git commit enabled ...";

${ROOT_DIR}/app-android/sh/keys/cleanup.sh; # FAIL OK

setGitUser;

GIT_MSG="CI: $(date +'%-B %-d update')";
echo "GIT_MSG: $GIT_MSG";

APP_ANDROID_PATH="."; # "-C ."

SRC_PATH="app-android/src";

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

printGitStatus;

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> COMMIT DATA CHANGE... DONE";
echo "================================================================================";
