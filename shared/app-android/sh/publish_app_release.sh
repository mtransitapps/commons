#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../.."; ROOT_DIR=$(realpath --relative-to="$ROOT_DIR" "$ROOT_DIR");

source "${ROOT_DIR}/commons/sh/commons.sh";

echo "================================================================================";
echo "> PUBLISH APP RELEASE (?)...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

setIsCI;

setIsGHEnabled;

setGitBranch;

setGitProjectName;

setGradleArgs;

setGitCommitEnabled;

setPushToStoreEnabled;

if [[ ${MT_GIT_COMMIT_ENABLED} != true ]]; then
  echo "> Git commit NOT enabled.. SKIP";
  exit 0 # success
fi
echo "> Git commit enabled ...";

if [[ ${MT_PUSH_STORE_ENABLED} != true ]]; then
  echo "> Push to Store NOT enabled... SKIP ($MT_PUSH_STORE_ENABLED)";
  exit 0 # success
fi
echo "> Push to Store enabled...";

MT_TEMP_DIR=".mt";
mkdir -p $MT_TEMP_DIR;
checkResult $?;
MT_APP_RELEASE_REQUIRED_FILE="$MT_TEMP_DIR/mt_app_release_required";

MT_APP_RELEASE_REQUIRED=false;
if [[ -f ${MT_APP_RELEASE_REQUIRED_FILE} ]]; then
  MT_APP_RELEASE_REQUIRED=$(cat $MT_APP_RELEASE_REQUIRED_FILE);
fi
echo "> App release required: $MT_APP_RELEASE_REQUIRED.";

if [[ "$MT_APP_RELEASE_REQUIRED" != "true" ]]; then
  echo "> App release NOT required > SKIP";
  exit 0; # ok
fi

# TAG RELEASE ON GITHUB
# Shared version name also used in https://github.com/mtransitapps/commons/blob/master/shared/app-android/build.gradle
APK_PATH="${ROOT_DIR}/app-android/build/outputs/apk/release/*.apk";
APK_PATH_APP_ANDROID="${ROOT_DIR}/build/outputs/apk/release/*.apk";
APK_FILES=($APK_PATH);
AAB_PATH="${ROOT_DIR}/app-android/build/outputs/bundle/release/*.aab";
AAB_PATH_APP_ANDROID="${ROOT_DIR}/build/outputs/bundle/release/*.aab";
AAB_FILES=($AAB_PATH);
if [ -e "${APK_FILES[0]}" ]; then
  APK_FILE_NAME=$(basename "$APK_FILES");
  echo "> APK file name: '$APK_FILE_NAME'.";
  APP_VERSION_NAME=$(echo "$APK_FILE_NAME" | sed 's/.*_v\([0-9]\{2\}\.[0-9]\{2\}\.[0-9]\{2\}_r[0-9]\+\).*/\1/');
elif [ -e "${AAB_FILES[0]}" ]; then
  AAB_FILE_NAME=$(basename "${AAB_FILES[0]}");
  echo "> AAB file name: '$AAB_FILE_NAME'.";
  APP_VERSION_NAME=$(echo "$AAB_FILE_NAME" | sed 's/.*_v\([0-9]\{2\}\.[0-9]\{2\}\.[0-9]\{2\}_r[0-9]\+\).*/\1/');
else
  echo "> Cannot find app version name w/o APK or AAB!";
  exit 1;
fi
if [[ -z "${APP_VERSION_NAME}" ]]; then
  echo "> APP_VERSION_NAME empty!";
  exit 1;
fi

function shouldCreateGitHubRelease() {
  local APP_VERSION_NAME_LOCAL=$1;
  if ! gh release view "$APP_VERSION_NAME_LOCAL" >/dev/null 2>&1; then
    return 0;
  fi
  local LATEST_RELEASE_TAG_NAME="";
  LATEST_RELEASE_TAG_NAME=$(gh release view --json tagName --jq .tagName 2>/dev/null);
  if [[ -z "$LATEST_RELEASE_TAG_NAME" ]]; then
    echo "Error: Failed to retrieve the latest release tag name from GitHub." >&2;
    exit 1;
  fi
  if [[ "$LATEST_RELEASE_TAG_NAME" == "$APP_VERSION_NAME_LOCAL" ]]; then
    return 1;
  fi
  echo "Existing release '$APP_VERSION_NAME_LOCAL' is not latest release ('$LATEST_RELEASE_TAG_NAME')." >&2;
  exit 1;
}

if [[ ${IS_GH_ENABLED} == true ]]; then
  echo "> GitHub > publishing release '$APP_VERSION_NAME'...";
  GH_FILES="";
  GH_FILES_APP_ANDROID="";
  if [ -e "${APK_FILES[0]}" ]; then
      GH_FILES+=" $APK_PATH";
      GH_FILES_APP_ANDROID+=" $APK_PATH_APP_ANDROID";
  elif [ -e "${AAB_FILES[0]}" ]; then
      GH_FILES+=" $AAB_PATH";
      GH_FILES_APP_ANDROID+=" $AAB_PATH_APP_ANDROID";
  else
      echo "> No APK/AAB";
  fi
  echo "> GH_FILES: $GH_FILES.";
  if shouldCreateGitHubRelease "$APP_VERSION_NAME"; then
    gh release create $APP_VERSION_NAME --target $GIT_BRANCH --latest --generate-notes $GH_FILES;
    checkResult $?;
  else
    echo "> GitHub > release '$APP_VERSION_NAME' already exists and is latest... SKIP";
  fi
  echo "> GitHub > publishing release '$APP_VERSION_NAME'... DONE";

  # PUSH TO PLAY STORE
  if [[ -d "app-android" ]]; then
    CURRENT_PATH=$(pwd);
    cd app-android || exit 1; # >>

    if [[ -f "${ROOT_DIR}/app-android/sh/keys/cleanup.sh" ]]; then
      "${ROOT_DIR}"/app-android/sh/keys/cleanup.sh; # FAIL OK
    fi

    "${ROOT_DIR}"/play/publish_to_current_users.sh;
    checkResult $?;

    cd ${CURRENT_PATH} || exit; # <<
  fi
else
  echo "> Use case not supported yet!"; #TODO GH release?
fi

echo "--------------------------------------------------------------------------------";
AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> PUBLISH APP RELEASE (?)... DONE";
echo "================================================================================";
