#!/usr/bin/env bash
set -e #Crash if any step crashes
CURRENT_PATH=`pwd`
PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
echo Script location: "${PARENT_PATH}"
cd "${PARENT_PATH}"
pip3 install -r requirements.txt &>/dev/null
pip3 install -r ./requirements-test.txt &>/dev/null
./prepareContract.sh
#Running twice to check if tests are independent
pytest -v -o junit_family=xunit1 --cov=. --cov-report xml:test-reports/coverage.xml  --junitxml=test-reports/nosetests.xml
pytest -v -o junit_family=xunit1 --cov=. --cov-report xml:test-reports/coverage.xml  --junitxml=test-reports/nosetests.xml

