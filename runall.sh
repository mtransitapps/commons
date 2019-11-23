#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/commons.sh;

echo "================================================================================";
echo "> RUN ALL...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});

echo "Current directory: '$CURRENT_DIRECTORY'.";

echo "Command: '$@'.";

for FILE_NAME in $(ls -a) ; do
	if [[ $FILE_NAME == "." ]] || [[ $FILE_NAME == ".." ]]; then
		echo "> Skip $FILE_NAME.";
		continue;
	fi
	if ! [[ -d "$FILE_NAME" ]]; then
		echo "> Skip $FILE_NAME (not a directory).";
		continue;
	fi
	echo "--------------------------------------------------------------------------------";
	echo "> Running '$@' in '$FILE_NAME'...";
	cd ${FILE_NAME} || exit;
	
	$@;
	checkResult $?;
	
	cd ..;
	echo "> Running '$@' in '$FILE_NAME'... DONE";
	echo "--------------------------------------------------------------------------------";
done

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> DEPLOY SYNC... DONE";
echo "================================================================================";
