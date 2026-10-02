#!/bin/bash
# Setup script for recording screenshots
# This script:
# 1. Installs the main mtransit-for-android app (APK path from env var)
# 2. Grants location permission to the main app
# 3. Sets GPS location based on GTFS area bounds
# 4. Installs module app(s) from MODULE_APK_FILES (newline list, item = pkg:apkPath)
# 5. Calls the screenshot recording script

set -e

echo ">> Setup and record screenshots..."

# Constants
MAIN_APP_PACKAGE="org.mtransit.android"

echo ">> Step 1: Install main mtransit app..."

if [ -z "$MAIN_APK_FILE" ]; then
  echo " > ERROR: MAIN_APK_FILE environment variable not set"
  exit 1
fi

if [ ! -f "$MAIN_APK_FILE" ]; then
  echo " > ERROR: Main APK file not found: $MAIN_APK_FILE"
  exit 1
fi

if [ -z "$MODULE_APK_FILES" ]; then
  echo " > ERROR: MODULE_APK_FILES environment variable not set"
  exit 1
fi

# Validate every MODULE_APK_FILES entry before installation.
while IFS= read -r MODULE_ENTRY; do
  [ -z "$MODULE_ENTRY" ] && continue

  if [[ "$MODULE_ENTRY" != *:* ]]; then
    echo " > ERROR: invalid MODULE_APK_FILES entry (expected pkg:apkPath): $MODULE_ENTRY"
    exit 1
  fi

  MODULE_PKG="${MODULE_ENTRY%%:*}"
  MODULE_APK="${MODULE_ENTRY#*:}"
  if [ -z "$MODULE_PKG" ] || [ -z "$MODULE_APK" ]; then
    echo " > ERROR: invalid MODULE_APK_FILES entry (empty pkg/apk): $MODULE_ENTRY"
    exit 1
  fi

  if [ ! -f "$MODULE_APK" ]; then
    echo " > ERROR: module APK file not found: $MODULE_APK"
    exit 1
  fi
done <<< "$MODULE_APK_FILES"

echo " - Installing main app from: $MAIN_APK_FILE"
adb install -r -d "$MAIN_APK_FILE"

# Verify installation
if ! adb shell pm list packages | grep -q "^package:${MAIN_APP_PACKAGE}$"; then
  echo " > ERROR: Main app installation failed"
  exit 1
fi

echo " - Main app installed successfully"

echo ">> Step 2: Grant location permission to main app..."

# Grant location permissions
adb shell pm grant "$MAIN_APP_PACKAGE" android.permission.ACCESS_FINE_LOCATION
adb shell pm grant "$MAIN_APP_PACKAGE" android.permission.ACCESS_COARSE_LOCATION

echo " - Location permissions granted"

echo ">> Step 2.5: Set emulator GPS location..."

REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
if [[ "$REPO_NAME" == "mtransit-for-android" ]]; then
  MAIN_APP_SCREENSHOT_LAT="45.5230433" # Montréal office
  MAIN_APP_SCREENSHOT_LNG="-73.5814131" # Montréal office
  echo " - Main app repo detected ('$REPO_NAME'): setting GPS to $MAIN_APP_SCREENSHOT_LAT, $MAIN_APP_SCREENSHOT_LNG"
  adb emu geo fix "$MAIN_APP_SCREENSHOT_LNG" "$MAIN_APP_SCREENSHOT_LAT"
  echo " - GPS location set successfully"
else
  # Parse GPS coordinates from XML if available
  GPS_XML_FILE="app-android/src/main/res-current/values/current_gtfs_rts_values_gen.xml"
  if [ -f "$GPS_XML_FILE" ]; then
    echo " - Found GPS coordinates file: $GPS_XML_FILE"
    
    # Extract min/max lat/lng values using xmllint
    MIN_LAT=$(xmllint --xpath "string(//resources/string[@name='current_gtfs_rts_area_min_lat']/text())" "$GPS_XML_FILE" 2>/dev/null || echo "")
    MAX_LAT=$(xmllint --xpath "string(//resources/string[@name='current_gtfs_rts_area_max_lat']/text())" "$GPS_XML_FILE" 2>/dev/null || echo "")
    MIN_LNG=$(xmllint --xpath "string(//resources/string[@name='current_gtfs_rts_area_min_lng']/text())" "$GPS_XML_FILE" 2>/dev/null || echo "")
    MAX_LNG=$(xmllint --xpath "string(//resources/string[@name='current_gtfs_rts_area_max_lng']/text())" "$GPS_XML_FILE" 2>/dev/null || echo "")
    
    if [ -n "$MIN_LAT" ] && [ -n "$MAX_LAT" ] && [ -n "$MIN_LNG" ] && [ -n "$MAX_LNG" ]; then
      # Calculate center point (average of min and max)
      CENTER_LAT=$(echo "scale=6; ($MIN_LAT + $MAX_LAT) / 2" | bc)
      CENTER_LNG=$(echo "scale=6; ($MIN_LNG + $MAX_LNG) / 2" | bc)
      
      echo " - Setting GPS location to center: $CENTER_LAT, $CENTER_LNG"
      adb emu geo fix "$CENTER_LNG" "$CENTER_LAT"
      
      echo " - GPS location set successfully"
    else
      echo " > WARNING: Could not parse GPS coordinates from XML"
    fi
  elif [ -f "app-android/src/main/res/values/bike_station_values.xml" ]; then
    BIKE_GPS_XML_FILE="app-android/src/main/res/values/bike_station_values.xml"
    echo " - Found bike station coordinates file: $BIKE_GPS_XML_FILE"
    
    # Extract min/max lat/lng values using xmllint
    MIN_LAT=$(xmllint --xpath "string(//resources/string[@name='bike_station_area_min_lat']/text())" "$BIKE_GPS_XML_FILE" 2>/dev/null || echo "")
    MAX_LAT=$(xmllint --xpath "string(//resources/string[@name='bike_station_area_max_lat']/text())" "$BIKE_GPS_XML_FILE" 2>/dev/null || echo "")
    MIN_LNG=$(xmllint --xpath "string(//resources/string[@name='bike_station_area_min_lng']/text())" "$BIKE_GPS_XML_FILE" 2>/dev/null || echo "")
    MAX_LNG=$(xmllint --xpath "string(//resources/string[@name='bike_station_area_max_lng']/text())" "$BIKE_GPS_XML_FILE" 2>/dev/null || echo "")
    
    if [ -n "$MIN_LAT" ] && [ -n "$MAX_LAT" ] && [ -n "$MIN_LNG" ] && [ -n "$MAX_LNG" ]; then
      # Calculate center point (average of min and max)
      CENTER_LAT=$(echo "scale=6; ($MIN_LAT + $MAX_LAT) / 2" | bc)
      CENTER_LNG=$(echo "scale=6; ($MIN_LNG + $MAX_LNG) / 2" | bc)
      
      echo " - Setting GPS location to center: $CENTER_LAT, $CENTER_LNG"
      adb emu geo fix "$CENTER_LNG" "$CENTER_LAT"
      
      echo " - GPS location set successfully"
    else
      echo " > WARNING: Could not parse bike station coordinates from XML"
    fi
  else
    echo " - No GPS coordinates file found, skipping GPS setup"
  fi
fi

echo ">> Step 3: Install module app(s)..."

while IFS= read -r MODULE_ENTRY; do
  [ -z "$MODULE_ENTRY" ] && continue

  MOD_PKG="${MODULE_ENTRY%%:*}"
  MOD_APK="${MODULE_ENTRY#*:}"

  echo " - Installing module '$MOD_PKG' from: $MOD_APK"
  adb install -r -d "$MOD_APK"

  if adb shell pm list packages | grep -q "^package:${MOD_PKG}$"; then
    echo " - Module '$MOD_PKG' installed successfully"
  else
    echo " > ERROR: Module '$MOD_PKG' installation may have failed!"
    exit 1
  fi
done <<< "$MODULE_APK_FILES"

echo ">> Step 4: Disable Pixel Launcher to prevent crashes..."
# Stop Pixel Launcher to prevent "not responding" dialogs during screenshot capture
adb shell am force-stop com.google.android.apps.nexuslauncher || true
adb shell pm disable-user --user 0 com.google.android.apps.nexuslauncher || true
echo " - Pixel Launcher disabled"

echo ">> Step 5: Launch main app and wait for initialization..."
# Launch the main app once to let it initialize (download data, etc.)
adb shell monkey -p org.mtransit.android -c android.intent.category.LAUNCHER 1
INIT_DURATION_IN_SEC=30
echo " - Main app launched, waiting $INIT_DURATION_IN_SEC seconds for initialization..."
sleep $INIT_DURATION_IN_SEC
echo " - Main app initialized"

echo ">> Step 6: Record screenshots..."
# Call the screenshot recording script
if [ -f "./commons-android/pub/all-app-screenshots.sh" ]; then
  ./commons-android/pub/all-app-screenshots.sh
elif [ -f "../commons-android/pub/all-app-screenshots.sh" ]; then
  ../commons-android/pub/all-app-screenshots.sh
else
  echo " > ERROR: Screenshot recording script not found"
  exit 1
fi

echo ">> Setup and record screenshots... DONE"
