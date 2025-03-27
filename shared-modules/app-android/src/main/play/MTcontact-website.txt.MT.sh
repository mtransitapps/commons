#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";

ROOT_DIR="$SCRIPT_DIR/../../../../../..";
COMMONS_DIR="${ROOT_DIR}/commons";
source ${COMMONS_DIR}/commons.sh;

setGitProjectName;

setIsCI;

echo "Generating contact-website.txt...";

APP_ANDROID_DIR="${ROOT_DIR}/app-android";
SRC_DIR="${APP_ANDROID_DIR}/src";
MAIN_DIR="${SRC_DIR}/main";
PLAY_DIR="${MAIN_DIR}/play";
CONTACT_WEBSITE_FILE="${PLAY_DIR}/contact-website.txt";
mkdir -p "${PLAY_DIR}";
checkResult $?;
if [ -f "${CONTACT_WEBSITE_FILE}" ]; then
  echo "File '$CONTACT_WEBSITE_FILE' already exist."; # compat with existing contact-website.txt
  exit 0;
fi

rm -f "${CONTACT_WEBSITE_FILE}";
checkResult $?;
touch "${CONTACT_WEBSITE_FILE}";
checkResult $?;

GIT_OWNER="mtransitapps"; #TODO extract from GIT_REMOTE_URL=$(git config --get remote.origin.url); # 'git@github.com:owner/repo.git' or 'https://github.com/owner/repo'.
CONTACT_WEBITE_URL="https://github.com/$GIT_OWNER/$PROJECT_NAME";

echo "$CONTACT_WEBITE_URL" > "${CONTACT_WEBSITE_FILE}";
checkResult $?;

if [[ ${IS_CI} = true ]]; then
  echo "---------------------------------------------------------------------------------------------------------------"
  cat "${CONTACT_WEBSITE_FILE}"; #DEBUG
  echo "---------------------------------------------------------------------------------------------------------------"
fi

echo "Generating contact-website.txt... DONE";