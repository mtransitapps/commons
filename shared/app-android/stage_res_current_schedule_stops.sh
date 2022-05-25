#!/bin/bash
source ../commons/commons.sh

git add -v src/main/res-current/raw/current_gtfs_schedule_stop_*;

git ls-files --deleted --error-unmatch src/main/res-current/raw/ &> /dev/null;
RESULT=$?;

if [[ ${RESULT} -eq 0 ]]; then
	git rm $(git ls-files --deleted src/main/res-current/raw/);
	checkResult $?;
fi
