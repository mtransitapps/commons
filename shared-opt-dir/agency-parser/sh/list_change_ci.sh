#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR=$(cd "${SCRIPT_DIR}/../.." && pwd);

source "${ROOT_DIR}/commons/sh/commons.sh"

echo "================================================================================";
echo "> LIST CHANGE FOR CI...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

setGitProjectName;

setIsCI;

setGradleArgs;

setGitCommitEnabled;

if [[ -d "${ROOT_DIR}/agency-parser" ]]; then

    CURRENT_PATH=$(pwd);
	cd "${ROOT_DIR}/agency-parser" || exit; # >>

	./sh/list_change.sh;
	RESULT=$?;
	if [[ ${MT_GIT_COMMIT_ENABLED} == true ]]; then
		echo "RESULT: $RESULT (fail ok/expected)"; # will auto commit
	else
		echo "Data changed but GIT commit disabled!";
		checkResult $RESULT; # break build, need to manually commit
	fi

	cd ${CURRENT_PATH} || exit; # <<
else
	echo "> SKIP PARSING FOR '$PROJECT_NAME'.";
fi

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "--------------------------------------------------------------------------------";
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> LIST CHANGE FOR CI... DONE";
echo "================================================================================";
