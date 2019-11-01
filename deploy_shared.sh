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

# SHARED

DEST_PATH=".";
SRC_DIR_PATH="commons/shared";
for FILENAME in $(ls -a $SRC_DIR_PATH/) ; do
	SRC_FILE_PATH=$SRC_DIR_PATH/$FILENAME;
	if [[ $FILENAME == "." ]] || [[ $FILENAME == ".." ]]; then
		echo "> Skip '$FILENAME'.";
		continue;
	fi
	DEST_FILE_PATH="$DEST_PATH/$FILENAME"
	if [[ -f $SRC_FILE_PATH ]]; then
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
			echo "> Error while deploying '$SRC_FILE_PATH' to '$DEST_PATH'!";
			exit ${RESULT};
		fi
		echo "--------------------------------------------------------------------------------";
	elif [[ -d "$SRC_FILE_PATH" ]]; then
		if ! [[ -d "$DEST_FILE_PATH" ]]; then
			mkdir $DEST_FILE_PATH;
			RESULT=$?;
			if [[ ${RESULT} -ne 0 ]]; then
				echo "> Error while creating directory '$DEST_FILE_PATH' in target directory!";
				exit ${RESULT};
			fi
		fi
		S_DEST_PATH="${DEST_PATH}/${FILENAME}";
		for S_FILENAME in $(ls -a $SRC_DIR_PATH/${FILENAME}/) ; do
			S_SRC_FILE_PATH=$SRC_DIR_PATH/${FILENAME}/$S_FILENAME;
			if [[ $S_FILENAME == "." ]] || [[ $S_FILENAME == ".." ]]; then
				echo "> Skip '$S_FILENAME'.";
				continue;
			fi
			S_DEST_FILE_PATH="$S_DEST_PATH/$S_FILENAME"
			if [[ -f "$S_DEST_FILE_PATH" ]]; then
				echo "> File '$S_DEST_FILE_PATH' ($S_SRC_FILE_PATH) exists in target directory!";
				ls -l $S_DEST_FILE_PATH;
				exit 1;
			fi
			if [[ -d "$S_DEST_FILE_PATH" ]]; then
				SS_DEST_PATH="${S_DEST_PATH}/${S_FILENAME}";
				for SS_FILENAME in $(ls -a $SRC_DIR_PATH/${FILENAME}/${S_FILENAME}/) ; do
					SS_SRC_FILE_PATH=$SRC_DIR_PATH/${FILENAME}/${S_FILENAME}/$SS_FILENAME;
					if [[ $SS_FILENAME == "." ]] || [[ $SS_FILENAME == ".." ]]; then
						echo "> Skip '$SS_FILENAME'.";
						continue;
					fi
					SS_DEST_FILE_PATH="$SS_DEST_PATH/$SS_FILENAME"
					if [[ -f "$SS_DEST_FILE_PATH" ]]; then
						echo "> File '$SS_DEST_FILE_PATH' ($SS_SRC_FILE_PATH) exists in target directory!";
						ls -l $SS_DEST_FILE_PATH;
						exit 1;
					fi
					if [[ -d "$SS_DEST_FILE_PATH" ]]; then
						echo "> Directory '$SS_DEST_FILE_PATH' ($SS_SRC_FILE_PATH) exists in target directory!";
						ls -l $SS_DEST_FILE_PATH;
						exit 1;
					fi
					echo "--------------------------------------------------------------------------------";
					echo "> Deploying '$SS_SRC_FILE_PATH' in '$SS_DEST_PATH'...";
					cp -nR $SS_SRC_FILE_PATH $SS_DEST_PATH/;
					RESULT=$?;
					echo "> Deploying '$SS_SRC_FILE_PATH' in '$SS_DEST_PATH'... DONE";
					if [[ ${RESULT} -ne 0 ]]; then
						echo "Error while deploying '$SS_SRC_FILE_PATH' to '$SS_FILENAME'!";
						exit ${RESULT};
					fi
					echo "--------------------------------------------------------------------------------";
				done
			else
				echo "--------------------------------------------------------------------------------";
				echo "> Deploying '$S_SRC_FILE_PATH' in '$S_DEST_PATH'...";
				cp -nR $S_SRC_FILE_PATH $S_DEST_PATH/;
				RESULT=$?;
				echo "> Deploying '$S_SRC_FILE_PATH' in '$S_DEST_PATH'... DONE";
				if [[ ${RESULT} -ne 0 ]]; then
					echo "> Error while deploying '$S_SRC_FILE_PATH' to '$S_FILENAME'!";
					exit ${RESULT};
				fi
				echo "--------------------------------------------------------------------------------";
			fi
		done
	else #WTF
		echo "> File to deploy '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
		ls -l $FILENAME;
		exit 1;
	fi
done

# SHARED-OPT-DIR

DEST_PATH=".";
SRC_DIR_PATH="commons/shared-opt-dir";
for FILENAME in $(ls -a $SRC_DIR_PATH/) ; do
	SRC_FILE_PATH=$SRC_DIR_PATH/$FILENAME;
	if [[ $FILENAME == "." ]] || [[ $FILENAME == ".." ]]; then
		echo "> Skip '$FILENAME'.";
		continue;
	fi
	DEST_FILE_PATH="$DEST_PATH/$FILENAME"
	if [[ -f $SRC_FILE_PATH ]]; then
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
			echo "> Error while deploying '$SRC_FILE_PATH' to '$DEST_PATH'!";
			exit ${RESULT};
		fi
		echo "--------------------------------------------------------------------------------";
	elif [[ -d "$SRC_FILE_PATH" ]]; then
		if ! [[ -d "$DEST_FILE_PATH" ]]; then
			echo "> Skip optional directory '$DEST_FILE_PATH' in target directory.";
			continue;
		fi
		S_DEST_PATH="${DEST_PATH}/${FILENAME}";
		for S_FILENAME in $(ls -a $SRC_DIR_PATH/${FILENAME}/) ; do
			S_SRC_FILE_PATH=$SRC_DIR_PATH/${FILENAME}/$S_FILENAME;
			if [[ $S_FILENAME == "." ]] || [[ $S_FILENAME == ".." ]]; then
				echo "> Skip '$S_FILENAME'.";
				continue;
			fi
			S_DEST_FILE_PATH="$S_DEST_PATH/$S_FILENAME"
			if [[ -f "$S_DEST_FILE_PATH" ]]; then
				echo "> File '$S_DEST_FILE_PATH' ($S_SRC_FILE_PATH) exists in target directory!";
				ls -l $S_DEST_FILE_PATH;
				exit 1;
			fi
			if [[ -d "$S_DEST_FILE_PATH" ]]; then
				SS_DEST_PATH="${S_DEST_PATH}/${S_FILENAME}";
				for SS_FILENAME in $(ls -a $SRC_DIR_PATH/${FILENAME}/${S_FILENAME}/) ; do
					SS_SRC_FILE_PATH=$SRC_DIR_PATH/${FILENAME}/${S_FILENAME}/$SS_FILENAME;
					if [[ $SS_FILENAME == "." ]] || [[ $SS_FILENAME == ".." ]]; then
						echo "> Skip '$SS_FILENAME'.";
						continue;
					fi
					SS_DEST_FILE_PATH="$SS_DEST_PATH/$SS_FILENAME"
					if [[ -f "$SS_DEST_FILE_PATH" ]]; then
						echo "> File '$SS_DEST_FILE_PATH' ($SS_SRC_FILE_PATH) exists in target directory!";
						ls -l $SS_DEST_FILE_PATH;
						exit 1;
					fi
					if [[ -d "$SS_DEST_FILE_PATH" ]]; then
						echo "> Directory '$SS_DEST_FILE_PATH' ($SS_SRC_FILE_PATH) exists in target directory!";
						ls -l $SS_DEST_FILE_PATH;
						exit 1;
					fi
					echo "--------------------------------------------------------------------------------";
					echo "> Deploying '$SS_SRC_FILE_PATH' in '$SS_DEST_PATH'...";
					cp -nR $SS_SRC_FILE_PATH $SS_DEST_PATH/;
					RESULT=$?;
					echo "> Deploying '$SS_SRC_FILE_PATH' in '$SS_DEST_PATH'... DONE";
					if [[ ${RESULT} -ne 0 ]]; then
						echo "Error while deploying '$SS_SRC_FILE_PATH' to '$SS_FILENAME'!";
						exit ${RESULT};
					fi
					echo "--------------------------------------------------------------------------------";
				done
			else
				echo "--------------------------------------------------------------------------------";
				echo "> Deploying '$S_SRC_FILE_PATH' in '$S_DEST_PATH'...";
				cp -nR $S_SRC_FILE_PATH $S_DEST_PATH/;
				RESULT=$?;
				echo "> Deploying '$S_SRC_FILE_PATH' in '$S_DEST_PATH'... DONE";
				if [[ ${RESULT} -ne 0 ]]; then
					echo "> Error while deploying '$S_SRC_FILE_PATH' to '$S_FILENAME'!";
					exit ${RESULT};
				fi
				echo "--------------------------------------------------------------------------------";
			fi
		done
	else #WTF
		echo "> File to deploy '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
		ls -l $FILENAME;
		exit 1;
	fi
done

# SHARED-OVERWRITE

DEST_PATH=".";
SRC_DIR_PATH="commons/shared-overwrite";
for FILENAME in $(ls -a $SRC_DIR_PATH/) ; do
	SRC_FILE_PATH=$SRC_DIR_PATH/$FILENAME;
	if [[ $FILENAME == "." ]] || [[ $FILENAME == ".." ]]; then
		echo "> Skip '$FILENAME'.";
		continue;
	fi
	DEST_FILE_PATH="$DEST_PATH/$FILENAME"
	if [[ -f $SRC_FILE_PATH ]]; then
		echo "--------------------------------------------------------------------------------";
		echo "> Deploying '$SRC_FILE_PATH' in '$DEST_PATH'...";
		cp -n $SRC_FILE_PATH $DEST_FILE_PATH;
		RESULT=$?;
		echo "> Deploying '$SRC_FILE_PATH' in '$DEST_PATH'... DONE";
		if [[ ${RESULT} -ne 0 ]]; then
			echo "> Error while deploying '$SRC_FILE_PATH' to '$DEST_PATH'!";
			exit ${RESULT};
		fi
		echo "--------------------------------------------------------------------------------";
	elif [[ -d "$SRC_FILE_PATH" ]]; then
		if ! [[ -d "$DEST_FILE_PATH" ]]; then
			mkdir $DEST_FILE_PATH;
			RESULT=$?;
			if [[ ${RESULT} -ne 0 ]]; then
				echo "> Error while creating directory '$DEST_FILE_PATH' in target directory!";
				exit ${RESULT};
			fi
		fi
		S_DEST_PATH="${DEST_PATH}/${FILENAME}";
		for S_FILENAME in $(ls -a $SRC_DIR_PATH/${FILENAME}/) ; do
			S_SRC_FILE_PATH=$SRC_DIR_PATH/${FILENAME}/$S_FILENAME;
			if [[ $S_FILENAME == "." ]] || [[ $S_FILENAME == ".." ]]; then
				echo "> Skip '$S_FILENAME'.";
				continue;
			fi
			S_DEST_FILE_PATH="$S_DEST_PATH/$S_FILENAME"
			if [[ -d "$S_DEST_FILE_PATH" ]]; then
				SS_DEST_PATH="${S_DEST_PATH}/${S_FILENAME}";
				for SS_FILENAME in $(ls -a $SRC_DIR_PATH/${FILENAME}/${S_FILENAME}/) ; do
					SS_SRC_FILE_PATH=$SRC_DIR_PATH/${FILENAME}/${S_FILENAME}/$SS_FILENAME;
					if [[ $SS_FILENAME == "." ]] || [[ $SS_FILENAME == ".." ]]; then
						echo "> Skip '$SS_FILENAME'.";
						continue;
					fi
					SS_DEST_FILE_PATH="$SS_DEST_PATH/$SS_FILENAME"
					echo "--------------------------------------------------------------------------------";
					echo "> Deploying '$SS_SRC_FILE_PATH' in '$SS_DEST_PATH'...";
					cp -nR $SS_SRC_FILE_PATH $SS_DEST_PATH/;
					RESULT=$?;
					echo "> Deploying '$SS_SRC_FILE_PATH' in '$SS_DEST_PATH'... DONE";
					if [[ ${RESULT} -ne 0 ]]; then
						echo "Error while deploying '$SS_SRC_FILE_PATH' to '$SS_FILENAME'!";
						exit ${RESULT};
					fi
					echo "--------------------------------------------------------------------------------";
				done
			else
				echo "--------------------------------------------------------------------------------";
				echo "> Deploying '$S_SRC_FILE_PATH' in '$S_DEST_PATH'...";
				cp -nR $S_SRC_FILE_PATH $S_DEST_PATH/;
				RESULT=$?;
				echo "> Deploying '$S_SRC_FILE_PATH' in '$S_DEST_PATH'... DONE";
				if [[ ${RESULT} -ne 0 ]]; then
					echo "> Error while deploying '$S_SRC_FILE_PATH' to '$S_FILENAME'!";
					exit ${RESULT};
				fi
				echo "--------------------------------------------------------------------------------";
			fi
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
