#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/commons.sh;

# RECIPES:
# - ./mtransit-for-android-gradle/commons/runall.sh "[ -d parser ] && git add parser || echo \"> SKIP\"; ";
# - ./mtransit-for-android-gradle/commons/runall.sh "[ -d agency-parser ] && git add agency-parser || echo \"> SKIP\"; ";
# - ./mtransit-for-android-gradle/commons/runall.sh "git commit -m \"Update git submodules\" || echo \"> SKIP\"; "
# - ./mtransit-for-android-gradle/commons/runall.sh "[ -f gradlew ] && rm gradlew || echo \"> SKIP\"; ";
# - ./mtransit-for-android-gradle/commons/runall.sh "./commons/cleanup.sh; ";
# - ./mtransit-for-android-gradle/commons/runall.sh "./commons/sync.sh; ";
# - ./mtransit-for-android-gradle/commons/runall.sh "git status -sb; ";
# - ./mtransit-for-android-gradle/commons/runall.sh "git commit -m \"Update git submodules\" || echo \"> SKIP\"; ";
# - ./mtransit-for-android-gradle/commons/runall.sh "git commit --allow-empty -m \"Update git submodules\"; ";
# - ./mtransit-for-android-gradle/commons/runall.sh "git commit --allow-empty -m \"Trigger build\"; ";
# - ./mtransit-for-android-gradle/commons/runall.sh "[ -f app-android/.gitignore ] && git -C app-android add .gitignore || echo \"> SKIP\"; ";
# - ./mtransit-for-android-gradle/commons/runall.sh "[ -f agency-parser/.gitignore ] && git -C agency-parser add .gitignore || echo \"> SKIP\"; ";
# - ./mtransit-for-android-gradle/commons/runall.sh "[ -f agency-parser/.gitignore ] && git -C agency-parser commit -m \"Update git submodules\" || echo \"> SKIP\"; ";
# - ./mtransit-for-android-gradle/commons/runall.sh "[ -f agency-parser/.gitignore ] && git -C agency-parser push || echo \"> SKIP\"; ";
# CLEANUP:
# - ./mtransit-for-android-gradle/commons/runall.sh "[ -d \"agency-parser/input\" ] && rm -r agency-parser/input/* || echo \"> SKIP\"; "
# - ./mtransit-for-android-gradle/commons/runall.sh "[ -f \"agency-parser/input/gtfs.zip\" ] && rm -r agency-parser/input/gtfs.zip || echo \"> SKIP\"; "
# - ./mtransit-for-android-gradle/commons/runall.sh "[ -d \".gradle\" ] && rm -r .gradle || echo \"> SKIP\"; "

echo "================================================================================";
echo "> RUN ALL...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});

echo "Current directory: '$CURRENT_DIRECTORY'.";

echo "Command: '$@'.";

for FILE_NAME in $(ls -a) ; do
	if [[ $FILE_NAME == "." ]] || [[ $FILE_NAME == ".." ]]; then
		echo "> Skip $FILE_NAME.";
		continue;
	fi
	if ! [[ -d "$FILE_NAME" ]]; then
		echo "> Skip $FILE_NAME (not a directory).";
		continue;
	fi
	echo "--------------------------------------------------------------------------------";
	echo "> Running '$@' in '$FILE_NAME'...";
	cd ${FILE_NAME} || exit;
	
	eval $@;
	checkResult $?;
	
	cd ..;
	echo "> Running '$@' in '$FILE_NAME'... DONE";
	echo "--------------------------------------------------------------------------------";
done

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> DEPLOY SYNC... DONE";
echo "================================================================================";
