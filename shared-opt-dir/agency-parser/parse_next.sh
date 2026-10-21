#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/..";

source ${ROOT_DIR}/commons/sh/commons.sh

echo ">> Parsing Next...";

setGradleArgs;

FILE_PATH="${ROOT_DIR}/config";
if [[ -d "${ROOT_DIR}/config" ]]; then
	FILE_PATH="${ROOT_DIR}/config";
elif [[ -d "${ROOT_DIR}/app-android/config" ]]; then # OLD REPO
	FILE_PATH="${ROOT_DIR}/app-android/config";
fi

URL="";
if [[ -e "$FILE_PATH/input_url_next" ]]; then
 URL=$(cat "$FILE_PATH/input_url_next");
elif [[ -f "$FILE_PATH/input_url" ]]; then
	URL=$(cat "$FILE_PATH/input_url");
elif [[ -f "$FILE_PATH/source_url" ]]; then
	URL=$(cat "$FILE_PATH/source_url");
fi

GENERATE_STOP_TIMES_FROM_FREQUENCIES="false";
if [[ -f "${SCRIPT_DIR}/generate_stop_times_from_frequencies" ]]; then
	GENERATE_STOP_TIMES_FROM_FREQUENCIES=$(cat "${SCRIPT_DIR}/generate_stop_times_from_frequencies");
fi

FILE_PATH="${ROOT_DIR}/app-android/config";
if [[ -d "${ROOT_DIR}/app-android/config" ]]; then
	FILE_PATH="${ROOT_DIR}/app-android/config";
fi

GTFS_DIR="input/gtfs_next";
if ! [[ -e "$FILE_PATH/input/gtfs_next" ]]; then
	GTFS_DIR="input/gtfs";
fi
if ! [[ -e "$FILE_PATH/input/gtfs_next/agency.txt" ]]; then
	GTFS_DIR="input/gtfs";
fi

ARGS="$GTFS_DIR unused next_ $GENERATE_STOP_TIMES_FROM_FREQUENCIES $URL";

${ROOT_DIR}/gradlew run \
  --args="${ARGS}" \
  ${GRADLE_ARGS};
RESULT=$?;

echo ">> Parsing Next... DONE";
exit ${RESULT};
