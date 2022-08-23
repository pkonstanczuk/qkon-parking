#!/usr/bin/env bash
SERVICE_REQUIREMENTS=$3
FILE_NAME_LAYER=$2
SERVICE_NAME=$1
set -e
PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
rm -rf ${PARENT_PATH}/shared_vizyah/dist
cd ${PARENT_PATH}/shared_vizyah
poetry build --format wheel
pip3 install ./dist/shared_vizyah-1.0.0-py3-none-any.whl -t ./dist/python
pip3 install -t ${PARENT_PATH}/shared_vizyah/dist/python -r ${SERVICE_REQUIREMENTS}
#Removing boto libraries as they are already in Lambda
rm -rf ${PARENT_PATH}/shared_vizyah/dist/python/boto*
cd ${PARENT_PATH}/shared_vizyah/dist
zip -r ./"${FILE_NAME_LAYER}" ./python/*
aws s3 cp ${PARENT_PATH}/shared_vizyah/dist/"${FILE_NAME_LAYER}" s3://vizyah-artifacts/${SERVICE_NAME}/"${FILE_NAME_LAYER}"
rm -rf ${PARENT_PATH}/shared_vizyah/dist