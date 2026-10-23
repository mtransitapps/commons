#!/bin/bash

# DEPRECATED: use agency-parser/sh/validate_and_parse_current.sh instead
# TODO: remove after update /.github/workflows/mt-sync-code-data.yml updated)

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/agency-parser/sh/validate_and_parse_current.sh" "$@";
