set -e
SERVICE_NAME=user-service
CONTRACT_FILE_NAME=${SERVICE_NAME}-contract.yaml
DEVOPS_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "${DEVOPS_PATH}"
mkdir -p "${DEVOPS_PATH}"/../../devops/contracts-ui/contracts
java -jar "${DEVOPS_PATH}"/../../shared/openapi-generator-cli.jar generate -g python-flask -i "${DEVOPS_PATH}"/../contract.yaml -o "${DEVOPS_PATH}"/../build/ --additional-properties=useNose=true,packageName=contract,generateSourceCodeOnly=true
cp "${DEVOPS_PATH}"/../build/contract/openapi/openapi.yaml "${DEVOPS_PATH}"/../../devops/contracts-ui/contracts/${CONTRACT_FILE_NAME}
rm -rf "${DEVOPS_PATH}"/../build
echo "Finished"

