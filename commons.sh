#!/bin/bash
echo "================================================================================";
echo "> LOADING COMMONS...";
COMMONS_BEFORE_DATE=$(date +%D-%X);
COMMONS_BEFORE_DATE_SEC=$(date +%s);

# set current working directory to the directory of the script
function setCurrentDirectory() {
	if [ "$#" -lt 1 ]; then
		echo "> setCurrentDirectory() > Illegal number of parameters!";
		exit -1;
	fi
	local CURRENT_DIRECTORY=$0;
	cd "$(dirname "$CURRENT_DIRECTORY")";
	echo "> Current directory set to $CURRENT_DIRECTORY.";
}

function checkResult() {
	if [ "$#" -lt 1 ]; then
		echo "> checkResult() > Illegal number of parameters!";
		exit -1;
	fi
	local RESULT=$1;
	local CONFIRM=false; # OFF by default
	if [ "$#" -ge 2 ]; then
		CONFIRM=$2;
	fi
	if [ $RESULT != 0 ]; then
		echo "> FAILED, AGAIN AND AGAIN, FAILED, AGAIN AND AGAIN, FAILED, AGAIN AND AGAIN";
		exit $RESULT;
	else
		if [ "$CONFIRM" == true ]; then
			read  -n 1 -p "Continue?" mainmenuinput;
		fi
	fi
}

function contains() {
	if [ "$#" -lt 2 ]; then
		echo "> contains() > Illegal number of parameters!";
		exit -1;
	fi
	local LIST=("$@");
	local ITEM_IDX=0;
	local ITEM=${LIST[ITEM_IDX]};
	unset LIST[ITEM_IDX];
	for e in "${LIST[@]}"; do
		if [ "$e" = "$ITEM" ] ; then
			return 0; # CONTAINS
		fi
	done
	return -1; # NOT CONTAINS
}

COMMONS_AFTER_DATE=$(date +%D-%X);
COMMONS_AFTER_DATE_SEC=$(date +%s);
COMMONS_DURATION_SEC=$(($COMMONS_AFTER_DATE_SEC-$COMMONS_BEFORE_DATE_SEC));
echo "> LOADING COMMONS... DONE ($COMMONS_DURATION_SEC secs FROM $COMMONS_BEFORE_DATE TO $COMMONS_AFTER_DATE)";
echo "================================================================================";
