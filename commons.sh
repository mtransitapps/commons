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
	# IS_CI=true; # DEBUG
}

function setGradleArgs() {
	setIsCI;

	GRADLE_ARGS="";
	if [[ ${IS_CI} = true ]]; then
		# GRADLE_ARGS+=" --info"; # -i
		# GRADLE_ARGS+=" --stacktrace"; # -s
		GRADLE_ARGS+=" --no-daemon"; # org.gradle.daemon=false
		# GRADLE_ARGS+=" --daemon"; # org.gradle.daemon=true #memory
		GRADLE_ARGS+=" --no-parallel"; # org.gradle.parallel=false
		GRADLE_ARGS+=" --no-configure-on-demand"; # org.gradle.configureondemand=false
		GRADLE_ARGS+=" --max-workers=2"; # org.gradle.workers.max=2
		GRADLE_ARGS+=" --console=plain";
		GRADLE_ARGS+=" -Dkotlin.compiler.execution.strategy=in-process";
		GRADLE_ARGS+=" -Dkotlin.incremental=false";
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
	if [[ "$NEW_FILE" == "$LAST_FILE" ]]; then
	  NEW_FILE="NEW_${NEW_FILE}"
	fi
	echo "> download() > Downloading from '$URL'...";
	if [[ -e ${LAST_FILE} ]]; then
		cp "${LAST_FILE}" "${NEW_FILE}";
		# TODO --no-if-modified-since ??
		# wget --header="User-Agent: MonTransit" --timeout=60 --tries=6 -N "$URL";
		curl -L -o "${NEW_FILE}" -z "${LAST_FILE}" --max-time 240 --retry 3 "$URL";
		local RESULT=$?;
		if [[ ${RESULT} != 0 ]]; then
			echo "> download() > Downloading from '$URL'... FAILED";
			echo "> download() > Downloading from '$URL' (unsecure)...";
			curl --insecure -L -o "${NEW_FILE}" -z "${LAST_FILE}" --max-time 240 --retry 3 "$URL";
			local RESULT=$?;
			if [[ ${RESULT} != 0 ]]; then
				echo "> download() > Downloading from '$URL' (unsecure)...FAILED";
				echo "> download() > Downloading from '$URL' with WGET...";
				wget -O "${NEW_FILE}" --header="User-Agent: MonTransit" --timeout=60 --tries=3 -N "$URL";
			fi
		fi
	else
		# wget --header="User-Agent: MonTransit" --timeout=60 --tries=6 -S "$URL";
		curl -L -o "${NEW_FILE}" --max-time 240 --retry 3 "$URL";
		local RESULT=$?;
		if [[ ${RESULT} != 0 ]]; then
			echo "> download() > Downloading from '$URL'... FAILED";
			echo "> download() > Downloading from '$URL' (unsecure)...";
			curl --insecure -L -o "${NEW_FILE}" --max-time 240 --retry 3 "$URL";
			local RESULT=$?;
			if [[ ${RESULT} != 0 ]]; then
				echo "> download() > Downloading from '$URL' (unsecure)...FAILED";
				echo "> download() > Downloading from '$URL' with WGET...";
				wget -O "${NEW_FILE}" --header="User-Agent: MonTransit" --timeout=60 --tries=3 -N "$URL";
			fi
		fi
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
