#!/bin/bash
if [[ -z "${ANDROID_HOME}" ]]; then
    echo "ANDROID_HOME not set!";
    exit 1;
fi
PIDCAT="${ANDROID_HOME}/pidcat.py";
if [ ! -f "$PIDCAT" ]; then
    echo "$PIDCAT does NOT exists."
    exists 1;
fi
