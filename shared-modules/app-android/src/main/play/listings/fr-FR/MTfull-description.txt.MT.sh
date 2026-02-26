#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";

ROOT_DIR="$SCRIPT_DIR/../../../../../../../..";
COMMONS_DIR="${ROOT_DIR}/commons";
source ${COMMONS_DIR}/commons.sh;
source ${COMMONS_DIR}/feature_flags.sh;

setGitProjectName;

setIsCI;

echo ">> Generating fr-FR/full-description.txt...";

APP_ANDROID_DIR="${ROOT_DIR}/app-android";
SRC_DIR="${APP_ANDROID_DIR}/src";
MAIN_DIR="${SRC_DIR}/main";
PLAY_DIR="${MAIN_DIR}/play";
LISTINGS_DIR="${PLAY_DIR}/listings";
FR_FR_DIR="${LISTINGS_DIR}/fr-FR";

LANG_FR_FILE="${ROOT_DIR}/config/lang/fr";
if [ ! -f "$LANG_FR_FILE" && ! -d "$FR_FR_DIR" ]; then
    echo ">> Generating fr-FR/full-description.txt... SKIP (FR lang not supported)";
    exit 0; # ok
fi

FULL_DESCRIPTION_FILE="${FR_FR_DIR}/full-description.txt";
mkdir -p "${FR_FR_DIR}";
checkResult $?;
if [ -f "${FULL_DESCRIPTION_FILE}" ]; then
  echo ">> File '$FULL_DESCRIPTION_FILE' already exist."; # compat with existing fr-FR/full-description.txt
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
    if [ -n "$PARENT_AGENCY_NAME_LONG" ]; then
        AGENCY_LABEL="$AGENCY_LABEL ($PARENT_AGENCY_NAME_LONG)";
    fi
fi

if [ -n "$AGENCY_LOCATION_SHORT" ]; then
  AGENCY_LABEL="$AGENCY_LABEL de $AGENCY_LOCATION_SHORT"
fi

GIT_OWNER="mtransitapps"; #TODO extract de GIT_REMOTE_URL=$(git config --get remote.origin.url); # 'git@github.com:owner/repo.git' or 'https://github.com/owner/repo'.
CONTACT_WEBSITE_URL="https://github.com/$GIT_OWNER/$PROJECT_NAME";

SOURCE_URL_FILE="${CONFIG_DIR}/source_url_fr";
if [ ! -f "$SOURCE_URL_FILE" ]; then
  SOURCE_URL_FILE="${CONFIG_DIR}/source_url";
fi
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

AGENCY_OWNER_FILE="${CONFIG_DIR}/agency_owner"; #optional
if [ -f "$AGENCY_OWNER_FILE" ]; then
  AGENCY_OWNER_LONG=$(tail -n 1 $AGENCY_OWNER_FILE);
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
    COUNTRY_LABEL="États-Unis";
elif [ "$COUNTRY_CODE" = "fr" ]; then
    COUNTRY_LABEL="France";
else
  echo "Unexpected country code '$COUNTRY_CODE'!"
  exit 1 # error
fi

LOCATION_LABEL="$CITIES_LABEL (";
if [ -n "$STATE_LABEL_LONG" ]; then
    LOCATION_LABEL="$LOCATION_LABEL$STATE_LABEL_LONG, ";
fi
LOCATION_LABEL="$LOCATION_LABEL$COUNTRY_LABEL)";

SOURCE_PROVIDER="$SOURCE_NAME";
if [ -z "$SOURCE_PROVIDER" ]; then
  SOURCE_PROVIDER="$AGENCY_NAME_SHORT";
  if [ -n "$PARENT_AGENCY_NAME_LONG" ]; then
      SOURCE_PROVIDER=$PARENT_AGENCY_NAME_LONG;
  fi
fi

INDEX=1;
NOT_RELATED_WITH="";
if [ -n "$SOURCE_NAME" ]; then
  if [ "${INDEX}" -eq 1 ]; then
    NOT_RELATED_WITH="$SOURCE_NAME";
  else
    NOT_RELATED_WITH+=" ou $SOURCE_NAME";
  fi
  ((INDEX++))
fi
if [ -n "$AGENCY_OWNER_LONG" ]; then
  if [ "${INDEX}" -eq 1 ]; then
    NOT_RELATED_WITH="$AGENCY_OWNER_LONG";
  else
    NOT_RELATED_WITH+=" ou $AGENCY_OWNER_LONG";
  fi
  ((INDEX++))
fi
if [ -n "$AGENCY_NAME_LONG" ]; then
  if [ "${INDEX}" -eq 1 ]; then
    NOT_RELATED_WITH="$AGENCY_NAME_LONG";
  else
    NOT_RELATED_WITH+=" ou $AGENCY_NAME_LONG";
  fi
  ((INDEX++))
fi
if [ -n "$PARENT_AGENCY_NAME_LONG" ]; then
  if [ "${INDEX}" -eq 1 ]; then
    NOT_RELATED_WITH="$PARENT_AGENCY_NAME_LONG";
  else
    NOT_RELATED_WITH+=" ou $PARENT_AGENCY_NAME_LONG";
  fi
  ((INDEX++))
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
    TYPE_LABEL="trains léger"; # TODO?
elif [ "$TYPE" -eq 1 ]; then # SUBWAY
    TYPE_LABEL="métros";
elif [ "$TYPE" -eq 2 ]; then # TRAIN
    TYPE_LABEL="trains";
elif [ "$TYPE" -eq 3 ]; then # BUS
    TYPE_LABEL="autobus"; # "bus"
elif [ "$TYPE" -eq 4 ]; then # FERRY
    TYPE_LABEL="bateaux";
elif [ "$TYPE" -eq 100 ]; then # BIKE
    TYPE_LABEL="vélos";
else
  echo "Unexpected agency type '$TYPE'!"
  exit 1 # error
fi

PROVIDES_LINE="Cette application contient";

INFORMATION_LIST="";

if [ -f "$BIKE_STATION_VALUES_FILE" ]; then
  PROVIDES_LINE="${PROVIDES_LINE} la disponibilité";
  if [ -n "$INFORMATION_LIST" ]; then
    INFORMATION_LIST="${INFORMATION_LIST},";
  fi
  INFORMATION_LIST="${INFORMATION_LIST}disponibilité";
fi
GTFS_RDS_VALUES_FILE="${VALUES_DIR}/gtfs_rts_values.xml"; # do not change to avoid breaking compat w/ old modules
if [ -f "$GTFS_RDS_VALUES_FILE" ]; then
  PROVIDES_LINE="${PROVIDES_LINE} les horaires (accessible hors-ligne)";
  if [ -n "$INFORMATION_LIST" ]; then
    INFORMATION_LIST="${INFORMATION_LIST},";
  fi
  INFORMATION_LIST="${INFORMATION_LIST}horaire";
fi

PROVIDES_LINE="${PROVIDES_LINE} des $TYPE_LABEL";

PROVIDES_LINE_END="";

RSS_FILE="${VALUES_DIR}/rss_values.xml";
TWITTER_FILE="${VALUES_DIR}/twitter_values.xml";
YOUTUBE_FILE="${VALUES_DIR}/youtube_values.xml";
# INSTAGRAM_FILE="${VALUES_DIR}/instagram_values.xml"; # NOT WORKING
if [[ -f "${RSS_FILE}" || -f "${TWITTER_FILE}" || -f "${YOUTUBE_FILE}" ]]; then
  if [ -z "$PROVIDES_LINE_END" ]; then
    PROVIDES_LINE_END="${PROVIDES_LINE_END} et";
  else 
    PROVIDES_LINE_END="${PROVIDES_LINE_END},";
  fi
  PROVIDES_LINE_END="${PROVIDES_LINE_END} les nouvelles";
  NEWS_SOURCE_COUNT=0;
  if [[ -f "${RSS_FILE}" ]]; then
    FEEDS_LABEL=$(xmllint --xpath '//resources/string-array[@name="rss_feeds_label"]/item/text()' $RSS_FILE);
    checkResult $?;
    FEEDS_LABEL=$(echo "$FEEDS_LABEL" | sort -u);
    FEEDS_LABEL_ARRAY=(${FEEDS_LABEL//$'\n'/ });
    FEEDS_LABEL_ARRAY_LENGTH=(${#FEEDS_LABEL_ARRAY[@]});
    if [ "${NEWS_SOURCE_COUNT}" -eq 0 ]; then
      PROVIDES_LINE_END="${PROVIDES_LINE_END} de";
    fi
    if [ "${FEEDS_LABEL_ARRAY_LENGTH}" -gt 0 ]; then
      INDEX=1;
      for FEED_LABEL in "${FEEDS_LABEL_ARRAY[@]}"; do
        if [ "${INDEX}" -eq 1 ]; then
          PROVIDES_LINE_END="${PROVIDES_LINE_END}";
        elif [ "${INDEX}" -lt "${FEEDS_LABEL_ARRAY_LENGTH}" ]; then
          PROVIDES_LINE_END="${PROVIDES_LINE_END},";
        else
          PROVIDES_LINE_END="${PROVIDES_LINE_END} et";
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
      PROVIDES_LINE_END="${PROVIDES_LINE_END} de";
    else
      PROVIDES_LINE_END="${PROVIDES_LINE_END} ainsi que";
    fi
    if [ "${SCREEN_NAMES_ARRAY_LENGTH}" -gt 0 ]; then
      INDEX=1;
      for SCREEN_NAME in "${SCREEN_NAMES_ARRAY[@]}"; do
        if [ "${INDEX}" -eq 1 ]; then
          PROVIDES_LINE_END="${PROVIDES_LINE_END}";
        elif [ "${INDEX}" -lt "${SCREEN_NAMES_ARRAY_LENGTH}" ]; then
          PROVIDES_LINE_END="${PROVIDES_LINE_END},";
        else
          PROVIDES_LINE_END="${PROVIDES_LINE_END} et";
        fi
        PROVIDES_LINE_END="${PROVIDES_LINE_END} @${SCREEN_NAME}";
        ((INDEX++))
      done
      PROVIDES_LINE_END="${PROVIDES_LINE_END} sur";
    fi
    PROVIDES_LINE_END="${PROVIDES_LINE_END} Twitter";
    ((NEWS_SOURCE_COUNT++))
  fi
  # if [[ -f "${YOUTUBE_FILE}" ]]; then
  # YOUTUBE_FILE="${YOUTUBE_FILE} de YouTube"; # Google Play Store doesn´t like it
  # fi
fi

setFeatureFlags;

GTFS_RT_FILE="${VALUES_DIR}/gtfs_real_time_values.xml";
if [ -f "${GTFS_RT_FILE}" ]; then
  RT_PARTS=()
  if grep -q "gtfs_real_time_agency_service_alerts_url" "${GTFS_RT_FILE}"; then
    RT_PARTS+=(" alertes de service")
  fi
  if grep -q "gtfs_real_time_agency_vehicle_positions_url" "${GTFS_RT_FILE}"; then
    if [[ "${F_EXPORT_VEHICLE_LOCATION_PROVIDER}" == "true" ]]; then
      RT_PARTS+=(" positions des véhicules")
    fi
  fi
  OLD_IFS=$IFS; IFS=","
  RT_LINE="${RT_PARTS[*]}"
  IFS=$OLD_IFS
  if [ -n "$RT_LINE" ]; then
    RT_LINE="${RT_LINE} en temps-réel";
    if [ -z "$PROVIDES_LINE_END" ]; then
      PROVIDES_LINE_END=" et${RT_LINE}${PROVIDES_LINE_END}";
    else 
      PROVIDES_LINE_END=",${RT_LINE}${PROVIDES_LINE_END}";
    fi
  fi
fi

PROVIDES_LINE="${PROVIDES_LINE}${PROVIDES_LINE_END}";

OPERATE_IN=""
if [ -f $GTFS_RDS_VALUES_FILE ]; then
  OPERATE_IN="desservent"
elif [ -f $BIKE_STATION_VALUES_FILE ]; then
  OPERATE_IN="sont disponibles à"
else
  echo "> No agency file! (rds:$GTFS_RDS_VALUES_FILE|bike:$BIKE_STATION_VALUES_FILE)"
  exit 1 # error
fi

cat >>"${FULL_DESCRIPTION_FILE}" <<EOL
Cette application ajoute les informations des $TYPE_LABEL $AGENCY_LABEL à MonTransit.

$PROVIDES_LINE.

Les $TYPE_LABEL de $AGENCY_NAME_SHORT $OPERATE_IN $LOCATION_LABEL.

Une fois cette application installée, l'application MonTransit affichera les informations des $TYPE_LABEL ($INFORMATION_LIST...).

Cette application a seulement une icône temporaire : télécharger l'app MonTransit (gratuit) dans la section "Autres ..." ci-dessous ou en cliquant sur ce lien Google Play https://bit.ly/MonTransitPlay

Vous pouvez installer cette application sur la carte SD mais ce n'est pas recommandé.

Les informations viennent des données publiées par $SOURCE_PROVIDER:
$SOURCE_URL

Cette application est gratuite et open-source :
$CONTACT_WEBSITE_URL

Cette application n'est pas associée à $NOT_RELATED_WITH.
EOL

PERMISSIONS_LINE="";

if [ -f "${BIKE_STATION_FILE}" ]; then
  if [ -z "$PERMISSIONS_LINES" ]; then
    echo "" >> "${FULL_DESCRIPTION_FILE}";
    echo "Autorisations :" >> "${FULL_DESCRIPTION_FILE}";
    checkResult $?;
    PERMISSIONS_LINE="- Autres : requis pour le téléchargement des";
  else
    PERMISSIONS_LINE="${PERMISSIONS_LINE} et des";
  fi
  PERMISSIONS_LINE="${PERMISSIONS_LINE} informations des stations vélos";
fi

if [ -f "${GTFS_RT_FILE}" ]; then
  if [ -z "$PERMISSIONS_LINES" ]; then
    echo "" >> "${FULL_DESCRIPTION_FILE}";
    echo "Autorisations :" >> "${FULL_DESCRIPTION_FILE}";
    checkResult $?;
    PERMISSIONS_LINE="- Autres : requis pour le téléchargement des";
  else 
    PERMISSIONS_LINE="${PERMISSIONS_LINE} et des";
  fi
  PERMISSIONS_LINE="${PERMISSIONS_LINE} alertes de service en temps-réel";
fi
if [[ -f "${RSS_FILE}" || -f "${TWITTER_FILE}" || -f "${YOUTUBE_FILE}" ]]; then
  if [ -z "$PERMISSIONS_LINE" ]; then
    echo "" >> "${FULL_DESCRIPTION_FILE}";
    echo "Autorisations :" >> "${FULL_DESCRIPTION_FILE}";
    checkResult $?;
    PERMISSIONS_LINE="- Autres : requis pour le téléchargement des";
  else 
    PERMISSIONS_LINE="${PERMISSIONS_LINE} et des";
  fi
  PERMISSIONS_LINE="${PERMISSIONS_LINE} nouvelles";
fi

echo "$PERMISSIONS_LINE" >> "${FULL_DESCRIPTION_FILE}";
checkResult $?;

if [[ ${IS_CI} = true ]]; then
  echo "---------------------------------------------------------------------------------------------------------------";
  cat "${FULL_DESCRIPTION_FILE}"; #DEBUG
  echo "---------------------------------------------------------------------------------------------------------------";
fi

echo ">> Generating fr-FR/full-description.txt... DONE";
