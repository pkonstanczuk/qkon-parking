#!/usr/bin/env bash
SERVICE_REQUIREMENTS=$3
FILE_NAME_LAYER=$2
FILE_NAME_LAYER_ZIP=${FILE_NAME_LAYER}.zip
SERVICE_NAME=$1
set -e
PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
rm -rf ${PARENT_PATH}/shared_python/dist
cd ${PARENT_PATH}/shared_python
VER=$(../../version.sh)
poetry build --format wheel
pip3 install ./dist/shared_qkon-1.0.0-py3-none-any.whl -t ./dist/python
pip3 install -t ${PARENT_PATH}/shared_python/dist/python -r ${SERVICE_REQUIREMENTS}
#Removing boto libraries as they are already in Lambda
rm -rf ${PARENT_PATH}/shared_python/dist/python/boto*
cd ${PARENT_PATH}/shared_python/dist
zip -r ./"${FILE_NAME_LAYER_ZIP}" ./python/*
curl --header "JOB-TOKEN: $CI_JOB_TOKEN" --upload-file ${PARENT_PATH}/shared_python/dist/"${FILE_NAME_LAYER_ZIP}" "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/${FILE_NAME_LAYER}/${VER}/${FILE_NAME_LAYER_ZIP}"
curl --header "JOB-TOKEN: $CI_JOB_TOKEN" --upload-file ${PARENT_PATH}/shared_python/dist/"${FILE_NAME_LAYER_ZIP}" "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/${FILE_NAME_LAYER}/latest/${FILE_NAME_LAYER_ZIP}"
rm -rf ${PARENT_PATH}/shared_python/dist