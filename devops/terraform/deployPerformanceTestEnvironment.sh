#!/usr/bin/env bash
# exit when any command fails
set -e
export ENVIRONMENT=performance
export DEVOPS_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "${DEVOPS_PATH}"
cp CI.tfvars ${ENVIRONMENT}.tfvars
${DEVOPS_PATH}/deploy.sh
