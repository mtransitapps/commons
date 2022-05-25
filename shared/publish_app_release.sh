#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> PUBLISH APP RELEASE (?)...";
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

setPushToStoreEnabled;

if [[ ${MT_GIT_COMMIT_ENABLED} != true ]]; then
  echo "> Git commit NOT enabled.. SKIP";
  exit 0 # success
fi
echo "> Git commit enabled ...";

if [[ ${MT_PUSH_STORE_ENABLED} != true ]]; then
  echo "> Push to Store NOT enabled... SKIP ($MT_PUSH_STORE_ENABLED)";
  exit 0 # success
fi
echo "> Push to Store enabled...";

MT_TEMP_DIR=".mt";
mkdir -p $MT_TEMP_DIR;
checkResult $?;
MT_APP_RELEASE_REQUIRED_FILE="$MT_TEMP_DIR/mt_app_release_required";

MT_APP_RELEASE_REQUIRED=false;
if [[ -f ${MT_APP_RELEASE_REQUIRED_FILE} ]]; then
  MT_APP_RELEASE_REQUIRED=$(cat $MT_APP_RELEASE_REQUIRED_FILE);
fi
echo "> App release required: $MT_APP_RELEASE_REQUIRED.";

if [[ "$MT_APP_RELEASE_REQUIRED" != "true" ]]; then
  echo "> App release NOT required > SKIP";
elif [[ "$GIT_BRANCH" = "mmathieum" ]]; then #LEGACY
  MAIN_BRANCH_NAME="master"; #TODO master->main
  echo "> GIT submodule > push origin mmathieum:$MAIN_BRANCH_NAME...";
  git submodule foreach git push origin mmathieum:$MAIN_BRANCH_NAME; # git push fails if there are new changes on remote
  checkResult $?;
  echo "> GIT submodule > push origin mmathieum:$MAIN_BRANCH_NAME... DONE";
  echo "> GIT > push origin mmathieum:$MAIN_BRANCH_NAME...";
  git push origin mmathieum:$MAIN_BRANCH_NAME; # git push fails if there are new changes on remote
  checkResult $?;
  echo "> GIT > push origin mmathieum:$MAIN_BRANCH_NAME... DONE";

  if [[ -d "app-android" ]]; then
    cd app-android || exit -1; # >>

    if [[ -f "keys_cleanup.sh" ]]; then
      echo ">> Cleaning keys...";
      ./keys_cleanup.sh;
      echo "RESULT: $? (fail ok/expected)";
      echo ">> Cleaning keys... DONE";
    fi

    ./publish_to_current_users.sh;
    checkResult $?;

    cd ../; # <<
  fi
else
  echo "> Use case not supported yet!"; #TODO GH release?
fi

echo "--------------------------------------------------------------------------------";
AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> PUBLISH APP RELEASE (?)... DONE";
echo "================================================================================";

