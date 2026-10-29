#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR=$(cd "${SCRIPT_DIR}/../../.." && pwd)

if [ "$1" = "debug" ]; then
  DEBUG=true;
else
  DEBUG=false;
fi

CONFIG_DIR="${ROOT_DIR}/config";
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

APP_ACTIVITY="org.mtransit.android.commons.ui.ModuleRedirectActivity"
if [[ "$APP_PKG" = "org.mtransit.android" || "$APP_PKG" = "org.mtransit.android.debug" ]]; then
  APP_ACTIVITY="org.mtransit.android.MainActivity"
fi
echo "ACTIVITY: '$APP_ACTIVITY'."
