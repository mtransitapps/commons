#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../../.."; ROOT_DIR=$(realpath --relative-to="$ROOT_DIR" "$ROOT_DIR");

source "${ROOT_DIR}/commons/sh/commons.sh"

echo ">> Encrypting file '$@'...";

if [[ -z "${MT_ENCRYPT_KEY}" ]]; then
	echo "MT_ENCRYPT_KEY environment variable is NOT defined!";
	exit 1;
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
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

APP_ANDROID_DIR="${ROOT_DIR}/app-android";

if [[ -z "$TARGET_FILE" ]]; then
	# target file should be in the APP_ANDROID_DIR/enc/ path of the SOURCE FILE in APP_ANDROID_DIR
	SOURCE_FILE_PATH_RELATED_TO_APP_ANDROID_DIR=$(realpath --relative-to="$APP_ANDROID_DIR" "$SOURCE_FILE");
	TARGET_FILE="$APP_ANDROID_DIR/enc/$SOURCE_FILE_PATH_RELATED_TO_APP_ANDROID_DIR";
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
