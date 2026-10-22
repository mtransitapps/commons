#!/bin/bash

# DEPRECATED: use agency-parser/sh/list_change_ci.sh instead
# TODO: remove after update /.github/workflows/mt-sync-code-data.yml updated)

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/agency-parser/sh/list_change_ci.sh" "$@";
