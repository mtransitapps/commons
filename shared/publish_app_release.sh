#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> PUBLISH APP RELEASE (?)...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

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
APK_PATH="./app-android/build/outputs/apk/release/*.apk";
APK_PATH_APP_ANDROID="./build/outputs/apk/release/*.apk";
APK_FILES=($APK_PATH);
AAB_PATH="./app-android/build/outputs/bundle/release/*.aab";
AAB_PATH_APP_ANDROID="./build/outputs/bundle/release/*.aab";
AAB_FILES=($AAB_PATH);
if [ -e "${APK_FILES[0]}" ]; then
  APK_FILE_NAME=$(basename "$APK_FILES");
  echo "APK file name: '$APK_FILE_NAME'.";
  APP_VERSION_NAME=$(echo "$APK_FILE_NAME" | sed 's/.*_v\([0-9]\{2\}\.[0-9]\{2\}\.[0-9]\{2\}_r[0-9]\+\).*/\1/');
elif [ -e "${AAB_FILES[0]}" ]; then
  ABB_FILE_NAME=$(basename "$AAB_FILES");
  echo "ABB file name: '$ABB_FILE_NAME'.";
  APP_VERSION_NAME=$(echo "$ABB_FILE_NAME" | sed 's/.*_v\([0-9]\{2\}\.[0-9]\{2\}\.[0-9]\{2\}_r[0-9]\+\).*/\1/');
else
  echo "Cannot find app version name w/o APK or ABB!";
  exit 1;
fi
if [[ -z "${APP_VERSION_NAME}" ]]; then
  echo "APP_VERSION_NAME empty!";
  exit 1;
fi
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
      echo "No APK/AAB";
  fi
  echo "GH_FILES: $GH_FILES.";
  gh release create $APP_VERSION_NAME --target $GIT_BRANCH --latest --generate-notes $GH_FILES;
  checkResult $?;
  # OLD REPO
  if [[ $GIT_PROJECT_NAME == *"-gradle"* ]]; then # OLD REPO
    if [[ -d "app-android" ]]; then
      cd app-android || exit 1; # >>
      gh release create $APP_VERSION_NAME --target $GIT_BRANCH --latest --generate-notes $GH_FILES_APP_ANDROID;
      checkResult $?;
      cd ../; # <<
    fi
  fi
  echo "> GitHub > publishing release '$APP_VERSION_NAME'... DONE";

  # PUSH TO GOOGLE PLAY STORE
  if [[ -d "app-android" ]]; then
    cd app-android || exit 1; # >>

    if [[ -f "keys_cleanup.sh" ]]; then
      ./keys_cleanup.sh; # FAIL OK
    fi

    ./publish_to_current_users.sh;
    checkResult $?;

    cd ../; # <<
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

