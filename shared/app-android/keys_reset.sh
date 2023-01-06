#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh
echo ">> Resetting keys...";

source ${SCRIPT_DIR}/keys_files.sh;

if [[ ${#FILES[@]} -lt 1 ]]; then
	echo "FILES environment variable is NOT defined (need at least 1 empty \"\")!";
	exit 1;
fi

CLEAR="${SCRIPT_DIR}/clr"

for FILE in "${FILES[@]}" ; do
	FILE_PATH="${SCRIPT_DIR}/${FILE}";
	if [[ -z "${FILE_PATH}" ]]; then
		echo "Ignoring empty '$FILE_PATH'.";
		continue;
	fi
	echo "--------------------------------------------------------------------------------";
	echo "> Resetting '$FILE_PATH'...";

	FILE_ENC="${SCRIPT_DIR}/enc/${FILE}";

	if [[ -f ${FILE_ENC} ]]; then
		rm ${FILE_ENC};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo "Error while deleting old encrypted file '$FILE_ENC'!";
			exit ${RESULT};
		fi
	fi

	./${SCRIPT_DIR}/encrypt_file.sh ${FILE_PATH} ${FILE_ENC};
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo "Error while encrypting file '${FILE_PATH}' to '$FILE_ENC'!";
		exit ${RESULT};
	fi

	echo "> Resetting '$FILE'... DONE";
	echo "--------------------------------------------------------------------------------";
done

echo ">> Resetting keys... DONE";

