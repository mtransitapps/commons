#!/bin/bash
source commons/commons.sh;

RESULT_FILE="gradle_cache_key_checksum.txt";

if [[ -f ${RESULT_FILE} ]]; then
  rm ${RESULT_FILE};
fi
touch ${RESULT_FILE};

checksum_file() {
  openssl md5 $1 | awk '{print $2}';
}

echo "gradle-cache-" >> ${RESULT_FILE}
checksum_file build.gradle >> ${RESULT_FILE}
checksum_file commons/gradle/libs.versions.toml >> ${RESULT_FILE}
checksum_file commons-java/build.gradle >> ${RESULT_FILE}
checksum_file commons-android/build.gradle >> ${RESULT_FILE}
checksum_file app-android/build.gradle >> ${RESULT_FILE}

if [[ -d "parser" ]]; then
    checksum_file parser/build.gradle >> ${RESULT_FILE}
fi
if [[ -d "agency-parser" ]]; then
    checksum_file agency-parser/build.gradle >> ${RESULT_FILE}
fi

echo "${RESULT_FILE}:";
echo "----------";
cat ${RESULT_FILE};
echo "----------";
