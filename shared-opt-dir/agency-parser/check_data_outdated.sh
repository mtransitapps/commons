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

# Get current timestamp in seconds
NOW_TIMESTAMP_SEC=$(date +%s);
echo "> Current timestamp: '$NOW_TIMESTAMP_SEC'";

# Check current and next data files
CURRENT_VALUES="${APP_ANDROID_DIR}/res-current/values/current_gtfs_rts_values_gen.xml";
NEXT_VALUES="${APP_ANDROID_DIR}/res-next/values/next_gtfs_rts_values_gen.xml";

# Function to extract last departure timestamp from XML file
get_last_departure_from_xml() {
  local FILE=$1;
  if [[ ! -f "$FILE" ]]; then
    echo "";
    return;
  fi
  # Extract the last_departure_in_sec value from XML
  # Pattern matches lines like: 
  # <integer name="current_gtfs_rts_last_departure_in_sec">1782094500</integer>
  # <integer name="next_gtfs_rts_last_departure_in_sec">1782094500</integer> <!-- with comments -->
  grep -E "<integer name=\"[^\"]*_gtfs_rts_last_departure_in_sec\">[0-9]+</integer>" "$FILE" 2>/dev/null | sed 's/[^[:digit:]]*\([[:digit:]]\+\).*/\1/' || echo "";
}

# Prefer "next" file if available, otherwise fallback to "current"
DEPLOYED_LAST_DEPARTURE_SEC="";
DATA_FILE_USED="";

if [[ -f "$NEXT_VALUES" ]]; then
  DEPLOYED_LAST_DEPARTURE_SEC=$(get_last_departure_from_xml "$NEXT_VALUES");
  DATA_FILE_USED="next";
  if [[ -n "$DEPLOYED_LAST_DEPARTURE_SEC" ]]; then
    echo "> Using next data file.";
  else
    echo "> Next data file found but timestamp not found.";
  fi
elif [[ -f "$CURRENT_VALUES" ]]; then
  DEPLOYED_LAST_DEPARTURE_SEC=$(get_last_departure_from_xml "$CURRENT_VALUES");
  DATA_FILE_USED="current";
  if [[ -n "$DEPLOYED_LAST_DEPARTURE_SEC" ]]; then
    echo "> Using current data file.";
  else
    echo "> Current data file found but timestamp not found.";
  fi
fi

if [[ -z "$DEPLOYED_LAST_DEPARTURE_SEC" ]]; then
  if [[ ! -f "$NEXT_VALUES" ]] && [[ ! -f "$CURRENT_VALUES" ]]; then
    echo ">> No data files found. Cannot determine if data is outdated.";
  else
    echo ">> Data files found but last departure timestamp not found. Cannot determine if data is outdated.";
  fi
  exit 0; # Exit code 0 - avoid triggering sync when uncertain
fi

echo "> Deployed last departure timestamp: '$DEPLOYED_LAST_DEPARTURE_SEC' (from $DATA_FILE_USED)";

# Check if deployed data is outdated (last departure is in the past)
if [[ "$DEPLOYED_LAST_DEPARTURE_SEC" -lt "$NOW_TIMESTAMP_SEC" ]]; then
  DIFF_SEC=$((NOW_TIMESTAMP_SEC - DEPLOYED_LAST_DEPARTURE_SEC));
  DIFF_DAYS=$((DIFF_SEC / 86400));
  echo ">> Deployed data has expired! Last departure was $DIFF_DAYS days ago.";
  echo ">> Data is OUTDATED. Sync recommended.";
  exit 1; # Exit code 1 indicates data is outdated
fi

# Check archive directory for available data
ARCHIVE_DIR="${SCRIPT_DIR}/archive";
echo "> Archive dir: '$ARCHIVE_DIR'";

if [[ ! -d "$ARCHIVE_DIR" ]]; then
  echo ">> No archive directory found. Cannot check for newer data.";
  echo ">> Data is up-to-date (based on deployed data only).";
  exit 0; # No archive, so we can't determine if newer data available
fi

# Find archives
mapfile -t ARCHIVES < <(find "$ARCHIVE_DIR" -name "*.zip" -type f 2>/dev/null | sort)
echo "> Archives found: ${#ARCHIVES[@]}";

if [[ "${#ARCHIVES[@]}" -eq 0 ]]; then
  echo ">> No archives available. Data cannot be updated.";
  echo ">> Data is up-to-date (based on deployed data only).";
  exit 0;
fi

# Check if any archive has data that extends beyond the deployed last departure
ARCHIVE_HAS_NEWER_DATA=false;

# Find archives and check them
for ARCHIVE in "${ARCHIVES[@]}" ; do
  ARCHIVE_BASENAME=$(basename "$ARCHIVE");
  ARCHIVE_BASENAME_NO_EXT="${ARCHIVE_BASENAME%.*}";
  
  # Validate archive date format
  if ! [[ "$ARCHIVE_BASENAME_NO_EXT" =~ ^[0-9]{8}-[0-9]{8}$ ]]; then
    echo "> Archive: $ARCHIVE_BASENAME";
    echo "  - WARNING: Archive filename doesn't match expected format (YYYYMMDD-YYYYMMDD.zip)";
    continue;
  fi
  
  ARCHIVE_START_DATE=${ARCHIVE_BASENAME_NO_EXT:0:8}
  ARCHIVE_END_DATE=${ARCHIVE_BASENAME_NO_EXT:9:8}
  echo "> Archive: $ARCHIVE_BASENAME (${ARCHIVE_START_DATE} to ${ARCHIVE_END_DATE})";
  
  # Convert archive end date (YYYYMMDD) to timestamp at end of day (23:59:59)
  ARCHIVE_END_TIMESTAMP=$(date -d "${ARCHIVE_END_DATE} 23:59:59" +%s 2>/dev/null);
  
  if [[ -n "$ARCHIVE_END_TIMESTAMP" ]]; then
    echo "  - Archive end timestamp: $ARCHIVE_END_TIMESTAMP";
    # If archive has data beyond what's currently deployed, we need to sync
    if [[ "$ARCHIVE_END_TIMESTAMP" -gt "$DEPLOYED_LAST_DEPARTURE_SEC" ]]; then
      echo "  - Archive has newer data than deployed!";
      ARCHIVE_HAS_NEWER_DATA=true;
      break; # Found newer data, no need to check other archives
    fi
  fi
done
# ARCHIVES_COUNT=$(find "$ARCHIVE_DIR" -name "*.zip" -type f 2>/dev/null | wc -l);
# echo "> Archives found: $ARCHIVES_COUNT";
#
# if [[ "$ARCHIVES_COUNT" -eq 0 ]]; then
#   echo ">> No archives available. Data cannot be updated.";
#   echo ">> Data is up-to-date (based on deployed data only).";
#   exit 0;
# fi
#
# # Check if any archive has data that extends beyond the deployed last departure
# ARCHIVE_HAS_NEWER_DATA=false;
#
# # Find archives and check them
# mapfile -t ARCHIVES < <(find "$ARCHIVE_DIR" -name "*.zip" -type f | sort)
# if [[ "${#ARCHIVES[@]}" -gt 0 ]]; then
#   for ARCHIVE in "${ARCHIVES[@]}" ; do
#     ARCHIVE_BASENAME=$(basename "$ARCHIVE");
#     ARCHIVE_BASENAME_NO_EXT="${ARCHIVE_BASENAME%.*}";
#     ARCHIVE_BASENAME_NO_EXT_PARTS=(${ARCHIVE_BASENAME_NO_EXT//-/ });
#     ARCHIVE_START_DATE=${ARCHIVE_BASENAME_NO_EXT_PARTS[0]};
#     ARCHIVE_END_DATE=${ARCHIVE_BASENAME_NO_EXT_PARTS[1]};
#    
#     echo "> Archive: $ARCHIVE_BASENAME (${ARCHIVE_START_DATE} to ${ARCHIVE_END_DATE})";
#
#     # Validate archive date format
#     if [[ -z "$ARCHIVE_START_DATE" ]] || [[ -z "$ARCHIVE_END_DATE" ]]; then
#       echo "  - WARNING: Archive filename doesn't match expected format (YYYYMMDD-YYYYMMDD.zip)";
#       continue;
#     fi
#    
#     # Convert archive end date (YYYYMMDD) to timestamp at end of day (23:59:59)
#     ARCHIVE_END_TIMESTAMP=$(date -d "${ARCHIVE_END_DATE} 23:59:59" +%s 2>/dev/null);
#    
#     if [[ -n "$ARCHIVE_END_TIMESTAMP" ]]; then
#       echo "  - Archive end timestamp: $ARCHIVE_END_TIMESTAMP";
#       # If archive has data beyond what's currently deployed, we need to sync
#       if [[ "$ARCHIVE_END_TIMESTAMP" -gt "$DEPLOYED_LAST_DEPARTURE_SEC" ]]; then
#         echo "  - Archive has newer data than deployed!";
#         ARCHIVE_HAS_NEWER_DATA=true;
#       fi
#     fi
#   done
# fi

# Determine if data is outdated based on archive availability
if [[ "$ARCHIVE_HAS_NEWER_DATA" == true ]]; then
  echo ">> Archive contains newer data. Data is OUTDATED. Sync recommended.";
  exit 1; # Exit code 1 indicates data is outdated
else
  echo ">> Data is up-to-date.";
  exit 0; # Exit code 0 indicates data is current
fi
