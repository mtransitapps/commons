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

trackScriptName() {
  case "$1" in
    beta-private) echo "private_beta";;
    *) echo "$1";;
  esac
}

TRACKS=(internal alpha beta-private production)
CURRENT_USER_TRACKS=()
for track in "${TRACKS[@]}"; do
  if [[ -f "$CONFIG_PATH/store/$track" ]]; then
    CURRENT_USER_TRACKS+=("$track")
  fi
done

if [[ ${#CURRENT_USER_TRACKS[@]} -eq 0 ]]; then # no internal, no alpha, no private beta, no production
  echo "> Push to Store NOT enabled... SKIP (no current users)";
  exit 0 # success
fi

TRACKS_STR="${CURRENT_USER_TRACKS[0]}"
for (( i=1; i<${#CURRENT_USER_TRACKS[@]}; i++ )); do
  TRACKS_STR+=" + ${CURRENT_USER_TRACKS[$i]}"
done
echo "> Current users == ${TRACKS_STR}.";
FIRST_TRACK_SCRIPT_NAME="$(trackScriptName "${CURRENT_USER_TRACKS[0]}")"
if [[ "${CURRENT_USER_TRACKS[0]}" == "production" ]]; then
  "$SCRIPT_DIR"/publish_to_"${FIRST_TRACK_SCRIPT_NAME}"_100.sh || exit 1; #error
else
  "$SCRIPT_DIR"/publish_to_"${FIRST_TRACK_SCRIPT_NAME}".sh || exit 1; #error
fi

for (( i=1; i<${#CURRENT_USER_TRACKS[@]}; i++ )); do
  PREVIOUS_TRACK_SCRIPT_NAME="$(trackScriptName "${CURRENT_USER_TRACKS[$((i-1))]}")"
  CURRENT_TRACK_SCRIPT_NAME="$(trackScriptName "${CURRENT_USER_TRACKS[$i]}")"
  if [[ "${CURRENT_USER_TRACKS[$i]}" == "production" ]]; then
    "$SCRIPT_DIR"/promote_from_"${PREVIOUS_TRACK_SCRIPT_NAME}"_to_"${CURRENT_TRACK_SCRIPT_NAME}"_100.sh || exit 1; #error
  else
    "$SCRIPT_DIR"/promote_from_"${PREVIOUS_TRACK_SCRIPT_NAME}"_to_"${CURRENT_TRACK_SCRIPT_NAME}".sh || exit 1; #error
  fi
done

echo ">> Publishing to all current users... DONE";
