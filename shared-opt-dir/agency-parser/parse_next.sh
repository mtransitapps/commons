#!/bin/bash
source ../commons/commons.sh
echo ">> Parsing Next...";

setGradleArgs;

GTFS_ZIP="input/gtfs_next.zip";
if ! [[ -e "input_url_next" ]]; then
	GTFS_ZIP="input/gtfs.zip";
fi
CHANGE_DIRECTORY=$(cat "change_directory");
RES_DIR="res-next"
ARGS="$GTFS_ZIP $CHANGE_DIRECTORY$RES_DIR/raw next_"

../gradlew run \
--args="${ARGS}" \
${GRADLE_ARGS};
RESULT=$?;

echo ">> Parsing Next... DONE";
exit ${RESULT};
