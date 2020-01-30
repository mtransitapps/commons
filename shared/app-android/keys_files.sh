#!/bin/bash
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

if [[ -f "src/main/res/values/keys.xml" ]]; then
	FILES+=("src/main/res/values/keys.xml");
fi

if [[ -f "google-services.json" ]]; then
	FILES+=("google-services.json");
	if [[ -f "src/debug/google-services.json" ]]; then
        FILES+=("src/debug/google-services.json");
    fi
fi

echo "Files:";
printf '* "%s"\n' "${FILES[@]}";
