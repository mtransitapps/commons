#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../.."; ROOT_DIR=$(realpath --relative-to="$PWD" "$ROOT_DIR");

source "${ROOT_DIR}/commons/sh/commons.sh"

echo "================================================================================";
echo "> VALIDATE & PARSE NEXT...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

setGitProjectName;

setIsCI;

setGradleArgs;

setGitCommitEnabled;

if [[ -d "${ROOT_DIR}/agency-parser" ]]; then

    CURRENT_PATH=$(pwd);
	cd ${ROOT_DIR}/agency-parser || exit; # >>
	ROOT_FROM_CURRENT_DIR="./..";

	echo "> VALIDATING DATA FOR '$PROJECT_NAME'...";

	if [[ -e "input/gtfs_next.zip" ]]; then
		$ROOT_FROM_CURRENT_DIR/commons/gtfs/gtfs-validator.sh "input/gtfs_next.zip" "output/next";
		# checkResult $?; # too many errors for now
	fi

	echo "> VALIDATING DATA FOR '$PROJECT_NAME'... DONE";

	echo "> PARSING DATA FOR '$PROJECT_NAME'...";

	# NEXT...
	./sh/parse_next.sh;
	checkResult $?;
	# NEXT... DONE

	echo "> PARSING DATA FOR '$PROJECT_NAME'... DONE";

  	cd ${CURRENT_PATH} || exit; # <<
else
	echo "> SKIP PARSING FOR '$PROJECT_NAME'.";
fi

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "--------------------------------------------------------------------------------";
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> VALIDATE & PARSE NEXT... DONE";
echo "================================================================================";
