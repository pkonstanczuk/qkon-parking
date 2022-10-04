#!/usr/bin/env bash
if [ -z "$VERSION" ]
then
      VERSION=${CI_PIPELINE_IID}
fi
if [ -z "$VERSION" ]
then
      VERSION=latest
fi
if [ "$1" == "--publish" ]; then
  git tag "${VERSION}"
  git push origin --tags
fi
echo "${VERSION}"
