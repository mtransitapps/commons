#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh
echo ">> Parsing Current...";

setGradleArgs;

GENERATE_STOP_TIMES_FROM_FREQUENCIES="";
if [[ -f "${SCRIPT_DIR}/generate_stop_times_from_frequencies" ]]; then
	GENERATE_STOP_TIMES_FROM_FREQUENCIES=$(cat "${SCRIPT_DIR}/generate_stop_times_from_frequencies");
fi

GTFS_DIR="input/gtfs";

ARGS="$GTFS_DIR unused current_ $GENERATE_STOP_TIMES_FROM_FREQUENCIES";

${SCRIPT_DIR}/../gradlew run \
--args="${ARGS}" \
${GRADLE_ARGS};
RESULT=$?;

echo ">> Parsing Current... DONE";
exit ${RESULT};
