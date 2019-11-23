#!/bin/bash
source ../commons/commons.sh

git add src/main/res-next/raw/next_gtfs_schedule_stop_*;

git ls-files --deleted --error-unmatch src/main/res-next/raw/ &> /dev/null;
RESULT=$?;

if [[ ${RESULT} -eq 0 ]]; then
	git rm $(git ls-files --deleted src/main/res-next/raw/);
	checkResult $?;
fi
