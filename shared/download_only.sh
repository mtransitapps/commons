#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/commons/commons.sh
echo "================================================================================";
echo "> DOWNLOAD only...";
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

    echo "> DOWNLOADING DATA FOR '$AGENCY_ID'...";

    AGENCY_PARSER_DIR=".";

    # DOWNLOAD ALL AVAILABLE FEEDS URLS & ARCHIVE ZIP FILES
    $AGENCY_PARSER_DIR/download.sh; # and archive
    RESULT=$?; # failure is fine: will use last successful archive(s)
    echo "> Download result: $RESULT";

    echo "> DOWNLOADING DATA FOR '$AGENCY_ID'... DONE";

  cd ../; # <<
else
  echo "> SKIP DOWNLOADING FOR '$AGENCY_ID'.";
fi

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> DOWNLOAD only... DONE";
echo "================================================================================";
