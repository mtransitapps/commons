#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR=$(cd "${SCRIPT_DIR}/../.." && pwd)

source "${ROOT_DIR}/commons/sh/commons.sh";

echo "================================================================================";
echo "> SHARED SETUP...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

setGitProjectName;

setIsCI;

DEBUG_FILES=$IS_CI;
# DEBUG_FILES=true;
function echoFile() {
	if [[ $DEBUG_FILES == true ]]; then
		echo "$@";
	else
		echo -n ".";
	fi
}

function canOverwriteFile() {
	if [[ "$#" -ne 2 ]]; then
		echo "> canOverwriteFile() > Illegal number of parameters!";
		exit 1;
	fi
	local SRC_FILE_PATH=$1;
	local DEST_FILE_PATH=$2;
	local FILE_NAME=$(basename ${SRC_FILE_PATH});
	if [[ -f "$DEST_FILE_PATH" ]]; then
		diff -q ${SRC_FILE_PATH} ${DEST_FILE_PATH};
		local RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then # FILE CHANGED
			if [[ $FILE_NAME == ".gitignore" || $FILE_NAME == "MT.gitignore" ]]; then
				echo "> Changed '$FILE_NAME' removed ('$SRC_FILE_PATH'=>'$DEST_FILE_PATH')!";
				rm ${DEST_FILE_PATH};
				checkResult $?;
			else
				echo "> File '$DEST_FILE_PATH' exists & was changed from '$SRC_FILE_PATH'!";
				ls -l $DEST_FILE_PATH;
				ls -l $SRC_FILE_PATH;
				diff ${SRC_FILE_PATH} ${DEST_FILE_PATH};
				exit ${RESULT};
			fi
		fi
	fi
}

function deleteFile() {
	if [[ "$#" -ne 1 ]]; then
		echo "> deleteFile() > Illegal number of parameters!";
		exit 1;
	fi
	local DEST_FILE_PATH=$1;
	if [[ -f "${DEST_FILE_PATH}" ]]; then
		rm "${DEST_FILE_PATH}";
		checkResult $?;
		echoFile "> Deleting '${DEST_FILE_PATH}'... DONE ✓";
	else
		echoFile "> Deleting '${DEST_FILE_PATH}'... SKIP (not found)";
	fi
}

function deployFile() {
	if [[ "$#" -lt 2 ]]; then
		echo "> deployFile() > Illegal number of parameters!";
		exit 1;
	fi
	local SRC_FILE_PATH=$1;
	local DEST_FILE_PATH=$2;
	local OVER_WRITE=false; # do not over-write by default
	if [[ "$#" -ge 3 ]]; then
		OVER_WRITE=$3;
	fi
	# echo "--------------------------------------------------------------------------------";
	if [[ $SRC_FILE_PATH == *.MT.sh ]]; then
		local DEST_DIR=$(dirname ${DEST_FILE_PATH});
		echoFile "> Deploying '$SRC_FILE_PATH' in '$DEST_DIR'...";
		"$SRC_FILE_PATH" "$DEST_DIR";
		local RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo "> Error while deploying file '$SRC_FILE_PATH' in '$DEST_DIR'!";
			exit ${RESULT};
		fi
		echoFile "> Deploying '$SRC_FILE_PATH' in '$DEST_DIR'... DONE ✓";
		return;
	fi
	if [[ "$OVER_WRITE" == true ]]; then
		if [[ -f "${DEST_FILE_PATH}" ]]; then
			rm ${DEST_FILE_PATH};
			checkResult $?;
		fi
	else
		canOverwriteFile ${SRC_FILE_PATH} ${DEST_FILE_PATH};
		checkResult $?;
	fi
	DEST_DIR=$(dirname ${DEST_FILE_PATH});
	mkdir -p ${DEST_DIR};
	checkResult $?;
	echoFile "> Deploying '$SRC_FILE_PATH'...";
	cp --update=none -p "$SRC_FILE_PATH" "$DEST_FILE_PATH" || cp --no-clobber -p "$SRC_FILE_PATH" "$DEST_FILE_PATH"; # Ubuntu 22.04 & 24.04 compat
	local RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo "> Error while deploying file '$SRC_FILE_PATH'!";
		exit ${RESULT};
	fi
	echoFile "> Deploying '$SRC_FILE_PATH'... DONE ✓";
	# echo "--------------------------------------------------------------------------------";
}

function canOverwriteDirectory() {
	if [[ "$#" -ne 2 ]]; then
		echo "> canOverwriteDirectory() > Illegal number of parameters!";
		exit 1;
	fi
	local SRC_FILE_PATH=$1;
	local DEST_FILE_PATH=$2;
	local DIR_NAME=$(basename ${SRC_FILE_PATH});
	if [[ -d "$DEST_FILE_PATH" ]]; then
		diff -q -r ${SRC_FILE_PATH} ${DEST_FILE_PATH};
		local RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then # DIR CHANGED
			echo "> Directory '$DEST_FILE_PATH' exists & was changed from '$SRC_FILE_PATH'!";
			ls -l $DEST_FILE_PATH;
			ls -l $SRC_FILE_PATH;
			diff -r ${SRC_FILE_PATH} ${DEST_FILE_PATH};
			exit ${RESULT};
		fi
	fi
}

function deployDirectory() {
	if [[ "$#" -lt 2 ]]; then
		echo "> deployDirectory() > Illegal number of parameters!";
		exit 1;
	fi
	local SRC_FILE_PATH=$1;
	local DEST_FILE_PATH=$2;
	local OVER_WRITE=false; # do not over-write by default
	if [[ "$#" -ge 3 ]]; then
		OVER_WRITE=$3;
	fi
	local OPT_DIR=false; # do create directory by default
	if [[ "$#" -ge 4 ]]; then
		OPT_DIR=$4;
	fi
	# echo "--------------------------------------------------------------------------------";
	echoFile "> Deploying '${SRC_FILE_PATH}/'...";
	if [[ "$SRC_FILE_PATH" == *MTSTAR ]]; then
		echoFile "> Skip fake directory '$DEST_FILE_PATH' in target directory.";
	elif ! [[ -d "$DEST_FILE_PATH" ]]; then
		if [[ "$OPT_DIR" == true ]]; then
			echoFile "> Skip optional directory '$DEST_FILE_PATH' in target directory.";
			return;
		fi
	fi
	local S_FILE_NAME;
	for S_FILE_NAME in $(ls -a ${SRC_FILE_PATH}/) ; do
		local S_SRC_FILE_PATH=${SRC_FILE_PATH}/$S_FILE_NAME;
		if [[ $S_FILE_NAME == "." ]] || [[ $S_FILE_NAME == ".." ]]; then
			continue;
		fi
		local S_FILE_NAME_DEST=${S_FILE_NAME#"MT"}; # MT+filename used to ignore ".gitignore"
		local S_DEST_FILE_PATH="$DEST_FILE_PATH/$S_FILE_NAME_DEST";
		if [[ $S_FILE_NAME == MT.DELETE.* ]]; then
			deleteFile "$DEST_FILE_PATH/${S_FILE_NAME#"MT.DELETE."}";
			checkResult $?;
		elif [[ -f $S_SRC_FILE_PATH ]]; then
			deployFile ${S_SRC_FILE_PATH} ${S_DEST_FILE_PATH} ${OVER_WRITE};
			checkResult $?;
		elif [[ -d "$S_SRC_FILE_PATH" ]]; then
			deployDirectory ${S_SRC_FILE_PATH} ${S_DEST_FILE_PATH} ${OVER_WRITE}; # ${OPT_DIR} only for 1st level
			checkResult $?;
		else #WTF
			# echo "--------------------------------------------------------------------------------";
			echo "> File to deploy '$S_FILE_NAME' ($S_SRC_FILE_PATH) is neither a directory or a file!";
			ls -l ${S_FILE_NAME};
			exit 1;
		fi
	done
	echoFile "> Deploying '${SRC_FILE_PATH}/'... DONE ✓";
	# echo "--------------------------------------------------------------------------------";
}

echo "> Deploying shared files...";
SRC_DIR_PATH="$ROOT_DIR/commons/shared";
for FILENAME in $(ls -a $SRC_DIR_PATH/) ; do
	SRC_FILE_PATH=$SRC_DIR_PATH/$FILENAME;
	if [[ $FILENAME == "." ]] || [[ $FILENAME == ".." ]]; then
		continue;
	fi
	FILENAME_DEST=${FILENAME#"MT"}; # MT+filename used to ignore ".gitignore"
	DEST_FILE_PATH="$ROOT_DIR/$FILENAME_DEST";
	if [[ -f $SRC_FILE_PATH ]]; then
		deployFile ${SRC_FILE_PATH} ${DEST_FILE_PATH};
		checkResult $?;
	elif [[ -d "$SRC_FILE_PATH" ]]; then
		deployDirectory ${SRC_FILE_PATH} ${DEST_FILE_PATH};
		checkResult $?;
	else #WTF
		echo "> File to deploy '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
		ls -l "$SRC_FILE_PATH";
		exit 1;
	fi
done
echo -e "\n> Deploying shared files... DONE ✓";

echo "--------------------------------------------------------------------------------";

echo "> Deploying optional shared files...";
SRC_DIR_PATH="$ROOT_DIR/commons/shared-opt-dir";
for FILENAME in $(ls -a $SRC_DIR_PATH/) ; do
	SRC_FILE_PATH=$SRC_DIR_PATH/$FILENAME;
	if [[ $FILENAME == "." ]] || [[ $FILENAME == ".." ]]; then
		continue;
	fi
	FILENAME_DEST=${FILENAME#"MT"}; # MT+filename used to ignore ".gitignore"
	DEST_FILE_PATH="$ROOT_DIR/$FILENAME_DEST"
	if [[ -f $SRC_FILE_PATH ]]; then
		deployFile ${SRC_FILE_PATH} ${DEST_FILE_PATH};
		checkResult $?;
	elif [[ -d "$SRC_FILE_PATH" ]]; then
		deployDirectory ${SRC_FILE_PATH} ${DEST_FILE_PATH} false true; #do-not-over-write #opt-dir
		checkResult $?;
	else #WTF
		echo "> File to deploy '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
		ls -l "$SRC_FILE_PATH";
		exit 1;
	fi
done
echo -e "\n> Deploying optional shared files... DONE ✓";

echo "--------------------------------------------------------------------------------";

if [[ $PROJECT_NAME == "mtransit-for-android" ]]; then
  echo "> Deploying main shared files...";
  SRC_DIR_PATH="$ROOT_DIR/commons/shared-main";
  for FILENAME in $(ls -a $SRC_DIR_PATH/) ; do
    SRC_FILE_PATH=$SRC_DIR_PATH/$FILENAME;
    if [[ $FILENAME == "." ]] || [[ $FILENAME == ".." ]]; then
      continue;
    fi
    FILENAME_DEST=${FILENAME#"MT"}; # MT+filename used to ignore ".gitignore"
    DEST_FILE_PATH="$ROOT_DIR/$FILENAME_DEST"
    if [[ -f $SRC_FILE_PATH ]]; then
      deployFile ${SRC_FILE_PATH} ${DEST_FILE_PATH};
      checkResult $?;
    elif [[ -d "$SRC_FILE_PATH" ]]; then
      deployDirectory ${SRC_FILE_PATH} ${DEST_FILE_PATH};
      checkResult $?;
    else #WTF
      echo "> File to deploy '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
      ls -l "$SRC_FILE_PATH";
      exit 1;
    fi
  done
  echo -e "\n> Deploying main shared files... DONE ✓";
else
  echo "> Deploying modules shared files...";
  SRC_DIR_PATH="$ROOT_DIR/commons/shared-modules";
  for FILENAME in $(ls -a $SRC_DIR_PATH/) ; do
    SRC_FILE_PATH=$SRC_DIR_PATH/$FILENAME;
    if [[ $FILENAME == "." ]] || [[ $FILENAME == ".." ]]; then
      continue;
    fi
    FILENAME_DEST=${FILENAME#"MT"}; # MT+filename used to ignore ".gitignore"
    DEST_FILE_PATH="$ROOT_DIR/$FILENAME_DEST"
    if [[ -f $SRC_FILE_PATH ]]; then
      deployFile ${SRC_FILE_PATH} ${DEST_FILE_PATH};
      checkResult $?;
    elif [[ -d "$SRC_FILE_PATH" ]]; then
      deployDirectory ${SRC_FILE_PATH} ${DEST_FILE_PATH};
      checkResult $?;
    else #WTF
      echo "> File to deploy '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
      ls -l "$SRC_FILE_PATH";
      exit 1;
    fi
  done
  echo -e "\n> Deploying modules shared files... DONE ✓";
fi

echo "--------------------------------------------------------------------------------";

echo "> Deploying overwritten shared files...";
SRC_DIR_PATH="$ROOT_DIR/commons/shared-overwrite";
for FILENAME in $(ls -a $SRC_DIR_PATH/) ; do
	SRC_FILE_PATH=$SRC_DIR_PATH/$FILENAME;
	if [[ $FILENAME == "." ]] || [[ $FILENAME == ".." ]]; then
		continue;
	fi
	FILENAME_DEST=${FILENAME#"MT"}; # MT+filename used to ignore ".gitignore"
	DEST_FILE_PATH="$ROOT_DIR/$FILENAME_DEST"
	if [[ $FILENAME == MT.DELETE.* ]]; then
		deleteFile "$ROOT_DIR/${FILENAME#"MT.DELETE."}";
		checkResult $?;
	elif [[ -f $SRC_FILE_PATH ]]; then
		deployFile ${SRC_FILE_PATH} ${DEST_FILE_PATH} true; #over-write
		checkResult $?;
	elif [[ -d "$SRC_FILE_PATH" ]]; then
		deployDirectory ${SRC_FILE_PATH} ${DEST_FILE_PATH} true; #DO over-write
		checkResult $?;
	else #WTF
		echo "> File to deploy '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
		ls -l "$SRC_FILE_PATH";
		exit 1;
	fi
done
echo -e "\n> Deploying overwritten shared files... DONE ✓";

echo "--------------------------------------------------------------------------------";

echo "> Deploying overwritten all repositories shared files...";
SRC_DIR_PATH="$ROOT_DIR/commons/shared-overwrite-all-repositories";
for FILENAME in $(ls -a $SRC_DIR_PATH/) ; do
	SRC_FILE_PATH=$SRC_DIR_PATH/$FILENAME;
	if [[ $FILENAME == "." ]] || [[ $FILENAME == ".." ]]; then
		continue;
	fi
	FILENAME_DEST=${FILENAME#"MT"}; # MT+filename used to ignore ".gitignore"
	DEST_FILE_PATH="$ROOT_DIR/$FILENAME_DEST"
	if [[ $FILENAME == MT.DELETE.* ]]; then
		deleteFile "$ROOT_DIR/${FILENAME#"MT.DELETE."}";
		checkResult $?;
	elif [[ -f $SRC_FILE_PATH ]]; then
		deployFile ${SRC_FILE_PATH} ${DEST_FILE_PATH} true; #over-write
		checkResult $?;
	elif [[ -d "$SRC_FILE_PATH" ]]; then
		deployDirectory ${SRC_FILE_PATH} ${DEST_FILE_PATH} true; #DO over-write
		checkResult $?;
	else #WTF
		echo "> File to deploy '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
		ls -l "$SRC_FILE_PATH";
		exit 1;
	fi
done

# SHARED SUBMODULES
declare -a SUBMODULES=(
	"commons"
	"commons-java"
	"commons-android"
);
if [[ $PROJECT_NAME == "mtransit-for-android" ]]; then
	echo "> Main android app: '$PROJECT_NAME' > parser required ✓";
	SUBMODULES+=('parser');
elif [[ $PROJECT_NAME == *"-bike"* ]]; then
	echo "> Bike android app: '$PROJECT_NAME' > parser NOT required ✓";
else
	echo "> Bus/Train/... android app: '$PROJECT_NAME' > parser required ✓";
	SUBMODULES+=('parser');
fi

for SUBMODULE in "${SUBMODULES[@]}"; do
  echo "> Deploying overwritten all repositories shared files to '$SUBMODULE'...";
  for FILENAME in $(ls -a $SRC_DIR_PATH/) ; do
	SRC_FILE_PATH=$SRC_DIR_PATH/$FILENAME;
	if [[ $FILENAME == "." ]] || [[ $FILENAME == ".." ]]; then
		continue;
	fi
	FILENAME_DEST=${FILENAME#"MT"}; # MT+filename used to ignore ".gitignore"
	DEST_FILE_PATH="$ROOT_DIR/$SUBMODULE/$FILENAME_DEST"
	if [[ $FILENAME == MT.DELETE.* ]]; then
		deleteFile "$ROOT_DIR/$SUBMODULE/${FILENAME#"MT.DELETE."}";
		checkResult $?;
	elif [[ -f $SRC_FILE_PATH ]]; then
		deployFile ${SRC_FILE_PATH} ${DEST_FILE_PATH} true; #over-write
		checkResult $?;
	elif [[ -d "$SRC_FILE_PATH" ]]; then
		deployDirectory ${SRC_FILE_PATH} ${DEST_FILE_PATH} true; #DO over-write
		checkResult $?;
	else #WTF
		echo "> File to deploy '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
		ls -l "$SRC_FILE_PATH";
		exit 1;
	fi
  done
done
echo -e "\n> Deploying overwritten all repositories shared files... DONE ✓";

echo "--------------------------------------------------------------------------------";
AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> SHARED SETUP... DONE ✓";
echo "================================================================================";
