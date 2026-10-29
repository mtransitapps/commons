#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../.."; ROOT_DIR=$(realpath --relative-to="$PWD" "$ROOT_DIR");

source "${ROOT_DIR}/commons/sh/commons.sh";

echo "================================================================================";
echo "> GIT SETUP...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

setGitProjectName;

setIsCI;

IS_SHALLOW=$(git -C "$ROOT_DIR" rev-parse --is-shallow-repository);
if [[ "$IS_SHALLOW" == true && "${GITHUB_ACTIONS}" == false ]]; then
	echo "> Fetching unshallow GIT repo...";
	git -C "$ROOT_DIR" fetch -v --unshallow;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo "> Error while fetching unshallow GIT repository!";
		exit ${RESULT};
	fi
	echo "> Fetching unshallow GIT repo... DONE ✓";
else
	echo "> Not a shallow GIT repo ✓";
fi

INIT_SUBMODULE=false;
if [[ -f "$ROOT_DIR/.gitmodules" ]]; then
	INIT_SUBMODULE=false;
else
	INIT_SUBMODULE=true;
fi

# SHARED SUBMODULES
declare -a SUBMODULES=(
	"commons"
	"commons-java"
	"commons-android"
);
declare -a SUBMODULES_REPO=(
	"commons"
	"commons-java"
	"commons-android"
);

# PARSER
if [[ $PROJECT_NAME == "mtransit-for-android" ]]; then
	echo "> Main android app: '$PROJECT_NAME' > parser required ✓";
	SUBMODULES+=('parser');
	SUBMODULES_REPO+=('parser');
elif [[ $PROJECT_NAME == *"-bike"* ]]; then
	echo "> Bike android app: '$PROJECT_NAME' > parser NOT required ✓";
else
	echo "> Bus/Train/... android app: '$PROJECT_NAME' > parser required ✓";
	SUBMODULES+=('parser');
	SUBMODULES_REPO+=('parser');
	mkdir -p agency-parser/archive; # needed for shared-opt-dir #InitRepo
	if [[ "$INIT_SUBMODULE" == true ]]; then
		git lfs track agency-parser/archive/*;
	fi
fi


printf "> Submodules: ";
printf "'%s', " "${SUBMODULES[@]}" | sed 's/, $//';
printf " ✓\n";

for S in "${!SUBMODULES[@]}"; do
	SUBMODULE=${SUBMODULES[$S]}
	SUBMODULE_REPO=${SUBMODULES_REPO[$S]}
	# echo "--------------------------------------------------------------------------------";
	if [[ -z "${SUBMODULE_REPO}" ]]; then
		echo "SUBMODULE_REPO empty!";
		exit 1;
	fi
	if [[ "$INIT_SUBMODULE" == true ]]; then # ADDNING GIT SUBMODULE
		if [[ -d "$ROOT_DIR/$SUBMODULE" ]]; then
			echo "> Cannot override '$ROOT_DIR/$SUBMODULE'!";
			exit 1;
		fi
		REPO_URL="https://github.com/mtransitapps/$SUBMODULE_REPO.git";
		echo "> Adding submodule '$REPO_URL' in '$ROOT_DIR/$SUBMODULE'...";
		git -C "$ROOT_DIR" submodule add $REPO_URL $SUBMODULE; # GitHub secret PAT
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo "> Error while adding submodule '$REPO_URL' in '$ROOT_DIR/$SUBMODULE'!";
			exit ${RESULT};
		fi
		echo "> Adding submodule '$REPO_URL' in '$ROOT_DIR/$SUBMODULE'... DONE ✓";
	fi
	if ! [[ -d "$ROOT_DIR/$SUBMODULE" ]]; then
		echo "> Submodule directory '$ROOT_DIR/$SUBMODULE' does NOT exist!";
		exit 1;
	fi
	CURRENT_REMOTE_URL=$(git -C "$ROOT_DIR/$SUBMODULE" remote get-url origin);
	if [[ ${IS_CI} = false ]]; then
		NEW_REMOTE_URL="git@github.com:mtransitapps/$SUBMODULE_REPO.git";
		if [[ "$CURRENT_REMOTE_URL" == "$NEW_REMOTE_URL" ]]; then
			echo "> Submodule '$SUBMODULE' > remote URL is already set to '$NEW_REMOTE_URL' ✓";
		else
			echo "> Submodule '$SUBMODULE' > setting remote URL '$NEW_REMOTE_URL' in '$SUBMODULE'...";
			git -C "$ROOT_DIR/$SUBMODULE" remote -v set-url origin $NEW_REMOTE_URL;
			RESULT=$?;
			if [[ ${RESULT} -ne 0 ]]; then
				echo "> Submodule '$SUBMODULE' > ERROR while setting remote URL for '$NEW_REMOTE_URL'!";
				exit ${RESULT};
			fi
			echo "> Submodule '$SUBMODULE' > setting remote URL '$NEW_REMOTE_URL' in '$SUBMODULE'... DONE ✓";
		fi;
	elif [[ "$GITHUB_ACTIONS" == true ]]; then
		# NEW_REMOTE_URL="https://github.com/mtransitapps/$SUBMODULE_REPO.git;";
		NEW_REMOTE_URL="git@github.com:mtransitapps/$SUBMODULE_REPO.git";
		if [[ "$CURRENT_REMOTE_URL" == "$NEW_REMOTE_URL" ]]; then
			echo "> Submodule '$SUBMODULE' > remote URL is already set to '$NEW_REMOTE_URL' ✓";
		else
			echo "> Setting submodule remote URL '$NEW_REMOTE_URL' in '$SUBMODULE'...";
			git -C "$ROOT_DIR/$SUBMODULE" remote -v set-url origin $NEW_REMOTE_URL;
			RESULT=$?;
			if [[ ${RESULT} -ne 0 ]]; then
				echo "> Submodule '$SUBMODULE' > ERROR while setting remote URL for '$NEW_REMOTE_URL'!";
				exit ${RESULT};
			fi
			echo "> Submodule '$SUBMODULE' > setting remote URL '$NEW_REMOTE_URL' in '$SUBMODULE'... DONE ✓";
		fi
	fi
	# echo "--------------------------------------------------------------------------------";
done

echo "--------------------------------------------------------------------------------";
AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> GIT SETUP... DONE ✓";
echo "================================================================================";
