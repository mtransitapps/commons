#!/bin/bash
source ../commons/commons.sh;

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

if [[ ! -f "./config/store/alpha" ]]; then
    echo "> Publish to alpha NOT authorized!";
    exit 1; # error
fi

./promote.sh --from-track internal --promote-track alpha --release-status completed;
