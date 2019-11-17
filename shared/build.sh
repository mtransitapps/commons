#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> RUN ALL...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD);
if [[ "$GIT_BRANCH" = "HEAD" ]]; then
	GIT_BRANCH="";
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

CONFIRM=false;

setIsCI;

setGradleArgs;

declare -a EXCLUDE=(".git" "test" "build" "gen" "gradle");

echo "> CLEANING FOR '$AGENCY_ID'...";
for d in ${PWD}/* ; do
	DIRECTORY=$(basename ${d});
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
		cd ${d} || exit;
		echo "> GIT cleaning in '$DIRECTORY'...";
		GIT_REV_PARSE_HEAD=$(git rev-parse HEAD);
		GIT_REV_PARSE_REMOTE_BRANCH=$(git rev-parse origin/${GIT_BRANCH});
		if [[ "$GIT_REV_PARSE_HEAD" != "$GIT_REV_PARSE_REMOTE_BRANCH" ]]; then
			echo "> GIT repo outdated in '$DIRECTORY' (local:$GIT_REV_PARSE_HEAD|origin/$GIT_BRANCH:$GIT_REV_PARSE_REMOTE_BRANCH).";
			exit 1;
		else
			echo "> GIT repo up-to-date in '$DIRECTORY' (local:$GIT_REV_PARSE_HEAD|origin/$GIT_BRANCH:$GIT_REV_PARSE_REMOTE_BRANCH).";
		fi

		git checkout ${GIT_BRANCH};
		checkResult $? ${CONFIRM};

		git pull;
		checkResult $? ${CONFIRM};
		echo "> GIT cleaning in '$DIRECTORY'... DONE";
		cd ..;
		echo "--------------------------------------------------------------------------------";
	fi
done

echo "GRADLE VERSION:";
./gradlew --version ${GRADLE_ARGS};

echo "JAVA VERSION:";
java -version;

echo "CURL VERSION:";
curl --version;

if [[ -d "agency-parser" ]]; then
	echo "> CLEANING FOR '$AGENCY_ID' (GRADLE BUILD)...";

	./gradlew :parser:clean ${GRADLE_ARGS};
	checkResult $? ${CONFIRM};

	./gradlew :agency-parser:clean ${GRADLE_ARGS};
	checkResult $? ${CONFIRM};
	echo "> CLEANING FOR '$AGENCY_ID' (GRADLE BUILD)... DONE";

	echo "> DOWNLOADING DATA FOR '$AGENCY_ID'...";
	cd agency-parser || exit; # >>

	./download.sh;
	checkResult $? ${CONFIRM};

	./unzip_gtfs.sh;
	checkResult $? ${CONFIRM};

	echo "> DOWNLOADING DATA FOR '$AGENCY_ID'... DONE";

	echo "> BUILDING FOR '$AGENCY_ID' (GRADLE BUILD)... ";
	../gradlew :parser:build ${GRADLE_ARGS};
	checkResult $? ${CONFIRM};

	echo "> BUILDING FOR '$AGENCY_ID' (GRADLE BUILD)... DONE";

	echo "> PARSING DATA FOR '$AGENCY_ID'...";

	./parse_pre_current.sh;
	checkResult $? ${CONFIRM};

	../gradlew :agency-parser:build ${GRADLE_ARGS};
	checkResult $? ${CONFIRM};

	./parse_current.sh;
	checkResult $? ${CONFIRM};

	./parse_pre_next.sh;
	checkResult $? ${CONFIRM};

	../gradlew :agency-parser:build ${GRADLE_ARGS};
	checkResult $? ${CONFIRM};

	./parse_next.sh;
	checkResult $? ${CONFIRM};

	./list_change.sh;
	checkResult $? ${CONFIRM};

	cd ..; # <<
	echo "> PARSING DATA FOR '$AGENCY_ID'... DONE";
else
	echo "> SKIP PARSING FOR '$AGENCY_ID'.";
fi

echo "> BUILDING ANDROID APP FOR '$AGENCY_ID'...";
cd app-android || exit;

./build.sh
checkResult $? ${CONFIRM};

cd ..;
echo "> BUILDING ANDROID APP FOR '$AGENCY_ID'... DONE";
echo "--------------------------------------------------------------------------------";

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> RUN ALL... DONE";
echo "================================================================================";
