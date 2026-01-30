#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh

echo ">> Checking if data is outdated..."

# Check if app-android directory exists
APP_ANDROID_DIR="${SCRIPT_DIR}/../app-android/src/main";
if [[ ! -d "${APP_ANDROID_DIR}" ]]; then
  echo ">> No app-android directory found. Data check not applicable.";
  exit 0;
fi

# Get current date (yesterday to account for timezones)
YESTERDAY=$(date -d "yesterday" +%Y%m%d);
echo "> Yesterday: '$YESTERDAY'";

# Note: Binary schedule_service_dates files and XML values files are checked for existence only.
# Future enhancement: parse these files to extract actual last departure timestamps.

# Check current and next data files
CURRENT_SCHEDULE="${APP_ANDROID_DIR}/res-current/raw/current_gtfs_schedule_service_dates";
CURRENT_VALUES="${APP_ANDROID_DIR}/res-current/values/current_gtfs_rts_values_gen.xml";
NEXT_SCHEDULE="${APP_ANDROID_DIR}/res-next/raw/next_gtfs_schedule_service_dates";
NEXT_VALUES="${APP_ANDROID_DIR}/res-next/values/next_gtfs_rts_values_gen.xml";

HAS_CURRENT_DATA=false;
HAS_NEXT_DATA=false;

# Check if current data exists
if [[ -f "$CURRENT_SCHEDULE" ]] || [[ -f "$CURRENT_VALUES" ]]; then
  HAS_CURRENT_DATA=true;
  echo "> Current data files found.";
fi

# Check if next data exists
if [[ -f "$NEXT_SCHEDULE" ]] || [[ -f "$NEXT_VALUES" ]]; then
  HAS_NEXT_DATA=true;
  echo "> Next data files found.";
fi

if [[ "$HAS_CURRENT_DATA" == false ]] && [[ "$HAS_NEXT_DATA" == false ]]; then
  echo ">> No data files found. Data sync recommended.";
  exit 1; # Exit code 1 means data is outdated/missing
fi

# Check archive directory for available data
ARCHIVE_DIR="${SCRIPT_DIR}/archive";
echo "> Archive dir: '$ARCHIVE_DIR'";

if [[ ! -d "$ARCHIVE_DIR" ]]; then
  echo ">> No archive directory found. Cannot determine if data is outdated.";
  exit 0; # No archive, so we can't determine if outdated
fi

# Find archives
ARCHIVES_COUNT=$(find "$ARCHIVE_DIR" -name "*.zip" -type f 2>/dev/null | wc -l);
echo "> Archives found: $ARCHIVES_COUNT";

if [[ "$ARCHIVES_COUNT" -eq 0 ]]; then
  echo ">> No archives available. Data cannot be updated.";
  exit 0;
fi

# Check if any archive is newer/better than current data
HAS_CURRENT_ARCHIVE=false;
HAS_FUTURE_ARCHIVE=false;

# Find archives and check them
mapfile -t ARCHIVES < <(find "$ARCHIVE_DIR" -name "*.zip" -type f | sort)
if [[ "${#ARCHIVES[@]}" -gt 0 ]]; then
  for ARCHIVE in "${ARCHIVES[@]}" ; do
  ARCHIVE_BASENAME=$(basename "$ARCHIVE");
  ARCHIVE_BASENAME_NO_EXT="${ARCHIVE_BASENAME%.*}";
  ARCHIVE_BASENAME_NO_EXT_PARTS=(${ARCHIVE_BASENAME_NO_EXT//-/ });
  ARCHIVE_START_DATE=${ARCHIVE_BASENAME_NO_EXT_PARTS[0]};
  ARCHIVE_END_DATE=${ARCHIVE_BASENAME_NO_EXT_PARTS[1]};
  
  echo "> Archive: $ARCHIVE_BASENAME (${ARCHIVE_START_DATE} to ${ARCHIVE_END_DATE})";
  
  # Check if archive is current (includes yesterday/today)
  if [[ "$ARCHIVE_START_DATE" -le "$YESTERDAY" ]] && [[ "$ARCHIVE_END_DATE" -ge "$YESTERDAY" ]]; then
    HAS_CURRENT_ARCHIVE=true;
    echo "  - Current/in-progress archive";
  fi
  
  # Check if archive is in the future
  if [[ "$ARCHIVE_START_DATE" -gt "$YESTERDAY" ]]; then
    HAS_FUTURE_ARCHIVE=true;
    echo "  - Future archive";
  fi
done
fi

# Determine if data is outdated
DATA_OUTDATED=false;

# If we have NO current data but archives are available
if [[ "$HAS_CURRENT_DATA" == false ]] && [[ "$HAS_CURRENT_ARCHIVE" == true ]]; then
  echo ">> Current data missing but archive available. Data is OUTDATED.";
  DATA_OUTDATED=true;
fi

# If we have current data but NO next data, and future archive exists
if [[ "$HAS_CURRENT_DATA" == true ]] && [[ "$HAS_NEXT_DATA" == false ]] && [[ "$HAS_FUTURE_ARCHIVE" == true ]]; then
  echo ">> Next data missing but future archive available. Data is OUTDATED.";
  DATA_OUTDATED=true;
fi

# Output result
if [[ "$DATA_OUTDATED" == true ]]; then
  echo ">> Data is OUTDATED. Sync recommended.";
  exit 1; # Exit code 1 indicates data is outdated
else
  echo ">> Data is up-to-date.";
  exit 0; # Exit code 0 indicates data is current
fi
