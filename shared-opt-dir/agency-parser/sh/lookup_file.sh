#!/bin/bash
echo ">> Looking-up in $1 '${*:2}'...";
echo "--------------------------------------------------------------------------------";

FILE_NAME=$1;

ARGS=${*:2};

HEAD_COMMAND="head -n1 $FILE_NAME";

CAT_COMMAND="cat";
if command -v "batcat" &> /dev/null
then
#    CAT_COMMAND="batcat -l csv --file-name $FILE_NAME";
     CAT_COMMAND="batcat -l csv --paging never --file-name $FILE_NAME";
fi

GREP_COMMAND="";
for arg in $ARGS
do
  GREP_FILE_NAME="";
  if [ -z "$GREP_COMMAND" ]; then
    GREP_FILE_NAME=$FILE_NAME;
    else
    GREP_COMMAND+=" | "
  fi
  GREP_COMMAND="${GREP_COMMAND} grep --color=auto -i \"${arg}\" $GREP_FILE_NAME";
done

COMMAND="($HEAD_COMMAND & $GREP_COMMAND) | $CAT_COMMAND";
eval "$COMMAND";

echo "--------------------------------------------------------------------------------";
echo ">> Looking-up in $1 '${*:2}'... DONE";
