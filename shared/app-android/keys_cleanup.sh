#!/bin/bash
source ../commons/commons.sh
echo ">> Cleaning keys...";

source keys_files.sh;

if [[ ${#FILES[@]} -lt 1 ]]; then
	echo "FILES environment variable is NOT defined (need at least 1 empty \"\")!";
	exit 1;
fi

CLEAR="clr"

for FILE in "${FILES[@]}" ; do
	if [[ -z "${FILE}" ]]; then
		echo "Ignoring empty '$FILE'.";
		continue;
	fi
	echo "--------------------------------------------------------------------------------";
	echo "> Cleaning '$FILE'...";

	git ls-files --error-unmatch ${FILE} &> /dev/null;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then #file is NOT tracked by git
		if ! [[ -d $CLEAR ]]; then
			echo "Missing '$CLEAR' directory!";
			exit 1;
		fi
		mv $CLEAR/${FILE} ${FILE};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo "Resetting decrypted file '$FILE' using 'mv $CLEAR/${FILE} ${FILE}' did NOT work!";
			rm ${FILE}; # deleting file
			exit ${RESULT};
		fi
	else #file is tracked by git
		git checkout -- ${FILE};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo "Resetting decrypted file '$FILE' using 'git checkout' did NOT work!";
			rm ${FILE}; # deleting file
			exit ${RESULT};
		fi
		git diff --name-status --exit-code ${FILE};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo "File '$FILE' NOT the same as clear file!";
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

