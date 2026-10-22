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

if [[ -d "${ROOT_DIR}/agency-parser" ]]; then

    CURRENT_PATH=$(pwd);
    cd ${ROOT_DIR}/agency-parser || exit; # >>
    ROOT_FROM_CURRENT_DIR="./..";

    echo "> PREPARING DATA FOR '$PROJECT_NAME'...";

    AGENCY_PARSER_DIR=".";

    # PICK ZIP FILES FROM ARCHIVE
    $ROOT_FROM_CURRENT_DIR/commons/gtfs/archive_selection.sh;
    RESULT=$?;
    checkResult $RESULT;
    echo "> Select archive result: $RESULT";

    $ROOT_FROM_CURRENT_DIR/commons/gtfs/unzip_gtfs.sh;
    RESULT=$?;
    checkResult $RESULT;
    echo " > Unzip result: $RESULT";

    echo "> PREPARING DATA FOR '$PROJECT_NAME'... DONE";

    cd ${CURRENT_PATH} || exit; # <<
else
    echo "> SKIP PREPARING FOR '$PROJECT_NAME'.";
fi

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> PREPARE only... DONE";
echo "================================================================================";
