#!/bin/bash
source ../commons/commons.sh
echo ">> Downloading..."

FILE_PATH=".";
if [[ -d "../app-android/config" ]]; then
	FILE_PATH="../app-android/config";
fi

URL=`cat $FILE_PATH/input_url`;
mkdir -p input;
download "${URL}" "input/gtfs.zip";
checkResult $?;
if [[ -e "$FILE_PATH/input_url_next" ]]; then
	URL=`cat $FILE_PATH/input_url_next`;
	download "${URL}" "input/gtfs_next.zip";
	checkResult $?;
fi
echo ">> Downloading... DONE"
