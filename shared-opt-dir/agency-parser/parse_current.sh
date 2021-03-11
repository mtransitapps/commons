#!/bin/bash
source ../commons/commons.sh
echo ">> Parsing Current...";

setGradleArgs;

GENERATE_STOP_TIMES_FROM_FREQUENCIES="";
if [[ -f "generate_stop_times_from_frequencies" ]]; then
	GENERATE_STOP_TIMES_FROM_FREQUENCIES=$(cat "generate_stop_times_from_frequencies");
fi

GTFS_ZIP="input/gtfs.zip";

ARGS="$GTFS_ZIP unused current_ $GENERATE_STOP_TIMES_FROM_FREQUENCIES";

../gradlew run \
--args="${ARGS}" \
${GRADLE_ARGS};
RESULT=$?;

echo ">> Parsing Current... DONE";
exit ${RESULT};
