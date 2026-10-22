#!/bin/bash

# DEPRECATED: use sh/git_sync.sh
# TODO: remove after update mtransitapps/gh-actions/.github/actions/setup)

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/sh/git_sync.sh" "$@";
