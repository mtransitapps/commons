#!/bin/bash
#NO DEPENDENCY <= EXECUTED BEFORE GIT SUBMODULE

echo "================================================================================";
echo "> DEPLOY SHARED...";
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
		if [[ -f "$DEST_FILE_PATH" ]]; then
			echo "> File '$DEST_FILE_PATH' ($SRC_FILE_PATH) exists in target directory!";
			ls -l $DEST_FILE_PATH;
			exit 1;
		fi
		echo "> Deploying '$SRC_FILE_PATH' in '$DEST_PATH'...";
		cp -n $SRC_FILE_PATH $DEST_FILE_PATH;
		RESULT=$?;
		echo "> Deploying '$SRC_FILE_PATH' in '$DEST_PATH'... DONE";
		if [[ ${RESULT} -ne 0 ]]; then
			echo "Error while deploying '$SRC_FILE_PATH' to '$DEST_PATH'!";
			exit ${RESULT};
		fi
		echo "--------------------------------------------------------------------------------";
	elif [[ -d "$SRC_FILE_PATH" ]]; then
		DEST_PATH=".";
		DEST_FILE_PATH="$DEST_PATH/$FILENAME"
		if ! [[ -d "$DEST_FILE_PATH" ]]; then
			mkdir $DEST_FILE_PATH;
			RESULT=$?;
			if [[ ${RESULT} -ne 0 ]]; then
				echo "Error while creating directory '$DEST_FILE_PATH' in target directory!";
				exit ${RESULT};
			fi
		fi
		for S_SRC_FILE_PATH in commons/shared/${FILENAME}/* ; do
			echo "--------------------------------------------------------------------------------";
			S_FILENAME=$(basename ${S_SRC_FILE_PATH});
			S_DEST_PATH="${FILENAME}";
			S_DEST_FILE_PATH="$S_DEST_PATH/$S_FILENAME"
			if [[ -f "$S_DEST_FILE_PATH" ]]; then
				echo "> File '$S_DEST_FILE_PATH' ($S_SRC_FILE_PATH) exists in target directory!";
				ls -l $S_DEST_FILE_PATH;
				exit 1;
			fi
			if [[ -d "$S_DEST_FILE_PATH" ]]; then
				echo "> Directory '$S_DEST_FILE_PATH' ($S_SRC_FILE_PATH) exists in target directory!";
				ls -l $S_DEST_FILE_PATH;
				exit 1;
			fi
			echo "> Deploying '$S_SRC_FILE_PATH' in '$S_DEST_PATH'...";
			cp -nR $S_SRC_FILE_PATH $S_DEST_FILE_PATH/;
			RESULT=$?;
			echo "> Deploying '$S_SRC_FILE_PATH' in '$S_DEST_PATH'... DONE";
			if [[ ${RESULT} -ne 0 ]]; then
				echo "Error while deploying '$S_SRC_FILE_PATH' to '$S_FILENAME'!";
				exit ${RESULT};
			fi
			echo "--------------------------------------------------------------------------------";
		done
	else #WTF
		echo "> File to deploy '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
		ls -l $FILENAME;
		exit 1;
	fi
done 


echo "--------------------------------------------------------------------------------";
AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> DEPLOY SHARED... DONE";
echo "================================================================================";
