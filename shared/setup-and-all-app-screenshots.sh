#!/bin/bash

# DEPRECATED: use sh/ci/setup-and-all-app-screenshots.sh instead
# TODO: remove after update /.github/workflows/*.yml updated)

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/sh/ci/setup-and-all-app-screenshots.sh" "$@";
