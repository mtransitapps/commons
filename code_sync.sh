#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/commons.sh;

echo "================================================================================";
echo "> CODE SYNC...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});

echo "Current directory: '$CURRENT_DIRECTORY'";

# GIT SUBMODULEs

GIT_URL=$(git config --get remote.origin.url); # remote get-url origin
echo "> Git URL: '$GIT_URL'.";
GIT_PROJECT_NAME=$(basename -- ${GIT_URL});
GIT_PROJECT_NAME="${GIT_PROJECT_NAME%.*}"
echo "> Git project name: '$GIT_PROJECT_NAME'.";
if [[ -z "${GIT_PROJECT_NAME}" ]]; then
	echo "GIT_PROJECT_NAME not found!";
	exit 1;
fi

setGitBranch;

setIsCI;

setGitCommitEnabled;

if [[ ${MT_GIT_COMMIT_ENABLED} != true ]]; then
  echo "> Git commit NOT enabled.. SKIP";
  exit 0 # success
fi
echo "> Git commit enabled ...";

echo "--------------------------------------------------------------------------------";
echo "> Checkout branch '$GIT_BRANCH'...";
git submodule foreach git fetch --all;
git submodule foreach git branch -a;
# git submodule foreach git checkout $GIT_BRANCH;
git submodule foreach git switch --no-guess $GIT_BRANCH;
RESULT=$?;
if [[ ${RESULT} -ne 0 ]]; then
	echo "> Error while checking out '$GIT_BRANCH' in submodules!";
	exit ${RESULT};
fi
echo "> Checkout branch '$GIT_BRANCH'... DONE";
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
echo "> Pulling latest from branch '$GIT_BRANCH'...";
git submodule foreach git pull;
RESULT=$?;
if [[ ${RESULT} -ne 0 ]]; then
	echo "> Error while pulling latest from '$GIT_BRANCH' in submodules!";
	exit ${RESULT};
fi
echo "> Pulling latest from branch '$GIT_BRANCH'... DONE";
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> CODE SYNC... DONE";
echo "================================================================================";
