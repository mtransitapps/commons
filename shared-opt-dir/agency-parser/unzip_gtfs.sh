#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh
echo ">> Unzipping GTFS files...";

GTFS_ZIP="${SCRIPT_DIR}/input/gtfs.zip";
TARGET_DIR="${SCRIPT_DIR}/input/gtfs";
if [[ -d ${TARGET_DIR} ]]; then
	rm -r ${TARGET_DIR};
	checkResult $? false;
fi
unzip -j ${GTFS_ZIP} -d ${TARGET_DIR};
checkResult $? false;

GTFS_ZIP="${SCRIPT_DIR}/input/gtfs_next.zip";
if [[ -f ${GTFS_ZIP} ]]; then
    TARGET_DIR="${SCRIPT_DIR}/input/gtfs_next";
    if [[ -d ${TARGET_DIR} ]]; then
        rm -r ${TARGET_DIR};
        checkResult $? false;
    fi
    unzip -j ${GTFS_ZIP} -d ${TARGET_DIR};
    checkResult $? false;
fi

echo ">> Unzipping GTFS files...... DONE";
