#!/usr/bin/env bash
PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "${PARENT_PATH}"
set -e
black . --line-length 120 "$@"
