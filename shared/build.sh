#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> BUILD ALL...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

setGitBranch

CONFIRM=false;

setIsCI;

setGradleArgs;

declare -a EXCLUDE=(".git" "test" "build" "gen" "gradle");

echo "> CLEANING FOR '$AGENCY_ID'...";

if [[ $CIRCLECI != "true" ]]; then
	for d in ${PWD}/* ; do
		DIRECTORY=$(basename ${d});
		if ! [[ -d "$d" ]]; then
			echo "> Skip GIT cleaning (not a directory) '$DIRECTORY'.";
			echo "--------------------------------------------------------------------------------";
			continue;
		fi
		if contains ${DIRECTORY} ${EXCLUDE[@]}; then
			echo "> Skip GIT cleaning in excluded directory '$DIRECTORY'.";
			echo "--------------------------------------------------------------------------------";
			continue;
		fi
		if [[ -d "$d" ]]; then
			# TODO only if not master????
			cd ${d} || exit;
			echo "> GIT cleaning in '$DIRECTORY'...";
			GIT_REV_PARSE_HEAD=$(git rev-parse HEAD);
			GIT_REV_PARSE_REMOTE_BRANCH=$(git rev-parse origin/${GIT_BRANCH});
			if [[ "$GIT_REV_PARSE_HEAD" != "$GIT_REV_PARSE_REMOTE_BRANCH" ]]; then
				echo "> GIT repo outdated in '$DIRECTORY' (local:$GIT_REV_PARSE_HEAD|origin/$GIT_BRANCH:$GIT_REV_PARSE_REMOTE_BRANCH).";
				exit 1;
			else
				echo "> GIT repo up-to-date in '$DIRECTORY' (local:$GIT_REV_PARSE_HEAD|origin/$GIT_BRANCH:$GIT_REV_PARSE_REMOTE_BRANCH).";
			fi

			git checkout ${GIT_BRANCH};
			checkResult $? ${CONFIRM};
			echo "> GIT cleaning in '$DIRECTORY'... DONE";
			cd ..;
			echo "--------------------------------------------------------------------------------";
		fi
	done
fi

echo "--------------------------------------------------------------------------------";
echo "GRADLE VERSION:";
./gradlew --version ${GRADLE_ARGS};
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
echo "JAVA VERSION:";
java -version;
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
echo "CURL VERSION:";
curl --version;
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
echo "OPENSSL VERSION:";
openssl version;
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
echo "AWK VERSION:";
awk --version;
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
echo "GAWK VERSION:";
gawk --version;
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
echo "MAWK VERSION:";
mawk --version;
echo "--------------------------------------------------------------------------------";

echo "--------------------------------------------------------------------------------";
echo "SPLIT VERSION:";
split --version;
echo "--------------------------------------------------------------------------------";

if [[ -d "agency-parser" ]] && [[ $GIT_BRANCH != "master" ]]; then
	echo "> CLEANING FOR '$AGENCY_ID' (GRADLE BUILD)...";

	./gradlew :commons-java:clean ${GRADLE_ARGS};
	checkResult $? ${CONFIRM};

	./gradlew :parser:clean ${GRADLE_ARGS};
	checkResult $? ${CONFIRM};

	./gradlew :agency-parser:clean ${GRADLE_ARGS};
	checkResult $? ${CONFIRM};
	echo "> CLEANING FOR '$AGENCY_ID' (GRADLE BUILD)... DONE";

	echo "> DOWNLOADING DATA FOR '$AGENCY_ID'...";
	cd agency-parser || exit; # >>

	./download.sh;
	checkResult $? ${CONFIRM};

	../commons/gtfs/gtfs-validator.sh "input/gtfs.zip" "output/current";
  # checkResult $?; # too many errors for now

  if [[ -e "input/gtfs_next.zip" ]]; then
    ../commons/gtfs/gtfs-validator.sh "input/gtfs_next.zip" "output/next";
    # checkResult $?; # too many errors for now
  fi

	./unzip_gtfs.sh;
	checkResult $? ${CONFIRM};

	echo "> DOWNLOADING DATA FOR '$AGENCY_ID'... DONE";

	echo "> BUILDING FOR '$AGENCY_ID' (GRADLE BUILD)... ";
	../gradlew :commons-java:build ${GRADLE_ARGS}; #includes test
	checkResult $? ${CONFIRM};

	../gradlew :parser:build ${GRADLE_ARGS}; #includes test
	checkResult $? ${CONFIRM};

	echo "> BUILDING FOR '$AGENCY_ID' (GRADLE BUILD)... DONE";

	echo "> PARSING DATA FOR '$AGENCY_ID'...";

  # CURRENT...
	../gradlew :agency-parser:build ${GRADLE_ARGS};
	checkResult $? ${CONFIRM};

	./parse_current.sh;
	checkResult $? ${CONFIRM};
	# CURRENT... DONE

	# NEXT...
	../gradlew :agency-parser:build ${GRADLE_ARGS};
	checkResult $? ${CONFIRM};

	./parse_next.sh;
	checkResult $? ${CONFIRM};
	# NEXT... DONE

	./list_change.sh;
	checkResult $? ${CONFIRM};

	cd ..; # <<
	echo "> PARSING DATA FOR '$AGENCY_ID'... DONE";
else
	echo "> SKIP PARSING FOR '$AGENCY_ID' (branch:$GIT_BRANCH).";
fi

echo "> BUILDING ANDROID APP FOR '$AGENCY_ID'...";
cd app-android || exit;

./build.sh
checkResult $? ${CONFIRM};

cd ..;
echo "> BUILDING ANDROID APP FOR '$AGENCY_ID'... DONE";
echo "--------------------------------------------------------------------------------";

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> BUILD ALL... DONE";
echo "================================================================================";
