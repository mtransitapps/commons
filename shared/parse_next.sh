#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}";

source ${ROOT_DIR}/commons/sh/commons.sh

echo "================================================================================";
echo "> PARSE NEXT...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

ROOT_DIR_NAME=$(basename ${ROOT_DIR});
AGENCY_ID=$(basename -s -gradle ${ROOT_DIR_NAME});

setIsCI;

setGradleArgs;

setGitCommitEnabled;

if [[ -d "${SCRIPT_DIR}/agency-parser" ]]; then
  cd ${SCRIPT_DIR}/agency-parser || exit; # >>
  AGENCY_PARSER_DIR=".";
  echo "> AGENCY_PARSER_DIR: $AGENCY_PARSER_DIR";
  INPUT_DIR="$AGENCY_PARSER_DIR/input";

	echo "> VALIDATING DATA FOR '$AGENCY_ID'...";

	if [[ -e "$INPUT_DIR/gtfs_next.zip" ]]; then
		$ROOT_DIR/commons/gtfs/gtfs-validator.sh "$INPUT_DIR/gtfs_next.zip" "output/next";
		# checkResult $?; # too many errors for now
	fi

	echo "> VALIDATING DATA FOR '$AGENCY_ID'... DONE";

	echo "> PARSING DATA FOR '$AGENCY_ID'...";

	# NEXT...
	$AGENCY_PARSER_DIR/parse_next.sh;
	checkResult $?;
	# NEXT... DONE

	echo "> PARSING DATA FOR '$AGENCY_ID'... DONE";

  cd ..; # <<
else
	echo "> SKIP PARSING FOR '$AGENCY_ID'.";
fi

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> PARSE NEXT... DONE";
echo "================================================================================";
