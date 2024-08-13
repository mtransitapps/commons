#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> PUSH COMMITS...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

setIsCI;

setGradleArgs;

setGitCommitEnabled;

if [[ ${MT_GIT_COMMIT_ENABLED} != true ]]; then
  echo "> Git commit NOT enabled.. SKIP";
  exit 0 # success
fi
echo "> Git commit enabled ...";

if [[ ${MT_SKIP_PUSH_COMMIT} == true ]]; then
  echo "> MT_SKIP_PUSH_COMMIT=$MT_SKIP_PUSH_COMMIT... SKIP";
  exit 0 # success
fi

cd app-android || exit;
echo ">> Cleaning keys...";
./keys_cleanup.sh;
echo "RESULT: $? (fail ok/expected)";
echo ">> Cleaning keys... DONE";
cd ..;

setGitUser;

echo "> GIT submodule > push...";
git submodule foreach git push; # git push fails if there are new changes on remote
checkResult $?;
echo "> GIT submodule > push... DONE";

echo "> GIT > push...";
git push; # git push fails if there are new changes on remote
checkResult $?;
echo "> GIT > push... DONE";

printGitStatus;

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> PUSH COMMITS... DONE";
echo "================================================================================";
