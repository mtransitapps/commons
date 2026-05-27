#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source "${SCRIPT_DIR}"/../commons/commons.sh;

setPushToStoreEnabled;
if [[ ${MT_PUSH_STORE_ENABLED} != true ]]; then
  echo "> Push to Store NOT enabled... SKIP ($MT_PUSH_STORE_ENABLED)";
  exit 1; # error
fi
echo "> Push to Store enabled...";

setPushToStoreInternalEnabled;
if [[ ${MT_PUSH_STORE_INTERNAL_ENABLED} != true ]]; then
  echo "> Push to Store Internal NOT enabled... SKIP ($MT_PUSH_STORE_INTERNAL_ENABLED)";
  exit 1; # error
fi
echo "> Push to Store Internal enabled...";

setGitProjectName "${SCRIPT_DIR}/../";
CONFIG_PATH="$SCRIPT_DIR/../config";
if [[ "$GIT_PROJECT_NAME" == *"-gradle"* ]]; then # OLD REPO
  CONFIG_PATH="$SCRIPT_DIR/config";
fi

if [[ ! -f "$CONFIG_PATH/store/internal" ]]; then
    echo "> Publish to internal draft NOT authorized!";
    exit 1; # error
fi

${SCRIPT_DIR}/publish.sh \
  --track internal \
  --release-status draft --user-fraction 1.00 \
;
