#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR="${SCRIPT_DIR}/../../.."; ROOT_DIR=$(realpath --relative-to="$PWD" "$ROOT_DIR");

"${ROOT_DIR}/gradlew" :app-android:installDebug;