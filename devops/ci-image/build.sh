#!/usr/bin/env bash
#Tested with version 4.3.1
set -e
#pip3 install awscli
docker build -t qkon/master-ci:latest .
#docker login -u $DOCKERHUB_LOGIN -p $DOCKERHUB_PASS
#docker push qkon/master-ci:latest