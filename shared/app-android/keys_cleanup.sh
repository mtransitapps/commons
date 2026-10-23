#!/bin/bash

# DEPRECATED: use sh/keys/cleanup.sh
# TODO: remove after update /.github/workflows/mt-record-screenshots.yml updated)

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/sh/keys/cleanup.sh" "$@";
