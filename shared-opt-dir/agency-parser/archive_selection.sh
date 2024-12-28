#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh

echo ">> Selecting archive GTFS..."

YESTERDAY=$(date -d "yesterday" +%Y%m%d); # service can start yesterday and finish today
echo "> Yesterday: '$YESTERDAY'";

ARCHIVE_DIR="${SCRIPT_DIR}/archive";
echo "- archive dir: '$ARCHIVE_DIR'";

mkdir -p "$ARCHIVE_DIR";

CURRENT_ARCHIVE="";
CURRENT_ARCHIVE_START_DATE="";
CURRENT_ARCHIVE_END_DATE="";
NEXT_ARCHIVE="";
NEXT_ARCHIVE_START_DATE="";
NEXT_ARCHIVE_END_DATE="";

# ARCHIVES_COUNT=$(find $ARCHIVE_DIR/* -maxdepth 0 -type d | wc -l);
ARCHIVES_COUNT=$(find $ARCHIVE_DIR -name "*.zip" -type f | wc -l);
if [[ "$ARCHIVES_COUNT" -gt 0 ]]; then
  for ARCHIVE in $(find $ARCHIVE_DIR -name "*.zip" -type f) ; do
    echo "--------------------"
    echo "- archive: $ARCHIVE";
    ARCHIVE_BASENAME=$(basename "$ARCHIVE");
    ARCHIVE_BASENAME_NO_EXT="${ARCHIVE_BASENAME%.*}";
    ARCHIVE_BASENAME_NO_EXT_PARTS=(${ARCHIVE_BASENAME_NO_EXT//-/ });
    ARCHIVE_START_DATE=${ARCHIVE_BASENAME_NO_EXT_PARTS[0]};
    ARCHIVE_END_DATE=${ARCHIVE_BASENAME_NO_EXT_PARTS[1]};
    echo "- archive start date: '$ARCHIVE_START_DATE'";
    echo "- archive end date: '$ARCHIVE_END_DATE'";
    if [[ "$ARCHIVE_END_DATE" -lt "$YESTERDAY" && "$ARCHIVE_END_DATE" -gt "$CURRENT_ARCHIVE_END_DATE" ]]; then
      echo "- archive is entirely in the past & older than previous one > KEEP as CURRENT";
      CURRENT_ARCHIVE="$ARCHIVE";
      CURRENT_ARCHIVE_START_DATE=$ARCHIVE_START_DATE;
      CURRENT_ARCHIVE_END_DATE=$ARCHIVE_END_DATE;
    elif [[ "$ARCHIVE_START_DATE" -lt "$YESTERDAY" && "$ARCHIVE_END_DATE" -gt "$YESTERDAY" ]]; then
      echo "- archive starts before $YESTERDAY and ends after > KEEP as CURRENT";
      CURRENT_ARCHIVE="$ARCHIVE";
      CURRENT_ARCHIVE_START_DATE=$ARCHIVE_START_DATE;
      CURRENT_ARCHIVE_END_DATE=$ARCHIVE_END_DATE;
    elif [[ "$ARCHIVE_START_DATE" -gt "$YESTERDAY" ]]; then
      echo "- archive is in the future";
      if [[ -z "$NEXT_ARCHIVE_START_DATE" && "$ARCHIVE_START_DATE" -lt "$NEXT_ARCHIVE_START_DATE" ]]; then
        echo "- archive is newer than previous next one > KEEP as NEXT";
        NEXT_ARCHIVE="$ARCHIVE";
        NEXT_ARCHIVE_START_DATE=$ARCHIVE_START_DATE;
        NEXT_ARCHIVE_END_DATE=$ARCHIVE_END_DATE;
      else
        echo "- 1st future archive > KEEP as NEXT";
        NEXT_ARCHIVE="$ARCHIVE";
        NEXT_ARCHIVE_START_DATE=$ARCHIVE_START_DATE;
        NEXT_ARCHIVE_END_DATE=$ARCHIVE_END_DATE;
      fi
    else
      echo "- TODO handle this case?";
      # TODO ? exit 1;
    fi
    echo "--------------------"
  done
fi

GTFS_FILE="${SCRIPT_DIR}/input/gtfs.zip";
GTFS_NEXT_FILE="${SCRIPT_DIR}/input/gtfs_next.zip";

if [[ -n "$CURRENT_ARCHIVE" ]]; then
  echo ">> Using current archive...";
  echo "- Archive: '$CURRENT_ARCHIVE'.";
  echo "- Copying '$CURRENT_ARCHIVE' to '$GTFS_FILE'...";
  cp "$CURRENT_ARCHIVE" "$GTFS_FILE";
  checkResult $?;
  echo "- Copying '$CURRENT_ARCHIVE' to '$GTFS_FILE'... DONE";
  echo ">> Using current archive... DONE";
fi

if [[ -n "$NEXT_ARCHIVE" ]]; then
  echo ">> Using next archive...";
  echo "- Archive: '$NEXT_ARCHIVE'.";
  echo "- Copying '$NEXT_ARCHIVE' to '$GTFS_NEXT_FILE'...";
  cp "$NEXT_ARCHIVE" "$GTFS_NEXT_FILE";
  checkResult $?;
  echo "- Copying '$NEXT_ARCHIVE' to '$GTFS_NEXT_FILE'... DONE";
  echo ">> Using next archive... DONE";
fi

echo ">> Selecting archive GTFS... DONE"
