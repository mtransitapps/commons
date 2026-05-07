#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh
echo ">> Encrypting file '$@'...";

if [[ -z "${MT_ENCRYPT_KEY}" ]]; then
	echo "MT_ENCRYPT_KEY environment variable is NOT defined!";
	exit 1;
fi

if [[ $# -ne 1 ]]; then
	echo "Expecting 1 or 2 arguments for the file (arg:'$@')!";
	exit 1;
fi

SOURCE_FILE=$1;

if [[ -z "$SOURCE_FILE" ]]; then
	echo "Empty file name '$SOURCE_FILE'!";
	exit 1;
fi

if ! [[ -f $SOURCE_FILE ]]; then
	echo "'$SOURCE_FILE' is NOT a valid file!";
	exit 1;
fi

TARGET_FILE=$2;

if [[ -z "$TARGET_FILE" ]]; then
	# target file should be in the SCRIPT_DIR/enc/ path of the SOURCE FILE in SCRIPT_DIR
	SOURCE_FILE_PATH_RELATED_TO_SCRIPT_DIR=$(realpath --relative-to="$SCRIPT_DIR" "$SOURCE_FILE");
	TARGET_FILE="$SCRIPT_DIR/enc/$SOURCE_FILE_PATH_RELATED_TO_SCRIPT_DIR";
fi

if [[ -f $TARGET_FILE ]]; then
	echo ">> Cannot override existing '$TARGET_FILE' file!";
	exit 1;
fi

TARGET_DIRECTORY=$(dirname $TARGET_FILE);
mkdir -p $TARGET_DIRECTORY;

echo ">> Encrypting file '$SOURCE_FILE' to '$TARGET_FILE'...";

# openssl aes-256-cbc -md sha256 -salt -in $SOURCE_FILE -out $TARGET_FILE -k ${MT_ENCRYPT_KEY};
openssl aes-256-cbc -pbkdf2 -iter 7007 -md sha256 -salt -in $SOURCE_FILE -out $TARGET_FILE -k ${MT_ENCRYPT_KEY};
RESULT=$?;
if [[ ${RESULT} -ne 0 ]]; then
	echo ">> Error while encrypting '$SOURCE_FILE' to '$TARGET_FILE'!";
	exit ${RESULT};
fi

echo ">> Encrypting file '$SOURCE_FILE' to '$TARGET_FILE'... DONE";
