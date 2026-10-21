#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../../..";
source ${ROOT_DIR}/commons/commons.sh

declare -a FILES=(
	"signing/release/keys.properties"
	"signing/release/keystore.keystore"
	"signing/release/keystore-encrypted.keystore"
	"play-android-publisher-service-account-key.json"
	"signing/play-upload/certificate.pem"
	"signing/play-upload/keys.properties"
	"signing/play-upload/keystore.keystore"
	"src/main/play/contact-email.txt"
);

APP_ANDROID_DIR="${ROOT_DIR}/app-android";

if [[ -f "${APP_ANDROID_DIR}/src/main/res/values/keys.xml" ]]; then
	FILES+=("src/main/res/values/keys.xml");
	if [[ -f "${APP_ANDROID_DIR}/src/debug/res/values/keys.xml" ]]; then
		FILES+=("src/debug/res/values/keys.xml");
	fi
fi

if [[ -f "${APP_ANDROID_DIR}/google-services.json" ]]; then
	FILES+=("google-services.json");
	if [[ -f "${APP_ANDROID_DIR}/src/debug/google-services.json" ]]; then
        FILES+=("src/debug/google-services.json");
    fi
fi

setIsCI;

DEBUG_FILES=$IS_CI;
# DEBUG_FILES=true;

if [[ $DEBUG_FILES == true ]]; then
	echo "> Files:";
	printf '> - "%s"\n' "${FILES[@]}";
fi
