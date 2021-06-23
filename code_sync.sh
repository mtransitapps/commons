#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/commons.sh;

echo "================================================================================";
echo "> CODE SYNC...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});

echo "Current directory: '$CURRENT_DIRECTORY'";

# GIT SUBMODULEs

GIT_URL=$(git config --get remote.origin.url); # remote get-url origin
echo "> Git URL: '$GIT_URL'.";
GIT_PROJECT_NAME=$(basename -- ${GIT_URL});
GIT_PROJECT_NAME="${GIT_PROJECT_NAME%.*}"
echo "> Git project name: '$GIT_PROJECT_NAME'.";
if [[ -z "${GIT_PROJECT_NAME}" ]]; then
	echo "GIT_PROJECT_NAME not found!";
	exit 1;
fi

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD);
if [[ "$GIT_BRANCH" = "HEAD" ]]; then
	GIT_BRANCH="";
fi
if [[ -z "${MT_GIT_BRANCH}" ]]; then
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

setIsCI;
echo "IS_CI: $IS_CI";

echo "MT_ORG_GIT_COMMIT_ON: '$MT_ORG_GIT_COMMIT_ON'." # allowed
echo "MT_ORG_GIT_COMMIT_OFF: '$MT_ORG_GIT_COMMIT_OFF'." # forbidden
echo "MT_GIT_COMMIT_ON: '$MT_GIT_COMMIT_ON'." # allowed
echo "MT_GIT_COMMIT_OFF: '$MT_GIT_COMMIT_OFF'." # forbidden

if [[ ${MT_ORG_GIT_COMMIT_OFF} = false ]]; then
  echo "> Git commit disabled (org).. SKIP";
  exit 0 # success
fi

if [[ ${MT_GIT_COMMIT_OFF} = false ]]; then
  echo "> Git commit disabled (project).. SKIP";
  exit 0 # success
fi

if [[ ${MT_ORG_GIT_COMMIT_ON} != true && $MT_GIT_COMMIT_ON != true ]]; then
  echo "> Git commit not enabled (org:'$MT_ORG_GIT_COMMIT_ON'|project:'$MT_GIT_COMMIT_ON').. SKIP";
  exit 0 # success
fi

echo "> Git commit enabled ...";

echo "--------------------------------------------------------------------------------";
echo "> Checkout branch '$GIT_BRANCH'...";
# git checkout $GIT_BRANCH;
# RESULT=$?;
# if [[ ${RESULT} -ne 0 ]]; then
# 	echo "> Error while checking out '$GIT_BRANCH' in main repo!";
# 	exit ${RESULT};
# fi
git submodule foreach git checkout $GIT_BRANCH;
RESULT=$?;
if [[ ${RESULT} -ne 0 ]]; then
	echo "> Error while checking out '$GIT_BRANCH' in submodules!";
	exit ${RESULT};
fi
echo "> Checkout branch '$GIT_BRANCH'... DONE";
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
echo "> Pulling latest from branch '$GIT_BRANCH'...";
# git pull;
# RESULT=$?;
# if [[ ${RESULT} -ne 0 ]]; then
# 	echo "> Error while pulling latest from '$GIT_BRANCH' in main repo!";
# 	exit ${RESULT};
# fi
git submodule foreach git pull;
RESULT=$?;
if [[ ${RESULT} -ne 0 ]]; then
	echo "> Error while pulling latest from '$GIT_BRANCH' in submodules!";
	exit ${RESULT};
fi
echo "> Pulling latest from branch '$GIT_BRANCH'... DONE";
echo "--------------------------------------------------------------------------------";

# IS_SHALLOW=$(git rev-parse --is-shallow-repository);
# if [[ "$IS_SHALLOW" == true ]]; then
# 	echo "> Fetching unshallow GIT repo...";
# 	git fetch --unshallow;
# 	RESULT=$?;
# 	if [[ ${RESULT} -ne 0 ]]; then
# 		echo "> Error while fetching unshallow GIT repository!";
# 		exit ${RESULT};
# 	fi
# 	echo "> Fetching unshallow GIT repo... DONE";
# else
# 	echo "> Not a shallow GIT repo.";
# fi
#
# INIT_SUBMODULE=false;
# if [[ -f "$CURRENT_PATH/.gitmodules" ]]; then
# 	INIT_SUBMODULE=false;
# else
# 	INIT_SUBMODULE=true;
# fi
#
# declare -a SUBMODULES=(
# 	"commons"
# 	"commons-java"
# 	"commons-android"
# 	"app-android"
# );
# PROJECT_NAME="${GIT_PROJECT_NAME:0:$((${#GIT_PROJECT_NAME} - 7))}";
# declare -a SUBMODULES_REPO=(
# 	"commons"
# 	"commons-java"
# 	"commons-android"
# );
# if [[ $PROJECT_NAME == *android ]]; then
# 	SUBMODULES_REPO+=($PROJECT_NAME);
# else
# 	SUBMODULES_REPO+=("$PROJECT_NAME-android");
# fi
# if [[ $PROJECT_NAME == "mtransit-for-android" ]]; then
# 	echo "> Main android app: '$PROJECT_NAME' > parser NOT required";
# elif [[ $PROJECT_NAME == *bike ]]; then
# 	echo "> Bike android app: '$PROJECT_NAME' > parser NOT required";
# else
# 	echo "> Bus/Train/... android app: '$PROJECT_NAME' > parser required";
# 	SUBMODULES+=('parser');
# 	SUBMODULES_REPO+=('parser');
# 	SUBMODULES+=('agency-parser');
# 	SUBMODULES_REPO+=("${PROJECT_NAME}-parser");
# fi
# echo "> Submodules:";
# printf '> - "%s"\n' "${SUBMODULES[@]}";
#
# for S in "${!SUBMODULES[@]}"; do
# 	SUBMODULE=${SUBMODULES[$S]}
# 	SUBMODULE_REPO=${SUBMODULES_REPO[$S]}
# 	echo "--------------------------------------------------------------------------------";
# 	if [[ -z "${SUBMODULE_REPO}" ]]; then
# 		echo "SUBMODULE_REPO empty!";
# 		exit 1;
# 	fi
# 	if [[ "$INIT_SUBMODULE" == true ]]; then # ADDNING GIT SUBMODULE
# 		if [[ -d "$CURRENT_PATH/$SUBMODULE" ]]; then
# 			echo "> Cannot override '$CURRENT_PATH/$SUBMODULE'!";
# 			exit 1;
# 		fi
# 		echo "> Adding submodule '$SUBMODULE_REPO' in '$SUBMODULE'...";
# 		git submodule add git://github.com/mtransitapps/$SUBMODULE_REPO.git $SUBMODULE;
# 		RESULT=$?;
# 		if [[ ${RESULT} -ne 0 ]]; then
# 			echo "> Error while cloning '$SUBMODULE_REPO' submodule in '$SUBMODULE'!";
# 			exit ${RESULT};
# 		fi
# 		echo "> Adding submodule '$SUBMODULE_REPO' in '$SUBMODULE'... DONE";
# 	fi
# 	if ! [[ -d "$CURRENT_PATH/$SUBMODULE" ]]; then
# 		echo "> Submodule directory '$CURRENT_PATH/$SUBMODULE' does NOT exist!";
# 		exit 1;
# 	fi
# 	cd $CURRENT_PATH/$SUBMODULE || exit; # >>
# 	if [[ ${IS_CI} = false ]]; then
# 		echo "> Setting submodule remote URL '$SUBMODULE_REPO' in '$SUBMODULE'...";
# 		git remote set-url origin git@github.com:mtransitapps/$SUBMODULE_REPO.git;
# 		RESULT=$?;
# 		if [[ ${RESULT} -ne 0 ]]; then
# 			echo "> Error while setting remote URL for '$SUBMODULE_REPO' submodule in '$SUBMODULE'!";
# 			exit ${RESULT};
# 		fi
# 		echo "> Setting submodule remote URL '$SUBMODULE_REPO' in '$SUBMODULE'... DONE";
# 	fi
# 	echo "> Setting submodule branch '$GIT_BRANCH' in '$SUBMODULE'...";
# 	git checkout $GIT_BRANCH;
# 	RESULT=$?;
# 	if [[ ${RESULT} -ne 0 ]]; then
# 		echo "> Error while checking out '$GIT_BRANCH' in '$SUBMODULE_REPO' submodule in '$SUBMODULE'!";
# 		exit ${RESULT};
# 	fi
# 	git pull;
# 	RESULT=$?;
# 	if [[ ${RESULT} -ne 0 ]]; then
# 		echo "> Error while pulling latest changes from '$GIT_BRANCH' in '$SUBMODULE_REPO' submodule in '$SUBMODULE'!";
# 		exit ${RESULT};
# 	fi
# 	echo "> Setting submodule branch '$GIT_BRANCH' in '$SUBMODULE'... DONE";
# 	cd $CURRENT_PATH || exit; # <<
# 	echo "--------------------------------------------------------------------------------";
# done
#
# DEST_PATH=".";
#
# function canOverwriteFile() {
# 	if [[ "$#" -ne 2 ]]; then
# 		echo "> canOverwriteFile() > Illegal number of parameters!";
# 		exit 1;
# 	fi
# 	local SRC_FILE_PATH=$1;
# 	local DEST_FILE_PATH=$2;
# 	local FILE_NAME=$(basename ${SRC_FILE_PATH});
# 	if [[ -f "$DEST_FILE_PATH" ]]; then
# 		diff -q ${SRC_FILE_PATH} ${DEST_FILE_PATH};
# 		local RESULT=$?;
# 		if [[ ${RESULT} -ne 0 ]]; then # FILE CHANGED
# 			if [[ $FILE_NAME == ".gitignore" ]]; then
# 				echo "> Changed '$FILE_NAME' removed ('$SRC_FILE_PATH'=>'$DEST_FILE_PATH')!";
# 				rm ${DEST_FILE_PATH};
# 				checkResult $?;
# 			else
# 				echo "> File '$DEST_FILE_PATH' exists & was changed from '$SRC_FILE_PATH'!";
# 				ls -l $DEST_FILE_PATH;
# 				ls -l $SRC_FILE_PATH;
# 				diff ${SRC_FILE_PATH} ${DEST_FILE_PATH};
# 				exit ${RESULT};
# 			fi
# 		fi
# 	fi
# }
#
# function deployFile() {
# 	if [[ "$#" -lt 2 ]]; then
# 		echo "> deployFile() > Illegal number of parameters!";
# 		exit 1;
# 	fi
# 	local SRC_FILE_PATH=$1;
# 	local DEST_FILE_PATH=$2;
# 	local OVER_WRITE=false; # do not over-write by default
# 	if [[ "$#" -ge 3 ]]; then
# 		OVER_WRITE=$3;
# 	fi
# 	echo "--------------------------------------------------------------------------------";
# 	if [[ "$OVER_WRITE" == true ]]; then
# 		if [[ -f "${DEST_FILE_PATH}" ]]; then
# 			rm ${DEST_FILE_PATH};
# 			checkResult $?;
# 		fi
# 	else
# 		canOverwriteFile ${SRC_FILE_PATH} ${DEST_FILE_PATH};
# 		checkResult $?;
# 	fi
# 	echo "> Deploying file '$SRC_FILE_PATH'...";
# 	cp -n -p $SRC_FILE_PATH $DEST_FILE_PATH;
# 	local RESULT=$?;
# 	if [[ ${RESULT} -ne 0 ]]; then
# 		echo "> Error while deploying file '$SRC_FILE_PATH'!";
# 		exit ${RESULT};
# 	fi
# 	echo "> Deploying file '$SRC_FILE_PATH'... DONE";
# 	echo "--------------------------------------------------------------------------------";
# }
#
# function canOverwriteDirectory() {
# 	if [[ "$#" -ne 2 ]]; then
# 		echo "> canOverwriteDirectory() > Illegal number of parameters!";
# 		exit 1;
# 	fi
# 	local SRC_FILE_PATH=$1;
# 	local DEST_FILE_PATH=$2;
# 	local DIR_NAME=$(basename ${SRC_FILE_PATH});
# 	if [[ -d "$DEST_FILE_PATH" ]]; then
# 		diff -q -r ${SRC_FILE_PATH} ${DEST_FILE_PATH};
# 		local RESULT=$?;
# 		if [[ ${RESULT} -ne 0 ]]; then # DIR CHANGED
# 			echo "> Directory '$DEST_FILE_PATH' exists & was changed from '$SRC_FILE_PATH'!";
# 			ls -l $DEST_FILE_PATH;
# 			ls -l $SRC_FILE_PATH;
# 			diff -r ${SRC_FILE_PATH} ${DEST_FILE_PATH};
# 			exit ${RESULT};
# 		fi
# 	fi
# }
#
# function deployDirectory() {
# 	if [[ "$#" -lt 2 ]]; then
# 		echo "> deployDirectory() > Illegal number of parameters!";
# 		exit 1;
# 	fi
# 	local SRC_FILE_PATH=$1;
# 	local DEST_FILE_PATH=$2;
# 	local OVER_WRITE=false; # do not over-write by default
# 	if [[ "$#" -ge 3 ]]; then
# 		OVER_WRITE=$3;
# 	fi
# 	local OPT_DIR=false; # do create directory by default
# 	if [[ "$#" -ge 4 ]]; then
# 		OPT_DIR=$4;
# 	fi
# 	echo "--------------------------------------------------------------------------------";
# 	echo "> Deploying directory '${SRC_FILE_PATH}'...";
# 	if ! [[ -d "$DEST_FILE_PATH" ]]; then
# 		if [[ "$OPT_DIR" == true ]]; then
# 			echo "> Skip optional directory '$DEST_FILE_PATH' in target directory.";
# 			return;
# 		fi
# 		mkdir $DEST_FILE_PATH;
# 		local RESULT=$?;
# 		if [[ ${RESULT} -ne 0 ]]; then
# 			echo "> Error while creating directory '$DEST_FILE_PATH' in target directory!";
# 			exit ${RESULT};
# 		fi
# 	fi
# 	local S_FILE_NAME;
# 	for S_FILE_NAME in $(ls -a ${SRC_FILE_PATH}/) ; do
# 		local S_SRC_FILE_PATH=${SRC_FILE_PATH}/$S_FILE_NAME;
# 		if [[ $S_FILE_NAME == "." ]] || [[ $S_FILE_NAME == ".." ]]; then
# 			continue;
# 		fi
# 		local S_DEST_FILE_PATH="$DEST_FILE_PATH/$S_FILE_NAME";
# 		if [[ -f $S_SRC_FILE_PATH ]]; then
# 			deployFile ${S_SRC_FILE_PATH} ${S_DEST_FILE_PATH} ${OVER_WRITE};
# 			checkResult $?;
# 		elif [[ -d "$S_SRC_FILE_PATH" ]]; then
# 			deployDirectory ${S_SRC_FILE_PATH} ${S_DEST_FILE_PATH} ${OVER_WRITE}; # ${OPT_DIR} only for 1st level
# 			checkResult $?;
# 		else #WTF
# 			echo "--------------------------------------------------------------------------------";
# 			echo "> File to deploy '$S_FILE_NAME' ($S_SRC_FILE_PATH) is neither a directory or a file!";
# 			ls -l ${S_FILE_NAME};
# 			exit 1;
# 		fi
# 	done
# 	echo "> Deploying directory '${SRC_FILE_PATH}'... DONE";
# 	echo "--------------------------------------------------------------------------------";
# }
#
# echo "--------------------------------------------------------------------------------";
# echo "> Deploying overwriten shared files...";
# SRC_DIR_PATH="commons/shared-overwrite";
# for FILENAME in $(ls -a $SRC_DIR_PATH/) ; do
# 	SRC_FILE_PATH=$SRC_DIR_PATH/$FILENAME;
# 	if [[ $FILENAME == "." ]] || [[ $FILENAME == ".." ]]; then
# 		continue;
# 	fi
# 	DEST_FILE_PATH="$DEST_PATH/$FILENAME"
# 	if [[ -f $SRC_FILE_PATH ]]; then
# 		deployFile ${SRC_FILE_PATH} ${DEST_FILE_PATH} true; #DO over-write
# 		checkResult $?;
# 	elif [[ -d "$SRC_FILE_PATH" ]]; then
# 		deployDirectory ${SRC_FILE_PATH} ${DEST_FILE_PATH} true; #DO over-write
# 		checkResult $?;
# 	else #WTF
# 		echo "> File to deploy '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
# 		ls -l $FILENAME;
# 		exit 1;
# 	fi
# done
# echo "> Deploying overwriten shared files... DONE";
# echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> CODE SYNC... DONE";
echo "================================================================================";
