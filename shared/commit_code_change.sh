#!/bin/bash

# DEPRECATED: use sh/git/commit_code_change.sh instead
# TODO: remove after update /.github/workflows/mt-[download-data|sync-code|sync-code-data].yml updated)

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/sh/git/commit_code_change.sh" "$@";
