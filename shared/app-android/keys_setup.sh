#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh
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

source ${SCRIPT_DIR}/keys_files.sh;

if [[ ${#FILES[@]} -lt 1 ]]; then
	echo " ERROR! FILES environment variable is NOT defined (need at least 1 empty \"\")!";
	exit 1;
fi

if [[ -z "${MT_ENCRYPT_KEY}" ]]; then
	echo " ERROR! MT_ENCRYPT_KEY environment variable is NOT defined!";
	exit 1;
fi

for FILE in "${FILES[@]}" ; do
	FILE_PATH="${SCRIPT_DIR}/${FILE}";
	if [[ -z "${FILE_PATH}" ]]; then
		echoFile "Ignoring empty '$FILE_PATH'.";
		continue;
	fi

	if [[ ! -f ${FILE_PATH} ]]; then
		echo " ERROR! File '$FILE_PATH' does NOT exist!";
		exit 1;
	fi

	FILE_ENC_PATH="${SCRIPT_DIR}/enc/${FILE}";

	if [[ ! -f ${FILE_ENC_PATH} ]]; then
		echo " ERROR! File '$FILE_ENC_PATH' does NOT exist!";
		exit 1;
	fi
done

CLEAR="${SCRIPT_DIR}/clr"

for FILE in "${FILES[@]}" ; do
	FILE_PATH="${SCRIPT_DIR}/${FILE}";
	if [[ -z "${FILE_PATH}" ]]; then
		echoFile "Ignoring empty '$FILE_PATH'.";
		continue;
	fi
	echoFile -n "> Decrypting '$FILE_PATH'...";

	git ls-files --error-unmatch ${FILE_PATH} &> /dev/null;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then # file is NOT tracked by git
		if ! [[ -d $CLEAR ]]; then
			mkdir $CLEAR;
			RESULT=$?;
			if [[ ${RESULT} -ne 0 ]]; then
				echo " ERROR! while creating '$CLEAR' directory!";
				exit ${RESULT};
			else
				echoFile -n " (directory '$CLEAR' created)";
			fi
		fi
		CLEAR_DIR=$(dirname "$CLEAR/${FILE}");
		mkdir -p $CLEAR_DIR;
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo " ERROR! while creating clear directory '$CLEAR_DIR'!";
			exit ${RESULT};
		fi
		cp ${FILE_PATH} $CLEAR/${FILE};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo " ERROR! while copying '${FILE_PATH}' to '$CLEAR/${FILE}'!";
			exit ${RESULT};
		fi
	fi

	FILE_ENC="${SCRIPT_DIR}/enc/${FILE}";

	./${SCRIPT_DIR}/decrypt_file.sh ${FILE_ENC} ${FILE_PATH} "quiet";
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo " ERROR! while decrypting '$FILE_ENC'!";
		exit ${RESULT};
	fi

	git ls-files --error-unmatch ${FILE_PATH} &> /dev/null;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then #file is NOT tracked by git
		diff -q ${FILE_PATH} $CLEAR/${FILE} &> /dev/null;
		RESULT=$?;
		if [[ ${RESULT} -eq 0 ]]; then
			echo " ERROR! Decrypted file '$FILE_PATH' NOT different than clear file!";
			exit 1;
		fi
		# rm ${FILE}.clear;
	else # file is tracked by git
		git diff --name-status --exit-code ${FILE_PATH} &> /dev/null;
		RESULT=$?;
		if [[ ${RESULT} -eq 0 ]]; then
			echo " ERROR! Decrypted file '$FILE_PATH' NOT different than clear file!";
			ls -al ${FILE_PATH}; #DEBUG
			ls -al ${FILE_ENC}; #DEBUG
			exit 1;
		fi
	fi

	echoFile " DONE ✓";
done

echo -e "\n>> Setup-ing keys... DONE";

