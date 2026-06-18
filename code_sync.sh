#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/commons.sh;

echo "================================================================================";
echo "> CODE SYNC...";
echo "--------------------------------------------------------------------------------";
# TODO rename "git repo sync"
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

# GIT SUBMODULEs

setGitProjectName;

setGitBranch;

setIsCI;

setGitCommitEnabled;

setGitCommitDependencyUpdateEnabled;

if [[ ${MT_GIT_COMMIT_ENABLED} != true && ${MT_GIT_COMMIT_DEPENDENCY_UPDATE_ENABLED} != true ]]; then
  echo "> Git commit NOT enabled.. SKIP (MT_GIT_COMMIT_ENABLED:$MT_GIT_COMMIT_ENABLED|MT_GIT_COMMIT_DEPENDENCY_UPDATE_ENABLED:$MT_GIT_COMMIT_DEPENDENCY_UPDATE_ENABLED)";
  exit 0 # success
fi
echo "> Git commit enabled ...";

echo "> Fetching latest from submodules...";
git submodule foreach git fetch -v --all;
echo "> Fetching latest from submodules... DONE";

echo "--------------------------------------------------------------------------------";
git submodule foreach git branch -v -a;
echo "--------------------------------------------------------------------------------";

echo "> Switching to branch '$GIT_BRANCH' (or '$DEFAULT_GIT_BRANCH')...";
git submodule foreach "git switch $GIT_BRANCH || git switch $DEFAULT_GIT_BRANCH";
RESULT=$?;
if [[ ${RESULT} -ne 0 ]]; then
	echo "> Error while switching to branch '$GIT_BRANCH' (or '$DEFAULT_GIT_BRANCH') in submodules!";
	exit ${RESULT};
fi
echo "> Switching to branch '$GIT_BRANCH' (or '$DEFAULT_GIT_BRANCH')... DONE";
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
echo "> Pulling latest from submodules...";
git submodule foreach "git pull -v --ff-only";
RESULT=$?;
if [[ ${RESULT} -ne 0 ]]; then
	echo "> Error while pulling latest from submodules!";
	exit ${RESULT};
fi
echo "> Pulling latest from submodules... DONE";
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> CODE SYNC... DONE";
echo "================================================================================";
