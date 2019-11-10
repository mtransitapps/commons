#!/bin/bash
source ../commons/commons.sh
echo ">> Promote '${@}'...";

# LINKS:
# https://github.com/Triple-T/gradle-play-publisher#promoting-artifacts
# Use --no-commit to do a dry-run
# gradlew help --task promoteReleaseArtifact

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

IS_CI=false;
if [[ ! -z "${CI}" ]]; then
	IS_CI=true;
fi
echo "$0 > IS_CI:'${IS_CI}'";

GRADLE_ARGS="";
if [[ ${IS_CI} = true ]]; then
	GRADLE_ARGS=" --console=plain";
fi

../gradlew promoteReleaseArtifact ${GRADLE_ARGS} ${@};
checkResult $?;

echo ">> Promote '${@}'... DONE";
