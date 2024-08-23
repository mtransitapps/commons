#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/commons/commons.sh
echo "================================================================================";
echo "> DOWNLOAD & PARSE...";
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

	echo "> DOWNLOADING DATA FOR '$AGENCY_ID'...";
	cd ${SCRIPT_DIR}/agency-parser || exit; # >>

	./download.sh;
	RESULT=$?;
	echo "> Download result: $RESULT";

	../commons/gtfs/gtfs-validator.sh "input/gtfs.zip" "output/current";
	# checkResult $?; # too many errors for now

	if [[ -e "$FILE_PATH/input_url_next" ]]; then
		../commons/gtfs/gtfs-validator.sh "input/gtfs_next.zip" "output/next";
		# checkResult $?; # too many errors for now
	fi

	if [[ $RESULT -eq 0 ]]; then
		./unzip_gtfs.sh;
		RESULT=$?;
		echo " > Unzip result: $RESULT";
	fi

	if [[ $RESULT -ne 0 ]]; then
		echo "> Try using archive...";
		ARCHIVE_DIR="archive";
		INPUT_DIR="input";
		ARCHIVES_COUNT=$(find $ARCHIVE_DIR -name "*.zip" -type f | wc -l);
		echo "> Archives count: $ARCHIVES_COUNT";
		# 1 - for current
		if [[ "$ARCHIVES_COUNT" -eq 1 ]]; then
			echo ">> Using the only 1 archive...";
			cp $(find $ARCHIVE_DIR -name "*.zip" -type f) "$INPUT_DIR/gtfs.zip";
			checkResult $?;
		else
			echo ">> Too many ($ARCHIVES_COUNT) archives to choose from!";
			exit $RESULT;
		fi
		# 2 - for next if exists
		if [[ -e "../config/input_url_next" ]]; then
			echo ">> Try using archive for next URL...";
			if [[ "$ARCHIVES_COUNT" -eq 1 ]]; then
				echo ">> Using the only 1 archive for next URL...";
				cp $(find $ARCHIVE_DIR -name "*.zip" -type f) "$INPUT_DIR/gtfs_next.zip";
				checkResult $?;
			else
				echo ">> Too many ($ARCHIVES_COUNT) next archives to choose from!";
				# TODO? exit $RESULT;
			fi
		fi
		# 3 - unzip archive(s)
		./unzip_gtfs.sh;
		checkResult $?;
	fi

	echo "> DOWNLOADING DATA FOR '$AGENCY_ID'... DONE";

	echo "> PARSING DATA FOR '$AGENCY_ID'...";

	# CURRENT...
	./parse_current.sh;
	checkResult $?;
	# CURRENT... DONE

	# NEXT...
	./parse_next.sh;
	checkResult $?;
	# NEXT... DONE

	./list_change.sh;
	RESULT=$?;
	if [[ ${MT_GIT_COMMIT_ENABLED} == true ]]; then
		echo "RESULT: $RESULT (fail ok/expected)"; # will auto commit
	else
		echo "Data changed but GIT commit disabled!";
		checkResult $RESULT; # break build, need to manually commit
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
