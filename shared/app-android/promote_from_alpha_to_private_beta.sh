#!/bin/bash
# --promote-track Beta (Private) == DEFAULT
SCRIPT_DIR="$(dirname "$0")";
source "${SCRIPT_DIR}"/../commons/commons.sh;

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

setGitProjectName $SCRIPT_DIR/../;
CONFIG_PATH="$SCRIPT_DIR/../config";
if [[ $GIT_PROJECT_NAME == *"-gradle"* ]]; then # OLD REPO
  CONFIG_PATH="$SCRIPT_DIR/config";
fi

if [[ ! -f "$CONFIG_PATH/store/beta-private" ]]; then
    echo "> Publish to Beta Private NOT authorized!";
    exit 1; # error
fi

./promote.sh --from-track alpha --release-status completed;
