#!/bin/bash
echo ">> Looking-up in gtfs/frequencies.txt '${@}'...";
echo "--------------------------------------------------------------------------------";

head -n1 input/gtfs/frequencies.txt;

cat input/gtfs/frequencies.txt | grep --color=auto -i "$@";

echo "--------------------------------------------------------------------------------";
echo ">> Looking-up in gtfs/frequencies.txt '${@}'... DONE";
