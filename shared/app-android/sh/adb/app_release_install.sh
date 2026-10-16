#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR="${SCRIPT_DIR}/../..";

${ROOT_DIR}/gradlew :app-android:installRelease --no-scan -PuseGooglePlayUploadKeysProperties=false;