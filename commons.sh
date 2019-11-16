#!/bin/bash
# echo "================================================================================";
# echo "> LOADING COMMONS...";
# COMMONS_BEFORE_DATE=$(date +%D-%X);
# COMMONS_BEFORE_DATE_SEC=$(date +%s);

function setIsCI() {
	IS_CI=false;
    if [[ ! -z "${CI}" ]]; then
        IS_CI=true;
    fi
}

function setGradleArgs() {
	setIsCI;

    GRADLE_ARGS="";
    if [[ ${IS_CI} = true ]]; then
        GRADLE_ARGS="-Dorg.gradle.daemon=false -Dorg.gradle.workers.max=2 --console=plain";
    fi
}

# set current working directory to the directory of the script
function setCurrentDirectory() {
	if [[ "$#" -lt 1 ]]; then
		echo "> setCurrentDirectory() > Illegal number of parameters!";
		exit 1;
	fi
	local CURRENT_DIRECTORY=$0;
	cd "$(dirname "$CURRENT_DIRECTORY")" || exit;
	echo "> Current directory set to $CURRENT_DIRECTORY.";
}

function checkResult() {
	if [[ "$#" -lt 1 ]]; then
		echo "> checkResult() > Illegal number of parameters!";
		exit 1;
	fi
	local RESULT=$1;
	local CONFIRM=false; # OFF by default
	if [[ "$#" -ge 2 ]]; then
		CONFIRM=$2;
	fi
	if [[ ${RESULT} != 0 ]]; then
		echo "> FAILED, AGAIN AND AGAIN, FAILED, AGAIN AND AGAIN, FAILED, AGAIN AND AGAIN";
		exit ${RESULT};
	else
		if [[ "$CONFIRM" == true ]]; then
			read -r -n 1 -p "Continue?";
		fi
	fi
}

function contains() {
	if [[ "$#" -lt 2 ]]; then
		echo "> contains() > Illegal number of parameters!";
		exit 1;
	fi
	local LIST=("$@");
	local ITEM_IDX=0;
	local ITEM=${LIST[ITEM_IDX]};
	unset 'LIST[ITEM_IDX]';
	for e in "${LIST[@]}"; do
		if [[ "$e" = "$ITEM" ]] ; then
			return 0; # CONTAINS
		fi
	done
	return 1; # NOT CONTAINS
}

function download() {
	if [[ "$#" -lt 2 ]]; then
		echo "> download() > Illegal number of parameters!";
		exit 1;
	fi
	local URL=$1;
	local NEW_FILE=$(basename "$URL");
	local LAST_FILE=$2;
	echo "> download() > Downloading from '$URL'...";
	if [[ -e ${LAST_FILE} ]]; then
		cp "${LAST_FILE}" "${NEW_FILE}";
		# TODO --no-if-modified-since ??
		# wget --header="User-Agent: MonTransit" --timeout=60 --tries=6 -N "$URL";
		curl -L -o "${NEW_FILE}" -z "${LAST_FILE}" --max-time 240 --retry 3 "$URL";
	else
		# wget --header="User-Agent: MonTransit" --timeout=60 --tries=6 -S "$URL";
		curl -L -o "${NEW_FILE}" --max-time 240 --retry 3 "$URL";
	fi;
	if [[ -e "${NEW_FILE}" ]]; then
		if [[ -e ${LAST_FILE} ]]; then
			diff "${NEW_FILE}" ${LAST_FILE} >/dev/null;
			if [[ $? -eq 0 ]]; then
				echo "> download() > Ignoring same downloaded file.";
				ls -l "${LAST_FILE}";
				ls -l "${NEW_FILE}";
				rm "${NEW_FILE}"; # same file
			else
				echo "> download() > Replacing old file with NEW downloaded file.";
				ls -l "${LAST_FILE}";
				ls -l "${NEW_FILE}";
				mv "${NEW_FILE}" "${LAST_FILE}"; # different file
			fi
		else
			echo "> download() > Using NEW downloaded file.";
			mv "${NEW_FILE}" "${LAST_FILE}"; # new file
		fi
	else
		echo "> download() > Failed to download file from '$URL'!";
		return 1; # DID NOT DOWNLOAD
	fi;
	return 0; # DOWNLOADED SUCCESSFULLY
}

# COMMONS_AFTER_DATE=$(date +%D-%X);
# COMMONS_AFTER_DATE_SEC=$(date +%s);
# COMMONS_DURATION_SEC=$(($COMMONS_AFTER_DATE_SEC-$COMMONS_BEFORE_DATE_SEC));
# echo "> LOADING COMMONS... DONE ($COMMONS_DURATION_SEC secs FROM $COMMONS_BEFORE_DATE TO $COMMONS_AFTER_DATE)";
# echo "================================================================================";
