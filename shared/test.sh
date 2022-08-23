#!/usr/bin/env bash
set -e
PARENT_PATH=$( cd "$(dirname "$0")" ; pwd -P)
cd ${PARENT_PATH}/shared_python
pip3 install ${PARENT_PATH}/shared_python
pip3 install -r ${PARENT_PATH}/requirements-test.txt
cd ..
pytest -v -o junit_family=xunit1 --cov=. --cov-report xml:test-reports/coverage.xml  --junitxml=test-reports/nosetests.xml
cd ${PARENT_PATH}/shared_python
poetry install
rm -f ${PARENT_PATH}/shared_python/poetry.lock