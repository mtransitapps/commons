#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> TEST...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

CONFIRM=false;

setIsCI;

setGradleArgs;

setGitProjectName;

echo "> TESTS FOR '$AGENCY_ID' (GRADLE BUILD)... ";
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

echo "> TESTS FOR '$AGENCY_ID' (GRADLE BUILD)... DONE";

echo "> TESTS ANDROID APP FOR '$AGENCY_ID'...";
cd app-android || exit;

echo ">> Running test...";
../gradlew :commons-android:testDebugUnitTest :app-android:testDebugUnitTest ${GRADLE_ARGS};
RESULT=$?;
checkResult ${RESULT};
echo ">> Running test... DONE";

if [[ $PROJECT_NAME == "mtransit-for-android" ]]; then
	echo ">> Running dependency guard...";
	../gradlew :app-android:dependencyGuard :parser:dependencyGuard ${GRADLE_ARGS};
	RESULT=$?;
	checkResult ${RESULT};
	echo ">> Running dependency guard... DONE";
fi

checkResult ${RESULT};

cd ..;
echo "> TESTS ANDROID APP FOR '$AGENCY_ID'... DONE";
echo "--------------------------------------------------------------------------------";

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> TEST... DONE";
echo "================================================================================";
