#!/bin/bash
echo ">> Looking-up in gtfs/agency.txt '${@}'...";
echo "--------------------------------------------------------------------------------";

head -n1 input/gtfs/agency.txt;

cat input/gtfs/agency.txt | grep --color=auto -i "$@";

echo "--------------------------------------------------------------------------------";
echo ">> Looking-up in gtfs/agency.txt '${@}'... DONE";
