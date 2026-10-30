#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR=$(cd "${SCRIPT_DIR}/../.." && pwd);

source "${ROOT_DIR}/commons/sh/commons.sh"

echo ">> Parsing Current...";

setGradleArgs;

CONFIG_DIR="${ROOT_DIR}/config";

AGENCY_PARSER_DIR="${ROOT_DIR}/agency-parser";

URL="";
if [[ -f "$CONFIG_DIR/input_url" ]]; then
	URL=$(cat "$CONFIG_DIR/input_url");
elif [[ -f "$CONFIG_DIR/source_url" ]]; then
	URL=$(cat "$CONFIG_DIR/source_url");
fi

GENERATE_STOP_TIMES_FROM_FREQUENCIES="false";
if [[ -f "${AGENCY_PARSER_DIR}/generate_stop_times_from_frequencies" ]]; then
	GENERATE_STOP_TIMES_FROM_FREQUENCIES=$(cat "${AGENCY_PARSER_DIR}/generate_stop_times_from_frequencies");
fi

GTFS_DIR="input/gtfs";

ARGS="$GTFS_DIR unused current_ $GENERATE_STOP_TIMES_FROM_FREQUENCIES $URL";

"${ROOT_DIR}/gradlew" run \
  --args="${ARGS}" \
  ${GRADLE_ARGS};
RESULT=$?;

echo ">> Parsing Current... DONE";
exit ${RESULT};
