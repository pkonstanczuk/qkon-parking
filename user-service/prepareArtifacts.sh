#!/usr/bin/env bash
set -e
SERVICE_NAME=user-service
#Generic part below
DEVOPS_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "${DEVOPS_PATH}"
PARENT_PATH=`pwd`
version=$(../version.sh)
./test.sh
FILE_NAME=${SERVICE_NAME}-${version}.zip
FILE_NAME_CONTRACT=${SERVICE_NAME}-contract-${version}.yaml
rm -rf ${PARENT_PATH}/build
mkdir -p ${PARENT_PATH}/build/python
cp -r ${PARENT_PATH}/src ${PARENT_PATH}/build
cd ${PARENT_PATH}/build
find . | grep -E "(__pycache__|.pytest_cache|\.pyc|\.iml|\.pyo$)" | xargs rm -rf
cd ${PARENT_PATH}/src
zip -r ${PARENT_PATH}/build/"${FILE_NAME}" ./*

if [ "$1" == "--publish" ]; then
FILE_NAME_LAYER=${SERVICE_NAME}-layer-${version}.zip
${PARENT_PATH}/../shared/buildLambaLayer.sh ${SERVICE_NAME} $FILE_NAME_LAYER ${PARENT_PATH}/requirements.txt

curl --header "JOB-TOKEN: $CI_JOB_TOKEN" --upload-file ${PARENT_PATH}/build/${FILE_NAME} "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/${FILE_NAME}/${version}/${FILE_NAME}"
curl --header "JOB-TOKEN: $CI_JOB_TOKEN" --upload-file ${PARENT_PATH}/build/${FILE_NAME} "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/${FILE_NAME}/latest/${FILE_NAME}"
fi
rm -rf ${PARENT_PATH}/build/python
rm -rf ${PARENT_PATH}/build/src
