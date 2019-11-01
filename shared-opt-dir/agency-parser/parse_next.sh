#!/bin/bash
echo ">> Parsing Next...";
PARSER_DIRECTORY="../parser";
PARSER_CLASSPATH=$(cat "$PARSER_DIRECTORY/classpath")
CLASS=$(cat "parser_class")
GTFS_ZIP="input/gtfs_next.zip";
if ! [[ -e "input_url_next" ]]; then
	GTFS_ZIP="input/gtfs.zip";
fi
CHANGE_DIRECTORY=$(cat "change_directory");
RES_DIR="res-next"
ARGS="$GTFS_ZIP $CHANGE_DIRECTORY$RES_DIR/raw next_"
java -Xms2048m -Xmx8192m -Dfile.encoding=UTF-8 \
-classpath \
bin:\
${PARSER_CLASSPATH} \
${CLASS} \
${ARGS};
RESULT=$?;
echo ">> Parsing Next... DONE";
exit ${RESULT};
