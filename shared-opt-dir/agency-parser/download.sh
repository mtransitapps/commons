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

URL=`cat $FILE_PATH/input_url`;
INPUT_DIR="${SCRIPT_DIR}/input";
mkdir -p "${INPUT_DIR}";
download "${URL}" "${INPUT_DIR}/gtfs.zip";
checkResult $?;
${SCRIPT_DIR}/archive.sh "${INPUT_DIR}/gtfs.zip" "${INPUT_DIR}/gtfs";

if [[ -e "$FILE_PATH/input_url_next" ]]; then
	URL=`cat $FILE_PATH/input_url_next`;
	download "${URL}" "${INPUT_DIR}/gtfs_next.zip";
	checkResult $?;
	${SCRIPT_DIR}/archive.sh "${INPUT_DIR}/gtfs_next.zip" "${INPUT_DIR}/gtfs_next";
fi

ARCHIVE_DIR="${SCRIPT_DIR}/archive";
if [[ ${MT_GIT_COMMIT_ENABLED} == true ]]; then
  echo "> Adding ZIP archives changes to git...";
  git -C "$ARCHIVE_DIR" add "*.zip";
  checkResult $? false;
  git -C "$ARCHIVE_DIR" status -sb;
  echo "> Commiting ZIP archives changes to git...";
  git -C "$ARCHIVE_DIR" diff --staged --quiet || git -C "$ARCHIVE_DIR" commit -m "Update GTFS archives";
  checkResult $?;
  git -C "$ARCHIVE_DIR" status -sb;
  echo "> Pushing ZIP archives changes to git...";
  git -C "$ARCHIVE_DIR" push; # git push fails if there are new changes on remote
  checkResult $?;
else
  echo ">> Git commit NOT enabled.. SKIP";
fi

echo ">> Downloading... DONE"
