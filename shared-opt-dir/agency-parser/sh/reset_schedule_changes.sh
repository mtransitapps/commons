#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../.."; ROOT_DIR=$(realpath --relative-to="$ROOT_DIR" "$ROOT_DIR");

source "${ROOT_DIR}/commons/sh/commons.sh"

function resetDirectory() {
  local DIR=$1;
  if [[ -z $DIR ]]; then
    echo "> Reset schedule changes... ERROR: Missing directory!";
    exit 1;
  fi
  if [[ -d $DIR ]]; then
    echo "> Reset schedule changes... '$DIR'";
    # git restore --source=HEAD --staged --worktree -- $DIR;
    git checkout -- $DIR;
    # checkResult $?; # expected (files not known to git)
    git clean -fd -- $DIR;
    checkResult $?;
    echo "> Reset schedule changes... '$DIR' DONE";
  fi
}

echo "> Reset schedule changes...";
APP_ANDROID_MAIN="${ROOT_DIR}/app-android/src/main";
resetDirectory "$APP_ANDROID_MAIN/res/";
checkResult $?;
resetDirectory "$APP_ANDROID_MAIN/res-current/";
checkResult $?;
resetDirectory "$APP_ANDROID_MAIN/res-next/";
checkResult $?;
resetDirectory "$APP_ANDROID_MAIN/play/";
checkResult $?;
echo "> Reset schedule changes... DONE";
