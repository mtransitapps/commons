#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh
echo ">> Pushing listing to Google Play Console...";

# LINKS:
# https://github.com/Triple-T/gradle-play-publisher#publishing-listings
# gradlew help --task publishListing

${SCRIPT_DIR}/keys_cleanup.sh; # FAIL OK
${SCRIPT_DIR}/keys_setup.sh;
checkResult $?;

setGradleArgs;

${SCRIPT_DIR}/../gradlew :app-android:publishListing; # no ${GRADLE_ARGS} for release
COMMAND_RESULT=$?; # save command result but cleanup keys 1st

${SCRIPT_DIR}/keys_cleanup.sh;
checkResult $?;

checkResult $COMMAND_RESULT; # check command result after keys cleanup

echo ">> Pushing listing to Google Play Console... DONE";
