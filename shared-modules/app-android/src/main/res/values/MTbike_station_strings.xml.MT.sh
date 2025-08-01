#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";

ROOT_DIR="$SCRIPT_DIR/../../../../../../..";
COMMONS_DIR="${ROOT_DIR}/commons";
source ${COMMONS_DIR}/commons.sh;

setGitProjectName;

setIsCI;

BIKE_STATION_FILE="${ROOT_DIR}/app-android/src/main/res/values/bike_station_values.xml";
if [ ! -f "${BIKE_STATION_FILE}" ]; then
    echo ">> Generating bike_station_strings.xml... SKIP (not an Bike station agency)";
    exit 0; # ok
fi

echo ">> Generating bike_station_strings.xml...";

APP_ANDROID_DIR="${ROOT_DIR}/app-android";
SRC_DIR="${APP_ANDROID_DIR}/src";
MAIN_DIR="${SRC_DIR}/main";
RES_DIR="${MAIN_DIR}/res";
VALUES_DIR="${RES_DIR}/values";
BIKE_STATION_STRINGS_FILE="${VALUES_DIR}/bike_station_strings.xml";
mkdir -p "${VALUES_DIR}";
checkResult $?;
if [ -f "${BIKE_STATION_STRINGS_FILE}" ]; then
  echo ">> File '$BIKE_STATION_STRINGS_FILE' already exist."; # compat with existing bike_station_strings.xml
  exit 0; # compat w/ manually created file
fi

rm -f "${BIKE_STATION_STRINGS_FILE}";
checkResult $?;
touch "${BIKE_STATION_STRINGS_FILE}";
checkResult $?;

CONFIG_DIR="${ROOT_DIR}/config";
if [ ! -d "$CONFIG_DIR" ]; then
    echo "$CONFIG_DIR doesn't exist!";
    exit 1;
fi

AGENCY_NAME_FILE="${CONFIG_DIR}/agency_name";
if [ ! -f "$AGENCY_NAME_FILE" ]; then
    echo "$AGENCY_NAME_FILE doesn't exist!";
    exit 1;
fi

AGENCY_NAME_LONG=$(tail -n 1 $AGENCY_NAME_FILE);
if [ -z "$AGENCY_NAME_LONG" ]; then
    echo "$AGENCY_NAME_LONG is empty!";
    exit 1;
fi

AGENCY_NAME_SHORT=$(head -n 1 $AGENCY_NAME_FILE);
if [ -z "$AGENCY_NAME_SHORT" ]; then
    echo "$AGENCY_NAME_SHORT is empty!";
    exit 1;
fi

BIKE_STATION_VALUES_FILE="${VALUES_DIR}/bike_station_values.xml"
TYPE=-1;
if [ -f $BIKE_STATION_VALUES_FILE ]; then
  TYPE=$(grep -E "<integer name=\"bike_station_agency_type\">[0-9]+</integer>$" $BIKE_STATION_VALUES_FILE | tr -dc '0-9')
else
  echo " > No agency file! (bike:$BIKE_STATION_VALUES_FILE)"
  exit 1 # error
fi
TYPE_LABEL="";
if [ "$TYPE" -eq 100 ]; then # BIKE
    TYPE_LABEL="bikes";
else
  echo "Unexpected agency type '$TYPE'!"
  exit 1 # error
fi

cat >>"${BIKE_STATION_STRINGS_FILE}" <<EOL
<?xml version="1.0" encoding="utf-8"?>
<!-- DO NOT EDIT: this file is generated by MTbike_station_strings.xml.MT.sh -->
<resources xmlns:tools="http://schemas.android.com/tools" tools:locale="en">
    <string name="bike_station_label">$AGENCY_NAME_LONG $TYPE_LABEL</string>
    <string name="bike_station_short_name">$AGENCY_NAME_SHORT</string>
</resources>
EOL

if [[ ${IS_CI} = true ]]; then
  echo "---------------------------------------------------------------------------------------------------------------";
  cat "${BIKE_STATION_STRINGS_FILE}"; #DEBUG
  echo "---------------------------------------------------------------------------------------------------------------";
fi

echo ">> Generating bike_station_strings.xml... DONE";