#!/bin/bash
source ../commons/commons.sh;

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

if [[ ! -f "./config/store/production" ]]; then
    echo "> Publish to production NOT authorized!";
    exit 1; # error
fi

./publish.sh --track production --user-fraction 1.0 --release-status completed
