#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}";

source ${ROOT_DIR}/commons/sh/commons.sh

echo "================================================================================";
echo "> DOWNLOAD only...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

setGitProjectName;

setIsCI;

setGradleArgs;

setGitCommitEnabled;

if [[ -d "${SCRIPT_DIR}/agency-parser" ]]; then

    CURRENT_PATH=$(pwd);
    cd ${SCRIPT_DIR}/agency-parser || exit; # >>

    echo "> DOWNLOADING DATA FOR '$PROJECT_NAME'...";

    # DOWNLOAD ALL AVAILABLE FEEDS URLS & ARCHIVE ZIP FILES
    ./download.sh; # and archive
    RESULT=$?; # failure is fine: will use last successful archive(s)
    echo "> Download result: $RESULT";

    echo "> DOWNLOADING DATA FOR '$PROJECT_NAME'... DONE";

    cd ${CURRENT_PATH} || exit; # <<
else
    echo "> SKIP DOWNLOADING FOR '$PROJECT_NAME'.";
fi

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> DOWNLOAD only... DONE";
echo "================================================================================";
