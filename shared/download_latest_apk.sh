#!/bin/bash

# DEPRECATED: use app-android/sh/download_latest_apk.sh instead
# TODO: remove after update /.github/workflows/mt-record-screenshot.yml updated)

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/app-android/sh/download_latest_apk.sh" "$@";
