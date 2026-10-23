#!/bin/bash

# DEPRECATED: use sh/ci/build.sh instead
# TODO: remove after CircleCI & GitLab CI configurations updated

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/sh/ci/build.sh" "$@";
