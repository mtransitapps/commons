#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../../.."; ROOT_DIR=$(realpath --relative-to="$PWD" "$ROOT_DIR");

source "${ROOT_DIR}/commons/sh/commons.sh";

setPushToStoreEnabled;
if [[ ${MT_PUSH_STORE_ENABLED} != true ]]; then
  echo "> Push to Store NOT enabled... SKIP ($MT_PUSH_STORE_ENABLED)";
  exit 1; # error
fi
echo "> Push to Store enabled...";

setPushToStoreProductionEnabled;
if [[ ${MT_PUSH_STORE_PRODUCTION_ENABLED} != true ]]; then
  echo "> Push to Store Production NOT enabled... SKIP ($MT_PUSH_STORE_PRODUCTION_ENABLED)";
  exit 1; # error
fi
echo "> Push to Store Production enabled...";

setGitProjectName "${ROOT_DIR}";
CONFIG_PATH="$ROOT_DIR/config";

if [[ ! -f "$CONFIG_PATH/store/production" ]]; then
    echo "> Publish to production NOT authorized!";
    exit 1; # error
fi

${SCRIPT_DIR}/promote.sh \
  --promote-track production \
  --release-status inProgress --user-fraction 0.33 \
  --from-track internal \
;
