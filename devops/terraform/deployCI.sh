#!/usr/bin/env bash
# exit when any command fails
set -e
export ENVIRONMENT=${BITBUCKET_PR_ID}
#Put version here is you want to deploy custom version
export TF_VAR_code_version=${BITBUCKET_BUILD_NUMBER}
if [ -z "$ENVIRONMENT" ]
then
      echo 'Error! Can be run only on CI/CD'
      exit 1
fi
echo "Proceeding with creation of environment ${ENVIRONMENT}"
export DEVOPS_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "${DEVOPS_PATH}"
cp CI.tfvars ${ENVIRONMENT}.tfvars
${DEVOPS_PATH}/deploy.sh

