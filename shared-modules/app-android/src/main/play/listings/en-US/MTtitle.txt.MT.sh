#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";

ROOT_DIR="$SCRIPT_DIR/../../../../../../../..";
COMMONS_DIR="${ROOT_DIR}/commons";
source ${COMMONS_DIR}/commons.sh;

setIsCI;

echo ">> Generating title.txt...";

APP_ANDROID_DIR="${ROOT_DIR}/app-android";
SRC_DIR="${APP_ANDROID_DIR}/src";
MAIN_DIR="${SRC_DIR}/main";
PLAY_DIR="${MAIN_DIR}/play";
LISTINGS_DIR="${PLAY_DIR}/listings";
EN_US_DIR="${LISTINGS_DIR}/en-US";
TITLE_FILE="${EN_US_DIR}/title.txt";
mkdir -p "${EN_US_DIR}";
checkResult $?;
if [ -f "${TITLE_FILE}" ]; then
  echo ">> File '$TITLE_FILE' already exist."; # compat with existing title.txt
  exit 0; # compat w/ manually created file
fi

rm -f "${TITLE_FILE}";
checkResult $?;
touch "${TITLE_FILE}";
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

AGENCY_LOCATION_SHORT="" # optional
AGENCY_LOCATION_FILE="${CONFIG_DIR}/agency_location";
if [ -f "$AGENCY_LOCATION_FILE" ]; then
    AGENCY_LOCATION_SHORT=$(head -n 1 $AGENCY_LOCATION_FILE);
    if [ -z "$AGENCY_LOCATION_SHORT" ]; then
        echo "$AGENCY_LOCATION_SHORT is empty!";
        exit 1;
    fi
fi

command -v xmllint >/dev/null 2>&1 || (sudo apt-get update && sudo apt-get install -y libxml2-utils);
command -v jq >/dev/null 2>&1 || (sudo apt-get update && sudo apt-get install -y jq);

GTFS_CONFIG_DIR="${CONFIG_DIR}/gtfs";
RES_DIR="${MAIN_DIR}/res";
VALUES_DIR="${RES_DIR}/values";
GTFS_RDS_VALUES_GEN_FILE="${VALUES_DIR}/gtfs_rts_values_gen.xml"; # do not change to avoid breaking compat w/ old modules
BIKE_STATION_VALUES_FILE="${VALUES_DIR}/bike_station_values.xml";
AGENCY_JSON_FILE="${GTFS_CONFIG_DIR}/agency.json";
TYPE=-1;
if [ -f $GTFS_RDS_VALUES_GEN_FILE ]; then
  # https://github.com/mtransitapps/parser/blob/master/src/main/java/org/mtransit/parser/gtfs/data/GRouteType.kt
  TYPE=$(xmllint --xpath "//resources/integer[@name='gtfs_rts_agency_type']/text()" "$GTFS_RDS_VALUES_GEN_FILE")
elif [ -f $AGENCY_JSON_FILE ]; then
  # https://github.com/mtransitapps/parser/blob/master/src/main/java/org/mtransit/parser/gtfs/data/GRouteType.kt
  TYPE=$(jq '.target_route_type_id' "$AGENCY_JSON_FILE")
elif [ -f $BIKE_STATION_VALUES_FILE ]; then
  TYPE=$(xmllint --xpath "//resources/integer[@name='bike_station_agency_type']/text()" "$BIKE_STATION_VALUES_FILE")
else
  echo " > No agency file! (rds:$GTFS_RDS_VALUES_GEN_FILE|bike:$BIKE_STATION_VALUES_FILE)"
  exit 1 # error
fi
TYPE_LABEL="";
if [ "$TYPE" -eq 0 ]; then # LIGHT_RAIL
    TYPE_LABEL="Light Rail";
elif [ "$TYPE" -eq 1 ]; then # SUBWAY
    TYPE_LABEL="Subway";
elif [ "$TYPE" -eq 2 ]; then # TRAIN
    TYPE_LABEL="Train";
elif [ "$TYPE" -eq 3 ]; then # BUS
    TYPE_LABEL="Bus";
elif [ "$TYPE" -eq 4 ]; then # FERRY
    TYPE_LABEL="Ferry";
elif [ "$TYPE" -eq 100 ]; then # BIKE
    TYPE_LABEL="Bike";
else
  echo "Unexpected agency type '$TYPE'!"
  exit 1 # error
fi

MAX_LENGTH=30;
TYPE_LABEL_MIN_LENGTH=3; # ${#TYPE_LABEL}

AGENCY_LABEL=$AGENCY_NAME_SHORT;

AGENCY_LABEL_AND_LOCATION_SHORT_LENGTH=$((${#AGENCY_LABEL} + ${#AGENCY_LOCATION_SHORT} + $TYPE_LABEL_MIN_LENGTH));

if [[ ! -z "$AGENCY_LOCATION_SHORT" && "$AGENCY_LABEL_AND_LOCATION_SHORT_LENGTH" -lt "$MAX_LENGTH" ]]; then
  AGENCY_LABEL="$AGENCY_LOCATION_SHORT $AGENCY_LABEL"
fi

TITLE="$AGENCY_LABEL $TYPE_LABEL - MonTransit";

echo $TITLE | awk -v len=$MAX_LENGTH '{ if (length($0) > len) print substr($0, 1, len-1) "…"; else print; }' >> "${TITLE_FILE}"

if [[ ${IS_CI} = true ]]; then
  echo "---------------------------------------------------------------------------------------------------------------";
  cat "${TITLE_FILE}"; #DEBUG
  echo "---------------------------------------------------------------------------------------------------------------";
fi

echo ">> Generating title.txt... DONE";