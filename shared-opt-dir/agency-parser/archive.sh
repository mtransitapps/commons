#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh

echo ">> Archiving GTFS... '$*'"
GTFS_FILE=$1;
FILES_DIR=$2;

if [[ ! -f "${GTFS_FILE}" ]]; then
  echo "ERROR: GTFS file '$GTFS_FILE' not found !";
  exit 1;
fi

if [[ -d ${FILES_DIR} ]]; then
	rm -r ${FILES_DIR};
	checkResult $? false;
fi
unzip -j ${GTFS_FILE} -d ${FILES_DIR};
checkResult $? false;

if [[ ! -d "${FILES_DIR}" ]]; then
  echo "ERROR: GTFS files directory not found in ${FILES_DIR}";
  exit 1;
fi

YESTERDAY=$(date -d "yesterday" +%Y%m%d); # service can start yesterday and finish today
echo "> Yesterday: '$YESTERDAY'";

START_DATE=""
END_DATE=""
FILE_CALENDAR="${FILES_DIR}/calendar.txt";
FILE_CALENDAR_DATES="${FILES_DIR}/calendar_dates.txt";
if [[ -f "$FILE_CALENDAR" ]]; then
  echo "Using $FILE_CALENDAR...";
  HEADERS=$(head -n 1 "$FILE_CALENDAR" | tr -d '\r')
  IFS="," read -r -a HEADERS_ARRAY <<< "$HEADERS"
  cleanArray HEADERS_ARRAY
  START_DATE_INDEX=$(getArrayIndex HEADERS_ARRAY "start_date")
  checkResult $?;
  END_DATE_INDEX=$(getArrayIndex HEADERS_ARRAY "end_date")
  checkResult $?;
  CUT_START_DATE_INDEX=$((START_DATE_INDEX+1))
  CUT_END_DATE_INDEX=$((END_DATE_INDEX+1))
  mapfile -t START_DATES < <(tail -n +2 "${FILE_CALENDAR}" | tr -d '\r' | cut -d ',' -f $CUT_START_DATE_INDEX)
  cleanArray START_DATES
  mapfile -t END_DATES < <(tail -n +2 "${FILE_CALENDAR}" | tr -d '\r' | cut -d ',' -f $CUT_END_DATE_INDEX)
  cleanArray END_DATES
  readarray -t START_DATES_SORTED < <(printf '%s\n' "${START_DATES[@]}" | sort)
  readarray -t END_DATES_SORTED < <(printf '%s\n' "${END_DATES[@]}" | sort)
  START_DATE=${START_DATES_SORTED[0]}
  END_DATE=${END_DATES_SORTED[-1]}
  echo "- start date: '${START_DATE}'"
  echo "- end date: '${END_DATE}'"
elif [[ -f "$FILE_CALENDAR_DATES" ]]; then
  echo "- Using $FILE_CALENDAR_DATES...";
  HEADERS=$(head -n 1 "$FILE_CALENDAR_DATES" | tr -d '\r')
  IFS="," read -r -a HEADERS_ARRAY <<< "$HEADERS"
  cleanArray HEADERS_ARRAY
  DATE_INDEX=$(getArrayIndex HEADERS_ARRAY "date")
  checkResult $?;
  CUT_INDEX=$((DATE_INDEX+1))
  mapfile -t DATES < <(tail -n +2 "${FILE_CALENDAR_DATES}" | tr -d '\r' | cut -d ',' -f $CUT_INDEX)
  cleanArray DATES
  readarray -t DATES_SORTED < <(printf '%s\n' "${DATES[@]}" | sort)
  START_DATE=${DATES_SORTED[0]}
  END_DATE=${DATES_SORTED[-1]}
  echo "- start date: '${START_DATE}'"
  echo "- end date: '${END_DATE}'"
else
  echo "ERROR: GTFS files not found in ${FILES_DIR}";
  exit 1;
fi

if [[ -z "$START_DATE" || -z "$END_DATE" ]]; then
  echo "ERROR: GTFS start '$START_DATE' | end '$END_DATE' dates not found!";
  exit 1;
fi

ARCHIVE_DIR="${SCRIPT_DIR}/archive";
echo "- archive dir: '$ARCHIVE_DIR'";

mkdir -p "$ARCHIVE_DIR";

rm -f "${ARCHIVE_DIR}/*.zip"; # delete old GTFS ZIP archives
checkResult $?;

GTFS_DIR_COUNT=$(find $ARCHIVE_DIR/* -maxdepth 0 -type d | wc -l);
if [[ "$GTFS_DIR_COUNT" -gt 0 ]]; then
  for GTFS_DIR in $(find $ARCHIVE_DIR/* -maxdepth 0 -type d) ; do
    echo "--------------------"
    echo "- GTFS: $GTFS_DIR";
    GTFS_DIR_BASENAME=$(basename "$GTFS_DIR");
    GTFS_DIR_BASENAME_NO_EXT="${GTFS_DIR_BASENAME%.*}";
    GTFS_DIR_BASENAME_NO_EXT_PARTS=(${GTFS_DIR_BASENAME_NO_EXT//-/ });
    GTFS_DIR_START_DATE=${GTFS_DIR_BASENAME_NO_EXT_PARTS[0]};
    GTFS_DIR_END_DATE=${GTFS_DIR_BASENAME_NO_EXT_PARTS[1]};
    echo "- GTFS start date: '$GTFS_DIR_START_DATE'";
    echo "- GTFS end date: '$GTFS_DIR_END_DATE'";
    if [[ "$GTFS_DIR_END_DATE" -lt "$YESTERDAY" && "$GTFS_DIR_END_DATE" -lt "$START_DATE" ]]; then
      echo "- GTFS is entirely in the past & older than new one > REMOVE";
      rm -r "$GTFS_DIR";
      checkResult $?;
    elif [[ "$GTFS_DIR_START_DATE" -eq "$START_DATE" && "$GTFS_DIR_END_DATE" -eq "$END_DATE" ]]; then
      echo "- GTFS is the same as the new one > REMOVE";
      rm -r "$GTFS_DIR";
      checkResult $?;
    elif [[ "$GTFS_DIR_START_DATE" -ge "$START_DATE" && "$GTFS_DIR_END_DATE" -le "$END_DATE" ]]; then
      echo "- GTFS is entirely inside the new ZIP > REMOVE";
      rm -r "$GTFS_DIR";
      checkResult $?;
    elif [[ "$GTFS_DIR_START_DATE" -lt "$YESTERDAY" && "$GTFS_DIR_END_DATE" -le "$END_DATE" ]]; then
      echo "- GTFS (after $YESTERDAY) is entirely inside the new one > REMOVE";
      rm -r "$GTFS_DIR";
      checkResult $?;
    elif [[ "$GTFS_DIR_START_DATE" -gt "$END_DATE" && "$GTFS_DIR_END_DATE" -gt "$YESTERDAY" ]]; then
      echo "- GTFS is entirely in the future & newer than new ZIP > KEEP";
    else
      echo "- TODO handle this case?";
      # - new ZIP file (future) is entirely inside archive ZIP file (current)
      # TODO ? exit 1;
    fi
    echo "--------------------"
  done
fi

NEW_ARCHIVE_DIR="${ARCHIVE_DIR}/${START_DATE}-${END_DATE}";
cp -R "$FILES_DIR/." "$NEW_ARCHIVE_DIR";
checkResult $?;

echo ">> Archiving GTFS... DONE ($ARCHIVE_FILE)"