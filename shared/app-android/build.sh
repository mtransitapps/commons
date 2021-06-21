#!/bin/bash
source ../commons/commons.sh
echo ">> Building...";

DIRECTORY=$(basename ${PWD});
CUSTOM_SETTINGS_GRADLE_FILE="../settings.gradle.all";

GIT_URL=$(git config --get remote.origin.url); # remote get-url origin
echo ">> Git URL: '$GIT_URL'.";
GIT_PROJECT_NAME=$(basename -- ${GIT_URL});
GIT_PROJECT_NAME="${GIT_PROJECT_NAME%.*}"
echo ">> Git project name: '$GIT_PROJECT_NAME'.";
if [[ -z "${GIT_PROJECT_NAME}" ]]; then
	echo "GIT_PROJECT_NAME not found!";
	exit 1;
fi

setIsCI;

setGradleArgs;

SETTINGS_FILE_ARGS="";
if [[ -f ${CUSTOM_SETTINGS_GRADLE_FILE} ]]; then
	SETTINGS_FILE_ARGS=" -c $CUSTOM_SETTINGS_GRADLE_FILE"; #--settings-file
fi

echo ">> Setup-ing keys...";
./keys_setup.sh;
checkResult $?;
echo ">> Setup-ing keys... DONE";

echo ">> Gradle cleaning...";
../gradlew ${SETTINGS_FILE_ARGS} clean ${GRADLE_ARGS};
RESULT=$?;
checkResult ${RESULT};
echo ">> Gradle cleaning... DONE";

if [[ ${IS_CI} = true ]]; then
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

# declare -a SONAR_PROJECTS=(
# "mtransit-for-android"
# "commons-android"
# );
# if contains ${GIT_PROJECT_NAME} ${SONAR_PROJECTS[@]}; then
# if [[ -z "${MT_SONAR_LOGIN}" ]]; then
# echo "MT_SONAR_LOGIN environment variable is NOT defined!";
# exit 1;
# fi
# if [[ ! -z "${CIRCLECI}" ]]; then
# GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD);
# if [[ "$GIT_BRANCH" = "HEAD" ]]; then
# GIT_BRANCH="";
# fi
# if [[ -z "${GIT_BRANCH}" ]]; then
# GIT_BRANCH=${CIRCLE_BRANCH}; #CircleCI
# if [[ "$GIT_BRANCH" = "HEAD" ]]; then
# GIT_BRANCH="";
# fi
# fi
# SONAR_ARGS="";
# SONAR_ARGS+=" -Dsonar.organization=mtransitapps-github";
# SONAR_ARGS+=" -Dsonar.projectKey=mt:${GIT_PROJECT_NAME}";
# SONAR_ARGS+=" -Dsonar.projectName=MT:${GIT_PROJECT_NAME}";
# SONAR_ARGS+=" -Dsonar.host.url=https://sonarcloud.io";
# echo ">> Sonar args: '$SONAR_ARGS'.";
# SONAR_PR_ARGS="";
# if [[ ! -z "${CIRCLE_PULL_REQUEST}" ]]; then
# # https://docs.sonarqube.org/latest/analysis/pull-request/
# TARGET_BRANCH="mmathieum"; # not provided by CircleCI https://ideas.circleci.com/ideas/CCI-I-894
# # TO DO IF hotfix/... || develop -> master ELSE feature/... -> develop
# PR_NUMBER=${CIRCLE_PULL_REQUEST##*/};
# echo ">> Git PR number: '$PR_NUMBER'.";
# SONAR_PR_ARGS+=" -Dsonar.pullrequest.base=${TARGET_BRANCH}";
# SONAR_PR_ARGS+=" -Dsonar.pullrequest.branch=${GIT_BRANCH}";
# SONAR_PR_ARGS+=" -Dsonar.pullrequest.key=${PR_NUMBER}";
# fi
# echo ">> Sonar PR args: '$SONAR_PR_ARGS'.";
# echo ">> Running sonar...";
# ../gradlew ${SETTINGS_FILE_ARGS} :${DIRECTORY}:sonarqube \
# $SONAR_ARGS \
# -Dsonar.login=${MT_SONAR_LOGIN} \
# $SONAR_PR_ARGS \
# ${GRADLE_ARGS}
# RESULT=$?;
# checkResult ${RESULT};
# echo ">> Running sonar... DONE";
# fi
# else
# echo ">> Skipping sonar for '$GIT_PROJECT_NAME'.";
# fi

    echo ">> Running assemble & bundle...";
	../gradlew ${SETTINGS_FILE_ARGS} assembleDebug bundleDebug ${GRADLE_ARGS};
	RESULT=$?;
	checkResult ${RESULT};
	echo ">> Running assemble & bundle... DONE";
fi

echo ">> Running bundle release AAB...";
../gradlew ${SETTINGS_FILE_ARGS} :${DIRECTORY}:bundleRelease ${GRADLE_ARGS};
RESULT=$?;
checkResult ${RESULT};
echo ">> Running bundle release AAB... DONE";

if [[ ${IS_CI} = false ]]; then
	echo ">> Running assemble release APK...";
	../gradlew ${SETTINGS_FILE_ARGS} :${DIRECTORY}:assembleRelease -PuseGooglePlayUploadKeysProperties=false ${GRADLE_ARGS};
	RESULT=$?;
	checkResult ${RESULT};
	echo ">> Running assemble release APK... DONE";
fi

if [[ ! -z "${MT_OUTPUT_DIR}" ]]; then
	echo ">> Copying release artifacts to output dir '${MT_OUTPUT_DIR}'...";
	if ! [[ -d "${MT_OUTPUT_DIR}" ]]; then
		echo ">> Output release '${MT_OUTPUT_DIR}' not found!";
		exit 1;
	fi
	cp build/outputs/bundle/release/*.aab ${MT_OUTPUT_DIR};
	checkResult $?;
	cp build/outputs/apk/release/*.apk ${MT_OUTPUT_DIR};
	checkResult $?;
	echo ">> Copying release artifacts to output dir '${MT_OUTPUT_DIR}'... DONE";
fi

echo ">> Cleaning keys...";
./keys_cleanup.sh;
checkResult $?;
echo ">> Cleaning keys... DONE";

echo ">> Building... DONE";
exit ${RESULT};
