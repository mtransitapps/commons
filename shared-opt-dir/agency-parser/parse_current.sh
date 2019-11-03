#!/bin/bash
echo ">> Parsing Current...";

IS_CI=false;
if [[ ! -z "${CI}" ]]; then
	IS_CI=true;
fi
echo "/build.sh > IS_CI:'${IS_CI}'";

GRADLE_ARGS="";
if [[ ${IS_CI} = true ]]; then
	GRADLE_ARGS=" --no-daemon --console=plain";
fi

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
