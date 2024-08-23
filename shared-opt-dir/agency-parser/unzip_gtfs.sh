#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh
echo ">> Unzipping GTFS files...";

GTFS_ZIP="${SCRIPT_DIR}/input/gtfs.zip";
TARGET_DIR="${SCRIPT_DIR}/input/gtfs";
if [[ -d ${TARGET_DIR} ]]; then
    echo ">> Removing existing GTFS files in '$TARGET_DIR'...";
	rm -r ${TARGET_DIR};
	checkResult $?;
fi
echo ">> Unzip '$GTFS_ZIP' in '$TARGET_DIR'...";
unzip -j ${GTFS_ZIP} -d ${TARGET_DIR};
checkResult $?;
echo ">> Unzip '$GTFS_ZIP' in '$TARGET_DIR'... DONE";

GTFS_ZIP="${SCRIPT_DIR}/input/gtfs_next.zip";
if [[ -f ${GTFS_ZIP} ]]; then
    TARGET_DIR="${SCRIPT_DIR}/input/gtfs_next";
    if [[ -d ${TARGET_DIR} ]]; then
        echo ">> Removing existing GTFS files in '$TARGET_DIR'...";
        rm -r ${TARGET_DIR};
        checkResult $?;
    fi
    echo ">> Unzip $GTFS_ZIP in '$TARGET_DIR'...";
    unzip -j ${GTFS_ZIP} -d ${TARGET_DIR};
    checkResult $?;
    echo ">> Unzip $GTFS_ZIP in '$TARGET_DIR'... DONE";
fi

echo ">> Unzipping GTFS files...... DONE";
