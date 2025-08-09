#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";

ROOT_DIR="$SCRIPT_DIR/../../../../../../../..";
COMMONS_DIR="${ROOT_DIR}/commons";
source ${COMMONS_DIR}/commons.sh;

setIsCI;

echo ">> Generating short-description.txt...";

APP_ANDROID_DIR="${ROOT_DIR}/app-android";
SRC_DIR="${APP_ANDROID_DIR}/src";
MAIN_DIR="${SRC_DIR}/main";
PLAY_DIR="${MAIN_DIR}/play";
LISTINGS_DIR="${PLAY_DIR}/listings";
EN_US_DIR="${LISTINGS_DIR}/en-US";
SHORT_DESCRIPTION_FILE="${EN_US_DIR}/short-description.txt";
mkdir -p "${EN_US_DIR}";
checkResult $?;
if [ -f "${SHORT_DESCRIPTION_FILE}" ]; then
  echo ">> File '$SHORT_DESCRIPTION_FILE' already exist."; # compat with existing short-description.txt
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

RES_DIR="${MAIN_DIR}/res";
VALUES_DIR="${RES_DIR}/values";
GTFS_RTS_VALUES_GEN_FILE="${VALUES_DIR}/gtfs_rts_values_gen.xml";
BIKE_STATION_VALUES_FILE="${VALUES_DIR}/bike_station_values.xml"
TYPE=-1;
if [ -f $GTFS_RTS_VALUES_GEN_FILE ]; then
  # https://github.com/mtransitapps/parser/blob/master/src/main/java/org/mtransit/parser/gtfs/data/GRouteType.kt
  TYPE=$(grep -E "<integer name=\"gtfs_rts_agency_type\">[0-9]+</integer>$" $GTFS_RTS_VALUES_GEN_FILE | tr -dc '0-9')
elif [ -f $BIKE_STATION_VALUES_FILE ]; then
  TYPE=$(grep -E "<integer name=\"bike_station_agency_type\">[0-9]+</integer>$" $BIKE_STATION_VALUES_FILE | tr -dc '0-9')
else
  echo " > No agency file! (rts:$GTFS_RTS_VALUES_GEN_FILE|bike:$BIKE_STATION_VALUES_FILE)"
  exit 1 # error
fi
TYPE_LABEL="";
if [ "$TYPE" -eq 0 ]; then # LIGHT_RAIL
    TYPE_LABEL="light rail"; # TODO?
elif [ "$TYPE" -eq 1 ]; then # SUBWAY
    TYPE_LABEL="subways";
elif [ "$TYPE" -eq 2 ]; then # TRAIN
    TYPE_LABEL="trains";
elif [ "$TYPE" -eq 3 ]; then # BUS
    TYPE_LABEL="buses";
elif [ "$TYPE" -eq 4 ]; then # FERRY
    TYPE_LABEL="ferries";
elif [ "$TYPE" -eq 100 ]; then # BIKE
    TYPE_LABEL="bike sharing";
else
  echo "Unexpected agency type '$TYPE'!"
  exit 1 # error
fi

SHORT_DESC="$AGENCY_NAME_LONG $TYPE_LABEL for MonTransit.";

if [ ! -z "$AGENCY_LOCATION_SHORT" ]; then
  SHORT_DESC="$AGENCY_LOCATION_SHORT $SHORT_DESC"
fi

RES_VALUES_DIR="${MAIN_DIR}/res/values";
BIKE_STATION_FILE="${RES_VALUES_DIR}/bike_station_values.xml";
if [ -f "$BIKE_STATION_FILE" ]; then
  SHORT_DESC="${SHORT_DESC} Availability.";
fi
GTFS_FILE="${RES_VALUES_DIR}/gtfs_rts_values_gen.xml";
if [ -f "$GTFS_FILE" ]; then
  SHORT_DESC="${SHORT_DESC} Schedule.";
fi
GTFS_RT_FILE="${RES_VALUES_DIR}/gtfs_real_time_values.xml";
if [ -f "${GTFS_RT_FILE}" ]; then
  SHORT_DESC="${SHORT_DESC} Alerts.";
fi

RSS_FILE="${RES_VALUES_DIR}/rss_values.xml";
TWITTER_FILE="${RES_VALUES_DIR}/twitter_values.xml";
YOUTUBE_FILE="${RES_VALUES_DIR}/youtube_values.xml";
# INSTAGRAM_FILE="${RES_VALUES_DIR}/instagram_values.xml"; # NOT WORKING
if [[ -f "${RSS_FILE}" || -f "${TWITTER_FILE}" || -f "${YOUTUBE_FILE}" ]]; then
  SHORT_DESC="${SHORT_DESC} News.";
fi

MAX_LENGTH=80;

echo $SHORT_DESC | awk -v len=$MAX_LENGTH '{ if (length($0) > len) print substr($0, 1, len-1) "…"; else print; }' >> "${SHORT_DESCRIPTION_FILE}"

if [[ ${IS_CI} = true ]]; then
  echo "---------------------------------------------------------------------------------------------------------------";
  cat "${SHORT_DESCRIPTION_FILE}"; #DEBUG
  echo "---------------------------------------------------------------------------------------------------------------";
fi

echo ">> Generating short-description.txt... DONE";