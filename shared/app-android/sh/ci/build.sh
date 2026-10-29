#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../../.."; ROOT_DIR=$(realpath --relative-to="$ROOT_DIR" "$ROOT_DIR");

source ${ROOT_DIR}/commons/sh/commons.sh

echo ">> Building...";
# TODO REMOVE (DEPRECATED, USE other scripts) (used by CircleCI & GitLab CI)

setGitProjectName;

setIsCI;

setGradleArgs;

echo ">> Gradle cleaning...";
${ROOT_DIR}/gradlew clean ${GRADLE_ARGS};
RESULT=$?;
checkResult ${RESULT};
echo ">> Gradle cleaning... DONE";

if [[ ${IS_CI} = true ]]; then
    echo ">> Running test...";
	${ROOT_DIR}/gradlew -p ../ testAll ${GRADLE_ARGS};
	RESULT=$?;
	checkResult ${RESULT};
    echo ">> Running test... DONE";

    echo ">> Running lint...";
	${ROOT_DIR}/gradlew :app-android:lintDebug ${GRADLE_ARGS};
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
# if [[ -n "${CIRCLECI}" ]]; then
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
# if [[ -n "${CIRCLE_PULL_REQUEST}" ]]; then
# # https://docs.sonarqube.org/latest/analysis/pull-request/
# TARGET_BRANCH="TODO"; # not provided by CircleCI https://ideas.circleci.com/ideas/CCI-I-894
# # TO DO IF hotfix/... || develop -> master ELSE feature/... -> develop
# PR_NUMBER=${CIRCLE_PULL_REQUEST##*/};
# echo ">> Git PR number: '$PR_NUMBER'.";
# SONAR_PR_ARGS+=" -Dsonar.pullrequest.base=${TARGET_BRANCH}";
# SONAR_PR_ARGS+=" -Dsonar.pullrequest.branch=${GIT_BRANCH}";
# SONAR_PR_ARGS+=" -Dsonar.pullrequest.key=${PR_NUMBER}";
# fi
# echo ">> Sonar PR args: '$SONAR_PR_ARGS'.";
# echo ">> Running sonar...";
# ${ROOT_DIR}/gradlew :app-android:sonarqube \
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
	${ROOT_DIR}/gradlew :app-android:assembleDebug :app-android:bundleDebug ${GRADLE_ARGS};
	RESULT=$?;
	checkResult ${RESULT};
	echo ">> Running assemble & bundle... DONE";
fi

APP_ANDROID_DIR="${ROOT_DIR}/app-android";

if [[ ${IS_CI} = false ]]; then

	$APP_ANDROID_DIR/sh/keys/setup.sh;
	checkResult $?;

	echo ">> Running bundle release AAB...";
	${ROOT_DIR}/gradlew :app-android:bundleRelease --no-scan; # no ${GRADLE_ARGS} for release
	RESULT=$?;
	checkResult ${RESULT};
	echo ">> Running bundle release AAB... DONE";


	echo ">> Running assemble release APK...";
	${ROOT_DIR}/gradlew :app-android:assembleRelease --no-scan -PuseGooglePlayUploadKeysProperties=false; # no ${GRADLE_ARGS} for release
	RESULT=$?;
	checkResult ${RESULT};
	echo ">> Running assemble release APK... DONE";

	if [[ -n "${MT_OUTPUT_DIR}" ]]; then
		echo ">> Copying release artifacts to output dir '${MT_OUTPUT_DIR}'...";
		if ! [[ -d "${MT_OUTPUT_DIR}" ]]; then
			echo ">> Output release '${MT_OUTPUT_DIR}' not found!";
			exit 1;
		fi
		cp ${ROOT_DIR}/build/outputs/bundle/release/*.aab ${MT_OUTPUT_DIR};
		checkResult $?;
		cp ${ROOT_DIR}/build/outputs/apk/release/*.apk ${MT_OUTPUT_DIR};
		checkResult $?;
		echo ">> Copying release artifacts to output dir '${MT_OUTPUT_DIR}'... DONE";
	fi

	$APP_ANDROID_DIR/sh/keys/cleanup.sh;
	checkResult $?;

fi

echo ">> Building... DONE";
exit ${RESULT};
