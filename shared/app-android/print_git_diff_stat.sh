#!/bin/bash
source ../commons/commons.sh

echo "GIT DIFF (not staged):";
echo "==========";
git diff --stat src/main/res-current/;
git diff --stat src/main/res-next/;
git diff src/main/play/release-notes/;
echo "==========";

echo "GIT DIFF (staged):";
git diff --cached --stat src/main/res-current/;
git diff --cached --stat src/main/res-next/;
git diff --cached src/main/play/release-notes/;
echo "==========";