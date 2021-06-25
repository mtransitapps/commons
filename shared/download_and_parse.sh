#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> DOWNLOAD & PARSE...";
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

if [[ -d "agency-parser" ]]; then

	echo "> DOWNLOADING DATA FOR '$AGENCY_ID'...";
	cd agency-parser || exit; # >>

	./download.sh;
	checkResult $? ${CONFIRM};

	./unzip_gtfs.sh;
	checkResult $? ${CONFIRM};

	echo "> DOWNLOADING DATA FOR '$AGENCY_ID'... DONE";

	echo "> PARSING DATA FOR '$AGENCY_ID'...";

	# CURRENT...
	./parse_current.sh;
	checkResult $? ${CONFIRM};
	# CURRENT... DONE

	# NEXT...
	./parse_next.sh;
	checkResult $? ${CONFIRM};
	# NEXT... DONE

	./list_change.sh;
	RESULT=$?;
	if [[ ${MT_GIT_COMMIT_ENABLED} == true ]]; then
		echo "RESULT: $RESULT (fail ok/expected)"; # will auto commitk
	else
		checkResult $RESULT ${CONFIRM}; # break build, need to manually commit
	fi

	cd ..; # <<
	echo "> PARSING DATA FOR '$AGENCY_ID'... DONE";
else
	echo "> SKIP PARSING FOR '$AGENCY_ID'.";
fi

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> DOWNLOAD & PARSE... DONE";
echo "================================================================================";
