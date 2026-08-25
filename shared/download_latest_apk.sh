#!/bin/bash
set -e
echo ">> Downloading '$*' latest release APK..."

REPO=$1;

if [[ -z $REPO ]]; then
  echo ">> Downloading latest release APK... ERROR (no repo provided)!"
  exit 1 #error
fi

REPO_NAME=$(basename "$REPO")

echo "Fetching latest '$REPO_NAME' repository release APK from: '$REPO'"

if ! APK_FILE_LIST=$(gh release view -R "$REPO" --json assets --jq '.assets[] | select(.name | endswith(".apk")) | .name'); then
  echo "ERROR: Failed to fetch release info from GitHub!"
  exit 1 #error
fi

if [[ -z "$APK_FILE_LIST" ]]; then
  echo "ERROR: Could not find APK in latest release!"
  exit 1 #error
fi

read -r APK_FILE <<< "$APK_FILE_LIST"

if [[ -z "$APK_FILE" ]]; then
  echo "ERROR: Could not find APK in latest release!"
  exit 1 #error
fi

echo "Downloading '$APK_FILE'..."
if ! gh release download -R "$REPO" --pattern "$APK_FILE" >/dev/null; then
  echo "ERROR: Could not download APK from latest release!"
  exit 1 #error
fi
if [ ! -f "$APK_FILE" ] || [ ! -s "$APK_FILE" ]; then
  echo "ERROR: Failed to download module APK or file is empty!"
  exit 1 #error
fi

export APK_FILE="$APK_FILE"

echo "'$REPO' latest release APK downloaded successfully to '$APK_FILE'."

echo ">> Downloading '$*' latest release APK... DONE"