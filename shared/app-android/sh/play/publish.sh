#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../../.."; ROOT_DIR=$(realpath --relative-to="$ROOT_DIR" "$ROOT_DIR");

source "${ROOT_DIR}/commons/sh/commons.sh";

echo ">> Publishing \"$@\"...";

setPushToStoreEnabled;

if [[ ${MT_PUSH_STORE_ENABLED} != true ]]; then
  echo "> Push to Store NOT enabled... SKIP ($MT_PUSH_STORE_ENABLED)";
  exit 0 # success
fi
echo "> Push to Store enabled ...";

# LINKS:
# https://github.com/Triple-T/gradle-play-publisher#common-configuration
# https://github.com/Triple-T/gradle-play-publisher#publishing-an-app-bundle
# Use --no-commit to do a dry-run
# gradlew help --task publishReleaseBundle

if [[ $# -eq 0 ]]; then
    echo ">> Invalid number of arguments! ($#)"
	exit 1;
fi

${ROOT_DIR}/app-android/sh/keys/setup.sh;
checkResult $?;

setGradleArgs;

"${ROOT_DIR}/gradlew" publishReleaseBundle --no-scan "$@"; # no ${GRADLE_ARGS} for release
COMMAND_RESULT=$?; # save command result but cleanup keys 1st

if [[ $COMMAND_RESULT -ne 0 ]]; then
  echo "> Gradle failed ($COMMAND_RESULT). Retrying in 10 seconds...";
  sleep 10;
  "${ROOT_DIR}/gradlew" publishReleaseBundle --no-scan "$@"; # no ${GRADLE_ARGS} for release
  COMMAND_RESULT=$?;
fi  

${ROOT_DIR}/app-android/sh/keys/cleanup.sh;
checkResult $?;

checkResult $COMMAND_RESULT; # check command result after keys cleanup

echo ">> Publishing \"$@\"... DONE";
