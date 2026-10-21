#!/bin/bash

# DEPRECATED: use sh/gh_repo_update_details.sh instead
# TODO: remove after update /.github/workflows/mt-record-screenshots.yml updated)

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/sh/gh_repo_update_details.sh" "$@";