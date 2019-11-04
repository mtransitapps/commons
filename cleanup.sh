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

DEST_PATH=".";

SRC_DIR_PATH="commons/shared";
for FILENAME in $(ls -a $SRC_DIR_PATH/) ; do
	SRC_FILE_PATH=$SRC_DIR_PATH/$FILENAME;
	if [[ $FILENAME == "." ]] || [[ $FILENAME == ".." ]]; then
		continue;
	fi
	DEST_FILE_PATH="$DEST_PATH/$FILENAME"
	if [[ -f ${SRC_FILE_PATH} ]]; then
		echo "--------------------------------------------------------------------------------";
		if ! [[ -f "$DEST_FILE_PATH" ]]; then
			echo "> File to cleanup '$DEST_FILE_PATH' ($SRC_FILE_PATH) does NOT exist in target directory!";
			exit 1;
		fi
		diff -q ${DEST_FILE_PATH} ${SRC_FILE_PATH};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo "> Deployed shared file $DEST_FILE_PATH CHANGED (source: '$SRC_FILE_PATH')!";
			exit ${RESULT};
		fi
		echo "> Cleaning-up file '$DEST_FILE_PATH' in '$DEST_PATH'...";
		rm ${DEST_FILE_PATH};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo "> Error while cleaning-up file '$DEST_FILE_PATH' to '$DEST_PATH'!";
			exit ${RESULT};
		fi
		echo "> Cleaning-up file '$DEST_FILE_PATH' in '$DEST_PATH'... DONE";
		echo "--------------------------------------------------------------------------------";
	elif [[ -d "$SRC_FILE_PATH" ]]; then
		if ! [[ -d "$DEST_FILE_PATH" ]]; then
			echo "> Directory to cleanup '$DEST_FILE_PATH' not found in target directory!";
			exit 1;
		fi
		S_DEST_PATH="$DEST_PATH/${FILENAME}";
		for S_FILENAME in $(ls -a ${SRC_DIR_PATH}/${FILENAME}/) ; do
			S_SRC_FILE_PATH=${SRC_DIR_PATH}/${FILENAME}/$S_FILENAME;
			if [[ $S_FILENAME == "." ]] || [[ $S_FILENAME == ".." ]]; then
				continue;
			fi
			echo "--------------------------------------------------------------------------------";
			S_DEST_FILE_PATH="$S_DEST_PATH/$S_FILENAME"
			if [[ -f "$S_SRC_FILE_PATH" ]]; then
				if ! [[ -f "$S_DEST_FILE_PATH" ]]; then
					echo "> File to cleanup '$S_DEST_FILE_PATH' ($S_SRC_FILE_PATH) does NOT exist in target directory!";
					exit 1;
				fi
				diff -q ${S_DEST_FILE_PATH} ${S_SRC_FILE_PATH};
				RESULT=$?;
				if [[ ${RESULT} -ne 0 ]]; then
					echo "> Deployed shared file $S_DEST_FILE_PATH CHANGED (source: '$S_SRC_FILE_PATH')!";
					exit ${RESULT};
				fi
				echo "> Cleaning-up file '$S_DEST_FILE_PATH' in '$S_DEST_PATH'...";
				rm ${S_DEST_FILE_PATH};
				RESULT=$?;
				if [[ ${RESULT} -ne 0 ]]; then
					echo "> Error while cleaning-up file '$S_DEST_FILE_PATH' to '$S_DEST_PATH'!";
					exit ${RESULT};
				fi
				echo "> Cleaning-up file '$S_DEST_FILE_PATH' in '$S_DEST_PATH'... DONE";
				echo "--------------------------------------------------------------------------------";
			elif [[ -d "$S_SRC_FILE_PATH" ]]; then
				if ! [[ -d "$S_DEST_FILE_PATH" ]]; then
					echo "> Direcotory to cleanup '$S_DEST_FILE_PATH' ($S_SRC_FILE_PATH) does NOT exist in target directory!";
					exit 1;
				fi
				SS_DEST_PATH="${S_DEST_PATH}/${S_FILENAME}";
				for SS_FILENAME in $(ls -a ${SRC_DIR_PATH}/${FILENAME}/${S_FILENAME}/) ; do
					SS_SRC_FILE_PATH=${SRC_DIR_PATH}/${FILENAME}/${S_FILENAME}/$SS_FILENAME;
					if [[ $SS_FILENAME == "." ]] || [[ $SS_FILENAME == ".." ]]; then
						continue;
					fi
					echo "--------------------------------------------------------------------------------";
					SS_DEST_FILE_PATH="$SS_DEST_PATH/$SS_FILENAME"
					if [[ -f "$SS_SRC_FILE_PATH" ]]; then
						if ! [[ -f "$SS_DEST_FILE_PATH" ]]; then
							echo "> File to cleanup '$SS_DEST_FILE_PATH' ($SS_SRC_FILE_PATH) does NOT exist in target directory!";
							exit 1;
						fi
						diff -q ${SS_DEST_FILE_PATH} ${SS_SRC_FILE_PATH};
						RESULT=$?;
						if [[ ${RESULT} -ne 0 ]]; then
							echo "> Deployed shared file $SS_DEST_FILE_PATH CHANGED (source: '$SS_SRC_FILE_PATH')!";
							exit ${RESULT};
						fi
						echo "> Cleaning-up file '$SS_DEST_FILE_PATH' in '$SS_DEST_PATH'...";
						rm ${SS_DEST_FILE_PATH};
						RESULT=$?;
						if [[ ${RESULT} -ne 0 ]]; then
							echo "> Error while cleaning-up file '$SS_DEST_FILE_PATH' to '$SS_DEST_PATH'!";
							exit ${RESULT};
						fi
						echo "> Cleaning-up file '$SS_DEST_FILE_PATH' in '$SS_DEST_PATH'... DONE";
						echo "--------------------------------------------------------------------------------";
					elif [[ -d "$S_SRC_FILE_PATH" ]]; then
						if ! [[ -d "$SS_DEST_FILE_PATH" ]]; then
							echo "> Direcotory to cleanup '$SS_DEST_FILE_PATH' ($SS_SRC_FILE_PATH) does NOT exist in target directory!";
							exit 1;
						fi
						diff -q -r ${SS_DEST_FILE_PATH} ${SS_SRC_FILE_PATH};
						RESULT=$?;
						if [[ ${RESULT} -ne 0 ]]; then
							echo "> Deployed shared directory $SS_DEST_FILE_PATH CHANGED (source: '$SS_SRC_FILE_PATH')!";
							exit ${RESULT};
						fi
						echo "> Cleaning-up directory '$SS_DEST_FILE_PATH' in '$SS_DEST_PATH'...";
						rm -r ${SS_DEST_FILE_PATH};
						RESULT=$?;
						if [[ ${RESULT} -ne 0 ]]; then
							echo "> Error while cleaning-up directory '$SS_DEST_FILE_PATH' to '$SS_DEST_PATH'!";
							exit ${RESULT};
						fi
						echo "> Cleaning-up directory '$SS_DEST_FILE_PATH' in '$SS_DEST_PATH'... DONE";
						echo "--------------------------------------------------------------------------------";
					else #WTF
						echo "> File to cleanup '$SS_FILENAME' ($SS_SRC_FILE_PATH) is neither a directory or a file!";
						ls -l ${SS_FILENAME};
						exit 1;
					fi
				done
				if ! [[ "$(ls -A ${S_DEST_FILE_PATH})" ]]; then
					echo "> Deleting empty directory '$S_DEST_FILE_PATH'...";
					rm -r ${S_DEST_FILE_PATH};
					RESULT=$?;
					if [[ ${RESULT} -ne 0 ]]; then
						echo "> Error while deleting empty directory '$S_DEST_FILE_PATH'!";
						exit ${RESULT};
					fi
					echo "> Deleting empty directory '$S_DEST_FILE_PATH'... DONE";
				fi
			else #WTF
				echo "> File to cleanup '$S_FILENAME' ($S_SRC_FILE_PATH) is neither a directory or a file!";
				ls -l ${S_FILENAME};
				exit 1;
			fi
		done
		if ! [[ "$(ls -A ${DEST_FILE_PATH})" ]]; then
			echo "> Deleting empty directory '$DEST_FILE_PATH'...";
			rm -r ${DEST_FILE_PATH};
			RESULT=$?;
			if [[ ${RESULT} -ne 0 ]]; then
				echo "> Error while deleting empty directory '$DEST_FILE_PATH'!";
				exit ${RESULT};
			fi
			echo "> Deleting empty directory '$DEST_FILE_PATH'... DONE";
		fi
	else #WTF
		echo "> File to cleanup '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
		ls -l ${FILENAME};
		exit 1;
	fi
done

SRC_DIR_PATH="commons/shared-opt-dir";
for FILENAME in $(ls -a $SRC_DIR_PATH/) ; do
	SRC_FILE_PATH=$SRC_DIR_PATH/$FILENAME;
	if [[ $FILENAME == "." ]] || [[ $FILENAME == ".." ]]; then
		continue;
	fi
	DEST_FILE_PATH="$DEST_PATH/$FILENAME"
	if [[ -f ${SRC_FILE_PATH} ]]; then
		echo "--------------------------------------------------------------------------------";
		if ! [[ -f "$DEST_FILE_PATH" ]]; then
			echo "> File to cleanup '$DEST_FILE_PATH' ($SRC_FILE_PATH) does NOT exist in target directory.";
			continue;
		fi
		diff -q ${DEST_FILE_PATH} ${SRC_FILE_PATH};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo "> Deployed shared file $DEST_FILE_PATH CHANGED (source: '$SRC_FILE_PATH')!";
			exit ${RESULT};
		fi
		echo "> Cleaning-up file '$DEST_FILE_PATH' in '$DEST_PATH'...";
		rm ${DEST_FILE_PATH};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo "> Error while cleaning-up file '$DEST_FILE_PATH' to '$DEST_PATH'!";
			exit ${RESULT};
		fi
		echo "> Cleaning-up file '$DEST_FILE_PATH' in '$DEST_PATH'... DONE";
		echo "--------------------------------------------------------------------------------";
	elif [[ -d "$SRC_FILE_PATH" ]]; then
		if ! [[ -d "$DEST_FILE_PATH" ]]; then
			echo "> Directory to cleanup '$DEST_FILE_PATH' does NOT exist in target in target directory.";
			continue;
		fi
		S_DEST_PATH="$DEST_PATH/${FILENAME}";
		for S_FILENAME in $(ls -a ${SRC_DIR_PATH}/${FILENAME}/) ; do
			S_SRC_FILE_PATH=${SRC_DIR_PATH}/${FILENAME}/$S_FILENAME;
			if [[ $S_FILENAME == "." ]] || [[ $S_FILENAME == ".." ]]; then
				continue;
			fi
			echo "--------------------------------------------------------------------------------";
			S_DEST_FILE_PATH="$S_DEST_PATH/$S_FILENAME"
			if [[ -f "$S_SRC_FILE_PATH" ]]; then
				if ! [[ -f "$S_DEST_FILE_PATH" ]]; then
					echo "> File to cleanup '$S_DEST_FILE_PATH' ($S_SRC_FILE_PATH) does NOT exist in target directory.";
					continue;
				fi
				diff -q ${S_DEST_FILE_PATH} ${S_SRC_FILE_PATH};
				RESULT=$?;
				if [[ ${RESULT} -ne 0 ]]; then
					echo "> Deployed shared file $S_DEST_FILE_PATH CHANGED (source: '$S_SRC_FILE_PATH')!";
					exit ${RESULT};
				fi
				echo "> Cleaning-up file '$S_DEST_FILE_PATH' in '$S_DEST_PATH'...";
				rm ${S_DEST_FILE_PATH};
				RESULT=$?;
				if [[ ${RESULT} -ne 0 ]]; then
					echo "> Error while cleaning-up file '$S_DEST_FILE_PATH' to '$S_DEST_PATH'!";
					exit ${RESULT};
				fi
				echo "> Cleaning-up file '$S_DEST_FILE_PATH' in '$S_DEST_PATH'... DONE";
				echo "--------------------------------------------------------------------------------";
			elif [[ -d "$S_SRC_FILE_PATH" ]]; then
				if ! [[ -d "$S_DEST_FILE_PATH" ]]; then
					echo "> Direcotory to cleanup '$S_DEST_FILE_PATH' ($S_SRC_FILE_PATH) does NOT exist in target directory.";
					continue;
				fi
				SS_DEST_PATH="${S_DEST_PATH}/${S_FILENAME}";
				for SS_FILENAME in $(ls -a ${SRC_DIR_PATH}/${FILENAME}/${S_FILENAME}/) ; do
					SS_SRC_FILE_PATH=${SRC_DIR_PATH}/${FILENAME}/${S_FILENAME}/$SS_FILENAME;
					if [[ $SS_FILENAME == "." ]] || [[ $SS_FILENAME == ".." ]]; then
						continue;
					fi
					echo "--------------------------------------------------------------------------------";
					SS_DEST_FILE_PATH="$SS_DEST_PATH/$SS_FILENAME"
					if [[ -f "$SS_SRC_FILE_PATH" ]]; then
						if ! [[ -f "$SS_DEST_FILE_PATH" ]]; then
							echo "> File to cleanup '$SS_DEST_FILE_PATH' ($SS_SRC_FILE_PATH) does NOT exist in target directory.";
							continue;
						fi
						diff -q ${SS_DEST_FILE_PATH} ${SS_SRC_FILE_PATH};
						RESULT=$?;
						if [[ ${RESULT} -ne 0 ]]; then
							echo "> Deployed shared file $SS_DEST_FILE_PATH CHANGED (source: '$SS_SRC_FILE_PATH')!";
							exit ${RESULT};
						fi
						echo "> Cleaning-up file '$SS_DEST_FILE_PATH' in '$SS_DEST_PATH'...";
						rm ${SS_DEST_FILE_PATH};
						RESULT=$?;
						if [[ ${RESULT} -ne 0 ]]; then
							echo "> Error while cleaning-up file '$SS_DEST_FILE_PATH' to '$SS_DEST_PATH'!";
							exit ${RESULT};
						fi
						echo "> Cleaning-up file '$SS_DEST_FILE_PATH' in '$SS_DEST_PATH'... DONE";
						echo "--------------------------------------------------------------------------------";
					elif [[ -d "$S_SRC_FILE_PATH" ]]; then
						if ! [[ -d "$SS_DEST_FILE_PATH" ]]; then
							echo "> Direcotory to cleanup '$SS_DEST_FILE_PATH' ($SS_SRC_FILE_PATH) does NOT exist in target directory.";
							continue;
						fi
						diff -q -r ${SS_DEST_FILE_PATH} ${SS_SRC_FILE_PATH};
						RESULT=$?;
						if [[ ${RESULT} -ne 0 ]]; then
							echo "> Deployed shared directory $SS_DEST_FILE_PATH CHANGED (source: '$SS_SRC_FILE_PATH')!";
							exit ${RESULT};
						fi
						echo "> Cleaning-up directory '$SS_DEST_FILE_PATH' in '$SS_DEST_PATH'...";
						rm -r ${SS_DEST_FILE_PATH};
						RESULT=$?;
						if [[ ${RESULT} -ne 0 ]]; then
							echo "> Error while cleaning-up directory '$SS_DEST_FILE_PATH' to '$SS_DEST_PATH'!";
							exit ${RESULT};
						fi
						echo "> Cleaning-up directory '$SS_DEST_FILE_PATH' in '$SS_DEST_PATH'... DONE";
						echo "--------------------------------------------------------------------------------";
					else #WTF
						echo "> File to cleanup '$SS_FILENAME' ($SS_SRC_FILE_PATH) is neither a directory or a file!";
						ls -l ${SS_FILENAME};
						exit 1;
					fi
				done
				if ! [[ "$(ls -A ${S_DEST_FILE_PATH})" ]]; then
					echo "> Deleting empty directory '$S_DEST_FILE_PATH'...";
					rm -r ${S_DEST_FILE_PATH};
					RESULT=$?;
					if [[ ${RESULT} -ne 0 ]]; then
						echo "> Error while deleting empty directory '$S_DEST_FILE_PATH'!";
						exit ${RESULT};
					fi
					echo "> Deleting empty directory '$S_DEST_FILE_PATH'... DONE";
				fi
			else #WTF
				echo "> File to cleanup '$S_FILENAME' ($S_SRC_FILE_PATH) is neither a directory or a file!";
				ls -l ${S_FILENAME};
				exit 1;
			fi
		done
		if ! [[ "$(ls -A ${DEST_FILE_PATH})" ]]; then
			echo "> Deleting empty directory '$DEST_FILE_PATH'...";
			rm -r ${DEST_FILE_PATH};
			RESULT=$?;
			if [[ ${RESULT} -ne 0 ]]; then
				echo "> Error while deleting empty directory '$DEST_FILE_PATH'!";
				exit ${RESULT};
			fi
			echo "> Deleting empty directory '$DEST_FILE_PATH'... DONE";
		fi
	else #WTF
		echo "> File to cleanup '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
		ls -l ${FILENAME};
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
