#!/bin/bash
# ORIGINAL FILE: https://github.com/mtransitapps/commons/tree/master/shared-overwrite
#NO DEPENDENCY <= EXECUTED BEFORE GIT SUBMODULE

echo "> GitHub Actions: $GITHUB_ACTIONS.";

IS_SHALLOW=$(git rev-parse --is-shallow-repository);
if [[ "$IS_SHALLOW" == true && "$GITHUB_ACTIONS" == false ]]; then
	echo "> Fetching un-shallow GIT repo...";
	git fetch -v --unshallow;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo "> Error while fetching un-shallow GIT repository!";
		exit ${RESULT};
	fi
	echo "> Fetching un-shallow GIT repo... DONE";
else
	echo "> Not a shallow GIT repo.";
fi

GIT_REPO_URL=$(git config --get remote.origin.url);
echo "> Git repo URL: '$GIT_REPO_URL'.";

declare -a SUBMODULES=(
	"commons"
	"commons-java"
	"commons-android"
);
if [[ $GIT_REPO_URL == *"android-gradle"* ]]; then
	SUBMODULES+=('app-android'); # OLD REPO
fi
if [[ -d "parser" ]]; then
    SUBMODULES+=('parser');
	if [[ $GIT_REPO_URL == *"android-gradle"* ]]; then
		SUBMODULES+=('agency-parser'); # OLD REPO
	fi
fi
echo "Submodules:";
printf '* "%s"\n' "${SUBMODULES[@]}";

for SUBMODULE in "${SUBMODULES[@]}" ; do
	if ! [[ -d "$SUBMODULE" ]]; then
		echo "> Submodule does NOT exist '$SUBMODULE'!";
		exit 1;
	fi
	git submodule update --init --recursive ${SUBMODULE};
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo "Error while update GIT submodule '$SUBMODULE'!";
		exit ${RESULT};
	fi
	echo "'$SUBMODULE' updated successfully."
done
