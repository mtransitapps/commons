#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../../..";

source ${ROOT_DIR}/commons/sh/commons.sh

echo ">> Resetting keys...";

source ${SCRIPT_DIR}/files.sh;

if [[ ${#FILES[@]} -lt 1 ]]; then
	echo "FILES environment variable is NOT defined (need at least 1 empty \"\")!";
	exit 1;
fi

APP_ANDROID_DIR="${ROOT_DIR}/app-android";

CLEAR="${APP_ANDROID_DIR}/clr"

for FILE in "${FILES[@]}" ; do
	FILE_PATH="${APP_ANDROID_DIR}/${FILE}";
	if [[ -z "${FILE_PATH}" ]]; then
		echo "Ignoring empty '$FILE_PATH'.";
		continue;
	fi
	echo "--------------------------------------------------------------------------------";
	echo "> Resetting '$FILE_PATH'...";

	FILE_ENC="${APP_ANDROID_DIR}/enc/${FILE}";

	if [[ -f ${FILE_ENC} ]]; then
		rm ${FILE_ENC};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo "Error while deleting old encrypted file '$FILE_ENC'!";
			exit ${RESULT};
		fi
	fi

	${SCRIPT_DIR}/encrypt_file.sh ${FILE_PATH} ${FILE_ENC};
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo "Error while encrypting file '${FILE_PATH}' to '$FILE_ENC'!";
		exit ${RESULT};
	fi

	echo "> Resetting '$FILE'... DONE";
	echo "--------------------------------------------------------------------------------";
done

echo ">> Resetting keys... DONE";

