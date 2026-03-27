#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"

if [ "$1" = "debug" ]; then
  DEBUG=true
else
  DEBUG=false
fi

APP_PKG="org.mtransit.android"
if [ "$DEBUG" = true ]; then
  APP_PKG="$APP_PKG.debug" #DEBUG
fi
echo "PKG: '$APP_PKG'."

APP_ACTIVITY="org.mtransit.android.ui.SplashScreenActivity"