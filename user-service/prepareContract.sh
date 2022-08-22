#!/usr/bin/env bash
#Tested with version 4.3.1
set -e
SERVICE_NAME=user-service
CONTRACT_FILE_NAME=${SERVICE_NAME}-contract.yaml
PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "${PARENT_PATH}"
rm -rf ./src/contract
rm -rf ./build
mkdir -p ./docs
mkdir -p ./src/contract
#https://openapi-generator.tech/docs/generators/python-legacy/
java -jar ../shared/openapi-generator-cli.jar generate -g python-flask -i ./contract.yaml -o ./build/ --additional-properties=useNose=true,packageName=contract,generateSourceCodeOnly=true
cp "${PARENT_PATH}"/build/contract/openapi/openapi.yaml "${PARENT_PATH}"/../devops/contracts-ui/contracts/${CONTRACT_FILE_NAME}


# datamodel-codegen does not work with referenced definitions(shared-contract) it is bug
# https://githubhot.com/repo/koxudaxi/datamodel-code-generator/issues/714
# so for now using previous generator which also produces openapi.yaml on the way with resolved references as an input
# to this one
datamodel-codegen --input "${PARENT_PATH}"/../devops/contracts-ui/contracts/${CONTRACT_FILE_NAME} --output src/contract/models.py
#The util below generates also stubs for api.py, useful when implementing new endpoints but it is not needed for app to work
#fastapi-codegen --input ./docs/${CONTRACT_FILE_NAME} --output src/contract/
rm -rf "${PARENT_PATH}"/build
echo "Finished"

