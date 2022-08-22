#!/usr/bin/env bash
set -e
docker build -t registry.gitlab.com/qak87/qparking:latest .
if [ "$1" == "--publish" ]; then
  docker login registry.gitlab.com
  docker push registry.gitlab.com/qak87/qparking:latest
fi