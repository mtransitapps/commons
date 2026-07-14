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

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

if ! gh release download -R "$REPO" --pattern "*.apk" --dir "$TMP_DIR" >/dev/null; then
  echo "ERROR: Could not download APK from latest release!"
  exit 1 #error
fi

shopt -s nullglob
APK_FILES=("$TMP_DIR"/*.apk)
shopt -u nullglob

if [ ${#APK_FILES[@]} -eq 0 ]; then
  echo "ERROR: Could not find APK in latest release!"
  exit 1 #error
fi

APK_URL="${APK_FILES[0]}"
APK_FILE=$(basename "$APK_URL")

echo "Downloading '$APK_URL' to '$APK_FILE'..."
mv "$APK_URL" "$APK_FILE"
if [ ! -f "$APK_FILE" ] || [ ! -s "$APK_FILE" ]; then
  echo "ERROR: Failed to download module APK or file is empty!"
  exit 1 #error
fi

export APK_FILE="$APK_FILE"

echo "'$REPO' latest release APK downloaded successfully to '$APK_FILE'."

echo ">> Downloading '$*' latest release APK... DONE"