#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";

ROOT_DIR="$SCRIPT_DIR/../../../../../..";
COMMONS_DIR="${ROOT_DIR}/commons";
source ${COMMONS_DIR}/commons.sh;

echo "Generating contact-website.txt...";

APP_ANDROID_DIR="${ROOT_DIR}/app-android";
SRC_DIR="${APP_ANDROID_DIR}/src";
MAIN_DIR="${SRC_DIR}/main";
PLAY_DIR="${MAIN_DIR}/play";
CONTACT_WEBSITE_FILE="${PLAY_DIR}/contact-website.txt";
mkdir -p "${PLAY_DIR}";
checkResult $?;
if [ -f "${CONTACT_WEBSITE_FILE}" ]; then
  echo "File already exist."; # compat with existing contact-website.txt
  exit 0;
fi

rm -f "${CONTACT_WEBSITE_FILE}";
checkResult $?;
touch "${CONTACT_WEBSITE_FILE}";
checkResult $?;

GIT_REMOTE_URL=$(git config --get remote.origin.url); # git@github.com:owner/repo.git
if [ -z "$GIT_REMOTE_URL" ]; then
    echo "No remote git URL available!";
    exit 1;
fi
GIT_OWNER_REPO=$(echo "$GIT_REMOTE_URL" | cut -d: -f2 | cut -d. -f1);
if [ -z "$GIT_OWNER_REPO" ]; then
    echo "Remote git URL '$GIT_REMOTE_URL' format unexpected!";
    exit 1;
fi
CONTACT_WEBITE_URL="https://github.com/$GIT_OWNER_REPO"
echo "Contact webste URL: '$CONTACT_WEBITE_URL'.";

echo "$CONTACT_WEBITE_URL" > "${CONTACT_WEBSITE_FILE}";
checkResult $?;

echo "Generating contact-website.txt... DONE";