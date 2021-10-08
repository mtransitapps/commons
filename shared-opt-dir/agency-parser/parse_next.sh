#!/bin/bash
source ../commons/commons.sh
echo ">> Parsing Next...";

setGradleArgs;

GENERATE_STOP_TIMES_FROM_FREQUENCIES="";
if [[ -f "generate_stop_times_from_frequencies" ]]; then
	GENERATE_STOP_TIMES_FROM_FREQUENCIES=$(cat "generate_stop_times_from_frequencies");
fi

GTFS_ZIP="input/gtfs_next.zip";
if ! [[ -e "input_url_next" ]]; then
	GTFS_ZIP="input/gtfs.zip";
fi
if ! [[ -e "input/gtfs_next/agency.txt" ]]; then
	GTFS_ZIP="input/gtfs.zip";
fi

ARGS="$GTFS_ZIP unused next_ $GENERATE_STOP_TIMES_FROM_FREQUENCIES";

../gradlew run \
--args="${ARGS}" \
${GRADLE_ARGS};
RESULT=$?;

echo ">> Parsing Next... DONE";
exit ${RESULT};
