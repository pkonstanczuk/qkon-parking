#!/usr/bin/env bash
VERSION=${CI_PIPELINE_IID}
if [ -z "$VERSION" ]
then
      VERSION=latest
fi
if [ "$1" == "--publish" ]; then
  git tag "${VERSION}"
  git push origin --tags
fi
echo "${VERSION}"
