#!/bin/bash
source ../commons/commons.sh
echo ">> Pre Parsing...";
COMMON_DIR="src/main/java/org/mtransit/parser";
DIR_NAME=$(ls ${COMMON_DIR});
JAVA_FILES_DIR="$COMMON_DIR/$DIR_NAME";
JAVA_STOPS_FILE="$JAVA_FILES_DIR/Stops.java";

GTFS_DIR="input/gtfs";
if [[ -f "input/gtfs_next" ]]; then
    GTFS_DIR="input/gtfs_next";
fi

COLUMNS=$(head -n1 ${GTFS_DIR}/stops.txt);
COLUMNS_ARRAY=($(echo $COLUMNS | tr "," "\n"))
STOP_CODE_IDX=-1;
STOP_ID_IDX=-1;
STOP_NAME_IDX=-1;
for i in "${!COLUMNS_ARRAY[@]}"; do
	COLUMN=${COLUMNS_ARRAY[$i]};
	if [[ ${COLUMN} == *stop_id* ]]; then
		STOP_ID_IDX=$(($i+1));
		echo ">> Stop ID column found at index: $STOP_ID_IDX.";
	elif [[ ${COLUMN} == *stop_code* ]]; then
		STOP_CODE_IDX=$(($i+1));
		echo ">> Stop code column found at index: $STOP_CODE_IDX.";
	elif [[ ${COLUMN} == *stop_name* ]]; then
		STOP_NAME_IDX=$(($i+1));
		echo ">> Stop name column found at index: $STOP_NAME_IDX.";
	fi
done

if [[ ${STOP_ID_IDX} -lt 0 ]]; then
	echo ">> Cannot find stop id!";
	exit 1;
fi
if [[ ${STOP_CODE_IDX} -lt 0 ]]; then
	echo ">> Cannot find [optional] stop code > using stop ID '$STOP_ID_IDX'.";
	STOP_CODE_IDX=${STOP_ID_IDX};
fi
if [[ ${STOP_NAME_IDX} -lt 0 ]]; then
	echo ">> Cannot find stop name!";
	exit 1;
fi

rm -f ${GTFS_DIR}/stops_split.txt.*;
checkResult $? false;

split -d -l 5000 ${GTFS_DIR}/stops.txt ${GTFS_DIR}/stops_split.txt.;
checkResult $? false;

echo ">> Pre Parsing > Set Java stops file...";
> ${JAVA_STOPS_FILE}; # empty file
echo "package org.mtransit.parser.$DIR_NAME;" >> ${JAVA_STOPS_FILE};
echo "" >> ${JAVA_STOPS_FILE};
echo "import java.util.HashMap;" >> ${JAVA_STOPS_FILE};
echo "" >> ${JAVA_STOPS_FILE};
echo "public class Stops {" >> ${JAVA_STOPS_FILE};
echo "" >> ${JAVA_STOPS_FILE};
echo "	private static HashMap<String, String> ALL_STOPS;" >> ${JAVA_STOPS_FILE};
echo "" >> ${JAVA_STOPS_FILE};
echo "	public static HashMap<String, String> getALL_STOPS() {" >> ${JAVA_STOPS_FILE};
echo "		if (ALL_STOPS == null) {" >> ${JAVA_STOPS_FILE};
echo "			synchronized (Stops.class) {" >> ${JAVA_STOPS_FILE};
echo "				if (ALL_STOPS == null) {" >> ${JAVA_STOPS_FILE};
echo "					ALL_STOPS = new HashMap<String, String>();" >> ${JAVA_STOPS_FILE};

i=0;
for STOP_FILE in ${GTFS_DIR}/stops_split.txt.* ; do
    i=$(($i+1));
    echo "					ALL_STOPS = init$i(ALL_STOPS);" >> ${JAVA_STOPS_FILE};
done

echo "				}" >> ${JAVA_STOPS_FILE};
echo "			}" >> ${JAVA_STOPS_FILE};
echo "		}" >> ${JAVA_STOPS_FILE};
echo "		return ALL_STOPS;" >> ${JAVA_STOPS_FILE};
echo "	}" >> ${JAVA_STOPS_FILE};

i=0;
for STOP_FILE in ${GTFS_DIR}/stops_split.txt.* ; do
    i=$(($i+1));
    echo "" >> ${JAVA_STOPS_FILE};
    echo "	private static HashMap<String, String> init$i(HashMap<String, String> allStops) {" >> ${JAVA_STOPS_FILE};
    awk \
        -F "\"*,\"*" \
        -v stopCode=${STOP_CODE_IDX} \
        -v stopId=${STOP_ID_IDX} \
        -v stopName=${STOP_NAME_IDX} \
        '{print "		allStops.put(\"" $stopCode "\", \"" $stopId"\"); // " $stopName}' \
        ${STOP_FILE} >> ${JAVA_STOPS_FILE};
        checkResult $? false;
    echo "		return allStops;" >> ${JAVA_STOPS_FILE};
    echo "	}" >> ${JAVA_STOPS_FILE};
done

echo "}" >> ${JAVA_STOPS_FILE};
echo "" >> ${JAVA_STOPS_FILE};
echo ">> Pre Parsing > Set Java stops file... DONE";
echo ">> Pre Parsing... DONE";
