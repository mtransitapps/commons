#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> COMMIT CODE CHANGE..";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

CONFIRM=false;

setIsCI;

setGradleArgs;

setGitCommitEnabled;

if [[ ${MT_GIT_COMMIT_ENABLED} != true ]]; then
  echo "> Git commit NOT enabled.. SKIP";
  exit 0 # success
fi
echo "> Git commit enabled ...";

cd app-android || exit;
echo ">> Cleaning keys...";
./keys_cleanup.sh;
echo "RESULT: $? (fail ok/expected)";
echo ">> Cleaning keys... DONE";
cd ..;

setGitUser;

GIT_MSG="Sync code";
if [[ ${IS_CI} = true ]]; then
  GIT_MSG="CI: sync code";
fi
echo "GIT_MSG: $GIT_MSG";

echo "> GIT submodule > add...";
git submodule foreach git add -v -A;
checkResult $?;
echo "> GIT submodule > add... DONE";
echo "> GIT submodule > commit '$GIT_MSG'...";
# git submodule foreach git commit -q -m "$GIT_MSG";
# git submodule foreach git diff-index --quiet HEAD || git commit -m "$GIT_MSG";
git submodule foreach "git diff-index --quiet HEAD || git commit -m '$GIT_MSG'";
checkResult $?;
echo "> GIT submodule > commit '$GIT_MSG'... DONE";
# TODO ? git submodule foreach git push;

echo "> GIT > git_commit_all_submodules.sh...";
./git_commit_all_submodules.sh;
checkResult $?;
echo "> GIT > git_commit_all_submodules.sh... DONE";
# TODO ? git push;

printGitStatus;

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> COMMIT CODE CHANGE... DONE";
echo "================================================================================";
