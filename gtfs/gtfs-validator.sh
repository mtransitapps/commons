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
GTFS_VALIDATOR_VERSION=$(sed -n 's/.*<gtfs.validator.version>\([^<]*\)<\/gtfs.validator.version>.*/\1/p' "$VERSION_FILE" | head -n 1 | tr -d '[:space:]');
if [ -z "$GTFS_VALIDATOR_VERSION" ]; then
    echo "> GTFS Validator version not found in '$VERSION_FILE'!";
    exit 1;
fi
JAR_FILE="$SCRIPT_DIR/gtfs-validator-$GTFS_VALIDATOR_VERSION-cli.jar";
if [ ! -s "$JAR_FILE" ]; then
    rm -f "$JAR_FILE";
    if ! command -v gh >/dev/null 2>&1; then
        echo "> GitHub CLI (gh) is required to download GTFS Validator '$GTFS_VALIDATOR_VERSION' (https://cli.github.com/)!";
        exit 1;
    fi
    echo "> Downloading GTFS Validator '$GTFS_VALIDATOR_VERSION'...";
    gh release download "v$GTFS_VALIDATOR_VERSION" \
      --repo MobilityData/gtfs-validator \
      --pattern "gtfs-validator-$GTFS_VALIDATOR_VERSION-cli.jar" \
      --dir "$SCRIPT_DIR";
    DOWNLOAD_RESULT=$?;
    if [[ ${DOWNLOAD_RESULT} -ne 0 ]]; then
        echo "> Error while downloading GTFS Validator '$GTFS_VALIDATOR_VERSION'!";
        exit ${DOWNLOAD_RESULT};
    fi
    if [ ! -s "$JAR_FILE" ]; then
        echo "> Downloaded GTFS Validator JAR '$JAR_FILE' is missing or empty!";
        exit 1;
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