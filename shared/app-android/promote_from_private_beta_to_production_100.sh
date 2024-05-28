#!/bin/bash
# --from-track Beta (Private) == DEFAULT
SCRIPT_DIR="$(dirname "$0")";
source "${SCRIPT_DIR}"/../commons/commons.sh;

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

setGitProjectName $SCRIPT_DIR/../;
CONFIG_PATH="$SCRIPT_DIR/../config";
if [[ $GIT_PROJECT_NAME == *"-gradle"* ]]; then # OLD REPO
  CONFIG_PATH="$SCRIPT_DIR/config";
fi

if [[ ! -f "$CONFIG_PATH/store/production" ]]; then
    echo "> Publish production NOT authorized!";
    exit 1; # error
fi

./promote.sh --promote-track production --user-fraction 1.00 --release-status completed;
