#!/bin/bash

# DEPRECATED: use sh/init_cache_key.sh instead
# TODO: remove after CircleCI & GitLab CI configurations updated

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/sh/init_cache_key.sh" "$@";
