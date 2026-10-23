#!/bin/bash

# DEPRECATED: use agency-parser/sh/prepare_only.sh
# TODO: remove after a while (used in mt-sync-code-data.yml)

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/agency-parser/sh/prepare_only.sh" "$@";
