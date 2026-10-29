#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR=$(cd "${SCRIPT_DIR}/../../.." && pwd)

"${ROOT_DIR}/gradlew" :app-android:installRelease --no-scan -PuseGooglePlayUploadKeysProperties=false;