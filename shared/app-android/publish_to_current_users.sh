#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source "${SCRIPT_DIR}"/../commons/commons.sh;
# Current user == track w/ most visibility (production OR private beta)
echo ">> Publishing to all current users...";

setPushToStoreEnabled;
if [[ ${MT_PUSH_STORE_ENABLED} != true ]]; then
  echo "> Push to Store NOT enabled... SKIP ($MT_PUSH_STORE_ENABLED)";
  exit 0 # success
fi
echo "> Push to Store enabled...";

setGitProjectName $SCRIPT_DIR/../;
CONFIG_PATH="$SCRIPT_DIR/../config";
if [[ $GIT_PROJECT_NAME == *"-gradle"* ]]; then # OLD REPO
  CONFIG_PATH="$SCRIPT_DIR/config";
fi

if [[ -f "$CONFIG_PATH/store/production" ]]; then
    echo "> Current users == production.";
    $SCRIPT_DIR/publish_to_production_100.sh;
    exit $?;
elif [[ -f "$CONFIG_PATH/store/beta-private" ]]; then
    if [[ -f "$CONFIG_PATH/store/alpha" ]]; then
        echo "> Current users == alpha + private-beta.";
        $SCRIPT_DIR/publish_to_alpha.sh;
        RESULT=$?;
        if [[ ${RESULT} != 0 ]]; then
            exit ${RESULT};
        fi
        $SCRIPT_DIR/promote_from_alpha_to_private_beta.sh;
        exit $?;
    else
        echo "> Current users == private-beta.";
        $SCRIPT_DIR/publish_to_private_beta.sh;
        exit $?;
    fi
elif [[ -f "$CONFIG_PATH/store/alpha" ]]; then
    echo "> Current users == alpha.";
    $SCRIPT_DIR/publish_to_alpha.sh;
    exit $?;
else
    echo "> Current users NOT found!";
    exit 1; # error
fi


echo ">> Publishing to all current users... DONE";