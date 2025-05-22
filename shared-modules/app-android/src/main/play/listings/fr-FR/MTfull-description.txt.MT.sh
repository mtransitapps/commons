#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";

ROOT_DIR="$SCRIPT_DIR/../../../../../../../..";
COMMONS_DIR="${ROOT_DIR}/commons";
source ${COMMONS_DIR}/commons.sh;

setGitProjectName;

setIsCI;

LANG_FR_FILE="${ROOT_DIR}/config/lang/fr";
if [ ! -f "$LANG_FR_FILE" ]; then
    echo ">> Generating fr-FR/full-description.txt... SKIP (FR lang not supported)";
    exit 0; # ok
fi

echo ">> Generating fr-FR/full-description.txt...";

APP_ANDROID_DIR="${ROOT_DIR}/app-android";
SRC_DIR="${APP_ANDROID_DIR}/src";
MAIN_DIR="${SRC_DIR}/main";
PLAY_DIR="${MAIN_DIR}/play";
LISTINGS_DIR="${PLAY_DIR}/listings";
FR_FR_DIR="${LISTINGS_DIR}/fr-FR";
FULL_DESCRIPTION_FILE="${FR_FR_DIR}/full-description.txt";
mkdir -p "${FR_FR_DIR}";
checkResult $?;
if [ -f "${FULL_DESCRIPTION_FILE}" ]; then
  echo ">> File '$FULL_DESCRIPTION_FILE' already exist."; # compat with existing fr-FR/full-description.txt
  exit 0;
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
  AGENCY_LABEL="$AGENCY_LABEL de $AGENCY_LOCATION_SHORT"
fi

GIT_OWNER="mtransitapps"; #TODO extract de GIT_REMOTE_URL=$(git config --get remote.origin.url); # 'git@github.com:owner/repo.git' or 'https://github.com/owner/repo'.
CONTACT_WEBITE_URL="https://github.com/$GIT_OWNER/$PROJECT_NAME";

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

LOCATION_LABEL="$CITIES_LABEL au";
if [ ! -z "$STATE_LABEL_LONG" ]; then
    LOCATION_LABEL="$LOCATION_LABEL $STATE_LABEL_LONG,";
fi
LOCATION_LABEL="$LOCATION_LABEL $COUNTRY_LABEL";

SOURCE_PROVIDER=$AGENCY_NAME_LONG;
if [ ! -z "$PARENT_AGENCY_NAME_LONG" ]; then
    SOURCE_PROVIDER=$PARENT_AGENCY_NAME_LONG;
fi

NOT_RELATED_WITH=$AGENCY_NAME_LONG;
if [ ! -z "$PARENT_AGENCY_NAME_LONG" ]; then
    NOT_RELATED_WITH="$NOT_RELATED_WITH et $PARENT_AGENCY_NAME_LONG";
fi

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
    TYPE_LABEL="trains léger"; # TODO?
elif [ "$TYPE" -eq 1 ]; then # SUBWAY
    TYPE_LABEL="métros";
elif [ "$TYPE" -eq 2 ]; then # TRAIN
    TYPE_LABEL="trains";
elif [ "$TYPE" -eq 3 ]; then # BUS
    TYPE_LABEL="bus";
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

RES_VALUES_DIR="${MAIN_DIR}/res/values";
BIKE_STATION_FILE="${RES_VALUES_DIR}/bike_station_values.xml";
if [ -f "$BIKE_STATION_FILE" ]; then
  PROVIDES_LINE="${PROVIDES_LINE} la disponibilité";
  if [ ! -z "$INFORMATION_LIST" ]; then
    INFORMATION_LIST="${INFORMATION_LIST},";
  fi
  INFORMATION_LIST="${INFORMATION_LIST}disponibilité";
fi
GTFS_FILE="${RES_VALUES_DIR}/gtfs_rts_values_gen.xml";
if [ -f "$GTFS_FILE" ]; then
  PROVIDES_LINE="${PROVIDES_LINE} les horaires (accessible hors-ligne)";
  if [ ! -z "$INFORMATION_LIST" ]; then
    INFORMATION_LIST="${INFORMATION_LIST},";
  fi
  INFORMATION_LIST="${INFORMATION_LIST}horaire";
fi

PROVIDES_LINE="${PROVIDES_LINE} des $TYPE_LABEL";

xmllint --version || (sudo apt-get update && sudo apt-get install -y libxml2-utils);

PROVIDES_LINE_END="";

RSS_FILE="${RES_VALUES_DIR}/rss_values.xml";
TWITTER_FILE="${RES_VALUES_DIR}/twitter_values.xml";
YOUTUBE_FILE="${RES_VALUES_DIR}/youtube_values.xml";
# INSTAGRAM_FILE="${RES_VALUES_DIR}/instagram_values.xml"; # NOT WORKING
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

GTFS_RT_FILE="${RES_VALUES_DIR}/gtfs_real_time_values.xml";
if [ -f "${GTFS_RT_FILE}" ]; then
  if [ -z "$PROVIDES_LINE_END" ]; then
    PROVIDES_LINE_END=" et alertes de service en temps-réel ${PROVIDES_LINE_END}";
  else 
    PROVIDES_LINE_END=", alertes de service en temps-réel ${PROVIDES_LINE_END}";
  fi
fi

PROVIDES_LINE="${PROVIDES_LINE}${PROVIDES_LINE_END}";

OPERATE_IN=""
if [ -f $GTFS_RTS_VALUES_GEN_FILE ]; then
  OPERATE_IN="desservent"
elif [ -f $BIKE_STATION_VALUES_FILE ]; then
  OPERATE_IN="sont disponibles à"
else
  echo " > No agency file! (rts:$GTFS_RTS_VALUES_GEN_FILE|bike:$BIKE_STATION_VALUES_FILE)"
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
$CONTACT_WEBITE_URL

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