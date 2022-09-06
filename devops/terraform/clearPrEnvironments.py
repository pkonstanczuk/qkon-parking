#!/usr/bin/env python3
import os
import re
import subprocess
import sys

_PR_ENV_TO_PRESERVE: str = os.getenv("PR_ENV_TO_PRESERVE", "")
_PERFORMANCE_ENV: str = "performance"

if __name__ == "__main__":
    p = subprocess.run("terraform init -input=false", stdout=subprocess.PIPE, shell=True)
    p = subprocess.run("terraform workspace list", stdout=subprocess.PIPE, shell=True)
    output = p.stdout.decode("utf-8").replace(" ", "").split("\n")
    prEnvs: list[str] = []
    for entry in output:
        if re.match(r"[-+]?\d+(\.0*)?$", entry) is not None and entry not in _PR_ENV_TO_PRESERVE:
            prEnvs.append(entry)
        if entry == _PERFORMANCE_ENV:
            prEnvs.append(_PERFORMANCE_ENV)
    print(f"Found Pr envs to clean: {prEnvs}")
    for entry in prEnvs:
        print(f"Starting cleaning: {entry}")
        output = subprocess.Popen(f"./destroyCI.sh --ci-version {entry}", stdout=subprocess.PIPE, shell=True)
        for c in iter(lambda: output.stdout.read(1), b""):
            sys.stdout.buffer.write(c)
        print(f"FINISHED destroying {entry}")
