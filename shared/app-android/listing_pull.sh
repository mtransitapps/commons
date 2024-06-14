#!/bin/bash
source ../commons/commons.sh
echo ">> Pulling listing from Google Play Console...";

# LINKS:
# https://github.com/Triple-T/gradle-play-publisher#quickstart
# gradlew help --task bootstrapListing

CURRENT_DIRECTORY_PATH="$(realpath "$PWD")";
SCRIPT_DIRECTORY_PATH="$(realpath $(dirname "$0"))";

if [[ "${CURRENT_DIRECTORY_PATH}" != "${SCRIPT_DIRECTORY_PATH}" ]]; then
	echo ">> Script needs to be executed from '$SCRIPT_DIRECTORY_PATH' instead of '${CURRENT_DIRECTORY_PATH}'!";
	exit 1;
fi

echo ">> Setup-ing keys...";
./keys_setup.sh;
checkResult $?;
echo ">> Setup-ing keys... DONE";

setGradleArgs;

../gradlew bootstrapListing ${GRADLE_ARGS};
COMMAND_RESULT=$?; # save command result but cleanup keys 1st

echo ">> Cleaning keys...";
./keys_cleanup.sh;
checkResult $?;
echo ">> Cleaning keys... DONE";

checkResult $COMMAND_RESULT; # check command result after keys cleanup

RELEASE_NOTES_DIR="src/main/play/release-notes";

OLD_IFS="$IFS"; # work w/ file name with spaces
IFS=$'\n'; # work w/ file name with spaces
for DIR in `find ${RELEASE_NOTES_DIR} -maxdepth 1 -type d ! -path ${RELEASE_NOTES_DIR}` ; do
  echo ">> Directory: '$DIR'.";
	for FILE_NAME in `find ${DIR} -maxdepth 1 -type f -name "*.txt"` ; do
    # DEFAULT
		if [[ "${FILE_NAME}" == "${DIR}/default.txt" ]]; then
		  echo ">> - Default release note found.";
    # PRODUCTION
		elif [[ "${FILE_NAME}" == "${DIR}/production.txt" ]]; then
      if [[ ! -f "${DIR}/default.txt" ]]; then
        cp "${DIR}/production.txt" "${DIR}/default.txt";
        checkResult $?;
        echo ">> - Production release note used for default.";
      fi
      rm "${FILE_NAME}";
      checkResult $?;
      echo ">> - File '${FILE_NAME}' deleted.";
    # BETA (Private)
		elif [[ "${FILE_NAME}" == "${DIR}/Beta\ \(Private\).txt" ]]; then
      if [[ ! -f "${DIR}/default.txt" ]]; then
        cp "${DIR}/Beta\ \(Private\).txt" "${DIR}/default.txt";
        checkResult $?;
        echo ">> - Beta (Private) release note used for default.";
      fi
      rm "${FILE_NAME}";
      checkResult $?;
      echo ">> - File '${FILE_NAME}' deleted.";
    # ALPHA
    elif [[ "${FILE_NAME}" == "${DIR}/alpha.txt" ]]; then
      if [[ ! -f "${DIR}/default.txt" ]]; then
        cp "${DIR}/alpha.txt" "${DIR}/default.txt";
        checkResult $?;
        echo ">> - Alpha release note used for default.";
      fi
      rm "${FILE_NAME}";
      checkResult $?;
      echo ">> - File '${FILE_NAME}' deleted.";
    # OTHER
    else
      rm "${FILE_NAME}";
      checkResult $?;
      echo ">> - File '${FILE_NAME}' deleted.";
		fi
	done
	if [[ ! -f "${DIR}/default.txt" ]]; then
    echo ">> - No default release note in '$DIR'!";
    exit 1;
  fi
done
IFS="$OLD_IFS"; # work w/ file name with spaces

echo ">> Pulling listing from Google Play Console... DONE";
