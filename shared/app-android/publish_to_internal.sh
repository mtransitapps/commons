#!/bin/bash
source ../commons/commons.sh;

setPushToStoreEnabled;
if [[ ${MT_PUSH_STORE_ENABLED} != true ]]; then
  echo "> Push to Store NOT enabled... SKIP ($MT_PUSH_STORE_ENABLED)";
  exit 1; # error
fi
echo "> Push to Store enabled...";

if [[ ! -f "./config/store/internal" ]]; then
    echo "> Publish to internal NOT authorized!";
    exit 1; # error
fi

./publish.sh --track internal --user-fraction 1.0 --release-status completed
