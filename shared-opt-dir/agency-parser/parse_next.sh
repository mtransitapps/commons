#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/..";

source ${ROOT_DIR}/commons/sh/commons.sh

echo ">> Parsing Next...";

setGradleArgs;

CONFIG_DIR="${ROOT_DIR}/config";

URL="";
if [[ -e "$CONFIG_DIR/input_url_next" ]]; then
 URL=$(cat "$CONFIG_DIR/input_url_next");
elif [[ -f "$CONFIG_DIR/input_url" ]]; then
	URL=$(cat "$CONFIG_DIR/input_url");
elif [[ -f "$CONFIG_DIR/source_url" ]]; then
	URL=$(cat "$CONFIG_DIR/source_url");
fi

GENERATE_STOP_TIMES_FROM_FREQUENCIES="false";
if [[ -f "${SCRIPT_DIR}/generate_stop_times_from_frequencies" ]]; then
	GENERATE_STOP_TIMES_FROM_FREQUENCIES=$(cat "${SCRIPT_DIR}/generate_stop_times_from_frequencies");
fi

GTFS_DIR="input/gtfs_next";
if ! [[ -e "$SCRIPT_DIR/input/gtfs_next" ]]; then
	GTFS_DIR="input/gtfs";
fi
if ! [[ -e "$SCRIPT_DIR/input/gtfs_next/agency.txt" ]]; then
	GTFS_DIR="input/gtfs";
fi

ARGS="$GTFS_DIR unused next_ $GENERATE_STOP_TIMES_FROM_FREQUENCIES $URL";

${ROOT_DIR}/gradlew run \
  --args="${ARGS}" \
  ${GRADLE_ARGS};
RESULT=$?;

echo ">> Parsing Next... DONE";
exit ${RESULT};
