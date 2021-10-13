#!/bin/bash
source ../commons/commons.sh
echo ">> Pushing listing to Google Play Console...";

# LINKS:
# https://github.com/Triple-T/gradle-play-publisher#publishing-listings
# gradlew help --task publishListing

CURRENT_DIRECTORY_PATH="$(realpath "$PWD")";
SCRIPT_DIRECTORY_PATH="$(realpath $(dirname "$0"))";

if [[ "${CURRENT_DIRECTORY_PATH}" != "${SCRIPT_DIRECTORY_PATH}" ]]; then
	echo ">> Script needs to be executed from '$SCRIPT_DIRECTORY_PATH' instead of '${CURRENT_DIRECTORY_PATH}'!";
	exit 1;
fi

echo ">> Setup-ing keys...";
./keys_setup.sh;
checkResult $?;
echo ">> Setup-ing keys... DONE";

setGradleArgs;

../gradlew publishListing ${GRADLE_ARGS};
COMMAND_RESULT=$?; # save command result but cleanup keys 1st

echo ">> Cleaning keys...";
./keys_cleanup.sh;
checkResult $?;
echo ">> Cleaning keys... DONE";

checkResult $COMMAND_RESULT; # check command result after keys cleanup

echo ">> Pushing listing to Google Play Console... DONE";
