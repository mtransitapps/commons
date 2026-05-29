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

VERSION_FILE="$SCRIPT_DIR/pom.xml";
if [ ! -f "$VERSION_FILE" ]; then
    echo "> GTFS Validator version file '$VERSION_FILE' not found!";
    exit 1;
fi
GTFS_VALIDATOR_VERSION=$(grep -E '<gtfs.validator.version>[^<]+</gtfs.validator.version>' "$VERSION_FILE" | sed -E 's/.*<gtfs.validator.version>([^<]+)<\/gtfs.validator.version>.*/\1/' | head -n1);
if [ -z "$GTFS_VALIDATOR_VERSION" ]; then
    echo "> GTFS Validator version not found in '$VERSION_FILE'!";
    exit 1;
fi
JAR_FILE="$SCRIPT_DIR/gtfs-validator-$GTFS_VALIDATOR_VERSION-cli.jar";
JAR_URL="https://github.com/MobilityData/gtfs-validator/releases/download/v$GTFS_VALIDATOR_VERSION/gtfs-validator-$GTFS_VALIDATOR_VERSION-cli.jar";
if [ ! -f "$JAR_FILE" ]; then
    echo "> Downloading GTFS Validator '$GTFS_VALIDATOR_VERSION'...";
    curl --fail --location --output "$JAR_FILE" "$JAR_URL";
    DOWNLOAD_RESULT=$?;
    if [[ ${DOWNLOAD_RESULT} -ne 0 ]]; then
        echo "> Error while downloading GTFS Validator '$GTFS_VALIDATOR_VERSION'!";
        exit ${DOWNLOAD_RESULT};
    fi
    echo "> Downloading GTFS Validator '$GTFS_VALIDATOR_VERSION'... DONE";
fi
echo "> GTFS Validator version: '$GTFS_VALIDATOR_VERSION'.";
echo "> GTFS Validator JAR file: '$JAR_FILE'.";

echo "> Launching GTFS Validator...";
# https://github.com/MobilityData/gtfs-validator#using-the-command-line
# https://github.com/MobilityData/gtfs-validator/releases/latest/
# --url $(cat $FILE_PATH/input_url) --storage_directory "$GTFS_ZIP_FILE"
# --country_code ca
java \
  -jar "$JAR_FILE" \
  --input "$GTFS_ZIP_FILE" \
  --output_base "$OUTPUT" \
  --pretty \
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

echo "> Report summary:";
echo "> - Warnings:";
echo "> ----------";
grep -B 1 -A 1 -i "\"severity\": \"WARNING\"," $OUTPUT/report.json;
echo "> ----------";
echo "> - Errors:";
echo "> ----------";
grep -B 1 -A 1 -i "\"severity\": \"ERROR\"," $OUTPUT/report.json;
echo "> ----------";
echo "> Looking for errors...";
ERROR_COUNT=$(grep -i "\"severity\": \"ERROR\"," $OUTPUT/report.json | wc -l);
if [[ "$ERROR_COUNT" -gt 0 ]]; then
  echo "> Found $ERROR_COUNT error!";
else
  echo "> Found no error.";
fi
echo "> Looking for errors... DONE";
exit $ERROR_COUNT;