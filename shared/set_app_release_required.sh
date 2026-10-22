#!/bin/bash

# DEPRECATED: use sh/ci/set_app_release_required.sh instead
# TODO: remove after update /.github/workflows/*.yml updated)

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/sh/ci/set_app_release_required.sh" "$@";
