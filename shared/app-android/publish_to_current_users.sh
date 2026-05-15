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

setGitProjectName "${SCRIPT_DIR}/../";
CONFIG_PATH="$SCRIPT_DIR/../config";
if [[ "$GIT_PROJECT_NAME" == *"-gradle"* ]]; then # OLD REPO
  CONFIG_PATH="$SCRIPT_DIR/config";
fi

# TODO sequential algo from internal to production, with checks at each step (alpha, private beta, production) and publish to the track if it exists in config (if not, skip to next track), first track publish and other track promote
if [[ -f "$CONFIG_PATH/store/production" ]]; then
  if [[ -f "$CONFIG_PATH/store/beta-private" ]]; then
    if [[ -f "$CONFIG_PATH/store/alpha" ]]; then
      if [[ -f "$CONFIG_PATH/store/internal" ]]; then
        echo "> Current users == internal + alpha + private-beta + production.";
        $SCRIPT_DIR/publish_to_internal.sh || exit 1; #error
        $SCRIPT_DIR/promote_from_internal_to_alpha.sh || exit 1; #error
        $SCRIPT_DIR/promote_from_alpha_to_private_beta.sh || exit 1; #error
        $SCRIPT_DIR/promote_from_private_beta_to_production_100.sh || exit 1; #error
      else # no internal
        echo "> Current users == alpha + private-beta + production.";
        $SCRIPT_DIR/publish_to_alpha.sh || exit 1; #error
        $SCRIPT_DIR/promote_from_alpha_to_private_beta.sh || exit 1; #error
        $SCRIPT_DIR/promote_from_private_beta_to_production_100.sh || exit 1; #error
      fi
    else # no alpha
      if [[ -f "$CONFIG_PATH/store/internal" ]]; then
        echo "> Current users == internal + private-beta + production.";
        $SCRIPT_DIR/publish_to_internal.sh || exit 1; #error
        $SCRIPT_DIR/promote_from_internal_to_private_beta.sh || exit 1; #error
        $SCRIPT_DIR/promote_from_private_beta_to_production_100.sh || exit 1; #error
      else # no internal
        echo "> Current users == private-beta + production.";
        $SCRIPT_DIR/publish_to_private_beta.sh || exit 1; #error
        $SCRIPT_DIR/promote_from_private_beta_to_production_100.sh || exit 1; #error
      fi
    fi
  else # no private beta
    if [[ -f "$CONFIG_PATH/store/alpha" ]]; then
      if [[ -f "$CONFIG_PATH/store/internal" ]]; then
        echo "> Current users == internal + alpha + production.";
        $SCRIPT_DIR/publish_to_internal.sh || exit 1; #error
        $SCRIPT_DIR/promote_from_internal_to_alpha.sh || exit 1; #error
        $SCRIPT_DIR/promote_from_alpha_to_production_100.sh || exit 1; #error
      else # no internal
        echo "> Current users == alpha + production.";
        $SCRIPT_DIR/publish_to_alpha.sh || exit 1; #error
        $SCRIPT_DIR/promote_from_alpha_to_production_100.sh || exit 1; #error
      fi
    else # no alpha
      if [[ -f "$CONFIG_PATH/store/internal" ]]; then
        echo "> Current users == internal + production.";
        $SCRIPT_DIR/publish_to_internal.sh || exit 1; #error
        $SCRIPT_DIR/promote_from_internal_to_production_100.sh || exit 1; #error
      else # no internal
        echo "> Current users == production.";
        $SCRIPT_DIR/publish_to_production_100.sh || exit 1; #error
      fi
    fi
  fi
elif [[ -f "$CONFIG_PATH/store/beta-private" ]]; then
  if [[ -f "$CONFIG_PATH/store/alpha" ]]; then
    if [[ -f "$CONFIG_PATH/store/internal" ]]; then
      echo "> Current users == internal + alpha + private-beta.";
      $SCRIPT_DIR/publish_to_internal.sh || exit 1; #error
      $SCRIPT_DIR/promote_from_internal_to_alpha.sh || exit 1; #error
      $SCRIPT_DIR/promote_from_alpha_to_private_beta.sh || exit 1; #error
    else # no internal
      echo "> Current users == alpha + private-beta.";
      $SCRIPT_DIR/publish_to_alpha.sh || exit 1; #error
      $SCRIPT_DIR/promote_from_alpha_to_private_beta.sh || exit 1; #error
    fi
  else # no alpha
    if [[ -f "$CONFIG_PATH/store/internal" ]]; then
      echo "> Current users == internal + private-beta.";
      $SCRIPT_DIR/publish_to_internal.sh || exit 1; #error
      $SCRIPT_DIR/promote_from_internal_to_private_beta.sh || exit 1; #error
    else # no internal
      echo "> Current users == private-beta.";
      $SCRIPT_DIR/publish_to_private_beta.sh || exit 1; #error
    fi
  fi
elif [[ -f "$CONFIG_PATH/store/alpha" ]]; then
  if [[ -f "$CONFIG_PATH/store/internal" ]]; then
    echo "> Current users == internal + alpha.";
    $SCRIPT_DIR/publish_to_internal.sh || exit 1; #error
    $SCRIPT_DIR/promote_from_internal_to_alpha.sh || exit 1; #error
  else # no internal
    echo "> Current users == alpha.";
    $SCRIPT_DIR/publish_to_alpha.sh || exit 1; #error
  fi
else if [[ -f "$CONFIG_PATH/store/internal" ]]; then
    echo "> Current users == internal.";
    $SCRIPT_DIR/publish_to_internal.sh || exit 1; #error
else # no internal, no alpha, no private beta, no production
  echo "> Push to Store NOT enabled... SKIP (no current users)";
  exit 0 # success
fi

echo ">> Publishing to all current users... DONE";
