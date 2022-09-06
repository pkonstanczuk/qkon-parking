#!/usr/bin/env bash
# exit when any command fails
set -e
export REGION=eu-central-1
if [ -z "$TF_VAR_code_version" ]
then
      export TF_VAR_code_version=$(../../version.sh)
fi
echo "Deployed version of code is ${TF_VAR_code_version}"

${DEVOPS_PATH}/downloadApiDefinition.py ${TF_VAR_code_version}
terraform init -input=false
terraform workspace select ${ENVIRONMENT} || terraform workspace new ${ENVIRONMENT}

terraform validate
#terraform destroy -var-file="${ENVIRONMENT}.tfvars"
terraform apply -input=false -parallelism=20 -auto-approve -var-file="${ENVIRONMENT}.tfvars"

echo "Redeploy dashboard"
rm -rf dist
mkdir dist
cd dist
SERVICE_NAME=dashboard
FILE_NAME=${SERVICE_NAME}-${TF_VAR_code_version}.zip
#aws s3 cp s3://park1-artifacts/${SERVICE_NAME}/${FILE_NAME} ./
unzip "${FILE_NAME}"
#aws s3 sync --acl private ${DEVOPS_PATH}/dist/vizyah s3://parkq-${ENVIRONMENT}-dashboard-bucket
echo "Finished"
