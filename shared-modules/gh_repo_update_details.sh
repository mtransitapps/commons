#!/bin/bash

# DEPRECATED: use sh/gh_repo_update_details.sh instead
# TODO: remove after update /.github/workflows/mt-gh-repo-update-details.yml updated)

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/sh/gh_repo_update_details.sh" "$@";