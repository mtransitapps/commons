#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh
echo ">> Decrypting-ing file $@...";

if [[ -z "${MT_ENCRYPT_KEY}" ]]; then
	echo "MT_ENCRYPT_KEY environment variable is NOT defined!";
	exit 1;
fi

if [[ $# -ne 2 ]]; then
	echo "Expecting 2 argument for the file (arg:$@)!";
	exit 1;
fi

if [[ -z "$1" ]]; then
	echo "Empty file name '$1'!";
	exit 1;
fi

if [[ -z "$2" ]]; then
	echo "Empty file name '$2'!";
	exit 1;
fi

if ! [[ -f $1 ]]; then
	echo "'$1' is NOT a valid file!";
	exit 1;
fi

if [[ -f $2 ]]; then
	echo ">> Overriding existing '$2' file.";
fi

openssl aes-256-cbc -md sha256 -d -in $1 -out $2 -k ${MT_ENCRYPT_KEY};
RESULT=$?;
if [[ ${RESULT} -ne 0 ]]; then
	echo ">> Error while decrypting '$1' to '$2'!";
	exit ${RESULT};
fi

echo ">> Decrypting-ing file $@... DONE";
