#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> SET APP RELEASE REQUIRED (OR NOT)...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

setIsCI;

setGitBranch;

setGradleArgs;

setGitCommitEnabled;

MT_APP_RELEASE_REQUIRED=false;

MT_TEMP_DIR=".mt";
mkdir -p $MT_TEMP_DIR;
checkResult $?;
MT_DATA_CHANGED_FILE="$MT_TEMP_DIR/mt_data_changed";
MT_APP_RELEASE_REQUIRED_FILE="$MT_TEMP_DIR/mt_app_release_required";

MT_DATA_CHANGED=false;
if [[ -f ${MT_DATA_CHANGED_FILE} ]]; then
  MT_DATA_CHANGED=$(cat $MT_DATA_CHANGED_FILE);
fi
echo "> Data changed: $MT_DATA_CHANGED.";

if [[ "$MT_DATA_CHANGED" == "true" ]]; then
  MT_APP_RELEASE_REQUIRED=true; # new data
elif [[ "$GIT_BRANCH" == "mmathieum" ]]; then #LEGACY
  git fetch -v;
  RESULT=$?;
  if [[ ${RESULT} -ne 0 ]]; then
    echo "> Error while fetching GIT repository log!";
    exit ${RESULT};
  fi
  MAIN_BRANCH_NAME="master"; #TODO master->main
  MAIN_LAST_HASH=$(git log origin/$MAIN_BRANCH_NAME --max-count 1 --pretty=format:"%h");
  LOCAL_LAST_HASH=$(git log --max-count 1 --pretty=format:"%h");

  MAIN_LAST_TIMESTAMP_SEC=$(git log origin/$MAIN_BRANCH_NAME --max-count 1 --pretty=format:"%at");
  MAIN_LAST_RELEASE_DATE_TIME=$(date --date='@'$MAIN_LAST_TIMESTAMP_SEC'');
  echo "> Last release date: $MAIN_LAST_RELEASE_DATE_TIME.";

  LOCAL_LAST_TIMESTAMP_SEC=$(git log --max-count 1 --pretty=format:"%at");
  NOW_TIMESTAMP_SEC=$(date +%s);
  DIFF_SEC=$(($NOW_TIMESTAMP_SEC-$MAIN_LAST_TIMESTAMP_SEC));
  DIFF_DAYS=$(($DIFF_SEC/86400));
  MIN_DIFF_FOR_RELEASE_SEC=4233600; # 7 weeks
  NEXT_RELEASE_REQUIRED_SEC=$(($MAIN_LAST_TIMESTAMP_SEC+$MIN_DIFF_FOR_RELEASE_SEC));
  NEXT_RELEASE_DATE_TIME=$(date --date='@'$NEXT_RELEASE_REQUIRED_SEC'');
  if [[ "${MAIN_LAST_HASH}" != "${LOCAL_LAST_HASH}" ]]; then
    if [[ $NOW_TIMESTAMP_SEC -gt $NEXT_RELEASE_REQUIRED_SEC ]]; then
      MT_APP_RELEASE_REQUIRED=true; # release code change
    else
      echo "> Last release was only $DIFF_DAYS days ago > no need to release (next release: $NEXT_RELEASE_DATE_TIME).";
    fi
  else
    echo "> Same code hash $MAIN_LAST_HASH > no need to release.";
  fi
else
  echo "> Use case not supported yet!"; #TODO GH release?
  MT_APP_RELEASE_REQUIRED=false;
fi
echo "> App release requred: $MT_APP_RELEASE_REQUIRED.";
echo "$MT_APP_RELEASE_REQUIRED" > $MT_APP_RELEASE_REQUIRED_FILE;
checkResult $?;

echo "--------------------------------------------------------------------------------";
AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> SET APP RELEASE REQUIRED (OR NOT)... DONE";
echo "================================================================================";

