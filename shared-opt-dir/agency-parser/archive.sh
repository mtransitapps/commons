#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh

echo ">> Archiving GTFS... '$*'"
GTFS_FILE=$1;
FILES_DIR=$2;

if [[ ! -f "${GTFS_FILE}" ]]; then
  echo "ERROR: GTFS file not found in ${FILES_DIR}";
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


ZIP_FILE_COUNT=$(find $ARCHIVE_DIR -name "*.zip" -type f | wc -l);
if [[ "$ZIP_FILE_COUNT" -gt 0 ]]; then
  for ZIP_FILE in $(ls -a ${ARCHIVE_DIR}/*.zip) ; do
    echo "--------------------"
    echo "- ZIP file: $ZIP_FILE";
    ZIP_FILE_BASENAME=$(basename "$ZIP_FILE");
    ZIP_FILE_BASENAME_NO_EXT="${ZIP_FILE_BASENAME%.*}";
    ZIP_FILE_BASENAME_NO_EXT_PARTS=(${ZIP_FILE_BASENAME_NO_EXT//-/ });
    ZIP_FILE_START_DATE=${ZIP_FILE_BASENAME_NO_EXT_PARTS[0]};
    ZIP_FILE_END_DATE=${ZIP_FILE_BASENAME_NO_EXT_PARTS[1]};
    echo "- ZIP start date: '$ZIP_FILE_START_DATE'";
    echo "- ZIP end date: '$ZIP_FILE_END_DATE'";
    if [[ "$ZIP_FILE_END_DATE" -lt "$YESTERDAY" && "$ZIP_FILE_END_DATE" -lt "$START_DATE" ]]; then
      echo "- ZIP file is entirely in the past and older than new ZIP > REMOVE";
      rm "$ZIP_FILE";
      checkResult $?;
    elif [[ "$ZIP_FILE_START_DATE" -eq "$START_DATE" && "$ZIP_FILE_END_DATE" -eq "$END_DATE" ]]; then
      echo "- ZIP file is the same as the new ZIP > REMOVE";
      rm "$ZIP_FILE";
      checkResult $?;
    elif [[ "$ZIP_FILE_START_DATE" -ge "$START_DATE" && "$ZIP_FILE_END_DATE" -le "$END_DATE" ]]; then
      echo "- ZIP file is entirely inside the new ZIP > REMOVE";
      rm "$ZIP_FILE";
      checkResult $?;
    elif [[ "$ZIP_FILE_START_DATE" -lt "$YESTERDAY" && "$ZIP_FILE_END_DATE" -le "$END_DATE" ]]; then
      echo "- ZIP file (after $YESTERDAY) is entirely inside the new ZIP > REMOVE";
      rm "$ZIP_FILE";
      checkResult $?;
    elif [[ "$ZIP_FILE_START_DATE" -gt "$END_DATE" && "$ZIP_FILE_END_DATE" -gt "$YESTERDAY" ]]; then
      echo "- ZIP file is entirely in the future and newer than new ZIP > KEEP";
    else
      echo "- TODO handle this case?";
      # - new ZIP file (future) is entirely inside archive ZIP file (current)
      # TODO ? exit 1;
    fi
    echo "--------------------"
  done
fi

ARCHIVE_FILE="${ARCHIVE_DIR}/${START_DATE}-${END_DATE}.zip";
cp "$GTFS_FILE" "$ARCHIVE_FILE";
checkResult $?;

echo ">> Archiving GTFS... DONE ($ARCHIVE_FILE)"