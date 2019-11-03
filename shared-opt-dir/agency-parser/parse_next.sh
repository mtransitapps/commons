#!/bin/bash
echo ">> Parsing Next...";

IS_CI=false;
if [[ ! -z "${CI}" ]]; then
	IS_CI=true;
fi
echo "/build.sh > IS_CI:'${IS_CI}'";

GRADLE_ARGS="";
if [[ ${IS_CI} = true ]]; then
	GRADLE_ARGS=" --console=plain";
fi

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
