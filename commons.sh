#!/bin/bash

# DEPRECATED: use sh/commons.sh
# TODO: remove after a while (used in many places)

SCRIPT_DIR="$(dirname "$0")";
exec "${SCRIPT_DIR}/sh/commons.sh" "$@";
