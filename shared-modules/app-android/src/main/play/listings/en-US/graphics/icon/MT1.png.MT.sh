#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";

ROOT_DIR="$SCRIPT_DIR/../../../../../../../../../..";
COMMONS_DIR="${ROOT_DIR}/commons";
source ${COMMONS_DIR}/commons.sh;

setIsCI;

setGitProjectName;

echo ">> Generating icon/1.png...";

APP_ANDROID_DIR="${ROOT_DIR}/app-android";
SRC_DIR="${APP_ANDROID_DIR}/src";
MAIN_DIR="${SRC_DIR}/main";
PLAY_DIR="${MAIN_DIR}/play";
LISTINGS_DIR="${PLAY_DIR}/listings";
EN_US_DIR="${LISTINGS_DIR}/en-US";
GRAPHICS_DIR="${EN_US_DIR}/graphics";
FEATURE_GRAPHIC_DIR="${GRAPHICS_DIR}/icon";
FILE_1_PNG="${FEATURE_GRAPHIC_DIR}/1.png";
mkdir -p "${FEATURE_GRAPHIC_DIR}";
checkResult $?;
if [ -f "${FILE_1_PNG}" ]; then
  if [[ ${MT_GENERATE_IMAGES} != true ]]; then
    echo ">> File '$FILE_1_PNG' already exist."; # compat with existing icon/1.png
    exit 0; # compat w/ manually created file
  else
    echo ">> File '$FILE_1_PNG' already exist: overriding image... (MT_GENERATE_IMAGES=$MT_GENERATE_IMAGES)";
  fi
fi

rm -f "${FILE_1_PNG}";
checkResult $?;

$ROOT_DIR/commons-android/pub/module-hi-res-app-icon.sh; # uses inkscape
checkResult $?;

echo ">> Generating icon/1.png... DONE";