#!/bin/bash
declare -a FILES=(
	"app-signing-release-keystore.keystore"
	"app-signing-release-keys.properties"
	"app-signing-release-keystore-encrypted.keystore"
	"google-play-auto-publisher.json"
	"google-play-upload-certificate.pem"
	"google-play-upload-keystore.keystore"
	"google-play-upload-keys.properties"
);

if [[ -f "res/values/keys.xml" ]]; then
	FILES+=("res/values/keys.xml");
fi

if [[ -f "google-services.json" ]]; then
	FILES+=("google-services.json");
fi

echo "Files:";
printf '* "%s"\n' "${FILES[@]}";
