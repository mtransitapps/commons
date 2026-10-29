#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR=$(cd "${SCRIPT_DIR}/../.." && pwd)

source "${ROOT_DIR}/commons/sh/commons.sh"

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

echo "> GIT $ROOT_DIR > add...";
git -C "$ROOT_DIR" add -v -A "app-android/src/main/play"; # release notes...
checkResult $?;
git -C "$ROOT_DIR" add -v -A "app-android/src/main/res/value*"; # values, values-fr...
checkResult $?;
if [[ -d "$ROOT_DIR/app-android/src/main/res-current" ]]; then # not in main app
  git -C "$ROOT_DIR" add -v -A "app-android/src/main/res-current"; # main static schedule # required for non-bike agency modules
  checkResult $?;
  if [[ -d "$ROOT_DIR/app-android/src/main/res-next" ]]; then
      git -C "$ROOT_DIR" add -v -A "app-android/src/main/res-next"; # next static schedule # optional
      checkResult $?;
  fi
fi
echo "> GIT $ROOT_DIR > add... DONE";
echo "> GIT $ROOT_DIR > commit '$GIT_MSG'...";
# git -C "$ROOT_DIR" commit -q -m "$GIT_MSG";
# git -C "$ROOT_DIR" diff-index --quiet HEAD || git -C "$ROOT_DIR" commit -m "$GIT_MSG";
git -C "$ROOT_DIR" diff --staged --quiet || git -C "$ROOT_DIR" commit -m "$GIT_MSG";
checkResult $?;
echo "> GIT $ROOT_DIR > commit '$GIT_MSG'... DONE";
# TODO ? git -C $ROOT_DIR push;

printGitStatus;

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> COMMIT DATA CHANGE... DONE";
echo "================================================================================";
