#!/bin/bash
SCRIPT_DIR="$(dirname "$0")";
ROOT_DIR="${SCRIPT_DIR}/../.."; ROOT_DIR=$(realpath --relative-to="$ROOT_DIR" "$ROOT_DIR");

source ${ROOT_DIR}/commons/sh/commons.sh;

RESULT_FILE="${ROOT_DIR}/gradle_cache_key_checksum.txt";

if [[ -f ${RESULT_FILE} ]]; then
  rm ${RESULT_FILE};
fi
touch ${RESULT_FILE};

checksum_file() {
  openssl md5 $1 | awk '{print $2}';
}

echo "gradle-cache-" >> ${RESULT_FILE}
checksum_file ${ROOT_DIR}/build.gradle >> ${RESULT_FILE}
checksum_file ${ROOT_DIR}/commons/gradle/libs.versions.toml >> ${RESULT_FILE}
checksum_file ${ROOT_DIR}/commons-java/build.gradle >> ${RESULT_FILE}
checksum_file ${ROOT_DIR}/commons-android/build.gradle >> ${RESULT_FILE}
checksum_file ${ROOT_DIR}/app-android/build.gradle >> ${RESULT_FILE}

if [[ -d "${ROOT_DIR}/parser" ]]; then
    checksum_file ${ROOT_DIR}/parser/build.gradle >> ${RESULT_FILE}
fi
if [[ -d "${ROOT_DIR}/agency-parser" ]]; then
    checksum_file ${ROOT_DIR}/agency-parser/build.gradle >> ${RESULT_FILE}
fi

echo "${RESULT_FILE}:";
echo "----------";
cat ${RESULT_FILE};
echo "----------";
