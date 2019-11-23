#!/bin/bash
source ../commons/commons.sh

git add src/main/res-next/raw/next_gtfs_schedule_stop_*;

git ls-files --deleted src/main/res-next/raw/next_gtfs_schedule_stop_* &> /dev/null;
RESULT=$?;

if [[ ${RESULT} -ne 0 ]]; then
	git rm $(git ls-files --deleted src/main/res-next/raw/next_gtfs_schedule_stop_*);
	checkResult $?;
fi
