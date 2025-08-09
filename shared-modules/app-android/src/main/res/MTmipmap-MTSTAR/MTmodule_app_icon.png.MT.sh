#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";

ROOT_DIR="$SCRIPT_DIR/../../../../../../..";
COMMONS_DIR="${ROOT_DIR}/commons";
source ${COMMONS_DIR}/commons.sh;

setIsCI;

setGitProjectName;

echo ">> Generating mipmap-*/module_app_icon.png...";

APP_ANDROID_DIR="${ROOT_DIR}/app-android";
SRC_DIR="${APP_ANDROID_DIR}/src";
MAIN_DIR="${SRC_DIR}/main";
RES_DIR="${MAIN_DIR}/res";

REQUIRED_ICON_FILE="${MAIN_DIR}/play/listings/en-US/graphics/icon/1.png";
if [ ! -f "$REQUIRED_ICON_FILE" ]; then
    $ROOT_DIR/commons/shared-modules/app-android/src/main/play/listings/en-US/graphics/icon/MT1.png.MT.sh;
    checkResult $?;
fi

FILE_NAME="module_app_icon.png";

MIPMAP_MDPI="${RES_DIR}/mipmap-mdpi";
FILE_PNG="${MIPMAP_MDPI}/${FILE_NAME}";
mkdir -p "${MIPMAP_MDPI}";
checkResult $?;
if [ -f "${FILE_PNG}" ]; then
  echo ">> File '$FILE_PNG' already exist."; # compat with existing mipmap-*/module_app_icon.png
  exit 0; # compat w/ manually created file
fi
rm -f "${FILE_PNG}";
checkResult $?;

MIPMAP_HDPI="${RES_DIR}/mipmap-hdpi";
FILE_PNG="${MIPMAP_HDPI}/${FILE_NAME}";
mkdir -p "${MIPMAP_HDPI}";
checkResult $?;
if [ -f "${FILE_PNG}" ]; then
  echo ">> File '$FILE_PNG' already exist."; # compat with existing mipmap-*/module_app_icon.png
  exit 0; # compat w/ manually created file
fi
rm -f "${FILE_PNG}";
checkResult $?;

MIPMAP_XHDPI="${RES_DIR}/mipmap-xhdpi";
FILE_PNG="${MIPMAP_XHDPI}/${FILE_NAME}";
mkdir -p "${MIPMAP_XHDPI}";
checkResult $?;
if [ -f "${FILE_PNG}" ]; then
  echo ">> File '$FILE_PNG' already exist."; # compat with existing mipmap-*/module_app_icon.png
  exit 0; # compat w/ manually created file
fi
rm -f "${FILE_PNG}";
checkResult $?;

MIPMAP_XXHDPI="${RES_DIR}/mipmap-xxhdpi";
FILE_PNG="${MIPMAP_XXHDPI}/${FILE_NAME}";
mkdir -p "${MIPMAP_XXHDPI}";
checkResult $?;
if [ -f "${FILE_PNG}" ]; then
  echo ">> File '$FILE_PNG' already exist."; # compat with existing mipmap-*/module_app_icon.png
  exit 0; # compat w/ manually created file
fi
rm -f "${FILE_PNG}";
checkResult $?;

MIPMAP_XXXHDPI="${RES_DIR}/mipmap-xxxhdpi";
FILE_PNG="${MIPMAP_XXXHDPI}/${FILE_NAME}";
mkdir -p "${MIPMAP_XXXHDPI}";
checkResult $?;
if [ -f "${FILE_PNG}" ]; then
  echo ">> File '$FILE_PNG' already exist."; # compat with existing mipmap-*/module_app_icon.png
  exit 0; # compat w/ manually created file
fi
rm -f "${FILE_PNG}";
checkResult $?;

$ROOT_DIR/commons-android/pub/module-res-mipmap-launcher-icon.sh;
checkResult $?;

echo ">> Generating mipmap-*/module_app_icon.png... DONE";