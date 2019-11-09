#!/bin/bash
source ../commons/commons.sh
echo ">> Unzipping GTFS files...";
TARGET_DIR="input/gtfs";
if [[ -d $TARGET_DIR ]]; then
	rm -r $TARGET_DIR;
	checkResult $? false;
fi
unzip input/gtfs.zip -d $TARGET_DIR;
checkResult $? false;
echo ">> Unzipping GTFS files...... DONE";
