#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";

ROOT_DIR="$SCRIPT_DIR/../../../../../../../..";
COMMONS_DIR="${ROOT_DIR}/commons";
source ${COMMONS_DIR}/commons.sh;

setIsCI;

LANG_FR_FILE="${ROOT_DIR}/config/lang/fr";
if [ ! -f "$LANG_FR_FILE" ]; then
    echo ">> Generating fr-FR/short-description.txt... SKIP (FR lang not supported)";
    exit 0; # ok
fi

echo ">> Generating fr-FR/short-description.txt...";

APP_ANDROID_DIR="${ROOT_DIR}/app-android";
SRC_DIR="${APP_ANDROID_DIR}/src";
MAIN_DIR="${SRC_DIR}/main";
PLAY_DIR="${MAIN_DIR}/play";
LISTINGS_DIR="${PLAY_DIR}/listings";
FR_FR_DIR="${LISTINGS_DIR}/fr-FR";
SHORT_DESCRIPTION_FILE="${FR_FR_DIR}/short-description.txt";
mkdir -p "${FR_FR_DIR}";
checkResult $?;
if [ -f "${SHORT_DESCRIPTION_FILE}" ]; then
  echo ">> File '$SHORT_DESCRIPTION_FILE' already exist."; # compat with existing fr-FR/short-description.txt
  exit 0; # compat w/ manually created file
fi

rm -f "${SHORT_DESCRIPTION_FILE}";
checkResult $?;
touch "${SHORT_DESCRIPTION_FILE}";
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

AGENCY_LOCATION_SHORT="" # optional
AGENCY_LOCATION_FILE="${CONFIG_DIR}/agency_location";
if [ -f "$AGENCY_LOCATION_FILE" ]; then
    AGENCY_LOCATION_SHORT=$(head -n 1 $AGENCY_LOCATION_FILE);
    if [ -z "$AGENCY_LOCATION_SHORT" ]; then
        echo "$AGENCY_LOCATION_SHORT is empty!";
        exit 1;
    fi
fi

AGENCY_LABEL=$AGENCY_NAME_LONG;

GTFS_CONFIG_DIR="${CONFIG_DIR}/gtfs";
RES_DIR="${MAIN_DIR}/res";
VALUES_DIR="${RES_DIR}/values";
GTFS_RDS_VALUES_GEN_FILE="${VALUES_DIR}/gtfs_rts_values_gen.xml"; # do not change to avoid breaking compat w/ old modules
BIKE_STATION_VALUES_FILE="${VALUES_DIR}/bike_station_values.xml";
AGENCY_JSON_FILE="${GTFS_CONFIG_DIR}/agency.json";
TYPE=-1;
if [ -f $GTFS_RDS_VALUES_GEN_FILE ]; then
  # https://github.com/mtransitapps/parser/blob/master/src/main/java/org/mtransit/parser/gtfs/data/GRouteType.kt
  TYPE=$(grep -E "<integer name=\"gtfs_rts_agency_type\">[0-9]+</integer>$" $GTFS_RDS_VALUES_GEN_FILE | tr -dc '0-9')
elif [ -f $AGENCY_JSON_FILE ]; then
  # https://github.com/mtransitapps/parser/blob/master/src/main/java/org/mtransit/parser/gtfs/data/GRouteType.kt
  TYPE=$(grep -E "\"target_route_type_id\": [0-9]+,$" $AGENCY_JSON_FILE | tr -dc '0-9')
elif [ -f $BIKE_STATION_VALUES_FILE ]; then
  TYPE=$(grep -E "<integer name=\"bike_station_agency_type\">[0-9]+</integer>$" $BIKE_STATION_VALUES_FILE | tr -dc '0-9')
else
  echo " > No agency file! (rds:$GTFS_RDS_VALUES_GEN_FILE|bike:$BIKE_STATION_VALUES_FILE)"
  exit 1 # error
fi
TYPE_LABEL="";
if [ "$TYPE" -eq 0 ]; then # LIGHT_RAIL
    TYPE_LABEL="Trains légers"; # TODO?
elif [ "$TYPE" -eq 1 ]; then # SUBWAY
    TYPE_LABEL="Métros";
elif [ "$TYPE" -eq 2 ]; then # TRAIN
    TYPE_LABEL="Trains";
elif [ "$TYPE" -eq 3 ]; then # BUS
    TYPE_LABEL="Bus"; # TODO Autobus?
elif [ "$TYPE" -eq 4 ]; then # FERRY
    TYPE_LABEL="Bateaux";
elif [ "$TYPE" -eq 100 ]; then # BIKE
    TYPE_LABEL="Vélos partagés";
else
  echo "Unexpected agency type '$TYPE'!"
  exit 1 # error
fi

AGENCY_LABEL=$AGENCY_NAME_LONG;
if [ ! -z "$AGENCY_LOCATION_SHORT" ]; then
  AGENCY_LABEL="$AGENCY_LABEL de $AGENCY_LOCATION_SHORT"
fi

SHORT_DESC="$TYPE_LABEL $AGENCY_LABEL pour MonTransit.";

RES_VALUES_DIR="${MAIN_DIR}/res/values";
BIKE_STATION_FILE="${RES_VALUES_DIR}/bike_station_values.xml";
if [ -f "$BIKE_STATION_FILE" ]; then
  SHORT_DESC="${SHORT_DESC} Disponibilité.";
fi
GTFS_RDS_VALUES_FILE="${RES_VALUES_DIR}/gtfs_rts_values.xml"; # do not change to avoid breaking compat w/ old modules
if [ -f "$GTFS_RDS_VALUES_FILE" ]; then
  SHORT_DESC="${SHORT_DESC} Horaire.";
fi
GTFS_RT_FILE="${RES_VALUES_DIR}/gtfs_real_time_values.xml";
if [ -f "${GTFS_RT_FILE}" ]; then
  SHORT_DESC="${SHORT_DESC} Alertes.";
fi

RSS_FILE="${RES_VALUES_DIR}/rss_values.xml";
TWITTER_FILE="${RES_VALUES_DIR}/twitter_values.xml";
YOUTUBE_FILE="${RES_VALUES_DIR}/youtube_values.xml";
# INSTAGRAM_FILE="${RES_VALUES_DIR}/instagram_values.xml"; # NOT WORKING
if [[ -f "${RSS_FILE}" || -f "${TWITTER_FILE}" || -f "${YOUTUBE_FILE}" ]]; then
  SHORT_DESC="${SHORT_DESC} Nouvelles.";
fi

MAX_LENGTH=80;

echo $SHORT_DESC | awk -v len=$MAX_LENGTH '{ if (length($0) > len) print substr($0, 1, len-1) "…"; else print; }' >> "${SHORT_DESCRIPTION_FILE}"

if [[ ${IS_CI} = true ]]; then
  echo "---------------------------------------------------------------------------------------------------------------";
  cat "${SHORT_DESCRIPTION_FILE}"; #DEBUG
  echo "---------------------------------------------------------------------------------------------------------------";
fi

echo ">> Generating fr-FR/short-description.txt... DONE";