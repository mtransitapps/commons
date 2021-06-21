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

# echo "--------------------------------------------------------------------------------";
# echo "GRADLE VERSION:";
# ./gradlew --version ${GRADLE_ARGS};
# echo "--------------------------------------------------------------------------------";

# echo "--------------------------------------------------------------------------------";
# echo "JAVA VERSION:";
# java -version;
# echo "--------------------------------------------------------------------------------";

# echo "--------------------------------------------------------------------------------";
# echo "CURL VERSION:";
# curl --version;
# echo "--------------------------------------------------------------------------------";

# echo "--------------------------------------------------------------------------------";
# echo "OPENSSL VERSION:";
# openssl version;
# echo "--------------------------------------------------------------------------------";

# echo "--------------------------------------------------------------------------------";
# echo "AWK VERSION:";
# awk --version;
# echo "--------------------------------------------------------------------------------";

# echo "--------------------------------------------------------------------------------";
# echo "GAWK VERSION:";
# gawk --version;
# echo "--------------------------------------------------------------------------------";

# echo "--------------------------------------------------------------------------------";
# echo "MAWK VERSION:";
# mawk --version;
# echo "--------------------------------------------------------------------------------";

# echo "--------------------------------------------------------------------------------";
# echo "SPLIT VERSION:";
# split --version;
# echo "--------------------------------------------------------------------------------";

# ./gradlew clean build ${GRADLE_ARGS}; # 'build' includes 'test'
# checkResult $? ${CONFIRM};

# if [[ -d "agency-parser" ]]; then
# && [[ $GIT_BRANCH != "master" ]]
echo "> CLEANING FOR '$AGENCY_ID' (GRADLE BUILD)...";

./gradlew :commons-java:clean ${GRADLE_ARGS};
checkResult $? ${CONFIRM};

./gradlew :parser:clean ${GRADLE_ARGS};
checkResult $? ${CONFIRM};

if [[ -d "agency-parser" ]]; then
	./gradlew :agency-parser:clean ${GRADLE_ARGS};
	checkResult $? ${CONFIRM};
fi

echo "> CLEANING FOR '$AGENCY_ID' (GRADLE BUILD)... DONE";

	# echo "> DOWNLOADING DATA FOR '$AGENCY_ID'...";
	# cd agency-parser || exit; # >>

	# ./download.sh;
	# checkResult $? ${CONFIRM};

	# ./unzip_gtfs.sh;
	# checkResult $? ${CONFIRM};

	# echo "> DOWNLOADING DATA FOR '$AGENCY_ID'... DONE";

echo "> BUILDING FOR '$AGENCY_ID' (GRADLE BUILD)... ";
./gradlew :commons-java:build ${GRADLE_ARGS}; # includes test
checkResult $? ${CONFIRM};

./gradlew :parser:build ${GRADLE_ARGS}; # includes test
checkResult $? ${CONFIRM};

if [[ -d "agency-parser" ]]; then
	./gradlew :agency-parser:build ${GRADLE_ARGS};
	checkResult $? ${CONFIRM};
fi

echo "> BUILDING FOR '$AGENCY_ID' (GRADLE BUILD)... DONE";

	# echo "> PARSING DATA FOR '$AGENCY_ID'...";

    # # CURRENT...
	# ../gradlew :agency-parser:build ${GRADLE_ARGS};
	# checkResult $? ${CONFIRM};

	# ./parse_current.sh;
	# checkResult $? ${CONFIRM};
	# # CURRENT... DONE

	# # NEXT...
	# ../gradlew :agency-parser:build ${GRADLE_ARGS};
	# checkResult $? ${CONFIRM};

	# ./parse_next.sh;
	# checkResult $? ${CONFIRM};
	# # NEXT... DONE

	# ./list_change.sh;
	# checkResult $? ${CONFIRM};

	# cd ..; # <<
	# echo "> PARSING DATA FOR '$AGENCY_ID'... DONE";
# else
# 	echo "> SKIP PARSING FOR '$AGENCY_ID'.";
# 	#  (branch:$GIT_BRANCH)
# fi

echo "> BUILDING ANDROID APP FOR '$AGENCY_ID'...";
cd app-android || exit;

# ./build.sh
# checkResult $? ${CONFIRM};

echo ">> Setup-ing keys...";
./keys_setup.sh;
checkResult $?;
echo ">> Setup-ing keys... DONE";

echo ">> Gradle cleaning...";
../gradlew ${SETTINGS_FILE_ARGS} :app-android:clean ${GRADLE_ARGS};
RESULT=$?;
checkResult ${RESULT};
echo ">> Gradle cleaning... DONE";

echo ">> Running test...";
../gradlew ${SETTINGS_FILE_ARGS} :commons-android:testDebugUnitTest :app-android:testDebugUnitTest ${GRADLE_ARGS};
RESULT=$?;
checkResult ${RESULT};
echo ">> Running test... DONE";

echo ">> Running lint...";
../gradlew ${SETTINGS_FILE_ARGS} :app-android:lintDebug ${GRADLE_ARGS};
RESULT=$?;
checkResult ${RESULT};
echo ">> Running lint... DONE";

echo ">> Running assemble & bundle...";
../gradlew ${SETTINGS_FILE_ARGS} assembleDebug bundleDebug ${GRADLE_ARGS};
RESULT=$?;
checkResult ${RESULT};
echo ">> Running assemble & bundle... DONE";

echo ">> Cleaning keys...";
./keys_cleanup.sh;
checkResult $?;
echo ">> Cleaning keys... DONE";

cd ..;
echo "> BUILDING ANDROID APP FOR '$AGENCY_ID'... DONE";
echo "--------------------------------------------------------------------------------";

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> RUN ALL... DONE";
echo "================================================================================";
