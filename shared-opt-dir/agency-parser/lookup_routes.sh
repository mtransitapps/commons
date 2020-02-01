#!/bin/bash
echo ">> Looking-up in gtfs/routes.txt '${@}'...";
echo "--------------------------------------------------------------------------------";

head -n1 input/gtfs/routes.txt;

cat input/gtfs/routes.txt | grep --color=auto -i "$@";

echo "--------------------------------------------------------------------------------";
echo ">> Looking-up in gtfs/routes.txt '${@}'... DONE";
