#!/bin/bash

# DEPRECATED: use sh/ci/init_cache_key.sh instead
# TODO: remove after CircleCI & GitLab CI configurations updated

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/sh/ci/init_cache_key.sh" "$@";
