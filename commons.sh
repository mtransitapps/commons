#!/bin/bash
echo "================================================================================";
echo "> LOADING COMMONS...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

# set current working directory to the directory of the script
function setCurrentDirectory() {
	if [ "$#" -lt 1 ]; then
		echo "> setCurrentDirectory() > Illegal number of parameters!";
		exit -1;
	fi
	CURRENT_DIRECTORY=$0;
	cd "$(dirname "$CURRENT_DIRECTORY")";
	echo "> Current directory set to $CURRENT_DIRECTORY.";
}

function checkResult() {
	if [ "$#" -lt 1 ]; then
		echo "> checkResult() > Illegal number of parameters!";
		exit -1;
	fi
	RESULT=$1;
	CONFIRM=false; # OFF by default
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
	LIST=("$@");
	ITEM_IDX=0;
	ITEM=${LIST[ITEM_IDX]};
	unset LIST[ITEM_IDX];
	for e in "${LIST[@]}"; do
		if [ "$e" = "$ITEM" ] ; then
			return 0; # CONTAINS
		fi
	done
	return -1; # NOT CONTAINS
}

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> LOADING COMMONS... DONE";
echo "================================================================================";
