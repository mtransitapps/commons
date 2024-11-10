#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh
echo ">> Parsing Current...";

setGradleArgs;

FILE_PATH="${SCRIPT_DIR}";
if [[ -d "${SCRIPT_DIR}/../config" ]]; then
	FILE_PATH="${SCRIPT_DIR}/../config";
elif [[ -d "${SCRIPT_DIR}/../app-android/config" ]]; then # OLD REPO
	FILE_PATH="${SCRIPT_DIR}/../app-android/config";
fi

URL=$(cat "$FILE_PATH/input_url");

GENERATE_STOP_TIMES_FROM_FREQUENCIES="false";
if [[ -f "${SCRIPT_DIR}/generate_stop_times_from_frequencies" ]]; then
	GENERATE_STOP_TIMES_FROM_FREQUENCIES=$(cat "${SCRIPT_DIR}/generate_stop_times_from_frequencies");
fi

GTFS_DIR="input/gtfs";

ARGS="$GTFS_DIR unused current_ $GENERATE_STOP_TIMES_FROM_FREQUENCIES $URL";

${SCRIPT_DIR}/../gradlew run \
--args="${ARGS}" \
${GRADLE_ARGS};
RESULT=$?;

echo ">> Parsing Current... DONE";
exit ${RESULT};
