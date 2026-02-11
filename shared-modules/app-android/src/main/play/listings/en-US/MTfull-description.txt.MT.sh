#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";

ROOT_DIR="$SCRIPT_DIR/../../../../../../../..";
COMMONS_DIR="${ROOT_DIR}/commons";
source ${COMMONS_DIR}/commons.sh;

setGitProjectName;

setIsCI;

echo ">> Generating full-description.txt...";

APP_ANDROID_DIR="${ROOT_DIR}/app-android";
SRC_DIR="${APP_ANDROID_DIR}/src";
MAIN_DIR="${SRC_DIR}/main";
PLAY_DIR="${MAIN_DIR}/play";
LISTINGS_DIR="${PLAY_DIR}/listings";
EN_US_DIR="${LISTINGS_DIR}/en-US";
FULL_DESCRIPTION_FILE="${EN_US_DIR}/full-description.txt";
mkdir -p "${EN_US_DIR}";
checkResult $?;
if [ -f "${FULL_DESCRIPTION_FILE}" ]; then
  echo ">> File '$FULL_DESCRIPTION_FILE' already exist."; # compat with existing full-description.txt
  exit 0; # compat w/ manually created file
fi

rm -f "${FULL_DESCRIPTION_FILE}";
checkResult $?;
touch "${FULL_DESCRIPTION_FILE}";
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

AGENCY_NAME_SHORT=$(head -n 1 $AGENCY_NAME_FILE);
if [ -z "$AGENCY_NAME_SHORT" ]; then
    echo "$AGENCY_NAME_SHORT is empty!";
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

PARENT_AGENCY_NAME_LONG="";
PARENT_AGENCY_NAME_FILE="$CONFIG_DIR/parent_agency_name";
if [ -f "$PARENT_AGENCY_NAME_FILE" ]; then
    PARENT_AGENCY_NAME_LONG=$(tail -n 1 $PARENT_AGENCY_NAME_FILE);
    if [ ! -z "$PARENT_AGENCY_NAME_LONG" ]; then
        AGENCY_LABEL="$AGENCY_LABEL ($PARENT_AGENCY_NAME_LONG)";
    fi
fi

if [ ! -z "$AGENCY_LOCATION_SHORT" ]; then
  AGENCY_LABEL="$AGENCY_LOCATION_SHORT $AGENCY_LABEL"
fi

GIT_OWNER="mtransitapps"; #TODO extract from GIT_REMOTE_URL=$(git config --get remote.origin.url); # 'git@github.com:owner/repo.git' or 'https://github.com/owner/repo'.
CONTACT_WEBSITE_URL="https://github.com/$GIT_OWNER/$PROJECT_NAME";

SOURCE_URL_FILE="${CONFIG_DIR}/source_url";
if [ ! -f "$SOURCE_URL_FILE" ]; then
    echo "$SOURCE_URL_FILE doesn't exist!";
    exit 1;
fi
SOURCE_URL=$(head -n 1 $SOURCE_URL_FILE);
if [ -z "$SOURCE_URL" ]; then
    echo "$SOURCE_URL is empty!";
    exit 1;
fi

SOURCE_NAME_FILE="${CONFIG_DIR}/source_name"; #optional
if [ -f "$SOURCE_NAME_FILE" ]; then
  SOURCE_NAME=$(head -n 1 $SOURCE_NAME_FILE);
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

STATE_LABEL_LONG=""; # optional
STATE_FILE="${CONFIG_DIR}/state";
if [ -f "$STATE_FILE" ]; then
    STATE_LABEL_LONG=$(tail -n 1 $STATE_FILE);
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

LOCATION_LABEL="$CITIES_LABEL in";
if [ ! -z "$STATE_LABEL_LONG" ]; then
    LOCATION_LABEL="$LOCATION_LABEL $STATE_LABEL_LONG,";
fi
LOCATION_LABEL="$LOCATION_LABEL $COUNTRY_LABEL";

SOURCE_PROVIDER="$SOURCE_NAME";
if [ -z "$SOURCE_PROVIDER" ]; then
  SOURCE_PROVIDER="$AGENCY_NAME_SHORT";
  if [ ! -z "$PARENT_AGENCY_NAME_LONG" ]; then
      SOURCE_PROVIDER=$PARENT_AGENCY_NAME_LONG;
  fi
fi

INDEX=1;
NOT_RELATED_WITH="";
if [ ! -z "$AGENCY_NAME_LONG" ]; then
  if [ "${INDEX}" -eq 1 ]; then
    NOT_RELATED_WITH="$AGENCY_NAME_LONG";
  else
    NOT_RELATED_WITH+=" or $AGENCY_NAME_LONG";
  fi
  ((INDEX++))
fi
if [ ! -z "$PARENT_AGENCY_NAME_LONG" ]; then
  if [ "${INDEX}" -eq 1 ]; then
    NOT_RELATED_WITH="$PARENT_AGENCY_NAME_LONG";
  else
    NOT_RELATED_WITH+=" or $PARENT_AGENCY_NAME_LONG";
  fi
  ((INDEX++))
fi
if [ ! -z "$SOURCE_NAME" ]; then
  if [ "${INDEX}" -eq 1 ]; then
    NOT_RELATED_WITH="$SOURCE_NAME";
  else
    NOT_RELATED_WITH+=" or $SOURCE_NAME";
  fi
  ((INDEX++))
fi

requireCommand "xmllint" "libxml2-utils";

RES_DIR="${MAIN_DIR}/res";
VALUES_DIR="${RES_DIR}/values";
GTFS_RDS_VALUES_GEN_FILE="${VALUES_DIR}/gtfs_rts_values_gen.xml"; # do not change to avoid breaking compat w/ old modules
BIKE_STATION_VALUES_FILE="${VALUES_DIR}/bike_station_values.xml"
TYPE=-1;
if [ -f $GTFS_RDS_VALUES_GEN_FILE ]; then
  # https://github.com/mtransitapps/parser/blob/master/src/main/java/org/mtransit/parser/gtfs/data/GRouteType.kt
  TYPE=$(xmllint --xpath "//resources/integer[@name='gtfs_rts_agency_type']/text()" "$GTFS_RDS_VALUES_GEN_FILE")
elif [ -f $BIKE_STATION_VALUES_FILE ]; then
  TYPE=$(xmllint --xpath "//resources/integer[@name='bike_station_agency_type']/text()" "$BIKE_STATION_VALUES_FILE")
else
  echo " > No agency file! (rds:$GTFS_RDS_VALUES_GEN_FILE|bike:$BIKE_STATION_VALUES_FILE)"
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
    TYPE_LABEL="bike stations";
else
  echo "Unexpected agency type '$TYPE'!"
  exit 1 # error
fi

PROVIDES_LINE="This app provides the $TYPE_LABEL";

INFORMATION_LIST="";

RES_VALUES_DIR="${MAIN_DIR}/res/values";
BIKE_STATION_FILE="${RES_VALUES_DIR}/bike_station_values.xml";
if [ -f "$BIKE_STATION_FILE" ]; then
  PROVIDES_LINE="${PROVIDES_LINE} availability";
  if [ ! -z "$INFORMATION_LIST" ]; then
    INFORMATION_LIST="${INFORMATION_LIST},";
  fi
  INFORMATION_LIST="${INFORMATION_LIST}availability";
fi
GTFS_FILE="${RES_VALUES_DIR}/gtfs_rts_values_gen.xml"; # do not change to avoid breaking compat w/ old modules
if [ -f "$GTFS_FILE" ]; then
  PROVIDES_LINE="${PROVIDES_LINE} schedule (accessible offline)";
  if [ ! -z "$INFORMATION_LIST" ]; then
    INFORMATION_LIST="${INFORMATION_LIST},";
  fi
  INFORMATION_LIST="${INFORMATION_LIST}schedule";
fi

PROVIDES_LINE_END="";

RSS_FILE="${RES_VALUES_DIR}/rss_values.xml";
TWITTER_FILE="${RES_VALUES_DIR}/twitter_values.xml";
YOUTUBE_FILE="${RES_VALUES_DIR}/youtube_values.xml";
# INSTAGRAM_FILE="${RES_VALUES_DIR}/instagram_values.xml"; # NOT WORKING
if [[ -f "${RSS_FILE}" || -f "${TWITTER_FILE}" || -f "${YOUTUBE_FILE}" ]]; then
  if [ -z "$PROVIDES_LINE_END" ]; then
    PROVIDES_LINE_END="${PROVIDES_LINE_END} and";
  else 
    PROVIDES_LINE_END="${PROVIDES_LINE_END},";
  fi
  PROVIDES_LINE_END="${PROVIDES_LINE_END} news";
  NEWS_SOURCE_COUNT=0;
  if [[ -f "${RSS_FILE}" ]]; then
    FEEDS_LABEL=$(xmllint --xpath '//resources/string-array[@name="rss_feeds_label"]/item/text()' $RSS_FILE);
    checkResult $?;
    FEEDS_LABEL=$(echo "$FEEDS_LABEL" | sort -u);
    FEEDS_LABEL_ARRAY=(${FEEDS_LABEL//$'\n'/ });
    FEEDS_LABEL_ARRAY_LENGTH=(${#FEEDS_LABEL_ARRAY[@]});
    if [ "${NEWS_SOURCE_COUNT}" -eq 0 ]; then
      PROVIDES_LINE_END="${PROVIDES_LINE_END} from";
    fi
    if [ "${FEEDS_LABEL_ARRAY_LENGTH}" -gt 0 ]; then
      INDEX=1;
      for FEED_LABEL in "${FEEDS_LABEL_ARRAY[@]}"; do
        if [ "${INDEX}" -eq 1 ]; then
          PROVIDES_LINE_END="${PROVIDES_LINE_END}";
        elif [ "${INDEX}" -lt "${FEEDS_LABEL_ARRAY_LENGTH}" ]; then
          PROVIDES_LINE_END="${PROVIDES_LINE_END},";
        else
          PROVIDES_LINE_END="${PROVIDES_LINE_END} and";
        fi
        PROVIDES_LINE_END="${PROVIDES_LINE_END} $FEED_LABEL";
        ((INDEX++))
      done
    fi
     ((NEWS_SOURCE_COUNT++))
  fi
  if [[ -f "${TWITTER_FILE}" ]]; then
    SCREEN_NAMES=$(xmllint --xpath '//resources/string-array[@name="twitter_screen_names"]/item/text()' $TWITTER_FILE);
    checkResult $?;
    SCREEN_NAMES_ARRAY=(${SCREEN_NAMES//$'\n'/ });
    SCREEN_NAMES_ARRAY_LENGTH=(${#SCREEN_NAMES_ARRAY[@]});
    if [ "${NEWS_SOURCE_COUNT}" -eq 0 ]; then
      PROVIDES_LINE_END="${PROVIDES_LINE_END} from";
    else
      PROVIDES_LINE_END="${PROVIDES_LINE_END} as well as";
    fi
    if [ "${SCREEN_NAMES_ARRAY_LENGTH}" -gt 0 ]; then
      INDEX=1;
      for SCREEN_NAME in "${SCREEN_NAMES_ARRAY[@]}"; do
        if [ "${INDEX}" -eq 1 ]; then
          PROVIDES_LINE_END="${PROVIDES_LINE_END}";
        elif [ "${INDEX}" -lt "${SCREEN_NAMES_ARRAY_LENGTH}" ]; then
          PROVIDES_LINE_END="${PROVIDES_LINE_END},";
        else
          PROVIDES_LINE_END="${PROVIDES_LINE_END} and";
        fi
        PROVIDES_LINE_END="${PROVIDES_LINE_END} @${SCREEN_NAME}";
        ((INDEX++))
      done
      PROVIDES_LINE_END="${PROVIDES_LINE_END} on";
    fi
    PROVIDES_LINE_END="${PROVIDES_LINE_END} Twitter";
    ((NEWS_SOURCE_COUNT++))
  fi
  # if [[ -f "${YOUTUBE_FILE}" ]]; then
  # YOUTUBE_FILE="${YOUTUBE_FILE} from YouTube"; # Google Play Store doesn´t like it
  # fi
fi

GTFS_RT_FILE="${RES_VALUES_DIR}/gtfs_real_time_values.xml";
if [ -f "${GTFS_RT_FILE}" ]; then
  if [ -z "$PROVIDES_LINE_END" ]; then
    PROVIDES_LINE_END=" and real-time service alerts${PROVIDES_LINE_END}";
  else 
    PROVIDES_LINE_END=", real-time service alerts${PROVIDES_LINE_END}";
  fi
fi

PROVIDES_LINE="${PROVIDES_LINE}${PROVIDES_LINE_END}";

OPERATE_IN=""
if [ -f $GTFS_RDS_VALUES_GEN_FILE ]; then
  OPERATE_IN="serve"
elif [ -f $BIKE_STATION_VALUES_FILE ]; then
  OPERATE_IN="are available in"
else
  echo " > No agency file! (rds:$GTFS_RDS_VALUES_GEN_FILE|bike:$BIKE_STATION_VALUES_FILE)"
  exit 1 # error
fi

cat >>"${FULL_DESCRIPTION_FILE}" <<EOL
This app adds $AGENCY_LABEL $TYPE_LABEL information to MonTransit.

$PROVIDES_LINE.

$AGENCY_NAME_SHORT $TYPE_LABEL $OPERATE_IN $LOCATION_LABEL.

Once this application is installed, the MonTransit app will display $TYPE_LABEL information ($INFORMATION_LIST...).

This application only has a temporary icon: download the MonTransit app (free) in the "More ..." section bellow or by following this Google Play link https://bit.ly/MonTransitPlay

You can install this application on the SD card but it is not recommended.

The information comes from the data published by $SOURCE_PROVIDER:
$SOURCE_URL

This application is free and open-source:
$CONTACT_WEBSITE_URL

This app is not related with $NOT_RELATED_WITH.
EOL

PERMISSIONS_LINE="";

if [ -f "${BIKE_STATION_FILE}" ]; then
  if [ -z "$PERMISSIONS_LINES" ]; then
    echo "" >> "${FULL_DESCRIPTION_FILE}";
    echo "Permissions:" >> "${FULL_DESCRIPTION_FILE}";
    checkResult $?;
    PERMISSIONS_LINE="- Other: required to download";
  else
    PERMISSIONS_LINE="${PERMISSIONS_LINE} and";
  fi
  PERMISSIONS_LINE="${PERMISSIONS_LINE} bike stations information";
fi

if [ -f "${GTFS_RT_FILE}" ]; then
  if [ -z "$PERMISSIONS_LINES" ]; then
    echo "" >> "${FULL_DESCRIPTION_FILE}";
    echo "Permissions:" >> "${FULL_DESCRIPTION_FILE}";
    checkResult $?;
    PERMISSIONS_LINE="- Other: required to download";
  else 
    PERMISSIONS_LINE="${PERMISSIONS_LINE} and";
  fi
  PERMISSIONS_LINE="${PERMISSIONS_LINE} real-time service alerts";
fi
if [[ -f "${RSS_FILE}" || -f "${TWITTER_FILE}" || -f "${YOUTUBE_FILE}" ]]; then
  if [ -z "$PERMISSIONS_LINE" ]; then
    echo "" >> "${FULL_DESCRIPTION_FILE}";
    echo "Permissions:" >> "${FULL_DESCRIPTION_FILE}";
    checkResult $?;
    PERMISSIONS_LINE="- Other: required to download";
  else 
    PERMISSIONS_LINE="${PERMISSIONS_LINE} and";
  fi
  PERMISSIONS_LINE="${PERMISSIONS_LINE} news";
fi

echo "$PERMISSIONS_LINE" >> "${FULL_DESCRIPTION_FILE}";
checkResult $?;

if [[ ${IS_CI} = true ]]; then
  echo "---------------------------------------------------------------------------------------------------------------";
  cat "${FULL_DESCRIPTION_FILE}"; #DEBUG
  echo "---------------------------------------------------------------------------------------------------------------";
fi

echo ">> Generating full-description.txt... DONE";
