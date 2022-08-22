#!/usr/bin/env bash
VERSION=${BITBUCKET_BUILD_NUMBER}
if [ -z "$VERSION" ]
then
      VERSION=latest
fi
if [ "$1" == "--publish" ]; then
  git tag "${VERSION}"
  git push origin --tags
fi
echo "${VERSION}"
