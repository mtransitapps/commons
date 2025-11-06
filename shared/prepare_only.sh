#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/commons/commons.sh
echo "================================================================================";
echo "> PREPARE only...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

setIsCI;

setGradleArgs;

setGitCommitEnabled;

if [[ -d "${SCRIPT_DIR}/agency-parser" ]]; then

  cd ${SCRIPT_DIR}/agency-parser || exit; # >>

    echo "> PREPARING DATA FOR '$AGENCY_ID'...";

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

    echo "> PREPARING DATA FOR '$AGENCY_ID'... DONE";

  cd ../; # <<
else
  echo "> SKIP PREPARING FOR '$AGENCY_ID'.";
fi

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> PREPARE only... DONE";
echo "================================================================================";
