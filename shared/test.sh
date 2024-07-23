#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> TEST ALL...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

CONFIRM=false;

setIsCI;

setGradleArgs;

echo "> BUILDING FOR '$AGENCY_ID' (GRADLE BUILD)... ";
./gradlew :commons-java:test ${GRADLE_ARGS}; # build includes test
checkResult $? ${CONFIRM};

if [[ -d "parser" ]]; then
	./gradlew :parser:test ${GRADLE_ARGS}; # build includes test
	checkResult $? ${CONFIRM};
fi

if [[ -d "agency-parser" ]]; then
	./gradlew :agency-parser:test ${GRADLE_ARGS}; # build includes test
	checkResult $? ${CONFIRM};
fi

echo "> BUILDING FOR '$AGENCY_ID' (GRADLE BUILD)... DONE";

echo "> BUILDING ANDROID APP FOR '$AGENCY_ID'...";
cd app-android || exit;

echo ">> Setup-ing keys...";
./keys_setup.sh;
checkResult $?;
echo ">> Setup-ing keys... DONE";

echo ">> Running test...";
../gradlew :commons-android:testDebugUnitTest :app-android:testDebugUnitTest ${GRADLE_ARGS};
RESULT=$?;
checkResult ${RESULT};
echo ">> Running test... DONE";

echo ">> Running dependency guard...";
../gradlew :app-android:dependencyGuard :parser:dependencyGuard ${GRADLE_ARGS};
RESULT=$?;
checkResult ${RESULT};
echo ">> Running dependency guard... DONE";

echo ">> Running lint...";
../gradlew :app-android:lintDebug ${GRADLE_ARGS};
RESULT=$?;
checkResult ${RESULT};
echo ">> Running lint... DONE";

echo ">> Cleaning keys...";
./keys_cleanup.sh;
checkResult $?;
echo ">> Cleaning keys... DONE";

cd ..;
echo "> BUILDING ANDROID APP FOR '$AGENCY_ID'... DONE";
echo "--------------------------------------------------------------------------------";

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> TEST ALL... DONE";
echo "================================================================================";
