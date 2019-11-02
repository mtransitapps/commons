#!/bin/bash
#NO DEPENDENCY <= EXECUTED BEFORE GIT SUBMODULE

echo "================================================================================";
echo "> SYNC...";
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

IS_CI=false;
if [[ ! -z "${CI}" ]]; then
	IS_CI=true;
fi
echo "/build.sh > IS_CI:'${IS_CI}'";

IS_SHALLOW=$(git rev-parse --is-shallow-repository);
echo "IS_SHALLOW: $IS_SHALLOW";
if [[ "$IS_SHALLOW" == true ]]; then
	git fetch --unshallow;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo "> Error while fetching unshallow GIT repository!";
		exit ${RESULT};
	fi
fi;

INIT_SUBMODULE=false;
if [[ -f "$CURRENT_PATH/.gitmodules" ]]; then
	INIT_SUBMODULE=false;
else
	INIT_SUBMODULE=true;
fi

declare -a SUBMODULES=(
	"commons"
	"commons-android"
	"app-android"
);
PROJECT_NAME="${GIT_PROJECT_NAME:0:$((${#GIT_PROJECT_NAME} - 7))}";
declare -a SUBMODULES_REPO=(
	"commons"
	"commons-android"
);
if [[ $PROJECT_NAME == *android ]]; then
	SUBMODULES_REPO+=($PROJECT_NAME);
else
	SUBMODULES_REPO+=("$PROJECT_NAME-android");
fi
if [[ $PROJECT_NAME == "mtransit-for-android" ]]; then
	echo "> Main android app: '$PROJECT_NAME' > parser NOT required";
elif [[ $PROJECT_NAME == *bike ]]; then
	echo "> Bike android app: '$PROJECT_NAME' > parser NOT required";
else
	echo "> Bus/Train/... android app: '$PROJECT_NAME' > parser required";
	SUBMODULES+=('parser');
	SUBMODULES_REPO+=('parser');
	SUBMODULES+=('agency-parser');
	SUBMODULES_REPO+=("${PROJECT_NAME}-parser");
fi
echo "> Submodules:";
printf '> - "%s"\n' "${SUBMODULES[@]}";

for S in "${!SUBMODULES[@]}"; do
	SUBMODULE=${SUBMODULES[$S]}
	SUBMODULE_REPO=${SUBMODULES_REPO[$S]}
	echo "--------------------------------------------------------------------------------";
	if [[ -z "${SUBMODULE_REPO}" ]]; then
		echo "SUBMODULE_REPO empty!";
		exit 1;
	fi
	if [[ "$INIT_SUBMODULE" == true ]]; then # ADDNING GIT SUBMODULE
		if [[ -d "$CURRENT_PATH/$SUBMODULE" ]]; then
			echo "> Cannot override '$CURRENT_PATH/$SUBMODULE'!";
			exit 1;
		fi
		echo "> Adding submodule '$SUBMODULE_REPO' in '$SUBMODULE'...";
		git submodule add git://github.com/mtransitapps/$SUBMODULE_REPO.git $SUBMODULE;
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo "> Error while cloning '$SUBMODULE_REPO' submodule in '$SUBMODULE'!";
			exit ${RESULT};
		fi
		echo "> Adding submodule '$SUBMODULE_REPO' in '$SUBMODULE'... DONE";
	fi
	if ! [[ -d "$CURRENT_PATH/$SUBMODULE" ]]; then
		echo "> Submodule directory '$CURRENT_PATH/$SUBMODULE' does NOT exist!";
		exit 1;
	fi
	cd $CURRENT_PATH/$SUBMODULE || exit; # >>
	if [[ ${IS_CI} = false ]]; then
		echo "> Setting submodule remote URL '$SUBMODULE_REPO' in '$SUBMODULE'...";
		git remote set-url origin git@github.com:mtransitapps/$SUBMODULE_REPO.git;
		RESULT=$?;
		if [[ ${RESULT} -ne 0 ]]; then
			echo "> Error while setting remote URL for '$SUBMODULE_REPO' submodule in '$SUBMODULE'!";
			exit ${RESULT};
		fi
		echo "> Setting submodule remote URL '$SUBMODULE_REPO' in '$SUBMODULE'... DONE";
	fi
	echo "> Setting submodule branch '$GIT_BRANCH' in '$SUBMODULE'...";
	git checkout $GIT_BRANCH;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo "> Error while checkint out $GIT_BRANCH in '$SUBMODULE_REPO' submodule in '$SUBMODULE'!";
		exit ${RESULT};
	fi
	echo "> Setting submodule branch '$GIT_BRANCH' in '$SUBMODULE'... DONE";
	cd $CURRENT_PATH || exit; # <<
	echo "--------------------------------------------------------------------------------";
done

DEST_PATH=".";

echo "--------------------------------------------------------------------------------";
echo "> Deploying shared files...";
SRC_DIR_PATH="commons/shared";
for FILENAME in $(ls -a $SRC_DIR_PATH/) ; do
	SRC_FILE_PATH=$SRC_DIR_PATH/$FILENAME;
	if [[ $FILENAME == "." ]] || [[ $FILENAME == ".." ]]; then
		continue;
	fi
	DEST_FILE_PATH="$DEST_PATH/$FILENAME"
	if [[ -f $SRC_FILE_PATH ]]; then
		echo "--------------------------------------------------------------------------------";
		if [[ -f "$DEST_FILE_PATH" ]]; then
			echo "> File '$DEST_FILE_PATH' ($SRC_FILE_PATH) exists in target directory!";
			ls -l $DEST_FILE_PATH;
			exit 1;
		fi
		echo "> Deploying '$SRC_FILE_PATH' in '$DEST_PATH'...";
		cp -n $SRC_FILE_PATH $DEST_FILE_PATH;
		RESULT=$?;
		echo "> Deploying '$SRC_FILE_PATH' in '$DEST_PATH'... DONE";
		if [[ ${RESULT} -ne 0 ]]; then
			echo "> Error while deploying '$SRC_FILE_PATH' to '$DEST_PATH'!";
			exit ${RESULT};
		fi
		echo "--------------------------------------------------------------------------------";
	elif [[ -d "$SRC_FILE_PATH" ]]; then
		if ! [[ -d "$DEST_FILE_PATH" ]]; then
			mkdir $DEST_FILE_PATH;
			RESULT=$?;
			if [[ ${RESULT} -ne 0 ]]; then
				echo "> Error while creating directory '$DEST_FILE_PATH' in target directory!";
				exit ${RESULT};
			fi
		fi
		S_DEST_PATH="${DEST_PATH}/${FILENAME}";
		for S_FILENAME in $(ls -a $SRC_DIR_PATH/${FILENAME}/) ; do
			S_SRC_FILE_PATH=$SRC_DIR_PATH/${FILENAME}/$S_FILENAME;
			if [[ $S_FILENAME == "." ]] || [[ $S_FILENAME == ".." ]]; then
				continue;
			fi
			S_DEST_FILE_PATH="$S_DEST_PATH/$S_FILENAME"
			if [[ -f "$S_DEST_FILE_PATH" ]]; then
				echo "> File '$S_DEST_FILE_PATH' ($S_SRC_FILE_PATH) exists in target directory!";
				ls -l $S_DEST_FILE_PATH;
				exit 1;
			fi
			if [[ -d "$S_DEST_FILE_PATH" ]]; then
				SS_DEST_PATH="${S_DEST_PATH}/${S_FILENAME}";
				for SS_FILENAME in $(ls -a $SRC_DIR_PATH/${FILENAME}/${S_FILENAME}/) ; do
					SS_SRC_FILE_PATH=$SRC_DIR_PATH/${FILENAME}/${S_FILENAME}/$SS_FILENAME;
					if [[ $SS_FILENAME == "." ]] || [[ $SS_FILENAME == ".." ]]; then
						continue;
					fi
					SS_DEST_FILE_PATH="$SS_DEST_PATH/$SS_FILENAME"
					if [[ -f "$SS_DEST_FILE_PATH" ]]; then
						echo "> File '$SS_DEST_FILE_PATH' ($SS_SRC_FILE_PATH) exists in target directory!";
						ls -l $SS_DEST_FILE_PATH;
						exit 1;
					fi
					if [[ -d "$SS_DEST_FILE_PATH" ]]; then
						echo "> Directory '$SS_DEST_FILE_PATH' ($SS_SRC_FILE_PATH) exists in target directory!";
						ls -l $SS_DEST_FILE_PATH;
						exit 1;
					fi
					echo "--------------------------------------------------------------------------------";
					echo "> Deploying '$SS_SRC_FILE_PATH' in '$SS_DEST_PATH'...";
					cp -nR $SS_SRC_FILE_PATH $SS_DEST_PATH/;
					RESULT=$?;
					echo "> Deploying '$SS_SRC_FILE_PATH' in '$SS_DEST_PATH'... DONE";
					if [[ ${RESULT} -ne 0 ]]; then
						echo "Error while deploying '$SS_SRC_FILE_PATH' to '$SS_FILENAME'!";
						exit ${RESULT};
					fi
					echo "--------------------------------------------------------------------------------";
				done
			else
				echo "--------------------------------------------------------------------------------";
				echo "> Deploying '$S_SRC_FILE_PATH' in '$S_DEST_PATH'...";
				cp -nR $S_SRC_FILE_PATH $S_DEST_PATH/;
				RESULT=$?;
				echo "> Deploying '$S_SRC_FILE_PATH' in '$S_DEST_PATH'... DONE";
				if [[ ${RESULT} -ne 0 ]]; then
					echo "> Error while deploying '$S_SRC_FILE_PATH' to '$S_FILENAME'!";
					exit ${RESULT};
				fi
				echo "--------------------------------------------------------------------------------";
			fi
		done
	else #WTF
		echo "> File to deploy '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
		ls -l $FILENAME;
		exit 1;
	fi
done
echo "> Deploying shared files... DONE";
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
echo "> Deploying optional shared files...";
SRC_DIR_PATH="commons/shared-opt-dir";
for FILENAME in $(ls -a $SRC_DIR_PATH/) ; do
	SRC_FILE_PATH=$SRC_DIR_PATH/$FILENAME;
	if [[ $FILENAME == "." ]] || [[ $FILENAME == ".." ]]; then
		continue;
	fi
	DEST_FILE_PATH="$DEST_PATH/$FILENAME"
	if [[ -f $SRC_FILE_PATH ]]; then
		echo "--------------------------------------------------------------------------------";
		if [[ -f "$DEST_FILE_PATH" ]]; then
			echo "> File '$DEST_FILE_PATH' ($SRC_FILE_PATH) exists in target directory!";
			ls -l $DEST_FILE_PATH;
			exit 1;
		fi
		echo "> Deploying '$SRC_FILE_PATH' in '$DEST_PATH'...";
		cp -n $SRC_FILE_PATH $DEST_FILE_PATH;
		RESULT=$?;
		echo "> Deploying '$SRC_FILE_PATH' in '$DEST_PATH'... DONE";
		if [[ ${RESULT} -ne 0 ]]; then
			echo "> Error while deploying '$SRC_FILE_PATH' to '$DEST_PATH'!";
			exit ${RESULT};
		fi
		echo "--------------------------------------------------------------------------------";
	elif [[ -d "$SRC_FILE_PATH" ]]; then
		if ! [[ -d "$DEST_FILE_PATH" ]]; then
			echo "> Skip optional directory '$DEST_FILE_PATH' in target directory.";
			continue;
		fi
		S_DEST_PATH="${DEST_PATH}/${FILENAME}";
		for S_FILENAME in $(ls -a $SRC_DIR_PATH/${FILENAME}/) ; do
			S_SRC_FILE_PATH=$SRC_DIR_PATH/${FILENAME}/$S_FILENAME;
			if [[ $S_FILENAME == "." ]] || [[ $S_FILENAME == ".." ]]; then
				continue;
			fi
			S_DEST_FILE_PATH="$S_DEST_PATH/$S_FILENAME"
			if [[ -f "$S_DEST_FILE_PATH" ]]; then
				echo "> File '$S_DEST_FILE_PATH' ($S_SRC_FILE_PATH) exists in target directory!";
				ls -l $S_DEST_FILE_PATH;
				exit 1;
			fi
			if [[ -d "$S_DEST_FILE_PATH" ]]; then
				SS_DEST_PATH="${S_DEST_PATH}/${S_FILENAME}";
				for SS_FILENAME in $(ls -a $SRC_DIR_PATH/${FILENAME}/${S_FILENAME}/) ; do
					SS_SRC_FILE_PATH=$SRC_DIR_PATH/${FILENAME}/${S_FILENAME}/$SS_FILENAME;
					if [[ $SS_FILENAME == "." ]] || [[ $SS_FILENAME == ".." ]]; then
						continue;
					fi
					SS_DEST_FILE_PATH="$SS_DEST_PATH/$SS_FILENAME"
					if [[ -f "$SS_DEST_FILE_PATH" ]]; then
						echo "> File '$SS_DEST_FILE_PATH' ($SS_SRC_FILE_PATH) exists in target directory!";
						ls -l $SS_DEST_FILE_PATH;
						exit 1;
					fi
					if [[ -d "$SS_DEST_FILE_PATH" ]]; then
						echo "> Directory '$SS_DEST_FILE_PATH' ($SS_SRC_FILE_PATH) exists in target directory!";
						ls -l $SS_DEST_FILE_PATH;
						exit 1;
					fi
					echo "--------------------------------------------------------------------------------";
					echo "> Deploying '$SS_SRC_FILE_PATH' in '$SS_DEST_PATH'...";
					cp -nR $SS_SRC_FILE_PATH $SS_DEST_PATH/;
					RESULT=$?;
					echo "> Deploying '$SS_SRC_FILE_PATH' in '$SS_DEST_PATH'... DONE";
					if [[ ${RESULT} -ne 0 ]]; then
						echo "Error while deploying '$SS_SRC_FILE_PATH' to '$SS_FILENAME'!";
						exit ${RESULT};
					fi
					echo "--------------------------------------------------------------------------------";
				done
			else
				echo "--------------------------------------------------------------------------------";
				echo "> Deploying '$S_SRC_FILE_PATH' in '$S_DEST_PATH'...";
				cp -nR $S_SRC_FILE_PATH $S_DEST_PATH/;
				RESULT=$?;
				echo "> Deploying '$S_SRC_FILE_PATH' in '$S_DEST_PATH'... DONE";
				if [[ ${RESULT} -ne 0 ]]; then
					echo "> Error while deploying '$S_SRC_FILE_PATH' to '$S_FILENAME'!";
					exit ${RESULT};
				fi
				echo "--------------------------------------------------------------------------------";
			fi
		done
	else #WTF
		echo "> File to deploy '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
		ls -l $FILENAME;
		exit 1;
	fi
done
echo "> Deploying optional shared files... DONE";
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
echo "> Deploying overwriten shared files...";
SRC_DIR_PATH="commons/shared-overwrite";
for FILENAME in $(ls -a $SRC_DIR_PATH/) ; do
	SRC_FILE_PATH=$SRC_DIR_PATH/$FILENAME;
	if [[ $FILENAME == "." ]] || [[ $FILENAME == ".." ]]; then
		continue;
	fi
	DEST_FILE_PATH="$DEST_PATH/$FILENAME"
	if [[ -f $SRC_FILE_PATH ]]; then
		echo "--------------------------------------------------------------------------------";
		echo "> Deploying '$SRC_FILE_PATH' in '$DEST_PATH'...";
		cp $SRC_FILE_PATH $DEST_FILE_PATH;
		RESULT=$?;
		echo "> Deploying '$SRC_FILE_PATH' in '$DEST_PATH'... DONE";
		if [[ ${RESULT} -ne 0 ]]; then
			echo "> Error while deploying '$SRC_FILE_PATH' to '$DEST_PATH'!";
			exit ${RESULT};
		fi
		echo "--------------------------------------------------------------------------------";
	elif [[ -d "$SRC_FILE_PATH" ]]; then
		if ! [[ -d "$DEST_FILE_PATH" ]]; then
			mkdir $DEST_FILE_PATH;
			RESULT=$?;
			if [[ ${RESULT} -ne 0 ]]; then
				echo "> Error while creating directory '$DEST_FILE_PATH' in target directory!";
				exit ${RESULT};
			fi
		fi
		S_DEST_PATH="${DEST_PATH}/${FILENAME}";
		for S_FILENAME in $(ls -a $SRC_DIR_PATH/${FILENAME}/) ; do
			S_SRC_FILE_PATH=$SRC_DIR_PATH/${FILENAME}/$S_FILENAME;
			if [[ $S_FILENAME == "." ]] || [[ $S_FILENAME == ".." ]]; then
				continue;
			fi
			S_DEST_FILE_PATH="$S_DEST_PATH/$S_FILENAME"
			if [[ -d "$S_DEST_FILE_PATH" ]]; then
				SS_DEST_PATH="${S_DEST_PATH}/${S_FILENAME}";
				for SS_FILENAME in $(ls -a $SRC_DIR_PATH/${FILENAME}/${S_FILENAME}/) ; do
					SS_SRC_FILE_PATH=$SRC_DIR_PATH/${FILENAME}/${S_FILENAME}/$SS_FILENAME;
					if [[ $SS_FILENAME == "." ]] || [[ $SS_FILENAME == ".." ]]; then
						continue;
					fi
					SS_DEST_FILE_PATH="$SS_DEST_PATH/$SS_FILENAME"
					echo "--------------------------------------------------------------------------------";
					echo "> Deploying '$SS_SRC_FILE_PATH' in '$SS_DEST_PATH'...";
					cp -R $SS_SRC_FILE_PATH $SS_DEST_PATH/;
					RESULT=$?;
					echo "> Deploying '$SS_SRC_FILE_PATH' in '$SS_DEST_PATH'... DONE";
					if [[ ${RESULT} -ne 0 ]]; then
						echo "Error while deploying '$SS_SRC_FILE_PATH' to '$SS_FILENAME'!";
						exit ${RESULT};
					fi
					echo "--------------------------------------------------------------------------------";
				done
			else
				echo "--------------------------------------------------------------------------------";
				echo "> Deploying '$S_SRC_FILE_PATH' in '$S_DEST_PATH'...";
				cp -R $S_SRC_FILE_PATH $S_DEST_PATH/;
				RESULT=$?;
				echo "> Deploying '$S_SRC_FILE_PATH' in '$S_DEST_PATH'... DONE";
				if [[ ${RESULT} -ne 0 ]]; then
					echo "> Error while deploying '$S_SRC_FILE_PATH' to '$S_FILENAME'!";
					exit ${RESULT};
				fi
				echo "--------------------------------------------------------------------------------";
			fi
		done
	else #WTF
		echo "> File to deploy '$FILENAME' ($SRC_FILE_PATH) is neither a directory or a file!";
		ls -l $FILENAME;
		exit 1;
	fi
done
echo "> Deploying overwriten shared files... DONE";
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> DEPLOY SYNC... DONE";
echo "================================================================================";
