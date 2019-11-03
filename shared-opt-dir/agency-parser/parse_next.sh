#!/bin/bash
echo ">> Parsing Next...";
GTFS_ZIP="input/gtfs_next.zip";
if ! [[ -e "input_url_next" ]]; then
	GTFS_ZIP="input/gtfs.zip";
fi
CHANGE_DIRECTORY=$(cat "change_directory");
RES_DIR="res-next"
ARGS="$GTFS_ZIP $CHANGE_DIRECTORY$RES_DIR/raw next_"
../gradlew run \
--args="${ARGS}";
RESULT=$?;
echo ">> Parsing Next... DONE";
exit ${RESULT};
