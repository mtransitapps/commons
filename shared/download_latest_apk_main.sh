#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";

set -e

REPO_NAME="mtransit-for-android"
REPO="mtransitapps/$REPO_NAME"

source ./$SCRIPT_DIR/download_latest_apk.sh "$REPO"

if [[ -z "$APK_FILE" ]]; then
  echo ">> ERROR: no APK file!"
  exit 1 # error
fi

export MAIN_APK_FILE="$APK_FILE"
echo "MAIN_APK_FILE: '$MAIN_APK_FILE'."
