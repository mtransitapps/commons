#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh
echo ">> Downloading..."

FILE_PATH="${SCRIPT_DIR}";
if [[ -d "${SCRIPT_DIR}/../app-android/config" ]]; then
	FILE_PATH="${SCRIPT_DIR}/../app-android/config";
fi

URL=`cat $FILE_PATH/input_url`;
INPUT_DIR="${SCRIPT_DIR}/input";
mkdir -p "${INPUT_DIR}";
download "${URL}" "${INPUT_DIR}/gtfs.zip";
checkResult $?;
if [[ -e "$FILE_PATH/input_url_next" ]]; then
	URL=`cat $FILE_PATH/input_url_next`;
	download "${URL}" "${INPUT_DIR}/gtfs_next.zip";
	checkResult $?;
fi
echo ">> Downloading... DONE"
