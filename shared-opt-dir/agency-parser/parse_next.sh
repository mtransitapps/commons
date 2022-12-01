#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh
echo ">> Parsing Next...";

setGradleArgs;

GENERATE_STOP_TIMES_FROM_FREQUENCIES="";
if [[ -f "${SCRIPT_DIR}/generate_stop_times_from_frequencies" ]]; then
	GENERATE_STOP_TIMES_FROM_FREQUENCIES=$(cat "${SCRIPT_DIR}/generate_stop_times_from_frequencies");
fi

FILE_PATH="${SCRIPT_DIR}";
if [[ -d "${SCRIPT_DIR}/../app-android/config" ]]; then
	FILE_PATH="${SCRIPT_DIR}/../app-android/config";
fi

GTFS_ZIP="input/gtfs_next.zip";
if ! [[ -e "$FILE_PATH/input_url_next" ]]; then
	GTFS_ZIP="input/gtfs.zip";
fi
if ! [[ -e "${SCRIPT_DIR}/input/gtfs_next/agency.txt" ]]; then
	GTFS_ZIP="input/gtfs.zip";
fi

ARGS="$GTFS_ZIP unused next_ $GENERATE_STOP_TIMES_FROM_FREQUENCIES";

${SCRIPT_DIR}/../gradlew run \
--args="${ARGS}" \
${GRADLE_ARGS};
RESULT=$?;

echo ">> Parsing Next... DONE";
exit ${RESULT};
