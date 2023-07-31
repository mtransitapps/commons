#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh

if [[ "$3" != "quiet" ]]; then
	echo -n ">> Decrypting-ing file '$@'...";
fi

if [[ -z "${MT_ENCRYPT_KEY}" ]]; then
	echo " ERROR! MT_ENCRYPT_KEY environment variable is NOT defined!";
	exit 1;
fi

if [[ $# -lt 2 ]]; then
	echo " ERROR! Expecting 2-3 arguments for the file (arg:$@)!";
	exit 1;
fi

if [[ -z "$1" ]]; then
	echo " ERROR! Empty source file name '$1'!";
	exit 1;
fi

if [[ -z "$2" ]]; then
	echo " ERROR! Empty target file name '$2'!";
	exit 1;
fi

if ! [[ -f $1 ]]; then
	echo " ERROR! '$1' is NOT a valid file!";
	exit 1;
fi

if [[ -f $2 ]]; then
	echo -n " (overriding existing '$2' file)";
fi

# openssl aes-256-cbc -md sha256 -d -in $1 -out $2 -k ${MT_ENCRYPT_KEY};
openssl aes-256-cbc -pbkdf2 -iter 7007 -md sha256 -d -in $1 -out $2 -k ${MT_ENCRYPT_KEY};
RESULT=$?;
if [[ ${RESULT} -ne 0 ]]; then
	echo " ERROR! while decrypting '$1' to '$2'!";
	exit ${RESULT};
fi

if [[ "$3" != "quiet" ]]; then
	echo " DONE ✓";
fi
