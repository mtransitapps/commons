#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}";

source ${ROOT_DIR}/commons/sh/commons.sh

echo "================================================================================";
echo "> PREPARE only...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

setGitProjectName;

setIsCI;

setGradleArgs;

setGitCommitEnabled;

if [[ -d "${SCRIPT_DIR}/agency-parser" ]]; then

  cd ${SCRIPT_DIR}/agency-parser || exit; # >>

    echo "> PREPARING DATA FOR '$PROJECT_NAME'...";

    AGENCY_PARSER_DIR=".";

    # PICK ZIP FILES FROM ARCHIVE
    $AGENCY_PARSER_DIR/archive_selection.sh;
    RESULT=$?;
    checkResult $RESULT;
    echo "> Select archive result: $RESULT";

    $AGENCY_PARSER_DIR/unzip_gtfs.sh;
    RESULT=$?;
    checkResult $RESULT;
    echo " > Unzip result: $RESULT";

    INPUT_DIR="$AGENCY_PARSER_DIR/input";

    echo "> PREPARING DATA FOR '$PROJECT_NAME'... DONE";

  cd ../; # <<
else
  echo "> SKIP PREPARING FOR '$PROJECT_NAME'.";
fi

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> PREPARE only... DONE";
echo "================================================================================";
