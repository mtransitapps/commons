#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";

set -e

REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
REPO="mtransitapps/${REPO_NAME}"

source ./$SCRIPT_DIR/download_latest_apk.sh "$REPO"

if [[ -z "$APK_FILE" ]]; then
  echo ">> ERROR: no APK file!"
  exit 1 # error
fi

export MODULE_APK_FILE="$APK_FILE"
echo "MODULE_APK_FILE: '$MODULE_APK_FILE'."
