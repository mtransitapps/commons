#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../.."; ROOT_DIR=$(realpath --relative-to="$ROOT_DIR" "$ROOT_DIR");

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

    echo "> PREPARING DATA FOR '$PROJECT_NAME'...";

    # PICK ZIP FILES FROM ARCHIVE
    ./sh/archive_selection.sh; # in agency-parser
    RESULT=$?;
    checkResult $RESULT;
    echo "> Select archive result: $RESULT";

    ./sh/unzip_gtfs.sh; # in agency-parser
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
echo "--------------------------------------------------------------------------------";
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> PREPARE only... DONE";
echo "================================================================================";
