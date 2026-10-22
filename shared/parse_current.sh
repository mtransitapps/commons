#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}";

source ${ROOT_DIR}/commons/sh/commons.sh

echo "================================================================================";
echo "> PARSE CURRENT...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

setGitProjectName;

setIsCI;

setGradleArgs;

setGitCommitEnabled;

if [[ -d "${SCRIPT_DIR}/agency-parser" ]]; then
  cd ${SCRIPT_DIR}/agency-parser || exit; # >>
  AGENCY_PARSER_DIR=".";
  echo "> AGENCY_PARSER_DIR: $AGENCY_PARSER_DIR";
  INPUT_DIR="$AGENCY_PARSER_DIR/input";

	echo "> VALIDATING DATA FOR '$PROJECT_NAME'...";

	$ROOT_DIR/commons/gtfs/gtfs-validator.sh "$INPUT_DIR/gtfs.zip" "output/current";
	# checkResult $?; # too many errors for now

	echo "> VALIDATING DATA FOR '$PROJECT_NAME'... DONE";

	echo "> PARSING DATA FOR '$PROJECT_NAME'...";

	# CURRENT...
	$AGENCY_PARSER_DIR/parse_current.sh;
	checkResult $?;
	# CURRENT... DONE

	echo "> PARSING DATA FOR '$PROJECT_NAME'... DONE";

	cd ..; # <<
else
	echo "> SKIP PARSING FOR '$PROJECT_NAME'.";
fi

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> PARSE CURRENT... DONE";
echo "================================================================================";
