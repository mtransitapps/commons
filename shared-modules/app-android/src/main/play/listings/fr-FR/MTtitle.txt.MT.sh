#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";

ROOT_DIR="$SCRIPT_DIR/../../../../../../../..";
COMMONS_DIR="${ROOT_DIR}/commons";
source ${COMMONS_DIR}/commons.sh;

setIsCI;

echo ">> Generating fr-FR/title.txt...";

APP_ANDROID_DIR="${ROOT_DIR}/app-android";
SRC_DIR="${APP_ANDROID_DIR}/src";
MAIN_DIR="${SRC_DIR}/main";
PLAY_DIR="${MAIN_DIR}/play";
LISTINGS_DIR="${PLAY_DIR}/listings";
FR_FR_DIR="${LISTINGS_DIR}/fr-FR";

LANG_FR_FILE="${ROOT_DIR}/config/lang/fr";
if [ ! -f "$LANG_FR_FILE" && ! -f "$FR_FR_DIR"]; then
    echo ">> Generating fr-FR/full-description.txt... SKIP (FR lang not supported)";
    exit 0; # ok
fi

TITLE_FILE="${FR_FR_DIR}/title.txt";
mkdir -p "${FR_FR_DIR}";
checkResult $?;
if [ -f "${TITLE_FILE}" ]; then
  echo ">> File '$TITLE_FILE' already exist."; # compat with existing fr-FR/title.txt
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

requireCommand "xmllint" "libxml2-utils";
requireCommand "jq";

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
  TYPE=$(jq '.target_route_type_id // empty' "$AGENCY_JSON_FILE")
elif [ -f $BIKE_STATION_VALUES_FILE ]; then
  TYPE=$(xmllint --xpath "//resources/integer[@name='bike_station_agency_type']/text()" "$BIKE_STATION_VALUES_FILE")
else
  echo "> No agency file! (rds:$GTFS_RDS_VALUES_GEN_FILE|json:$AGENCY_JSON_FILE|bike:$BIKE_STATION_VALUES_FILE)"
  exit 1 # error
fi
if [ -z "$TYPE" ]; then
  echo " > No type found for agency!"
  exit 1 # error
fi
TYPE_LABEL="";
if [ "$TYPE" -eq 0 ]; then # LIGHT_RAIL
    TYPE_LABEL="Train Léger";
elif [ "$TYPE" -eq 1 ]; then # SUBWAY
    TYPE_LABEL="Métro";
elif [ "$TYPE" -eq 2 ]; then # TRAIN
    TYPE_LABEL="Train";
elif [ "$TYPE" -eq 3 ]; then # BUS
    TYPE_LABEL="Bus";
elif [ "$TYPE" -eq 4 ]; then # FERRY
    TYPE_LABEL="Bateau";
elif [ "$TYPE" -eq 100 ]; then # BIKE
    TYPE_LABEL="Vélo";
else
  echo "Unexpected agency type '$TYPE'!"
  exit 1 # error
fi

MAX_LENGTH=30;

AGENCY_LABEL=$AGENCY_NAME_SHORT;

AGENCY_LABEL_AND_LOCATION_SHORT_LENGTH=$((${#AGENCY_LABEL} + ${#AGENCY_LOCATION_SHORT}));

if [[ -n "$AGENCY_LOCATION_SHORT" && "$AGENCY_LABEL_AND_LOCATION_SHORT_LENGTH" -lt "$MAX_LENGTH" ]]; then
  AGENCY_LABEL="$AGENCY_LABEL $AGENCY_LOCATION_SHORT"
fi

TITLE="$TYPE_LABEL $AGENCY_LABEL - MonTransit";

echo $TITLE | awk -v len=$MAX_LENGTH '{ if (length($0) > len) print substr($0, 1, len-1) "…"; else print; }' >> "${TITLE_FILE}"

if [[ ${IS_CI} = true ]]; then
  echo "---------------------------------------------------------------------------------------------------------------";
  cat "${TITLE_FILE}"; #DEBUG
  echo "---------------------------------------------------------------------------------------------------------------";
fi

echo ">> Generating fr-FR/title.txt... DONE";