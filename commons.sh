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

function setIsGHEnabled() {
	# https://docs.github.com/en/actions/using-workflows/using-github-cli-in-workflows
	IS_GH_ENABLED=false;
	if [[ ! -z "${GITHUB_TOKEN}" ]]; then
		IS_GH_ENABLED=true;
	elif [[ -z "${CI}" ]]; then # IF not CI DO
		IS_GH_ENABLED=true; # local
	fi
	# echo "IS_GH_ENABLED: $IS_GH_ENABLED"; # DEBUG
}

function setGitCommitEnabled() {
	MT_GIT_COMMIT_ENABLED="false";

	echo "MT_ORG_GIT_COMMIT_ON: '$MT_ORG_GIT_COMMIT_ON'." # allowed
	echo "MT_ORG_GIT_COMMIT_OFF: '$MT_ORG_GIT_COMMIT_OFF'." # forbidden
	echo "MT_GIT_COMMIT_ON: '$MT_GIT_COMMIT_ON'." # allowed
	echo "MT_GIT_COMMIT_OFF: '$MT_GIT_COMMIT_OFF'." # forbidden

	if [[ ${MT_ORG_GIT_COMMIT_OFF} == "mt_true" ]]; then
		echo "> Git commit disabled (org).. SKIP";
		MT_GIT_COMMIT_ENABLED="false";
	elif [[ ${MT_GIT_COMMIT_OFF} == "mt_true" ]]; then
		echo "> Git commit disabled (project).. SKIP";
		MT_GIT_COMMIT_ENABLED="false";
	elif [[ ${MT_ORG_GIT_COMMIT_ON} != "mt_true" && $MT_GIT_COMMIT_ON != "mt_true" ]]; then
		echo "> Git commit NOT enabled (org:'$MT_ORG_GIT_COMMIT_ON'|project:'$MT_GIT_COMMIT_ON').. SKIP";
		MT_GIT_COMMIT_ENABLED="false";
	else
		echo "> Git commit enabled (org:'$MT_ORG_GIT_COMMIT_ON'|project:'$MT_GIT_COMMIT_ON').";
		MT_GIT_COMMIT_ENABLED="true";
	fi
}

function setGitCommitDependencyUpdateEnabled() {
	MT_GIT_COMMIT_DEPENDENCY_UPDATE_ENABLED="false";

	echo "MT_ORG_GIT_COMMIT_DEPENDENCY_UPDATE_ON: '$MT_ORG_GIT_COMMIT_DEPENDENCY_UPDATE_ON'." # allowed
	echo "MT_ORG_GIT_COMMIT_DEPENDENCY_UPDATE_OFF: '$MT_ORG_GIT_COMMIT_DEPENDENCY_UPDATE_OFF'." # forbidden
	echo "MT_GIT_COMMIT_DEPENDENCY_UPDATE_ON: '$MT_GIT_COMMIT_DEPENDENCY_UPDATE_ON'." # allowed
	echo "MT_GIT_COMMIT_DEPENDENCY_UPDATE_OFF: '$MT_GIT_COMMIT_DEPENDENCY_UPDATE_OFF'." # forbidden

	if [[ ${MT_ORG_GIT_COMMIT_DEPENDENCY_UPDATE_OFF} == "mt_true" ]]; then
		echo "> Git dependency update commit disabled (org).. SKIP";
		MT_GIT_COMMIT_DEPENDENCY_UPDATE_ENABLED="false";
	elif [[ ${MT_GIT_COMMIT_DEPENDENCY_UPDATE_OFF} == "mt_true" ]]; then
		echo "> Git dependency update commit disabled (project).. SKIP";
		MT_GIT_COMMIT_DEPENDENCY_UPDATE_ENABLED="false";
	elif [[ ${MT_ORG_GIT_COMMIT_DEPENDENCY_UPDATE_ON} != "mt_true" && $MT_GIT_COMMIT_DEPENDENCY_UPDATE_ON != "mt_true" ]]; then
		echo "> Git dependency update commit NOT enabled (org:'$MT_ORG_GIT_COMMIT_DEPENDENCY_UPDATE_ON'|project:'$MT_GIT_COMMIT_DEPENDENCY_UPDATE_ON').. SKIP";
		MT_GIT_COMMIT_DEPENDENCY_UPDATE_ENABLED="false";
	else
		echo "> Git dependency update commit enabled (org:'$MT_ORG_GIT_COMMIT_DEPENDENCY_UPDATE_ON'|project:'$MT_GIT_COMMIT_DEPENDENCY_UPDATE_ON').";
		MT_GIT_COMMIT_DEPENDENCY_UPDATE_ENABLED="true";
	fi
}

function setPushToStoreEnabled() {
	MT_PUSH_STORE_ENABLED="false";

	echo "MT_ORG_PUSH_STORE_ON: '$MT_ORG_PUSH_STORE_ON'." # allowed
	echo "MT_ORG_PUSH_STORE_OFF: '$MT_ORG_PUSH_STORE_OFF'." # forbidden
	echo "MT_PUSH_STORE_ON: '$MT_PUSH_STORE_ON'." # allowed
	echo "MT_PUSH_STORE_OFF: '$MT_PUSH_STORE_OFF'." # forbidden

	if [[ ${MT_ORG_PUSH_STORE_OFF} == "mt_true" ]]; then
		echo "> Push to Store disabled (org).. SKIP";
		MT_PUSH_STORE_ENABLED="false";
	elif [[ ${MT_PUSH_STORE_OFF} == "mt_true" ]]; then
		echo "> Push to Store disabled (project).. SKIP";
		MT_PUSH_STORE_ENABLED="false";
	elif [[ ${MT_ORG_PUSH_STORE_ON} != "mt_true" && $MT_PUSH_STORE_ON != "mt_true" ]]; then
		echo "> Push to Store NOT enabled (org:'$MT_ORG_PUSH_STORE_ON'|project:'$MT_PUSH_STORE_ON').. SKIP";
		MT_PUSH_STORE_ENABLED="false";
	else
		echo "> Push to Store enabled (org:'$MT_ORG_PUSH_STORE_ON'|project:'$MT_PUSH_STORE_ON')";
		MT_PUSH_STORE_ENABLED="true";
	fi
}

function setPushToStoreAlphaEnabled() {
	MT_PUSH_STORE_ALPHA_ENABLED="false";

	echo "MT_ORG_STORE_ALPHA_ON: '$MT_ORG_STORE_ALPHA_ON'." # allowed
	echo "MT_ORG_STORE_ALPHA_OFF: '$MT_ORG_STORE_ALPHA_OFF'." # forbidden
	echo "MT_STORE_ALPHA_ON: '$MT_STORE_ALPHA_ON'." # allowed
	echo "MT_STORE_ALPHA_OFF: '$MT_STORE_ALPHA_OFF'." # forbidden

	if [[ ${MT_ORG_STORE_ALPHA_OFF} == "mt_true" ]]; then
		echo "> Push to Store Alpha disabled (org).. SKIP";
		MT_PUSH_STORE_ALPHA_ENABLED="false";
	elif [[ ${MT_STORE_ALPHA_OFF} == "mt_true" ]]; then
		echo "> Push to Store Alpha disabled (project).. SKIP";
		MT_PUSH_STORE_ALPHA_ENABLED="false";
	elif [[ ${MT_ORG_STORE_ALPHA_ON} != "mt_true" && $MT_STORE_ALPHA_ON != "mt_true" ]]; then
		echo "> Push to Store Alpha NOT enabled (org:'$MT_ORG_STORE_ALPHA_ON'|project:'$MT_STORE_ALPHA_ON').. SKIP";
		MT_PUSH_STORE_ALPHA_ENABLED="false";
	else
		echo "> Push to Store Alpha enabled (org:'$MT_ORG_STORE_ALPHA_ON'|project:'$MT_STORE_ALPHA_ON')";
		MT_PUSH_STORE_ALPHA_ENABLED="true";
	fi
}

function setPushToStoreBetaPrivateEnabled() {
	MT_PUSH_STORE_BETA_PRIVATE_ENABLED="false";

	echo "MT_ORG_STORE_BETA_PRIVATE_ON: '$MT_ORG_STORE_BETA_PRIVATE_ON'." # allowed
	echo "MT_ORG_STORE_BETA_PRIVATE_OFF: '$MT_ORG_STORE_BETA_PRIVATE_OFF'." # forbidden
	echo "MT_STORE_BETA_PRIVATE_ON: '$MT_STORE_BETA_PRIVATE_ON'." # allowed
	echo "MT_STORE_BETA_PRIVATE_OFF: '$MT_STORE_BETA_PRIVATE_OFF'." # forbidden

	if [[ ${MT_ORG_STORE_BETA_PRIVATE_OFF} == "mt_true" ]]; then
		echo "> Push to Store Beta Private disabled (org).. SKIP";
		MT_PUSH_STORE_BETA_PRIVATE_ENABLED="false";
	elif [[ ${MT_STORE_BETA_PRIVATE_OFF} == "mt_true" ]]; then
		echo "> Push to Store Beta Private disabled (project).. SKIP";
		MT_PUSH_STORE_BETA_PRIVATE_ENABLED="false";
	elif [[ ${MT_ORG_STORE_BETA_PRIVATE_ON} != "mt_true" && $MT_STORE_BETA_PRIVATE_ON != "mt_true" ]]; then
		echo "> Push to Store Beta Private NOT enabled (org:'$MT_ORG_STORE_BETA_PRIVATE_ON'|project:'$MT_STORE_BETA_PRIVATE_ON').. SKIP";
		MT_PUSH_STORE_BETA_PRIVATE_ENABLED="false";
	else
		echo "> Push to Store Beta Private enabled (org:'$MT_ORG_STORE_BETA_PRIVATE_ON'|project:'$MT_STORE_BETA_PRIVATE_ON')";
		MT_PUSH_STORE_BETA_PRIVATE_ENABLED="true";
	fi
}

function setPushToStoreProductionEnabled() {
	MT_PUSH_STORE_PRODUCTION_ENABLED="false";

	echo "MT_ORG_STORE_PRODUCTION_ON: '$MT_ORG_STORE_PRODUCTION_ON'." # allowed
	echo "MT_ORG_STORE_PRODUCTION_OFF: '$MT_ORG_STORE_PRODUCTION_OFF'." # forbidden
	echo "MT_STORE_PRODUCTION_ON: '$MT_STORE_PRODUCTION_ON'." # allowed
	echo "MT_STORE_PRODUCTION_OFF: '$MT_STORE_PRODUCTION_OFF'." # forbidden

	if [[ ${MT_ORG_STORE_PRODUCTION_OFF} == "mt_true" ]]; then
		echo "> Push to Store Production disabled (org).. SKIP";
		MT_PUSH_STORE_PRODUCTION_ENABLED="false";
	elif [[ ${MT_STORE_PRODUCTION_OFF} == "mt_true" ]]; then
		echo "> Push to Store Production disabled (project).. SKIP";
		MT_PUSH_STORE_PRODUCTION_ENABLED="false";
	elif [[ ${MT_ORG_STORE_PRODUCTION_ON} != "mt_true" && $MT_STORE_PRODUCTION_ON != "mt_true" ]]; then
		echo "> Push to Store Production NOT enabled (org:'$MT_ORG_STORE_PRODUCTION_ON'|project:'$MT_STORE_PRODUCTION_ON').. SKIP";
		MT_PUSH_STORE_PRODUCTION_ENABLED="false";
	else
		echo "> Push to Store Production enabled (org:'$MT_ORG_STORE_PRODUCTION_ON'|project:'$MT_STORE_PRODUCTION_ON')";
		MT_PUSH_STORE_PRODUCTION_ENABLED="true";
	fi
}

function setGitUser() {
	setIsCI;
	if [[ ${IS_CI} = true ]]; then
		git config --global user.name 'MonTransit Bot';
		checkResult $?;
		git config --global user.email '84137772+montransit@users.noreply.github.com';
		checkResult $?;
	fi
}

function setGitProjectName() {
	local DIR=$1;
	if [[ -z "${DIR}" ]]; then
		DIR=".";
	fi
	GIT_URL=$(git -C $DIR config --get remote.origin.url);
	echo "GIT_URL: '$GIT_URL'.";
	GIT_PROJECT_NAME=$(basename -- ${GIT_URL});
	GIT_PROJECT_NAME="${GIT_PROJECT_NAME%.*}" # remove ".git" extension
	echo "GIT_PROJECT_NAME: '$GIT_PROJECT_NAME'.";
	if [[ -z "${GIT_PROJECT_NAME}" ]]; then
		echo "GIT_PROJECT_NAME not found!";
		exit 1;
	fi
	PROJECT_NAME="${GIT_PROJECT_NAME%-gradle}";
	echo "PROJECT_NAME: '$PROJECT_NAME'.";
}

function setGitBranch() {
	GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD);
	if [[ "$GIT_BRANCH" = "HEAD" ]]; then
		GIT_BRANCH="";
	fi
	if [[ -z "${GIT_BRANCH}" ]]; then
		GIT_BRANCH=${MT_GIT_BRANCH}; #GitHub Actions CI
		if [[ "$GIT_BRANCH" = "HEAD" ]]; then
			GIT_BRANCH="";
		fi
	fi
	if [[ -z "${GIT_BRANCH}" ]]; then
		GIT_BRANCH=${TRAVIS_PULL_REQUEST_BRANCH}; #TravicCI
		if [[ "$GIT_BRANCH" = "HEAD" ]]; then
			GIT_BRANCH="";
		fi
	fi
	if [[ -z "${GIT_BRANCH}" ]]; then
		GIT_BRANCH=${TRAVIS_BRANCH}; #TravicCI
		if [[ "$GIT_BRANCH" = "HEAD" ]]; then
			GIT_BRANCH="";
		fi
	fi
	if [[ -z "${GIT_BRANCH}" ]]; then
		GIT_BRANCH=${CI_COMMIT_REF_NAME}; #GitLab
		if [[ "$GIT_BRANCH" = "HEAD" ]]; then
			GIT_BRANCH="";
		fi
	fi
	if [[ -z "${GIT_BRANCH}" ]]; then
		echo "GIT_BRANCH not found!";
		exit 1;
	fi
	echo "GIT_BRANCH: $GIT_BRANCH.";
}

function printGitStatus() {
	GIT_LOG_FORMAT="%h - %ad - %ae : %s";
	GIT_LOG_FORMAT_RECENT_ONLY="%ar"
	GIT_LOG_SINCE_DATE="1 hours ago";
	GIT_LOG_LAST_OTHER_ARGS="--date=iso";
	DIFF_LIMIT="33";
	GIT_LOG_SINCE_OTHER_ARGS="--date=iso --name-status";
	echo "==================================================";
	echo "> [GIT STATUS & LOG]...";
	echo "'$(basename $PWD)'"
	git config --get remote.origin.url;
	git status -sb;
	STAGED_DIFF=$(git diff --cached | head -n $DIFF_LIMIT);
	if [ ! -z "$STAGED_DIFF" ]; then
		echo "> staged:";
		echo "$STAGED_DIFF";
	fi
	NOT_STAGED_DIFF=$(git diff | head -n $DIFF_LIMIT);
	if [ ! -z "$NOT_STAGED_DIFF" ]; then
		echo "> not staged:";
		echo "$NOT_STAGED_DIFF";
	fi
	LOG=$(git log --since="$GIT_LOG_SINCE_DATE" --pretty=format:"${GIT_LOG_FORMAT}" $GIT_LOG_SINCE_OTHER_ARGS);
	if [ -z "$LOG" ]; then
		LOG=$(git log --max-count 1 --pretty=format:"${GIT_LOG_FORMAT}" $GIT_LOG_LAST_OTHER_ARGS);
		echo "> latest old commit ($(git log --max-count 1 --pretty=format:$GIT_LOG_FORMAT_RECENT_ONLY)):";
	else
		echo "> commits since $GIT_LOG_SINCE_DATE:";
	fi
	echo "$LOG";
	echo "--------------------------------------------------";
	git submodule foreach "
		git status -sb;
		git config --get remote.origin.url;
		STAGED_DIFF=\$(git diff --cached | head -n $DIFF_LIMIT);
		if [ ! -z \"\$STAGED_DIFF\" ]; then
			echo \"> staged:\";
			echo \"\$STAGED_DIFF\";
		fi
		NOT_STAGED_DIFF=\$(git diff | head -n $DIFF_LIMIT);
		if [ ! -z \"\$NOT_STAGED_DIFF\" ]; then
			echo \"> not staged:\";
			echo \"\$NOT_STAGED_DIFF\";
		fi
		LOG=\$(git log --since=\"$GIT_LOG_SINCE_DATE\" --pretty=format:\"${GIT_LOG_FORMAT}\" $GIT_LOG_SINCE_OTHER_ARGS);
		if [ -z \"\$LOG\" ]; then
			LOG=\$(git log --max-count 1 --pretty=format:\"${GIT_LOG_FORMAT}\" $GIT_LOG_LAST_OTHER_ARGS);
			echo \"> latest old commit (\$(git log --max-count 1 --pretty=format:\"$GIT_LOG_FORMAT_RECENT_ONLY\")):\";
		else
			echo \"> commits since $GIT_LOG_SINCE_DATE:\";
		fi
		echo \"\$LOG\";
		echo \"--------------------------------------------------\";
	";
	echo "> [GIT STATUS & LOG]... DONE";
	echo "==================================================";
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

	echo "> GitHub Actions: $GITHUB_ACTIONS.";
	if [[ ${GITHUB_ACTIONS} = true ]]; then
		GRADLE_ARGS=""; # use daemon on GitHub
	fi

	if [[ ${IS_CI} = true ]]; then
		GRADLE_ARGS+=" --warning-mode all"; # print warnings in CI
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
		echo "> ---------- COMMAND FAILED! ---------- <";
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
	local OPENSSL_CONF_FILE="download_openssl_allow_tls1_0.cnf"
	if [[ "$NEW_FILE" == "$LAST_FILE" ]]; then
		NEW_FILE="NEW_${NEW_FILE}"
	fi
	curl --version;
	wget --version;
	local CURL_="curl";
	# local CURL_="curl --verbose"; #DEBUG
	local WGET_="wget";
	# local WGET_="wget --verbose"; #DEBUG
	local CURL_OPENSSL_UNSAFE_LEGACY_RENEGOTIATION="openssl_conf = openssl_init\n[openssl_init]\nssl_conf = ssl_sect\n[ssl_sect]\nsystem_default = system_default_sect\n[system_default_sect]\nOptions = UnsafeLegacyRenegotiation";
	echo "> download() > Downloading from '$URL'...";
	if [[ -e ${LAST_FILE} ]]; then
		echo "> download() > (using last file '${LAST_FILE}')";
		cp "${LAST_FILE}" "${NEW_FILE}";
		# TODO --no-if-modified-since ??
		# $WGET_ --header="User-Agent: MonTransit" --timeout=60 --tries=6 --timestamping "$URL";
		$CURL_ --user-agent "MonTransit" --location --output "${NEW_FILE}" --time-cond "${LAST_FILE}" --max-time 240 --retry 3 "$URL";
		local RESULT=$?;
		if [[ ${RESULT} != 0 ]]; then
			echo "> download() > Downloading from '$URL'... FAILED";
			echo "> download() > Downloading from '$URL' (insecure)...";
			$CURL_  --insecure --user-agent "MonTransit" --location --output "${NEW_FILE}" --time-cond "${LAST_FILE}" --max-time 240 --retry 3 "$URL";
			local RESULT=$?;
			if [[ ${RESULT} != 0 ]]; then
				echo "> download() > Downloading from '$URL' (insecure)...FAILED";
				echo "> download() > Downloading from '$URL' with WGET...";
				$WGET_ -O "${NEW_FILE}" --header="User-Agent: MonTransit" --timeout=60 --tries=3 --timestamping "$URL";
				local RESULT=$?;
				if [[ ${RESULT} != 0 ]]; then
					echo "> download() > Downloading from '$URL' with WGET... FAILED";
					echo "> download() > Downloading from '$URL' with CURL & custom OPENSSL_CONF='$OPENSSL_CONF_FILE'...";
					echo -e $CURL_OPENSSL_UNSAFE_LEGACY_RENEGOTIATION | OPENSSL_CONF=/dev/stdin curl --user-agent "MonTransit" --location --output "${NEW_FILE}" --time-cond "${LAST_FILE}" --max-time 240 --retry 3 "$URL";
				fi
			fi
		fi
	else
		echo "> download() > (not using last file)";
		# $WGET_ --header="User-Agent: MonTransit" --timeout=60 --tries=6 -S "$URL";
		$CURL_  --user-agent "MonTransit" --location --output "${NEW_FILE}" --max-time 240 --retry 3 "$URL";
		local RESULT=$?;
		if [[ ${RESULT} != 0 ]]; then
			echo "> download() > Downloading from '$URL'... FAILED";
			echo "> download() > Downloading from '$URL' (insecure)...";
			$CURL_  --insecure --user-agent "MonTransit" --location --output "${NEW_FILE}" --max-time 240 --retry 3 "$URL";
			local RESULT=$?;
			if [[ ${RESULT} != 0 ]]; then
				echo "> download() > Downloading from '$URL' (insecure)...FAILED";
				echo "> download() > Downloading from '$URL' with WGET...";
				$WGET_ -O "${NEW_FILE}" --header="User-Agent: MonTransit" --timeout=60 --tries=3 "$URL";
				local RESULT=$?;
				if [[ ${RESULT} != 0 ]]; then
					echo "> download() > Downloading from '$URL' with WGET... FAILED";
					echo "> download() > Downloading from '$URL' with CURL & custom OPENSSL_CONF='$OPENSSL_CONF_FILE'...";
					echo -e $CURL_OPENSSL_UNSAFE_LEGACY_RENEGOTIATION | OPENSSL_CONF=/dev/stdin curl --user-agent "MonTransit" --location --output "${NEW_FILE}" --max-time 240 --retry 3 "$URL";
				fi
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
			ls -l "${LAST_FILE}";
		fi
	else
		echo "> download() > Failed to download file from '$URL'!";
		return 1; # DID NOT DOWNLOAD
	fi;
	return 0; # DOWNLOADED SUCCESSFULLY
}

function getArrayIndex() {
  local -n ARRAY=$1 # use -n for a reference to the array
  local KEY=$2
  for i in "${!ARRAY[@]}"; do
    if [[ ${ARRAY[i]} = "$KEY" ]]; then
      printf '%s\n' "$i"
      return
    fi
  done
  echo "> getArrayIndex() > Failed to find '$KEY' in array!";
  exit 1
}

function cleanArray() {
  local -n ARRAY=$1 # use -n for a reference to the array
  ARRAY=("${ARRAY[@]/#\"}") # remove leading quotes
  ARRAY=("${ARRAY[@]/%\"}") # remove trailing quotes
  for i in "${!ARRAY[@]}"; do
	if [ -z "${ARRAY[i]}" ]; then
	  unset "ARRAY[i]"
	fi
  done
}

# COMMONS_AFTER_DATE=$(date +%D-%X);
# COMMONS_AFTER_DATE_SEC=$(date +%s);
# COMMONS_DURATION_SEC=$(($COMMONS_AFTER_DATE_SEC-$COMMONS_BEFORE_DATE_SEC));
# echo "> LOADING COMMONS... DONE ($COMMONS_DURATION_SEC secs FROM $COMMONS_BEFORE_DATE TO $COMMONS_AFTER_DATE)";
# echo "================================================================================";
