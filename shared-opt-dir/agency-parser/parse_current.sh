#!/bin/bash
echo ">> Parsing Current...";
GTFS_ZIP="input/gtfs.zip";
CHANGE_DIRECTORY=$(cat "change_directory");
RES_DIR="res-current"
ARGS="$GTFS_ZIP $CHANGE_DIRECTORY$RES_DIR/raw current_"
../gradlew run \
--args="${ARGS}";
RESULT=$?;
echo ">> Parsing Current... DONE";
exit ${RESULT};
