#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR=$(cd "${SCRIPT_DIR}/../../.." && pwd);

source "${ROOT_DIR}/commons/sh/commons.sh"

echo ">> Setup-ing keys...";

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
	echo " ERROR! FILES environment variable is NOT defined (need at least 1 empty \"\")!";
	exit 1;
fi

if [[ -z "${MT_ENCRYPT_KEY}" ]]; then
	echo " ERROR! MT_ENCRYPT_KEY environment variable is NOT defined!";
	exit 1;
fi

APP_ANDROID_DIR="${ROOT_DIR}/app-android";

CLEAR="${APP_ANDROID_DIR}/clr"

SHARED_UNTRACKED_CLEAR_DIR="${ROOT_DIR}/commons/shared/app-android"
SHARED_UNTRACKED_ENC_DIR="${ROOT_DIR}/commons/shared/app-android/enc"

# 1 - check current files state

for FILE in "${FILES[@]}" ; do
	if [[ -z "${FILE}" ]]; then
		echoFile "Ignoring empty file path '$FILE' in '$APP_ANDROID_DIR'.";
		continue;
	fi

	FILE_PATH="${APP_ANDROID_DIR}/${FILE}";
	if [[ ! -f ${FILE_PATH} ]]; then
		git ls-files --error-unmatch ${FILE_PATH} &> /dev/null;
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then # file is NOT tracked by git
			if [[ -f $SHARED_UNTRACKED_CLEAR_DIR/${FILE} ]]; then
				mkdir -p "$(dirname "$FILE_PATH")";
				cp $SHARED_UNTRACKED_CLEAR_DIR/${FILE} ${FILE_PATH};
				RESULT=$?;
				if [[ ${RESULT} -ne 0 ]]; then
					echo " ERROR! while copying shared untracked clear file '$SHARED_UNTRACKED_CLEAR_DIR/${FILE}' to '${FILE_PATH}'!";
					exit ${RESULT};
				fi
			else
				echoFile "Ignoring missing non tracked file path '$FILE_PATH'.";
				continue;
			fi
		else # file is tracked by git
			echo " ERROR! File path '$FILE_PATH' does NOT exist!";
			exit 1;
		fi
	else
		# make sure file is not already decrypted
		git ls-files --error-unmatch ${FILE_PATH} &> /dev/null;
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then # file is NOT tracked by git
			if [[ -f $CLEAR/${FILE} ]]; then
				diff -q ${FILE_PATH} $CLEAR/${FILE} &> /dev/null;
				RESULT=$?;
				if [[ ${RESULT} -ne 0 ]]; then
					echo " ERROR! File '$FILE_PATH' has local changes compared to clear version!";
					echo " -> should run 'keys/cleanup.sh' or commit changes.";
					exit 1; # local changes?
				fi
			elif [[ -f $SHARED_UNTRACKED_CLEAR_DIR/${FILE} ]]; then
				diff -q ${FILE_PATH} $SHARED_UNTRACKED_CLEAR_DIR/${FILE} &> /dev/null;
				RESULT=$?;
				if [[ ${RESULT} -ne 0 ]]; then
					echo " ERROR! File '$FILE_PATH' has local changes compared to shared clear version!";
					echo " -> should run 'keys/cleanup.sh' or commit changes.";
					exit 1; # local changes?
				fi
			fi
		else
			git diff --name-status --exit-code ${FILE_PATH} &> /dev/null;
			RESULT=$?;
			if [[ ${RESULT} -ne 0 ]]; then
				echo " ERROR! Decrypted file '$FILE_PATH' has local changes compared to git version!";
				exit 1; # local changes?
			fi
		fi
	fi

	FILE_ENC_PATH="${APP_ANDROID_DIR}/enc/${FILE}";
	if [[ ! -f ${FILE_ENC_PATH} ]]; then
		git ls-files --error-unmatch ${FILE_ENC_PATH} &> /dev/null;
		RESULT=$?;
		if [[ ${RESULT} -ne 0 && -f $SHARED_UNTRACKED_ENC_DIR/${FILE} ]]; then
			cp $SHARED_UNTRACKED_ENC_DIR/${FILE} ${FILE_ENC_PATH};
			RESULT=$?;
			if [[ ${RESULT} -ne 0 ]]; then
				echo " ERROR! while copying shared untracked encrypted file '$SHARED_UNTRACKED_ENC_DIR/${FILE}' to '${FILE_ENC_PATH}'!";
				exit ${RESULT};
			fi
		else
			echo " ERROR! Encrypted file '$FILE_ENC_PATH' does NOT exist!";
			exit 1;
		fi
	fi
done

# 2 - decrypt files

for FILE in "${FILES[@]}" ; do
	if [[ -z "${FILE}" ]]; then
		echoFile "Ignoring empty file path '$FILE' in '$APP_ANDROID_DIR'.";
		continue;
	fi

	FILE_PATH="${APP_ANDROID_DIR}/${FILE}";
	echoFile -n "> Decrypting '$FILE_PATH'...";

	# CREATE clear copy of untracked file before decrypting
	git ls-files --error-unmatch ${FILE_PATH} &> /dev/null;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then # file is NOT tracked by git
		CLEAR_DIR=$(dirname "$CLEAR/${FILE}");
		mkdir -p "$CLEAR_DIR";
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo " ERROR! while creating clear directory '$CLEAR_DIR'!";
			exit ${RESULT};
		fi
		if [[ ! -f ${FILE_PATH} ]]; then
			if [[ -f "$SHARED_UNTRACKED_CLEAR_DIR/${FILE}" ]]; then
				cp "$SHARED_UNTRACKED_CLEAR_DIR/${FILE}" "$CLEAR/${FILE}";
				RESULT=$?;
				if [[ ${RESULT} -ne 0 ]]; then
					echo " ERROR! while copying shared untracked clear file '$SHARED_UNTRACKED_CLEAR_DIR/${FILE}' to '$CLEAR/${FILE}'!";
					exit ${RESULT};
				fi
			else
				echoFile "File path '$FILE_PATH' does NOT exist, SKIPPING clear file.";
			fi
		else
			cp "${FILE_PATH}" "$CLEAR/${FILE}";
			RESULT=$?;
			if [[ ${RESULT} -ne 0 ]]; then
				echo " ERROR! while copying '${FILE_PATH}' to '$CLEAR/${FILE}'!";
				exit ${RESULT};
			fi
		fi
	else # file is tracked by git
		: # DO NOTHING (no need for clear file copy, can use git to revert)
	fi

	# DECRYPT the encrypted file to the original file path
	FILE_ENC="${APP_ANDROID_DIR}/enc/${FILE}";

	"${SCRIPT_DIR}/decrypt_file.sh" "${FILE_ENC}" "${FILE_PATH}" "quiet";
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo " ERROR! while decrypting '$FILE_ENC'!";
		exit ${RESULT};
	fi

	# VERIFY that the decrypted file is different from the clear file for untracked files, or different from the git version for tracked files
	git ls-files --error-unmatch "${FILE_PATH}" &> /dev/null;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then #file is NOT tracked by git
		diff -q "${FILE_PATH}" "$CLEAR/${FILE}" &> /dev/null;
		RESULT=$?;
		if [[ ${RESULT} -eq 0 ]]; then
			echo " ERROR! Decrypted file '$FILE_PATH' NOT different than clear file!";
			exit 1;
		fi
		# rm ${FILE}.clear;
	else # file is tracked by git
		git diff --name-status --exit-code "${FILE_PATH}" &> /dev/null;
		RESULT=$?;
		if [[ ${RESULT} -eq 0 ]]; then
			echo " ERROR! Decrypted file '$FILE_PATH' NOT different than git version!";
			ls -al "${FILE_PATH}"; #DEBUG
			ls -al "${FILE_ENC}"; #DEBUG
			exit 1;
		fi
		git update-index --skip-worktree -- "${FILE_PATH}";
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo " ERROR! while setting 'skip-worktree' for '${FILE_PATH}'!";
			exit ${RESULT};
		fi
	fi

	echoFile " DONE ✓";
done

echo -e "\n>> Setup-ing keys... DONE";

