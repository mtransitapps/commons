#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../../.."; ROOT_DIR=$(realpath --relative-to="$ROOT_DIR" "$ROOT_DIR");

source "${ROOT_DIR}/commons/sh/commons.sh";

setPushToStoreEnabled;
if [[ ${MT_PUSH_STORE_ENABLED} != true ]]; then
  echo "> Push to Store NOT enabled... SKIP ($MT_PUSH_STORE_ENABLED)";
  exit 1; # error
fi
echo "> Push to Store enabled...";

setPushToStoreAlphaEnabled;
if [[ ${MT_PUSH_STORE_ALPHA_ENABLED} != true ]]; then
  echo "> Push to Store Alpha NOT enabled... SKIP ($MT_PUSH_STORE_ALPHA_ENABLED)";
  exit 1; # error
fi
echo "> Push to Store Alpha enabled...";

setGitProjectName "${ROOT_DIR}";
CONFIG_PATH="$ROOT_DIR/config";

if [[ ! -f "$CONFIG_PATH/store/alpha" ]]; then
    echo "> Publish to alpha NOT authorized!";
    exit 1; # error
fi

${SCRIPT_DIR}/publish.sh \
  --track alpha \
  --release-status completed --user-fraction 1.00 \
;
