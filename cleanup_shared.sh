#!/bin/bash
#NO DEPENDENCY <= EXECUTED BEFORE GIT SUBMODULE

echo "================================================================================";
echo "> CLEANUP SHARED...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});

echo "Current directory: $CURRENT_DIRECTORY";

for SRC_FILE_PATH in commons/shared/* ; do
	FILENAME=$(basename ${SRC_FILE_PATH});
	if [[ -f $SRC_FILE_PATH ]]; then
		DEST_PATH=".";
		DEST_FILE_PATH="$DEST_PATH/$FILENAME"
		echo "--------------------------------------------------------------------------------";
		if ! [[ -f "$DEST_FILE_PATH" ]]; then
			echo "> File '$DEST_FILE_PATH' ($SRC_FILE_PATH) does NOT exist in target directory!";
			exit 1;
		fi
		diff -q $DEST_FILE_PATH $SRC_FILE_PATH;
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo "Deployed shared file $DEST_FILE_PATH changed (source: '$SRC_FILE_PATH')!";
			exit ${RESULT};
		fi		
		echo "> Cleaning-up '$DEST_FILE_PATH' in '$DEST_PATH'...";
		rm $DEST_FILE_PATH;
		RESULT=$?;
		echo "> Cleaning-up '$DEST_FILE_PATH' in '$DEST_PATH'... DONE";
		if [[ ${RESULT} -ne 0 ]]; then
			echo "Error while cleaning-up '$DEST_FILE_PATH' to '$DEST_PATH'!";
			exit ${RESULT};
		fi
		echo "--------------------------------------------------------------------------------";
	elif [[ -d "$SRC_FILE_PATH" ]]; then
		DEST_PATH=".";
		DEST_FILE_PATH="$DEST_PATH/$FILENAME"
		if ! [[ -d "$DEST_FILE_PATH" ]]; then
			echo "Directory to cleanup '$DEST_FILE_PATH' not found in target directory!";
			exit 1;
		fi
		for S_SRC_FILE_PATH in commons/shared/${FILENAME}/* ; do
			echo "--------------------------------------------------------------------------------";
			S_FILENAME=$(basename ${S_SRC_FILE_PATH});
			S_DEST_PATH="${FILENAME}";
			S_DEST_FILE_PATH="$S_DEST_PATH/$S_FILENAME"
			if [[ -f "$S_SRC_FILE_PATH" ]]; then
				if ! [[ -f "$S_DEST_FILE_PATH" ]]; then
					echo "> File '$S_DEST_FILE_PATH' ($S_SRC_FILE_PATH) does NOT exist in target directory!";
					exit 1;
				fi
				diff -q $S_DEST_FILE_PATH $S_SRC_FILE_PATH;
				RESULT=$?;
				if [[ ${RESULT} -ne 0 ]]; then
					echo "Deployed shared file $S_DEST_FILE_PATH changed (source: '$S_SRC_FILE_PATH')!";
					exit ${RESULT};
				fi		
				echo "> Cleaning-up '$S_DEST_FILE_PATH' in '$S_DEST_PATH'...";
				rm $S_DEST_FILE_PATH;
				RESULT=$?;
				echo "> Cleaning-up '$S_DEST_FILE_PATH' in '$S_DEST_PATH'... DONE";
				if [[ ${RESULT} -ne 0 ]]; then
					echo "Error while cleaning-up '$S_DEST_FILE_PATH' to '$DEST_PATH'!";
					exit ${RESULT};
				fi
				echo "--------------------------------------------------------------------------------";
			elif [[ -d "$S_SRC_FILE_PATH" ]]; then
				if ! [[ -d "$S_DEST_FILE_PATH" ]]; then
					echo "> Direcotory '$S_DEST_FILE_PATH' ($S_SRC_FILE_PATH) does NOT exist in target directory!";
					exit 1;
				fi
				diff -q -r $S_DEST_FILE_PATH $S_SRC_FILE_PATH;
				RESULT=$?;
				if [[ ${RESULT} -ne 0 ]]; then
					echo "Deployed shared directory $S_DEST_FILE_PATH changed (source: '$S_SRC_FILE_PATH')!";
					exit ${RESULT};
				fi	
				echo "> Cleaning-up '$S_DEST_FILE_PATH' in '$S_DEST_PATH'...";
				rm -r $S_DEST_FILE_PATH;
				RESULT=$?;
				echo "> Cleaning-up '$S_DEST_FILE_PATH' in '$S_DEST_PATH'... DONE";
				if [[ ${RESULT} -ne 0 ]]; then
					echo "Error while cleaning-up '$S_DEST_FILE_PATH' to '$DEST_PATH'!";
					exit ${RESULT};
				fi
				echo "--------------------------------------------------------------------------------";
			else #WTF
				echo "> File to cleanup '$S_FILENAME' ($S_SRC_FILE_PATH) is neither a directory or a file!";
				ls -l $S_FILENAME;
				exit 1;
			fi
		done
	else #WTF
		echo "> File to cleanup '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
		ls -l $FILENAME;
		exit 1;
	fi
done 


echo "--------------------------------------------------------------------------------";
AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> CLEANUP SHARED... DONE";
echo "================================================================================";
