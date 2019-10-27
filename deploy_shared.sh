#!/bin/bash
#NO DEPENDENCY <= EXECUTED BEFORE GIT SUBMODULE

echo "================================================================================";
echo "> DEPLOY SHARED...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});

echo "Current directory: $CURRENT_DIRECTORY";

for f in commons/shared/* ; do
	FILE=$(basename ${f});
	if [[ -d "$f" ]]; then
		if ! [[ -d "$FILE" ]]; then
			mkdir $FILE;
			RESULT=$?;
			if [[ ${RESULT} -ne 0 ]]; then
				echo "Error while creating directory '$FILE' in target directory!";
				exit ${RESULT};
			fi
		fi
		for ff in commons/shared/${FILE}/* ; do
			echo "--------------------------------------------------------------------------------";
			FFILE=$(basename ${ff});
			if [[ -f "${FILE}/${FFILE}" ]]; then
				echo "> File '$FFILE' ($ff) exists in target directory!";
				ls -l ${FILE}/${FFILE};
				exit 1;
			fi
			if [[ -d "${FILE}/${FFILE}" ]]; then
				echo "> Directory '$FFILE' ($ff) exists in target directory!";
				ls -l ${FILE}/${FFILE};
				exit 1;
			fi
			echo "> Deploying '$ff' in '$FILE'...";
			cp -nR $ff $FILE/;
			RESULT=$?;
			echo "> Deploying '$ff' in '$FILE'... DONE";
			if [[ ${RESULT} -ne 0 ]]; then
				echo "Error while deploying '$ff' to '$FFILE'!";
				exit ${RESULT};
			fi
			echo "--------------------------------------------------------------------------------";
		done
	else
		echo "--------------------------------------------------------------------------------";
		if [[ -f "$FILE" ]]; then
			echo "> File '$FILE' ($f) exists in target directory!";
			ls -l $FILE;
			exit 1;
		fi
		echo "> Deploying '$f' in '$FILE'...";
		cp -n $f $FILE;
		RESULT=$?;
		echo "> Deploying '$f' in '$FILE'... DONE";
		if [[ ${RESULT} -ne 0 ]]; then
			echo "Error while deploying '$f' to '$FILE'!";
			exit ${RESULT};
		fi
		echo "--------------------------------------------------------------------------------";
	fi
done 


echo "--------------------------------------------------------------------------------";
AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> DEPLOY SHARED... DONE";
echo "================================================================================";
