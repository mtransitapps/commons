#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh
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

source ${SCRIPT_DIR}/keys_files.sh;

if [[ ${#FILES[@]} -lt 1 ]]; then
	echo "ERROR! FILES environment variable is NOT defined (need at least 1 empty \"\")!";
	exit 1;
fi

CLEAR="${SCRIPT_DIR}/clr"

for FILE in "${FILES[@]}" ; do
	FILE_PATH="${SCRIPT_DIR}/${FILE}";
	if [[ -z "${FILE_PATH}" ]]; then
		echoFile "> Ignoring empty '$FILE_PATH'.";
		continue;
	fi
	echoFile -n "> Cleaning '$FILE_PATH'...";

	git ls-files --error-unmatch ${FILE_PATH} &> /dev/null;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then # file is NOT tracked by git
		if ! [[ -d $CLEAR ]]; then
			echo " ERROR! Missing '$CLEAR' directory!";
			exit 1;
		fi
		mv $CLEAR/${FILE} ${FILE_PATH};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo " ERROR! Resetting decrypted file '$FILE_PATH' using 'mv $CLEAR/${FILE} ${FILE_PATH}' did NOT work!";
			rm ${FILE_PATH}; # deleting file
			exit ${RESULT};
		fi
	else # file is tracked by git
		git checkout -- ${FILE_PATH};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo " ERROR! Resetting decrypted file '$FILE_PATH' using 'git checkout' did NOT work!";
			rm ${FILE}; # deleting file
			exit ${RESULT};
		fi
		git diff --name-status --exit-code ${FILE_PATH};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo " ERROR! File '$FILE_PATH' NOT the same as clear file!";
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

