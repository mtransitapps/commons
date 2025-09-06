#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> ASSEMBLE RELEASE..";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

setIsCI;

setIsGHEnabled;

setPushToStoreEnabled;

setGradleArgs;

MT_TEMP_DIR=".mt";
mkdir -p $MT_TEMP_DIR;
checkResult $?;
MT_APP_RELEASE_REQUIRED_FILE="$MT_TEMP_DIR/mt_app_release_required";
MT_APP_RELEASE_REQUIRED=unknown;
if [[ -f ${MT_APP_RELEASE_REQUIRED_FILE} ]]; then
  MT_APP_RELEASE_REQUIRED=$(cat $MT_APP_RELEASE_REQUIRED_FILE);
fi
if [[ "$MT_APP_RELEASE_REQUIRED" == "false" ]]; then
  echo "> App release NOT required ($MT_APP_RELEASE_REQUIRED) > SKIP assemble";
  exit 0; # ok
fi

IS_SHALLOW=$(git rev-parse --is-shallow-repository);
if [[ "$IS_SHALLOW" == true ]]; then
	echo "> Fetching unshallow GIT repo...";
	git fetch -v --unshallow;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo "> Error while fetching unshallow GIT repository!";
		exit ${RESULT};
	fi
	echo "> Fetching unshallow GIT repo... DONE";
else
	echo "> Not a shallow GIT repo.";
fi

cd app-android || exit;

# ----------------------------------------

if [[ ${IS_GH_ENABLED} == true && ${MT_PUSH_STORE_ENABLED} == true ]]; then

	echo ">> Setup-ing keys...";
	./keys_setup.sh;
	checkResult $?;
	echo ">> Setup-ing keys... DONE";

	echo ">> Running assemble release APK..."; # for GH release
	../gradlew :app-android:assembleRelease -PuseGooglePlayUploadKeysProperties=false ${GRADLE_ARGS};
	RESULT=$?;
	echo ">> Running assemble release APK... DONE";

	echo ">> Cleaning keys...";
	./keys_cleanup.sh;
	checkResult $?;
	echo ">> Cleaning keys... DONE";

	checkResult $RESULT;
else
  echo ">> Running assemble release APK... SKIP (GH:$IS_GH_ENABLED|PushToStore:$MT_PUSH_STORE_ENABLED)";
fi

# ----------------------------------------

echo ">> Setup-ing keys...";
./keys_setup.sh;
checkResult $?;
echo ">> Setup-ing keys... DONE";

echo ">> Running bundle release AAB...";
../gradlew :app-android:bundleRelease ${GRADLE_ARGS};
RESULT=$?;
echo ">> Running bundle release AAB... DONE";

echo ">> Cleaning keys...";
./keys_cleanup.sh;
checkResult $?;
echo ">> Cleaning keys... DONE";

checkResult $RESULT;

# ----------------------------------------

cd ..;

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> ASSEMBLE RELEASE... DONE";
echo "================================================================================";
