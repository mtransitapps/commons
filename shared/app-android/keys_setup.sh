#!/bin/bash
source ../commons/commons.sh
echo ">> Setup-ing keys...";

source keys_files.sh;

if [[ ${#FILES[@]} -lt 1 ]]; then
	echo "FILES environment variable is NOT defined (need at least 1 empty \"\")!";
	exit 1;
fi

if [[ -z "${MT_ENCRYPT_KEY}" ]]; then
	echo "MT_ENCRYPT_KEY environment variable is NOT defined!";
	exit 1;
fi

for FILE in "${FILES[@]}" ; do
	if [[ -z "${FILE}" ]]; then
		echo "Ignoring empty '$FILE'.";
		continue;
	fi

	if [[ ! -f ${FILE} ]]; then
		echo "File '$FILE' does NOT exist!";
		exit 1;
	fi

	FILE_ENC="enc/${FILE}";

	if [[ ! -f ${FILE_ENC} ]]; then
		echo "File '$FILE_ENC' does NOT exist!";
		exit 1;
	fi
done

CLEAR="clr"

for FILE in "${FILES[@]}" ; do
	if [[ -z "${FILE}" ]]; then
		echo "Ignoring empty '$FILE'.";
		continue;
	fi
	echo "--------------------------------------------------------------------------------";
	echo "> Decrypting '$FILE'...";

	git ls-files --error-unmatch ${FILE} &> /dev/null;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then #file is NOT tracked by git
		if ! [[ -d $CLEAR ]]; then
			mkdir $CLEAR;
			RESULT=$?;
			if [[ ${RESULT} -ne 0 ]]; then
				echo "Error while creating '$CLEAR' directory!";
				exit ${RESULT};
			else
				echo "Directory '$CLEAR' created.";
			fi
		fi
		CLEAR_DIR=$(dirname "$CLEAR/${FILE}");
		mkdir -p $CLEAR_DIR;
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo "Error while creating clear directory '$CLEAR_DIR'!";
			exit ${RESULT};
		fi
		cp ${FILE} $CLEAR/${FILE};
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo "Error while copying '${FILE}' to '$CLEAR/${FILE}'!";
			exit ${RESULT};
		fi
	fi

	FILE_ENC="enc/${FILE}";

	./decrypt_file.sh ${FILE_ENC} ${FILE};
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo "Error while decrypting '$FILE_ENC'!";
		exit ${RESULT};
	fi

	git ls-files --error-unmatch ${FILE} &> /dev/null;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then #file is NOT tracked by git
		diff -q ${FILE} $CLEAR/${FILE} &> /dev/null;
		RESULT=$?;
		if [[ ${RESULT} -eq 0 ]]; then
			echo "Decrypted file '$FILE' NOT different than clear file!";
			exit ${RESULT};
		fi
		# rm ${FILE}.clear;
	else  #file is tracked by git
		git diff --name-status --exit-code ${FILE} &> /dev/null;
		RESULT=$?;
		if [[ ${RESULT} -eq 0 ]]; then
			echo "Decrypted file '$FILE' NOT different than clear file!";
			ls -al ${FILE}; #DEBUG
			ls -al ${FILE_ENC}; #DEBUG
			exit ${RESULT};
		fi
	fi

	echo "> Decrypting '$FILE'... DONE";
	echo "--------------------------------------------------------------------------------";
done

echo ">> Setup-ing keys... DONE";

