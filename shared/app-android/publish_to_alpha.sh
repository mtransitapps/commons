#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source "${SCRIPT_DIR}"/../commons/commons.sh;

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

setGitProjectName $SCRIPT_DIR/../;
CONFIG_PATH="$SCRIPT_DIR/../config";
if [[ $GIT_PROJECT_NAME == *"-gradle"* ]]; then # OLD REPO
  CONFIG_PATH="$SCRIPT_DIR/config";
fi

if [[ ! -f "$CONFIG_PATH/store/alpha" ]]; then
    echo "> Publish to alpha NOT authorized!";
    exit 1; # error
fi

./publish.sh --track alpha --user-fraction 1.0 --release-status completed
