#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> DOWNLOAD & PARSE...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

# GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD);
# if [[ "$GIT_BRANCH" = "HEAD" ]]; then
# 	GIT_BRANCH="";
# fi
# if [[ -z "${GIT_BRANCH}" ]]; then
# 	GIT_BRANCH=${TRAVIS_PULL_REQUEST_BRANCH}; #TravicCI
# 	if [[ "$GIT_BRANCH" = "HEAD" ]]; then
# 		GIT_BRANCH="";
# 	fi
# fi
# if [[ -z "${GIT_BRANCH}" ]]; then
# 	GIT_BRANCH=${TRAVIS_BRANCH}; #TravicCI
# 	if [[ "$GIT_BRANCH" = "HEAD" ]]; then
# 		GIT_BRANCH="";
# 	fi
# fi
# if [[ -z "${GIT_BRANCH}" ]]; then
# 	GIT_BRANCH=${CI_COMMIT_REF_NAME}; #GitLab
# 	if [[ "$GIT_BRANCH" = "HEAD" ]]; then
# 		GIT_BRANCH="";
# 	fi
# fi
# if [[ -z "${GIT_BRANCH}" ]]; then
# 	echo "GIT_BRANCH not found!";
# 	exit 1;
# fi
# echo "GIT_BRANCH: $GIT_BRANCH.";

CONFIRM=false;

setIsCI;

setGradleArgs;


if [[ -d "agency-parser" ]]; then
# && [[ $GIT_BRANCH != "master" ]]
	# echo "> CLEANING FOR '$AGENCY_ID' (GRADLE BUILD)...";

	# ./gradlew :commons-java:clean ${GRADLE_ARGS};
	# checkResult $? ${CONFIRM};

	# ./gradlew :parser:clean ${GRADLE_ARGS};
	# checkResult $? ${CONFIRM};

	# ./gradlew :agency-parser:clean ${GRADLE_ARGS};
	# checkResult $? ${CONFIRM};
	# echo "> CLEANING FOR '$AGENCY_ID' (GRADLE BUILD)... DONE";

	echo "> DOWNLOADING DATA FOR '$AGENCY_ID'...";
	cd agency-parser || exit; # >>

	./download.sh;
	checkResult $? ${CONFIRM};

	./unzip_gtfs.sh;
	checkResult $? ${CONFIRM};

	echo "> DOWNLOADING DATA FOR '$AGENCY_ID'... DONE";

	# echo "> BUILDING FOR '$AGENCY_ID' (GRADLE BUILD)... ";
	# ../gradlew :commons-java:build ${GRADLE_ARGS}; #includes test
	# checkResult $? ${CONFIRM};
	#
	# ../gradlew :parser:build ${GRADLE_ARGS}; #includes test
	# checkResult $? ${CONFIRM};
	#
	# ../gradlew :agency-parser:build ${GRADLE_ARGS}; #includes test
	# checkResult $? ${CONFIRM};
	#
	#echo "> BUILDING FOR '$AGENCY_ID' (GRADLE BUILD)... DONE";

	echo "> PARSING DATA FOR '$AGENCY_ID'...";

	# CURRENT...
	# ../gradlew :agency-parser:build ${GRADLE_ARGS};
	# checkResult $? ${CONFIRM};

	./parse_current.sh;
	checkResult $? ${CONFIRM};
	# CURRENT... DONE

	# NEXT...
	# ../gradlew :agency-parser:build ${GRADLE_ARGS};
	# checkResult $? ${CONFIRM};

	./parse_next.sh;
	checkResult $? ${CONFIRM};
	# NEXT... DONE

	./list_change.sh;
	checkResult $? ${CONFIRM};

	cd ..; # <<
	echo "> PARSING DATA FOR '$AGENCY_ID'... DONE";
else
	echo "> SKIP PARSING FOR '$AGENCY_ID'.";
	#  (branch:$GIT_BRANCH)
fi

# echo "> BUILDING ANDROID APP FOR '$AGENCY_ID'...";
# cd app-android || exit;

# ./build.sh
# checkResult $? ${CONFIRM};

# cd ..;
# echo "> BUILDING ANDROID APP FOR '$AGENCY_ID'... DONE";
# echo "--------------------------------------------------------------------------------";

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> DOWNLOAD & PARSE... DONE";
echo "================================================================================";
