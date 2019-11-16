#!/bin/bash
source ../commons/commons.sh
echo ">> Encrypting file $@...";

if [[ -z "${MT_ENCRYPT_KEY}" ]]; then
	echo "MT_ENCRYPT_KEY environment variable is NOT defined!";
	exit 1;
fi

if [[ $# -ne 2 ]]; then
	echo "Expecting 2 arguments for the file (arg:$@)!";
	exit 1;
fi


if [[ -z "$1" ]]; then
	echo "Empty file name '$1'!";
	exit 1;
fi

if ! [[ -f $1 ]]; then
	echo "'$1' is NOT a valid file!";
	exit 1;
fi

if [[ -f $2 ]]; then
	echo ">> Cannot override existing '$2' file!";
	exit 1;
fi

openssl aes-256-cbc -md sha256 -salt -in $1 -out $2 -k $MT_ENCRYPT_KEY
RESULT=$?;
if [[ ${RESULT} -ne 0 ]]; then
	echo ">> Error while encrypting '$1' to '$2'!";
	exit ${RESULT};
fi

echo ">> Encrypting file $@... DONE";
