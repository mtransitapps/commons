#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";

ROOT_DIR="$SCRIPT_DIR/../../../../../../../../../..";
COMMONS_DIR="${ROOT_DIR}/commons";
source ${COMMONS_DIR}/commons.sh;

setIsCI;

setGitProjectName;

echo ">> Generating feature-graphic/1.txt...";

APP_ANDROID_DIR="${ROOT_DIR}/app-android";
SRC_DIR="${APP_ANDROID_DIR}/src";
MAIN_DIR="${SRC_DIR}/main";
PLAY_DIR="${MAIN_DIR}/play";
LISTINGS_DIR="${PLAY_DIR}/listings";
EN_US_DIR="${LISTINGS_DIR}/en-US";
GRAPHICS_DIR="${EN_US_DIR}/graphics";
FEATURE_GRAPHIC_DIR="${GRAPHICS_DIR}/feature-graphic";
FILE_1_PNG="${FEATURE_GRAPHIC_DIR}/1.png";
mkdir -p "${FEATURE_GRAPHIC_DIR}";
checkResult $?;
if [ -f "${FILE_1_PNG}" ]; then
  echo ">> File '$FILE_1_PNG' already exist."; # compat with existing feature-graphic/1.txt
  exit 0;
fi

rm -f "${FILE_1_PNG}";
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

AGENCY_NAME_COUNT=$(grep -c ^ $AGENCY_NAME_FILE);
if [ $AGENCY_NAME_COUNT -eq 0 ]; then
    echo "$AGENCY_NAME_FILE is empty!";
    exit 1;
fi

AGENCY_NAME_SHORT=$(head -n 1 $AGENCY_NAME_FILE);
if [ -z "$AGENCY_NAME_SHORT" ]; then
    echo "$AGENCY_NAME_SHORT is empty!";
    exit 1;
fi

MAX_AGENCY_LENGTH=17 # from module-featured-graphic.sh

AGENCY_NAME_1="";
AGENCY_NAME_2="";

if [ "${#AGENCY_NAME_SHORT}" -le "$MAX_AGENCY_LENGTH" ]; then
    AGENCY_NAME_1=$AGENCY_NAME_SHORT;
else
  echo "Agency shortest name '$AGENCY_NAME_SHORT' is too long (${#AGENCY_NAME_SHORT} > $MAX_AGENCY_LENGTH)!";
  exit 1; # error
fi

CITIES_FILE="${CONFIG_DIR}/cities";
if [ ! -f "$CITIES_FILE" ]; then
    echo "$CITIES_FILE doesn't exist!";
    exit 1;
fi
CITIES_LABEL=$(head -n 1 $CITIES_FILE);
if [ -z "$CITIES_LABEL" ]; then
    echo "$CITIES_LABEL is empty!";
    exit 1;
fi

STATE_LABEL_SHORT=""; # optional
STATE_FILE="${CONFIG_DIR}/state";
if [ -f "$STATE_FILE" ]; then
    STATE_LABEL_SHORT=$(head -n 1 $STATE_FILE);
fi

COUNTRY_CODE=$(echo "$PROJECT_NAME" | cut -d- -f1);
if [ "$COUNTRY_CODE" = "ca" ]; then
    COUNTRY_LABEL="Canada";
elif [ "$COUNTRY_CODE" = "us" ]; then
    COUNTRY_LABEL="United States";
elif [ "$COUNTRY_CODE" = "fr" ]; then
    COUNTRY_LABEL="France";
else
  echo "Unexpected country code '$COUNTRY_CODE'!"
  exit 1 # error
fi

STATE_AND_COUNTRY_LABEL=$COUNTRY_LABEL;
if [ ! -z "$STATE_LABEL_SHORT" ]; then
    STATE_AND_COUNTRY_LABEL="$STATE_LABEL_SHORT, $COUNTRY_LABEL";
fi

MAX_CITY_LENGTH=77 # from module-featured-graphic.sh
CITIES_LABEL=$(echo $CITIES_LABEL | awk -v len=$MAX_CITY_LENGTH '{ if (length($0) > len) print substr($0, 1, len-1) "…"; else print; }');

if [[ -z "${AGENCY_NAME_2}" ]]; then
  $ROOT_DIR/commons-android/pub/module-featured-graphic.sh "$AGENCY_NAME_1" "$CITIES_LABEL" "$STATE_AND_COUNTRY_LABEL";
  checkResult $?;
else 
  $ROOT_DIR/commons-android/pub/module-featured-graphic.sh "$AGENCY_NAME_1" "$AGENCY_NAME_2" "$CITIES_LABEL" "$STATE_AND_COUNTRY_LABEL";
  checkResult $?;
fi

echo ">> Generating feature-graphic/1.txt... DONE";