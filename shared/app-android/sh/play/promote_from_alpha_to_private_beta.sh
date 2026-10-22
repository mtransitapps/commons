#!/bin/bash
# --promote-track Beta (Private) == DEFAULT
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../../..";
source "${ROOT_DIR}/commons/sh/commons.sh";

setPushToStoreEnabled;
if [[ ${MT_PUSH_STORE_ENABLED} != true ]]; then
  echo "> Push to Store NOT enabled... SKIP ($MT_PUSH_STORE_ENABLED)";
  exit 1; # error
fi
echo "> Push to Store enabled...";

setPushToStoreBetaPrivateEnabled;
if [[ ${MT_PUSH_STORE_BETA_PRIVATE_ENABLED} != true ]]; then
  echo "> Push to Store Beta Private NOT enabled... SKIP ($MT_PUSH_STORE_BETA_PRIVATE_ENABLED)";
  exit 1; # error
fi
echo "> Push to Store Beta Private enabled...";

setGitProjectName "${ROOT_DIR}";
CONFIG_PATH="$ROOT_DIR/config";

if [[ ! -f "$CONFIG_PATH/store/beta-private" ]]; then
    echo "> Publish to Beta Private NOT authorized!";
    exit 1; # error
fi

${SCRIPT_DIR}/promote.sh \
  --from-track alpha \
  --release-status completed \
;
