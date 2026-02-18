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

# Function to get latest release APK URL from GitHub
get_latest_apk_url() {
  local repo=$1
  local release_url="https://api.github.com/repos/${repo}/releases/latest"
  
  echo " - Fetching latest release info from: $release_url"
  
  # Use -f to fail on HTTP errors and check the response
  local response=$(curl -f -s "$release_url" 2>/dev/null)
  local curl_exit_code=$?
  
  if [ $curl_exit_code -ne 0 ]; then
    echo " > ERROR: Failed to fetch release information (curl exit code: $curl_exit_code)"
    echo " > This might be due to:"
    echo "   - GitHub API rate limiting"
    echo "   - Network connectivity issues"
    echo "   - Repository not found or access denied"
    return 1
  fi
  
  local apk_url=$(echo "$response" | grep "browser_download_url.*\.apk" | head -1 | cut -d '"' -f 4)
  
  if [ -z "$apk_url" ]; then
    echo " > ERROR: Could not find APK in latest release for $repo"
    echo " > This might be due to:"
    echo "   - No releases available for this repository"
    echo "   - The release does not contain an APK file"
    return 1
  fi
  
  echo "$apk_url"
  return 0
}

echo ">> Step 1: Download and install main mtransit app..."

# Get the latest release APK URL
APK_URL=$(get_latest_apk_url "$MAIN_APP_REPO")

if [ -z "$APK_URL" ]; then
  exit 1
fi

echo " - Found APK: $APK_URL"
echo " - Downloading..."

# Download the APK to a unique temporary file
APK_FILE=$(mktemp -t mtransit-main.XXXXXX.apk)
curl -f -L -o "$APK_FILE" "$APK_URL"

if [ ! -f "$APK_FILE" ] || [ ! -s "$APK_FILE" ]; then
  echo " > ERROR: Failed to download APK or file is empty"
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

# Verify we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo " > WARNING: Not in a git repository, skipping module installation"
else
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
    MODULE_APK_URL=$(get_latest_apk_url "$MODULE_REPO")
    
    if [ -n "$MODULE_APK_URL" ]; then
      echo " - Found module APK: $MODULE_APK_URL"
      echo " - Downloading..."
      
      MODULE_APK_FILE=$(mktemp -t mtransit-module.XXXXXX.apk)
      curl -f -L -o "$MODULE_APK_FILE" "$MODULE_APK_URL"
      
      if [ ! -f "$MODULE_APK_FILE" ] || [ ! -s "$MODULE_APK_FILE" ]; then
        echo " > WARNING: Failed to download module APK or file is empty, skipping module installation"
      else
        echo " - Installing module app..."
        adb install -r -d "$MODULE_APK_FILE"
        
        # Verify installation
        if adb shell pm list packages | grep -q "^package:${MODULE_PACKAGE}$"; then
          echo " - Module app installed successfully"
        else
          echo " > WARNING: Module app installation may have failed"
        fi
      fi
    else
      echo " > WARNING: Could not find module APK in latest release, skipping module installation"
    fi
  else
    echo " > WARNING: No config/pkg file found, skipping module installation"
  fi
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
