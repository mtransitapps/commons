#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> DEPENDENCY UPDATE > CHECK...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

CONFIRM=false;

setIsCI;

setGradleArgs;

UPDATES_FILE="commons/gradle/libs.versions.updates.toml";
if [[ -f "$UPDATES_FILE" ]]; then
  rm $UPDATES_FILE;
  checkResult $?;
fi

./gradlew versionCatalogUpdateLibs --interactive ${GRADLE_ARGS};
checkResult $?;

if [[ -f "$UPDATES_FILE" ]]; then
  echo "----------------------------------------------------------------------";
  cat $UPDATES_FILE;
  echo "----------------------------------------------------------------------";
fi

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> DEPENDENCY UPDATE > CHECK... DONE";
echo "================================================================================";