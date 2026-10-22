#!/bin/bash

# DEPRECATED: use app-android/sh/lint_only.sh instead
# TODO: remove after update /.github/workflows/mt-build.yml updated)

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/app-android/sh/lint_only.sh" "$@";
