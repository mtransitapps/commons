#!/bin/bash

# DEPRECATED: use sh/ci/push_commits.sh instead
# TODO: remove after update /.github/workflows/*.yml updated)

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/sh/ci/push_commits.sh" "$@";
