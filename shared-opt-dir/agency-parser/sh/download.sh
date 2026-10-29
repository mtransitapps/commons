#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../.."; ROOT_DIR=$(realpath --relative-to="$PWD" "$ROOT_DIR");

source "${ROOT_DIR}/commons/sh/commons.sh"

echo ">> Downloading..."

setIsCI;

setGitCommitEnabled;

setGitUser;

CONFIG_DIR="${ROOT_DIR}/config";

AGENCY_PARSER_DIR="${ROOT_DIR}/agency-parser";

ARCHIVE_DIR="${AGENCY_PARSER_DIR}/archive";

if [[ ! -f "$CONFIG_DIR/input_url" ]]; then
	echo ">> No input_url file found. Exiting early.";
	exit 0;
fi

if [[ -s "$CONFIG_DIR/input_url_user_agent" ]]; then
	USER_AGENT="$(tr -d $'\r\n' < "$CONFIG_DIR/input_url_user_agent")";
	if [[ -n "$USER_AGENT" ]]; then
		echo ">> Using user agent: '$USER_AGENT'";
		export MT_DOWNLOAD_USER_AGENT="$USER_AGENT";
	fi
fi

URL=`cat $CONFIG_DIR/input_url`;
INPUT_DIR="${AGENCY_PARSER_DIR}/input";
mkdir -p "${INPUT_DIR}";
download "${URL}" "${INPUT_DIR}/gtfs.zip";
checkResult $?;
${SCRIPT_DIR}/archive.sh "${INPUT_DIR}/gtfs.zip" "${INPUT_DIR}/gtfs";
checkResult $?;

if [[ -e "$CONFIG_DIR/input_url_next" ]]; then
	URL=`cat $CONFIG_DIR/input_url_next`;
	download "${URL}" "${INPUT_DIR}/gtfs_next.zip";
	checkResult $?;
	${SCRIPT_DIR}/archive.sh "${INPUT_DIR}/gtfs_next.zip" "${INPUT_DIR}/gtfs_next";
	checkResult $?;
fi

if [[ ${IS_CI} = true ]]; then
  printGitStatus;
fi

echo "DEBUG: -----------------------------------------"
echo "DEBUG: git -C "$ARCHIVE_DIR" diff --staged";
git -C "$ARCHIVE_DIR" diff --staged --quiet;
echo "- RESULT: $?";
git -C "$ARCHIVE_DIR" diff --staged;
echo "DEBUG: -----------------------------------------"
echo "DEBUG: git -C "$ARCHIVE_DIR" diff";
git -C "$ARCHIVE_DIR" diff --quiet;
echo "- RESULT: $?";
git -C "$ARCHIVE_DIR" diff;
echo "DEBUG: -----------------------------------------"

if [[ ${MT_GIT_COMMIT_ENABLED} == true ]]; then
  git -C "$ARCHIVE_DIR" diff --staged --quiet;
  GIT_STAGED_CHANGES=$?; # 0 if no changes
  echo "GIT_STAGED_CHANGES: $GIT_STAGED_CHANGES";
  if [[ $GIT_STAGED_CHANGES -eq 0 ]]; then
    echo "> Adding ZIP archives changes to git...";
    git -C "$ARCHIVE_DIR" add -v ".";
    checkResult $? false;
    if [[ ${IS_CI} = true ]]; then
      git -C "$ARCHIVE_DIR" status -sb;
    fi
  else
    echo "> Adding ZIP archives changes to git... SKIP";
  fi

  MT_SKIP_PUSH_COMMIT=true
  git -C "$ARCHIVE_DIR" diff --staged --quiet;
  GTFS_ARCHIVE_UPDATED=$?; # 0 if no changes
  echo "GTFS_ARCHIVE_UPDATED: $GTFS_ARCHIVE_UPDATED";
  if [[ $GTFS_ARCHIVE_UPDATED -gt 0 && $GIT_STAGED_CHANGES -eq 0 ]]; then
    echo "> Committing ZIP archives changes to git...";
    git -C "$ARCHIVE_DIR" commit -m "CI: Update GTFS archives"
    checkResult $?;
    MT_SKIP_PUSH_COMMIT=false
    # TODO push now?
  else
    echo "> Committing ZIP archives changes to git... SKIP";
  fi
  if [[ ${IS_CI} = true ]]; then
    git -C "$ARCHIVE_DIR" status -sb;
  fi
else
  echo ">> Git commit NOT enabled.. SKIP";
fi

echo "MT_SKIP_PUSH_COMMIT: $MT_SKIP_PUSH_COMMIT";
if [[ ${GITHUB_ACTIONS} = true ]]; then
  echo "MT_SKIP_PUSH_COMMIT=$MT_SKIP_PUSH_COMMIT" >> "$GITHUB_ENV"
else
  export MT_SKIP_PUSH_COMMIT="$MT_SKIP_PUSH_COMMIT"
fi

if [[ ${IS_CI} = true ]]; then
  printGitStatus;
fi

echo ">> Downloading... DONE"
