#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> SET APP RELEASE REQUIRED (OR NOT)...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

setIsCI;

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
else
  git fetch -v;
  RESULT=$?;
  if [[ ${RESULT} -ne 0 ]]; then
    echo "> Error while fetching GIT repository log!";
    exit ${RESULT};
  fi

  LAST_GIT_TAG_HASH=$(git rev-list --tags --max-count=1);
  LAST_GIT_TAG_NAME=$(git describe --tags $LAST_GIT_TAG_HASH)
  LAST_GIT_TAG_TIMESTAMP_SEC=$(git log -1 --pretty=format:"%at" $LAST_GIT_TAG_NAME);
  LAST_GIT_TAG_DATE_TIME=$(date --date='@'"$LAST_GIT_TAG_TIMESTAMP_SEC"'');

  echo "> Last release '$LAST_GIT_TAG_NAME' on '$LAST_GIT_TAG_DATE_TIME'.";

  LOCAL_LAST_HASH=$(git log --max-count 1 --pretty=format:"%h");

  NOW_TIMESTAMP_SEC=$(date +%s);
  DIFF_SEC=$(($NOW_TIMESTAMP_SEC-$LAST_GIT_TAG_TIMESTAMP_SEC));
  DIFF_DAYS=$(($DIFF_SEC/86400));
  MIN_DIFF_FOR_RELEASE_SEC=4233600; # 7 weeks
  NEXT_RELEASE_REQUIRED_SEC=$(($LAST_GIT_TAG_TIMESTAMP_SEC+$MIN_DIFF_FOR_RELEASE_SEC));
  NEXT_RELEASE_DATE_TIME=$(date --date='@'$NEXT_RELEASE_REQUIRED_SEC'');
  if [[ "${LAST_GIT_TAG_HASH}" != "${LOCAL_LAST_HASH}" ]]; then
    if [[ $NOW_TIMESTAMP_SEC -gt $NEXT_RELEASE_REQUIRED_SEC ]]; then
      MT_APP_RELEASE_REQUIRED=true; # release code change
    else
      echo "> Last release was only $DIFF_DAYS days ago > no need to release (next release: $NEXT_RELEASE_DATE_TIME).";
    fi
  else
    echo "> Same code hash '$LAST_GIT_TAG_HASH' > no need to release.";
  fi
fi
echo "> App release required: $MT_APP_RELEASE_REQUIRED.";
echo "$MT_APP_RELEASE_REQUIRED" > $MT_APP_RELEASE_REQUIRED_FILE;
checkResult $?;

if [[ ${MT_APP_RELEASE_REQUIRED} == true ]]; then
  MT_SKIP_PUSH_COMMIT=false;
  echo "MT_SKIP_PUSH_COMMIT: $MT_SKIP_PUSH_COMMIT";
  if [[ ${GITHUB_ACTIONS} = true ]]; then
    echo "MT_SKIP_PUSH_COMMIT=$MT_SKIP_PUSH_COMMIT" >> "$GITHUB_ENV"
  else
    export MT_SKIP_PUSH_COMMIT="$MT_SKIP_PUSH_COMMIT"
  fi
fi

echo "--------------------------------------------------------------------------------";
AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> SET APP RELEASE REQUIRED (OR NOT)... DONE";
echo "================================================================================";

