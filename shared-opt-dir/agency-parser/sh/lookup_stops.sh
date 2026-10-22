#!/bin/bash
echo ">> Looking-up in gtfs/stops.txt '${@}'...";
echo "--------------------------------------------------------------------------------";

head -n1 input/gtfs/stops.txt;

cat input/gtfs/stops.txt | grep --color=auto -i "$@";

echo "--------------------------------------------------------------------------------";
echo ">> Looking-up in gtfs/stops.txt '${@}'... DONE";
