#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh

echo ">> Archiving..."

# GTFS
echo "> Archiving GTFS..."
GTFS_FILE="${SCRIPT_DIR}/input/gtfs.zip";
FILES_DIR="${SCRIPT_DIR}/input/gtfs";

if [[ ! -d "${FILES_DIR}" ]]; then
  echo "ERROR: GTFS files not found in ${FILES_DIR}";
  exit 1;
fi

START_DATE=""
END_DATE=""
if [[ -f "${FILES_DIR}/calendars.txt" ]]; then
  echo "TODO: Using calendars.txt";
  exit 1
elif [[ -f "${FILES_DIR}/calendar_dates.txt" ]]; then
  echo "- Using calendar_dates.txt";
  HEADERS=$(head -n 1 "${FILES_DIR}/calendar_dates.txt")
  IFS="," read -r -a HEADERS_ARRAY <<< "$HEADERS"
  DATE_INDEX=$(getArrayIndex HEADERS_ARRAY "date")
  checkResult $?;
  CUT_INDEX=$((DATE_INDEX+1))
  mapfile -t DATES < <(tail -n +2 "${FILES_DIR}/calendar_dates.txt" | cut -d ',' -f $CUT_INDEX)
  readarray -t DATES_SORTED < <(printf '%s\n' "${DATES[@]}" | sort)
  START_DATE=${DATES_SORTED[0]}
  echo "- start date: ${START_DATE}"
  END_DATE=${DATES_SORTED[-1]}
  echo "- end date: ${END_DATE}"
else
  echo "ERROR: GTFS files not found in ${FILES_DIR}";
  exit 1;
fi

mkdir -p "${SCRIPT_DIR}/archive";

ARCHIVE_FILE="${SCRIPT_DIR}/archive/${START_DATE}-${END_DATE}.zip";
cp "$GTFS_FILE" "$ARCHIVE_FILE";
checkResult $?;

echo ">> Archiving GTFS... DONE ($ARCHIVE_FILE)"

# TODO next GTFS

echo "> Archiving... DONE"