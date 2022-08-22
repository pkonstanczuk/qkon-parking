#!/usr/bin/env bash
set -e
PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
echo Script location: "${PARENT_PATH}"
cd "${PARENT_PATH}"
npm list -g swagger-ui-watcher || npm install swagger-ui-watcher -g
swagger-ui-watcher -h localhost -p 8126 contract.yaml
