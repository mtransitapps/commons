#!/bin/bash
# --promote-track Beta (Private) == DEFAULT
source ../commons/commons.sh;

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

if [[ ! -f "./config/store/beta-private" ]]; then
    echo "> Publish to Beta Private NOT authorized!";
    exit 1; # error
fi

./promote.sh --from-track alpha --release-status completed;
