#!/bin/bash
# Setup script for recording screenshots
# This script:
# 1. Downloads and installs the main mtransit-for-android app
# 2. Grants location permission to the main app
# 3. Installs the current repository's module app
# 4. Calls the screenshot recording script

set -e

echo ">> Setup and record screenshots..."

# Get the script directory
SCRIPT_DIR="$(dirname "$0")"

# Constants
MAIN_APP_PACKAGE="org.mtransit.android"
MAIN_APP_REPO="mtransitapps/mtransit-for-android"

echo ">> Step 1: Download and install main mtransit app..."

# Get the latest release APK URL from GitHub
LATEST_RELEASE_URL="https://api.github.com/repos/${MAIN_APP_REPO}/releases/latest"
echo " - Fetching latest release info from: $LATEST_RELEASE_URL"

# Download release info and extract APK URL
APK_URL=$(curl -s "$LATEST_RELEASE_URL" | grep "browser_download_url.*\.apk" | head -1 | cut -d '"' -f 4)

if [ -z "$APK_URL" ]; then
  echo " > ERROR: Could not find APK in latest release"
  exit 1
fi

echo " - Found APK: $APK_URL"
echo " - Downloading..."

# Download the APK
APK_FILE="/tmp/mtransit-main.apk"
curl -L -o "$APK_FILE" "$APK_URL"

if [ ! -f "$APK_FILE" ]; then
  echo " > ERROR: Failed to download APK"
  exit 1
fi

echo " - Installing main app..."
adb install -r -d "$APK_FILE"

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

echo ">> Step 3: Install current repository module app..."

# Get the current repository name from git
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
echo " - Repository: $REPO_NAME"

# Get the package name from config/pkg if it exists
CONFIG_PKG_FILE="config/pkg"
if [ -f "$CONFIG_PKG_FILE" ]; then
  MODULE_PACKAGE=$(cat "$CONFIG_PKG_FILE")
  echo " - Module package: $MODULE_PACKAGE"
  
  # Get the latest release APK for this module
  MODULE_REPO="mtransitapps/${REPO_NAME}"
  MODULE_RELEASE_URL="https://api.github.com/repos/${MODULE_REPO}/releases/latest"
  echo " - Fetching module release info from: $MODULE_RELEASE_URL"
  
  MODULE_APK_URL=$(curl -s "$MODULE_RELEASE_URL" | grep "browser_download_url.*\.apk" | head -1 | cut -d '"' -f 4)
  
  if [ -n "$MODULE_APK_URL" ]; then
    echo " - Found module APK: $MODULE_APK_URL"
    echo " - Downloading..."
    
    MODULE_APK_FILE="/tmp/mtransit-module.apk"
    curl -L -o "$MODULE_APK_FILE" "$MODULE_APK_URL"
    
    echo " - Installing module app..."
    adb install -r -d "$MODULE_APK_FILE"
    
    # Verify installation
    if adb shell pm list packages | grep -q "^package:${MODULE_PACKAGE}$"; then
      echo " - Module app installed successfully"
    else
      echo " > WARNING: Module app installation may have failed"
    fi
  else
    echo " > WARNING: Could not find module APK in latest release, skipping module installation"
  fi
else
  echo " > WARNING: No config/pkg file found, skipping module installation"
fi

echo ">> Step 4: Record screenshots..."

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
