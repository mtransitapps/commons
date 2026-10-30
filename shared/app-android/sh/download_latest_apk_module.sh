#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";

set -e

REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
REPO="mtransitapps/${REPO_NAME}"

if ! APK_PATH=$("$SCRIPT_DIR/download_latest_apk.sh" "$REPO"); then
  echo ">> ERROR: no APK file!"
  exit 1 # error
fi

export MODULE_APK_FILE="$APK_PATH"
echo "MODULE_APK_FILE: '$MODULE_APK_FILE'."
