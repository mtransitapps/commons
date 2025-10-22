#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/commons/commons.sh
echo "================================================================================";
echo "> DOWNLOAD & PREPARE...";
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
  cd ${SCRIPT_DIR}/agency-parser || exit; # >>

	echo "> DOWNLOADING DATA FOR '$AGENCY_ID'...";

	AGENCY_PARSER_DIR=".";
	echo "> AGENCY_PARSER_DIR: $AGENCY_PARSER_DIR";

	# DOWNLOAD ALL AVAILABLE FEEDS URLS & ARCHIVE ZIP FILES
	$AGENCY_PARSER_DIR/download.sh; # and archive
	RESULT=$?; # failure is fine: will use last successful archive(s)
	echo "> Download result: $RESULT";

	# PICK ZIP FILES FROM ARCHIVE
	$AGENCY_PARSER_DIR/archive_selection.sh;
	RESULT=$?;
	checkResult $RESULT;
	echo "> Select archive result: $RESULT";

	# if [[ $RESULT -eq 0 ]]; then
	$AGENCY_PARSER_DIR/unzip_gtfs.sh;
	RESULT=$?;
	checkResult $RESULT;
	echo " > Unzip result: $RESULT";
	# fi

	INPUT_DIR="$AGENCY_PARSER_DIR/input";

# TODO delete? and use 'checkResult $?;' directly? -> should not be used anymore since archive_selection.sh
#	if [[ $RESULT -ne 0 ]]; then
#		echo "> Try using archive...";
#		ARCHIVE_DIR="$AGENCY_PARSER_DIR/archive";
#		GTFS_ZIP="$INPUT_DIR/gtfs.zip";
#		echo ">> current file:";
#		ls -l "$GTFS_ZIP";
#		ARCHIVES_COUNT=$(find $ARCHIVE_DIR -name "*.zip" -type f | wc -l);
#		echo "> Archives count: $ARCHIVES_COUNT";
#		ls -l $ARCHIVE_DIR;
#		# 1 - for current
#		if [[ "$ARCHIVES_COUNT" -eq 1 ]]; then
#			echo ">> Using the only 1 archive...";
#			ARCHIVE=$(find $ARCHIVE_DIR -name "*.zip" -type f);
#			echo ">> - Archive: '$ARCHIVE'.";
#			echo ">> - Loading archive from LFS...";
#			git lfs pull;
#			checkResult $?;
#			echo ">> - Loading archive from LFS... DONE";
#			ls -l $ARCHIVE_DIR;
#			echo ">> - Copying '$ARCHIVE' to '$GTFS_ZIP'...";
#			cp $ARCHIVE "$GTFS_ZIP";
#			checkResult $?;
#			echo ">> - Copying '$ARCHIVE' to '$GTFS_ZIP'... DONE";
#			echo ">> new file:";
#			ls -l "$GTFS_ZIP";
#		else
#			echo ">> Too many ($ARCHIVES_COUNT) archives to choose from!";
#			exit $RESULT;
#		fi
#		# 2 - for next if exists
#		if [[ -e "../config/input_url_next" ]]; then
#			echo ">> Try using archive for next URL...";
#			GTFS_NEXT_ZIP="$INPUT_DIR/gtfs_next.zip";
#			echo ">> current file:";
#			ls -l "$GTFS_NEXT_ZIP";
#			if [[ "$ARCHIVES_COUNT" -eq 1 ]]; then
#				echo ">> Using the only 1 archive for next URL...";
#				ARCHIVE=$(find $ARCHIVE_DIR -name "*.zip" -type f);
#				echo ">> - Archive: '$ARCHIVE'.";
#				echo ">> - Loading archive from LFS...";
#				git lfs pull;
#				checkResult $?;
#				echo ">> - Loading archive from LFS... DONE";
#				ls -l $ARCHIVE_DIR;
#				echo ">> - Copying '$ARCHIVE' to '$GTFS_NEXT_ZIP'...";
#				cp $ARCHIVE "$GTFS_NEXT_ZIP";
#				checkResult $?;
#				echo ">> - Copying '$ARCHIVE' to '$GTFS_NEXT_ZIP'... DONE";
#				echo ">> new file:";
#				ls -l "$GTFS_NEXT_ZIP";
#			else
#				echo ">> Too many ($ARCHIVES_COUNT) next archives to choose from!";
#				# TODO? exit $RESULT;
#			fi
#		fi
#		# 3 - unzip archive(s)
#		$AGENCY_PARSER_DIR/unzip_gtfs.sh;
#		checkResult $?;
#	fi

	echo "> DOWNLOADING DATA FOR '$AGENCY_ID'... DONE";

	cd ../; # <<
else
	echo "> SKIP DOWNLOADING FOR '$AGENCY_ID'.";
fi

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> DOWNLOAD & PREPARE... DONE";
echo "================================================================================";
