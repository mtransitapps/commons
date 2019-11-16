#!/bin/bash
source ../commons/commons.sh
echo ">> Parsing Current...";

setGradleArgs;

../gradlew --stop;

free -t -m;

egrep --color 'Mem|Cache|Swap' /proc/meminfo;

GTFS_ZIP="input/gtfs.zip";
CHANGE_DIRECTORY=$(cat "change_directory");
RES_DIR="res-current"
ARGS="$GTFS_ZIP $CHANGE_DIRECTORY$RES_DIR/raw current_"

../gradlew run \
--args="${ARGS}" \
${GRADLE_ARGS};
RESULT=$?;

echo ">> Parsing Current... DONE";
exit ${RESULT};
