#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
declare -a FILES=(
	"app-signing-release-keystore.keystore"
	"app-signing-release-keys.properties"
	"app-signing-release-keystore-encrypted.keystore"
	"google-play-auto-publisher.json"
	"google-play-upload-certificate.pem"
	"google-play-upload-keystore.keystore"
	"google-play-upload-keys.properties"
	"src/main/play/contact-email.txt"
);

if [[ -f "${SCRIPT_DIR}/src/main/res/values/keys.xml" ]]; then
	FILES+=("src/main/res/values/keys.xml");
	if [[ -f "${SCRIPT_DIR}/src/debug/res/values/keys.xml" ]]; then
		FILES+=("src/debug/res/values/keys.xml");
	fi
fi

if [[ -f "${SCRIPT_DIR}/google-services.json" ]]; then
	FILES+=("google-services.json");
	if [[ -f "${SCRIPT_DIR}/src/debug/google-services.json" ]]; then
        FILES+=("src/debug/google-services.json");
    fi
fi

echo "Files:";
printf '* "%s"\n' "${FILES[@]}";
