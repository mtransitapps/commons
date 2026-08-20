#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> PUSH COMMITS...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

setIsCI;

setGradleArgs;

setGitCommitEnabled;

if [[ ${MT_GIT_COMMIT_ENABLED} != true ]]; then
  echo "> Git commit NOT enabled.. SKIP";
  exit 0 # success
fi
echo "> Git commit enabled ...";

if [[ ${MT_SKIP_PUSH_COMMIT} == true ]]; then
  echo "> MT_SKIP_PUSH_COMMIT=$MT_SKIP_PUSH_COMMIT... SKIP";
  exit 0 # success
fi

cd app-android || exit;
./keys_cleanup.sh; # FAIL OK
cd ..;

setGitUser;

echo "> GIT submodule > push (only when ahead)...";

git submodule foreach --recursive '
  SUB_PATH="$displaypath"
  echo "--------------------------------------------------------------------------------"
  echo "> Submodule: $name ($SUB_PATH)"

  # Determine current branch (empty if detached HEAD)
  BRANCH="$(git symbolic-ref --short -q HEAD)"
  if [ -z "$BRANCH" ]; then
    echo "> Detached HEAD... SKIP"
    exit 0
  fi

  # Ensure upstream exists, fallback to origin/<branch> when possible
  UPSTREAM="$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || true)"
  if [[ -z "$UPSTREAM" ]]; then
    if git show-ref --verify --quiet "refs/remotes/origin/$BRANCH"; then
      UPSTREAM="origin/$BRANCH"
    else
      echo "> No upstream for $BRANCH... SKIP"
      exit 0
    fi
  fi

  # Count commits ahead of upstream
  AHEAD_COUNT="$(git rev-list --count "${UPSTREAM}..HEAD" 2>/dev/null || echo 0)"
  if [[ "$AHEAD_COUNT" -gt 0 ]]; then
    echo "> Ahead of $UPSTREAM by $AHEAD_COUNT commit(s)... PUSH"
    git push
    RC=$?
    if [[ $RC -ne 0 ]]; then
      echo "> Push failed for submodule: $name"
      exit $RC
    fi
    echo "> Push done for submodule: $name"
  else
    echo "> No new commit to push... SKIP"
  fi
'
checkResult $?;
echo "> GIT submodule > push... DONE";

echo "> GIT > push...";
git push; # git push fails if there are new changes on remote
checkResult $?;
echo "> GIT > push... DONE";

printGitStatus;

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> PUSH COMMITS... DONE";
echo "================================================================================";
