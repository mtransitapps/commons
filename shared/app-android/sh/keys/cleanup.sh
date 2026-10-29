#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../../..";

source ${ROOT_DIR}/commons/sh/commons.sh

echo ">> Cleaning keys...";

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

source ${SCRIPT_DIR}/files.sh;

if [[ ${#FILES[@]} -lt 1 ]]; then
	echo "ERROR! FILES environment variable is NOT defined (need at least 1 empty \"\")!";
	exit 1;
fi

APP_ANDROID_DIR="${ROOT_DIR}/app-android";

CLEAR="${APP_ANDROID_DIR}/clr"

SHARED_UNTRACKED_CLEAR_DIR="${ROOT_DIR}/commons/shared/app-android"

for FILE in "${FILES[@]}" ; do
	if [[ -z "${FILE}" ]]; then
		echoFile "> Ignoring empty '${FILE}'.";
		continue;
	fi

	FILE_PATH="${APP_ANDROID_DIR}/${FILE}";
	echoFile -n "> Cleaning '${FILE_PATH}'...";

	git ls-files --error-unmatch ${FILE_PATH} &> /dev/null;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then # file is NOT tracked by git
		if [[ -f $CLEAR/${FILE} ]]; then
			mv $CLEAR/${FILE} ${FILE_PATH};
			RESULT=$?;
			if [[ ${RESULT} -ne 0 ]]; then
				echo " ERROR! Resetting decrypted file '${FILE_PATH}' using 'mv $CLEAR/${FILE} ${FILE_PATH}' did NOT work!";
				if [[ $IS_CI == true ]]; then
					rm ${FILE_PATH}; # deleting file
				fi
				exit ${RESULT};
			fi
		elif [[ -f $SHARED_UNTRACKED_CLEAR_DIR/${FILE} ]]; then
			cp $SHARED_UNTRACKED_CLEAR_DIR/${FILE} ${FILE_PATH};
			RESULT=$?;
			if [[ ${RESULT} -ne 0 ]]; then
				echo " ERROR! Resetting decrypted file '${FILE_PATH}' using 'cp $SHARED_UNTRACKED_CLEAR_DIR/${FILE} ${FILE_PATH}' did NOT work!";
				if [[ $IS_CI == true ]]; then
					rm ${FILE_PATH}; # deleting file
				fi
				exit ${RESULT};
			fi
		else
			echo " ERROR! No clear file found for untracked decrypted file '${FILE_PATH}'!";
			if [[ $IS_CI == true ]]; then
				rm ${FILE_PATH}; # deleting file
			fi
			exit 1;
		fi
	else # file is tracked by git
		git update-index --no-skip-worktree -- "${FILE_PATH}";
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo " ERROR! while setting '--no-skip-worktree' for '${FILE_PATH}'!";
			exit ${RESULT};
		fi
		git checkout -- ${FILE_PATH};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo " ERROR! Resetting decrypted file '${FILE_PATH}' using 'git checkout' did NOT work!";
			if [[ $IS_CI == true ]]; then
				rm ${FILE_PATH}; # deleting file
			fi
			exit ${RESULT};
		fi
		git diff --name-status --exit-code ${FILE_PATH};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo " ERROR! File '${FILE_PATH}' NOT the same as git file!";
			exit ${RESULT};
		fi
	fi

	echoFile " DONE ✓";
done

if [[ -d $CLEAR ]]; then
	echoFile -n "> Deleting '$CLEAR' directory...";
	rm -r $CLEAR;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo " ERROR! while deleting '$CLEAR' directory!";
		ls -al $CLEAR;
		exit ${RESULT};
	else
		echoFile " DONE ✓";
	fi
fi

echo -e "\n>> Cleaning keys... DONE";

