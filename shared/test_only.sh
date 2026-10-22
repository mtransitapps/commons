#!/bin/bash

# DEPRECATED: use sh/ci/test_only.sh instead
# TODO: remove after update /.github/workflows/*.yml updated)

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/sh/ci/test_only.sh" "$@";
