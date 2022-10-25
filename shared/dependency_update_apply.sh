#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> DEPENDENCY UPDATE > APPLY...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

CONFIRM=false;

setIsCI;

setGradleArgs;

UPDATES_FILE="commons/gradle.libs.versions.updates.toml";

if [[ -f "$UPDATES_FILE" ]]; then
  echo "----------------------------------------------------------------------";
  cat $UPDATES_FILE;
  echo "----------------------------------------------------------------------";
else
  echo "> Can NOT apply update w/o running check 1st!";
  exit 1;
fi

./gradlew versionCatalogApplyUpdatesLibs ${GRADLE_ARGS};
checkResult $?;

VERSION_FILE="gradle.libs.versions.toml";
git -C commons diff $VERSION_FILE;

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> DEPENDENCY UPDATE > APPLY... DONE";
echo "================================================================================";