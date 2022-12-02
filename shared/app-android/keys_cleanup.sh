#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh
echo ">> Cleaning keys...";

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
	echo "> Cleaning '$FILE_PATH'...";

	git ls-files --error-unmatch ${FILE_PATH} &> /dev/null;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then #file is NOT tracked by git
		if ! [[ -d $CLEAR ]]; then
			echo "Missing '$CLEAR' directory!";
			exit 1;
		fi
		mv $CLEAR/${FILE} ${FILE_PATH};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo "Resetting decrypted file '$FILE_PATH' using 'mv $CLEAR/${FILE} ${FILE_PATH}' did NOT work!";
			rm ${FILE_PATH}; # deleting file
			exit ${RESULT};
		fi
	else #file is tracked by git
		git checkout -- ${FILE_PATH};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo "Resetting decrypted file '$FILE_PATH' using 'git checkout' did NOT work!";
			rm ${FILE}; # deleting file
			exit ${RESULT};
		fi
		git diff --name-status --exit-code ${FILE_PATH};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo "File '$FILE_PATH' NOT the same as clear file!";
			exit ${RESULT};
		fi
	fi

	echo "> Cleaning '$FILE'... DONE";
	echo "--------------------------------------------------------------------------------";
done

if [[ -d $CLEAR ]]; then
	rm -r $CLEAR;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo "Error while deleting '$CLEAR' directory!";
		ls -al $CLEAR;
		exit ${RESULT};
	else
		echo "Directory '$CLEAR' deleted.";
	fi
fi

echo ">> Cleaning keys... DONE";

