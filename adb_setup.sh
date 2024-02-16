#!/bin/bash
if [[ -z "${ANDROID_HOME}" ]]; then
    echo "ANDROID_HOME not set!";
    exit 1;
fi
ADB="${ANDROID_HOME}/platform-tools/adb";
if [ ! -f "$ADB" ]; then
    echo "$ADB does NOT exists."
    exists 1;
fi
