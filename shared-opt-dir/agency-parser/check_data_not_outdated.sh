#!/bin/bash

# DEPRECATED: use sh/check_data_not_outdated.sh
# TODO: remove after update /.github/workflows/mt-download-data.yml updated)

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/sh/check_data_not_outdated.sh" "$@";
