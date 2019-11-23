#!/bin/bash
source ../commons/commons.sh
echo ">> Publishing '${@}'...";

# LINKS:
# https://github.com/Triple-T/gradle-play-publisher#common-configuration
# https://github.com/Triple-T/gradle-play-publisher#publishing-an-app-bundle
# Use --no-commit to do a dry-run
# gradlew help --task publishReleaseBundle

CURRENT_DIRECTORY_PATH="$(realpath "$PWD")";
SCRIPT_DIRECTORY_PATH="$(realpath $(dirname "$0"))";

if [[ "${CURRENT_DIRECTORY_PATH}" != "${SCRIPT_DIRECTORY_PATH}" ]]; then
	echo ">> Script needs to be exectured from '$SCRIPT_DIRECTORY_PATH' instead of '${CURRENT_DIRECTORY_PATH}'!";
	exit 1;
fi

if [[ $# -eq 0 ]]; then
    echo ">> Invalid number of arguments!"
	exit 1;
fi

echo ">> Setup-ing keys...";
./keys_setup.sh;
checkResult $?;
echo ">> Setup-ing keys... DONE";

setGradleArgs;

../gradlew publishReleaseBundle ${GRADLE_ARGS} ${@};
COMMAND_RESULT=$?; # save command result but cleanup keys 1st

echo ">> Cleaning keys...";
./keys_cleanup.sh;
checkResult $?;
echo ">> Cleaning keys... DONE";

checkResult $COMMAND_RESULT; # check command result after keys cleanup

echo ">> Publishing '${@}'... DONE";
