#!/bin/bash

# DEPRECATED: use app-android/sh/publish_app_release.sh
# TODO: remove after a while (used in mt-release.yml)

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/app-android/sh/publish_app_release.sh" "$@";
