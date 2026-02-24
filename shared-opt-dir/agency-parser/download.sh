#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
source ${SCRIPT_DIR}/../commons/commons.sh
echo ">> Downloading..."

setIsCI;

setGitCommitEnabled;

setGitUser;

FILE_PATH="${SCRIPT_DIR}";
if [[ -d "${SCRIPT_DIR}/../config" ]]; then
	FILE_PATH="${SCRIPT_DIR}/../config";
elif [[ -d "${SCRIPT_DIR}/../app-android/config" ]]; then # OLD REPO
	FILE_PATH="${SCRIPT_DIR}/../app-android/config";
fi

ARCHIVE_DIR="${SCRIPT_DIR}/archive";

URL=`cat $FILE_PATH/input_url`;
INPUT_DIR="${SCRIPT_DIR}/input";
mkdir -p "${INPUT_DIR}";
download "${URL}" "${INPUT_DIR}/gtfs.zip";
checkResult $?;
${SCRIPT_DIR}/archive.sh "${INPUT_DIR}/gtfs.zip" "${INPUT_DIR}/gtfs";
checkResult $?;

if [[ -e "$FILE_PATH/input_url_next" ]]; then
	URL=`cat $FILE_PATH/input_url_next`;
	download "${URL}" "${INPUT_DIR}/gtfs_next.zip";
	checkResult $?;
	${SCRIPT_DIR}/archive.sh "${INPUT_DIR}/gtfs_next.zip" "${INPUT_DIR}/gtfs_next";
	checkResult $?;
fi

printGitStatus;

if [[ ${MT_GIT_COMMIT_ENABLED} == true ]]; then
  git -C "$ARCHIVE_DIR" diff --staged --quiet;
  GIT_STAGED_CHANGES=$?; # 0 if no changes
  if [[ $GIT_STAGED_CHANGES -eq 0 ]]; then
    echo "> Adding ZIP archives changes to git...";
    git -C "$ARCHIVE_DIR" add -v ".";
    checkResult $? false;
    git -C "$ARCHIVE_DIR" status -sb;
  else
    echo "> Adding ZIP archives changes to git... SKIP";
  fi

  MT_SKIP_PUSH_COMMIT=true
  git -C "$ARCHIVE_DIR" diff --staged --quiet;
  GTFS_ARCHIVE_UPDATED=$?; # 0 if no changes
  if [[ $GTFS_ARCHIVE_UPDATED -gt 0 && $GIT_STAGED_CHANGES -eq 0 ]]; then
    echo "> Committing ZIP archives changes to git...";
    git -C "$ARCHIVE_DIR" commit -m "CI: Update GTFS archives"
    checkResult $?;
    MT_SKIP_PUSH_COMMIT=false
    # TODO push now?
  else
    echo "> Committing ZIP archives changes to git... SKIP";
  fi
  git -C "$ARCHIVE_DIR" status -sb;
else
  echo ">> Git commit NOT enabled.. SKIP";
fi

echo "MT_SKIP_PUSH_COMMIT: $MT_SKIP_PUSH_COMMIT";
if [[ ${GITHUB_ACTIONS} = true ]]; then
  echo "MT_SKIP_PUSH_COMMIT=$MT_SKIP_PUSH_COMMIT" >> "$GITHUB_ENV"
else
  export MT_SKIP_PUSH_COMMIT="$MT_SKIP_PUSH_COMMIT"
fi

printGitStatus;

echo ">> Downloading... DONE"
