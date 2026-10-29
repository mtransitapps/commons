#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../.."; ROOT_DIR=$(realpath --relative-to="$ROOT_DIR" "$ROOT_DIR");

source ${ROOT_DIR}/commons/sh/commons.sh

git add -v src/main/res-next/raw/next_gtfs_schedule_stop_*;

git ls-files --deleted --error-unmatch src/main/res-next/raw/ &> /dev/null;
RESULT=$?;

if [[ ${RESULT} -eq 0 ]]; then
	git rm $(git ls-files --deleted src/main/res-next/raw/);
	checkResult $?;
fi
