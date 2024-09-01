#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh

function resetDirectory() {
  local DIR=$1;
  if [[ -z $DIR ]]; then
    echo "> Reset schedule changes... ERROR: Missing directory!";
    exit 1;
  fi
  if [[ -d $DIR ]]; then
    echo "> Reset schedule changes... '$DIR'";
    # git restore --source=HEAD --staged --worktree -- $DIR;
    git  checkout -- $DIR;
    checkResult $?;
    git clean -fd -- $DIR;
    echo "> Reset schedule changes... '$DIR' DONE";
  fi
}

echo "> Reset schedule changes...";
TARGET="${SCRIPT_DIR}/../app-android/src/main";
resetDirectory "$TARGET/res/";
checkResult $?;
resetDirectory "$TARGET/res-current/";
checkResult $?;
resetDirectory "$TARGET/res-next/";
checkResult $?;
resetDirectory "$TARGET/play/";
checkResult $?;
echo "> Reset schedule changes... DONE";
