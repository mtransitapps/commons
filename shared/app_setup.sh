#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"

if [ "$1" = "debug" ]; then
  DEBUG=true;
else
  DEBUG=false;
fi

APP_ANDROID_DIR="${SCRIPT_DIR}/app-android";
CONFIG_DIR="${APP_ANDROID_DIR}/config";
CONFIG_PKG_FILE="${CONFIG_DIR}/pkg";
APP_PKG=""
if [ -f "$CONFIG_PKG_FILE" ]; then
  APP_PKG=$(cat "$CONFIG_PKG_FILE")
  if [ "$DEBUG" = true ]; then
    APP_PKG="$APP_PKG.debug" #DEBUG
  fi
else
  echo " > No PKG config file! (file:$CONFIG_PKG_FILE)"
  exit 1 #error
fi
echo "PKG: '$APP_PKG'."
if [[ -z "${APP_PKG}" ]]; then
    echo "APP_PKG not set!";
    exit 1;
fi