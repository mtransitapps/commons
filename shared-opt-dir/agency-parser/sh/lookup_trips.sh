#!/bin/bash
echo ">> Looking-up in gtfs/trips.txt '${@}'...";
echo "--------------------------------------------------------------------------------";

head -n1 input/gtfs/trips.txt;

cat input/gtfs/trips.txt | grep --color=auto -i "$@";

echo "--------------------------------------------------------------------------------";
echo ">> Looking-up in gtfs/trips.txt '${@}'... DONE";
