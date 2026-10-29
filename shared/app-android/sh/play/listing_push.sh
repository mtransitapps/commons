#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../../.."; ROOT_DIR=$(realpath --relative-to="$PWD" "$ROOT_DIR");

source "${ROOT_DIR}/commons/sh/commons.sh";

echo ">> Pushing listing to the Play Console...";

# LINKS:
# https://github.com/Triple-T/gradle-play-publisher#publishing-listings
# gradlew help --task publishListing

${ROOT_DIR}/app-android/sh/keys/cleanup.sh; # FAIL OK
${ROOT_DIR}/app-android/sh/keys/setup.sh;
checkResult $?;

setGradleArgs;

"${ROOT_DIR}/gradlew" :app-android:publishListing; # no ${GRADLE_ARGS} for release
# "${ROOT_DIR}/gradlew" :app-android:publishListing --no-commit; # DEBUG # no ${GRADLE_ARGS} for release
COMMAND_RESULT=$?; # save command result but cleanup keys 1st

${ROOT_DIR}/app-android/sh/keys/cleanup.sh;
checkResult $?;

checkResult $COMMAND_RESULT; # check command result after keys cleanup

echo ">> Pushing listing to the Play Console... DONE";
