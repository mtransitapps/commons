#!/bin/bash

# DEPRECATED: use app-android/sh/assemble_release.sh
# TODO: remove after a while (used in many YML)

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/app-android/sh/assemble_release.sh" "$@";
