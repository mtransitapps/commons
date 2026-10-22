#!/bin/bash
echo ">> Looking-up in gtfs/stop_times.txt '${@}'...";
echo "--------------------------------------------------------------------------------";

head -n1 input/gtfs/stop_times.txt;

cat input/gtfs/stop_times.txt | grep --color=auto -i "$@";

echo "--------------------------------------------------------------------------------";
echo ">> Looking-up in gtfs/stop_times.txt '${@}'... DONE";
