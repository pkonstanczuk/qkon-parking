#!/usr/bin/env bash
export ENVIRONMENT=${BITBUCKET_PR_ID}
#Can be empty for destroy script
export TF_VAR_code_version=
if [ "$1" == "--ci-version" ]; then
    export ENVIRONMENT=$2
fi
if [ -z "$ENVIRONMENT" ]
then
      echo 'Error! Can be run only on CI/CD'
      exit 1
fi
echo "Proceeding with destroying of environment ${ENVIRONMENT}"
export DEVOPS_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
#Doesn't really matter during destroy, just needs to be something
${DEVOPS_PATH}/downloadApiDefinition.py ${TF_VAR_code_version}
cd "${DEVOPS_PATH}"
terraform init -input=false
terraform workspace select ${ENVIRONMENT} || terraform workspace new ${ENVIRONMENT}
terraform validate
terraform destroy -auto-approve -parallelism=20  -var-file="CI.tfvars"
sleep 5
#Repeated because https://github.com/hashicorp/terraform-provider-aws/issues/16439
terraform destroy -auto-approve -parallelism=20  -var-file="CI.tfvars"
sleep 5
terraform destroy -auto-approve -parallelism=20  -var-file="CI.tfvars"
terraform workspace select default
terraform workspace delete ${ENVIRONMENT}

