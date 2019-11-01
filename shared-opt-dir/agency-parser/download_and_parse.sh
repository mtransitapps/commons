#!/bin/bash
source ../commons/commons.sh
echo ">> Downloading & Parsing..."
chmod +x download.sh;
checkResult $?;
./download.sh
checkResult $?;

chmod +x parse.sh;
checkResult $?;
./parse.sh
checkResult $?;

chmod +x list_change.sh;
checkResult $?;
./list_change.sh
checkResult $?;
echo ">> Downloading & Parsing... DONE"
