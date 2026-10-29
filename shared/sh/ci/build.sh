#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR=$(cd "${SCRIPT_DIR}/../.." && pwd);

source "${ROOT_DIR}/commons/sh/commons.sh";

echo "================================================================================";
echo "> BUILD ALL...";
echo "--------------------------------------------------------------------------------";
# TODO REMOVE (DEPRECATED, USE other scripts) (used by CircleCI & GitLab CI)
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

setGitProjectName;

setGitBranch;

setIsCI;

setGradleArgs;

declare -a EXCLUDE=(".git" "test" "build" "gen" "gradle");

echo "> CLEANING FOR '$PROJECT_NAME'...";

if [[ $CIRCLECI != "true" ]]; then
	for d in "${ROOT_DIR}"/* ; do
		DIRECTORY=$(basename "${d}");
		if ! [[ -d "$d" ]]; then
			echo "> Skip GIT cleaning (not a directory) '$DIRECTORY'.";
			echo "--------------------------------------------------------------------------------";
			continue;
		fi
		if contains ${DIRECTORY} ${EXCLUDE[@]}; then
			echo "> Skip GIT cleaning in excluded directory '$DIRECTORY'.";
			echo "--------------------------------------------------------------------------------";
			continue;
		fi
		if [[ -d "$d" ]]; then
			# TODO only if not master????
			echo "> GIT cleaning in '$DIRECTORY'...";
			GIT_REV_PARSE_HEAD=$(git -C "$d" rev-parse HEAD);
			GIT_REV_PARSE_REMOTE_BRANCH=$(git -C "$d" rev-parse origin/${GIT_BRANCH});
			if [[ "$GIT_REV_PARSE_HEAD" != "$GIT_REV_PARSE_REMOTE_BRANCH" ]]; then
				echo "> GIT repo outdated in '$DIRECTORY' (local:$GIT_REV_PARSE_HEAD|origin/$GIT_BRANCH:$GIT_REV_PARSE_REMOTE_BRANCH).";
				exit 1;
			else
				echo "> GIT repo up-to-date in '$DIRECTORY' (local:$GIT_REV_PARSE_HEAD|origin/$GIT_BRANCH:$GIT_REV_PARSE_REMOTE_BRANCH).";
			fi

			git -C "$d" switch ${GIT_BRANCH};
			checkResult $?;
			echo "> GIT cleaning in '$DIRECTORY'... DONE";
			echo "--------------------------------------------------------------------------------";
		fi
	done
fi

echo "--------------------------------------------------------------------------------";
echo "GRADLE VERSION:";
"${ROOT_DIR}/gradlew" --version ${GRADLE_ARGS};
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
echo "JAVA VERSION:";
java -version;
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
echo "CURL VERSION:";
curl --version;
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
echo "OPENSSL VERSION:";
openssl version;
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
echo "AWK VERSION:";
awk --version;
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
echo "GAWK VERSION:";
gawk --version;
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
echo "MAWK VERSION:";
mawk --version;
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
echo "SPLIT VERSION:";
split --version;
echo "--------------------------------------------------------------------------------";

if [[ -d "${ROOT_DIR}/agency-parser" ]] && [[ $GIT_BRANCH != "master" ]]; then

	echo "> CLEANING FOR '$PROJECT_NAME' (GRADLE BUILD)...";
	"${ROOT_DIR}/gradlew" :commons-java:clean ${GRADLE_ARGS};
	checkResult $?;
	"${ROOT_DIR}/gradlew" :parser:clean ${GRADLE_ARGS};
	checkResult $?;
	"${ROOT_DIR}/gradlew" :agency-parser:clean ${GRADLE_ARGS};
	checkResult $?;
	echo "> CLEANING FOR '$PROJECT_NAME' (GRADLE BUILD)... DONE";

	echo "> DOWNLOADING DATA FOR '$PROJECT_NAME'...";

	CURRENT_PATH=$(pwd);
	cd "${ROOT_DIR}/agency-parser" || exit; # >>
	ROOT_FROM_CURRENT_DIR="./..";

	./sh/download.sh; # in agency-parser
	checkResult $?;

	$ROOT_FROM_CURRENT_DIR/commons/gtfs/gtfs-validator.sh "input/gtfs.zip" "output/current"; # in agency-parser
  	# checkResult $?; # too many errors for now

	if [[ -e "input/gtfs_next.zip" ]]; then
		$ROOT_FROM_CURRENT_DIR/commons/gtfs/gtfs-validator.sh "input/gtfs_next.zip" "output/next"; # in agency-parser
		# checkResult $?; # too many errors for now
	fi

	./sh/unzip_gtfs.sh; # in agency-parser
	checkResult $?;

	echo "> DOWNLOADING DATA FOR '$PROJECT_NAME'... DONE";

	echo "> BUILDING FOR '$PROJECT_NAME' (GRADLE BUILD)... ";
	$ROOT_FROM_CURRENT_DIR/gradlew :commons-java:build ${GRADLE_ARGS}; #includes test # in agency-parser
	checkResult $?;

	$ROOT_FROM_CURRENT_DIR/gradlew :parser:build ${GRADLE_ARGS}; #includes test # in agency-parser
	checkResult $?;

	echo "> BUILDING FOR '$PROJECT_NAME' (GRADLE BUILD)... DONE";

	echo "> PARSING DATA FOR '$PROJECT_NAME'...";

    # CURRENT...
	$ROOT_FROM_CURRENT_DIR/gradlew :agency-parser:build ${GRADLE_ARGS}; # in agency-parser
	checkResult $?;

	./sh/parse_current.sh; # in agency-parser
	checkResult $?;
	# CURRENT... DONE

	# NEXT...
	$ROOT_FROM_CURRENT_DIR/gradlew :agency-parser:build ${GRADLE_ARGS}; # in agency-parser
	checkResult $?;

	./sh/parse_next.sh; # in agency-parser
	checkResult $?;
	# NEXT... DONE

	./sh/list_change.sh; # in agency-parser
	checkResult $?;

	cd "$CURRENT_PATH" || exit; # <<
	echo "> PARSING DATA FOR '$PROJECT_NAME'... DONE";
else
	echo "> SKIP PARSING FOR '$PROJECT_NAME' (branch:$GIT_BRANCH).";
fi

echo "> BUILDING ANDROID APP FOR '$PROJECT_NAME'...";
CURRENT_PATH=$(pwd);
cd "$ROOT_DIR/app-android" || exit; # >>
	
./sh/ci/build.sh; # $ROOT_DIR/app-android/sh/ci/build.sh
checkResult $?;

cd "$CURRENT_PATH"; # <<

echo "> BUILDING ANDROID APP FOR '$PROJECT_NAME'... DONE";
echo "--------------------------------------------------------------------------------";

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> BUILD ALL... DONE";
echo "================================================================================";
