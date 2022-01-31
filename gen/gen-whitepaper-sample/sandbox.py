#!/usr/bin/env python3
# Copyright © 2021 Broadcom

import logging
import os
import shutil
import sys
from subprocess import CalledProcessError

import helpers.zowe_util as zowe
from helpers.parms import SandboxContext


# Create target directory & all intermediate directories LNK/LNKINC/LOAD etc
def recreatedir(dirname):
    if os.path.exists(dirname):
        shutil.rmtree(dirname)    # Delete the directory
    os.makedirs(dirname)


# Main Where the execution starts
if __name__ == "__main__":
    context = SandboxContext()
    context.gather_params()

    numeric_log_level = getattr(logging, context.vals["log"].upper(), None)
    if not isinstance(numeric_log_level, int):
        raise ValueError('invalid log level: %s' % context.vals['log'])
    if context.vals['log_file'] == 'STDOUT':
        logging.basicConfig(level=numeric_log_level, stream=sys.stdout)
    else:
        logging.basicConfig(filename=context.vals['log-file'], level=numeric_log_level, stream=sys.stdout)

    if context.zowe('output_dir'):
        recreatedir(context.zowe('output_dir'))

    try:
        cmd = context.vals['command']
        sandbox = context.vals['sandbox']
        if cmd == 'empty':
            zowe.empty_sandbox(sandbox, context)
        elif cmd == 'create':
            zowe.create_sandbox(sandbox, context)
        elif cmd == 'delete':
            zowe.empty_sandbox(sandbox, context)
            zowe.delete_sandbox(sandbox, context)
    except CalledProcessError as cpe:
        print('problem invoking command rc=%s, stdout/stderr to follow', cpe.returncode)
        if cpe.stdout:
            print("stdout:\n%s", cpe.stdout)
        if cpe.stderr:
            print("stderr:\n%s", cpe.stderr)
