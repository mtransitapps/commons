#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});

echo "> Current directory: '$CURRENT_DIRECTORY'";

echo "> Args: '$@'.";

if [[ $# -ne 2 ]]; then
	echo "> Expecting 2 arguments for the file (arg:$@)!";
	exit 1;
fi

GTFS_ZIP_FILE=$1;
echo "> GTFS file: $GTFS_ZIP_FILE.".

OUTPUT=$2;
echo "> Output: $OUTPUT.".

if [ ! -f  "$GTFS_ZIP_FILE" ]; then
    echo "> GTFS file '$GTFS_ZIP_FILE' not fount!";
    exit 1;
fi

# echo "> GTFS Validator latest release...";
# gh release list --limit 1 --repo github.com/MobilityData/gtfs-validator;
# echo "> GTFS Validator latest release... DONE";

JAR_FILE_PATTERN="$SCRIPT_DIR/gtfs-validator-*.jar";
JAR_FILES=($JAR_FILE_PATTERN);
JAR_FILE="${JAR_FILES[0]}";
echo "> GTFS Validator JAR file: '$JAR_FILE'.";

echo "> Launching GTFS Validator...";
# https://github.com/MobilityData/gtfs-validator#run-the-app-via-command-line
# https://github.com/MobilityData/gtfs-validator/releases/latest/
# https://github.com/MobilityData/gtfs-validator/releases/latest/download/gtfs-validator-4.0.0-cli.jar
java \
  -jar "$JAR_FILE" \
  -i "$GTFS_ZIP_FILE" \
  -o "$OUTPUT" \
;
RESULT=$?;
if [[ ${RESULT} -ne 0 ]]; then
    echo "Error while validating '$GTFS_ZIP_FILE'!";
    exit ${RESULT};
fi
echo "> Launching GTFS Validator... DONE";

echo "> Reports available:";
echo "> - file://$CURRENT_PATH/$OUTPUT/report.html";
echo "> - file://$CURRENT_PATH/$OUTPUT/report.json";
echo "> - file://$CURRENT_PATH/$OUTPUT/system_errors.json";