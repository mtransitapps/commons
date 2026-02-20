#!/bin/bash
set -e
echo ">> Downloading '$*' latest release APK..."

REPO=$1;

if [[ -z $REPO ]]; then
  echo ">> Downloading latest release APK... ERROR (no repo provided)!"
  exit 1 #error
fi

REPO_NAME=$(basename "$REPO")

RELEASE_URL="https://api.github.com/repos/${REPO}/releases/latest"
echo "Fetching latest '$REPO_NAME' repository release info from: '$RELEASE_URL'"

RESPONSE=$(curl -f -s "$RELEASE_URL" 2>/dev/null)

if [ $? -ne 0 ]; then
  echo "ERROR: Could not fetch release info!"
  exit 1 #error
fi

APK_URL=$(echo "$RESPONSE" | grep "browser_download_url.*\.apk" | head -1 | cut -d '"' -f 4)

if [ -z "$APK_URL" ]; then
  echo "ERROR: Could not find APK in latest release!"
  exit 1 #error
fi

APK_FILE=$(basename "$APK_URL")

echo "Downloading '$APK_URL' to '$APK_FILE'..."
curl -f -L -o "$APK_FILE" "$APK_URL"
if [ ! -f "$APK_FILE" ] || [ ! -s "$APK_FILE" ]; then
  echo "ERROR: Failed to download module APK or file is empty!"
  exit 1 #error
fi

export APK_FILE="$APK_FILE"

echo "'$REPO' latest release APK downloaded successfully to '$APK_FILE'."

echo ">> Downloading '$*' latest release APK... DONE"