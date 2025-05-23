#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source $SCRIPT_DIR/commons.sh;

echo "================================================================================";
echo "> CLEANUP SHARED...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});

echo "Current directory: $CURRENT_DIRECTORY";

setGradleArgs;

setGitProjectName;

if [[ -f "./gradlew" ]]; then
	./gradlew clean ${GRADLE_ARGS};
	checkResult $?;
	rm gradlew; # only once
	checkResult $?;
fi

if [[ -d "app-android" ]]; then
	cd app-android || exit; # >>

	if [[ -f "keys_cleanup.sh" ]]; then
		echo ">> Cleaning keys...";
		./keys_cleanup.sh;
		echo "RESULT: $? (fail ok/expected)";
		echo ">> Cleaning keys... DONE";
	fi

	cd ../; # <<
fi

function cleanupFile() {
	if [[ "$#" -ne 2 ]]; then
		echo "> cleanupFile() > Illegal number of parameters!";
		exit 1;
	fi
	local SRC_FILE_PATH=$1;
	local DEST_FILE_PATH=$2;
	local FILE_NAME=$(basename ${SRC_FILE_PATH});
	if [[ $FILE_NAME == *.MT.sh ]]; then
		REAL_DEST_FILE_PATH=${DEST_FILE_PATH%.MT.sh};
		if [[ -f "$REAL_DEST_FILE_PATH" ]]; then
			git ls-files --error-unmatch ${REAL_DEST_FILE_PATH} &> /dev/null;
			RESULT=$?;
			if [[ ${RESULT} -ne 0 ]]; then # file is NOT tracked by git
				echo -n "> Cleaning-up '$REAL_DEST_FILE_PATH'...";
				rm ${REAL_DEST_FILE_PATH};
				RESULT=$?;
				if [[ ${RESULT} -ne 0 ]]; then
					echo " ERROR !";
					exit ${RESULT};
				fi
				echo " DONE ✓";
			else
				echo "> Cleaning-up '$REAL_DEST_FILE_PATH'... SKIP ✓ (tracked file could be generated)";
			fi
		else
			echo "> Cleaning-up '$REAL_DEST_FILE_PATH'... SKIP ✓ (missing)";
		fi
		return; # no need to validate generated file content
	fi
	if [[ $FILE_NAME == ".gitignore" || $FILE_NAME == "MT.gitignore" ]]; then
		return; # keep .gitignore files, even if modified
	fi
	if [[ -f "$DEST_FILE_PATH" ]]; then
		diff -q ${SRC_FILE_PATH} ${DEST_FILE_PATH};
		local RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then # FILE CHANGED
			echo "> Deployed shared file '$DEST_FILE_PATH' was changed from '$SRC_FILE_PATH'!";
			ls -l $DEST_FILE_PATH;
			ls -l $SRC_FILE_PATH;
			diff --color ${SRC_FILE_PATH} ${DEST_FILE_PATH};
			exit ${RESULT};
		fi
		echo -n "> Cleaning-up '$DEST_FILE_PATH'...";
		rm ${DEST_FILE_PATH};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo " ERROR !";
			exit ${RESULT};
		fi
		echo " DONE ✓";
	else
		echo "> Cleaning-up '$DEST_FILE_PATH/'... SKIP ✓ (missing)";
	fi
}

function cleanupDirectory() {
	if [[ "$#" -ne 2 ]]; then
		echo "> cleanupDirectory() > Illegal number of parameters!";
		exit 1;
	fi
	local SRC_FILE_PATH=$1;
	local DEST_FILE_PATH=$2;
	local FILE_NAME=$(basename ${SRC_FILE_PATH});
	if [[ -d "$DEST_FILE_PATH" ]]; then
		local S_FILE_NAME;
		for S_FILE_NAME in $(ls -a ${SRC_FILE_PATH}/) ; do
			local S_SRC_FILE_PATH=${SRC_FILE_PATH}/$S_FILE_NAME;
			if [[ $S_FILE_NAME == "." ]] || [[ $S_FILE_NAME == ".." ]]; then
				continue;
			fi
			local S_FILE_NAME_DEST=${S_FILE_NAME#"MT"}; # MT+filename used to ignore ".gitignore"
			if [[ "$S_FILE_NAME_DEST" == *MTSTAR ]]; then
				S_FILE_NAME_DEST_STARTS_WITH=${S_FILE_NAME_DEST%MTSTAR};
				S_FILE_NAME_DEST_LIST=$(find ${DEST_FILE_PATH}/ -mindepth 1 -maxdepth 1 -name "$S_FILE_NAME_DEST_STARTS_WITH*" -exec basename {} \; | xargs);
			else # just use file name
				S_FILE_NAME_DEST_LIST="$S_FILE_NAME_DEST";
			fi
			for S_FILE_NAME_DEST in $S_FILE_NAME_DEST_LIST ; do
				local S_DEST_FILE_PATH="$DEST_FILE_PATH/$S_FILE_NAME_DEST";
				if [[ -f "$S_SRC_FILE_PATH" ]]; then
					cleanupFile ${S_SRC_FILE_PATH} ${S_DEST_FILE_PATH};
					checkResult $?;
				elif [[ -d "$S_SRC_FILE_PATH" ]]; then
					cleanupDirectory ${S_SRC_FILE_PATH} ${S_DEST_FILE_PATH};
					checkResult $?;
				else #WTF
					echo "--------------------------------------------------------------------------------";
					echo "> File to cleanup '$S_FILENAME' ($S_SRC_FILE_PATH) is neither a directory or a file!";
					ls -l ${S_FILENAME};
					exit 1;
				fi
			done
		done
		if ! [[ "$(ls -A ${DEST_FILE_PATH})" ]]; then
			echo -n "> Cleaning-up '$DEST_FILE_PATH/' (empty)...";
			rm -r ${DEST_FILE_PATH};
			local RESULT=$?;
			if [[ ${RESULT} -ne 0 ]]; then
				echo " ERROR !";
				exit ${RESULT};
			fi
			echo " DONE ✓";
		fi
	else
		echo "> Cleaning-up '$DEST_FILE_PATH/'... SKIP ✓ (missing)";
	fi
}

DEST_PATH=".";

SRC_DIR_PATH="commons/shared";
for FILENAME in $(ls -a $SRC_DIR_PATH/) ; do
	SRC_FILE_PATH=$SRC_DIR_PATH/$FILENAME;
	if [[ $FILENAME == "." ]] || [[ $FILENAME == ".." ]]; then
		continue;
	fi
	FILENAME_DEST=${FILENAME#"MT"}; # MT+filename used to ignore ".gitignore"
	DEST_FILE_PATH="$DEST_PATH/$FILENAME_DEST"
	if [[ -f ${SRC_FILE_PATH} ]]; then
		cleanupFile ${SRC_FILE_PATH} ${DEST_FILE_PATH};
		checkResult $?;
	elif [[ -d "$SRC_FILE_PATH" ]]; then
		cleanupDirectory ${SRC_FILE_PATH} ${DEST_FILE_PATH};
		checkResult $?;
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
	FILENAME_DEST=${FILENAME#"MT"}; # MT+filename used to ignore ".gitignore"
	DEST_FILE_PATH="$DEST_PATH/$FILENAME_DEST"
	if [[ -f ${SRC_FILE_PATH} ]]; then
		cleanupFile ${SRC_FILE_PATH} ${DEST_FILE_PATH};
		checkResult $?;
	elif [[ -d "$SRC_FILE_PATH" ]]; then
		cleanupDirectory ${SRC_FILE_PATH} ${DEST_FILE_PATH};
		checkResult $?;
	else #WTF
		echo "> File to cleanup '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
		ls -l ${FILENAME};
		exit 1;
	fi
done

if [[ $PROJECT_NAME == "mtransit-for-android" ]]; then
  SRC_DIR_PATH="commons/shared-main";
  for FILENAME in $(ls -a $SRC_DIR_PATH/) ; do
    SRC_FILE_PATH=$SRC_DIR_PATH/$FILENAME;
    if [[ $FILENAME == "." ]] || [[ $FILENAME == ".." ]]; then
      continue;
    fi
    FILENAME_DEST=${FILENAME#"MT"}; # MT+filename used to ignore ".gitignore"
    DEST_FILE_PATH="$DEST_PATH/$FILENAME_DEST"
    if [[ -f ${SRC_FILE_PATH} ]]; then
      cleanupFile ${SRC_FILE_PATH} ${DEST_FILE_PATH};
      checkResult $?;
    elif [[ -d "$SRC_FILE_PATH" ]]; then
      cleanupDirectory ${SRC_FILE_PATH} ${DEST_FILE_PATH};
      checkResult $?;
    else #WTF
      echo "> File to cleanup '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
      ls -l ${FILENAME};
      exit 1;
    fi
  done
else # modules
  SRC_DIR_PATH="commons/shared-modules";
  for FILENAME in $(ls -a $SRC_DIR_PATH/) ; do
    SRC_FILE_PATH=$SRC_DIR_PATH/$FILENAME;
    if [[ $FILENAME == "." ]] || [[ $FILENAME == ".." ]]; then
      continue;
    fi
    FILENAME_DEST=${FILENAME#"MT"}; # MT+filename used to ignore ".gitignore"
    DEST_FILE_PATH="$DEST_PATH/$FILENAME_DEST"
    if [[ -f ${SRC_FILE_PATH} ]]; then
      cleanupFile ${SRC_FILE_PATH} ${DEST_FILE_PATH};
      checkResult $?;
    elif [[ -d "$SRC_FILE_PATH" ]]; then
      cleanupDirectory ${SRC_FILE_PATH} ${DEST_FILE_PATH};
      checkResult $?;
    else #WTF
      echo "> File to cleanup '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
      ls -l ${FILENAME};
      exit 1;
    fi
  done
fi

echo "--------------------------------------------------------------------------------";
AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> CLEANUP SHARED... DONE";
echo "================================================================================";
