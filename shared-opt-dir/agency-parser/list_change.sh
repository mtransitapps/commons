#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh
echo "> Listing change...";

MT_TEMP_DIR="${SCRIPT_DIR}/../.mt";
mkdir -p $MT_TEMP_DIR;
checkResult $?;
MT_DATA_CHANGED_FILE="$MT_TEMP_DIR/mt_data_changed";

TARGET="${SCRIPT_DIR}/../app-android/src/main/";
RESULT=$(git -C ${TARGET} status);
checkResult $? false;
RESULT=$(echo ${RESULT} | grep "/raw/" | wc -l);
STATUS=$?;
if [[ "$RESULT" -gt 0 ]]; then
	echo "> SCHEDULE CHANGED > MANUAL FIX!";
	git -C ${TARGET} status | grep "/raw/" | head -n 7;
	echo "true" > $MT_DATA_CHANGED_FILE;
	checkResult $?;
	exit 1;
fi
if [[ ${STATUS} == 1 ]]; then STATUS=0; fi; # grep returns 1 when no result
checkResult ${STATUS} false;
git -C ${TARGET} diff res/values/gtfs_rts_values_gen.xml;
checkResult $?;
RESULT=$(git -C ${TARGET} diff-index --name-only HEAD -- "res/raw" | wc -l);
if [[ "$RESULT" -gt 0 ]]; then
	echo "> SCHEDULE CHANGED > MANUAL FIX!";
	git -C ${TARGET} status | grep "res/raw" | head -n 7;
	echo "true" > $MT_DATA_CHANGED_FILE;
	checkResult $?;
	exit 1;
fi
git -C ${TARGET} diff res-current/values/current_gtfs_rts_values_gen.xml;
checkResult $?;
RESULT=$(git -C ${TARGET} diff-index --name-only HEAD -- "res-current/raw" | wc -l);
if [[ "$RESULT" -gt 0 ]]; then
	echo "> SCHEDULE CHANGED > MANUAL FIX!";
	git -C ${TARGET} status | grep "res-current/raw" | head -n 7;
	echo "true" > $MT_DATA_CHANGED_FILE;
	checkResult $?;
	exit 1;
fi
if [[ -d ${TARGET}/res-next ]]; then
	git -C ${TARGET} status | grep "res-next" | head -n 1;
	if [[ -f ${TARGET}/res-next/values/next_gtfs_rts_values_gen.xml ]]; then
		git -C ${TARGET} diff res-next/values/next_gtfs_rts_values_gen.xml;
		checkResult $?;
		git -C ${TARGET} ls-files --error-unmatch res-next/values/next_gtfs_rts_values_gen.xml &> /dev/null;
		RESULT=$?;
		if [[ "$RESULT" -gt 0 ]]; then
			echo "> SCHEDULE CHANGED > MANUAL FIX!";
			cat ${TARGET}/res-next/values/next_gtfs_rts_values_gen.xml;
			echo "true" > $MT_DATA_CHANGED_FILE;
			checkResult $?;
			exit 1;
		fi
	fi
	if [[ -d ${TARGET}/res-next/raw ]]; then
		RESULT=$(git -C ${TARGET} diff-index --name-only HEAD -- "res-next/raw" | wc -l);
		if [[ "$RESULT" -gt 0 ]]; then
			echo "> SCHEDULE CHANGED > MANUAL FIX!";
			git -C ${TARGET} status | grep "res-next/raw" | head -n 7;
			echo "true" > $MT_DATA_CHANGED_FILE;
			checkResult $?;
			exit 1;
		fi
	fi
fi
git -C ${TARGET} checkout res/values/gtfs_rts_values.xml;
checkResult $?;
echo "false" > $MT_DATA_CHANGED_FILE;
checkResult $?;
echo "> Listing change... DONE";
